import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanListScreen extends StatelessWidget {
  final String qrId;
  const ScanListScreen({super.key, required this.qrId});

  @override
  Widget build(BuildContext context) {
    final scansQuery = FirebaseFirestore.instance
        .collection('scans')
        .where('qrId', isEqualTo: qrId)
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Leituras')),
      body: StreamBuilder<QuerySnapshot>(
        stream: scansQuery.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhuma leitura ainda.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final name = d['readerName'] ?? d['readerUid'];
              final ts = (d['timestamp'] as Timestamp).toDate();
              return ListTile(
                title: Text(name),
                subtitle: Text(ts.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
