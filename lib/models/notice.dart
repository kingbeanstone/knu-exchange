class Notice {
  final String date;    // 공지 날짜
  final String title;   // 공지 제목
  final String content; // 공지 내용

  Notice({
    required this.date,
    required this.title,
    required this.content,
  });

  // 구글 시트 CSV의 한 행(row) 데이터를 객체로 변환
  factory Notice.fromCsv(List<dynamic> row) {
    return Notice(
      date: row.length > 0 ? row[0].toString().trim() : '',
      title: row.length > 1 ? row[1].toString().trim() : '제목 없음',
      content: row.length > 2 ? row[2].toString().trim() : '',
    );
  }
}