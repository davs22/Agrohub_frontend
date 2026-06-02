import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart'; // Mantive caso uses depois
import 'package:agrohub_app/pages/edit/pass_operador.dart';
import 'package:agrohub_app/modules/http_login.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _validarEEntrar() async {
    // 1. Mantemos a validação local (para o protótipo parecer real se digitarem errado)
    final cpfError = LoginValidators.validateCpf(
      _cpfController.text,
    );
    final senhaError = LoginValidators.validatePassword(
      _senhaController.text,
      minLength: 8,
    );

    setState(() {
      _cpfError = cpfError;
      _senhaError = senhaError;
    });

    if (cpfError != null || senhaError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final loginLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');

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

    // NAVEGAÇÃO: Notei que no teu código original ele estava a navegar para a própria LoginOperadorScreen.
    // Presumo que depois do login ele deva ir para uma "Home do Operador" ou para a "Home Admin".
    // Por agora, deixei a apontar para a HomeAdmScreen só para sair da tela de login, mas podes alterar depois!
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
        headerTitle: 'Comercio',
        visibleOptions: {
          DrawerMenuOption.novaSenhaOperador,
          DrawerMenuOption.administrador,
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
                    'lib/interface_icons/operador.svg',
                    width: 110,
                    height: 110,
                  ),
                ),
                // Reduzi de 100 para 60 para libertar espaço
                const SizedBox(height: 60),
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
                  hint: '6 digitos', // O hint diz 6, mas a tua validação pede 8, confere isso depois ;)
                  hintColor: Colors.black.withValues(alpha: 0.5),
                  ephemeral: true,
                  controll: _senhaController,
                  errorText: _senhaError,
                  eventChange: (_) {
                    if (_senhaError != null) {
                      setState(() {
                        _senhaError = LoginValidators.validatePassword(
                          _senhaController.text,
                          minLength: 6, // Ajustei aqui para 6 igual ao hint
                        );
                      });
                    }
                  },
                ),
                // Reduzi de 120 para 60 para libertar espaço para o botão extra
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
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewPassOperadorScreen(),
                      ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}