import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/login_adm_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'AgroHub',
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
      endDrawer: DrawerMenuComponent(
        headerTitle: 'Operador',
        items: [
          DrawerItem(
            title: 'Configuracoes',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              debugPrint('Navegar para Configuracoes');
            },
          ),
          DrawerItem(
            title: 'Logout',
            icon: Icons.person,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginAdmScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: TextComponent(
          text: 'Bem-vindo ao AgroHub!',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
