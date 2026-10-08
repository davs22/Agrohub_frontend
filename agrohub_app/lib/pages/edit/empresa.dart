import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/models/company_profile.dart';
import 'package:agrohub_app/repositories/company_repository.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:agrohub_app/view_models/company_view_model.dart';
import 'package:flutter/material.dart';

class CompanyEditLoader extends StatefulWidget {
  const CompanyEditLoader({super.key});
  @override
  State<CompanyEditLoader> createState() => _CompanyEditLoaderState();
}

class _CompanyEditLoaderState extends State<CompanyEditLoader> {
  late final Future<CompanyProfile?> _company = CompanyRepository().current();
  @override
  Widget build(BuildContext context) => FutureBuilder<CompanyProfile?>(
    future: _company,
    builder: (context, snapshot) {
      if (snapshot.hasData) return EditEmpresaScreen(company: snapshot.data!);
      return Scaffold(
        appBar: const AppBarComponent(title: 'Dados da empresa'),
        body: Center(child: snapshot.connectionState != ConnectionState.done
          ? const CircularProgressIndicator()
          : const Text('Entre como administrador para editar sua empresa.')),
      );
    },
  );
}

class EditEmpresaScreen extends StatefulWidget {
  const EditEmpresaScreen({super.key, required this.company});
  final CompanyProfile company;

  @override
  State<EditEmpresaScreen> createState() => _EditEmpresaScreenState();
}

class _EditEmpresaScreenState extends State<EditEmpresaScreen> {
  final _form = GlobalKey<FormState>();
  final _viewModel = CompanyViewModel();
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {for (final name in ['nome', 'telefone', 'email', 'hectares', 'latitude', 'longitude', 'cep', 'rua'])
      name: TextEditingController(text: widget.company.record[name]?.toString() ?? '')};
  }

  @override
  void dispose() {
    for (final field in _fields.values) { field.dispose(); }
    _viewModel.dispose();
    super.dispose();
  }

  Widget _input(String key, String label, IconData icon, {TextInputType? keyboard, String? Function(String)? validate}) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: _fields[key],
      enabled: !_viewModel.saving,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) => validate?.call(value ?? ''),
    ),
  );

  String? _optional(String value, String? Function(String) validator) => value.trim().isEmpty ? null : validator(value);

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final values = <String, dynamic>{for (final entry in _fields.entries) entry.key: entry.value.text.trim()};
    if (widget.company.isFarm) values['hectares'] = double.parse(_fields['hectares']!.text.replaceAll(',', '.'));
    values['telefone'] = _fields['telefone']!.text.replaceAll(RegExp(r'\D'), '');
    values['cep'] = _fields['cep']!.text.replaceAll(RegExp(r'\D'), '');
    final saved = await _viewModel.save(widget.company, values);
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados da empresa atualizados.')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBarComponent(title: widget.company.isFarm ? 'Editar fazenda' : 'Editar comércio'),
    body: SafeArea(child: ListenableBuilder(listenable: _viewModel, builder: (context, _) => Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Form(key: _form, child: ListView(padding: const EdgeInsets.all(24), children: [
        Text('Informações da empresa', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('CPF / CNPJ: ${DisplayFormatters.document(widget.company.document)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        _input('nome', widget.company.isFarm ? 'Nome da fazenda' : 'Nome do comércio', Icons.business, validate: (value) => LoginValidators.validateRequiredText(value, fieldName: 'o nome', minLength: 2)),
        _input('telefone', 'Telefone', Icons.phone_outlined, keyboard: TextInputType.phone, validate: (value) => _optional(value, LoginValidators.validatePhone)),
        _input('email', 'E-mail', Icons.mail_outline, keyboard: TextInputType.emailAddress, validate: (value) => _optional(value, LoginValidators.validateEmail)),
        if (widget.company.isFarm) ...[
          _input('hectares', 'Área total (hectares)', Icons.landscape_outlined, keyboard: const TextInputType.numberWithOptions(decimal: true), validate: (value) {
            final area = double.tryParse(value.replaceAll(',', '.'));
            return area == null || !area.isFinite || area < 0 ? 'Informe uma área válida.' : null;
          }),
          _input('latitude', 'Latitude (opcional)', Icons.location_on_outlined, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true), validate: (value) => _optional(value, LoginValidators.validateLatitude)),
          _input('longitude', 'Longitude (opcional)', Icons.location_on_outlined, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true), validate: (value) => _optional(value, LoginValidators.validateLongitude)),
        ] else ...[
          _input('cep', 'CEP', Icons.location_on_outlined, keyboard: TextInputType.number, validate: (value) => value.isEmpty || value.replaceAll(RegExp(r'\D'), '').length == 8 ? null : 'Informe um CEP com 8 números.'),
          _input('rua', 'Endereço', Icons.map_outlined, keyboard: TextInputType.streetAddress),
        ],
        if (_viewModel.error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(_viewModel.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        FilledButton.icon(onPressed: _viewModel.saving ? null : _save, icon: const Icon(Icons.check), label: Text(_viewModel.saving ? 'Salvando...' : 'Salvar alterações')),
      ])),
    )))),
  );
}
