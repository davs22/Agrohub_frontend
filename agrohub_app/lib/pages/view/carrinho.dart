import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/view/detalhe_produto.dart';
import 'package:agrohub_app/services/local_cart_service.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class CarrinhoScreen extends StatefulWidget {
  const CarrinhoScreen({super.key});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  late Future<_CarrinhoData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_CarrinhoData?> _loadData() async {
    final session = await SessionService.loadSession();
    if (session == null || session.localId == null) {
      return null;
    }

    final items = await LocalCartService.listarCarrinho(session.localId!.toString());
    return _CarrinhoData(session: session, items: items);
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  String _formatDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return '-';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    return parsed.toLocal().toString().split('.').first;
  }

  Widget _image(String? base64Value, double width, double height) {
    final bytes = LocalImageService.decodeImage(base64Value);
    if (bytes == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  void _refresh() {
    setState(() {
      _future = _loadData();
    });
  }

  Future<void> _removerItem(int idLocal) async {
    await LocalCartService.removerItem(idLocal);
    _refresh();
  }

  Future<void> _finalizarCompra(String operadorId) async {
    await LocalCartService.finalizarCompra(operadorId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra finalizada no banco local.')),
    );
    _refresh();
  }

  void _openDetails(int loteId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(idLocal: loteId)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<_CarrinhoData?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(
                child: Text(
                  'Carrinho nao encontrado.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            final items = data.items;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextComponent(
                    text: 'Carrinho',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text(
                              'Seu carrinho está vazio.',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          )
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final idLocal = item['id_local'] as int?;
                                final loteId = int.tryParse(item['lote_id']?.toString() ?? '');

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: compact
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _image(item['imagem_base64']?.toString(), double.infinity, 160),
                                            const SizedBox(height: 12),
                                            _line('Produto:', item['produto']),
                                            _line('Data_registro:', _formatDate(item['data_registro'])),
                                            _line('Talhão:', item['talhao_nome']),
                                            _line('Operador:', item['operador_nome']),
                                            const SizedBox(height: 10),
                                            Column(
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ButtonComponent(
                                                    label: 'Mais detalhes',
                                                    height: 38,
                                                    borderRadius: 6,
                                                    backgroundColor: const Color(0xFF24961F),
                                                    borderColor: const Color(0xFF24961F),
                                                    onPressed: loteId == null ? null : () => _openDetails(loteId),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ButtonComponent(
                                                    label: 'Excluir',
                                                    height: 38,
                                                    borderRadius: 6,
                                                    backgroundColor: const Color(0xFFFF1D1D),
                                                    borderColor: const Color(0xFFFF1D1D),
                                                    textColor: Colors.black,
                                                    onPressed: idLocal == null ? null : () => _removerItem(idLocal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _image(item['imagem_base64']?.toString(), imageWidth, imageHeight),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _line('Produto:', item['produto']),
                                                  _line('Data_registro:', _formatDate(item['data_registro'])),
                                                  _line('Talhão:', item['talhao_nome']),
                                                  _line('Operador:', item['operador_nome']),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: ButtonComponent(
                                                          label: 'Mais detalhes',
                                                          height: 38,
                                                          borderRadius: 6,
                                                          backgroundColor: const Color(0xFF24961F),
                                                          borderColor: const Color(0xFF24961F),
                                                          onPressed: loteId == null ? null : () => _openDetails(loteId),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        width: 48,
                                                        height: 38,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFFF1D1D),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: IconButton(
                                                          padding: EdgeInsets.zero,
                                                          onPressed: idLocal == null ? null : () => _removerItem(idLocal),
                                                          icon: const Icon(Icons.delete, color: Colors.black),
                                                        ),
                                                      ),
                                                    ],
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonComponent(
                      label: 'Finalizar compra',
                      height: 46,
                      borderRadius: 8,
                      backgroundColor: const Color(0xFF24961F),
                      borderColor: const Color(0xFF24961F),
                      onPressed: items.isEmpty
                          ? null
                          : () => _finalizarCompra(data.session.localId!.toString()),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _line(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label ${_formatValue(value)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CarrinhoData {
  final SessionData session;
  final List<Map<String, dynamic>> items;

  const _CarrinhoData({
    required this.session,
    required this.items,
  });
}
