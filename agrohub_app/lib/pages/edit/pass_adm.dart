import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/login/adm.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewPassAdmScreen extends StatefulWidget {
  const NewPassAdmScreen({super.key});

  @override
  State<NewPassAdmScreen> createState() => _NewPassAdmScreenState();
}

class _NewPassAdmScreenState extends State<NewPassAdmScreen> {
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  String? _cpfError;
  String? _senhaError;
  String? _codigoError;
  bool _codigoEnviado = false;
  int _segundosRestantes = 0;
  Timer? _codigoTimer;

  @override
  void dispose() {
    _codigoTimer?.cancel();
    _cpfController.dispose();
    _senhaController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final cpfError = LoginValidators.validateCpfOrCnpj(_cpfController.text);

    setState(() {
      _cpfError = cpfError;
    });

    if (cpfError != null) return;

    final loginLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final response = await http.post(
        Uri.parse('https://agrohub.discloud.app/auth/send-code/$loginLimpo'),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _codigoTimer?.cancel();

        setState(() {
          _codigoEnviado = true;
          _segundosRestantes = 50;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código enviado com sucesso. Verifique seu email.')),
        );

        _codigoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          if (_segundosRestantes <= 1) {
            timer.cancel();
            setState(() { _segundosRestantes = 0; });
            return;
          }
          setState(() { _segundosRestantes--; });
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar código. Verifique o usuário e a internet.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão com a internet.')),
      );
    }
  }

  Future<void> _validarERedefinirSenha() async {
    final cpfError = LoginValidators.validateCpfOrCnpj(_cpfController.text);
    final senhaError = LoginValidators.validatePassword(_senhaController.text, minLength: 8);
    final codigoError = LoginValidators.validateVerificationCode(_codigoController.text, length: 6);

    setState(() {
      _cpfError = cpfError;
      _senhaError = senhaError;
      _codigoError = codigoError;
    });

    if (cpfError != null || senhaError != null || codigoError != null) return;

    if (!_codigoEnviado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Envie o código de verificação antes de redefinir.')),
      );
      return;
    }

    final loginLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final codigo = _codigoController.text;
    
    try {
      // 1. Método PUT e Parâmetros na URL (Path e Query)
      final uri = Uri.parse('https://agrohub.discloud.app/auth/reset-password/$loginLimpo?code=$codigo');

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        // 2. Body contendo apenas a chave 'senha'
        body: jsonEncode({
          'senha': _senhaController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha redefinida com sucesso.')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginAdmScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código inválido ou expirado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão ao redefinir a senha.')),
      );
    }
  }

  bool get _podeRedefinirSenha {
    final cpfValido = LoginValidators.validateCpfOrCnpj(_cpfController.text) == null;
    final senhaValida = LoginValidators.validatePassword(_senhaController.text, minLength: 8) == null;
    final codigoValido = LoginValidators.validateVerificationCode(_codigoController.text, length: 6) == null;
    return cpfValido && senhaValida && codigoValido && _codigoEnviado;
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
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextComponent(
                              text: 'Redefinir senha de adm',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: TextComponent(
                            text: 'Digite seu usuario',
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InputComponent(
                          emoji: Icons.badge,
                          borderRadius: 20,
                          width: double.infinity,
                          height: 65,
                          hint: 'CNPJ/CPF',
                          controll: _cpfController,
                          typeInput: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CpfOrCnpjInputFormatter(),
                          ],
                          errorText: _cpfError,
                          eventChange: (_) {
                            setState(() {
                              _cpfError = LoginValidators.validateCpfOrCnpj(_cpfController.text);
                            });
                          },
                        ),
                        const SizedBox(height: 35),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: TextComponent(
                            text: 'Digite sua nova senha',
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InputComponent(
                          emoji: Icons.lock,
                          borderRadius: 20,
                          width: double.infinity,
                          height: 65,
                          hint: '8 digitos',
                          ephemeral: true,
                          controll: _senhaController,
                          errorText: _senhaError,
                          eventChange: (_) {
                            setState(() {
                              _senhaError = LoginValidators.validatePassword(_senhaController.text, minLength: 8);
                            });
                          },
                        ),
                        const SizedBox(height: 35),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: TextComponent(
                            text: 'Codigo de verificacao',
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InputComponent(
                          emoji: Icons.verified_user,
                          borderRadius: 20,
                          width: double.infinity,
                          height: 65,
                          hint: '6 digitos',
                          controll: _codigoController,
                          typeInput: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          errorText: _codigoError,
                          eventChange: (_) {
                            setState(() {
                              _codigoError = LoginValidators.validateVerificationCode(_codigoController.text, length: 6);
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _segundosRestantes > 0 ? null : _enviarCodigo,
                            child: Text(
                              _segundosRestantes > 0 ? 'Aguarde ${_segundosRestantes}s' : 'Enviar codigo',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        ButtonComponent(
                          label: 'Redefinir senha',
                          borderRadius: 10,
                          width: 250,
                          height: 50,
                          isDisabled: !_podeRedefinirSenha,
                          onPressed: _validarERedefinirSenha,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}