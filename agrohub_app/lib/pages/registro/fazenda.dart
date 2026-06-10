import 'package:agrohub_app/components/base_register_template.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterFazendaScreen extends StatefulWidget {
  const RegisterFazendaScreen({super.key});

  @override
  State<RegisterFazendaScreen> createState() => _RegisterFazendaScreenState();
}

class _RegisterFazendaScreenState extends State<RegisterFazendaScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _hectaresController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaAdmController = TextEditingController();
  final TextEditingController _senhaOperadorController = TextEditingController();

  String? _nomeError;
  String? _documentoError;
  String? _hectaresError;
  String? _latitudeError;
  String? _longitudeError;
  String? _telefoneError;
  String? _emailError;
  String? _senhaAdmError;
  String? _senhaOperadorError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _documentoController.dispose();
    _hectaresController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaAdmController.dispose();
    _senhaOperadorController.dispose();
    super.dispose();
  }

  Future<void> _validarFormulario() async {
    final nomeError = LoginValidators.validateRequiredText(
      _nomeController.text,
      fieldName: 'o nome da fazenda',
      minLength: 3,
    );
    final documentoError = LoginValidators.validateCpfOrCnpj(_documentoController.text);
    final hectaresError = LoginValidators.validatePositiveNumber(
      _hectaresController.text,
      fieldName: 'os hectares totais',
    );
    final latitudeError = LoginValidators.validateLatitude(_latitudeController.text);
    final longitudeError = LoginValidators.validateLongitude(_longitudeController.text);
    final telefoneError = LoginValidators.validatePhone(_telefoneController.text);
    final emailError = LoginValidators.validateEmail(_emailController.text);
    final senhaAdmError = LoginValidators.validatePassword(_senhaAdmController.text, minLength: 8);
    final senhaOperadorError = LoginValidators.validatePassword(_senhaOperadorController.text, minLength: 8);

    setState(() {
      _nomeError = nomeError;
      _documentoError = documentoError;
      _hectaresError = hectaresError;
      _latitudeError = latitudeError;
      _longitudeError = longitudeError;
      _telefoneError = telefoneError;
      _emailError = emailError;
      _senhaAdmError = senhaAdmError;
      _senhaOperadorError = senhaOperadorError;
    });

    final hasError = [
      nomeError,
      documentoError,
      hectaresError,
      latitudeError,
      longitudeError,
      telefoneError,
      emailError,
      senhaAdmError,
      senhaOperadorError,
    ].any((error) => error != null);

    if (hasError) return;

    setState(() {
      _isLoading = true;
    });

    final documentoLimpo = _documentoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final hectaresFormatado = _hectaresController.text.replaceAll(',', '.');
    final latitudeFormatada = _latitudeController.text.replaceAll(',', '.');
    final longitudeFormatada = _longitudeController.text.replaceAll(',', '.');

    final dadosLocais = {
      'nome': _nomeController.text,
      'documento': documentoLimpo,
      'hectares': double.tryParse(hectaresFormatado) ?? 0.0,
      'latitude': latitudeFormatada,
      'longitude': longitudeFormatada,
      'telefone': telefoneLimpo,
      'email': _emailController.text,
      'senha_adm': _senhaAdmController.text,
      'senha_operacao': _senhaOperadorController.text,
      'status': 'ATIVO',
    };

    await DatabaseHelper.instance.inserirRegistro('fazendas', dadosLocais);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fazenda salva no banco local.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BaseRegisterTemplate(
      title: 'Registro de Fazenda',
      headerDrawerTitle: 'Comércio',
      visibleOptions: const {
        DrawerMenuOption.registrarComercio,
        DrawerMenuOption.inicio,
        DrawerMenuOption.configuracoes,
      },
      isLoading: _isLoading,
      onSubmit: _validarFormulario,
      fields: [
        InputComponent(
          emoji: Icons.store,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Nome da Fazenda',
          controll: _nomeController,
          typeInput: TextInputType.name,
          errorText: _nomeError,
          eventChange: (_) {
            setState(() {
              _nomeError = LoginValidators.validateRequiredText(
                _nomeController.text,
                fieldName: 'o nome da fazenda',
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
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.agriculture,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Hectares totais',
          controll: _hectaresController,
          typeInput: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*([,.]\d*)?$')),
          ],
          errorText: _hectaresError,
          eventChange: (_) {
            setState(() {
              _hectaresError = LoginValidators.validatePositiveNumber(
                _hectaresController.text,
                fieldName: 'os hectares totais',
              );
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.location_on,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Latitude',
          controll: _latitudeController,
          typeInput: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*([,.]\d*)?$')),
          ],
          errorText: _latitudeError,
          eventChange: (_) {
            setState(() {
              _latitudeError = LoginValidators.validateLatitude(_latitudeController.text);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.explore,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Longitude',
          controll: _longitudeController,
          typeInput: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*([,.]\d*)?$')),
          ],
          errorText: _longitudeError,
          eventChange: (_) {
            setState(() {
              _longitudeError = LoginValidators.validateLongitude(_longitudeController.text);
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
          emoji: Icons.admin_panel_settings,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Senha de administração',
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
          width: double.infinity,
          height: 45,
          hint: 'Senha de operador',
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
      ],
    );
  }
}
