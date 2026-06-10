import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/view/carrinho.dart';
import 'package:agrohub_app/pages/view/detalhe_produto.dart';
import 'package:agrohub_app/pages/view/marketplace.dart';
import 'package:agrohub_app/pages/view/perfil_operador.dart';
import 'package:agrohub_app/pages/view/talhoes_operador.dart';
import 'package:agrohub_app/services/local_cart_service.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class HomeOperadorScreen extends StatefulWidget {
  const HomeOperadorScreen({super.key});

  @override
  State<HomeOperadorScreen> createState() => _HomeOperadorScreenState();
}

class _HomeOperadorScreenState extends State<HomeOperadorScreen> {
  late Future<_HomeOperadorData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_HomeOperadorData?> _loadData() async {
    final session = await SessionService.loadSession();
    if (session == null || session.localId == null) {
      return null;
    }

    Map<String, dynamic>? operatorRecord = await DatabaseHelper.instance.buscarPorId(
      'operadores',
      session.localId!,
    );

    if (operatorRecord == null && (session.tableName == 'comercios' || session.tableName == 'fazendas')) {
      operatorRecord = await DatabaseHelper.instance.buscarPorColuna(
        session.tableName,
        'documento',
        session.login,
      );
    }

    final publishedLots = await DatabaseHelper.instance.listarComFiltro(
      'lotes',
      where: 'is_published = ?',
      whereArgs: [1],
      orderBy: 'id_local DESC',
    );
    final publishedLotsCount = await DatabaseHelper.instance.contarRegistros(
      'lotes',
      where: 'is_published = ?',
      whereArgs: [1],
    );

    final cartCount = await LocalCartService.contarItens(session.localId!.toString());
    final talhoesCount = await DatabaseHelper.instance.contarRegistros(
      'talhoes',
      where: 'usuario_id = ?',
      whereArgs: [session.localId!.toString()],
    );

    return _HomeOperadorData(
      session: session,
      operatorRecord: operatorRecord,
      publishedLots: publishedLots.take(4).toList(),
      publishedLotsCount: publishedLotsCount,
      cartCount: cartCount,
      talhoesCount: talhoesCount,
    );
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

  Widget _metricCard(String label, String value, IconData icon, double width) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF24961F).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1B5E20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredCard(Map<String, dynamic> lote) {
    final image = LocalImageService.decodeImage(lote['imagem_base64']?.toString());
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = ResponsiveLayout.isCompact(screenWidth);
    final imageWidth = ResponsiveLayout.listImageWidth(screenWidth);
    final imageHeight = ResponsiveLayout.listImageHeight(screenWidth);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black87),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: image == null
                      ? Container(
                          width: double.infinity,
                          height: 160,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        )
                      : Image.memory(
                          image,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatValue(lote['produto']),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Talhão: ${_formatValue(lote['talhao_nome'])}'),
                Text('Data: ${_formatDate(lote['data_registro'])}'),
                const SizedBox(height: 10),
                ButtonComponent(
                  label: 'Ver detalhes',
                  height: 40,
                  borderRadius: 8,
                  backgroundColor: const Color(0xFF24961F),
                  borderColor: const Color(0xFF24961F),
                  onPressed: () {
                    final idLocal = lote['id_local'] as int?; 
                    if (idLocal == null) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(idLocal: idLocal),
                      ),
                      (route) => route.isFirst,
                    ).then((_) => setState(() => _future = _loadData()));
                  },
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: image == null
                      ? Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        )
                      : Image.memory(
                          image,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatValue(lote['produto']),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Talhão: ${_formatValue(lote['talhao_nome'])}'),
                      Text('Data: ${_formatDate(lote['data_registro'])}'),
                      const SizedBox(height: 10),
                      ButtonComponent(
                        label: 'Ver detalhes',
                        height: 40,
                        borderRadius: 8,
                        backgroundColor: const Color(0xFF24961F),
                        borderColor: const Color(0xFF24961F),
                        onPressed: () {
                          final idLocal = lote['id_local'] as int?;
                          if (idLocal == null) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(idLocal: idLocal),
                            ),
                            (route) => route.isFirst,
                          ).then((_) => setState(() => _future = _loadData()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _openMarketplace() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
      (route) => route.isFirst,
    ).then((_) => setState(() => _future = _loadData()));
  }

  void _openCarrinho() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CarrinhoScreen()),
      (route) => route.isFirst,
    ).then((_) => setState(() => _future = _loadData()));
  }

  void _openPerfil() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PerfilOperadorScreen()),
      (route) => route.isFirst,
    ).then((_) => setState(() => _future = _loadData()));
  }

  void _openTalhoes() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ViewTalhaoOperadorScreen()),
      (route) => route.isFirst,
    ).then((_) => setState(() => _future = _loadData()));
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<_HomeOperadorData?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(
                child: Text(
                  'Sessao nao encontrada. Faça login novamente.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            final screenWidth = MediaQuery.of(context).size.width;
            final contentWidth = ResponsiveLayout.homeMaxWidth(screenWidth);
            final metricWidth = ResponsiveLayout.summaryCardWidth(screenWidth);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF24961F), Color(0xFF1C7B18)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo, ${_formatValue(data.session.displayName ?? data.operatorRecord?['nome_completo'] ?? data.operatorRecord?['nome'])}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tudo pronto para acompanhar seus lotes e compras locais.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _metricCard('Marketplace', data.publishedLotsCount.toString(), Icons.storefront, metricWidth),
                              _metricCard('Carrinho', data.cartCount.toString(), Icons.shopping_cart, metricWidth),
                              _metricCard('Talhões', data.talhoesCount.toString(), Icons.grass, metricWidth),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Ações rápidas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = ResponsiveLayout.isCompact(constraints.maxWidth);
                        final firstRow = [
                          Expanded(
                            child: ButtonComponent(
                              label: 'Marketplace',
                              height: 46,
                              borderRadius: 10,
                              backgroundColor: const Color(0xFF24961F),
                              borderColor: const Color(0xFF24961F),
                              onPressed: _openMarketplace,
                            ),
                          ),
                          Expanded(
                            child: ButtonComponent(
                              label: 'Carrinho',
                              height: 46,
                              borderRadius: 10,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              borderColor: Theme.of(context).colorScheme.outlineVariant,
                              textColor: Theme.of(context).colorScheme.onSurface,
                              onPressed: _openCarrinho,
                            ),
                          ),
                        ];
                        final secondRow = [
                          Expanded(
                            child: ButtonComponent(
                              label: 'Perfil',
                              height: 46,
                              borderRadius: 10,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              borderColor: Theme.of(context).colorScheme.outlineVariant,
                              textColor: Theme.of(context).colorScheme.onSurface,
                              onPressed: _openPerfil,
                            ),
                          ),
                          Expanded(
                            child: ButtonComponent(
                              label: 'Talhões',
                              height: 46,
                              borderRadius: 10,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              borderColor: Theme.of(context).colorScheme.outlineVariant,
                              textColor: Theme.of(context).colorScheme.onSurface,
                              onPressed: _openTalhoes,
                            ),
                          ),
                        ];

                        Widget pairedButtons(List<Widget> buttons) {
                          if (compact) {
                            return Column(
                              children: [
                                buttons[0],
                                const SizedBox(height: 8),
                                buttons[1],
                              ],
                            );
                          }

                          return Row(
                            children: [
                              buttons[0],
                              const SizedBox(width: 12),
                              buttons[1],
                            ],
                          );
                        }

                        return Column(
                          children: [
                            pairedButtons(firstRow),
                            const SizedBox(height: 12),
                            pairedButtons(secondRow),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Lotes em destaque',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (data.publishedLots.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: const Text(
                          'Nenhum lote disponível no momento.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      ...data.publishedLots.map(_featuredCard),
                  ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeOperadorData {
  final SessionData session;
  final Map<String, dynamic>? operatorRecord;
  final List<Map<String, dynamic>> publishedLots;
  final int publishedLotsCount;
  final int cartCount;
  final int talhoesCount;

  const _HomeOperadorData({
    required this.session,
    required this.operatorRecord,
    required this.publishedLots,
    required this.publishedLotsCount,
    required this.cartCount,
    required this.talhoesCount,
  });
}
