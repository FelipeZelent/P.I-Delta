import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:suco/models/user_model.dart';
import 'package:suco/screens/login_screen.dart';
import '../tiles/drawer_title.dart';

class CustomDrawer extends StatelessWidget {

  final PageController pageController;

  CustomDrawer(this.pageController);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(left: 32, top: 20),
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                height: 110,
                child: Stack(
                  children: [
                    Positioned(
                      top: 15,
                      left: 8,
                      child: ScopedModelDescendant<UserModel>(
                        builder: (context, child, model){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Olá, ${!model.isLoggedIn() ? "" : model.userData["name"]}",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                child: Text(
                                  !model.isLoggedIn() ?
                                  "Entre ou Cadastre-se >"
                                  : "Sair",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                onTap: (){
                                  if(!model.isLoggedIn())
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context)=> LoginScreen())
                                  );
                                  else
                                    model.signOut();
                                } ,
                              )
                            ],
                          );
                        }
                      )
                    )
                  ],
                ),
              ),
              Divider(),
              DrawerTile(Icons.home, "Inicio", pageController, 0),
              DrawerTile(Icons.shopping_bag, "Carrinho", pageController, 1),
              DrawerTile(Icons.favorite, "Favoritos", pageController, 2),
              DrawerTile(Icons.person, "Perfil", pageController, 3),
            ],
          ),
        ],
      ),
    );
  }
}
