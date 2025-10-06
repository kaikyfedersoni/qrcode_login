import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String? scannedData;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() {
        scannedData = barcodes.first.rawValue ?? "Sem dados";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Você marcou presença na aula: $scannedData")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aluno - Escanear QR Code")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          if (scannedData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Última leitura: $scannedData"),
            ),
        ],
      ),
    );
  }
}
