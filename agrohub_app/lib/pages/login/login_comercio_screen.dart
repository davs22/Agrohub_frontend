import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/modules/http_login.dart';
import 'package:agrohub_app/pages/login/login_operador_screen.dart';
import 'package:agrohub_app/pages/registro/register_comercio_screen.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginComercioScreen extends StatefulWidget {
  const LoginComercioScreen({super.key});

  @override
  State<LoginComercioScreen> createState() => _LoginComercioScreenState();
}

class _LoginComercioScreenState extends State<LoginComercioScreen> {
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? _documentoError;
  String? _senhaError;
  //bool _isLoading = false;

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

    /* ==========================================
       INÍCIO DO CÓDIGO COMENTADO (API REAL)
       (Descomenta isto quando o backend estiver pronto)
    =============================================
    
    final result = await loginRequest(
      _documentoController.text,
      _senhaController.text,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.token == null) {
      return;
    }
    
    ============================================= */

    // ==========================================
    // INÍCIO DA SIMULAÇÃO (PROTÓTIPO)
    // ==========================================

    // Mostra um aviso visual de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Login simulado com sucesso! (Modo Protótipo)')),
    );

    // Espera 1 segundo para dar a sensação de que está a carregar algo
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    // Navega diretamente para a próxima tela ignorando o token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginOperadorScreen()),
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
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.registrarComercio,
          DrawerMenuOption.registrarFazenda,
        },
      ),
      body: SafeArea(
        // O SingleChildScrollView é o herói que vai resolver o erro do ecrã amarelo e preto!
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'lib/interface_icons/fazenda.svg',
                    width: 110,
                    height: 110,
                  ),
                ),
                // Reduzi um pouco este SizedBox (era 100) para ajudar no layout em ecrãs menores
                const SizedBox(height: 60), 
                const TextComponent(
                  text: 'Comercio',
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
                // Reduzi este espaço também (era 120) para os botões ficarem mais visíveis
                const SizedBox(height: 60), 
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
                        builder: (context) => const RegisterComercioScreen(),
                      ),
                    ),
                    child: const Text(
                      'Registre-se',
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
