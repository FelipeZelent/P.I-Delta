import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '../models/product.dart';
import '../services/auth_service.dart';
import '../data/favorites_repo.dart';
import '../data/cart_repo.dart';
import 'login_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? size; // tamanho selecionado

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final sizes = p.sizes.isEmpty ? const ['P', 'M', 'G'] : p.sizes;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          // Ícone de favorito com checagem de login e snackbar
          StreamBuilder<fa.User?>(
            stream: AuthService.instance.authStateChanges,
            builder: (context, snap) {
              final u = snap.data;

              if (u == null) {
                return IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entre em uma conta para favoritar')),
                    );
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                );
              }

              return StreamBuilder<bool>(
                stream: FavoritesRepo.instance.isFav(u.uid, p),
                builder: (context, favSnap) {
                  final isFav = favSnap.data ?? false;
                  return IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    onPressed: () async {
                      await FavoritesRepo.instance.toggle(u.uid, p);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav ? 'Removido dos favoritos' : 'Adicionado aos favoritos',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // imagem
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(p.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),

            // título + preço
            Text(p.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              brl(p.priceCents),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // tamanhos
            const Text('Tamanho', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: sizes.map((s) {
                final sel = size == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: sel,
                  onSelected: (_) => setState(() => size = s),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: .30),
                  backgroundColor: const Color(0xFF1A1B1E),
                  side: BorderSide(color: Colors.white.withValues(alpha: .24)),
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              p.description.isEmpty ? '—' : p.description,
              style: const TextStyle(height: 1.4),
            ),

            const SizedBox(height: 24),

            // CTA principal: varia de acordo com login
            StreamBuilder<fa.User?>(
              stream: AuthService.instance.authStateChanges,
              builder: (context, snap) {
                final u = snap.data;
                final logged = u != null;
                return SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: (size == null)
                        ? null
                        : () async {
                      if (!logged) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Entre em uma conta para comprar')),
                        );
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                        return;
                      }
                      await CartRepo.instance.addOrInc(
                        uid: u!.uid,
                        product: p,
                        size: size!,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Adicionado ao carrinho (tam $size)')),
                      );
                    },
                    icon: Icon(logged ? Icons.add_shopping_cart : Icons.login),
                    label: Text(logged ? 'Adicionar ao carrinho' : 'Entrar para comprar'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
