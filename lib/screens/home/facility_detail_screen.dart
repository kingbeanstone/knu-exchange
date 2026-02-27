import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/facility.dart';
import '../../utils/app_colors.dart';

class FacilityDetailScreen extends StatefulWidget {
  final Facility facility;
  const FacilityDetailScreen({super.key, required this.facility});

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _showMenuTab;

  @override
  void initState() {
    super.initState();
    _showMenuTab = widget.facility.category == 'Restaurant' || widget.facility.category == 'Cafe';
    _tabController = TabController(length: _showMenuTab ? 4 : 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('facilities').doc(widget.facility.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {}; // 👈 데이터가 없으면 빈 맵 반환
        final List<String> customHeaders = List<String>.from(data['menuHeaders'] ?? []);

        final f = Facility(
          id: widget.facility.id,
          korName: data['korName'] ?? '',
          engName: data['engName'] ?? '',
          latitude: widget.facility.latitude,
          longitude: widget.facility.longitude,
          korDesc: data['korDesc'] ?? '',
          engDesc: data['engDesc'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'],
          operatingHours: data['operatingHours'],
          interiorImages: List<String>.from(data['interiorImages'] ?? []),
        );

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  backgroundColor: AppColors.knuRed,
                  foregroundColor: Colors.white, // 뒤로 가기 화살표 색상 고정
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      // 1. 현재 AppBar의 높이를 계산합니다.
                      var top = constraints.biggest.height;

                      // 2. 펼쳐졌을 때(200)와 접혔을 때(약 104) 사이의 비율을 계산합니다.
                      // (104 = 툴바 56 + 탭바 48)
                      double expandRatio = ((top - 104) / (200 - 104)).clamp(0.0, 1.0);

                      // 3. 비율에 따라 좌측 패딩을 20에서 56 사이로 조절합니다.
                      // 접힐수록(expandRatio가 0에 가까울수록) 56에 가까워집니다.
                      double paddingStart = 56.0 - (36.0 * expandRatio);

                      return FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: EdgeInsetsDirectional.only(
                          start: paddingStart,
                          bottom: 62, // 탭바 위쪽으로 위치 고정
                        ),
                        title: Text(
                          f.engName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            f.imageUrl != null
                                ? Image.network(f.imageUrl!, fit: BoxFit.cover)
                                : Container(color: Colors.grey[300]),
                            // 글자가 잘 보이도록 어두운 그라데이션 추가
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.knuRed,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.knuRed,
                        tabs: [
                          const Tab(text: 'Home'),
                          if (_showMenuTab) const Tab(text: 'Menu'),
                          const Tab(text: 'Photos'),
                          const Tab(text: 'Floor'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(f),
                if (_showMenuTab) _buildMenuTab(f, customHeaders),
                _buildPhotosTab(f),
                const Center(child: Text('Floor info is coming soon!')),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 가장 안전한 버전의 메뉴 탭 ---
  Widget _buildMenuTab(Facility f, List<String> headers) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('facilities').doc(f.id).collection('menu').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No menu available.'));

        // ✅ [안전 장치 1] 어떤 타입의 order 필드가 오거나, 없어도 무조건 숫자로 변환하여 정렬
        final sortedDocs = docs.toList()..sort((a, b) {
          int getOrder(DocumentSnapshot doc) {
            final val = (doc.data() as Map<String, dynamic>)['order'];
            if (val == null) return 999;
            if (val is int) return val;
            return int.tryParse(val.toString()) ?? 999;
          }
          return getOrder(a).compareTo(getOrder(b));
        });

        // ✅ [안전 장치 2] 카테고리 그룹화 (LinkedHashMap으로 순서 유지)
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
                      children: headers.map((h) => SizedBox(
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
                          children: headers.map((h) {
                            // ✅ [안전 장치 3] 가격 데이터가 숫자/문자/null 상관없이 안전하게 출력
                            final price = prices[h];
                            return SizedBox(
                              width: 55,
                              child: Text(
                                price?.toString() ?? '-', // 가격이 없으면 '-'
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

  // --- 이하 공통 탭 빌더 (기존 유지) ---
  Widget _buildHomeTab(Facility f) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.category, "Category", f.category),
          _buildInfoRow(Icons.access_time, "Operating Hours", f.operatingHours ?? "Not specified"),
          const Divider(height: 40),
          const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(f.engDesc, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(Facility f) {
    final photos = f.interiorImages ?? [];
    if (photos.isEmpty) return const Center(child: Text('No photos available yet.'));
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: photos.length,
      itemBuilder: (context, index) => Image.network(photos[index], fit: BoxFit.cover),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.knuRed, size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}