import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/login_operador_screen.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginAdmScreen extends StatefulWidget {
  const LoginAdmScreen({super.key});

  @override
  State<LoginAdmScreen> createState() => _LoginAdmScreenState();
}

class _LoginAdmScreenState extends State<LoginAdmScreen> {
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? _documentoError;
  String? _senhaError;

  @override
  void dispose() {
    _documentoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _validarEEntrar() {
    final documentoError = LoginValidators.validateCpfOrCnpj(
      _documentoController.text,
    );
    final senhaError = LoginValidators.validatePassword(
      _senhaController.text,
      minLength: 8,
    );

    setState(() {
      _documentoError = documentoError;
      _senhaError = senhaError;
    });

    if (documentoError != null || senhaError != null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

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
        headerTitle: 'Administrador',
        items: [
          DrawerItem(
            title: 'Inicio',
            icon: Icons.home,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          DrawerItem(
            title: 'Configuracoes',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              debugPrint('Navegar para Configuracoes');
            },
          ),
          DrawerItem(
            title: 'Operador',
            icon: Icons.person,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginOperadorScreen(),
                ),
              );
            },
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
            InputComponent(
              emoji: Icons.badge,
              borderRadius: 20,
              width: 270,
              height: 65,
              hint: 'CNPJ/CPF',
              controll: _documentoController,
              typeInput: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CpfOrCnpjInputFormatter(),
              ],
              errorText: _documentoError,
              eventChange: (_) {
                setState(() {
                  _documentoError = LoginValidators.validateCpfOrCnpj(
                    _documentoController.text,
                  );
                });
              },
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
            InputComponent(
              emoji: Icons.lock,
              borderRadius: 20,
              width: 270,
              height: 65,
              hint: '8 digitos',
              hintColor: Colors.black.withValues(alpha: 0.5),
              ephemeral: true,
              controll: _senhaController,
              errorText: _senhaError,
              eventChange: (_) {
                if (_senhaError != null) {
                  setState(() {
                    _senhaError = LoginValidators.validatePassword(
                      _senhaController.text,
                      minLength: 8,
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 120),
            Center(
              child: ButtonComponent(
                label: 'Entrar',
                borderRadius: 10,
                width: 150,
                height: 50,
                onPressed: _validarEEntrar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
