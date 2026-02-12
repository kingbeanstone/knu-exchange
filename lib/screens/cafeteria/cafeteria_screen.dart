import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CafeteriaScreen extends StatefulWidget {
  const CafeteriaScreen({super.key});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  static const Map<String, String> _mealLabel = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
  };

  static const Map<String, int> _mealOrder = {
    'breakfast': 0,
    'lunch': 1,
    'dinner': 2,
  };
  static const Map<String, String> _studentFacilityDisplay = {
    'welfare_bldg': 'Welfare Bldg',
    'information_center': 'Information Center',
    'engineering_bldg': 'Engineering Bldg.',
    'global_plaza': 'Global Plaza Cafeteria',
  };

  // 날짜 선택 (기본: 오늘)
  late DateTime _selectedDate;
  String _selectedStudentFacility = 'welfare_bldg';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  // CSV 스키마: facility,date,meal,menu
  Future<List<Map<String, String>>> loadMenu() async {
    final raw = await rootBundle.loadString('assets/data/menu.csv');
    final lines = raw.split('\n');

    final List<Map<String, String>> menuList = [];

    // 0번째 줄은 헤더라고 가정
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final row = line.split(',');
      if (row.length >= 4) {
        final facility = row[0].trim().toLowerCase();
        final date = row[1].trim();
        final meal = row[2].trim().toLowerCase();

        // 메뉴 텍스트에 쉼표가 들어갈 수 있어 4번째 컬럼 이후는 다시 합칩니다.
        final joinedMenu = row.sublist(3).join(',').trim();
        final cleanedMenu = (joinedMenu.startsWith('"') &&
                joinedMenu.endsWith('"') &&
                joinedMenu.length >= 2)
            ? joinedMenu.substring(1, joinedMenu.length - 1)
            : joinedMenu;

        menuList.add({
          'facility': facility,
          'date': date,
          'meal': meal,
          'menu': cleanedMenu,
        });
      }
    }

    return menuList;
  }

  String _toIsoDate(DateTime d) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  String _weekdayShortEn(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }



  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Widget _buildDateHeader() {
    final isToday = _isToday(_selectedDate);
    final md = '${_selectedDate.month}/${_selectedDate.day}';
    final label = isToday
        ? 'TODAY · $md (${_weekdayShortEn(_selectedDate)})'
        : '$md (${_weekdayShortEn(_selectedDate)})';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuForFacility(
    List<Map<String, String>> menuList,
    String facilityId,
  ) {
    final iso = _toIsoDate(_selectedDate);

    final dayMenu = menuList
        .where((e) => e['facility'] == facilityId && e['date'] == iso)
        .toList();

    dayMenu.sort((a, b) {
      final aKey = (a['meal'] ?? '').toLowerCase();
      final bKey = (b['meal'] ?? '').toLowerCase();
      final aOrder = _mealOrder[aKey] ?? 999;
      final bOrder = _mealOrder[bKey] ?? 999;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      return aKey.compareTo(bKey);
    });

    if (dayMenu.isEmpty) {
      return const [
        SizedBox(height: 24),
        Center(
          child: Text(
            'No menu available for this date.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ];
    }

    final Map<String, List<Map<String, String>>> grouped = {};
    for (final item in dayMenu) {
      final meal = (item['meal'] ?? '').toLowerCase();
      grouped.putIfAbsent(meal, () => []).add(item);
    }

    final mealsInOrder = grouped.keys.toList()
      ..sort((a, b) => (_mealOrder[a] ?? 999).compareTo(_mealOrder[b] ?? 999));

    final List<Widget> widgets = [];

    for (final meal in mealsInOrder) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            _mealLabel[meal] ?? meal.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );

      for (final item in grouped[meal]!) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Card(
              child: ListTile(
                title: Text(item['menu'] ?? ''),
              ),
            ),
          ),
        );
      }
    }

    widgets.add(const SizedBox(height: 24));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭 개수 (학생식당, 기숙사, 교직원)
      initialIndex: 1, // Default: Dormitory
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cafeteria Menu'),
          backgroundColor: const Color(0xFFDD1829),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Student'),
              Tab(text: 'Dormitory'),
              Tab(text: 'Staff'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<Map<String, String>>>(
              future: loadMenu(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load menu: ${snapshot.error}'),
                  );
                }

                final menuList = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildDateHeader(),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedStudentFacility,
                        items: _studentFacilityDisplay.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedStudentFacility = value;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        children: _buildMenuForFacility(
                          menuList,
                          _selectedStudentFacility,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Dormitory 탭: 날짜 선택 + 선택한 날짜의 아침/점심/저녁 표시
            FutureBuilder<List<Map<String, String>>>(
              future: loadMenu(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load menu: ${snapshot.error}'),
                  );
                }

                final menuList = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildDateHeader(),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        children: _buildMenuForFacility(menuList, 'cheomsung_dorm'),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Center(child: Text('Staff Cafeteria Menu Here')),
          ],
        ),
      ),
    );
  }
}