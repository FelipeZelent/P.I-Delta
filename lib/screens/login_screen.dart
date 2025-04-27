import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:suco/models/user_model.dart';
import 'package:suco/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrar"),
        centerTitle: true,
        actions: [
          TextButton(
            child: Text("Criar Conta", style: TextStyle(fontSize: 15.0, color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignupScreen()),
              );
            },
          )
        ],
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          if (model.isLoading) return Center(child: CircularProgressIndicator());

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "E-mail"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) {
                    if (text == null || text.isEmpty || !text.contains("@")) return "E-mail inválido";
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passController,
                  decoration: InputDecoration(hintText: "Senha"),
                  obscureText: true,
                  validator: (text) {
                    if (text == null || text.length < 6) return "Senha inválida!";
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if(_emailController.text.isEmpty)
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Insira seu E-mail para recuperação!"),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            )
                        );
                      else {
                        model.recoverPass(_emailController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Confira seu E-mail!"),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            )
                        );
                      }
                    },
                    child: Text("Esqueci minha senha", textAlign: TextAlign.right),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  height: 44.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text("Entrar", style: TextStyle(fontSize: 18.0, color: Colors.white)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        model.signIn(
                            email: _emailController.text,
                            pass: _passController.text,
                            onSuccess: _onSuccess,
                            onFail: _onFail
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  void _onSuccess() {
    Navigator.of(context).pop();
  }

  void _onFail() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha ao Entrar!"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        )
    );
  }
}

