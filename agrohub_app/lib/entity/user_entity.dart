enum UserRole { ADMIN, INSTANCIA, COMERCIO, OPERADOR, USUARIO }

class UserEntity {
  final String nome;
  final String email;
  final String telefone;
  final String endereco;
  final String cpfOuCnpj;
  final String senha;
  final UserRole role;
  final String status;
  final String? organizacaoId;

  UserEntity({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.endereco,
    required this.cpfOuCnpj,
    required this.senha,
    required this.role,
    required this.status,
    this.organizacaoId,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'] ?? '',
      cpfOuCnpj: json['cpfOuCnpj'] ?? '',
      senha: json['senha'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      organizacaoId: json['organizacaoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'cpfOuCnpj': cpfOuCnpj,
      'senha': senha,
      'role': role,
      'status': status,
      'organizacaoId': organizacaoId,
    };
  }

  UserEntity copyWith({
    String? nome,
    String? email,
    String? telefone,
    String? endereco,
    String? cpfOuCnpj,
    String? senha,
    UserRole? role,
    String? status,
    String? organizacaoId,
  }) {
    return UserEntity(
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      cpfOuCnpj: cpfOuCnpj ?? this.cpfOuCnpj,
      senha: senha ?? this.senha,
      role: role ?? this.role,
      status: status ?? this.status,
      organizacaoId: organizacaoId ?? this.organizacaoId,
    );
  }
}