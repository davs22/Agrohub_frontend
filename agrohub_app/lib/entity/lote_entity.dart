class LoteEntity {
  final int? idLocal;
  final String? loteIdNuvem;
  final String? instanciaId;
  final String usuarioId;
  final String talhaoId;
  final String operadorId;
  final String? codigoRastreio;
  final String produto;
  final int quantidade;
  final String unidadeMedida;
  final String status;
  final String? imagemBase64;
  final String? imagemNomeArquivo;
  final bool isPublished;
  final DateTime? dataRegistro;
  final DateTime? dataAtualizacao;
  final int statusSincronizacao;

  const LoteEntity({
    this.idLocal,
    this.loteIdNuvem,
    this.instanciaId,
    required this.usuarioId,
    required this.talhaoId,
    required this.operadorId,
    this.codigoRastreio,
    required this.produto,
    required this.quantidade,
    required this.unidadeMedida,
    required this.status,
    this.imagemBase64,
    this.imagemNomeArquivo,
    this.isPublished = false,
    this.dataRegistro,
    this.dataAtualizacao,
    this.statusSincronizacao = 1,
  });

  factory LoteEntity.fromMap(Map<String, dynamic> json) {
    return LoteEntity(
      idLocal: json['id_local'] as int?,
      loteIdNuvem: json['lote_id_nuvem']?.toString(),
      instanciaId: json['instancia_id']?.toString(),
      usuarioId: json['usuario_id']?.toString() ?? '',
      talhaoId: json['talhao_id']?.toString() ?? '',
      operadorId: json['operador_id']?.toString() ?? '',
      codigoRastreio: json['codigo_rastreio']?.toString(),
      produto: json['produto']?.toString() ?? '',
      quantidade: _toInt(json['quantidade']) ?? 0,
      unidadeMedida: json['unidade_medida']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ATIVO',
      imagemBase64: json['imagem_base64']?.toString() ?? json['imagem_url']?.toString(),
      imagemNomeArquivo: json['imagem_nome_arquivo']?.toString(),
      isPublished: _toInt(json['is_published']) == 1,
      dataRegistro: _toDateTime(json['data_registro']),
      dataAtualizacao: _toDateTime(json['data_atualizacao']),
      statusSincronizacao: _toInt(json['status_sincronizacao']) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lote_id_nuvem': loteIdNuvem,
      'instancia_id': instanciaId,
      'usuario_id': usuarioId,
      'talhao_id': talhaoId,
      'operador_id': operadorId,
      'codigo_rastreio': codigoRastreio,
      'produto': produto,
      'quantidade': quantidade,
      'unidade_medida': unidadeMedida,
      'status': status,
      'imagem_base64': imagemBase64,
      'imagem_nome_arquivo': imagemNomeArquivo,
      'is_published': isPublished ? 1 : 0,
      'data_registro': dataRegistro?.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
      'status_sincronizacao': statusSincronizacao,
    };
  }

  LoteEntity copyWith({
    int? idLocal,
    String? loteIdNuvem,
    String? instanciaId,
    String? usuarioId,
    String? talhaoId,
    String? operadorId,
    String? codigoRastreio,
    String? produto,
    int? quantidade,
    String? unidadeMedida,
    String? status,
    String? imagemBase64,
    String? imagemNomeArquivo,
    bool? isPublished,
    DateTime? dataRegistro,
    DateTime? dataAtualizacao,
    int? statusSincronizacao,
  }) {
    return LoteEntity(
      idLocal: idLocal ?? this.idLocal,
      loteIdNuvem: loteIdNuvem ?? this.loteIdNuvem,
      instanciaId: instanciaId ?? this.instanciaId,
      usuarioId: usuarioId ?? this.usuarioId,
      talhaoId: talhaoId ?? this.talhaoId,
      operadorId: operadorId ?? this.operadorId,
      codigoRastreio: codigoRastreio ?? this.codigoRastreio,
      produto: produto ?? this.produto,
      quantidade: quantidade ?? this.quantidade,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      status: status ?? this.status,
      imagemBase64: imagemBase64 ?? this.imagemBase64,
      imagemNomeArquivo: imagemNomeArquivo ?? this.imagemNomeArquivo,
      isPublished: isPublished ?? this.isPublished,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      statusSincronizacao: statusSincronizacao ?? this.statusSincronizacao,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _toDateTime(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }
}
