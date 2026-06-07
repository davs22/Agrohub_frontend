import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrohub_app/components/base_edit_template.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditOperadorScreen extends StatefulWidget {
  final String usuarioIdNuvem;
  final int idLocal;

  const EditOperadorScreen({
    super.key, 
    required this.usuarioIdNuvem, 
    required this.idLocal,
  });

  @override
  State<EditOperadorScreen> createState() => _EditOperadorScreenState();
}

class _EditOperadorScreenState extends State<EditOperadorScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaOperadorController = TextEditingController();

  bool _ativo = true;
  String? _nomeError;
  String? _documentoError;
  String? _cpfError;
  String? _telefoneError;
  String? _emailError;
  String? _senhaOperadorError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _documentoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaOperadorController.dispose();
    super.dispose();
  }

  Future<void> _validarFormulario() async {
    final nomeError = LoginValidators.validateRequiredText(_nomeController.text, fieldName: 'o nome do operador', minLength: 3);
    final documentoError = LoginValidators.validateCpfOrCnpj(_documentoController.text);
    final telefoneError = LoginValidators.validatePhone(_telefoneController.text);
    final emailError = LoginValidators.validateEmail(_emailController.text);
    final senhaOperadorError = LoginValidators.validatePassword(_senhaOperadorController.text, minLength: 8);
    final cpfError = LoginValidators.validateCpf(_cpfController.text);

    setState(() {
      _nomeError = nomeError;
      _documentoError = documentoError;
      _cpfError = cpfError;
      _telefoneError = telefoneError;
      _emailError = emailError;
      _senhaOperadorError = senhaOperadorError;
    });

    final hasError = [
      nomeError, documentoError, _cpfError, telefoneError, emailError, senhaOperadorError,
    ].any((error) => error != null);

    if (hasError) return;

    setState(() { _isLoading = true; });

    final cpfLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final Map<String, dynamic> dadosLocais = {
      "nome_completo": _nomeController.text,
      "cpf": cpfLimpo,
      "email": _emailController.text,
      "telefone": telefoneLimpo,
      "senha": _senhaOperadorController.text,
      "status_sincronizacao": 0,
    };

    await DatabaseHelper.instance.atualizarRegistro('operadores', dadosLocais, widget.idLocal);

    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    final Map<String, dynamic> userData = {
      "nome": _nomeController.text,
      "email": _emailController.text,
      "telefone": telefoneLimpo,
      "endereco": "0", 
      "login": cpfLimpo,
      "senha": _senhaOperadorController.text,
      "role": "OPERADOR",
      "status": _ativo ? "ATIVO" : "INATIVO",
    };

    try {
      final response = await http.put(
        Uri.parse('https://agrohub.discloud.app/user/update/${widget.usuarioIdNuvem}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (!mounted) return;
      setState(() { _isLoading = false; });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await DatabaseHelper.instance.marcarComoSincronizado('operadores', widget.idLocal);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operador editado e sincronizado com a nuvem!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Modo Offline: Atualizado localmente. Erro na API: ${response.statusCode}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modo Offline: Atualizado localmente. Sem internet para enviar à nuvem.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseEditTemplate(
      title: 'Editar Operador',
      headerDrawerTitle: 'Administrador',
      visibleOptions: const {
        DrawerMenuOption.homeAdmin,
        DrawerMenuOption.listaOperadores,
        DrawerMenuOption.registrarOperador,
        DrawerMenuOption.editarOperador,
        DrawerMenuOption.configuracoes,
        DrawerMenuOption.logout,
      },
      isLoading: _isLoading,
      onSubmit: _validarFormulario,
      fields: [
        InputComponent(
          emoji: Icons.badge,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'CPF do operador',
          controll: _cpfController,
          typeInput: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CpfInputFormatter(),
          ],
          errorText: _cpfError,
          eventChange: (_) {
            setState(() {
              _cpfError = LoginValidators.validateCpf(_cpfController.text);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.admin_panel_settings,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'CNPJ/CPF de administrador',
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
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.manage_accounts,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Nome completo',
          controll: _nomeController,
          typeInput: TextInputType.name,
          inputFormatters: const [],
          errorText: _nomeError,
          eventChange: (_) {
            setState(() {
              _nomeError = LoginValidators.validateRequiredText(_nomeController.text, fieldName: 'o nome do operador', minLength: 3);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.phone,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Telefone',
          controll: _telefoneController,
          typeInput: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            PhoneInputFormatter(),
          ],
          errorText: _telefoneError,
          eventChange: (_) {
            setState(() {
              _telefoneError = LoginValidators.validatePhone(_telefoneController.text);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.email,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Email',
          ephemeral: false,
          showVisibilityToggle: false,
          controll: _emailController,
          typeInput: TextInputType.emailAddress,
          inputFormatters: const [],
          errorText: _emailError,
          eventChange: (_) {
            setState(() {
              _emailError = LoginValidators.validateEmail(_emailController.text);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.lock,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Nova Senha',
          controll: _senhaOperadorController,
          ephemeral: true,
          errorText: _senhaOperadorError,
          eventChange: (_) {
            setState(() {
              _senhaOperadorError = LoginValidators.validatePassword(_senhaOperadorController.text, minLength: 8);
            });
          },
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.black),
              const SizedBox(width: 12),
              Text(
                _ativo ? 'Ativo' : 'Inativo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Switch(
                value: _ativo,
                onChanged: (value) {
                  setState(() {
                    _ativo = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}