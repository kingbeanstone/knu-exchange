class UserModel {
  final String uid;              // Firebase Auth에서 생성된 고유 ID
  final String email;            // 학교 이메일 (@knu.ac.kr)
  final String displayName;      // 앱 내에서 사용할 닉네임
  final bool isExchangeStudent;  // 교환학생 여부 (필터링이나 배지용)
  final String? photoUrl;        // 프로필 이미지 URL (선택 사항)

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isExchangeStudent,
    this.photoUrl,
  });

  // 1. 객체를 Map으로 변환 (Firestore에 저장할 때 사용)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isExchangeStudent': isExchangeStudent,
      'photoUrl': photoUrl,
    };
  }

  // 2. Map을 객체로 변환 (Firestore에서 데이터를 가져올 때 사용)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Anonymous',
      isExchangeStudent: map['isExchangeStudent'] ?? false,
      photoUrl: map['photoUrl'],
    );
  }
}