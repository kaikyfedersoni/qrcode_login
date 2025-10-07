import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa um QR criado (coleção 'qrcodes')
class QrModel {
  final String id;
  final String title;
  final String creatorUid;
  final DateTime timestamp;

  QrModel({
    required this.id,
    required this.title,
    required this.creatorUid,
    required this.timestamp,
  });

  factory QrModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QrModel(
      id: doc.id,
      title: data['title'] ?? 'Sem título',
      creatorUid: data['creatorUid'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'creatorUid': creatorUid,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
