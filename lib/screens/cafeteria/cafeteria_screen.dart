import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/cafeteria/cafeteria_widgets.dart';
import '../../widgets/cafeteria/menu_section.dart';

class CafeteriaScreen extends StatefulWidget {
  final String? initialFacilityId;
  const CafeteriaScreen({super.key, this.initialFacilityId});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late TabController _tabController;
  String _selectedStudentFacility = 'welfare_bldg_cafeteria';

  // 학내 식당 목록 (On Campus 전용)
  final Map<String, String> _studentFacilities = {
    'welfare_bldg_cafeteria': 'Welfare Bldg',
    'information_center_cafeteria': 'Info Center',
    'engineering_bldg_cafeteria': 'Eng. Bldg',
    'kyungdaria_cafeteria': 'Kyungdaria'
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);

    // 초기 진입 시 기숙사 식당일 경우 탭 이동
    if (widget.initialFacilityId == 'cheomseong_dorm_cafeteria') {
      _tabController.index = 1;
    }

    if (widget.initialFacilityId != null &&
        _studentFacilities.containsKey(widget.initialFacilityId)) {
      _selectedStudentFacility = widget.initialFacilityId!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().refreshMenu();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final dateStr = _formatDate(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 다른 탭과 동일한 배경색
      appBar: AppBar(
        title: const Text(
          'Cafeteria',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // 왼쪽 정렬 통일
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'On Campus'),
            Tab(text: 'Dormitory'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. 커스텀 날짜 선택기
          CafeteriaDateSelector(
            selectedDate: _selectedDate,
            onPrev: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
            onNext: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
          ),

          // 2. 본문 컨텐츠
          Expanded(
            child: menuProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.knuRed))
                : TabBarView(
              controller: _tabController,
              children: [
                _buildOnCampusView(menuProvider, dateStr),
                _buildDormitoryView(menuProvider, dateStr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 학내 식당 뷰 (가로 칩 필터 포함)
  Widget _buildOnCampusView(MenuProvider provider, String dateStr) {
    return Column(
      children: [
        CafeteriaFacilityFilter(
          selectedId: _selectedStudentFacility,
          facilities: _studentFacilities,
          onSelected: (id) => setState(() => _selectedStudentFacility = id),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: CafeteriaMenuSection(
              menuData: provider.getFilteredMenu(_selectedStudentFacility, dateStr),
            ),
          ),
        ),
      ],
    );
  }

  // 기숙사 식당 뷰
  Widget _buildDormitoryView(MenuProvider provider, String dateStr) {
    return SingleChildScrollView(
      child: CafeteriaMenuSection(
        menuData: provider.getFilteredMenu('cheomseong_dorm_cafeteria', dateStr),
      ),
    );
  }
}