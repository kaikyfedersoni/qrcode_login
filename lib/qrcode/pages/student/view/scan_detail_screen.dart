import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/scan_controller.dart';


class ScanDetailScreen extends StatelessWidget {
  final String qrId;
  final String title;
  final ScanController _controller = ScanController();

  ScanDetailScreen({super.key, required this.qrId, required this.title});

  @override
  Widget build(BuildContext context) {
    final scansQuery = _controller.getScansByQrId(qrId);

    return Scaffold(
    appBar: AppBar(
    title: Text("Presenças - $title"),
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    ),
    body: StreamBuilder<QuerySnapshot>(
    stream: scansQuery.snapshots(),
    builder: (context, snap) {
    if (!snap.hasData) return const Center(child: CircularProgressIndicator());

    final docs = snap.data!.docs;
    if (docs.isEmpty) return const Center(child: Text("Nenhum aluno escaneou ainda."));

    return ListView.builder(
    itemCount: docs.length,
    itemBuilder: (_, i) {
    final d = docs[i];
    final readerName = d['readerName'] ?? 'Sem nome';
    final readerUid = d['readerUid'] ?? 'Sem UID';
    final data = (d['timestamp'] as Timestamp?)?.toDate();

    final dateText = data != null
    ? "${data.day}/${data.month}/${data.year} às ${data.hour}:${data.minute.toString().padLeft(2, '0')}"
        : "Sem data";

    return ListTile(
    leading: const Icon(Icons.person),
    title: Text(readerName),
    subtitle: Text("UID: $readerUid\n$dateText"),
    );
    },
    );
    },
    ),
    );


  }
}
