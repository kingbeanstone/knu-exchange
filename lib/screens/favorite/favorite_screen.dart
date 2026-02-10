import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFFDD1829),
        foregroundColor: Colors.white,
      ),
      // 즐겨찾기 목록이 비었을 때를 가정한 UI
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your favorite cafeterias or buildings!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}