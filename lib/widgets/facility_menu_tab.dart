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

  const FacilityMenuTab({super.key, required this.facility});

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

    // 학생 식당일 경우에만 초기 데이터 로드
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
    // 1. 학생 식당인 경우: 날짜 선택기 + 식당 고정 메뉴 섹션
    if (_studentCafeteriaIds.contains(widget.facility.id)) {
      return _buildStudentCafeteriaView();
    }

    // 2. 일반 시설인 경우: Firestore 기반 고정 메뉴판
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
              // 여기서 widget.facility.id로 자동 고정됩니다.
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
        if (snapshot.hasError) return const Center(child: Text('Error loading menu'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No menu items yet.'));

        Map<String, List<Map<String, dynamic>>> groupedMenu = {};
        for (var doc in docs) {
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
                Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.knuRed)),
                ...groupedMenu[category]!.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['name'] ?? ''),
                  trailing: Text('₩${item['price'] ?? '0'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                )),
                const Divider(height: 20),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}