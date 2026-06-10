import 'package:agrohub_app/components/base_edit_template.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/status_selector.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditTalhaoScreen extends StatefulWidget {
  final int idLocal;

  const EditTalhaoScreen({super.key, required this.idLocal});

  @override
  State<EditTalhaoScreen> createState() => _EditTalhaoScreenState();
}

class _EditTalhaoScreenState extends State<EditTalhaoScreen> {
  final TextEditingController _usuarioIdController = TextEditingController();
  final TextEditingController _nomeTalhaoController = TextEditingController();
  final TextEditingController _tamanhoHectaresController = TextEditingController();
  final TextEditingController _culturaAtualController = TextEditingController();
  String? _operadorSelecionadoNome;

  bool _ativo = true;
  bool _isLoading = false;
  String? _usuarioIdError;
  String? _nomeTalhaoError;
  String? _tamanhoHectaresError;
  String? _culturaAtualError;

  @override
  void initState() {
    super.initState();
    _loadTalhao();
  }

  @override
  void dispose() {
    _usuarioIdController.dispose();
    _nomeTalhaoController.dispose();
    _tamanhoHectaresController.dispose();
    _culturaAtualController.dispose();
    super.dispose();
  }

  Future<void> _loadTalhao() async {
    final record = await DatabaseHelper.instance.buscarPorId('talhoes', widget.idLocal);
    if (record == null || !mounted) {
      return;
    }

    String? operadorNome;
    final operadorId = record['usuario_id']?.toString();
    if (operadorId != null && operadorId.isNotEmpty) {
      final operador = await DatabaseHelper.instance.buscarPorColuna(
        'operadores',
        'id_local',
        operadorId,
      );
      operadorNome = operador?['nome_completo']?.toString();
    }

    setState(() {
      _usuarioIdController.text = record['usuario_id']?.toString() ?? '';
      _nomeTalhaoController.text = record['nome']?.toString() ?? '';
      _tamanhoHectaresController.text = record['tamanho_hectares']?.toString() ?? '';
      _culturaAtualController.text = record['cultura_atual']?.toString() ?? '';
      _ativo = record['status']?.toString().toUpperCase() != 'INATIVO';
      _operadorSelecionadoNome = operadorNome;
    });
  }

  Future<void> _validarFormulario() async {
    final usuarioIdError = LoginValidators.validateRequiredText(
      _usuarioIdController.text,
      fieldName: 'o id da instância',
      minLength: 3,
    );
    final nomeTalhaoError = LoginValidators.validateRequiredText(
      _nomeTalhaoController.text,
      fieldName: 'o nome do talhão',
      minLength: 2,
    );
    final tamanhoHectaresError = LoginValidators.validatePositiveNumber(
      _tamanhoHectaresController.text,
      fieldName: 'o tamanho em hectares',
    );
    final culturaAtualError = LoginValidators.validateRequiredText(
      _culturaAtualController.text,
      fieldName: 'a cultura atual',
      minLength: 2,
    );

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

    final tamanhoHectares = _tamanhoHectaresController.text.replaceAll(',', '.');
    final dadosLocais = {
      'usuario_id': _usuarioIdController.text,
      'nome': _nomeTalhaoController.text,
      'tamanho_hectares': double.tryParse(tamanhoHectares) ?? 0.0,
      'cultura_atual': _culturaAtualController.text,
      'status': _ativo ? 'ATIVO' : 'INATIVO',
    };

    await DatabaseHelper.instance.atualizarRegistro(
      'talhoes',
      dadosLocais,
      widget.idLocal,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Talhão atualizado no banco local.')),
    );
    Navigator.pop(context);
  }

  Future<void> _excluirTalhao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir talhao'),
          content: const Text('Esse talhao sera excluido permanentemente do banco local.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      _isLoading = true;
    });

    await DatabaseHelper.instance.deletarTalhaoComDependencias(widget.idLocal);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Talhao excluido do banco local.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BaseEditTemplate(
      title: 'Editar Talhões',
      headerDrawerTitle: 'Administrador',
      visibleOptions: const {
        DrawerMenuOption.homeAdmin,
        DrawerMenuOption.listaOperadores,
        DrawerMenuOption.registrarOperador,
        DrawerMenuOption.registrarTalhao,
        DrawerMenuOption.editarTalhao,
        DrawerMenuOption.registrarLote,
        DrawerMenuOption.editarLote,
        DrawerMenuOption.marketplace,
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
          hint: 'Operador referente',
          controll: _usuarioIdController,
          readOnly: true,
          errorText: _usuarioIdError,
          eventChange: (_) {
            setState(() {
              _usuarioIdError = LoginValidators.validateRequiredText(
                _usuarioIdController.text,
                fieldName: 'o operador',
                minLength: 3,
              );
            });
          },
        ),
        if (_operadorSelecionadoNome != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Operador selecionado: $_operadorSelecionadoNome',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.grass,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Nome do talhão',
          controll: _nomeTalhaoController,
          typeInput: TextInputType.name,
          errorText: _nomeTalhaoError,
          eventChange: (_) {
            setState(() {
              _nomeTalhaoError = LoginValidators.validateRequiredText(
                _nomeTalhaoController.text,
                fieldName: 'o nome do talhão',
                minLength: 2,
              );
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.square_foot,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Tamanho (hectares)',
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
                fieldName: 'o tamanho em hectares',
              );
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.eco,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Cultura atual',
          controll: _culturaAtualController,
          errorText: _culturaAtualError,
          eventChange: (_) {
            setState(() {
              _culturaAtualError = LoginValidators.validateRequiredText(
                _culturaAtualController.text,
                fieldName: 'a cultura atual',
                minLength: 2,
              );
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
        const SizedBox(height: 20),
        ButtonComponent(
          label: 'Excluir talhao',
          icon: Icons.delete_forever,
          width: double.infinity,
          height: 46,
          borderRadius: 4,
          backgroundColor: Colors.red,
          borderColor: Colors.red,
          textColor: Colors.white,
          onPressed: _excluirTalhao,
        ),
      ],
    );
  }
}
