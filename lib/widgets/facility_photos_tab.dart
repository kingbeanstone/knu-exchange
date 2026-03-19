import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'common/full_screen_gallery.dart'; // 방금 만든 파일 임포트

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
            Text('No photos available yet.',
                style: TextStyle(color: Colors.grey)),
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
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FullScreenGallery(photos: photos, initialIndex: index),
              ),
            );
          },
          child: Hero(
            tag: photos[index],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: photos[index],
                fit: BoxFit.cover,
                // memCacheWidth를 제거해서 화질 유지
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
          ),
        );
      },
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
            // ✅ NetworkImage 대신 CachedNetworkImageProvider를 사용해야
            // 미리 로딩(Precaching)된 데이터를 즉시 보여줍니다.
            imageProvider: CachedNetworkImageProvider(widget.photos[index]),
            heroAttributes: PhotoViewHeroAttributes(tag: widget.photos[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0,
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