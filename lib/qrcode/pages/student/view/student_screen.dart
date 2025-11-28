import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/student_controller.dart';
import 'widget/qr_scanner_widget.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final StudentController _controller = StudentController();
  bool hasRegistered = false;
  String? scannedData;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (hasRegistered) return;

    final barcode = capture.barcodes.first;
    final data = barcode.rawValue;

    if (data == null || data.isEmpty) return;

    final aulaTitulo = await _controller.registerPresence(context, data);

    if (aulaTitulo != null) {
      setState(() {
        hasRegistered = true;
        scannedData = aulaTitulo;
      });
    }

    // 🔥 EVITA NOVAS LEITURAS ATÉ O USUÁRIO SAIR DA TELA
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aluno - Escanear QR Code")),
      body: Column(
        children: [
          Expanded(
            child: QrScannerWidget(
              onDetect: _onDetect,
            ),
          ),

          if (scannedData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "✅ Presença confirmada em: $scannedData",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

