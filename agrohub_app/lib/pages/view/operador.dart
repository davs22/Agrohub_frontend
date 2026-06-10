import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/edit/operador.dart';
import 'package:flutter/material.dart';

class ViewOperadorScreen extends StatefulWidget {
  const ViewOperadorScreen({super.key});

  @override
  State<ViewOperadorScreen> createState() => _ViewOperadorScreenState();
}

class _ViewOperadorScreenState extends State<ViewOperadorScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _operadores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOperadores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOperadores() async {
    final data = await DatabaseHelper.instance.listarTodos(
      'operadores',
      orderBy: 'id_local DESC',
    );

    if (!mounted) return;

    setState(() {
      _operadores = data;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredOperadores {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _operadores;
    }

    return _operadores.where((item) {
      final values = [
        item['id_local'],
        item['documento_admin'],
        item['nome_completo'],
        item['cpf'],
        item['telefone'],
        item['email'],
        item['status'],
        item['data_registro'],
      ].map((value) => value?.toString().toLowerCase() ?? '');

      return values.any((value) => value.contains(query));
    }).toList();
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    if (text.isEmpty) return '-';
    return text;
  }

  String _formatDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return text;
    }

    final local = parsed.toLocal();
    return local.toString().split('.').first;
  }

  Widget _buildField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label ${_formatValue(value)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  void _openEdit(int idLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOperadorScreen(idLocal: idLocal),
      ),
    ).then((_) => _loadOperadores());
  }

  @override
  Widget build(BuildContext context) {
    final operadores = _filteredOperadores;

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
        headerTitle: 'Administrador',
        visibleOptions: {
          DrawerMenuOption.homeAdmin,
          DrawerMenuOption.listaOperadores,
          DrawerMenuOption.registrarOperador,
          DrawerMenuOption.editarOperador,
          DrawerMenuOption.registrarTalhao,
          DrawerMenuOption.editarTalhao,
          DrawerMenuOption.registrarLote,
          DrawerMenuOption.editarLote,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextComponent(
                text: 'Operadores',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Scrollbar(
                        thumbVisibility: true,
                        child: operadores.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum operador encontrado.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              )
                            : ListView.separated(
                                itemCount: operadores.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final operador = operadores[index];
                                  final idLocal = operador['id_local'] as int?;

                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _formatValue(operador['nome_completo']),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (idLocal != null)
                                              IconButton(
                                                onPressed: () => _openEdit(idLocal),
                                                icon: const Icon(Icons.edit),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _buildField('Id_operador:', operador['id_local']),
                                        _buildField('Cnpj/cpf_admin:', operador['documento_admin']),
                                        _buildField('Cpf:', operador['cpf']),
                                        _buildField('Telefone:', operador['telefone']),
                                        _buildField('Email:', operador['email']),
                                        _buildField('Status:', operador['status']),
                                        _buildField('Data_registro:', _formatDate(operador['data_registro'])),
                                        _buildField('Data_atualização:', _formatDate(operador['data_atualizacao'])),
                                        _buildField('Status_sinc:', operador['status_sincronizacao']),
                                      ],
                                    ),
                                  );
                                },
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
