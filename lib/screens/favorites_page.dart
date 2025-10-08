import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import '../models/product.dart';
import '../widgets/product_cart.dart';
import 'product_detail_page.dart';
import '../data/favorites_repo.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fa.User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snap) {
        final u = snap.data;

        // Deslogado: CTA para login
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
                        const Text(
                          'Entre para ver seus favoritos.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
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

        // Logado: stream de produtos favoritados
        return StreamBuilder<List<Product>>(
          stream: FavoritesRepo.instance.streamProducts(u.uid),
          builder: (context, favSnap) {
            if (favSnap.hasError) {
              return Center(child: Text('Erro: ${favSnap.error}'));
            }
            if (!favSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final products = favSnap.data!;
            if (products.isEmpty) {
              return const Center(child: Text('Nenhum favorito ainda'));
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .72,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => ProductCard(
                  product: products[i],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: products[i]),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
