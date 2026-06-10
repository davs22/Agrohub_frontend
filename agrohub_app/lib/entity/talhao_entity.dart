class TalhaoEntity {
  final int? idLocal;
  final String? talhaoIdNuvem;
  final String usuarioId;
  final String nome;
  final double tamanhoHectares;
  final String culturaAtual;
  final String status;
  final DateTime? dataRegistro;
  final DateTime? dataAtualizacao;
  final int statusSincronizacao;

  const TalhaoEntity({
    this.idLocal,
    this.talhaoIdNuvem,
    required this.usuarioId,
    required this.nome,
    required this.tamanhoHectares,
    required this.culturaAtual,
    required this.status,
    this.dataRegistro,
    this.dataAtualizacao,
    this.statusSincronizacao = 1,
  });

  factory TalhaoEntity.fromMap(Map<String, dynamic> json) {
    return TalhaoEntity(
      idLocal: json['id_local'] as int?,
      talhaoIdNuvem: json['talhao_id_nuvem']?.toString(),
      usuarioId: json['usuario_id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      tamanhoHectares: _toDouble(json['tamanho_hectares']),
      culturaAtual: json['cultura_atual']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ATIVO',
      dataRegistro: _toDateTime(json['data_registro']),
      dataAtualizacao: _toDateTime(json['data_atualizacao']),
      statusSincronizacao: _toInt(json['status_sincronizacao']) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'talhao_id_nuvem': talhaoIdNuvem,
      'usuario_id': usuarioId,
      'nome': nome,
      'tamanho_hectares': tamanhoHectares,
      'cultura_atual': culturaAtual,
      'status': status,
      'data_registro': dataRegistro?.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
      'status_sincronizacao': statusSincronizacao,
    };
  }

  TalhaoEntity copyWith({
    int? idLocal,
    String? talhaoIdNuvem,
    String? usuarioId,
    String? nome,
    double? tamanhoHectares,
    String? culturaAtual,
    String? status,
    DateTime? dataRegistro,
    DateTime? dataAtualizacao,
    int? statusSincronizacao,
  }) {
    return TalhaoEntity(
      idLocal: idLocal ?? this.idLocal,
      talhaoIdNuvem: talhaoIdNuvem ?? this.talhaoIdNuvem,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      tamanhoHectares: tamanhoHectares ?? this.tamanhoHectares,
      culturaAtual: culturaAtual ?? this.culturaAtual,
      status: status ?? this.status,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      statusSincronizacao: statusSincronizacao ?? this.statusSincronizacao,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
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
