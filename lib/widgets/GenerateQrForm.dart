import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GenerateQRForm extends StatefulWidget {
  const GenerateQRForm({super.key});

  @override
  State<GenerateQRForm> createState() => _GenerateQRFormState();
}

class _GenerateQRFormState extends State<GenerateQRForm> {
  final TextEditingController titleController = TextEditingController();
  String? qrData;

  Future<void> generateQRCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não autenticado.")),
      );
      return;
    }

    final qrId = const Uuid().v4();
    final title = titleController.text.trim().isEmpty
        ? "Chamada"
        : titleController.text.trim();

    final qrInfo = {
      'id': qrId,
      'title': title,
      'creatorUid': user.uid,
      'creatorEmail': user.email,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('qrcodes').doc(qrId).set(qrInfo);

      setState(() {
        qrData = qrId;
      });

      debugPrint("✅ QR salvo com ID: $qrId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR Code criado e salvo com sucesso!")),
      );
    } catch (e) {
      debugPrint("❌ Erro ao salvar QR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar QR Code: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: "Título da Aula",
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Mesmo verde do cabeçalho
            foregroundColor: Colors.white,
          ),
          onPressed: generateQRCode,
          child: const Text("Gerar QR Code"),
        ),
        const SizedBox(height: 20),
        if (qrData != null)
          QrImageView(
            data: qrData!,
            size: 200,
            version: QrVersions.auto,
          ),
      ],
    );
  }
}
