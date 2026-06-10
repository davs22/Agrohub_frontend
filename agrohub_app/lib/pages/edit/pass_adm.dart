import 'dart:async';
import 'dart:math';

import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
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
  String? _codigoGerado;

  @override
  void dispose() {
    _codigoTimer?.cancel();
    _cpfController.dispose();
    _senhaController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _buscarUsuario() async {
    final loginLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final comercio = await DatabaseHelper.instance.buscarPorColuna('comercios', 'documento', loginLimpo);
    if (comercio != null) return {'table': 'comercios', 'record': comercio};

    final fazenda = await DatabaseHelper.instance.buscarPorColuna('fazendas', 'documento', loginLimpo);
    if (fazenda != null) return {'table': 'fazendas', 'record': fazenda};

    return null;
  }

  Future<void> _enviarCodigo() async {
    final cpfError = LoginValidators.validateCpfOrCnpj(_cpfController.text);

    setState(() {
      _cpfError = cpfError;
    });

    if (cpfError != null) return;

    final usuario = await _buscarUsuario();
    if (usuario == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado no banco local.')),
      );
      return;
    }

    final codigo = (Random().nextInt(900000) + 100000).toString();
    _codigoGerado = codigo;
    _codigoTimer?.cancel();

    setState(() {
      _codigoEnviado = true;
      _segundosRestantes = 50;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código local gerado: $codigo')),
    );

    _codigoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_segundosRestantes <= 1) {
        timer.cancel();
        setState(() {
          _segundosRestantes = 0;
        });
        return;
      }

      setState(() {
        _segundosRestantes--;
      });
    });
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

    if (!_codigoEnviado || _codigoGerado == null || _codigoGerado != _codigoController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido. Gere um novo código local.')),
      );
      return;
    }

    final usuario = await _buscarUsuario();
    if (usuario == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado no banco local.')),
      );
      return;
    }

    final table = usuario['table'] as String;
    final record = usuario['record'] as Map<String, dynamic>;
    final idLocal = record['id_local'] as int?;

    if (idLocal == null) return;

    final senhaKey = table == 'comercios' || table == 'fazendas' ? 'senha_adm' : 'senha';
    await DatabaseHelper.instance.atualizarRegistro(
      table,
      {senhaKey: _senhaController.text},
      idLocal,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha redefinida com sucesso no banco local.')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginAdmScreen()),
    );
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
                          hint: '8 Dígitos',
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
                            text: 'Código de verificação',
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
                          hint: '6 Dígitos',
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
                              _segundosRestantes > 0 ? 'Aguarde ${_segundosRestantes}s' : 'Gerar código',
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
