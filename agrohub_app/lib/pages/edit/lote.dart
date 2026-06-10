import 'package:agrohub_app/components/base_edit_template.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/status_selector.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditLoteScreen extends StatefulWidget {
  final int idLocal;

  const EditLoteScreen({super.key, required this.idLocal});

  @override
  State<EditLoteScreen> createState() => _EditLoteScreenState();
}

class _EditLoteScreenState extends State<EditLoteScreen> {
  final TextEditingController _talhaoIdController = TextEditingController();
  final TextEditingController _operadorIdController = TextEditingController();
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _unidadeMedidaController = TextEditingController();

  bool _ativo = true;
  bool _isPublished = false;
  bool _isLoading = false;
  String? _talhaoIdError;
  String? _operadorIdError;
  String? _produtoError;
  String? _quantidadeError;
  String? _unidadeMedidaError;
  String? _imagemBase64;
  String? _imagemNomeArquivo;
  String? _talhaoSelecionadoNome;
  String? _operadorSelecionadoNome;

  @override
  void initState() {
    super.initState();
    _loadLote();
  }

  @override
  void dispose() {
    _talhaoIdController.dispose();
    _operadorIdController.dispose();
    _produtoController.dispose();
    _quantidadeController.dispose();
    _unidadeMedidaController.dispose();
    super.dispose();
  }

  Future<void> _loadLote() async {
    final record = await DatabaseHelper.instance.buscarPorId('lotes', widget.idLocal);
    if (record == null || !mounted) {
      return;
    }

    String? talhaoNome;
    String? operadorNome;

    final talhaoId = record['talhao_id']?.toString();
    if (talhaoId != null && talhaoId.isNotEmpty) {
      final talhao = await DatabaseHelper.instance.buscarPorColuna('talhoes', 'id_local', talhaoId);
      talhaoNome = talhao?['nome']?.toString();
    }

    final operadorId = record['operador_id']?.toString();
    if (operadorId != null && operadorId.isNotEmpty) {
      final operador = await DatabaseHelper.instance.buscarPorColuna('operadores', 'id_local', operadorId);
      operadorNome = operador?['nome_completo']?.toString();
    }

    setState(() {
      _talhaoIdController.text = record['talhao_id']?.toString() ?? '';
      _operadorIdController.text = record['operador_id']?.toString() ?? '';
      _produtoController.text = record['produto']?.toString() ?? '';
      _quantidadeController.text = record['quantidade']?.toString() ?? '';
      _unidadeMedidaController.text = record['unidade_medida']?.toString() ?? '';
      _ativo = record['status']?.toString().toUpperCase() != 'INATIVO';
      _isPublished = record['is_published']?.toString() == '1';
      _imagemBase64 = record['imagem_base64']?.toString();
      _imagemNomeArquivo = record['imagem_nome_arquivo']?.toString();
      _talhaoSelecionadoNome = talhaoNome;
      _operadorSelecionadoNome = operadorNome;
    });
  }

  Future<void> _selecionarImagem() async {
    final selection = await LocalImageService.pickImage();
    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _imagemBase64 = selection.base64Data;
      _imagemNomeArquivo = selection.fileName;
    });
  }

  Future<void> _selecionarTalhao() async {
    final talhoes = await DatabaseHelper.instance.listarTodos('talhoes', orderBy: 'id_local DESC');

    if (!mounted) return;

    final selecionado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Selecionar talhão',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: talhoes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final talhao = talhoes[index];
                      return ListTile(
                        title: Text(talhao['nome']?.toString() ?? '-'),
                        subtitle: Text('ID ${talhao['id_local']} • Operador ${talhao['usuario_id'] ?? '-'}'),
                        onTap: () => Navigator.pop(context, talhao),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selecionado == null || !mounted) return;

    setState(() {
      _talhaoIdController.text = selecionado['id_local']?.toString() ?? '';
      _talhaoSelecionadoNome = selecionado['nome']?.toString();
    });
  }

  Future<void> _validarFormulario() async {
    final talhaoIdError = LoginValidators.validateRequiredText(
      _talhaoIdController.text,
      fieldName: 'o talhão',
      minLength: 1,
    );
    final operadorIdError = LoginValidators.validateRequiredText(
      _operadorIdController.text,
      fieldName: 'o operador',
      minLength: 1,
    );
    final produtoError = LoginValidators.validateRequiredText(
      _produtoController.text,
      fieldName: 'o produto',
      minLength: 2,
    );
    final quantidadeError = LoginValidators.validatePositiveNumber(
      _quantidadeController.text,
      fieldName: 'a quantidade',
    );
    final unidadeMedidaError = LoginValidators.validateRequiredText(
      _unidadeMedidaController.text,
      fieldName: 'a unidade de medida',
      minLength: 1,
    );

    setState(() {
      _talhaoIdError = talhaoIdError;
      _operadorIdError = operadorIdError;
      _produtoError = produtoError;
      _quantidadeError = quantidadeError;
      _unidadeMedidaError = unidadeMedidaError;
    });

    final hasError = [
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
    final dadosLocais = {
      'usuario_id': _operadorIdController.text,
      'talhao_id': _talhaoIdController.text,
      'operador_id': _operadorIdController.text,
      'produto': _produtoController.text,
      'quantidade': quantidade,
      'unidade_medida': _unidadeMedidaController.text,
      'status': _ativo ? 'ATIVO' : 'INATIVO',
      'imagem_base64': _imagemBase64,
      'imagem_nome_arquivo': _imagemNomeArquivo,
      'is_published': _isPublished ? 1 : 0,
    };

    await DatabaseHelper.instance.atualizarRegistro('lotes', dadosLocais, widget.idLocal);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lote atualizado no banco local.')),
    );
    await FlowNavigation.goToRoot(context);
  }

  Future<void> _excluirLote() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir lote'),
          content: const Text('Esse lote sera excluido permanentemente do banco local.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(96, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                maxLines: 1,
                softWrap: false,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(96, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Excluir',
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      _isLoading = true;
    });

    await DatabaseHelper.instance.deletarLoteComDependencias(widget.idLocal);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lote excluido do banco local.')),
    );
    await FlowNavigation.goToRoot(context);
  }

  Widget _imagePreview() {
    final bytes = LocalImageService.decodeImage(_imagemBase64);
    if (bytes == null) {
      return Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Nenhuma imagem selecionada',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        bytes,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseEditTemplate(
      title: 'Editar Lotes',
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
                minLength: 2,
              );
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.grass,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Selecionar talhão',
          controll: _talhaoIdController,
          readOnly: true,
          onTap: _selecionarTalhao,
          errorText: _talhaoIdError,
          eventChange: (_) {
            setState(() {
              _talhaoIdError = LoginValidators.validateRequiredText(
                _talhaoIdController.text,
                fieldName: 'o talhão',
                minLength: 1,
              );
            });
          },
        ),
        if (_talhaoSelecionadoNome != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Talhão selecionado: $_talhaoSelecionadoNome',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.manage_accounts,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Operador referente',
          controll: _operadorIdController,
          readOnly: true,
          errorText: _operadorIdError,
          eventChange: (_) {
            setState(() {
              _operadorIdError = LoginValidators.validateRequiredText(
                _operadorIdController.text,
                fieldName: 'o operador',
                minLength: 1,
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
          emoji: Icons.numbers,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Quantidade',
          controll: _quantidadeController,
          typeInput: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: _quantidadeError,
          eventChange: (_) {
            setState(() {
              _quantidadeError = LoginValidators.validatePositiveNumber(
                _quantidadeController.text,
                fieldName: 'a quantidade',
              );
            });
          },
        ),
        const SizedBox(height: 20),
        InputComponent(
          emoji: Icons.scale,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'Unidade de medida',
          controll: _unidadeMedidaController,
          errorText: _unidadeMedidaError,
          eventChange: (_) {
            setState(() {
              _unidadeMedidaError = LoginValidators.validateRequiredText(
                _unidadeMedidaController.text,
                fieldName: 'a unidade de medida',
                minLength: 1,
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
        const SizedBox(height: 16),
        _imagePreview(),
        const SizedBox(height: 12),
        ButtonComponent(
          label: _imagemBase64 == null ? 'Selecionar imagem' : 'Trocar imagem',
          icon: Icons.image,
          width: double.infinity,
          height: 45,
          fontSize: 15,
          borderRadius: 4,
          backgroundColor: const Color(0xFFE0E0E0),
          borderColor: const Color(0xFFE0E0E0),
          onPressed: _selecionarImagem,
        ),
        if (_imagemBase64 != null) ...[
          const SizedBox(height: 8),
          ButtonComponent(
            label: 'Remover imagem',
            icon: Icons.delete_outline,
            width: double.infinity,
            height: 45,
            fontSize: 15,
            borderRadius: 4,
            backgroundColor: const Color(0xFFE0E0E0),
            borderColor: const Color(0xFFE0E0E0),
            onPressed: () {
              setState(() {
                _imagemBase64 = null;
                _imagemNomeArquivo = null;
              });
            },
          ),
        ],
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
          title: Text(
            'Adicionar no marketplace',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ButtonComponent(
          label: 'Excluir lote',
          icon: Icons.delete_forever,
          width: double.infinity,
          height: 46,
          borderRadius: 4,
          backgroundColor: Colors.red,
          borderColor: Colors.red,
          textColor: Colors.white,
          onPressed: _excluirLote,
        ),
      ],
    );
  }
}

