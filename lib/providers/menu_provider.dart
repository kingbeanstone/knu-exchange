import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../services/dorm_crawler_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _service = MenuService();
  final DormCrawlerService _dormService = DormCrawlerService();

  List<MenuItem> _allMenus = [];
  List<MenuItem> _dormMenus = [];
  bool _isLoading = false;

  // 일반 식당 메뉴와 크롤링된 기숙사 메뉴를 합쳐서 제공
  List<MenuItem> get allMenus => [..._allMenus, ..._dormMenus];
  bool get isLoading => _isLoading;

  /// 외부 API(Firestore/CSV)에서 일반 식당 메뉴를 새로고침합니다.
  Future<void> refreshMenu() async {
    // 현재 일반 메뉴 로직 비활성 (주석 처리 유지)
    /*
    _isLoading = true;
    notifyListeners();
    try {
      _allMenus = await _service.fetchRemoteMenu();
    } catch (e) {
      debugPrint("일반 메뉴 로드 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    */
  }

  /// 기숙사 식당이 선택된 경우 실시간으로 웹사이트에서 메뉴를 크롤링합니다.
  Future<void> fetchDormMenuIfNeeded(String facilityId, DateTime date) async {
    // 기숙사 식당이 아닌 경우 실행하지 않음
    if (facilityId != 'cheomseong_dorm_cafeteria') return;

    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // 이미 해당 날짜의 데이터가 메모리에 있는지 확인 (캐싱)
    bool exists = _dormMenus.any((m) => m.facility == facilityId && m.date == dateStr);
    if (exists) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 해당 월의 전체 식단 데이터를 크롤링하여 저장합니다.
      final newDormMenus = await _dormService.fetchDormMenu(
        year: date.year,
        month: date.month,
        dormitoryId: facilityId,
        getMode: 3, // 첨성관 식당 코드
      );

      // 크롤링된 데이터를 정제하고 중복을 제거하여 병합합니다.
      for (var item in newDormMenus) {
        // [핵심] 현재 처리중인 끼니(item.meal)에 맞는 텍스트만 뭉치에서 추출합니다.
        final cleanedMenuText = _cleanMenuContent(item.menu, item.meal);

        // 정제 후 내용이 비어있으면 추가하지 않습니다.
        if (cleanedMenuText.trim().isEmpty) continue;

        final cleanedItem = MenuItem(
          facility: item.facility,
          date: item.date,
          meal: item.meal,
          menu: cleanedMenuText,
        );

        // 중복 확인 (날짜, 식당, 끼니 기준)
        bool isDuplicate = _dormMenus.any((existing) =>
        existing.facility == cleanedItem.facility &&
            existing.date == cleanedItem.date &&
            existing.meal == cleanedItem.meal);

        if (!isDuplicate) {
          _dormMenus.add(cleanedItem);
        }
      }
    } catch (e) {
      debugPrint("기숙사 크롤링 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [수정] 메뉴 텍스트 뭉치에서 현재 끼니(meal)에 해당하는 영역만 매우 엄격하게 추출합니다.
  String _cleanMenuContent(String content, String meal) {
    final Map<String, String> headerMap = {
      'breakfast': '아침메뉴',
      'lunch': '점심메뉴',
      'dinner': '저녁메뉴',
    };

    final String targetHeader = headerMap[meal]!;

    // 1. 텍스트에 아침/점심/저녁 중 하나라도 헤더가 들어있는 '뭉치(Popup)' 데이터인지 확인
    bool isBundled = headerMap.values.any((h) => content.contains(h));

    String extracted = "";

    if (isBundled) {
      // 뭉치인 경우: 현재 요청된 끼니의 헤더 위치를 찾습니다.
      int start = content.indexOf(targetHeader);

      if (start != -1) {
        // 헤더 바로 다음부터가 실제 메뉴 데이터 시작점입니다.
        int dataStart = start + targetHeader.length;

        // 끝지점 탐색: 다른 끼니의 헤더가 나오거나 CLOSE, X 등의 종료 문구가 나오면 멈춥니다.
        List<String> terminators = [...headerMap.values, 'CLOSE', 'close', 'X', '식단표'];
        int end = content.length;

        for (var term in terminators) {
          // 자기 자신의 헤더는 제외하고 다음 구분자를 찾습니다.
          if (term == targetHeader) continue;

          int termIdx = content.indexOf(term, dataStart);
          if (termIdx != -1 && termIdx < end) {
            end = termIdx;
          }
        }
        extracted = content.substring(dataStart, end);
      } else {
        // 뭉치 텍스트인데 정작 필요한 끼니(예: 저녁) 헤더가 없다면 해당 데이터는 없는 것입니다.
        // 이 처리가 없으면 '저녁' 칸에 뭉치 전체(아침부터 시작하는)가 들어가는 문제가 발생합니다.
        return "";
      }
    } else {
      // 헤더가 전혀 없는 일반 텍스트 데이터인 경우 (이미 분리된 상태)
      extracted = content;
    }

    // 2. 추출된 섹션에서 불필요한 시스템 문구 및 기호 최종 제거 (Sanitize)
    final List<String> blackList = [
      '아침메뉴', '점심메뉴', '저녁메뉴',
      '식단표', 'CLOSE', '식단이 없습니다',
      '.', '&nbsp;', 'close', 'X', ':', '-', '01일', '02일' // 날짜 파편 제거
    ];

    return extracted
        .split(RegExp(r'[,|\n]')) // 쉼표나 줄바꿈으로 나누기
        .map((e) => e.trim())
        .where((e) {
      if (e.isEmpty) return false;
      // 블랙리스트에 포함되거나 연/월/일이 포함된 텍스트는 제외
      bool isSystemText = blackList.any((black) => e.contains(black));
      bool isDateText = e.contains('년') && e.contains('월') && e.contains('일');
      return !isSystemText && !isDateText;
    })
        .join(', ');
  }

  /// 특정 장소와 날짜에 해당하는 메뉴 목록을 필터링하여 반환합니다.
  List<MenuItem> getFilteredMenu(String facilityId, String date) {
    final filtered = allMenus.where((m) => m.facility == facilityId && m.date == date).toList();

    // 동일한 끼니가 중복 표시되는 것을 방지하기 위해 Map 사용
    final Map<String, MenuItem> uniqueMeals = {};
    for (var m in filtered) {
      uniqueMeals[m.meal] = m;
    }

    // 끼니 순서 정렬 (breakfast -> lunch -> dinner)
    final List<String> order = ['breakfast', 'lunch', 'dinner'];
    final result = uniqueMeals.values.toList();
    result.sort((a, b) => order.indexOf(a.meal).compareTo(order.indexOf(b.meal)));

    return result;
  }
}