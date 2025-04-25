import 'package:flutter/material.dart';
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Olá,",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            child: Text("Entre ou Cadastre-se >",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context)=> LoginScreen())
                              );
                            } ,
                          )
                        ],
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
