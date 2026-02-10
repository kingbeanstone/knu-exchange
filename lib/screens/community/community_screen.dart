import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: const Color(0xFFDD1829),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 기능 구현 예정
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: 10, // 임시 데이터 개수
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            title: Text('Post Title #$index'),
            subtitle: const Text('This is a summary of the post content...'),
            trailing: const Text('10:30 AM', style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () {
              // 게시글 상세 화면으로 이동
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 화면으로 이동
        },
        backgroundColor: const Color(0xFFDD1829),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}