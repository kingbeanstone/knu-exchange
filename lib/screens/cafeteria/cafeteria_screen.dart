import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../../utils/app_colors.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/menu_section.dart';

class CafeteriaScreen extends StatefulWidget {
  final String? initialFacilityId;
  const CafeteriaScreen({super.key, this.initialFacilityId});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  late DateTime _selectedDate;
  String _selectedStudentFacility = 'welfare_bldg_cafeteria';
  late Future<List<Map<String, String>>> _menuFuture;

  final Map<String, String> _studentFacilities = {
    'welfare_bldg_cafeteria': 'Welfare Bldg',
    'information_center_cafeteria': 'Information Center',
    'engineering_bldg_cafeteria': 'Engineering Bldg.',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _menuFuture = _loadMenu();
  }

  Future<List<Map<String, String>>> _loadMenu() async {
    final rawData = await rootBundle.loadString('assets/data/menu.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

    if (listData.isEmpty) return [];
    final headers = listData[0].map((e) => e.toString()).toList();

    return listData.skip(1).map((row) {
      Map<String, String> map = {};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i].toString();
      }
      return map;
    }).toList();
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
            tabs: [Tab(text: 'Student'), Tab(text: 'Dormitory'), Tab(text: 'Staff')],
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
              child: FutureBuilder<List<Map<String, String>>>(
                future: _menuFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final menuList = snapshot.data!;
                  final dateStr = _formatDate(_selectedDate);

                  return TabBarView(
                    children: [
                      _buildStudentTab(menuList, dateStr),
                      SingleChildScrollView(
                        child: CafeteriaMenuSection(
                            allMenuData: menuList,
                            facilityId: 'cheomseong_dorm_cafeteria',
                            selectedDate: dateStr
                        ),
                      ),
                      const Center(child: Text('Staff Cafeteria Menu (Coming Soon)')),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTab(List<Map<String, String>> menuList, String dateStr) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<String>(
            value: _selectedStudentFacility,
            decoration: const InputDecoration(labelText: 'Select Cafeteria', border: OutlineInputBorder()),
            items: _studentFacilities.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (val) => setState(() => _selectedStudentFacility = val!),
          ),
        ),
        CafeteriaMenuSection(
          allMenuData: menuList,
          facilityId: _selectedStudentFacility,
          selectedDate: dateStr,
        ),
      ],
    );
  }
}