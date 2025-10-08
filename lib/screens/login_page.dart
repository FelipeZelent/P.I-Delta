import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool showPass = false;
  bool loading = false;
  bool isSignup = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      if (isSignup) {
        await AuthService.instance.signUpEmailPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
          name: nameCtrl.text.trim(),
        );
      } else {
        await AuthService.instance.signInEmailPassword(
          emailCtrl.text.trim(),
          passCtrl.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isSignup ? 'Conta criada!' : 'Login ok')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _forgot() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite seu e-mail para recuperar a senha')),
      );
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviamos um e-mail de recuperação')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isSignup ? 'Criar conta' : 'Entrar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            if (isSignup) ...[
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passCtrl,
              obscureText: !showPass,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => showPass = !showPass),
                  icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => isSignup = !isSignup),
                  child: Text(isSignup ? 'Já tenho uma conta' : 'Criar uma conta'),
                ),
                const Spacer(),
                if (!isSignup)
                  TextButton(
                    onPressed: _forgot,
                    child: const Text('Esqueci minha senha'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(isSignup ? 'Criar conta' : 'Entrar'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
