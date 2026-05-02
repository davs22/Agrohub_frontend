class TalhaoEntity {
  final String nomeTalhao;
  final String tamanhoHectares;
  final String culturaAtual;
  final String status;
  final String? usuarioId;

  TalhaoEntity({
    required this.nomeTalhao,
    required this.tamanhoHectares,
    required this.culturaAtual,
    required this.status,
    this.usuarioId,
  });

  factory TalhaoEntity.fromJson(Map<String, dynamic> json) {
    return TalhaoEntity(
      nomeTalhao: json['nomeTalhao'] ?? '',
      tamanhoHectares: json['tamanhoHectares'] ?? '',
      culturaAtual: json['culturaAtual'] ?? '',
      status: json['status'] ?? '',
      usuarioId: json['usuarioId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeTalhao': nomeTalhao,
      'tamanhoHectares': tamanhoHectares,
      'culturaAtual': culturaAtual,
      'status': status,
      'usuarioId': usuarioId,
    };
  }

  TalhaoEntity copyWith({
    String? nomeTalhao,
    String? tamanhoHectares,
    String? culturaAtual,
    String? status,
    String? usuarioId,
  }) {
    return TalhaoEntity(
      nomeTalhao: nomeTalhao ?? this.nomeTalhao,
      tamanhoHectares: tamanhoHectares ?? this.tamanhoHectares,
      culturaAtual: culturaAtual ?? this.culturaAtual,
      status: status ?? this.status,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}