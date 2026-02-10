import '../models/facility.dart';

class MapService {
  // 모든 시설 데이터를 반환하는 함수
  List<Facility> getAllFacilities() {
    return [
      // 행정/필수 (Admin)
      Facility(
        id: 'global_plaza',
        korName: '글로벌플라자 (국제교류처)',
        engName: 'Global Plaza (Office of International Affairs)',
        latitude: 35.8899,
        longitude: 128.6105,
        korDesc: '교환학생 관련 서류 제출 및 상담이 진행되는 곳입니다.',
        engDesc: 'Office for international exchange programs and documents.',
        category: 'Admin',
      ),
      // 카페 (Cafe)
      Facility(
        id: 'cafe_gp',
        korName: 'GP 카페',
        engName: 'GP Cafe',
        latitude: 35.8902,
        longitude: 128.6106,
        korDesc: '글로벌플라자 1층에 위치한 카페입니다.',
        engDesc: 'A cafe located on the 1st floor of Global Plaza.',
        category: 'Cafe',
      ),
      Facility(
        id: 'cafe_it4',
        korName: 'IT-4 카페',
        engName: 'IT-4 Cafe',
        latitude: 35.8889,
        longitude: 128.6100,
        korDesc: 'IT융복합관 내부에 있는 카페입니다.',
        engDesc: 'Cafe inside the IT Convergence Building.',
        category: 'Cafe',
      ),
      // 편의점 (Store)
      Facility(
        id: 'gs25_dorm',
        korName: 'GS25 첨성관점',
        engName: 'GS25 Cheomseong-gwan',
        latitude: 35.8865,
        longitude: 128.6146,
        korDesc: '첨성관 기숙사 1층에 있는 편의점입니다.',
        engDesc: 'Convenience store located in Cheomseong-gwan dorm.',
        category: 'Store',
      ),
      Facility(
        id: 'gs25_gp',
        korName: 'GS25 글로벌플라자점',
        engName: 'GS25 Global Plaza',
        latitude: 35.8895,
        longitude: 128.6102,
        korDesc: '글로벌플라자 인근 편의점입니다.',
        engDesc: 'Convenience store near Global Plaza.',
        category: 'Store',
      ),
      // 식당 (Restaurant)
      Facility(
        id: 'rest_student',
        korName: '정보센터식당',
        engName: 'Information Center Cafeteria',
        latitude: 35.8918,
        longitude: 128.6115,
        korDesc: '학생들이 가장 많이 이용하는 학식당 중 하나입니다.',
        engDesc: 'One of the most popular student cafeterias.',
        category: 'Restaurant',
      ),
      Facility(
        id: 'rest_dorm',
        korName: '첨성관 식당',
        engName: 'Cheomseong-gwan Cafeteria',
        latitude: 35.8862,
        longitude: 128.6142,
        korDesc: '기숙사생들을 위한 식당입니다.',
        engDesc: 'Cafeteria for dormitory residents.',
        category: 'Restaurant',
      ),
    ];
  }

  // 특정 카테고리의 시설만 필터링하여 반환
  List<Facility> getFacilitiesByCategory(String category) {
    if (category == 'All') return getAllFacilities();
    return getAllFacilities().where((f) => f.category == category).toList();
  }
}