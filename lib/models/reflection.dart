// lib/models/reflection.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// 회고 기록을 위한 모델 클래스
class Reflection {
  final String id; // 고유 ID (Firebase document ID)
  final String type; // "play" 또는 "feed"
  final String question;
  final String answer;
  final DateTime timestamp;

  Reflection({
    required this.id,
    required this.type,
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  // Firebase에서 데이터를 가져올 때 사용하는 factory 생성자
  factory Reflection.fromFirestore(Map<String, dynamic> data, String id) {
    return Reflection(
      id: id,
      type: data['type'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Firebase에 데이터를 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'question': question,
      'answer': answer,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // copyWith 메서드 (필요한 경우)
  Reflection copyWith({
    String? id,
    String? type,
    String? question,
    String? answer,
    DateTime? timestamp,
  }) {
    return Reflection(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
