class Facility {
  final String id;
  final String korName;     // 한국어 명칭
  final String engName;     // 영어 명칭
  final double latitude;
  final double longitude;
  final String korDesc;     // 한국어 설명
  final String engDesc;     // 영어 설명
  final String category;    // 예: Admin, Dormitory, Restaurant, Bank

  Facility({
    required this.id,
    required this.korName,
    required this.engName,
    required this.latitude,
    required this.longitude,
    required this.korDesc,
    required this.engDesc,
    required this.category,
  });
}