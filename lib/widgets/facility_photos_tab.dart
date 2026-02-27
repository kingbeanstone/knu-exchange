import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
          onTap: () => _openPhotoGallery(context, index),
          child: Hero(
            tag: photos[index],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photos[index],
                fit: BoxFit.cover,
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

  void _openPhotoGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SamsungStyleGalleryScreen(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class SamsungStyleGalleryScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const SamsungStyleGalleryScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<SamsungStyleGalleryScreen> createState() => _SamsungStyleGalleryScreenState();
}

class _SamsungStyleGalleryScreenState extends State<SamsungStyleGalleryScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.photos.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.photos[index]),
            heroAttributes: PhotoViewHeroAttributes(tag: widget.photos[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0,
            // ❌ 기존 에러 원인: loadingBuilder는 여기서 정의하지 않습니다.
          );
        },
        pageController: _pageController,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        // ✅ 해결 1: physics를 scrollPhysics로 변경
        scrollPhysics: const BouncingScrollPhysics(),
        // ✅ 해결 2: loadingBuilder를 이 위치(Gallery 레벨)로 이동
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        wantKeepAlive: true,
      ),
    );
  }
}