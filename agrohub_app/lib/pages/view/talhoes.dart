import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/edit/talhao.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter/material.dart';

class ViewTalhaoScreen extends StatefulWidget {
  const ViewTalhaoScreen({super.key});

  @override
  State<ViewTalhaoScreen> createState() => _ViewTalhaoScreenState();
}

class _ViewTalhaoScreenState extends State<ViewTalhaoScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _talhoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTalhoes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTalhoes() async {
    final data = await DatabaseHelper.instance.listarTodos(
      'talhoes',
      orderBy: 'id_local DESC',
    );

    final enriched = <Map<String, dynamic>>[];
    for (final item in data) {
      final operadorId = item['usuario_id']?.toString();
      String? operadorNome;

      if (operadorId != null && operadorId.isNotEmpty) {
        final operador = await DatabaseHelper.instance.buscarPorColuna(
          'operadores',
          'id_local',
          operadorId,
        );
        operadorNome = operador?['nome_completo']?.toString();
      }

      enriched.add({
        ...item,
        'operador_nome': operadorNome,
      });
    }

    if (!mounted) return;

    setState(() {
      _talhoes = enriched;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredTalhoes {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _talhoes;

    return _talhoes.where((item) {
      final values = [
        item['id_local'],
        item['operador_nome'],
        item['nome'],
        item['tamanho_hectares'],
        item['cultura_atual'],
        item['status'],
        item['data_registro'],
      ].map((value) => value?.toString().toLowerCase() ?? '');

      return values.any((value) => value.contains(query));
    }).toList();
  }

  String _text(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return '-';
    return text;
  }

  String _date(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return '-';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    return parsed.toLocal().toString().split('.').first;
  }

  Widget _field(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label ${_text(value)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  void _openEdit(int idLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTalhaoScreen(idLocal: idLocal)),
    ).then((_) => _loadTalhoes());
  }

  @override
  Widget build(BuildContext context) {
    final talhoes = _filteredTalhoes;

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
          DrawerMenuOption.homeAdmin,
          DrawerMenuOption.listaOperadores,
          DrawerMenuOption.registrarOperador,
          DrawerMenuOption.editarOperador,
          DrawerMenuOption.registrarTalhao,
          DrawerMenuOption.editarTalhao,
          DrawerMenuOption.registrarLote,
          DrawerMenuOption.editarLote,
          DrawerMenuOption.marketplace,
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
                text: 'Talhões',
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
                        child: talhoes.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum talhão encontrado.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              )
                            : ListView.separated(
                                itemCount: talhoes.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final talhao = talhoes[index];
                                  final idLocal = talhao['id_local'] as int?;

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
                                                _text(talhao['nome']),
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
                                        _field('Operador:', talhao['operador_nome']),
                                        _field('Nome do talhão:', talhao['nome']),
                                        _field('Tamanho (hectares):', talhao['tamanho_hectares']),
                                        _field('Cultura atual:', talhao['cultura_atual']),
                                        _field('Status:', talhao['status']),
                                        _field('Data de registro:', _date(talhao['data_registro'])),
                                        _field('Data de atualização:', _date(talhao['data_atualizacao'])),
                                        _field('Status de sincronização:', talhao['status_sincronizacao']),
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
      ),
    );
  }
}
