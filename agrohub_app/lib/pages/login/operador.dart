import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/edit/pass_operador.dart';
import 'package:agrohub_app/modules/http_login.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:agrohub_app/components/base_login_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _validarEEntrar() async {
    final cpfError = LoginValidators.validateCpf(_cpfController.text);
    final senhaError = LoginValidators.validatePassword(
      _senhaController.text,
      minLength: 6,
    );

    setState(() {
      _cpfError = cpfError;
      _senhaError = senhaError;
    });

    if (cpfError != null || senhaError != null) return;

    setState(() { _isLoading = true; });

    final loginLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final result = await loginRequest(loginLimpo, _senhaController.text);

    if (!mounted) return;

    setState(() { _isLoading = false; });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.token == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', result.token!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeAdmScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoginTemplate(
      title: 'Operador',
      svgPath: 'lib/interface_icons/operador.svg',
      headerDrawerTitle: 'Comercio',
      visibleOptions: const {
        DrawerMenuOption.novaSenhaOperador,
        DrawerMenuOption.administrador,
        DrawerMenuOption.configuracoes,
        DrawerMenuOption.logout,
      },
      isLoading: _isLoading,
      onSubmit: _validarEEntrar,
      footerWidget: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewPassOperadorScreen()),
        ),
        child: const Text(
          'Esqueci minha senha',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      fields: [
        InputComponent(
          emoji: Icons.badge,
          borderRadius: 20,
          width: double.infinity,
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
                _cpfError = LoginValidators.validateCpf(_cpfController.text);
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
          width: double.infinity,
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
      ],
    );
  }
}