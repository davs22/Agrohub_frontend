import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
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
  final TextEditingController _hectaresController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaOperadorController =
      TextEditingController();

  bool _ativo = true;

  String? _nomeError;
  String? _documentoError;
  String? _cpfError;
  String? _telefoneError;
  String? _emailError;
  String? _senhaOperadorError;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _documentoController.dispose();
    _hectaresController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaOperadorController.dispose();
    super.dispose();
  }

  void _validarFormulario() {
    final nomeError = LoginValidators.validateRequiredText(
      _nomeController.text,
      fieldName: 'o nome do comercio',
      minLength: 3,
    );
    final documentoError = LoginValidators.validateCpfOrCnpj(
      _documentoController.text,
    );
    final telefoneError = LoginValidators.validatePhone(
      _telefoneController.text,
    );
    final emailError = LoginValidators.validateEmail(_emailController.text);
    final senhaOperadorError = LoginValidators.validatePassword(
      _senhaOperadorController.text,
      minLength: 8,
    );
    final cpfError = LoginValidators.validateCpf(
      _cpfController.text,
    );

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
      _cpfError,
      telefoneError,
      emailError,
      senhaOperadorError,
    ].any((error) => error != null);

    if (hasError) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro validado com sucesso.')),
    );

    Navigator.pop(context);
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
          DrawerMenuOption.homeAdmin,
          DrawerMenuOption.listaOperadores,
          DrawerMenuOption.registrarOperador,
          DrawerMenuOption.editarOperador,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextComponent(
                        text: 'Registro de Operador',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  InputComponent(
                    emoji: Icons.admin_panel_settings,
                    borderRadius: 4,
                    width: 400,
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
                        _documentoError = LoginValidators.validateCpfOrCnpj(
                          _documentoController.text,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  InputComponent(
                    emoji: Icons.manage_accounts,
                    borderRadius: 4,
                    width: 400,
                    height: 45,
                    hint: 'Nome completo',
                    controll: _nomeController,
                    typeInput: TextInputType.name,
                    inputFormatters: const [],
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
                    width: 400,
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
                        _cpfError = LoginValidators.validateCpf(
                            _cpfController.text);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  InputComponent(
                    emoji: Icons.phone,
                    borderRadius: 4,
                    width: 400,
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
                        _telefoneError = LoginValidators.validatePhone(
                          _telefoneController.text,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  InputComponent(
                    emoji: Icons.email,
                    borderRadius: 4,
                    width: 400,
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
                        _emailError = LoginValidators.validateEmail(
                          _emailController.text,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  InputComponent(
                    emoji: Icons.lock,
                    borderRadius: 4,
                    width: 400,
                    height: 45,
                    hint: 'Senha',
                    controll: _senhaOperadorController,
                    ephemeral: true,
                    errorText: _senhaOperadorError,
                    eventChange: (_) {
                      setState(() {
                        _senhaOperadorError =
                            LoginValidators.validatePassword(
                          _senhaOperadorController.text,
                          minLength: 8,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 400,
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
                  const SizedBox(height: 40),
                  ButtonComponent(
                    label: 'Registrar',
                    height: 40,
                    fontSize: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    onPressed: _validarFormulario,
                    borderColor: const Color.fromARGB(255, 76, 175, 80),
                    backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                    borderRadius: 4,
                    width: 400,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}