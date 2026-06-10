import 'package:agrohub_app/database/database_helper.dart';

class LocalCartService {
  static Future<List<Map<String, dynamic>>> listarCarrinho(
    String operadorId,
  ) async {
    return DatabaseHelper.instance.listarComFiltro(
      'carrinho_itens',
      where: 'operador_id = ?',
      whereArgs: [operadorId],
      orderBy: 'id_local DESC',
    );
  }

  static Future<bool> adicionarAoCarrinho({
    required String operadorId,
    required Map<String, dynamic> lote,
  }) async {
    final loteId = lote['id_local']?.toString();
    if (loteId == null || loteId.isEmpty) {
      return false;
    }

    final existente = await DatabaseHelper.instance.listarComFiltro(
      'carrinho_itens',
      where: 'lote_id = ? AND operador_id = ?',
      whereArgs: [loteId, operadorId],
      orderBy: 'id_local DESC',
    );

    if (existente.isNotEmpty) {
      return false;
    }

    await DatabaseHelper.instance.inserirRegistro('carrinho_itens', {
      'operador_id': operadorId,
      'lote_id': loteId,
      'instancia_id': lote['instancia_id']?.toString(),
      'talhao_id': lote['talhao_id']?.toString(),
      'operador_lote_id': lote['operador_id']?.toString(),
      'codigo_rastreio': lote['codigo_rastreio']?.toString(),
      'produto': lote['produto']?.toString() ?? '',
      'quantidade': lote['quantidade'] ?? 1,
      'unidade_medida': lote['unidade_medida']?.toString(),
      'imagem_base64': lote['imagem_base64']?.toString(),
      'imagem_nome_arquivo': lote['imagem_nome_arquivo']?.toString(),
      'talhao_nome': lote['talhao_nome']?.toString(),
      'operador_nome': lote['operador_nome']?.toString(),
      'status': 'ATIVO',
    });

    return true;
  }

  static Future<void> removerItem(int idLocal) async {
    await DatabaseHelper.instance.deletarRegistro('carrinho_itens', idLocal);
  }

  static Future<void> limparCarrinho(String operadorId) async {
    final itens = await listarCarrinho(operadorId);
    for (final item in itens) {
      final idLocal = item['id_local'] as int?;
      if (idLocal != null) {
        await removerItem(idLocal);
      }
    }
  }

  static Future<int> contarItens(String operadorId) async {
    return DatabaseHelper.instance.contarRegistros(
      'carrinho_itens',
      where: 'operador_id = ?',
      whereArgs: [operadorId],
    );
  }

  static Future<bool> finalizarCompra(String operadorId) async {
    final itens = await listarCarrinho(operadorId);
    for (final item in itens) {
      final loteId = int.tryParse(item['lote_id']?.toString() ?? '');
      if (loteId == null) {
        continue;
      }

      await DatabaseHelper.instance.atualizarRegistro(
        'lotes',
        {
          'status': 'VENDIDO',
          'is_published': 0,
        },
        loteId,
      );
    }

    await limparCarrinho(operadorId);
    return true;
  }
}
