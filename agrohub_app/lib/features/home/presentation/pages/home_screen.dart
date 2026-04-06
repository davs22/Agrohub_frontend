import 'package:agrohub_app/shared/widgets/app_bar.dart';
import 'package:agrohub_app/shared/widgets/button.dart';
import 'package:agrohub_app/shared/widgets/drawer_menu.dart';
import 'package:agrohub_app/shared/widgets/input.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarComponent(
        title: 'Inicio',
      ),
      drawer: DrawerMenuComponent(
        headerTitle: 'Dev Senior. Gabriel',
        headerSubtitle: 'gabriel.devsernior@agrohub.com',
        items: [
          DrawerItem(
            title: 'Inicio',
            icon: Icons.home,
            onTap: () => debugPrint('Navegar para Inicio'),
          ),
          DrawerItem(
            title: 'Configuracoes',
            icon: Icons.settings,
            onTap: () => debugPrint('Navegar para Configuracoes'),
          ),
          DrawerItem(
            title: 'Sair',
            icon: Icons.exit_to_app,
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () => debugPrint('Fazer Logout'),
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
                hint: 'hehehehe',
              ),
              ButtonComponent(label: 'click desabilitado'),
            ],
          ),
        ),
      ),
    );
  }
}
