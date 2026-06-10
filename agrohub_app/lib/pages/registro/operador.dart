import 'package:agrohub_app/components/base_register_template.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterOperadorScreen extends StatefulWidget {
  const RegisterOperadorScreen({super.key});

  @override
  State<RegisterOperadorScreen> createState() => _RegisterOperadorScreenState();
}

class _RegisterOperadorScreenState extends State<RegisterOperadorScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaOperadorController = TextEditingController();

  bool _ativo = true;
  bool _isLoading = false;
  String? _nomeError;
  String? _documentoError;
  String? _cpfError;
  String? _telefoneError;
  String? _emailError;
  String? _senhaOperadorError;

  @override
  void initState() {
    super.initState();
    _loadAdminDocumento();
  }

  Future<void> _loadAdminDocumento() async {
    final session = await SessionService.loadSession();
    if (!mounted || session == null) {
      return;
    }

    setState(() {
      _documentoController.text = session.documento ?? session.login;
    });
  }

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
    final nomeError = LoginValidators.validateRequiredText(
      _nomeController.text,
      fieldName: 'o nome do operador',
      minLength: 3,
    );
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
      nomeError,
      documentoError,
      cpfError,
      telefoneError,
      emailError,
      senhaOperadorError,
    ].any((error) => error != null);

    if (hasError) return;

    setState(() {
      _isLoading = true;
    });

    final cpfLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final documentoLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final dadosLocais = {
      'documento_admin': documentoLimpo,
      'nome_completo': _nomeController.text,
      'cpf': cpfLimpo,
      'email': _emailController.text,
      'telefone': telefoneLimpo,
      'senha': _senhaOperadorController.text,
      'status': _ativo ? 'ATIVO' : 'INATIVO',
    };

    await DatabaseHelper.instance.inserirRegistro('operadores', dadosLocais);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operador salvo no banco local.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BaseRegisterTemplate(
      title: 'Registrar operador',
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
          emoji: Icons.admin_panel_settings,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'CNPJ/CPF do Administrador',
          controll: _documentoController,
          typeInput: TextInputType.number,
          readOnly: true,
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
          errorText: _nomeError,
          eventChange: (_) {
            setState(() {
              _nomeError = LoginValidators.validateRequiredText(
                _nomeController.text,
                fieldName: 'o nome do operador',
                minLength: 3,
              );
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.badge,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'CPF',
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
          hint: 'Senha',
          controll: _senhaOperadorController,
          ephemeral: true,
          errorText: _senhaOperadorError,
          eventChange: (_) {
            setState(() {
              _senhaOperadorError = LoginValidators.validatePassword(
                _senhaOperadorController.text,
                minLength: 8,
              );
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
