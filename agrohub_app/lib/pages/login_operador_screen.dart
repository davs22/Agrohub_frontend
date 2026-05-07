import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/login_adm_screen.dart';
import 'package:agrohub_app/pages/new_pass_operador_screen.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginOperadorScreen extends StatefulWidget {
  const LoginOperadorScreen({super.key});

  @override
  State<LoginOperadorScreen> createState() => _LoginOperadorScreenState();
}

class _LoginOperadorScreenState extends State<LoginOperadorScreen> {
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? _cpfError;
  String? _senhaError;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _validarEEntrar() {
    final cpfError = LoginValidators.validateCpf(_cpfController.text);
    final senhaError = LoginValidators.validatePassword(
      _senhaController.text,
      minLength: 6,
    );

    setState(() {
      _cpfError = cpfError;
      _senhaError = senhaError;
    });

    if (cpfError != null || senhaError != null) {
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
        headerTitle: 'Operador',
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
            title: 'Administrador',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                'lib/interface_icons/operador.svg',
                width: 110,
                height: 110,
              ),
            ),
            const SizedBox(height: 100),
            const TextComponent(
              text: 'Operador',
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
              hint: 'CPF',
              controll: _cpfController,
              typeInput: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CpfInputFormatter(),
              ],
              errorText: _cpfError,
              eventChange: (_) {
                if (_cpfError != null) {
                  setState(() {
                    _cpfError =
                        LoginValidators.validateCpf(_cpfController.text);
                  });
                }
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
              hint: '6 digitos',
              hintColor: Colors.black.withValues(alpha: 0.5),
              ephemeral: true,
              controll: _senhaController,
              errorText: _senhaError,
              eventChange: (_) {
                if (_senhaError != null) {
                  setState(() {
                    _senhaError = LoginValidators.validatePassword(
                      _senhaController.text,
                      minLength: 6,
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
            const SizedBox(height: 20),
            Center(
                child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const NewPassOperadorScreen())),
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}
