import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/pages/edit/operador.dart';
import 'package:agrohub_app/pages/edit/pass_operador.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/material.dart';

class PerfilOperadorScreen extends StatefulWidget {
  const PerfilOperadorScreen({super.key});

  @override
  State<PerfilOperadorScreen> createState() => _PerfilOperadorScreenState();
}

class _PerfilOperadorScreenState extends State<PerfilOperadorScreen> {
  late Future<_PerfilOperadorData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_PerfilOperadorData?> _loadData() async {
    final session = await SessionService.loadSession();
    if (session == null || session.localId == null) {
      return null;
    }

    final record = await DatabaseHelper.instance.buscarPorId(
      'operadores',
      session.localId!,
    );

    return _PerfilOperadorData(session: session, record: record);
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

  void _openEdit(int idLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditOperadorScreen(idLocal: idLocal)),
    ).then((_) => setState(() => _future = _loadData()));
  }

  void _openReset() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewPassOperadorScreen()),
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
        child: FutureBuilder<_PerfilOperadorData?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;
            if (data == null || data.record == null) {
              return const Center(
                child: Text(
                  'Perfil nao encontrado.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            final record = data.record!;
            final idLocal = record['id_local'] as int?;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const TextComponent(
                    text: 'Perfil do operador',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field('Id_operador:', record['id_local']),
                        _field('Nome_completo:', record['nome_completo']),
                        _field('Cpf:', record['cpf']),
                        _field('Telefone:', record['telefone']),
                        _field('Email:', record['email']),
                        _field('Status:', record['status']),
                        _field('Data_registro:', _formatDate(record['data_registro'])),
                        _field('Data_atualizacao:', _formatDate(record['data_atualizacao'])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ButtonComponent(
                    label: 'Editar perfil',
                    height: 46,
                    borderRadius: 10,
                    backgroundColor: const Color(0xFF24961F),
                    borderColor: const Color(0xFF24961F),
                    onPressed: idLocal == null ? null : () => _openEdit(idLocal),
                  ),
                  const SizedBox(height: 10),
                  ButtonComponent(
                    label: 'Redefinir senha',
                    height: 46,
                    borderRadius: 10,
                    backgroundColor: Colors.white,
                    borderColor: Theme.of(context).colorScheme.onSurface,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    onPressed: _openReset,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PerfilOperadorData {
  final SessionData session;
  final Map<String, dynamic>? record;

  const _PerfilOperadorData({
    required this.session,
    required this.record,
  });
}

