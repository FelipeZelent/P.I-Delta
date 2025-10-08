import 'package:appstore/widgets/product_cart.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/product_repo.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;

  // categorias do Firestore
  final _categories = const ['todos', 'camisetas', 'blusas', 'calcas', 'coletes'];
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Stream<List<Product>> stream = (selected == 0)
        ? ProductRepo.instance.streamAll()
        : ProductRepo.instance.streamByCategory(_categories[selected]);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isSelected = selected == i;
                final label = _categories[i] == 'todos' ? 'todos' : _categories[i];
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selected = i),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: .30),
                  backgroundColor: const Color(0xFF1A1B1E),
                  side: BorderSide(color: Colors.white.withValues(alpha: .24)),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // grid de produtos (Firestore)
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Erro: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snap.data!;
                if (products.isEmpty) {
                  return const Center(child: Text('Nenhum produto'));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: products[i],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProductDetailPage(product: products[i])),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
