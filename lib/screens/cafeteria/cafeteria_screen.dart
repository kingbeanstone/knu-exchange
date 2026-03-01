import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/cafeteria/cafeteria_widgets.dart';
import '../../widgets/cafeteria/menu_section.dart';
import '../../widgets/common_notification_button.dart';

class CafeteriaScreen extends StatefulWidget {
  final String? initialFacilityId;
  const CafeteriaScreen({super.key, this.initialFacilityId});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  late DateTime _selectedDate;
  String _selectedFacilityId = 'welfare_bldg_cafeteria';

  /// [수정] 필터명에 건물 번호를 추가하여 위치 파악을 용이하게 변경
  final Map<String, String> _allFacilities = {
    'cheomseong_dorm_cafeteria': '114(Cheomseong)',
    'welfare_bldg_cafeteria': '305(Welfare)',
    'information_center_cafeteria': '116(Info)',
    'engineering_bldg_cafeteria': '408(Engineer)',
    'kyungdaria': '111(FastFood)',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    if (widget.initialFacilityId != null &&
        _allFacilities.containsKey(widget.initialFacilityId)) {
      _selectedFacilityId = widget.initialFacilityId!;
    }

    // 화면 진입 시 최신 메뉴 데이터 로드
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
        centerTitle: true,
        actions: const [
          CommonNotificationButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 날짜 선택 바
          CafeteriaDateSelector(
            selectedDate: _selectedDate,
            onPrev: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
            onNext: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
          ),

          // 식당 선택 필터 (수정된 이름 반영)
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