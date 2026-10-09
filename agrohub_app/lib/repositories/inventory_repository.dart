import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/repositories/account_repository.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:sqflite/sqflite.dart';

class InventoryPage {
  const InventoryPage(this.records, this.total);
  final List<Map<String, dynamic>> records;
  final int total;
}

abstract class InventoryQueryRepository {
  Future<bool> canManage();
  Future<InventoryPage> loadPage(String table, {String search = '',
      String filter = 'all', int page = 0, int pageSize = 16});
}

class InventoryRepository implements InventoryQueryRepository {
  const InventoryRepository();

  @override
  Future<bool> canManage() async {
    final session = await SessionService.loadSession();
    return session?.isAdmin ?? false;
  }

  Future<String?> _companyDocument() async {
    final session = await SessionService.loadSession();
    if (session == null || session.localId == null) return null;
    if (session.tableName == 'operadores') {
      final account = await const SqliteAccountRepository()
          .findById('operadores', session.localId!);
      return account?.ownerDocument;
    }
    return session.documento;
  }

  static String normalize(String value) {
    var result = value.toLowerCase().trim();
    const groups = {'a': 'áàâãä', 'e': 'éèêë', 'i': 'íìîï',
      'o': 'óòôõö', 'u': 'úùûü', 'c': 'ç'};
    groups.forEach((letter, accents) {
      for (final accent in accents.split('')) {
        result = result.replaceAll(accent, letter);
      }
    });
    return result;
  }

  static String _normalizedColumn(String column) {
    var expression = 'COALESCE(CAST($column AS TEXT), \'\')';
    const groups = {'a': 'áàâãä', 'e': 'éèêë', 'i': 'íìîï',
      'o': 'óòôõö', 'u': 'úùûü', 'c': 'ç'};
    groups.forEach((letter, accents) {
      for (final accent in accents.split('')) {
        expression = "replace(replace($expression, '$accent', '$letter'), '${accent.toUpperCase()}', '$letter')";
      }
    });
    return 'lower($expression)';
  }

  static ({String from, String select, List<String> search, List<Object?> args})
      _scope(String table, String document) => switch (table) {
    'operadores' => (
        from: 'operadores o', select: 'o.*',
        search: ['o.nome_completo', 'o.telefone', 'o.email', 'o.cpf', 'o.status'],
        args: [document],
      ),
    'talhoes' => (
        from: 'talhoes t JOIN operadores o ON CAST(t.usuario_id AS INTEGER) = o.id_local',
        select: 't.*, o.nome_completo AS operador_nome',
        search: ['t.nome', 't.cultura_atual', 't.status', 'o.nome_completo'],
        args: [document],
      ),
    'lotes' => (
        from: 'lotes l JOIN operadores o ON CAST(l.operador_id AS INTEGER) = o.id_local '
            'JOIN talhoes t ON CAST(l.talhao_id AS INTEGER) = t.id_local '
            'JOIN operadores fo ON CAST(t.usuario_id AS INTEGER) = fo.id_local',
        select: 'l.*, t.nome AS talhao_nome, o.nome_completo AS operador_nome, '
            'o.telefone AS operador_telefone, o.email AS operador_email',
        search: ['l.produto', 'l.status', 'l.unidade_medida', 't.nome',
            'o.nome_completo', 'o.telefone', 'o.email'],
        args: [document, document],
      ),
    _ => throw ArgumentError.value(table, 'table'),
  };

  @override
  Future<InventoryPage> loadPage(String table, {String search = '',
      String filter = 'all', int page = 0, int pageSize = 16}) async {
    final document = await _companyDocument();
    if (document == null || document.isEmpty) return const InventoryPage([], 0);
    final scope = _scope(table, document);
    final alias = table == 'operadores' ? 'o' : table == 'talhoes' ? 't' : 'l';
    final where = <String>[if (table == 'lotes') ...[
      'o.documento_admin = ?', 'fo.documento_admin = ?'
    ] else 'o.documento_admin = ?'];
    final args = <Object?>[...scope.args];
    switch (filter) {
      case 'active': where.add('$alias.status = ?'); args.add('ATIVO');
      case 'inactive': where.add('$alias.status = ?'); args.add('INATIVO');
      case 'stock': where.add('l.quantidade > 0');
      case 'empty': where.add('l.quantidade <= 0');
      case 'published': where.add('l.is_published = 1');
      case 'expired':
        where.add('substr(l.data_validade, 1, 10) < ? AND l.data_validade IS NOT NULL');
        args.add(DateTime.now().toIso8601String().substring(0, 10));
    }
    final query = normalize(search);
    if (query.isNotEmpty) {
      where.add('(${scope.search.map((column) => '${_normalizedColumn(column)} LIKE ?').join(' OR ')})');
      args.addAll(List.filled(scope.search.length, '%$query%'));
    }
    final db = await DatabaseHelper.instance.database;
    final clause = where.join(' AND ');
    final count = await db.rawQuery('SELECT COUNT(*) AS total FROM ${scope.from} WHERE $clause', args);
    final total = Sqflite.firstIntValue(count) ?? 0;
    final rows = await db.rawQuery(
        'SELECT ${scope.select} FROM ${scope.from} WHERE $clause '
        'ORDER BY $alias.id_local DESC LIMIT ? OFFSET ?',
        [...args, pageSize, page * pageSize]);
    return InventoryPage(rows, total);
  }

  // Forms and dashboard need the full company-scoped relation. The listing
  // above uses SQL paging, while this method is reserved for those consumers.
  Future<List<Map<String, dynamic>>> load(String table) async {
    final result = <Map<String, dynamic>>[];
    var page = 0;
    while (true) {
      final current = await loadPage(table, page: page, pageSize: 200);
      result.addAll(current.records);
      if (result.length >= current.total) return result;
      page++;
    }
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
