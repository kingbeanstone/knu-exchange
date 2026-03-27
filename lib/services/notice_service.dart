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

  /// [수정] 공지사항 작성 - imageUrls 리스트 저장 지원
  Future<void> addNotice(String title, String content, {List<String>? imageUrls}) async {
    try {
      await _firestore.collection('notices').add({
        'title': title,
        'content': content,
        'imageUrls': imageUrls ?? [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Notice add error: $e");
      rethrow;
    }
  }

  /// [수정] 공지사항 업데이트 - imageUrls 리스트 저장 지원
  Future<void> updateNotice(String noticeId, String title, String content, {List<String>? imageUrls}) async {
    try {
      await _firestore.collection('notices').doc(noticeId).update({
        'title': title,
        'content': content,
        'imageUrls': imageUrls ?? [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Notice update error: $e");
      rethrow;
    }
  }

  /// 공지사항 삭제
  Future<void> deleteNotice(String noticeId) async {
    try {
      await _firestore.collection('notices').doc(noticeId).delete();
    } catch (e) {
      debugPrint("Notice delete error: $e");
      rethrow;
    }
  }
}