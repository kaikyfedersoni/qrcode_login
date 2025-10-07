import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Controller responsável por registrar presença (estudante que escaneia)
class StudentController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tenta registrar a presença pelo qrId.
  /// Retorna o título da aula se sucesso, ou null se falhou.
  Future<String?> registerPresence(BuildContext context, String qrId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showMessage(context, 'Usuário não autenticado.');
        return null;
      }


    final qrDoc = await _firestore.collection('qrcodes').doc(qrId).get();
    if (!qrDoc.exists) {
    _showMessage(context, 'QR Code inválido ou expirado.');
    return null;
    }

    final qrData = qrDoc.data()!;
    final aulaTitulo = qrData['title'] ?? 'Aula sem título';

    await _firestore.collection('scans').add({
    'qrId': qrId,
    'readerName': user.displayName ?? user.email,
    'readerUid': user.uid,
    'timestamp': FieldValue.serverTimestamp(),
    });

    _showMessage(
    context,
    '✅ Presença registrada com sucesso na aula: $aulaTitulo',
    success: true,
    );

    return aulaTitulo;
    } catch (e) {
    _showMessage(context, 'Erro ao registrar presença: $e');
    return null;
    }

  }

  void _showMessage(BuildContext context, String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
