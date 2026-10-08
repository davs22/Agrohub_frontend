import 'package:agrohub_app/entity/lote_entity.dart';
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:flutter/foundation.dart';

class LotFormViewModel extends ChangeNotifier {
  LotFormViewModel({this.id, InventoryRepository? repository})
      : _repository = repository ?? const InventoryRepository();
  final int? id;
  final InventoryRepository _repository;
  List<Map<String, dynamic>> operators = [];
  List<Map<String, dynamic>> fields = [];
  LoteEntity? existing;
  bool loading = true;
  bool saving = false;
  String? error;
  bool _disposed = false;

  Future<void> load() async {
    loading = true;
    error = null;
    _emit();
    try {
      if (!await _repository.canManage()) {
        throw StateError('Acesso restrito à administração.');
      }
      operators = await _repository.load('operadores');
      fields = await _repository.load('talhoes');
      if (id != null) {
        final record = await _repository.lot(id!);
        if (record == null) {
          throw StateError('Lote não encontrado nesta empresa.');
        }
        existing = LoteEntity.fromMap(record);
      }
    } catch (_) {
      error =
          'Não foi possível abrir este lote. Verifique seu acesso e tente novamente.';
    } finally {
      loading = false;
      _emit();
    }
  }

  static double? parsePrice(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'R\$|\s'), '');
    if (cleaned.isEmpty) return 0;
    if (!RegExp(r'^\d+(?:[.,]\d{1,2})?$').hasMatch(cleaned)) return null;
    final parsed = double.tryParse(cleaned.replaceAll(',', '.'));
    return parsed != null && parsed.isFinite && parsed >= 0 ? parsed : null;
  }

  Future<bool> save(
      {required String product,
      required String fieldId,
      required String operatorId,
      required int quantity,
      required double price,
      required String unit,
      required bool active,
      required bool highlighted,
      String? image,
      String? imageName,
      DateTime? expires}) async {
    if (saving) return false;
    saving = true;
    error = null;
    _emit();
    try {
      if (product.trim().isEmpty ||
          unit.trim().isEmpty ||
          quantity < 0 ||
          !price.isFinite ||
          price < 0) {
        throw ArgumentError('Dados inválidos para o lote.');
      }
      final record = LoteEntity(
        idLocal: id,
        loteIdNuvem: existing?.loteIdNuvem,
        instanciaId: existing?.instanciaId,
        codigoRastreio: existing?.codigoRastreio,
        usuarioId: operatorId,
        talhaoId: fieldId,
        operadorId: operatorId,
        produto: product.trim(),
        quantidade: quantity,
        precoUnitario: price,
        dataValidade: expires,
        unidadeMedida: unit.trim(),
        status: active ? 'ATIVO' : 'INATIVO',
        imagemBase64: image,
        imagemNomeArquivo: imageName,
        isPublished: highlighted,
        dataRegistro: existing?.dataRegistro ?? DateTime.now(),
        dataAtualizacao: DateTime.now(),
      );
      await _repository.saveLot(record.toMap(), id: id);
      return true;
    } catch (_) {
      error =
          'Não foi possível salvar. Confira o talhão e o operador e tente novamente.';
      return false;
    } finally {
      saving = false;
      _emit();
    }
  }

  Future<bool> delete() async {
    if (id == null || saving) return false;
    saving = true;
    _emit();
    try {
      await _repository.deleteLot(id!);
      return true;
    } catch (_) {
      error = 'Não foi possível excluir o lote. Tente novamente.';
      return false;
    } finally {
      saving = false;
      _emit();
    }
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
