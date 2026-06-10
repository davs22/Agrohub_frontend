import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/view/detalhe_produto.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _lotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarketplace();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketplace() async {
    final data = await DatabaseHelper.instance.listarComFiltro(
      'lotes',
      where: 'is_published = ?',
      whereArgs: [1],
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
    if (query.isEmpty) {
      return _lotes;
    }

    return _lotes.where((item) {
      final values = [
        item['produto'],
        item['data_registro'],
        item['status'],
        item['talhao_nome'],
        item['operador_nome'],
      ].map((value) => value?.toString().toLowerCase() ?? '');

      return values.any((value) => value.contains(query));
    }).toList();
  }

  String _formatDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return '-';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    return parsed.toLocal().toString().split('.').first;
  }

  Widget _buildImage(String? base64Value, double width, double height) {
    final bytes = LocalImageService.decodeImage(base64Value);
    if (bytes == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  void _openDetails(int idLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(idLocal: idLocal),
      ),
    ).then((_) => _loadMarketplace());
  }

  @override
  Widget build(BuildContext context) {
    final lotes = _filteredLotes;
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = ResponsiveLayout.isCompact(screenWidth);
    final imageWidth = ResponsiveLayout.listImageWidth(screenWidth);
    final imageHeight = ResponsiveLayout.listImageHeight(screenWidth);

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
        headerTitle: 'Operador',
        visibleOptions: {
          DrawerMenuOption.homeOperador,
          DrawerMenuOption.marketplace,
          DrawerMenuOption.talhoes,
          DrawerMenuOption.carrinho,
          DrawerMenuOption.perfilOperador,
          DrawerMenuOption.novaSenhaOperador,
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
                text: 'Marketplace',
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
                                  'Nenhum lote publicado encontrado.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              )
                            : ListView.separated(
                                itemCount: lotes.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                                    child: compact
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildImage(lote['imagem_base64']?.toString(), double.infinity, 180),
                                              const SizedBox(height: 12),
                                              Text(
                                                lote['produto']?.toString() ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Data: ${_formatDate(lote['data_registro'])}',
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ButtonComponent(
                                                  label: 'Mais detalhes',
                                                  height: 40,
                                                  fontSize: 15,
                                                  borderRadius: 4,
                                                  backgroundColor: const Color(0xFF24961F),
                                                  borderColor: const Color(0xFF24961F),
                                                  onPressed: idLocal == null ? null : () => _openDetails(idLocal),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildImage(lote['imagem_base64']?.toString(), imageWidth, imageHeight),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      lote['produto']?.toString() ?? '-',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Data: ${_formatDate(lote['data_registro'])}',
                                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
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

