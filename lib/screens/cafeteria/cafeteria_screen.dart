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

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  late DateTime _selectedDate;
  String _selectedFacilityId = 'welfare_bldg_cafeteria';

  // 식당 목록 정의
  final Map<String, String> _allFacilities = {
    'cheomseong_dorm_cafeteria': 'Cheomeong Dorm',
    'welfare_bldg_cafeteria': 'Welfare Bldg',
    'information_center_cafeteria': 'Info Center',
    'engineering_bldg_cafeteria': 'Eng. Bldg',
    'kyungdaria_cafeteria': 'Kyungdaria',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // 초기 진입 시 전달된 식당 ID가 있으면 설정
    if (widget.initialFacilityId != null &&
        _allFacilities.containsKey(widget.initialFacilityId)) {
      _selectedFacilityId = widget.initialFacilityId!;
    }

    // 화면 진입 후 첫 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentData();
    });
  }

  /// 선택된 식당/날짜에 맞는 데이터를 로드하는 통합 함수
  Future<void> _loadCurrentData() async {
    final provider = context.read<MenuProvider>();

    // 1. 기본 전체 메뉴(CSV/Firestore) 새로고침
    await provider.refreshMenu();

    // 2. 기숙사 식당이 선택된 경우 크롤링 수행
    if (mounted) {
      await provider.fetchDormMenuIfNeeded(_selectedFacilityId, _selectedDate);
    }
  }

  /// 날짜나 식당 변경 시 호출되는 이벤트 핸들러
  void _onSelectionChanged({String? facilityId, DateTime? date}) {
    setState(() {
      if (facilityId != null) _selectedFacilityId = facilityId;
      if (date != null) _selectedDate = date;
    });

    // 변경된 조건으로 데이터 로드 (기숙사 크롤링 포함)
    context.read<MenuProvider>().fetchDormMenuIfNeeded(
        _selectedFacilityId,
        _selectedDate
    );
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final dateStr = _formatDate(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Cafeteria',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 1. 날짜 선택 영역
          CafeteriaDateSelector(
            selectedDate: _selectedDate,
            onPrev: () => _onSelectionChanged(date: _selectedDate.subtract(const Duration(days: 1))),
            onNext: () => _onSelectionChanged(date: _selectedDate.add(const Duration(days: 1))),
          ),

          // 2. 식당 필터 영역 (Wrap 위젯을 사용하여 4개 이상 시 자동 줄바꿈)
          CafeteriaFacilityFilter(
            selectedId: _selectedFacilityId,
            facilities: _allFacilities,
            onSelected: (id) => _onSelectionChanged(facilityId: id),
          ),

          const SizedBox(height: 16),

          // 3. 본문 메뉴 목록 영역
          Expanded(
            child: menuProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.knuRed))
                : RefreshIndicator(
              onRefresh: _loadCurrentData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: CafeteriaMenuSection(
                  menuData: menuProvider.getFilteredMenu(_selectedFacilityId, dateStr),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}