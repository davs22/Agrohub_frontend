import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:agrohub_app/services/session_service.dart';

class ManagementRepository {
  const ManagementRepository();

  Future<SessionData> requireAdmin() async {
    final session = await SessionService.loadSession();
    if (session == null || !session.isAdmin ||
        !const {'fazendas', 'comercios'}.contains(session.tableName)) {
      throw StateError('Apenas administradores podem alterar esses dados.');
    }
    return session;
  }

  Future<List<Map<String, dynamic>>> operators() =>
      const InventoryRepository().load('operadores');

  Future<Map<String, dynamic>> find(String table, int id) async {
    await requireAdmin();
    final records = await const InventoryRepository().load(table);
    return records.firstWhere(
      (record) => record['id_local'] == id,
      orElse: () => throw StateError('Registro não encontrado na sua empresa.'),
    );
  }

  Future<void> save(String table, Map<String, dynamic> values, {int? id}) async {
    final session = await requireAdmin();
    if (id != null) await find(table, id);
    final payload = Map<String, dynamic>.from(values);
    if (table == 'operadores') {
      payload['documento_admin'] = session.documento ?? session.login;
      final duplicate = await DatabaseHelper.instance.buscarPorColuna(
        table, 'cpf', payload['cpf'],
      );
      if (duplicate != null && duplicate['id_local'] != id) {
        throw StateError('Já existe um operador com esse CPF.');
      }
      if (id != null && (payload['senha']?.toString().isEmpty ?? true)) {
        payload.remove('senha');
      }
    } else if (table == 'talhoes') {
      final choices = await operators();
      if (!choices.any((row) => row['id_local'].toString() == payload['usuario_id'])) {
        throw StateError('Selecione um operador da sua empresa.');
      }
    } else {
      throw ArgumentError.value(table);
    }
    if (id == null) {
      await DatabaseHelper.instance.inserirRegistro(table, payload);
    } else {
      await DatabaseHelper.instance.atualizarRegistro(table, payload, id);
    }
  }

  Future<void> delete(String table, int id) async {
    await find(table, id);
    final db = await DatabaseHelper.instance.database;
    if (table == 'operadores') {
      final fields = await db.query('talhoes', where: 'usuario_id = ?', whereArgs: [id.toString()], limit: 1);
      final lots = await db.query('lotes', where: 'operador_id = ?', whereArgs: [id.toString()], limit: 1);
      if (fields.isNotEmpty || lots.isNotEmpty) {
        throw StateError('Este operador possui talhões ou lotes. Desative o cadastro para preservar o histórico.');
      }
    } else if (table == 'talhoes') {
      final lots = await db.query('lotes', where: 'talhao_id = ?', whereArgs: [id.toString()], limit: 1);
      if (lots.isNotEmpty) {
        throw StateError('Este talhão possui lotes. Desative o cadastro para preservar o histórico.');
      }
    } else {
      throw ArgumentError.value(table);
    }
    await DatabaseHelper.instance.deletarRegistro(table, id);
  }
}
