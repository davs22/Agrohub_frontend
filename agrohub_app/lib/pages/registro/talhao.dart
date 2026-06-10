import 'package:agrohub_app/components/base_register_template.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/status_selector.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/modules/http_register.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterTalhaoScreen extends StatefulWidget {
  const RegisterTalhaoScreen({super.key});

  @override
  State<RegisterTalhaoScreen> createState() => _RegisterTalhaoScreenState();
}

class _RegisterTalhaoScreenState extends State<RegisterTalhaoScreen> {
  final TextEditingController _usuarioIdController = TextEditingController();
  final TextEditingController _nomeTalhaoController = TextEditingController();
  final TextEditingController _tamanhoHectaresController =
      TextEditingController();
  final TextEditingController _culturaAtualController = TextEditingController();

  bool _ativo = true;
  bool _isLoading = false;
  String? _usuarioIdError;
  String? _nomeTalhaoError;
  String? _tamanhoHectaresError;
  String? _culturaAtualError;

  @override
  void dispose() {
    _usuarioIdController.dispose();
    _nomeTalhaoController.dispose();
    _tamanhoHectaresController.dispose();
    _culturaAtualController.dispose();
    super.dispose();
  }

  Future<void> _validarFormulario() async {
    final usuarioIdError = LoginValidators.validateRequiredText(
        _usuarioIdController.text,
        fieldName: 'o id da instância',
        minLength: 3);
    final nomeTalhaoError = LoginValidators.validateRequiredText(
        _nomeTalhaoController.text,
        fieldName: 'o nome do talhão',
        minLength: 2);
    final tamanhoHectaresError = LoginValidators.validatePositiveNumber(
        _tamanhoHectaresController.text,
        fieldName: 'o tamanho em hectares');
    final culturaAtualError = LoginValidators.validateRequiredText(
        _culturaAtualController.text,
        fieldName: 'a cultura atual',
        minLength: 2);

    setState(() {
      _usuarioIdError = usuarioIdError;
      _nomeTalhaoError = nomeTalhaoError;
      _tamanhoHectaresError = tamanhoHectaresError;
      _culturaAtualError = culturaAtualError;
    });

    final hasError = [
      usuarioIdError,
      nomeTalhaoError,
      tamanhoHectaresError,
      culturaAtualError,
    ].any((error) => error != null);

    if (hasError) return;

    setState(() {
      _isLoading = true;
    });

    final tamanhoHectares =
        _tamanhoHectaresController.text.replaceAll(',', '.');
    final status = _ativo ? 'ATIVO' : 'INATIVO';
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    final Map<String, dynamic> dadosLocais = {
      'usuario_id': _usuarioIdController.text,
      'nome': _nomeTalhaoController.text,
      'tamanho_hectares': double.tryParse(tamanhoHectares) ?? 0.0,
      'cultura_atual': _culturaAtualController.text,
      'status': status,
      'status_sincronizacao': 0,
    };

    final idSalvo =
        await DatabaseHelper.instance.inserirRegistro('talhoes', dadosLocais);

    final Map<String, dynamic> talhaoData = {
      'nomeTalhao': _nomeTalhaoController.text,
      'tamanhoHectares': tamanhoHectares,
      'culturaAtual': _culturaAtualController.text,
      'status': status,
      'usuarioId': _usuarioIdController.text,
    };

    final result = await talhoesRegister(talhaoData, token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.status >= 200 && result.status < 300) {
      await DatabaseHelper.instance.marcarComoSincronizado('talhoes', idSalvo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Talhão registrado e sincronizado com a nuvem!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Modo Offline: Salvo localmente. Erro na nuvem: ${result.message}')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseRegisterTemplate(
      title: 'Registrar Talhões',
      headerDrawerTitle: 'Administrador',
      visibleOptions: const {
        DrawerMenuOption.homeAdmin,
        DrawerMenuOption.listaOperadores,
        DrawerMenuOption.registrarOperador,
        DrawerMenuOption.registrarTalhao,
        DrawerMenuOption.editarTalhao,
        DrawerMenuOption.registrarLote,
        DrawerMenuOption.editarLote,
        DrawerMenuOption.configuracoes,
        DrawerMenuOption.logout,
      },
      isLoading: _isLoading,
      onSubmit: _validarFormulario,
      fields: [
        InputComponent(
          emoji: Icons.account_tree,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Id_instância',
          controll: _usuarioIdController,
          errorText: _usuarioIdError,
          eventChange: (_) {
            setState(() {
              _usuarioIdError = LoginValidators.validateRequiredText(
                  _usuarioIdController.text,
                  fieldName: 'o id da instância',
                  minLength: 3);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.grass,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Nome_talhão',
          controll: _nomeTalhaoController,
          typeInput: TextInputType.name,
          errorText: _nomeTalhaoError,
          eventChange: (_) {
            setState(() {
              _nomeTalhaoError = LoginValidators.validateRequiredText(
                  _nomeTalhaoController.text,
                  fieldName: 'o nome do talhão',
                  minLength: 2);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.square_foot,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Tamanho_hectares',
          controll: _tamanhoHectaresController,
          typeInput: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*([,.]\d*)?$')),
          ],
          errorText: _tamanhoHectaresError,
          eventChange: (_) {
            setState(() {
              _tamanhoHectaresError = LoginValidators.validatePositiveNumber(
                  _tamanhoHectaresController.text,
                  fieldName: 'o tamanho em hectares');
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.eco,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Cultura_atual',
          controll: _culturaAtualController,
          errorText: _culturaAtualError,
          eventChange: (_) {
            setState(() {
              _culturaAtualError = LoginValidators.validateRequiredText(
                  _culturaAtualController.text,
                  fieldName: 'a cultura atual',
                  minLength: 2);
            });
          },
        ),
        const SizedBox(height: 20),
        StatusSelectorComponent(
          isActive: _ativo,
          onChanged: (value) {
            setState(() {
              _ativo = value;
            });
          },
        ),
      ],
    );
  }
}
