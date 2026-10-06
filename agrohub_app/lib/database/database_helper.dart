import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'initial_seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agrohub_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: InitialSeedData.seed,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fazendas (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        documento TEXT NOT NULL,
        hectares REAL NOT NULL DEFAULT 0,
        latitude TEXT,
        longitude TEXT,
        telefone TEXT,
        email TEXT,
        senha_adm TEXT,
        senha_operacao TEXT,
        status TEXT NOT NULL DEFAULT 'ATIVO',
        data_registro TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE comercios (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        documento TEXT NOT NULL,
        cep TEXT,
        rua TEXT,
        telefone TEXT,
        email TEXT,
        senha_adm TEXT,
        senha_operacao TEXT,
        status TEXT NOT NULL DEFAULT 'ATIVO',
        data_registro TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE operadores (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        documento_admin TEXT,
        nome_completo TEXT NOT NULL,
        cpf TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        senha TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ATIVO',
        data_registro TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE talhoes (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        talhao_id_nuvem TEXT,
        usuario_id TEXT NOT NULL,
        nome TEXT NOT NULL,
        tamanho_hectares REAL NOT NULL,
        cultura_atual TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ATIVO',
        data_registro TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE lotes (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id_nuvem TEXT,
        instancia_id TEXT,
        usuario_id TEXT NOT NULL,
        talhao_id TEXT NOT NULL,
        operador_id TEXT NOT NULL,
        codigo_rastreio TEXT,
        produto TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        unidade_medida TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ATIVO',
        imagem_base64 TEXT,
        imagem_nome_arquivo TEXT,
        is_published INTEGER NOT NULL DEFAULT 0,
        data_registro TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE carrinho_itens (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        operador_id TEXT NOT NULL,
        lote_id TEXT NOT NULL,
        instancia_id TEXT,
        talhao_id TEXT,
        operador_lote_id TEXT,
        codigo_rastreio TEXT,
        produto TEXT NOT NULL,
        quantidade INTEGER NOT NULL DEFAULT 1,
        unidade_medida TEXT,
        imagem_base64 TEXT,
        imagem_nome_arquivo TEXT,
        talhao_nome TEXT,
        operador_nome TEXT,
        status TEXT NOT NULL DEFAULT 'ATIVO',
        data_registro TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await InitialSeedData.seed(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(
        db,
        'talhoes',
        'talhao_id_nuvem',
        'TEXT',
      );
      await _addColumnIfMissing(db, 'talhoes', 'usuario_id', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'lote_id_nuvem', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'instancia_id', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'usuario_id', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'talhao_id', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'operador_id', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'codigo_rastreio', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'status', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'imagem_url', 'TEXT');
      await _addColumnIfMissing(
          db, 'lotes', 'is_published', 'INTEGER NOT NULL DEFAULT 0');
    }

    if (oldVersion < 3) {
      await _addColumnIfMissing(
          db, 'fazendas', 'status', 'TEXT NOT NULL DEFAULT \'ATIVO\'');
      await _addColumnIfMissing(db, 'fazendas', 'data_registro', 'TEXT');
      await _addColumnIfMissing(db, 'fazendas', 'data_atualizacao', 'TEXT');
      await _addColumnIfMissing(
          db, 'comercios', 'status', 'TEXT NOT NULL DEFAULT \'ATIVO\'');
      await _addColumnIfMissing(db, 'comercios', 'data_registro', 'TEXT');
      await _addColumnIfMissing(db, 'comercios', 'data_atualizacao', 'TEXT');
      await _addColumnIfMissing(db, 'operadores', 'documento_admin', 'TEXT');
      await _addColumnIfMissing(
          db, 'operadores', 'status', 'TEXT NOT NULL DEFAULT \'ATIVO\'');
      await _addColumnIfMissing(db, 'operadores', 'data_registro', 'TEXT');
      await _addColumnIfMissing(db, 'operadores', 'data_atualizacao', 'TEXT');
      await _addColumnIfMissing(
          db, 'talhoes', 'status', 'TEXT NOT NULL DEFAULT \'ATIVO\'');
      await _addColumnIfMissing(db, 'talhoes', 'data_registro', 'TEXT');
      await _addColumnIfMissing(db, 'talhoes', 'data_atualizacao', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'imagem_base64', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'imagem_nome_arquivo', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'data_registro', 'TEXT');
      await _addColumnIfMissing(db, 'lotes', 'data_atualizacao', 'TEXT');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS carrinho_itens (
          id_local INTEGER PRIMARY KEY AUTOINCREMENT,
          operador_id TEXT NOT NULL,
          lote_id TEXT NOT NULL,
          instancia_id TEXT,
          talhao_id TEXT,
          operador_lote_id TEXT,
          codigo_rastreio TEXT,
          produto TEXT NOT NULL,
          quantidade INTEGER NOT NULL DEFAULT 1,
          unidade_medida TEXT,
          imagem_base64 TEXT,
          imagem_nome_arquivo TEXT,
          talhao_nome TEXT,
          operador_nome TEXT,
          status TEXT NOT NULL DEFAULT 'ATIVO',
          data_registro TEXT NOT NULL,
          data_atualizacao TEXT NOT NULL,
          status_sincronizacao INTEGER NOT NULL DEFAULT 1
        )
      ''');
    }
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((item) => item['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<int> inserirRegistro(
    String tabela,
    Map<String, dynamic> dados,
  ) async {
    final db = await database;
    final payload = Map<String, dynamic>.from(dados);
    final now = DateTime.now().toIso8601String();

    payload.putIfAbsent('data_registro', () => now);
    payload['data_atualizacao'] = now;
    payload['status_sincronizacao'] = 1;

    return db.insert(
      tabela,
      payload,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> salvarOuAtualizarPorColunaUnica(
    String tabela, {
    required String colunaUnica,
    required Object? valorUnico,
    required Map<String, dynamic> dados,
  }) async {
    final existente = await buscarPorColuna(
      tabela,
      colunaUnica,
      valorUnico,
    );

    if (existente != null) {
      final idLocal = existente['id_local'] as int?;
      if (idLocal != null) {
        return atualizarRegistro(tabela, dados, idLocal);
      }
    }

    return inserirRegistro(tabela, dados);
  }

  Future<int> atualizarRegistro(
    String tabela,
    Map<String, dynamic> dados,
    int idLocal,
  ) async {
    final db = await database;
    final payload = Map<String, dynamic>.from(dados);
    payload['status_sincronizacao'] = 1;
    payload['data_atualizacao'] = DateTime.now().toIso8601String();

    return db.update(
      tabela,
      payload,
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }

  Future<int> deletarRegistro(String tabela, int idLocal) async {
    final db = await database;
    return db.delete(
      tabela,
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }

  Future<int> deletarLoteComDependencias(int idLocal) async {
    final db = await database;
    return db.transaction((txn) async {
      await txn.delete(
        'carrinho_itens',
        where: 'lote_id = ?',
        whereArgs: [idLocal.toString()],
      );
      return txn.delete(
        'lotes',
        where: 'id_local = ?',
        whereArgs: [idLocal],
      );
    });
  }

  Future<int> deletarTalhaoComDependencias(int idLocal) async {
    final db = await database;
    return db.transaction((txn) async {
      final lotes = await txn.query(
        'lotes',
        columns: ['id_local'],
        where: 'talhao_id = ?',
        whereArgs: [idLocal.toString()],
      );

      for (final lote in lotes) {
        final loteId = lote['id_local'] as int?;
        if (loteId != null) {
          await txn.delete(
            'carrinho_itens',
            where: 'lote_id = ?',
            whereArgs: [loteId.toString()],
          );
        }
      }

      await txn.delete(
        'carrinho_itens',
        where: 'talhao_id = ?',
        whereArgs: [idLocal.toString()],
      );
      await txn.delete(
        'lotes',
        where: 'talhao_id = ?',
        whereArgs: [idLocal.toString()],
      );
      return txn.delete(
        'talhoes',
        where: 'id_local = ?',
        whereArgs: [idLocal],
      );
    });
  }

  Future<int> deletarOperadorComDependencias(int idLocal) async {
    final db = await database;
    return db.transaction((txn) async {
      await txn.delete(
        'carrinho_itens',
        where: 'operador_id = ? OR operador_lote_id = ?',
        whereArgs: [idLocal.toString(), idLocal.toString()],
      );
      await txn.delete(
        'lotes',
        where: 'operador_id = ? OR usuario_id = ?',
        whereArgs: [idLocal.toString(), idLocal.toString()],
      );
      await txn.delete(
        'talhoes',
        where: 'usuario_id = ?',
        whereArgs: [idLocal.toString()],
      );
      return txn.delete(
        'operadores',
        where: 'id_local = ?',
        whereArgs: [idLocal],
      );
    });
  }

  Future<int> deletarPorDocumento({
    required String tabela,
    required String documento,
  }) async {
    final db = await database;
    return db.delete(
      tabela,
      where: 'documento = ?',
      whereArgs: [documento],
    );
  }

  Future<List<Map<String, dynamic>>> listarTodos(
    String tabela, {
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(
      tabela,
      orderBy: orderBy ?? 'id_local DESC',
    );
  }

  Future<List<Map<String, dynamic>>> listarComFiltro(
    String tabela, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(
      tabela,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy ?? 'id_local DESC',
    );
  }

  Future<Map<String, dynamic>?> buscarPorId(
    String tabela,
    int idLocal,
  ) async {
    final db = await database;
    final resultado = await db.query(
      tabela,
      where: 'id_local = ?',
      whereArgs: [idLocal],
      limit: 1,
    );
    if (resultado.isEmpty) {
      return null;
    }
    return resultado.first;
  }

  Future<Map<String, dynamic>?> buscarPorColuna(
    String tabela,
    String coluna,
    Object? valor,
  ) async {
    final db = await database;
    final resultado = await db.query(
      tabela,
      where: '$coluna = ?',
      whereArgs: [valor],
      orderBy: 'id_local DESC',
      limit: 1,
    );
    if (resultado.isEmpty) {
      return null;
    }
    return resultado.first;
  }

  Future<int> contarRegistros(
    String tabela, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $tabela'
      '${where != null ? ' WHERE $where' : ''}',
      whereArgs ?? const [],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> marcarComoSincronizado(
    String tabela,
    int idLocal,
  ) async {
    final db = await database;
    return db.update(
      tabela,
      {
        'status_sincronizacao': 1,
        'data_atualizacao': DateTime.now().toIso8601String(),
      },
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }
}
