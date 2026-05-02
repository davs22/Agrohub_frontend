class LoteEntity {
  final String? lotesId;
  final String? codigoRastreio;
  final String produto;
  final int quantidade;
  final String unidadeMedida;
  final String status;
  final String imagemUrl;
  final DateTime? dataRegistro;
  final DateTime? dataAtualizacao;
  final String? usuarioId;
  final String? talhoesId;

  LoteEntity({
    this.lotesId,
    this.codigoRastreio,
    required this.produto,
    required this.quantidade,
    required this.unidadeMedida,
    required this.status,
    required this.imagemUrl,
    this.dataRegistro,
    this.dataAtualizacao,
    this.usuarioId,
    this.talhoesId,
  });

  factory LoteEntity.fromJson(Map<String, dynamic> json) {
    return LoteEntity(
      lotesId: json['lotesId'],
      codigoRastreio: json['codigoRastreio'],
      produto: json['produto'] ?? '',
      quantidade: json['quantidade'] ?? 0,
      unidadeMedida: json['unidadeMedida'] ?? '',
      status: json['status'] ?? '',
      imagemUrl: json['imagemUrl'] ?? '',
      dataRegistro: json['dataRegistro'] != null 
          ? DateTime.parse(json['dataRegistro']) 
          : null,
      dataAtualizacao: json['dataAtualizacao'] != null 
          ? DateTime.parse(json['dataAtualizacao']) 
          : null,
      usuarioId: json['userEntityId'] ?? json['usuarioId'],
      talhoesId: json['talhoesEntityId'] ?? json['talhoesId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produto': produto,
      'quantidade': quantidade,
      'unidadeMedida': unidadeMedida,
      'status': status,
      'imagemUrl': imagemUrl,
      'usuarioId': usuarioId,
      'talhoesId': talhoesId,
    };
  }

  LoteEntity copyWith({
    String? lotesId,
    String? codigoRastreio,
    String? produto,
    int? quantidade,
    String? unidadeMedida,
    String? status,
    String? imagemUrl,
    DateTime? dataRegistro,
    DateTime? dataAtualizacao,
    String? usuarioId,
    String? talhoesId,
  }) {
    return LoteEntity(
      lotesId: lotesId ?? this.lotesId,
      codigoRastreio: codigoRastreio ?? this.codigoRastreio,
      produto: produto ?? this.produto,
      quantidade: quantidade ?? this.quantidade,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      status: status ?? this.status,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      usuarioId: usuarioId ?? this.usuarioId,
      talhoesId: talhoesId ?? this.talhoesId,
    );
  }
}