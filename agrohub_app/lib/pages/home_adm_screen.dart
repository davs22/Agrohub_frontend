import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/view/lotes.dart';
import 'package:agrohub_app/pages/view/marketplace.dart';
import 'package:agrohub_app/pages/view/operador.dart';
import 'package:agrohub_app/pages/view/talhoes.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/material.dart';

class HomeAdmScreen extends StatefulWidget {
  const HomeAdmScreen({super.key});

  @override
  State<HomeAdmScreen> createState() => _HomeAdmScreenState();
}

class _HomeDashboardData {
  final SessionData session;
  final Map<String, dynamic>? userRecord;
  final int totalOperadores;
  final int totalTalhoes;
  final int totalLotes;
  final int totalMarketplace;

  const _HomeDashboardData({
    required this.session,
    required this.userRecord,
    required this.totalOperadores,
    required this.totalTalhoes,
    required this.totalLotes,
    required this.totalMarketplace,
  });
}

class _HomeAdmScreenState extends State<HomeAdmScreen> {
  late Future<_HomeDashboardData?> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_HomeDashboardData?> _loadDashboard() async {
    final session = await SessionService.loadSession();
    if (session == null) {
      return null;
    }

    final userRecord = await DatabaseHelper.instance.buscarPorColuna(
      session.tableName,
      session.tableName == 'operadores' ? 'cpf' : 'documento',
      session.login,
    );

    final totalOperadores = await DatabaseHelper.instance.contarRegistros('operadores');
    final totalTalhoes = await DatabaseHelper.instance.contarRegistros('talhoes');
    final totalLotes = await DatabaseHelper.instance.contarRegistros('lotes');
    final totalMarketplace = await DatabaseHelper.instance.contarRegistros(
      'lotes',
      where: 'is_published = ?',
      whereArgs: [1],
    );

    return _HomeDashboardData(
      session: session,
      userRecord: userRecord,
      totalOperadores: totalOperadores,
      totalTalhoes: totalTalhoes,
      totalLotes: totalLotes,
      totalMarketplace: totalMarketplace,
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

  Widget _buildUserRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label ${_formatValue(value)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _summaryCard(String label, int value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(String label, VoidCallback onPressed) {
    return ButtonComponent(
      label: label,
      width: double.infinity,
      height: 46,
      borderRadius: 4,
      backgroundColor: const Color(0xFF24961F),
      borderColor: const Color(0xFF24961F),
      onPressed: onPressed,
    );
  }

  void _openOperadores() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ViewOperadorScreen()),
      (route) => route.isFirst,
    );
  }

  void _openTalhoes() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ViewTalhaoScreen()),
      (route) => route.isFirst,
    );
  }

  void _openLotes() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ViewLoteScreen()),
      (route) => route.isFirst,
    );
  }

  void _openMarketplace() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
      (route) => route.isFirst,
    );
  }

  void _openEditOperatorFlow() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ViewOperadorScreen()),
      (route) => route.isFirst,
    );
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
        child: FutureBuilder<_HomeDashboardData?>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(
                child: Text(
                  'Sessão não encontrada. Faça login novamente.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            final user = data.userRecord ?? const {};
            final isOperator = data.session.role == 'OPERADOR';
            final isAdmin = data.session.role == 'COMERCIO' || data.session.role == 'FAZENDA';
            final isBusiness = !isOperator;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const TextComponent(
                    text: 'Painel do administrador',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _summaryCard('Operadores', data.totalOperadores),
                      _summaryCard('Talhões', data.totalTalhoes),
                      _summaryCard('Lotes', data.totalLotes),
                      _summaryCard('Marketplace', data.totalMarketplace),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
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
                        const Text(
                          'Dados do administrador',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildUserRow('Nome:', user['nome'] ?? user['nome_completo']),
                        _buildUserRow('Documento:', user['documento'] ?? user['cpf']),
                        if (isBusiness) _buildUserRow('Hectares totais:', user['hectares']),
                        if (isBusiness) _buildUserRow('Latitude:', user['latitude']),
                        if (isBusiness) _buildUserRow('Longitude:', user['longitude']),
                        if (user['cep'] != null) _buildUserRow('Cep:', user['cep']),
                        if (user['rua'] != null) _buildUserRow('Rua:', user['rua']),
                        _buildUserRow('Telefone:', user['telefone']),
                        _buildUserRow('Email:', user['email']),
                        _buildUserRow('Status:', user['status']),
                        _buildUserRow('Data_registro:', _formatDate(user['data_registro'])),
                        _buildUserRow('Data_atualização:', _formatDate(user['data_atualizacao'])),
                        const SizedBox(height: 16),
                        if (isAdmin)
                          SizedBox(
                            width: double.infinity,
                            child: ButtonComponent(
                              label: 'Editar operador',
                              height: 46,
                              borderRadius: 4,
                              backgroundColor: const Color(0xFF24961F),
                              borderColor: const Color(0xFF24961F),
                              onPressed: _openEditOperatorFlow,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Atalhos rápidos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _quickAction('Ver operadores', _openOperadores),
                  const SizedBox(height: 8),
                  _quickAction('Ver talhões', _openTalhoes),
                  const SizedBox(height: 8),
                  _quickAction('Ver lotes', _openLotes),
                  const SizedBox(height: 8),
                  _quickAction('Abrir marketplace', _openMarketplace),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
