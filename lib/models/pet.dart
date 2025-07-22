// lib/models/pet.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime lastUpdateTime; // 마지막 상태 업데이트 시간 (decay 계산용)
  
  // Decay rates (points per hour) - TESTING: Extreme decay for demonstration
  static const double hungerDecayRate = 1200.0; // TESTING: -10 points every 30 seconds
  static const double happinessDecayRate = 1200.0; // TESTING: -10 points every 30 seconds
  static const double cleanlinessDecayRate = 1200.0; // TESTING: -10 points every 30 seconds

  Pet({
    required this.name,
    required this.experience,
    required this.growthStage,
    this.lastReflectionDate,
    required this.hunger,
    required this.happiness,
    required this.cleanliness,
    this.lastAttendanceDate,
    DateTime? lastUpdateTime,
  }) : lastUpdateTime = lastUpdateTime ?? DateTime.now();

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
    DateTime? lastUpdateTime,
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
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  // Firebase에서 데이터를 가져올 때 사용하는 factory 생성자
  factory Pet.fromFirestore(Map<String, dynamic> data) {
    return Pet(
      name: data['name'] ?? 'My Pet',
      experience: data['experience'] ?? 0,
      growthStage: data['growthStage'] ?? 0,
      lastReflectionDate: data['lastReflectionDate']?.toDate(),
      hunger: data['hunger'] ?? 100,
      happiness: data['happiness'] ?? 100,
      cleanliness: data['cleanliness'] ?? 100,
      lastAttendanceDate: data['lastAttendanceDate']?.toDate(),
      lastUpdateTime: data['lastUpdateTime']?.toDate() ?? DateTime.now(),
    );
  }

  // Firebase에 데이터를 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'experience': experience,
      'growthStage': growthStage,
      'lastReflectionDate': lastReflectionDate != null ? Timestamp.fromDate(lastReflectionDate!) : null,
      'hunger': hunger,
      'happiness': happiness,
      'cleanliness': cleanliness,
      'lastAttendanceDate': lastAttendanceDate != null ? Timestamp.fromDate(lastAttendanceDate!) : null,
      'lastUpdateTime': Timestamp.fromDate(lastUpdateTime),
    };
  }

  // 시간 기반 stat decay 계산 메서드
  Pet applyDecay() {
    final now = DateTime.now();
    final timeDifference = now.difference(lastUpdateTime);
    final hoursElapsed = timeDifference.inSeconds / 3600.0; // Convert seconds to hours directly

    print('DECAY CALC: Time diff = ${timeDifference.inSeconds}s, Hours = $hoursElapsed');
    print('DECAY CALC: Rates - H:$hungerDecayRate Ha:$happinessDecayRate C:$cleanlinessDecayRate');
    
    // 각 stat에 decay 적용 (최소값 0)
    final hungerDecay = hoursElapsed * hungerDecayRate;
    final happinessDecay = hoursElapsed * happinessDecayRate;
    final cleanlinessDecay = hoursElapsed * cleanlinessDecayRate;
    
    print('DECAY CALC: Raw decay - H:$hungerDecay Ha:$happinessDecay C:$cleanlinessDecay');
    
    final newHunger = (hunger - hungerDecay).round().clamp(0, 100);
    final newHappiness = (happiness - happinessDecay).round().clamp(0, 100);
    final newCleanliness = (cleanliness - cleanlinessDecay).round().clamp(0, 100);

    print('DECAY CALC: Final values - H:$newHunger Ha:$newHappiness C:$newCleanliness');

    return copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      cleanliness: newCleanliness,
      lastUpdateTime: now,
    );
  }

  // 낮은 stat 상태 확인
  bool get hasLowStats => hunger < 30 || happiness < 30 || cleanliness < 30;
  bool get hasCriticalStats => hunger < 10 || happiness < 10 || cleanliness < 10;
  
  // Stat 상태별 색상 코드
  static int getStatColor(int statValue) {
    if (statValue >= 70) return 0xFF4CAF50; // Green
    if (statValue >= 40) return 0xFFFF9800; // Orange
    if (statValue >= 20) return 0xFFFF5722; // Red-Orange
    return 0xFFF44336; // Red
  }
}
