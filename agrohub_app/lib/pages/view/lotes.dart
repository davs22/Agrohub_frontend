import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/edit/lote.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter/material.dart';

class ViewLoteScreen extends StatefulWidget {
  const ViewLoteScreen({super.key});

  @override
  State<ViewLoteScreen> createState() => _ViewLoteScreenState();
}

class _ViewLoteScreenState extends State<ViewLoteScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _lotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLotes() async {
    final data = await DatabaseHelper.instance.listarTodos(
      'lotes',
      orderBy: 'id_local DESC',
    );

    final enriched = <Map<String, dynamic>>[];
    for (final item in data) {
      final talhaoId = item['talhao_id']?.toString();
      final operadorId = item['operador_id']?.toString();
      String? talhaoNome;
      String? operadorNome;

      if (talhaoId != null && talhaoId.isNotEmpty) {
        final talhao = await DatabaseHelper.instance.buscarPorColuna(
          'talhoes',
          'id_local',
          talhaoId,
        );
        talhaoNome = talhao?['nome']?.toString();
      }

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
        'talhao_nome': talhaoNome,
        'operador_nome': operadorNome,
      });
    }

    if (!mounted) return;

    setState(() {
      _lotes = enriched;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredLotes {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _lotes;

    return _lotes.where((item) {
      final values = [
        item['id_local'],
        item['produto'],
        item['talhao_nome'],
        item['operador_nome'],
        item['quantidade'],
        item['unidade_medida'],
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

  Widget _image(String? base64Value) {
    final bytes = LocalImageService.decodeImage(base64Value);
    if (bytes == null) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.memory(
        bytes,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      ),
    );
  }

  void _openEdit(int idLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditLoteScreen(idLocal: idLocal)),
    ).then((_) => _loadLotes());
  }

  @override
  Widget build(BuildContext context) {
    final lotes = _filteredLotes;

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
                text: 'Lotes',
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
                        child: lotes.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum lote encontrado.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              )
                            : ListView.separated(
                                itemCount: lotes.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final lote = lotes[index];
                                  final idLocal = lote['id_local'] as int?;

                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _image(lote['imagem_base64']),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _field('Produto:', lote['produto']),
                                                  _field('Talhão:', lote['talhao_nome']),
                                                  _field('Operador:', lote['operador_nome']),
                                                ],
                                              ),
                                            ),
                                            if (idLocal != null)
                                              IconButton(
                                                onPressed: () => _openEdit(idLocal),
                                                icon: const Icon(Icons.edit),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        _field('Quantidade:', lote['quantidade']),
                                        _field('Unidade de medida:', lote['unidade_medida']),
                                        _field('Status:', lote['status']),
                                        _field('Data de registro:', _date(lote['data_registro'])),
                                        _field('Data de atualização:', _date(lote['data_atualizacao'])),
                                        _field('Status de sincronização:', lote['status_sincronizacao']),
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
