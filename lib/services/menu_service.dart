
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/menu_item.dart';

class MenuService {
  // 구글 시트에서 '웹에 게시' 후 생성된 CSV 링크를 여기에 넣습니다.
  // 현재는 예시 URL입니다. 실제 배포 시 관리자가 생성한 URL로 교체하세요.
  final String _sheetUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vS-YOUR_SHEET_ID/pub?output=csv';

  Future<List<MenuItem>> fetchRemoteMenu() async {
    try {
      final response = await http.get(Uri.parse(_sheetUrl));

      if (response.statusCode == 200) {
        // 구글 시트의 CSV 응답을 파싱
        List<List<dynamic>> rows = const CsvToListConverter().convert(response.body);

        if (rows.length <= 1) return []; // 데이터가 없거나 헤더만 있는 경우

        // 첫 번째 헤더 줄 제외하고 모델 리스트로 변환
        return rows.skip(1).map((row) => MenuItem.fromCsv(row)).toList();
      } else {
        throw Exception('Failed to fetch menu: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}