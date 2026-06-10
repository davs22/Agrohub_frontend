import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/view/carrinho.dart';
import 'package:agrohub_app/services/local_cart_service.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final int idLocal;

  const ProductDetailScreen({super.key, required this.idLocal});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<Map<String, dynamic>?> _loadData() async {
    final lote = await DatabaseHelper.instance.buscarPorId('lotes', widget.idLocal);
    if (lote == null) {
      return null;
    }

    final talhaoId = lote['talhao_id']?.toString();
    final operadorId = lote['operador_id']?.toString();

    String? talhaoNome;
    String? operadorNome;
    String? operadorTelefone;
    String? operadorEmail;

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
      operadorTelefone = operador?['telefone']?.toString();
      operadorEmail = operador?['email']?.toString();
    }

    final session = await SessionService.loadSession();
    final instanciaNome = session?.displayName ?? 'AgroHub';

    return {
      ...lote,
      'talhao_nome': talhaoNome,
      'operador_nome': operadorNome,
      'operador_telefone': operadorTelefone,
      'operador_email': operadorEmail,
      'instancia_nome': instanciaNome,
    };
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

  Widget _field(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label ${_formatValue(value)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _image(String? base64Value) {
    final bytes = LocalImageService.decodeImage(base64Value);
    if (bytes == null) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.image_not_supported, size: 54),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        bytes,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _adicionarAoCarrinho(Map<String, dynamic> lote) async {
    final session = await SessionService.loadSession();
    final operadorId = session?.localId?.toString();
    if (operadorId == null) {
      return;
    }

    final added = await LocalCartService.adicionarAoCarrinho(
      operadorId: operadorId,
      lote: lote,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? 'Produto adicionado ao carrinho.' : 'Esse produto já está no carrinho.',
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CarrinhoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final lote = snapshot.data;
            if (lote == null) {
              return const Center(
                child: Text(
                  'Produto nao encontrado.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextComponent(
                      text: 'Detalhes do produto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 16),
                    _image(lote['imagem_base64']?.toString()),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _field('Id_lote:', lote['id_local']),
                          _field('Id_instância:', lote['instancia_id']),
                          _field('Id_talhão:', lote['talhao_id']),
                          _field('Id_operador:', lote['operador_id']),
                          _field('Código_rastreio:', lote['codigo_rastreio']),
                          _field('Produto:', lote['produto']),
                          _field('Quantidade:', lote['quantidade']),
                          _field('Unidade_medida:', lote['unidade_medida']),
                          _field('Data_registro:', _formatDate(lote['data_registro'])),
                          _field('Nome_instância:', lote['instancia_nome']),
                          _field('Talhão:', lote['talhao_nome']),
                          _field('Operador:', lote['operador_nome']),
                          _field('Telefone:', lote['operador_telefone']),
                          _field('Email:', lote['operador_email']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Coordenadas',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _field('Latitude:', lote['latitude']),
                          _field('Longitude:', lote['longitude']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ButtonComponent(
                            label: 'Adicionar ao carrinho',
                            height: 46,
                            borderRadius: 8,
                            backgroundColor: const Color(0xFF24961F),
                            borderColor: const Color(0xFF24961F),
                            onPressed: () => _adicionarAoCarrinho(lote),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 62,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          child: IconButton(
                            onPressed: _openCart,
                            icon: const Icon(Icons.shopping_cart, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}
