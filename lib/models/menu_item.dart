class MenuItem {
  final String facility;
  final String date;
  final String meal;
  final String menu;

  MenuItem({
    required this.facility,
    required this.date,
    required this.meal,
    required this.menu,
  });

  factory MenuItem.fromCsv(List<dynamic> row) {
    // CSV 데이터 파싱 시 발생할 수 있는 공백 및 null 오류 방지
    String safeGet(int index) {
      if (index < 0 || index >= row.length) return '';
      return row[index]?.toString().trim() ?? '';
    }

    return MenuItem(
      facility: safeGet(0),
      date: safeGet(1),
      // meal 데이터는 대소문자 구분 없이 비교하기 위해 소문자로 변환
      meal: safeGet(2).toLowerCase(),
      menu: safeGet(3),
    );
  }
}