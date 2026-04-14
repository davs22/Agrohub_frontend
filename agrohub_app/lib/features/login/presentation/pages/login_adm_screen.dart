import 'package:agrohub_app/shared/widgets/app_bar.dart';
import 'package:agrohub_app/shared/widgets/button.dart';
import 'package:agrohub_app/shared/widgets/drawer_menu.dart';
import 'package:agrohub_app/shared/widgets/input.dart';
import 'package:flutter/material.dart';


class LoginAdmScreen extends StatefulWidget {
  const LoginAdmScreen({super.key});

  @override
  State<LoginAdmScreen> createState() => _LoginAdmScreenState();
}

class _LoginAdmScreenState extends State<LoginAdmScreen> {
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
        headerTitle: 'Adiministrador',
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
            title: 'Operador',
            icon: Icons.person,
            onTap: () => debugPrint('Fazer Login como Operador'),
          ),
        ],
      ),

      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              InputComponent(
                emoji: Icons.person,
                width: 200,
                height: 200,
                hint: 'Digite sua senha',
              ),
              ButtonComponent(label: 'Login'),
            ],
          ),
        ),
      ),
    );
  }
}
