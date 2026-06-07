import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/modules/http_login.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:agrohub_app/components/base_login_template.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final documentoError = LoginValidators.validateCpfOrCnpj(_documentoController.text);
    final senhaError = LoginValidators.validatePassword(_senhaController.text, minLength: 8);

    setState(() {
      _documentoError = documentoError;
      _senhaError = senhaError;
    });

    if (documentoError != null || senhaError != null) return;

    setState(() { _isLoading = true; });

    final loginLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. TENTA O LOGIN ONLINE (API NA NUVEM)
      final result = await loginRequest(loginLimpo, _senhaController.text);

      if (result.token != null) {
        await prefs.setString('token', result.token!);
        await prefs.setString('role', 'ADMIN_NEGOCIO'); // Define o acesso como administrador
        
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmScreen()));
        return;
      }
    } catch (e) {
      debugPrint('Falha na API, tentando modo offline...');
    }

    // 2. CONTINGÊNCIA OFFLINE (BANCO LOCAL DO CELULAR)
    final db = await DatabaseHelper.instance.database;
    
    // Procura na tabela de comercios
    final comercioLocal = await db.query(
      'comercios', 
      where: 'documento = ? AND senha_adm = ?', 
      whereArgs: [loginLimpo, _senhaController.text]
    );

    // Procura na tabela de fazendas
    final fazendaLocal = await db.query(
      'fazendas', 
      where: 'documento = ? AND senha_adm = ?', 
      whereArgs: [loginLimpo, _senhaController.text]
    );

    if (!mounted) return;
    setState(() { _isLoading = false; });

    if (comercioLocal.isNotEmpty || fazendaLocal.isNotEmpty) {
      // Autenticação offline bem sucedida
      await prefs.setString('token', 'OFFLINE_MODE');
      await prefs.setString('role', 'ADMIN_NEGOCIO');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem internet: Autenticado no Modo Offline')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmScreen()));
    } else {
      // Falha dupla: Não tem internet e a senha/documento não batem com o banco local
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha na conexão ou credenciais incorretas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoginTemplate(
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
          hint: 'Senha de Administrador',
          hintColor: Colors.black.withValues(alpha: 0.5),
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
    );
  }
}