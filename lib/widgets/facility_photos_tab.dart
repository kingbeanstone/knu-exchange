import 'package:flutter/material.dart';

class FacilityPhotosTab extends StatelessWidget {
  final List<String> photos;

  const FacilityPhotosTab({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No photos available yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openFullScreenImage(context, index),
          child: Hero(
            tag: 'photo_$index',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photos[index],
                fit: BoxFit.cover,
                // 이미지 로딩 중 표시
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // 이미지를 크게 보여주는 다이얼로그/화면 함수
  void _openFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: PageView.builder(
            itemCount: photos.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: Hero(
                  tag: 'photo_$index',
                  child: InteractiveViewer( // 핀치 줌 기능 추가
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}