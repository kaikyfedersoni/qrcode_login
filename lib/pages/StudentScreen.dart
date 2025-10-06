import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String? scannedData;
  bool hasRegistered = false;

  Future<void> _registerPresence(String qrId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário não autenticado.")),
        );
        return;
      }

      // 1️⃣ Busca o QR Code no Firestore (coleção 'qrcodes')
      final qrDoc = await FirebaseFirestore.instance
          .collection('qrcodes')
          .doc(qrId)
          .get();

      if (!qrDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR Code inválido ou expirado.")),
        );
        return;
      }

      final qrData = qrDoc.data()!;
      final aulaTitulo = qrData['title'] ?? 'Aula sem título';

      // 2️⃣ Registra a presença (coleção 'scans')
      await FirebaseFirestore.instance.collection('scans').add({
        'qrId': qrId,
        'readerName': user.displayName ?? user.email,
        'readerUid': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3️⃣ Mostra mensagem de sucesso personalizada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Presença registrada com sucesso na aula: $aulaTitulo'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        hasRegistered = true;
        scannedData = aulaTitulo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar presença: $e")),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !hasRegistered) {
      final data = barcodes.first.rawValue;
      if (data != null && data.isNotEmpty) {
        _registerPresence(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aluno - Escanear QR Code")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(onDetect: _onDetect),
          ),
          if (scannedData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Presença confirmada em: $scannedData",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
