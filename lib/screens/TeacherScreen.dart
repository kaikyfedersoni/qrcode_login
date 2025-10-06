import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final TextEditingController titleController = TextEditingController();
  String? qrData;

  void generateQRCode() {
    setState(() {
      qrData = titleController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Professor - Gerar Chamada")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Título da Aula",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
        ),
      ),
    );
  }
}
