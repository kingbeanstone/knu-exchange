import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해 추가
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/menu_item.dart';

class MenuService {
  // 구글 시트 '웹에 게시' 시 생성된 CSV URL (반드시 output=csv 확인)
  final String _sheetUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQNfHaNZv1nOJdVq1ubjdPBQmE6lu1VoN1AySWiaW2l9oQLICAwUF_Kg_mtxpwgQUv6_WLtdmtYfpRR/pub?output=csv';

  Future<List<MenuItem>> fetchRemoteMenu() async {
    try {
      final response = await http.get(Uri.parse(_sheetUrl));

      if (response.statusCode == 200) {
        // [디버깅] 실제 데이터가 어떻게 오는지 로그 확인
        debugPrint('--- Menu CSV Fetch Success ---');

        List<List<dynamic>> rows = const CsvToListConverter().convert(response.body);

        if (rows.length <= 1) {
          debugPrint('Warning: No data rows found in CSV.');
          return [];
        }

        // 데이터 변환 및 로그 출력
        final items = rows.skip(1).map((row) {
          final item = MenuItem.fromCsv(row);
          // dinner가 포함되어 있는지 확인용 로그
          if (item.meal.contains('dinner')) {
            debugPrint('Found dinner item: ${item.date} - ${item.facility}');
          }
          return item;
        }).toList();

        return items;
      } else {
        throw Exception('Failed to load menu: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching menu: $e');
      rethrow;
    }
  }
}