class Constants {
  static const String appId = "knu_exchange_app";
  // 나중에 네이버 지도 Client ID나 API 엔드포인트를 여기에 넣으세요.
  static const String naverClientId = "8px8q0aopz";
}
/*


lib/

├── main.dart               # 앱 진입점

├── utils/                  # 앱 전체에서 쓰는 설정

│   ├── app_colors.dart     # (추천) 경북대 빨간색 등 색상 관리

│   └── constants.dart      # API 키, URL 등 상수

├── models/                 # 데이터 형틀

│   ├── facility.dart       # 건물 정보 (지도용)

│   └── cafeteria_menu.dart # 식당 메뉴 정보 (식당탭용)
│   └── post.dart
├── providers/

│   ├── favorite_provider.dart       # 건물 정보 (지도용)




├── services/               # 데이터 가져오는 일꾼

│   ├── map_service.dart    # 네이버 지도 API 관련

│   └── cafeteria_api.dart  # 학식 정보 크롤링/API 로직

├── widgets/                # 재사용 부품

│   ├── facility_card.dart  # 건물 정보 카드

│   └── menu_list_item.dart # 식당 메뉴 리스트 아이템

└── screens/                # 실제 화면들

├── main_screen.dart    # (아까 만든) 하단 탭 관리 화면

├── home/               # 홈(지도) 관련 화면 모음

│   └── home_screen.dart

├── cafeteria/          # 식당 관련 화면 모음

│   └── cafeteria_screen.dart

├── community/          # 커뮤니티 관련 화면 모음

│   └── community_screen.dart

├── favorite/           # 즐겨찾기 관련 화면 모음

│   └── favorite_screen.dart

└── settings/           # 설정 관련 화면 모음

└── settings_screen.dart*/
