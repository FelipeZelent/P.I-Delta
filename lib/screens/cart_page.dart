import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import '../models/product.dart';
import '../data/cart_repo.dart';
import '../data/orders_repo.dart';
import '../data/coupons_repo.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final couponCtrl = TextEditingController();
  Coupon? appliedCoupon;

  @override
  void dispose() {
    couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = couponCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite um cupom')));
      return;
    }
    final c = await CouponsRepo.instance.getByCode(code);
    if (c == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cupom inválido')));
      setState(() => appliedCoupon = null);
    } else {
      setState(() => appliedCoupon = c);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cupom aplicado: ${c.code} (${c.percent}%)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fa.User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snap) {
        final u = snap.data;

        if (u == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Entre para ver e finalizar seu carrinho.', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                            },
                            child: const Text('Entrar em uma conta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }

        return StreamBuilder<List<CartLine>>(
          stream: CartRepo.instance.streamLines(u.uid),
          builder: (context, s) {
            if (s.hasError) {
              return Center(child: Text('Erro: ${s.error}'));
            }
            if (!s.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = s.data!;
            final subtotal = items.fold<int>(0, (sum, it) => sum + it.lineTotalCents);
            final discountCents = appliedCoupon == null ? 0 : ((subtotal * appliedCoupon!.percent) / 100).round();
            final totalCents = (subtotal - discountCents).clamp(0, subtotal);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: items.isEmpty
              // Carrinho vazio: só a mensagem
                  ? const Center(child: Text('Seu carrinho está vazio'))
              // Carrinho com itens: lista + cupom + resumo + finalizar
                  : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final it = items[i];
                        return Dismissible(
                          key: Key('${it.product.id}-${it.size}-$i'),
                          onDismissed: (_) {
                            CartRepo.instance.remove(
                              uid: u.uid,
                              product: it.product,
                              size: it.size,
                            );
                          },
                          background: _swipeBg(context, false),
                          secondaryBackground: _swipeBg(context, true),
                          child: _CartTile(
                            line: it,
                            onInc: () => CartRepo.instance.updateQty(
                                uid: u.uid, product: it.product, size: it.size, qty: it.qty + 1),
                            onDec: () => CartRepo.instance.updateQty(
                                uid: u.uid, product: it.product, size: it.size, qty: it.qty - 1),
                            onRemove: () => CartRepo.instance.remove(
                                uid: u.uid, product: it.product, size: it.size),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cupom
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Cupom de desconto',
                            hintText: 'EX: 10OFF',
                            suffixIcon: appliedCoupon != null
                                ? IconButton(
                              tooltip: 'Remover cupom',
                              onPressed: () => setState(() => appliedCoupon = null),
                              icon: const Icon(Icons.close),
                            )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _applyCoupon,
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Resumo
                  _SummaryRow(label: 'Subtotal', value: brl(subtotal)),
                  if (appliedCoupon != null) ...[
                    const SizedBox(height: 6),
                    _SummaryRow(
                      label: 'Cupom (${appliedCoupon!.code})',
                      value: '- ${brl(discountCents)}',
                    ),
                  ],
                  const SizedBox(height: 6),
                  const _SummaryRow(label: 'Frete', value: 'Grátis'),
                  const SizedBox(height: 6),
                  const Divider(height: 24),
                  _SummaryRow(label: 'Total', value: brl(totalCents), isTotal: true),
                  const SizedBox(height: 12),

                  // Finalizar
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await OrdersRepo.instance.checkout(
                          uid: u.uid,
                          lines: items,
                          couponCode: appliedCoupon?.code,
                          discountPercent: appliedCoupon?.percent,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pedido criado!')),
                        );
                        setState(() {
                          appliedCoupon = null;
                          couponCtrl.clear();
                        });
                      },
                      child: const Text('Finalizar Compra'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _swipeBg(BuildContext ctx, bool right) {
    final c = Theme.of(ctx).colorScheme.error;
    return Container(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: c.withValues(alpha: .2), borderRadius: BorderRadius.circular(16)),
      child: Icon(Icons.delete, color: c),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.line, required this.onInc, required this.onDec, required this.onRemove});
  final CartLine line;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = line.product;
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A1B1E), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(p.imageUrl, width: 64, height: 64, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Tamanho:', style: TextStyle(color: Colors.white70)),
              Text(line.size, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              Text(brl(p.priceCents), style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary)),
            ]),
          ),
          const SizedBox(width: 12),
          _qtyPill(qty: line.qty, onInc: onInc, onDec: onDec),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline), color: Theme.of(context).colorScheme.error),
        ],
      ),
    );
  }
}

Widget _qtyPill({required int qty, required VoidCallback onInc, required VoidCallback onDec}) {
  return Builder(builder: (context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: .35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _roundIcon(onDec, Icons.remove),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w600))),
        _roundIcon(onInc, Icons.add),
      ]),
    );
  });
}

Widget _roundIcon(VoidCallback onTap, IconData icon) => InkResponse(
  onTap: onTap,
  customBorder: const CircleBorder(),
  radius: 18,
  child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 18)),
);

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.isTotal = false});
  final String label;
  final String value;
  final bool isTotal;
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: style), Text(value, style: style)]);
  }
}
