import 'package:flutter/material.dart';
import '../../student/view/scan_list_screen.dart';
import 'widgets/generate_qr_form.dart';

class TeacherScreen extends StatelessWidget {
  const TeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Professor - Gerar Chamada")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Expanded(child: GenerateQRForm()),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text("Ver Minhas Chamadas"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
