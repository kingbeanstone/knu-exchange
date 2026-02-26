import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Notice>> streamNotices() {
    return _firestore
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList());
  }
}