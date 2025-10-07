import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class TeacherController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> generateQRCode(BuildContext context, String title, Function(String) onSuccess) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não autenticado.")),
      );
      return;
    }


    final qrId = const Uuid().v4();
    final qrInfo = {
    'id': qrId,
    'title': title.isEmpty ? "Chamada" : title.trim(),
    'creatorUid': user.uid,
    'creatorEmail': user.email,
    'timestamp': FieldValue.serverTimestamp(),
    };

    try {
    await _firestore.collection('qrcodes').doc(qrId).set(qrInfo);
    onSuccess(qrId);
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("QR Code criado e salvo com sucesso!")),
    );
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Erro ao salvar QR Code: $e")),
    );
    }


  }
}
