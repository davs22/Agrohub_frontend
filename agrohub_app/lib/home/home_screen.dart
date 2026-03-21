import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarComponent(
        title: "Inicio",
      ),
      drawer: DrawerMenuComponent(
        headerTitle: "Dev Senior. Gabriel",
        headerSubtitle: "gabriel.devsernior@agrohub.com",
        items: [
          DrawerItem(
            title: "Início",
            icon: Icons.home,
            onTap: () => print("Navegar para Início"),
          ),
          DrawerItem(
            title: "Configurações",
            icon: Icons.settings,
            onTap: () => print("Navegar para Configurações"),
          ),
          DrawerItem(
            title: "Sair",
            icon: Icons.exit_to_app,
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () => print("Fazer Logout"),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              InputComponent(
                  emoji: Icons.door_back_door,
                  width: 200,
                  height: 200,
                  hint: "hehehehe"),
              ButtonComponent(label: "click desabilitado")
            ],
          ),
        ),
      ),
    );
  }
}