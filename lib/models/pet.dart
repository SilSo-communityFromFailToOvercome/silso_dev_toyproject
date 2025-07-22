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
  
  // Follow Button Timer Fields
  final DateTime? followButtonLastActivated; // 마지막 Follow 버튼 활성화 시간
  final bool followButtonIsActive; // Follow 버튼 현재 활성화 상태
  
  // Pet Animation System Fields
  /// Tracks the last completed task for triggering appropriate animations
  /// Values: 'clean', 'play', 'feed', or null
  final String? lastCompletedTask; // 마지막 완료된 작업 타입 (애니메이션 트리거용)
  
  /// Timestamp when the animation should be triggered
  /// Used to determine if animation should play when returning to MyPage
  final DateTime? animationTriggerTime; // 애니메이션 트리거 시간
  
  // Decay rates (points per hour) - TESTING: Extreme decay for demonstration
  static const double hungerDecayRate = 1200.0; // TESTING: -10 points every 30 seconds
  static const double happinessDecayRate = 1200.0; // TESTING: -10 points every 30 seconds
  static const double cleanlinessDecayRate = 1200.0; // TESTING: -10 points every 30 seconds
  
  // Follow Button Timer Constants
  /// Duration variable for follow button active state (in seconds)
  /// This controls how long the button remains active and clickable.
  /// During this period, users can press the button and the countdown shows remaining time.
  static const int followButtonActiveDurationSeconds = 15; // 15초 활성화 상태 (테스트용)
  
  /// Duration for follow button inactive state (in seconds)
  /// This controls how long the button remains disabled after being clicked.
  /// During this period, the button is grayed out and shows countdown to reactivation.
  static const int followButtonInactiveDurationSeconds = 30; // 30초 비활성화 상태 (테스트용)

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
    this.followButtonLastActivated,
    this.followButtonIsActive = false,
    this.lastCompletedTask,
    this.animationTriggerTime,
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
    DateTime? followButtonLastActivated,
    bool? followButtonIsActive,
    String? lastCompletedTask,
    DateTime? animationTriggerTime,
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
      followButtonLastActivated: followButtonLastActivated ?? this.followButtonLastActivated,
      followButtonIsActive: followButtonIsActive ?? this.followButtonIsActive,
      lastCompletedTask: lastCompletedTask ?? this.lastCompletedTask,
      animationTriggerTime: animationTriggerTime ?? this.animationTriggerTime,
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
      followButtonLastActivated: data['followButtonLastActivated']?.toDate(),
      followButtonIsActive: data['followButtonIsActive'] ?? false,
      lastCompletedTask: data['lastCompletedTask'],
      animationTriggerTime: data['animationTriggerTime']?.toDate(),
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
      'followButtonLastActivated': followButtonLastActivated != null ? Timestamp.fromDate(followButtonLastActivated!) : null,
      'followButtonIsActive': followButtonIsActive,
      'lastCompletedTask': lastCompletedTask,
      'animationTriggerTime': animationTriggerTime != null ? Timestamp.fromDate(animationTriggerTime!) : null,
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

  /// Follow Button Timer Logic Methods
  /// 
  /// Real-time countdown timer implementation for the follow button feature.
  /// The timer operates on a precise cycle using DateTime calculations:
  /// 
  /// CYCLE STRUCTURE:
  /// - ACTIVE state: followButtonActiveDurationSeconds (button enabled, countdown to deactivation)
  /// - INACTIVE state: followButtonInactiveDurationSeconds (button disabled, countdown to reactivation)
  /// - Total cycle: followButtonActiveDurationSeconds + followButtonInactiveDurationSeconds
  /// 
  /// REAL-TIME UPDATES:
  /// - Uses DateTime.now() for precise millisecond calculations
  /// - Updates triggered by external periodic Timer (in PetNotifier, every 30 seconds)
  /// - Can also be called directly for immediate UI updates
  /// - State persists across app restarts via Firebase (followButtonLastActivated timestamp)
  
  /// Calculate the current follow button state and remaining time with millisecond precision
  /// 
  /// HOW IT WORKS:
  /// 1. Gets current time using DateTime.now()
  /// 2. Calculates time difference from last activation with millisecond precision
  /// 3. Uses modular arithmetic to determine position in current cycle
  /// 4. Returns precise remaining time including milliseconds
  /// 
  /// Returns a map with keys:
  /// - 'isActive': boolean indicating if button is currently active
  /// - 'remainingMilliseconds': int with precise remaining time in milliseconds
  /// - 'remainingSeconds': int with remaining seconds (for backward compatibility)
  /// - 'totalCycleSeconds': int with total cycle duration
  Map<String, dynamic> getFollowButtonState() {
    final now = DateTime.now();
    
    // If never activated before, start in active state with full duration
    if (followButtonLastActivated == null) {
      final remainingMs = followButtonActiveDurationSeconds * 1000;
      return {
        'isActive': true,
        'remainingMilliseconds': remainingMs,
        'remainingSeconds': followButtonActiveDurationSeconds,
        'totalCycleSeconds': (followButtonActiveDurationSeconds + followButtonInactiveDurationSeconds),
      };
    }
    
    // Calculate time elapsed since last activation with millisecond precision
    final timeSinceActivation = now.difference(followButtonLastActivated!);
    final totalCycleDurationMs = (followButtonActiveDurationSeconds + followButtonInactiveDurationSeconds) * 1000;
    final activeDurationMs = followButtonActiveDurationSeconds * 1000;
    
    // Calculate position in current cycle using milliseconds for precision
    final cycleTimeElapsedMs = timeSinceActivation.inMilliseconds % totalCycleDurationMs;
    
    if (cycleTimeElapsedMs < activeDurationMs) {
      // Currently in ACTIVE phase - button is clickable
      // Calculate remaining time until deactivation
      final remainingActiveTimeMs = activeDurationMs - cycleTimeElapsedMs;
      final remainingActiveTimeSeconds = (remainingActiveTimeMs / 1000).ceil();
      
      return {
        'isActive': true,
        'remainingMilliseconds': remainingActiveTimeMs,
        'remainingSeconds': remainingActiveTimeSeconds,
        'totalCycleSeconds': (followButtonActiveDurationSeconds + followButtonInactiveDurationSeconds),
      };
    } else {
      // Currently in INACTIVE phase - button is disabled
      // Calculate remaining time until reactivation
      final remainingInactiveTimeMs = totalCycleDurationMs - cycleTimeElapsedMs;
      final remainingInactiveTimeSeconds = (remainingInactiveTimeMs / 1000).ceil();
      
      return {
        'isActive': false,
        'remainingMilliseconds': remainingInactiveTimeMs,
        'remainingSeconds': remainingInactiveTimeSeconds,
        'totalCycleSeconds': (followButtonActiveDurationSeconds + followButtonInactiveDurationSeconds),
      };
    }
  }
  
  /// Format remaining time in the required "sec : millisec" format
  /// 
  /// HOW getFormattedRemainingTime() WORKS:
  /// 1. Calls getFollowButtonState() to get precise remaining milliseconds
  /// 2. Extracts total milliseconds from the state map
  /// 3. Converts to seconds and remaining milliseconds using integer division and modulo
  /// 4. Formats as "sec : milli_sec" string with proper padding
  /// 
  /// EXAMPLE OUTPUT:
  /// - "12 : 450" = 12 seconds and 450 milliseconds remaining
  /// - "03 : 025" = 3 seconds and 25 milliseconds remaining  
  /// - "00 : 999" = 0 seconds and 999 milliseconds remaining
  /// 
  /// REAL-TIME UPDATES:
  /// This method provides real-time countdown by:
  /// - Using DateTime.now() internally via getFollowButtonState()
  /// - Calculating precise millisecond differences
  /// - Returning formatted string that changes every millisecond when called repeatedly
  /// - UI components can call this frequently (e.g., using Timer.periodic) for smooth countdown
  /// 
  /// USAGE IN UI:
  /// The UI should call this method periodically (e.g., every 100ms) to show smooth countdown.
  /// The followButtonActiveDurationSeconds variable controls the total countdown duration.
  String getFormattedRemainingTime() {
    final state = getFollowButtonState();
    final totalMilliseconds = state['remainingMilliseconds'] as int;
    
    // Extract seconds and milliseconds using integer arithmetic
    final seconds = totalMilliseconds ~/ 1000; // Integer division for whole seconds
    final milliseconds = totalMilliseconds % 1000; // Modulo for remaining milliseconds
    
    // Format as "sec : milli_sec" with proper zero padding
    // Seconds: padded to 2 digits (e.g., "03", "12")
    // Milliseconds: padded to 3 digits (e.g., "450", "025", "999")
    return '${seconds.toString().padLeft(2, '0')} : ${milliseconds.toString().padLeft(3, '0')}';
  }
  
  /// Get appropriate button text based on current state
  String getFollowButtonText() {
    final state = getFollowButtonState();
    return state['isActive'] ? '✅ Following' : '⏳ Follow Available In';
  }
  
  /// Get appropriate timer display text with real-time countdown
  /// 
  /// Returns user-friendly display text combining button state with precise countdown.
  /// Uses getFormattedRemainingTime() internally to show "sec : millisec" format.
  /// 
  /// EXAMPLE OUTPUT:
  /// - ACTIVE: "Active for 12 : 450 remaining"
  /// - INACTIVE: "Available in 08 : 125"
  String getTimerDisplayText() {
    final state = getFollowButtonState();
    final formattedTime = getFormattedRemainingTime();
    return state['isActive'] 
        ? 'Active for $formattedTime remaining'
        : 'Available in $formattedTime';
  }
  
  /// Pet Animation System Helper Methods
  /// 
  /// These methods support the task completion animation system that triggers
  /// contextual pet animations when users return to MyPage after completing tasks.
  
  /// Check if an animation should be triggered based on recent task completion
  /// Returns true if there's a pending animation within the last 10 seconds
  bool get shouldShowTaskAnimation {
    if (lastCompletedTask == null || animationTriggerTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    final timeSinceAnimation = now.difference(animationTriggerTime!);
    
    // Show animation if triggered within last 10 seconds
    return timeSinceAnimation.inSeconds <= 10;
  }
  
  /// Get the animation type based on the last completed task
  /// Returns animation identifier for the UI to determine which animation to play
  String? get currentAnimationType {
    if (!shouldShowTaskAnimation) return null;
    
    switch (lastCompletedTask) {
      case 'clean':
        return 'cleaning'; // Cleaning/attendance animation
      case 'play':
        return 'playing'; // Playful/happy animation  
      case 'feed':
        return 'eating'; // Feeding/eating animation
      default:
        return null;
    }
  }
  
  /// Clear animation state after animation has been shown
  /// Should be called after the animation completes to prevent re-triggering
  Pet clearAnimationState() {
    return copyWith(
      lastCompletedTask: null,
      animationTriggerTime: null,
    );
  }
  
  // Stat 상태별 색상 코드
  static int getStatColor(int statValue) {
    if (statValue >= 70) return 0xFF4CAF50; // Green
    if (statValue >= 40) return 0xFFFF9800; // Orange
    if (statValue >= 20) return 0xFFFF5722; // Red-Orange
    return 0xFFF44336; // Red
  }
}
