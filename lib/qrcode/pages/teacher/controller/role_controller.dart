import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'aluno';
    final doc = await _db.collection('usuarios').doc(user.uid).get();
    final data = doc.data();
    final role = data != null && data['role'] is String ? data['role'] as String : 'aluno';
    return role;
  }

  Future<void> toggleRole(BuildContext context, String uid, String role) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showSnack(context, 'Usuário não autenticado.', false);
      return;
    }


    final currentRole = await getCurrentUserRole();

    if (currentRole != 'teacher') {
    _showSnack(context, 'Apenas teachers podem alterar roles.', false);
    return;
    }

    final newRole = role == 'teacher' ? 'aluno' : 'teacher';
    final confirm = await _confirmDialog(context, newRole);
    if (confirm != true) return;

    try {
    await _db.collection('usuarios').doc(uid).update({'role': newRole});
    _showSnack(context, 'Role alterada para $newRole', true);
    } catch (e) {
    _showSnack(context, 'Erro ao alterar role: $e', false);
    }


  }

  Future<bool?> _confirmDialog(BuildContext context, String newRole) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar alteração'),
        content: Text('Deseja alterar o papel para "$newRole"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
