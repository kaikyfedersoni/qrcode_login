import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerWidget extends StatelessWidget {
  final Function(BarcodeCapture) onDetect;
  final MobileScannerController controller = MobileScannerController();

  QrScannerWidget({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: (capture) async {
        controller.stop(); // 🔥 PAUSA o scanner imediatamente
        await onDetect(capture);
      },
    );
  }
}
