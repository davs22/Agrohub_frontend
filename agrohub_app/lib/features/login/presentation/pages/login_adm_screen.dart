import 'package:agrohub_app/shared/widgets/app_bar.dart';
import 'package:agrohub_app/shared/widgets/button.dart';
import 'package:agrohub_app/shared/widgets/drawer_menu.dart';
import 'package:agrohub_app/shared/widgets/input.dart';
import 'package:agrohub_app/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                'lib/interface_icons/administrador.svg',
                width: 110,
                height: 110,
              ),
            ),
            const SizedBox(height: 100),
            const TextComponent(
              text: 'Administrador',
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              aligment: TextAlign.left,
            ),
            const SizedBox(height: 12),
            const InputComponent(
              emoji: Icons.badge,
              width: 270,
              height: 65,
              label: 'CNPJ/CPF',
            ),
            const SizedBox(height: 12),
            const TextComponent(
              text: 'Senha',
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              aligment: TextAlign.left,
            ),
            const SizedBox(height: 12),
            const InputComponent(
              emoji: Icons.lock,
              width: 270,
              height: 65,
              label: '8 digitos',
              ephemeral: true,
            ),
            const SizedBox(height: 120),
            Center(
              child: ButtonComponent(
                label: 'Entrar',
                onPressed: () {},
                fontSize: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 70,
                  vertical: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
