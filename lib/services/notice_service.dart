import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/notice.dart';

class NoticeService {
  // 구글 시트 [파일 > 공유 > 웹에 게시 > CSV]로 생성된 URL을 입력하세요.
  // 아래는 예시 URL입니다. 실제 관리자용 시트 URL로 교체해야 합니다.
  final String _noticeSheetUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSdddTvmNN6DJBtGDkw6erCIn9GAHmczd6opEZOIJB1mhBlLJWs6dEpRwhNKh6tNHTeGXSigylPH0CC/pub?output=csv';

  Future<List<Notice>> fetchRemoteNotices() async {
    try {
      final response = await http.get(Uri.parse(_noticeSheetUrl));

      if (response.statusCode == 200) {
        // CSV 파싱 (한글 깨짐 방지를 위해 response.body가 UTF-8인지 확인)
        List<List<dynamic>> rows = const CsvToListConverter().convert(response.body);

        if (rows.length <= 1) return []; // 데이터가 없거나 헤더만 있는 경우

        // 첫 번째 줄(헤더)을 제외하고 리스트 변환 (최신순을 위해 reversed 적용 가능)
        return rows.skip(1).map((row) => Notice.fromCsv(row)).toList().reversed.toList();
      } else {
        throw Exception('공지사항 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}