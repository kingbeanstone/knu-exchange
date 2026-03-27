class Facility {
  final String id;
  final String korName;
  final String engName;
  final double latitude;
  final double longitude;
  final String korDesc;
  final String engDesc;
  final String category;
  final String? imageUrl;
  final String? operatingHours;
  final List<String>? interiorImages;

  Facility({
    required this.id,
    required this.korName,
    required this.engName,
    required this.latitude,
    required this.longitude,
    required this.korDesc,
    required this.engDesc,
    required this.category,
    this.imageUrl,
    this.operatingHours,
    this.interiorImages,
  });
}