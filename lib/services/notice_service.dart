import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notice.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 공지사항 실시간 스트림 조회
  Stream<List<Notice>> streamNotices() {
    return _firestore
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList());
  }

  /// [추가] 공지사항 작성 - Cloud Functions 트리거 경로와 일치시킴
  Future<void> addNotice(String title, String content) async {
    try {
      await _firestore.collection('notices').add({
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Add notice error: $e");
      rethrow;
    }
  }

  /// [추가] 공지사항 삭제
  Future<void> deleteNotice(String noticeId) async {
    try {
      await _firestore.collection('notices').doc(noticeId).delete();
    } catch (e) {
      debugPrint("Delete notice error: $e");
      rethrow;
    }
  }
}