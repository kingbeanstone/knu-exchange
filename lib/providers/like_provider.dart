import 'package:flutter/material.dart';
import '../services/like_service.dart';

class LikeProvider with ChangeNotifier {
  final LikeService _service = LikeService();

  // 좋아요 토글 호출
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
      // Firestore Stream이 UI를 갱신하므로 별도의 notifyListeners는 필요 없음
    } catch (e) {
      debugPrint("좋아요 토글 중 오류 발생: $e");
      rethrow;
    }
  }

  // 특정 유저의 좋아요 여부 확인 스트림 제공
  Stream<bool> getIsLikedStream(String postId, String userId) {
    return _service.isLikedStream(postId, userId);
  }
}