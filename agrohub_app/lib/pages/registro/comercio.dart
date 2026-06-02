import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:agrohub_app/modules/http_register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterComercioScreen extends StatefulWidget {
  const RegisterComercioScreen({super.key});

  @override
  State<RegisterComercioScreen> createState() => _RegisterComercioScreenState();
}

class _RegisterComercioScreenState extends State<RegisterComercioScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaAdmController = TextEditingController();
  final TextEditingController _senhaOperadorController =
      TextEditingController();

  String? _nomeError;
  String? _documentoError;
  String? _ruaError;
  String? _cepError;
  String? _telefoneError;
  String? _emailError;
  String? _senhaAdmError;
  String? _senhaOperadorError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _documentoController.dispose();
    _ruaController.dispose();
    _cepController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaAdmController.dispose();
    _senhaOperadorController.dispose();
    super.dispose();
  }

  Future<void> _validarFormulario() async {
    final nomeError = LoginValidators.validateRequiredText(
      _nomeController.text,
      fieldName: 'o nome do comercio',
      minLength: 3,
    );
    final documentoError = LoginValidators.validateCpfOrCnpj(
      _documentoController.text,
    );
    final ruaError = LoginValidators.validateStreet(_ruaController.text);
    final cepError = LoginValidators.validateCep(_cepController.text);
    final telefoneError = LoginValidators.validatePhone(
      _telefoneController.text,
    );
    final emailError = LoginValidators.validateEmail(_emailController.text);
    final senhaAdmError = LoginValidators.validatePassword(
      _senhaAdmController.text,
      minLength: 8,
    );
    final senhaOperadorError = LoginValidators.validatePassword(
      _senhaOperadorController.text,
      minLength: 8,
    );

    setState(() {
      _nomeError = nomeError;
      _documentoError = documentoError;
      _ruaError = ruaError;
      _cepError = cepError;
      _telefoneError = telefoneError;
      _emailError = emailError;
      _senhaAdmError = senhaAdmError;
      _senhaOperadorError = senhaOperadorError;
    });

    final hasError = [
      nomeError,
      documentoError,
      ruaError,
      cepError,
      telefoneError,
      emailError,
      senhaAdmError,
      senhaOperadorError,
    ].any((error) => error != null);

    if (hasError) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final documentoLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cepLimpo = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final Map<String, dynamic> userData = {
      "nome": _nomeController.text,
      "documento": documentoLimpo,
      "rua": _ruaController.text,
      "cep": cepLimpo,
      "telefone": telefoneLimpo,
      "email": _emailController.text,
      "senhaAdm": _senhaAdmController.text,
      "senhaOperador": _senhaOperadorController.text,
      "tipo": "comercio",
    };

    final result = await registerRequest(userData);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.status >= 200 && result.status < 300) {
      Navigator.pop(context);
    }
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
          DrawerMenuOption.registrarFazenda,
          DrawerMenuOption.configuracoes,
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
                        text: 'Registro de Comercio',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  InputComponent(
                    emoji: Icons.store,
                    borderRadius: 4,
                    width: 400,
                    height: 45,
                    hint: 'Nome do Comercio',
                    controll: _nomeController,
                    typeInput: TextInputType.name,
                    inputFormatters: const [],
                    errorText: _nomeError,
                    eventChange: (_) {
                      setState(() {
                        _nomeError = LoginValidators.validateRequiredText(
                          _nomeController.text,
                          fieldName: 'o nome do comercio',
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
                  const SizedBox(height: 20),
                  InputComponent(
                    emoji: Icons.signpost_outlined,
                    borderRadius: 4,
                    width: 400,
                    height: 45,
                    hint: 'Rua',
                    controll: _ruaController,
                    typeInput: TextInputType.streetAddress,
                    inputFormatters: const [],
                    errorText: _ruaError,
                    eventChange: (_) {
                      setState(() {
                        _ruaError = LoginValidators.validateStreet(
                          _ruaController.text,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  InputComponent(
                    emoji: Icons.markunread_mailbox_outlined,
                    borderRadius: 4,
                    width: 400,
                    height: 45,
                    hint: 'Cep',
                    controll: _cepController,
                    typeInput: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CepInputFormatter(),
                    ],
                    errorText: _cepError,
                    eventChange: (_) {
                      setState(() {
                        _cepError = LoginValidators.validateCep(
                          _cepController.text,
                        );
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
                    emoji: Icons.admin_panel_settings,
                    borderRadius: 4,
                    width: 400,
                    height: 45,
                    hint: 'Senha de administracao',
                    controll: _senhaAdmController,
                    ephemeral: true,
                    errorText: _senhaAdmError,
                    eventChange: (_) {
                      setState(() {
                        _senhaAdmError = LoginValidators.validatePassword(
                          _senhaAdmController.text,
                          minLength: 8,
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
                    hint: 'Senha de operador',
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
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : ButtonComponent(
                          label: 'Registrar',
                          height: 40,
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          isDisabled: _isLoading,
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