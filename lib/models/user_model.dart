class UserModel {
  final String uid;              // Firebase Auth 고유 ID
  final String email;            // 학교 이메일
  final String displayName;      // 닉네임
  final bool isExchangeStudent;  // 교환학생 여부
  final bool isAdmin;            // 관리자 여부 (추가)
  final String? photoUrl;        // 프로필 이미지

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isExchangeStudent,
    this.isAdmin = false,        // 기본값은 false
    this.photoUrl,
  });

  // Firestore 저장용 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isExchangeStudent': isExchangeStudent,
      'isAdmin': isAdmin,
      'photoUrl': photoUrl,
    };
  }

  // Firestore 데이터로부터 객체 생성
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Anonymous',
      isExchangeStudent: map['isExchangeStudent'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      photoUrl: map['photoUrl'],
    );
  }
}