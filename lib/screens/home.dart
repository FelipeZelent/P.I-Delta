import 'package:appstore/screens/favorites_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _pages = const [
    HomePage(),
    FavoritesPage(),
    CartPage(),
    ProfilePage(),
  ];

  static const _titles = ['Home', 'Favoritos', 'Carrinho', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? StreamBuilder<fa.User?>(
          stream: AuthService.instance.authStateChanges,
          builder: (context, snap) {
            final u = snap.data;
            if (u == null) {
              return TextButton(
                onPressed: () async {
                  await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Entrar em uma conta'),
              );
            }
            final name = (u.displayName?.trim().isNotEmpty ?? false)
                ? u.displayName!
                : (u.email?.split('@').first ?? 'Usuário');
            return Text('Olá, $name');
          },
        )
            : Text(_titles[_selectedIndex]),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'carrinho',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'perfil'),
        ],
      ),
    );
  }
}
