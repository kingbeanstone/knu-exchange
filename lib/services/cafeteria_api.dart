import '../models/cafeteria_menu.dart';

class CafeteriaApi {
  // 실제 경북대 홈페이지 크롤링 로직이 들어갈 자리입니다.
  // 현재는 가공의 데이터를 반환하는 예시입니다.
  Future<CafeteriaMenu> getMenu(String type) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 흉내
    return CafeteriaMenu(
      restaurantName: type,
      date: '2026-02-10',
      lunch: ['돈까스', '미역국', '김치', '단무지'],
      dinner: ['제육덮밥', '콩나물국', '깍두기'],
    );
  }
}