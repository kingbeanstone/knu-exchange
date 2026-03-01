import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';

class MapService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 실시간 데이터 스트림
  Stream<List<Facility>> getFacilitiesStream() {
    return _db.collection('facilities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // 여기서 데이터를 하나씩 매핑하여 Facility 객체를 만듭니다.
        return Facility(
          id: doc.id,
          korName: data['korName'] ?? '',
          engName: data['engName'] ?? '',
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          korDesc: data['korDesc'] ?? '',
          engDesc: data['engDesc'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'],
          operatingHours: data['operatingHours'],
          interiorImages: List<String>.from(data['interiorImages'] ?? []),
        );
      }).toList();
    });
  }
}