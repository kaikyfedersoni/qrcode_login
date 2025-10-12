import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/scan_controller.dart';
import 'scan_detail_screen.dart';
import 'widget/scan_tile.dart';

class ScanListScreen extends StatefulWidget {
  const ScanListScreen({super.key});

  @override
  State<ScanListScreen> createState() => _ScanListScreenState();
}

class _ScanListScreenState extends State<ScanListScreen> {
  final ScanController _controller = ScanController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final user = _controller.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado.")),
      );
    }

    final qrQuery = _controller.getUserQRCodes(user.uid, filterDate: selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Chamadas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => selectedDate = null),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
          stream: qrQuery.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final qrDocs = snapshot.data!.docs;
            if (qrDocs.isEmpty) {
              return const Center(child: Text("Nenhuma chamada encontrada."));
            }

            return ListView.separated(
              separatorBuilder: (_, __) => const Divider(),
              itemCount: qrDocs.length,
              itemBuilder: (context, index) {
                final qr = qrDocs[index];
                final title = qr['title'] ?? 'Sem título';
                final ts = (qr['timestamp'] as Timestamp?)?.toDate();

                return ScanTile(
                  title: title,
                  timestamp: ts,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanDetailScreen(qrId: qr.id, title: title),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
