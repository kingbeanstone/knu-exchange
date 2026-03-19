import 'package:flutter/material.dart';
import '../../models/notice.dart';
import '../../utils/app_colors.dart';
import '../../utils/date_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ 추가

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onTap;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // ✅ 불필요한 null 체크(!)와 조건문 제거로 경고 해결
            if (notice.imageUrls.isNotEmpty) {
              for (var url in notice.imageUrls) {
                precacheImage(CachedNetworkImageProvider(url), context);
              }
            }
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        // ✅ 수정: withOpacity 대신 withValues 사용 (경고 예방)
                        color: AppColors.knuRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.campaign_rounded, size: 14, color: AppColors.knuRed),
                          SizedBox(width: 4),
                          Text(
                            "NOTICE",
                            style: TextStyle(
                              color: AppColors.knuRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormatter.formatRelativeTime(notice.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}