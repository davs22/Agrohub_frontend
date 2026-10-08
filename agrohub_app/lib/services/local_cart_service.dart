class LocalCartService {
  static Future<List<Map<String, dynamic>>> listarCarrinho(String operadorId) async => const [];

  static Future<bool> adicionarAoCarrinho({
    required String operadorId,
    required Map<String, dynamic> lote,
  }) async => false;

  static Future<void> removerItem(int idLocal) async {}
  static Future<void> limparCarrinho(String operadorId) async {}
  static Future<int> contarItens(String operadorId) async => 0;
  static Future<bool> finalizarCompra(String operadorId) async => false;
}
