class TeacherModel {
  final String uid;
  final String nome;
  final String email;
  final String role;

  TeacherModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.role,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> data) {
    return TeacherModel(
      uid: data['uid'] ?? '',
      nome: data['nome'] ?? data['email'] ?? 'Sem nome',
      email: data['email'] ?? '',
      role: data['role'] ?? 'aluno',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'role': role,
    };
  }
}
