import 'package:flutter/material.dart';
import 'package:suco/widgets/custom_drawer.dart';

import '../tabs/home_tab.dart';

class Home extends StatelessWidget {

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Scaffold(
          body: HomeTab(),
          drawer: CustomDrawer(_pageController),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Carrinho"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: Container(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Favoritos"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: Container(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Perfil"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: Container(),
        ),
      ],
    );
  }
}
