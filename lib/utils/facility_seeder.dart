import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FacilitySeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 도서관 및 헬스장 데이터를 Firestore에 저장하는 함수
  static Future<void> seedNewFacilities(BuildContext context) async {
    final List<Map<String, dynamic>> newFacilities = [
      {
        'id': 'central_library',
        'category': 'Study',
        'engName': 'KNU Central Library',
        'korName': '경북대학교 중앙도서관',
        'engDesc': 'The primary academic resource center of KNU. It provides various study spaces, computer labs, and a vast collection of books.',
        'korDesc': '경북대학교의 주요 학술 자원 센터입니다. 다양한 학습 공간, 컴퓨터 실습실 및 방대한 도서 컬렉션을 제공합니다.',
        'latitude': 35.89184,
        'longitude': 128.6125,
        'imageUrl': 'https://placehold.co/600x400?text=KNU+Library',
        'interiorImages': [],
      },
      {
        'id': 'fitness_center',
        'category': 'Sports',
        'engName': 'KNU Fitness Center',
        'korName': '경북대학교 헬스장',
        'engDesc': 'Located near the soccer field (Main Stadium). It is equipped with various exercise machines and facilities for students.',
        'korDesc': '운동장(메인 스타디움) 근처에 위치한 헬스장입니다. 학생들을 위한 다양한 운동 기구와 시설을 갖추고 있습니다.',
        'latitude': 35.88860,
        'longitude': 128.6059,
        'imageUrl': 'https://placehold.co/600x400?text=KNU+Fitness+Center',
        'interiorImages': [],
      }
    ];

    try {
      for (var facility in newFacilities) {
        final docId = facility['id'];
        // id 필드는 문서 ID로 쓰이므로 실제 데이터에서는 제외하고 저장 (선택 사항)
        final data = Map<String, dynamic>.from(facility)..remove('id');

        await _db.collection('facilities').doc(docId).set(data);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved new facilities!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }
}