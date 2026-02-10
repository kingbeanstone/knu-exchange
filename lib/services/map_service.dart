import '../models/facility.dart';

class MapService {
  List<Facility> getExchangeEssentialPlaces() {
    return [
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
      Facility(
        id: 'dorm_cheomseong',
        korName: '첨성관 기숙사',
        engName: 'Cheomseong-gwan Dormitory',
        latitude: 35.8864,
        longitude: 128.6145,
        korDesc: '외국인 학생들이 주로 거주하는 기숙사입니다.',
        engDesc: 'The main dormitory for international students.',
        category: 'Dormitory',
      ),
      // 추가적인 은행, 보건소, 식당 데이터 입력
    ];
  }
}