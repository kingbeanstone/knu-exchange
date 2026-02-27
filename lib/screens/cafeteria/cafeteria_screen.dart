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

class _CafeteriaScreenState extends State<CafeteriaScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late TabController _tabController;
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

    _tabController = TabController(length: 2, vsync: this);

    // 🔥 처음 진입 시 Dormitory면 탭 변경
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
  void didUpdateWidget(covariant CafeteriaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialFacilityId != oldWidget.initialFacilityId &&
        widget.initialFacilityId != null) {

      if (_studentFacilities.containsKey(widget.initialFacilityId)) {
        setState(() {
          _selectedStudentFacility = widget.initialFacilityId!;
        });
      }

      // 🔥 Dormitory 자동 전환
      if (widget.initialFacilityId == 'cheomseong_dorm_cafeteria') {
        _tabController.animateTo(1);
      } else {
        _tabController.animateTo(0);
      }
    }
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final dateStr = _formatDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeteria Menu'),
        backgroundColor: AppColors.knuRed,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [Tab(text: 'On Campus'), Tab(text: 'Cheomseong Dormitory')],
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
              controller: _tabController,
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