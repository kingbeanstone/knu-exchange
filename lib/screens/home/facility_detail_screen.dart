import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isAdmin = false;
  late bool _showMenuTab;

  @override
  void initState() {
    super.initState();
    // 식당이나 카페일 때만 메뉴 탭을 보여줍니다
    _showMenuTab = widget.facility.category == 'Restaurant' || widget.facility.category == 'Cafe';

    // 탭 개수 설정 (4개 또는 3개)
    _tabController = TabController(length: _showMenuTab ? 4 : 3, vsync: this);

    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('knu-exchange-app')
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('info')
          .get();
      if (mounted) setState(() => _isAdmin = doc.data()?['isAdmin'] == true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('facilities').doc(widget.facility.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final data = snapshot.data!.data() as Map<String, dynamic>;
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
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 60),
                    title: Text(f.engName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    background: f.imageUrl != null ? Image.network(f.imageUrl!, fit: BoxFit.cover) : Container(color: Colors.grey[300]),
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
                          const Tab(text: 'Floor'), // 👈 "Indoor Map"에서 "Floor"로 단축
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
                if (_showMenuTab) _buildMenuTab(f),
                _buildPhotosTab(f), // 👈 기존 Placeholder를 이 함수로 교체
                const Center(child: Text('Floor info is coming soon!')),
              ],
            ),
          ),
        );
      },
    );
  }

  // 홈 탭과 메뉴 탭 빌더는 이전과 동일
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

  Widget _buildMenuTab(Facility f) {
    return StreamBuilder<QuerySnapshot>(
      // 1. 해당 시설 문서 안의 'menu' 서브 컬렉션을 실시간으로 감시합니다.
      stream: FirebaseFirestore.instance
          .collection('facilities')
          .doc(f.id)
          .collection('menu')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading menu'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No menu items yet.'));
        }

        // 2. 데이터를 카테고리(Coffee, Latte, Decaf 등)별로 그룹화합니다.
        Map<String, List<Map<String, dynamic>>> groupedMenu = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] ?? 'Others';
          if (!groupedMenu.containsKey(category)) {
            groupedMenu[category] = [];
          }
          groupedMenu[category]!.add(data);
        }

        // 3. 그룹화된 데이터를 리스트로 출력합니다.
        return ListView(
          padding: const EdgeInsets.all(20),
          children: groupedMenu.keys.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 이름 (예: Coffee)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.knuRed, // 강조색 사용
                    ),
                  ),
                ),
                // 해당 카테고리에 속한 메뉴들
                ...groupedMenu[category]!.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 메뉴 이름
                        Text(item['name'] ?? '', style: const TextStyle(fontSize: 16)),
                        // 가격
                        Text(
                          '₩${item['price'] ?? '0'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 30), // 카테고리 간 구분선
              ],
            );
          }).toList(),
        );
      },
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
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(Facility f) {
    final photos = f.interiorImages ?? [];

    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No photos available yet.'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 한 줄에 3장씩 표시
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, photos[index]), // 클릭 시 크게 보기
          child: Hero(
            tag: photos[index],
            child: Image.network(
              photos[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

// 사진 크게 보기 다이얼로그
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // 줌 기능이 포함된 이미지 뷰어
            InteractiveViewer(
              child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}