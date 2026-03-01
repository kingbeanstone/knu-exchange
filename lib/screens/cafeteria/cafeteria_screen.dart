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
  // 기본 선택 식당
  String _selectedFacilityId = 'welfare_bldg_cafeteria';

  /// [확인] 엑셀의 'facility' 열에 적힌 이름과 왼쪽의 키(Key)값이 같아야 합니다.
  final Map<String, String> _allFacilities = {
    'cheomseong_dorm_cafeteria': 'Cheomeong Dorm',
    'welfare_bldg_cafeteria': 'Welfare Bldg',
    'information_center_cafeteria': 'Info Center',
    'engineering_bldg_cafeteria': 'Eng. Bldg',
    'kyungdaria': 'Kyungdaria', // ID를 kyungdaria로 단순화 (엑셀과 일치 확인 필요)
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    if (widget.initialFacilityId != null &&
        _allFacilities.containsKey(widget.initialFacilityId)) {
      _selectedFacilityId = widget.initialFacilityId!;
    }

    // 화면 진입 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().refreshMenu();
    });
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
        centerTitle: true, // 제목 중앙 정렬 추가
      ),
      body: Column(
        children: [
          CafeteriaDateSelector(
            selectedDate: _selectedDate,
            onPrev: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
            onNext: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
          ),

          CafeteriaFacilityFilter(
            selectedId: _selectedFacilityId,
            facilities: _allFacilities,
            onSelected: (id) => setState(() => _selectedFacilityId = id),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: menuProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.knuRed))
                : RefreshIndicator(
              color: AppColors.knuRed,
              onRefresh: () => context.read<MenuProvider>().refreshMenu(),
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