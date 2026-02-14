import '../models/facility.dart';

class MapService {
  // 모든 시설 데이터를 반환하는 함수
  List<Facility> getAllFacilities() {
    return [
      // 행정/필수 (Admin)
      Facility(
        id: 'global_plaza_building',
        korName: '글로벌플라자',
        engName: 'Global Plaza',
        latitude: 35.88993,
        longitude: 128.61046,
        korDesc: '경북대학교 글로벌플라자 건물입니다.',
        engDesc: 'Global Plaza building on KNU campus.',
        category: 'Admin',
      ),
      Facility(
        id: 'oia_office',
        korName: '국제교류처(OIA)',
        engName: 'Office of International Affairs (OIA)',
        latitude: 35.89012,
        longitude: 128.61069,
        korDesc: '교환학생/유학생 관련 서류 제출 및 상담이 진행되는 곳입니다.',
        engDesc: 'Support for exchange/international students (documents & consultation).',
        category: 'Admin',
      ),
      // 카페 (Cafe)
      // 카페 (Cafe)
      Facility(
        id: 'prompt_cafe',
        korName: '프롬프트',
        engName: 'PROMPT',
        latitude: 35.88977,
        longitude: 128.61058,
        korDesc: '교내 카페입니다.',
        engDesc: 'A cafe on campus.',
        category: 'Cafe',
      ),
      Facility(
        id: 'bighands_cafe',
        korName: '빅핸즈',
        engName: 'BIGHANDS',
        latitude: 35.88983,
        longitude: 128.61037,
        korDesc: '교내 카페입니다.',
        engDesc: 'A cafe on campus.',
        category: 'Cafe',
      ),
      Facility(
        id: 'hollys_cafe',
        korName: '할리스',
        engName: 'HOLLYS',
        latitude: 35.88966,
        longitude: 128.61029,
        korDesc: '교내 카페입니다.',
        engDesc: 'A cafe on campus.',
        category: 'Cafe',
      ),
      Facility(
        id: 'ilcheongdam_cafe',
        korName: '일청담 카페',
        engName: 'Ilcheongdam Cafe',
        latitude: 35.88958,
        longitude: 128.61016,
        korDesc: '교내 카페입니다.',
        engDesc: 'A cafe on campus.',
        category: 'Cafe',
      ),
      Facility(
        id: 'gp_cafe',
        korName: 'GP 카페',
        engName: 'GP Cafe',
        latitude: 35.8902,
        longitude: 128.61063,
        korDesc: '글로벌플라자 인근 카페입니다.',
        engDesc: 'A cafe near Global Plaza.',
        category: 'Cafe',
      ),
      Facility(
        id: 'cheomseong_cafe',
        korName: '첨성관 카페',
        engName: 'Cheomseong Dorm Cafe',
        latitude: 35.88631,
        longitude: 128.61427,
        korDesc: '첨성관 기숙사 내에 있는 카페입니다.',
        engDesc: 'A cafe located inside Cheomseong-gwan dormitory.',
        category: 'Cafe',
      ),
      // 편의점 (Store)
      Facility(
        id: 'gs25_dorm',
        korName: 'GS25 첨성관점',
        engName: 'GS25 Cheomseong-gwan',
        latitude: 35.88652,
        longitude: 128.61458,
        korDesc: '첨성관 기숙사 1층에 있는 편의점입니다.',
        engDesc: 'Convenience store located in Cheomseong-gwan dorm.',
        category: 'Store',
      ),
      Facility(
        id: 'gs25_gp',
        korName: 'GS25 글로벌플라자점',
        engName: 'GS25 Global Plaza',
        latitude: 35.88948,
        longitude: 128.61024,
        korDesc: '글로벌플라자 인근 편의점입니다.',
        engDesc: 'Convenience store near Global Plaza.',
        category: 'Store',
      ),
      // 식당 (Restaurant)
      Facility(
        id: 'welfare_bldg_cafeteria',
        korName: '복지관 식당',
        engName: 'Welfare Bldg Cafeteria',
        latitude: 35.88947,
        longitude: 128.61183,
        korDesc: '복지관에 위치한 학생 식당입니다.',
        engDesc: 'Student cafeteria located in the Welfare Building.',
        category: 'Restaurant',
      ),
      Facility(
        id: 'cheomseong_dorm_cafeteria',
        korName: '첨성관(기숙사) 식당',
        engName: 'Cheomseong Dorm Cafeteria',
        latitude: 35.88618,
        longitude: 128.61418,
        korDesc: '기숙사생들을 위한 식당입니다.',
        engDesc: 'Cafeteria for dormitory residents.',
        category: 'Restaurant',
      ),
      Facility(
        id: 'information_center_cafeteria',
        korName: '정보센터 식당',
        engName: 'Information Center Cafeteria',
        latitude: 35.89182,
        longitude: 128.61147,
        korDesc: '학생들이 많이 이용하는 학식당 중 하나입니다.',
        engDesc: 'One of the most popular student cafeterias.',
        category: 'Restaurant',
      ),
      Facility(
        id: 'engineering_bldg_cafeteria',
        korName: '공대 식당',
        engName: 'Engineering Bldg Cafeteria',
        latitude: 35.88858,
        longitude: 128.61353,
        korDesc: '공과대학 인근 학생 식당입니다.',
        engDesc: 'Student cafeteria near the Engineering Building.',
        category: 'Restaurant',
      ),
      Facility(
        id: 'global_plaza_cafeteria',
        korName: '글로벌플라자 식당',
        engName: 'Global Plaza Cafeteria',
        latitude: 35.88987,
        longitude: 128.61084,
        korDesc: '글로벌플라자 내부에 위치한 식당입니다.',
        engDesc: 'Cafeteria located inside Global Plaza.',
        category: 'Restaurant',
      ),
      Facility(
        id: 'kyungdaria_restaurant',
        korName: '경대리아',
        engName: 'Kyungdaria',
        latitude: 35.89203,
        longitude: 128.61136,
        korDesc: '경북대 도서관 휴게실에 있는 식당입니다.',
        engDesc: 'A restaurant in the KNU library lounge.',
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
