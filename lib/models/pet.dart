// lib/models/pet.dart
// Firebase 관련 import 제거

// 펫 데이터를 위한 모델 클래스
class Pet {
  final String name; // 펫 이름
  final int experience; // 현재 경험치
  final int growthStage; // 성장 단계 (0: 초기 알, 1: 금 간 알, 2: 부화 직전 알, 3: 새끼 펫)
  final DateTime? lastReflectionDate; // 마지막 회고 작성 날짜
  final int hunger; // 배고픔 (0-100)
  final int happiness; // 행복 (0-100)
  final int cleanliness; // 청결 (0-100)
  final DateTime? lastAttendanceDate; // 마지막 출석체크 날짜 (CLEAN 액션용)

  Pet({
    required this.name,
    required this.experience,
    required this.growthStage,
    this.lastReflectionDate,
    required this.hunger,
    required this.happiness,
    required this.cleanliness,
    this.lastAttendanceDate,
  });

  // Pet 객체 복사 및 변경을 위한 copyWith 메서드
  Pet copyWith({
    String? name,
    int? experience,
    int? growthStage,
    DateTime? lastReflectionDate,
    int? hunger,
    int? happiness,
    int? cleanliness,
    DateTime? lastAttendanceDate,
  }) {
    return Pet(
      name: name ?? this.name,
      experience: experience ?? this.experience,
      growthStage: growthStage ?? this.growthStage,
      lastReflectionDate: lastReflectionDate ?? this.lastReflectionDate,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      cleanliness: cleanliness ?? this.cleanliness,
      lastAttendanceDate: lastAttendanceDate ?? this.lastAttendanceDate,
    );
  }
}
