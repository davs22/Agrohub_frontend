import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/services/session_service.dart';

class InventoryRepository {
  const InventoryRepository();

  static String _document(Object? value) =>
      (value?.toString() ?? '').replaceAll(RegExp(r'\D'), '');

  Future<bool> canManage() async {
    final session = await SessionService.loadSession();
    return (session?.isAdmin ?? false) &&
        {'fazendas', 'comercios'}.contains(session?.tableName);
  }

  Future<List<Map<String, dynamic>>> load(String table) async {
    if (!{'operadores', 'talhoes', 'lotes'}.contains(table)) {
      throw ArgumentError.value(table, 'table');
    }
    final session = await SessionService.loadSession();
    if (session == null || session.localId == null) return [];
    final account = await DatabaseHelper.instance.buscarPorId(
      session.tableName,
      session.localId!,
    );
    final document = _document(session.tableName == 'operadores'
        ? (account?['documento_admin'])
        : (account?['documento'] ?? session.documento));
    if (document.isEmpty) return [];

    final allOperators = await DatabaseHelper.instance.listarTodos('operadores');
    final operators = allOperators
        .where((record) => _document(record['documento_admin']) == document)
        .toList();
    if (table == 'operadores') return operators;
    final operatorById = {
      for (final record in operators) record['id_local'].toString(): record,
    };
    final allFields = await DatabaseHelper.instance.listarTodos('talhoes');
    final fields = allFields
        .where((record) => operatorById.containsKey(record['usuario_id'].toString()))
        .map((record) => <String, dynamic>{
              ...record,
              'operador_nome': operatorById[record['usuario_id'].toString()]?['nome_completo'],
            })
        .toList();
    if (table == 'talhoes') return fields;
    final fieldById = {for (final record in fields) record['id_local'].toString(): record};
    final lots = await DatabaseHelper.instance.listarTodos('lotes', orderBy: 'id_local DESC');
    return lots
        .where((record) =>
            operatorById.containsKey(record['operador_id'].toString()) &&
            fieldById.containsKey(record['talhao_id'].toString()))
        .map((record) {
          final operator = operatorById[record['operador_id'].toString()];
          return <String, dynamic>{
            ...record,
            'talhao_nome': fieldById[record['talhao_id'].toString()]?['nome'],
            'operador_nome': operator?['nome_completo'],
            'operador_telefone': operator?['telefone'],
            'operador_email': operator?['email'],
          };
        })
        .toList();
  }

  Future<Map<String, dynamic>?> lot(int id) async {
    final lots = await load('lotes');
    for (final record in lots) {
      if (record['id_local'] == id) return record;
    }
    return null;
  }

  Future<void> saveLot(Map<String, dynamic> values, {int? id}) async {
    if (!await canManage()) throw StateError('Acesso restrito à administração.');
    final operators = await load('operadores');
    final fields = await load('talhoes');
    if (!operators.any((row) => row['id_local'].toString() == values['operador_id'].toString()) ||
        !fields.any((row) => row['id_local'].toString() == values['talhao_id'].toString())) {
      throw StateError('Selecione um talhão e um operador da sua empresa.');
    }
    if (id == null) {
      await DatabaseHelper.instance.inserirRegistro('lotes', values);
    } else {
      if (await lot(id) == null) throw StateError('Lote não encontrado.');
      await DatabaseHelper.instance.atualizarRegistro('lotes', values, id);
    }
  }

  Future<void> deleteLot(int id) async {
    if (!await canManage() || await lot(id) == null) {
      throw StateError('Lote não disponível para exclusão.');
    }
    await DatabaseHelper.instance.deletarLoteComDependencias(id);
  }
}
