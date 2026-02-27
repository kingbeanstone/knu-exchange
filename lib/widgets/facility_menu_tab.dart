import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';
import '../providers/menu_provider.dart';
import '../utils/app_colors.dart';
import './date_selector.dart';
import './menu_section.dart';

class FacilityMenuTab extends StatefulWidget {
  final Facility facility;
  final List<String> customHeaders; // 상세 페이지에서 받은 헤더 정보

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

  // 학생 식당 ID 리스트
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
    // 1. 학생 식당인 경우
    if (_studentCafeteriaIds.contains(widget.facility.id)) {
      return _buildStudentCafeteriaView();
    }

    // 2. 일반 시설인 경우 (상세 페이지의 고급 로직 적용)
    return _buildGeneralMenuView();
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
        const Divider(height: 1),
        Expanded(
          child: menuProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
        if (docs.isEmpty) return const Center(child: Text('No menu available.'));

        // 정렬 로직
        final sortedDocs = docs.toList()..sort((a, b) {
          int getOrder(DocumentSnapshot doc) {
            final val = (doc.data() as Map<String, dynamic>)['order'];
            if (val == null) return 999;
            if (val is int) return val;
            return int.tryParse(val.toString()) ?? 999;
          }
          return getOrder(a).compareTo(getOrder(b));
        });

        // 카테고리 그룹화
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.knuRed)),
                    Row(
                      children: widget.customHeaders.map((h) => SizedBox(
                          width: 55,
                          child: Text(h, textAlign: TextAlign.end, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w300))
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item['name'] ?? '', style: const TextStyle(fontSize: 14))),
                        Row(
                          children: widget.customHeaders.map((h) {
                            final price = prices[h];
                            return SizedBox(
                              width: 55,
                              child: Text(
                                price?.toString() ?? '-',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black87),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 30),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}