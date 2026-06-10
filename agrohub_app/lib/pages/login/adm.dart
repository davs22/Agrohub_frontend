import 'package:agrohub_app/components/base_login_template.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/services/local_auth_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  void initState() {
    super.initState();
    _ensureCompanySession();
  }

  Future<void> _ensureCompanySession() async {
    final session = await SessionService.loadSession();
    final isCompany = session != null && (session.role == 'COMERCIO' || session.role == 'FAZENDA');
    if (!mounted || isCompany) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginComercioScreen()),
      (route) => false,
    );
  }

  Future<bool> _handleBack() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginComercioScreen()),
      (route) => false,
    );
    return false;
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _validarEEntrar() async {
    final documentoError = LoginValidators.validateCpfOrCnpj(_documentoController.text);
    final senhaError = LoginValidators.validatePassword(_senhaController.text, minLength: 8);

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
    final result = await LocalAuthService.authenticateAdmin(
      loginLimpo,
      _senhaController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciais incorretas ou cadastro local não encontrado.')),
      );
      return;
    }

    await SessionService.saveSession(
      role: result.role,
      login: loginLimpo,
      tableName: result.tableName,
      localId: result.record['id_local'] as int?,
      displayName: result.record['nome']?.toString(),
      documento: result.record['documento']?.toString(),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeAdmScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: BaseLoginTemplate(
        title: 'Administrador',
        svgPath: 'lib/interface_icons/administrador.svg',
        headerDrawerTitle: 'Acesso Gestão',
        visibleOptions: const {
          DrawerMenuOption.novaSenhaAdmin,
          DrawerMenuOption.operador,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
        isLoading: _isLoading,
        onSubmit: _validarEEntrar,
        fields: [
          InputComponent(
            emoji: Icons.badge,
            borderRadius: 20,
            width: double.infinity,
            height: 65,
            hint: 'CNPJ/CPF do Negócio',
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
          TextComponent(
            text: 'Senha',
            color: colorScheme.onSurface,
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
            hint: '8 Dígitos',
            hintColor: colorScheme.onSurface.withValues(alpha: 0.55),
            ephemeral: true,
            controll: _senhaController,
            errorText: _senhaError,
            eventChange: (_) {
              if (_senhaError != null) {
                setState(() {
                  _senhaError = LoginValidators.validatePassword(_senhaController.text, minLength: 8);
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
