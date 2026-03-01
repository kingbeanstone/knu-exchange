import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';
import '../providers/menu_provider.dart';
import '../utils/app_colors.dart';
import 'cafeteria/cafeteria_widgets.dart';
import 'cafeteria/menu_section.dart';

class FacilityMenuTab extends StatefulWidget {
  final Facility facility;
  final List<String> customHeaders;

  const FacilityMenuTab({
    super.key,
    required this.facility,
    this.customHeaders = const []
  });

  @override
  State<FacilityMenuTab> createState() => _FacilityMenuTabState();
}

class _FacilityMenuTabState extends State<FacilityMenuTab> {
  late DateTime _selectedDate;

  final List<String> _studentCafeteriaIds = [
    'welfare_bldg_cafeteria',
    'information_center_cafeteria',
    'engineering_bldg_cafeteria',
    'kyungdaria_cafeteria',
    'cheomseong_dorm_cafeteria'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    if (_studentCafeteriaIds.contains(widget.facility.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MenuProvider>().refreshMenu();
      });
    }
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    // [수정] 배경색을 CafeteriaScreen과 동일하게 설정하여 통일감 부여
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _studentCafeteriaIds.contains(widget.facility.id)
          ? _buildStudentCafeteriaView()
          : _buildGeneralMenuView(),
    );
  }

  Widget _buildStudentCafeteriaView() {
    final menuProvider = context.watch<MenuProvider>();
    final dateStr = _formatDate(_selectedDate);

    return Column(
      children: [
        CafeteriaDateSelector(
          selectedDate: _selectedDate,
          onPrev: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          onNext: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
        ),
        // [수정] 디자인 가이드에 맞춰 Divider 높이 및 여백 조정
        const SizedBox(height: 8),
        Expanded(
          child: menuProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.knuRed))
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: CafeteriaMenuSection(
              menuData: menuProvider.getFilteredMenu(widget.facility.id, dateStr),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralMenuView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('facilities')
          .doc(widget.facility.id)
          .collection('menu')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu_rounded, color: Colors.grey.shade300, size: 48),
                const SizedBox(height: 16),
                const Text('No menu available.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // 정렬 및 카테고리 그룹화 로직 (기존 유지)
        final sortedDocs = docs.toList()..sort((a, b) {
          int getOrder(DocumentSnapshot doc) {
            final val = (doc.data() as Map<String, dynamic>)['order'];
            if (val == null) return 999;
            return val is int ? val : int.tryParse(val.toString()) ?? 999;
          }
          return getOrder(a).compareTo(getOrder(b));
        });

        Map<String, List<Map<String, dynamic>>> groupedMenu = {};
        for (var doc in sortedDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] ?? 'Others';
          groupedMenu.putIfAbsent(category, () => []).add(data);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: groupedMenu.keys.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 일반 시설 메뉴용 헤더 디자인 개선
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.knuRed,
                        )
                    ),
                    Row(
                      children: widget.customHeaders.map((h) => SizedBox(
                          width: 55,
                          child: Text(
                              h,
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 10, color: Colors.grey)
                          )
                      )).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...groupedMenu[category]!.map((item) {
                  final Map<String, dynamic> prices = item['prices'] ?? {};
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                                item['name'] ?? '',
                                style: const TextStyle(fontSize: 14, color: AppColors.darkGrey)
                            )
                        ),
                        ...widget.customHeaders.map((h) => SizedBox(
                            width: 55,
                            child: Text(
                              prices[h]?.toString() ?? '-',
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            )
                        )),
                      ],
                    ),
                  );
                }),
                const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}