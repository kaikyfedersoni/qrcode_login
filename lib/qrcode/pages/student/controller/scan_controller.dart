import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Controller para listar QRs do professor e presenças por qrId
class ScanController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Query getUserQRCodes(String userUid, {DateTime? filterDate}) {
    Query query = _firestore
        .collection('qrcodes')
        .where('creatorUid', isEqualTo: userUid)
        .orderBy('timestamp', descending: true);


    if (filterDate != null) {
    final start = DateTime(filterDate.year, filterDate.month, filterDate.day);
    final end = start.add(const Duration(days: 1));
    query = query
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end));
    }

    return query;


  }

  Query getScansByQrId(String qrId) {
    return _firestore
        .collection('scans')
        .where('qrId', isEqualTo: qrId)
        .orderBy('timestamp', descending: false);
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;
}
