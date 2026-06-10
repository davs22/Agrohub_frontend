import 'package:agrohub_app/components/base_edit_template.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditOperadorScreen extends StatefulWidget {
  final int idLocal;

  const EditOperadorScreen({
    super.key,
    required this.idLocal,
  });

  @override
  State<EditOperadorScreen> createState() => _EditOperadorScreenState();
}

class _EditOperadorScreenState extends State<EditOperadorScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaOperadorController = TextEditingController();

  bool _ativo = true;
  String? _nomeError;
  String? _documentoError;
  String? _cpfError;
  String? _telefoneError;
  String? _emailError;
  String? _senhaOperadorError;
  bool _isLoading = false;
  bool _canManage = false;
  bool _accessChecked = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _loadOperador();
    _loadAdminDocumento();
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

  Future<void> _loadOperador() async {
    final record = await DatabaseHelper.instance.buscarPorId('operadores', widget.idLocal);
    if (record == null || !mounted) {
      return;
    }

    setState(() {
      _nomeController.text = record['nome_completo']?.toString() ?? '';
      _cpfController.text = record['cpf']?.toString() ?? '';
      _documentoController.text = record['documento_admin']?.toString() ?? '';
      _telefoneController.text = record['telefone']?.toString() ?? '';
      _emailController.text = record['email']?.toString() ?? '';
      _senhaOperadorController.text = record['senha']?.toString() ?? '';
      _ativo = record['status']?.toString().toUpperCase() != 'INATIVO';
    });
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

  Future<void> _loadPermissions() async {
    final session = await SessionService.loadSession();
    if (!mounted) return;

    final allowed = session != null &&
        (session.role == 'ADMIN' || session.role == 'COMERCIO' || session.role == 'FAZENDA');

    setState(() {
      _canManage = allowed;
      _accessChecked = true;
    });
  }

  Future<void> _validarFormulario() async {
    if (!_canManage) return;

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

    await DatabaseHelper.instance.atualizarRegistro(
      'operadores',
      dadosLocais,
      widget.idLocal,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operador atualizado no banco local.')),
    );
    await FlowNavigation.goToRoot(context);
  }

  Future<void> _excluirOperador() async {
    if (!_canManage) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir operador'),
          content: const Text('Esse operador sera excluido permanentemente do banco local.'),
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

    await DatabaseHelper.instance.deletarOperadorComDependencias(widget.idLocal);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operador excluido do banco local.')),
    );
    await FlowNavigation.goToRoot(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_accessChecked && !_canManage) {
      return FlowBackGuard(
        child: Scaffold(
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
              DrawerMenuOption.configuracoes,
              DrawerMenuOption.logout,
            },
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Apenas o administrador pode editar operadores.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      );
    }

    return BaseEditTemplate(
      title: 'Editar operador',
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
          emoji: Icons.badge,
          borderRadius: 4,
          width: double.infinity,
          height: 45,
          hint: 'CPF do operador',
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
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 12),
              Text(
                _ativo ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
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
        const SizedBox(height: 20),
        ButtonComponent(
          label: 'Excluir operador',
          icon: Icons.delete_forever,
          width: double.infinity,
          height: 46,
          borderRadius: 4,
          backgroundColor: Colors.red,
          borderColor: Colors.red,
          textColor: Colors.white,
          onPressed: _excluirOperador,
        ),
      ],
    );
  }
}

