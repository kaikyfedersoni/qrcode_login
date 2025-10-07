import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controller/teacher_controller.dart';


class GenerateQRForm extends StatefulWidget {
  const GenerateQRForm({super.key});

  @override
  State<GenerateQRForm> createState() => _GenerateQRFormState();
}

class _GenerateQRFormState extends State<GenerateQRForm> {
  final TextEditingController titleController = TextEditingController();
  final TeacherController _controller = TeacherController();
  String? qrData;

  Future<void> _generateQRCode() async {
    await _controller.generateQRCode(context, titleController.text.trim(), (id) {
      setState(() {
        qrData = id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "Título da Aula"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: _generateQRCode,
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
