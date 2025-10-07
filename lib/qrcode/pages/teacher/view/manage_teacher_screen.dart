import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../teacher/models/teacher_model.dart';
import '../controller/role_controller.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final RoleController _controller = RoleController();
  final _db = FirebaseFirestore.instance;
  String? currentRole;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();
  }

  Future<void> _loadCurrentUserRole() async {
    final role = await _controller.getCurrentUserRole();
    setState(() {
      currentRole = role;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }


    if (currentRole != 'teacher') {
    return Scaffold(
    appBar: AppBar(title: const Text('Gerenciar Teachers')),
    body: const Center(child: Text('Acesso negado. Apenas teachers podem gerenciar roles.')),
    );
    }

    return Scaffold(
    appBar: AppBar(
    title: const Text('Gerenciar Usuários'),
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    ),
    body: StreamBuilder<QuerySnapshot>(
    stream: _db.collection('usuarios').orderBy('email').snapshots(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
    final docs = snapshot.data!.docs;

    return ListView.builder(
    itemCount: docs.length,
    itemBuilder: (context, i) {
    final data = docs[i].data() as Map<String, dynamic>;
    final teacher = TeacherModel.fromMap(data);
    return ListTile(
    title: Text(teacher.nome),
    subtitle: Text(teacher.email),
    trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Text(teacher.role),
    const SizedBox(width: 8),
    ElevatedButton(
    onPressed: () => _controller.toggleRole(context, teacher.uid, teacher.role),
    child: Text(teacher.role == 'teacher' ? 'Demotar' : 'Promover'),
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
