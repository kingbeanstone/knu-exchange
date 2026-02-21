import 'package:flutter/material.dart';
import '../services/like_service.dart';

class LikeProvider with ChangeNotifier {
  final LikeService _service = LikeService();

  // 좋아요 토글 호출
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _service.toggleLike(postId, userId);
    } catch (e) {
      debugPrint("Like toggle error: $e");
      rethrow;
    }
  }

  // 좋아요 여부 확인 (단발성)
  Future<bool> getIsLikedOnce(String postId, String userId) async {
    return await _service.checkIsLiked(postId, userId);
  }
}