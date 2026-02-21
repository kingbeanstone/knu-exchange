import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  // Firestore 경로: artifacts -> knu-exchange-app -> users -> {uid} -> favorites -> {facilityId}
  CollectionReference _favoriteRef(String userId) =>
      _db.collection('artifacts').doc(_appId).collection('users').doc(userId).collection('favorites');

  // 특정 사용자의 즐겨찾기 ID 목록을 가져옵니다.
  Future<Set<String>> getFavorites(String userId) async {
    try {
      final snapshot = await _favoriteRef(userId).get();
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      return {};
    }
  }

  // 즐겨찾기 추가 또는 삭제
  Future<void> toggleFavorite(String userId, String facilityId, bool isAdding) async {
    final docRef = _favoriteRef(userId).doc(facilityId);

    if (isAdding) {
      await docRef.set({
        'facilityId': facilityId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }
}