import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:flutter/material.dart';

class RegisterOperadorScreen extends StatefulWidget {
  const RegisterOperadorScreen({super.key});

  @override
  State<RegisterOperadorScreen> createState() => _RegisterOperadorScreenState();
}

class _RegisterOperadorScreenState extends State<RegisterOperadorScreen> {
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
      endDrawer: const DrawerMenuComponent(headerTitle: 'Administrador'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  TextComponent(
                    text: 'Registro de Operador',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              Flexible(
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      const SizedBox(height: 24),
                      InputComponent(
                        emoji: Icons.store,
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
                      Center(
                        child: ButtonComponent(
                          label: 'Registrar',
                          height: 40,
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          onPressed: _validarFormulario,
                          borderColor: const Color.fromARGB(255, 76, 175, 80),
                          backgroundColor:
                              const Color.fromARGB(255, 76, 175, 80),
                          borderRadius: 4,
                          width: 400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
