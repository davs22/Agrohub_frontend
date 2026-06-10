import 'package:agrohub_app/components/base_register_template.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/status_selector.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterTalhaoScreen extends StatefulWidget {
  const RegisterTalhaoScreen({super.key});

  @override
  State<RegisterTalhaoScreen> createState() => _RegisterTalhaoScreenState();
}

class _RegisterTalhaoScreenState extends State<RegisterTalhaoScreen> {
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

    await DatabaseHelper.instance.inserirRegistro('talhoes', dadosLocais);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Talhão salvo no banco local.')),
    );
    Navigator.pop(context);
  }

  Future<void> _selecionarOperador() async {
    final operadores = await DatabaseHelper.instance.listarTodos(
      'operadores',
      orderBy: 'id_local DESC',
    );

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
                  'Selecionar operador',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: operadores.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final operador = operadores[index];
                      return ListTile(
                        title: Text(operador['nome_completo']?.toString() ?? '-'),
                        subtitle: Text('ID ${operador['id_local']} • CPF ${operador['cpf'] ?? '-'}'),
                        onTap: () => Navigator.pop(context, operador),
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
      _usuarioIdController.text = selecionado['id_local']?.toString() ?? '';
      _operadorSelecionadoNome = selecionado['nome_completo']?.toString();
    });
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
          hint: 'Selecionar operador',
          controll: _usuarioIdController,
          readOnly: true,
          onTap: _selecionarOperador,
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
      ],
    );
  }
}
