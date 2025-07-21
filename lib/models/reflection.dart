// lib/models/reflection.dart
// Firebase 관련 import 제거

// 회고 기록을 위한 모델 클래스
class Reflection {
  final String id; // 고유 ID (로컬에서는 UUID 등으로 생성 가능)
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
}
