import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../data/orders_repo.dart';
import '../models/product.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Entre para ver seus pedidos')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de compras')),
      body: StreamBuilder<List<OrderModel>>(
        stream: OrdersRepo.instance.streamByUser(uid),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snap.data!;
          if (orders.isEmpty) return const Center(child: Text('Nenhum pedido'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  String _statusLabel(int s) {
    switch (s) {
      case 1: return 'Criado';
      case 2: return 'Pago';
      case 3: return 'Enviado';
      case 4: return 'Entregue';
      default: return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(_statusLabel(order.status), style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          ...order.items.map((it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(it.image, width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${it.title} · Tam ${it.size} · x${it.qty}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(brl((it.priceDouble * it.qty).round() * 100 ~/ 1), style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
                ]),
              )),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('R\$ ${order.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
          ]),
        ]),
      ),
    );
  }
}
