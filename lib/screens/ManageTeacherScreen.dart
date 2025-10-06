
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});
  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final _db = FirebaseFirestore.instance;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String currentRole = 'aluno';
  bool loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();
  }

  Future<void> _loadCurrentUserRole() async {
    final doc = await _db.collection('usuarios').doc(currentUserId).get();
    setState(() {
      currentRole = doc.data()?['role'] ?? 'aluno';
      loadingRole = false;
    });
  }

  Future<void> _toggleRole(String uid, String role) async {
    // Proteção extra no cliente (a regra no servidor também é necessária)
    if (currentRole != 'teacher') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apenas teachers podem alterar roles.')));
      return;
    }
    if (uid == currentUserId && role == 'teacher') {
      // não há problema em promover a si mesmo; apenas um exemplo de prevenção se quiser
    }
    final newRole = role == 'teacher' ? 'aluno' : 'teacher';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar alteração'),
        content: Text('Deseja alterar role para "$newRole" para este usuário?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirm != true) return;

    await _db.collection('usuarios').doc(uid).update({'role': newRole});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role alterada para $newRole')));
  }

  @override
  Widget build(BuildContext context) {
    if (loadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Se o usuário não for teacher, negar acesso na UI
    if (currentRole != 'teacher') {
      return Scaffold(
        appBar: AppBar(title: const Text('Gerenciar Teachers')),
        body: const Center(child: Text('Acesso negado. Apenas teachers podem gerenciar roles.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('usuarios').orderBy('email').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final uid = d['uid'] as String;
              final name = d['nome'] ?? d['email'] ?? 'Sem nome';
              final role = d['role'] ?? 'aluno';

              return ListTile(
                title: Text(name),
                subtitle: Text(d['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(role),
                    const SizedBox(width: 8),
                    // botão para alternar role
                    ElevatedButton(
                      onPressed: () => _toggleRole(uid, role),
                      child: Text(role == 'teacher' ? 'Demotar' : 'Promover'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
