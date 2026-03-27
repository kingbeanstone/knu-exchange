import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// 이미지 파일을 Firebase Storage에 업로드하고 다운로드 URL을 반환합니다.
  Future<String?> uploadImage({
    required File imageFile,
    required String storagePath,
  }) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child(storagePath).child(fileName);
      final SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  /// [추가] 여러 이미지 파일을 동시에 업로드하고 URL 리스트를 반환합니다.
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String storagePath,
  }) async {
    List<String> uploadUrls = [];
    for (File file in imageFiles) {
      final url = await uploadImage(imageFile: file, storagePath: storagePath);
      if (url != null) {
        uploadUrls.add(url);
      }
    }
    return uploadUrls;
  }

  /// 스토리지 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      debugPrint("Image delete error: $e");
    }
  }
}