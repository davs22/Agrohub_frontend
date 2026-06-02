import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/modules/http_login.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _documentoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _validarEEntrar() async {
    // 1. Mantemos a validação local (para o protótipo parecer real se digitarem errado)
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

    setState(() {
      _isLoading = true;
    });

    final loginLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final result = await loginRequest(
      loginLimpo,
      _senhaController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.token == null) {
      return;
    }

    // Navega diretamente para a próxima tela ignorando o token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeAdmScreen()),
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
      endDrawer: const DrawerMenuComponent(
        headerTitle: 'Administrador',
        visibleOptions: {
          DrawerMenuOption.novaSenhaAdmin,
          DrawerMenuOption.operador,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
      ),
      // MUDANÇAS APLICADAS AQUI: SafeArea + SingleChildScrollView
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                // Reduzi de 100 para 60 para libertar espaço
                const SizedBox(height: 60),
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
                // Reduzi de 120 para 60 para libertar espaço
                const SizedBox(height: 60),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : ButtonComponent(
                          label: 'Entrar',
                          borderRadius: 10,
                          width: 150,
                          height: 50,
                          isDisabled: _isLoading,
                          onPressed: _validarEEntrar,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}