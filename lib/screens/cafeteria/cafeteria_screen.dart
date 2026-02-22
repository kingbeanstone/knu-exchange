import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/menu_section.dart';
import '../../providers/menu_provider.dart';

class CafeteriaScreen extends StatefulWidget {
  final String? initialFacilityId;
  const CafeteriaScreen({super.key, this.initialFacilityId});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  late DateTime _selectedDate;
  String _selectedStudentFacility = 'welfare_bldg_cafeteria';

  final Map<String, String> _studentFacilities = {
    'welfare_bldg_cafeteria': 'Welfare Bldg',
    'information_center_cafeteria': 'Information Center',
    'engineering_bldg_cafeteria': 'Engineering Bldg.',
    'kyungdaria_cafeteria': 'Kyungdaria'
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // 화면 로드 시 자동으로 최신 데이터 요청
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

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialFacilityId == 'cheomseong_dorm_cafeteria' ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cafeteria Menu'),
          backgroundColor: AppColors.knuRed,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'Student'), Tab(text: 'Dormitory')],
          ),
        ),
        body: Column(
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
                  : TabBarView(
                children: [
                  _buildStudentTab(menuProvider, dateStr),
                  SingleChildScrollView(
                    child: CafeteriaMenuSection(
                      menuData: menuProvider.getFilteredMenu('cheomseong_dorm_cafeteria', dateStr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTab(MenuProvider provider, String dateStr) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedStudentFacility,
            decoration: const InputDecoration(labelText: 'Select Cafeteria', border: OutlineInputBorder()),
            items: _studentFacilities.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (val) => setState(() => _selectedStudentFacility = val!),
          ),
        ),
        CafeteriaMenuSection(
          menuData: provider.getFilteredMenu(_selectedStudentFacility, dateStr),
        ),
      ],
    );
  }
}