import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/registro/comercio.dart';
import 'package:agrohub_app/modules/http_login.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:agrohub_app/components/base_login_template.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final result = await loginRequest(loginLimpo, _senhaController.text);

      if (result.token != null) {
        await prefs.setString('token', result.token!);
        await prefs.setString('role', 'COMERCIO'); 
        
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmScreen()));
        return;
      }
    } catch (e) {
      debugPrint('Falha na API, tentando modo offline...');
    }

    final db = await DatabaseHelper.instance.database;
    final comercioLocal = await db.query('comercios', where: 'documento = ?', whereArgs: [loginLimpo]);
    final fazendaLocal = await db.query('fazendas', where: 'documento = ?', whereArgs: [loginLimpo]);

    if (!mounted) return;
    setState(() { _isLoading = false; });

    if (comercioLocal.isNotEmpty || fazendaLocal.isNotEmpty) {
      await prefs.setString('token', 'OFFLINE_MODE');
      await prefs.setString('role', comercioLocal.isNotEmpty ? 'COMERCIO' : 'FAZENDA');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem internet: Autenticado no Modo Offline')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha na conexão e usuário não encontrado offline.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoginTemplate(
      title: 'Comercio / Fazenda',
      svgPath: 'lib/interface_icons/fazenda.svg',
      headerDrawerTitle: 'Comercio',
      visibleOptions: const {
        DrawerMenuOption.configuracoes,
        DrawerMenuOption.registrarComercio,
        DrawerMenuOption.registrarFazenda,
      },
      isLoading: _isLoading,
      onSubmit: _validarEEntrar,
      footerWidget: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterComercioScreen()),
        ),
        child: const Text(
          'Registre-se',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      fields: [
        InputComponent(
          emoji: Icons.badge,
          borderRadius: 20,
          width: double.infinity,
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
          hint: '8 digitos',
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