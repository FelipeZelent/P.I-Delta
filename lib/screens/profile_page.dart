import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '../services/auth_service.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'orders_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fa.User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snap) {
        final u = snap.data;
        final isLogged = u != null && u.uid != 'guest';

        if (!isLogged) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const _SectionHeader('Você não está conectado'),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                        child: const Text('Entrar em uma conta'),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }

        final name = (u!.displayName?.trim().isNotEmpty ?? false) ? u.displayName! : (u.email?.split('@').first ?? 'Usuário');
        final email = u.email ?? '';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cabeçalho (nome + email)
            Column(
              children: [
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(email, style: const TextStyle(color: Colors.white70)),
                ],
              ],
            ),

            const SizedBox(height: 24),
            const _SectionHeader('CONFIGURAÇÕES'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Editar perfil'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Alterar senha'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta sem e-mail')));
                        return;
                      }
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Alterar senha'),
                          content: Text('Enviar um link de redefinição para $email?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enviar')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await AuthService.instance.sendPasswordReset(email: email);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail de redefinição enviado')));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const _SectionHeader('PEDIDOS'),
            Card(
              child: ListTile(
                title: const Text('Histórico de compras'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersPage())),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => AuthService.instance.signOut(),
                child: const Text('Sair'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: .2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: .2))),
      ],
    );
  }
}
