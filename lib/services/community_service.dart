import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _appId = 'knu-exchange-app';

  CollectionReference get _postsRef =>
      _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('posts');

  // 게시글 전체 목록 조회
  Future<List<Post>> getPosts() async {
    final snapshot = await _postsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Post(
        id: doc.id,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        // Firestore에 저장된 닉네임(author)을 가져옴
        author: data['author'] ?? 'Anonymous',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        category: PostCategory.values.firstWhere(
              (e) => e.toString() == data['category'],
          orElse: () => PostCategory.free,
        ),
        likes: data['likes'] ?? 0,
        comments: data['comments'] ?? 0,
      );
    }).toList();
  }

  // 특정 게시글 상세 조회
  Future<Post?> getPost(String postId) async {
    final doc = await _postsRef.doc(postId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: PostCategory.values.firstWhere(
            (e) => e.toString() == data['category'],
        orElse: () => PostCategory.free,
      ),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
    );
  }

  // 게시글 작성: 현재 사용자의 displayName을 author 필드에 확실히 저장
  Future<void> addPost(String title, String content, PostCategory category) async {
    final user = FirebaseAuth.instance.currentUser;
    // displayName이 없을 경우 이메일 아이디나 기본값 사용
    final String nickname = user?.displayName ?? user?.email?.split('@')[0] ?? 'Anonymous';

    await _postsRef.add({
      'title': title,
      'content': content,
      'author': nickname, // 작성자 닉네임 저장
      'authorId': user?.uid, // 검색/삭제 권한 확인용 ID 저장
      'createdAt': FieldValue.serverTimestamp(),
      'category': category.toString(),
      'likes': 0,
      'comments': 0,
    });
  }
}