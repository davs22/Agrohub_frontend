import 'package:agrohub_app/components/base_register_template.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/status_selector.dart';
import 'package:agrohub_app/constants.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/modules/http_register.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterLoteScreen extends StatefulWidget {
  const RegisterLoteScreen({super.key});

  @override
  State<RegisterLoteScreen> createState() => _RegisterLoteScreenState();
}

class _RegisterLoteScreenState extends State<RegisterLoteScreen> {
  final TextEditingController _instanciaIdController = TextEditingController();
  final TextEditingController _talhaoIdController = TextEditingController();
  final TextEditingController _operadorIdController = TextEditingController();
  final TextEditingController _codigoRastreioController =
      TextEditingController();
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _unidadeMedidaController =
      TextEditingController();
  final TextEditingController _imagemUrlController = TextEditingController();

  bool _ativo = true;
  bool _isPublished = false;
  bool _isLoading = false;
  String? _instanciaIdError;
  String? _talhaoIdError;
  String? _operadorIdError;
  String? _produtoError;
  String? _quantidadeError;
  String? _unidadeMedidaError;

  @override
  void dispose() {
    _instanciaIdController.dispose();
    _talhaoIdController.dispose();
    _operadorIdController.dispose();
    _codigoRastreioController.dispose();
    _produtoController.dispose();
    _quantidadeController.dispose();
    _unidadeMedidaController.dispose();
    _imagemUrlController.dispose();
    super.dispose();
  }

  Future<void> _validarFormulario() async {
    final instanciaIdError = LoginValidators.validateRequiredText(
        _instanciaIdController.text,
        fieldName: 'o id da instância',
        minLength: 3);
    final talhaoIdError = LoginValidators.validateRequiredText(
        _talhaoIdController.text,
        fieldName: 'o id do talhão',
        minLength: 3);
    final operadorIdError = LoginValidators.validateRequiredText(
        _operadorIdController.text,
        fieldName: 'o id do operador',
        minLength: 3);
    final produtoError = LoginValidators.validateRequiredText(
        _produtoController.text,
        fieldName: 'o produto',
        minLength: 2);
    final quantidadeError = LoginValidators.validatePositiveNumber(
        _quantidadeController.text,
        fieldName: 'a quantidade');
    final unidadeMedidaError = LoginValidators.validateRequiredText(
        _unidadeMedidaController.text,
        fieldName: 'a unidade de medida',
        minLength: 1);

    setState(() {
      _instanciaIdError = instanciaIdError;
      _talhaoIdError = talhaoIdError;
      _operadorIdError = operadorIdError;
      _produtoError = produtoError;
      _quantidadeError = quantidadeError;
      _unidadeMedidaError = unidadeMedidaError;
    });

    final hasError = [
      instanciaIdError,
      talhaoIdError,
      operadorIdError,
      produtoError,
      quantidadeError,
      unidadeMedidaError,
    ].any((error) => error != null);

    if (hasError) return;

    setState(() {
      _isLoading = true;
    });

    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final status = _ativo ? 'ATIVO' : 'INATIVO';
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    final Map<String, dynamic> dadosLocais = {
      'instancia_id': _instanciaIdController.text,
      'usuario_id': _operadorIdController.text,
      'talhao_id': _talhaoIdController.text,
      'operador_id': _operadorIdController.text,
      'codigo_rastreio': _codigoRastreioController.text,
      'produto': _produtoController.text,
      'quantidade': quantidade,
      'unidade_medida': _unidadeMedidaController.text,
      'status': status,
      'imagem_url': _imagemUrlController.text,
      'is_published': _isPublished ? 1 : 0,
      'data_registro': DateTime.now().toIso8601String(),
      'status_sincronizacao': 0,
    };

    final idSalvo =
        await DatabaseHelper.instance.inserirRegistro('lotes', dadosLocais);

    final Map<String, dynamic> loteData = {
      'produto': _produtoController.text,
      'quantidade': quantidade,
      'unidadeMedida': _unidadeMedidaController.text,
      'status': status,
      'imagemUrl': _imagemUrlController.text,
      'usuarioId': _operadorIdController.text,
      'talhoesId': _talhaoIdController.text,
      'isPublished': _isPublished ? 1 : 0,
    };

    final result = await lotesRegister(loteData, token);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.status >= 200 && result.status < 300) {
      await DatabaseHelper.instance.marcarComoSincronizado('lotes', idSalvo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lote registrado e sincronizado com a nuvem!')),
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

  Future<void> _editarImagemUrl() async {
    final controller = TextEditingController(text: _imagemUrlController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Imagem do lote'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'URL da imagem',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result != null) {
      setState(() {
        _imagemUrlController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseRegisterTemplate(
      title: 'Registrar lotes',
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
          controll: _instanciaIdController,
          errorText: _instanciaIdError,
          eventChange: (_) {
            setState(() {
              _instanciaIdError = LoginValidators.validateRequiredText(
                  _instanciaIdController.text,
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
          hint: 'Id_talhão',
          controll: _talhaoIdController,
          errorText: _talhaoIdError,
          eventChange: (_) {
            setState(() {
              _talhaoIdError = LoginValidators.validateRequiredText(
                  _talhaoIdController.text,
                  fieldName: 'o id do talhão',
                  minLength: 3);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.manage_accounts,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Id_operador',
          controll: _operadorIdController,
          errorText: _operadorIdError,
          eventChange: (_) {
            setState(() {
              _operadorIdError = LoginValidators.validateRequiredText(
                  _operadorIdController.text,
                  fieldName: 'o id do operador',
                  minLength: 3);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.qr_code,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Código_rastreio',
          controll: _codigoRastreioController,
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.inventory_2,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Produto',
          controll: _produtoController,
          errorText: _produtoError,
          eventChange: (_) {
            setState(() {
              _produtoError = LoginValidators.validateRequiredText(
                  _produtoController.text,
                  fieldName: 'o produto',
                  minLength: 2);
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.numbers,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Quantidade',
          controll: _quantidadeController,
          typeInput: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          errorText: _quantidadeError,
          eventChange: (_) {
            setState(() {
              _quantidadeError = LoginValidators.validatePositiveNumber(
                  _quantidadeController.text,
                  fieldName: 'a quantidade');
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.scale,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Unidade_medida',
          controll: _unidadeMedidaController,
          errorText: _unidadeMedidaError,
          eventChange: (_) {
            setState(() {
              _unidadeMedidaError = LoginValidators.validateRequiredText(
                  _unidadeMedidaController.text,
                  fieldName: 'a unidade de medida',
                  minLength: 1);
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
        const SizedBox(height: 12),
        ButtonComponent(
          label: 'Registrar imagem',
          icon: Icons.image,
          width: double.infinity,
          height: 36,
          fontSize: 15,
          borderRadius: 4,
          backgroundColor: const Color(0xFFE0E0E0),
          borderColor: const Color(0xFFE0E0E0),
          onPressed: _editarImagemUrl,
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _isPublished,
          onChanged: (value) {
            setState(() {
              _isPublished = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          title: const Text(
            'Adicionar no marketplace',
            style: TextStyle(
              color: componentTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
