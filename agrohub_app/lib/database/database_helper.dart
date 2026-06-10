import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fazendas (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        documento TEXT NOT NULL,
        hectares REAL,
        latitude TEXT,
        longitude TEXT,
        telefone TEXT,
        email TEXT,
        senha_adm TEXT,
        senha_operacao TEXT,
        status_sincronizacao INTEGER NOT NULL DEFAULT 0
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
        status_sincronizacao INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE operadores (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_completo TEXT NOT NULL,
        cpf TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        senha TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE talhoes (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        talhao_id_nuvem TEXT,
        usuario_id TEXT,
        nome TEXT NOT NULL,
        tamanho_hectares REAL NOT NULL,
        cultura_atual TEXT,
        status TEXT,
        status_sincronizacao INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE lotes (
        id_local INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id_nuvem TEXT,
        instancia_id TEXT,
        usuario_id TEXT,
        talhao_id TEXT,
        operador_id TEXT,
        codigo_rastreio TEXT,
        produto TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        unidade_medida TEXT NOT NULL,
        status TEXT,
        imagem_url TEXT,
        is_published INTEGER NOT NULL DEFAULT 0,
        data_registro TEXT NOT NULL,
        status_sincronizacao INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(db, 'talhoes', 'talhao_id_nuvem', 'TEXT');
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

  Future<int> inserirRegistro(String tabela, Map<String, dynamic> dados) async {
    final db = await instance.database;
    return await db.insert(tabela, dados,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> listarTodos(String tabela) async {
    final db = await instance.database;
    return await db.query(tabela);
  }

  Future<Map<String, dynamic>?> buscarPorId(String tabela, int idLocal) async {
    final db = await instance.database;
    final resultado = await db.query(
      tabela,
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
    if (resultado.isNotEmpty) {
      return resultado.first;
    }
    return null;
  }

  Future<int> atualizarRegistro(
      String tabela, Map<String, dynamic> dados, int idLocal) async {
    final db = await instance.database;
    dados['status_sincronizacao'] = 0;

    return await db.update(
      tabela,
      dados,
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }

  Future<int> deletarRegistro(String tabela, int idLocal) async {
    final db = await instance.database;
    return await db.delete(
      tabela,
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }

  Future<List<Map<String, dynamic>>> buscarNaoSincronizados(
      String tabela) async {
    final db = await instance.database;
    return await db.query(
      tabela,
      where: 'status_sincronizacao = ?',
      whereArgs: [0],
    );
  }

  Future<int> marcarComoSincronizado(String tabela, int idLocal) async {
    final db = await instance.database;
    return await db.update(
      tabela,
      {'status_sincronizacao': 1},
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }
}
