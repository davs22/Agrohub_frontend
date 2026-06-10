class UserEntity {
  final int? idLocal;
  final String nome;
  final String documento;
  final String? email;
  final String? telefone;
  final String? senha;
  final String status;
  final String role;
  final String? tableName;
  final String? cep;
  final String? rua;
  final double? hectares;
  final String? latitude;
  final String? longitude;
  final DateTime? dataRegistro;
  final DateTime? dataAtualizacao;

  const UserEntity({
    this.idLocal,
    required this.nome,
    required this.documento,
    this.email,
    this.telefone,
    this.senha,
    required this.status,
    required this.role,
    this.tableName,
    this.cep,
    this.rua,
    this.hectares,
    this.latitude,
    this.longitude,
    this.dataRegistro,
    this.dataAtualizacao,
  });

  factory UserEntity.fromMap(Map<String, dynamic> json) {
    return UserEntity(
      idLocal: json['id_local'] as int?,
      nome: json['nome']?.toString() ?? json['nome_completo']?.toString() ?? '',
      documento: json['documento']?.toString() ?? json['cpf']?.toString() ?? '',
      email: json['email']?.toString(),
      telefone: json['telefone']?.toString(),
      senha: json['senha']?.toString() ?? json['senha_adm']?.toString(),
      status: json['status']?.toString() ?? 'ATIVO',
      role: json['role']?.toString() ?? 'USUARIO',
      tableName: json['table_name']?.toString(),
      cep: json['cep']?.toString(),
      rua: json['rua']?.toString(),
      hectares: _toDouble(json['hectares'] ?? json['hectares_totais']),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      dataRegistro: _toDateTime(json['data_registro']),
      dataAtualizacao: _toDateTime(json['data_atualizacao']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'documento': documento,
      'email': email,
      'telefone': telefone,
      'senha': senha,
      'status': status,
      'role': role,
      'table_name': tableName,
      'cep': cep,
      'rua': rua,
      'hectares': hectares,
      'latitude': latitude,
      'longitude': longitude,
      'data_registro': dataRegistro?.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
    };
  }

  UserEntity copyWith({
    int? idLocal,
    String? nome,
    String? documento,
    String? email,
    String? telefone,
    String? senha,
    String? status,
    String? role,
    String? tableName,
    String? cep,
    String? rua,
    double? hectares,
    String? latitude,
    String? longitude,
    DateTime? dataRegistro,
    DateTime? dataAtualizacao,
  }) {
    return UserEntity(
      idLocal: idLocal ?? this.idLocal,
      nome: nome ?? this.nome,
      documento: documento ?? this.documento,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      senha: senha ?? this.senha,
      status: status ?? this.status,
      role: role ?? this.role,
      tableName: tableName ?? this.tableName,
      cep: cep ?? this.cep,
      rua: rua ?? this.rua,
      hectares: hectares ?? this.hectares,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _toDateTime(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }
}
