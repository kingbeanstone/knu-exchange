import 'package:intl/intl.dart';

class DateFormatter {
  /// 날짜를 상대적 시간(7 min ago, 2 hours ago 등)으로 변환합니다.
  /// 7일이 지나면 'yyyy.MM.dd' 형식으로 반환합니다.
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // 7일 이후에는 날짜 표시
      return DateFormat('yyyy.MM.dd').format(date);
    }
  }
}