import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'location_service.dart';

class StudentController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerPresence(BuildContext context, String qrId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showMessage(context, 'Usuário não autenticado.');
        return null;
      }

      // 🔒 Verificação de localização
      final insideArea = await LocationService.isInsideAllowedArea();
      if (!insideArea) {
        _showMessage(
          context,
          'Você precisa estar dentro da faculdade para registrar presença.',
        );
        return null;
      }

      // 🔍 Verifica se o QR existe
      final qrDoc = await _firestore.collection('qrcodes').doc(qrId).get();
      if (!qrDoc.exists) {
        _showMessage(context, 'QR Code inválido ou expirado.');
        return null;
      }

      final qrData = qrDoc.data()!;
      final aulaTitulo = qrData['title'] ?? 'Aula sem título';

      // 🧠 NOVO: Verifica se o aluno já registrou presença neste QR
      final existingScan = await _firestore
          .collection('scans')
          .where('qrId', isEqualTo: qrId)
          .where('readerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingScan.docs.isNotEmpty) {
        _showMessage(context, '⚠️ Você já registrou presença nesta aula.');
        return null;
      }

      // ✅ Registra a presença se ainda não houver
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
