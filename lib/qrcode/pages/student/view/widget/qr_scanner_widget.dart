import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerWidget extends StatelessWidget {
  final Function(BarcodeCapture) onDetect;

  const QrScannerWidget({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return MobileScanner(onDetect: onDetect);
  }
}
