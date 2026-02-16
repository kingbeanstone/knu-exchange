class MenuItem {
  final String facility; // 식당 ID (예: welfare_bldg_cafeteria)
  final String date;     // 날짜 (예: 2026-02-09)
  final String meal;     // 끼니 (breakfast, lunch, dinner)
  final String menu;     // 메뉴 내용

  MenuItem({
    required this.facility,
    required this.date,
    required this.meal,
    required this.menu,
  });

  // CSV 행 데이터를 객체로 변환
  factory MenuItem.fromCsv(List<dynamic> row) {
    return MenuItem(
      facility: row.length > 0 ? row[0].toString().trim() : '',
      date: row.length > 1 ? row[1].toString().trim() : '',
      meal: row.length > 2 ? row[2].toString().trim().toLowerCase() : '',
      menu: row.length > 3 ? row[3].toString().trim() : '',
    );
  }
}