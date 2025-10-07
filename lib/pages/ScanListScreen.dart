import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanListScreen extends StatefulWidget {
  const ScanListScreen({super.key});

  @override
  State<ScanListScreen> createState() => _ScanListScreenState();
}

class _ScanListScreenState extends State<ScanListScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado.")),
      );
    }

    // 🔹 Consulta dos QR Codes criados pelo professor
    Query qrQuery = FirebaseFirestore.instance
        .collection('qrcodes')
        .where('creatorUid', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true);

    // 🔹 Filtro de data
    if (selectedDate != null) {
      final start = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      final end = start.add(const Duration(days: 1));
      qrQuery = qrQuery
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThan: Timestamp.fromDate(end));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Chamadas"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  selectedDate = null;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: qrQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final qrDocs = snapshot.data!.docs;

          if (qrDocs.isEmpty) {
            return const Center(child: Text("Nenhuma chamada encontrada."));
          }

          return ListView.builder(
            itemCount: qrDocs.length,
            itemBuilder: (context, index) {
              final qr = qrDocs[index];
              final title = qr['title'] ?? 'Sem título';
              final ts = (qr['timestamp'] as Timestamp?)?.toDate();

              return ListTile(
                title: Text(title),
                subtitle: Text(ts != null
                    ? "${ts.day}/${ts.month}/${ts.year} - ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}"
                    : "Sem data"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanDetailScreen(qrId: qr.id, title: title),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ScanDetailScreen extends StatelessWidget {
  final String qrId;
  final String title;

  const ScanDetailScreen({
    super.key,
    required this.qrId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final scansQuery = FirebaseFirestore.instance
        .collection('scans')
        .where('qrId', isEqualTo: qrId)
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Presenças - $title"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: scansQuery.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Nenhum aluno escaneou ainda."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final readerName = d['readerName'] ?? 'Sem nome';
              final readerUid = d['readerUid'] ?? 'Sem UID';
              final data = (d['timestamp'] as Timestamp).toDate();

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(readerName),
                subtitle: Text(
                  "UID: $readerUid\n${data.day}/${data.month}/${data.year} às ${data.hour}:${data.minute.toString().padLeft(2, '0')}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
