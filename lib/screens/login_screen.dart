import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:suco/models/user_model.dart';
import 'package:suco/screens/signup_screen.dart';

class LoginScreen extends StatelessWidget {
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
                    onPressed: () {},
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
                            onSuccess: () {
                              // TODO: Redirecionar para tela principal
                            },
                            onFail: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Falha ao entrar!"))
                              );
                            }
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
}
