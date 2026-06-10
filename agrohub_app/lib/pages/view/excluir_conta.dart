import 'dart:async';
import 'dart:math';

import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExcluirContaScreen extends StatefulWidget {
  const ExcluirContaScreen({super.key});

  @override
  State<ExcluirContaScreen> createState() => _ExcluirContaScreenState();
}

class _ExcluirContaScreenState extends State<ExcluirContaScreen> {
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  Timer? _timer;
  String _selectedTable = 'comercios';
  String? _documentoError;
  String? _codigoError;
  String? _emailRegistrado;
  String? _nomeRegistrado;
  int _segundosRestantes = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _timer?.cancel();
    _documentoController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _buscarConta() async {
    final documentoLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (_selectedTable == 'comercios') {
      return DatabaseHelper.instance.buscarPorColuna('comercios', 'documento', documentoLimpo);
    }
    return DatabaseHelper.instance.buscarPorColuna('fazendas', 'documento', documentoLimpo);
  }

  Future<void> _solicitarCodigo() async {
    final documentoError = LoginValidators.validateCpfOrCnpj(_documentoController.text);
    setState(() {
      _documentoError = documentoError;
    });

    if (documentoError != null) return;

    final conta = await _buscarConta();
    if (conta == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta nao encontrada no banco local.')),
      );
      return;
    }

    final codigo = (Random().nextInt(900000) + 100000).toString();
    final prefs = await SharedPreferences.getInstance();
    final documentoLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    await prefs.setString('delete_code_${_selectedTable}_$documentoLimpo', codigo);
    await prefs.setInt('delete_code_exp_${_selectedTable}_$documentoLimpo', DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch);

    setState(() {
      _emailRegistrado = conta['email']?.toString();
      _nomeRegistrado = conta['nome']?.toString();
      _segundosRestantes = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Codigo preparado para o email cadastrado${_emailRegistrado != null ? ": $_emailRegistrado" : ""}.',
        ),
      ),
    );
  }

  Future<bool> _codigoValido() async {
    final documentoLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString('delete_code_${_selectedTable}_$documentoLimpo');
    final expiresAt = prefs.getInt('delete_code_exp_${_selectedTable}_$documentoLimpo');

    if (storedCode == null || expiresAt == null) return false;
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) return false;
    return storedCode == _codigoController.text;
  }

  Future<void> _excluirConta() async {
    final documentoError = LoginValidators.validateCpfOrCnpj(_documentoController.text);
    final codigoError = LoginValidators.validateVerificationCode(_codigoController.text, length: 6);

    setState(() {
      _documentoError = documentoError;
      _codigoError = codigoError;
    });

    if (documentoError != null || codigoError != null) return;

    final conta = await _buscarConta();
    if (conta == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta nao encontrada no banco local.')),
      );
      return;
    }

    final codigoOk = await _codigoValido();
    if (!codigoOk) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Codigo invalido ou expirado. Solicite um novo codigo.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final documentoLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    await DatabaseHelper.instance.deletarPorDocumento(
      tabela: _selectedTable,
      documento: documentoLimpo,
    );

    final session = await SessionService.loadSession();
    if (session != null && session.login == documentoLimpo && session.tableName == _selectedTable) {
      await SessionService.clearSession();
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta excluida permanentemente do banco local.')),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginComercioScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        headerTitle: 'Configuracoes',
        visibleOptions: {
          DrawerMenuOption.homeAdmin,
          DrawerMenuOption.homeOperador,
          DrawerMenuOption.listaOperadores,
          DrawerMenuOption.registrarOperador,
          DrawerMenuOption.registrarTalhao,
          DrawerMenuOption.registrarLote,
          DrawerMenuOption.marketplace,
          DrawerMenuOption.perfilOperador,
          DrawerMenuOption.carrinho,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
        hiddenOptions: {
          DrawerMenuOption.configuracoes,
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TextComponent(
              text: 'Excluir comercio / fazenda',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aviso: esta conta sera excluida permanentemente.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTable,
                    decoration: const InputDecoration(
                      labelText: 'Tipo da conta',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'comercios',
                        child: Text('Comercio'),
                      ),
                      DropdownMenuItem(
                        value: 'fazendas',
                        child: Text('Fazenda'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedTable = value;
                        _emailRegistrado = null;
                        _nomeRegistrado = null;
                        _codigoController.clear();
                        _codigoError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  InputComponent(
                    emoji: Icons.badge,
                    borderRadius: 8,
                    width: double.infinity,
                    height: 48,
                    hint: 'CPF / CNPJ',
                    controll: _documentoController,
                    typeInput: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CpfOrCnpjInputFormatter(),
                    ],
                    errorText: _documentoError,
                    eventChange: (_) {
                      setState(() {
                        _documentoError = LoginValidators.validateCpfOrCnpj(_documentoController.text);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ButtonComponent(
                    label: _segundosRestantes > 0 ? 'Aguarde $_segundosRestantes s' : 'Solicitar codigo',
                    icon: Icons.mail_outline,
                    width: double.infinity,
                    height: 46,
                    borderRadius: 8,
                    backgroundColor: colorScheme.primary,
                    borderColor: colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    isDisabled: _segundosRestantes > 0,
                    onPressed: _solicitarCodigo,
                  ),
                  if (_emailRegistrado != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Email cadastrado: $_emailRegistrado',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (_nomeRegistrado != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Conta selecionada: $_nomeRegistrado',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 16),
                  InputComponent(
                    emoji: Icons.verified_user,
                    borderRadius: 8,
                    width: double.infinity,
                    height: 48,
                    hint: 'Codigo de verificacao',
                    controll: _codigoController,
                    typeInput: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    errorText: _codigoError,
                    eventChange: (_) {
                      setState(() {
                        _codigoError = LoginValidators.validateVerificationCode(
                          _codigoController.text,
                          length: 6,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonComponent(
                    label: _isLoading ? 'Excluindo...' : 'Excluir definitivamente',
                    icon: Icons.delete_forever,
                    width: double.infinity,
                    height: 48,
                    borderRadius: 8,
                    backgroundColor: Colors.red,
                    borderColor: Colors.red,
                    textColor: Colors.white,
                    isDisabled: _isLoading,
                    onPressed: _excluirConta,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

