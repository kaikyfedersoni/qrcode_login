import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa um registro de leitura (coleção 'scans')
class ScanModel {
  final String id;
  final String qrId;
  final String readerName;
  final String readerUid;
  final DateTime timestamp;

  ScanModel({
    required this.id,
    required this.qrId,
    required this.readerName,
    required this.readerUid,
    required this.timestamp,
  });

  factory ScanModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScanModel(
      id: doc.id,
      qrId: data['qrId'] ?? '',
      readerName: data['readerName'] ?? 'Sem nome',
      readerUid: data['readerUid'] ?? 'Sem UID',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qrId': qrId,
      'readerName': readerName,
      'readerUid': readerUid,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
