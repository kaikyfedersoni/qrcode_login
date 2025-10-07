class UserModel {
  final String id;
  final String nome;
  final String email;
  final String role;
  final String deviceId;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'role': role,
      'deviceId': deviceId,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'aluno',
      deviceId: data['deviceId'] ?? '',
    );
  }
}
