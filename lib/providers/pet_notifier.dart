// lib/providers/pet_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // UUID 생성을 위해 추가
import '../models/pet.dart';
import '../models/reflection.dart';
import '../services/pet_service.dart';
import '../services/reflection_service.dart';
import '../screens/auth/auth_wrapper.dart';

// Uuid 인스턴스 생성
final uuid = Uuid();

// PetService 인스턴스 제공
final petServiceProvider = Provider<PetService>((ref) => PetService());

// ReflectionService 인스턴스 제공
final reflectionServiceProvider = Provider<ReflectionService>((ref) => ReflectionService());

// 펫 상태를 관리하는 StateNotifier
class PetNotifier extends StateNotifier<Pet> {
  final PetService _petService;
  final ReflectionService _reflectionService;
  final String? _userId;
  Timer? _decayTimer;
  
  PetNotifier(this._petService, this._reflectionService, this._userId) : super(_initialPet) {
    _loadPetData(); // 초기화 시 Firebase에서 펫 데이터 로드
    _startDecayTimer(); // decay 타이머 시작
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    super.dispose();
  }

  // 초기 펫 상태 (더미 데이터)
  static final Pet _initialPet = Pet(
    name: '회고의 알',
    experience: 0,
    growthStage: 0,
    hunger: 100,
    happiness: 100,
    cleanliness: 100,
    lastReflectionDate: null,
    lastAttendanceDate: null,
  );


  // Firebase에서 펫 데이터 로드
  Future<void> _loadPetData() async {
    if (_userId == null) return;
    
    try {
      final pet = await _petService.getPet(_userId);
      if (pet != null) {
        // 로드된 펫에 decay 적용
        final decayedPet = pet.applyDecay();
        state = decayedPet;
        
        // decay가 적용되었다면 Firebase에 저장
        if (pet != decayedPet) {
          _savePetData();
        }
      } else {
        // 펫이 존재하지 않으면 새로 생성
        await _petService.createPet(_userId, _initialPet);
      }
    } catch (e) {
      // 에러 발생 시 로컬 상태 유지 (디버그용 출력 제거)
    }
  }

  // Decay 타이머 시작 (TESTING: 30초마다 실행)
  void _startDecayTimer() {
    _decayTimer?.cancel();
    _decayTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _applyRealtimeDecay();
    });
  }

  // 실시간 decay 적용
  void _applyRealtimeDecay() {
    print('DECAY TIMER: Applying decay at ${DateTime.now()}');
    final oldStats = 'H:${state.hunger} Ha:${state.happiness} C:${state.cleanliness}';
    final decayedPet = state.applyDecay();
    final newStats = 'H:${decayedPet.hunger} Ha:${decayedPet.happiness} C:${decayedPet.cleanliness}';
    print('DECAY: $oldStats -> $newStats');
    
    // Also update follow button state during timer tick
    final buttonState = decayedPet.getFollowButtonState();
    final updatedPet = decayedPet.copyWith(
      followButtonIsActive: buttonState['isActive'],
    );
    
    if (state != updatedPet) {
      state = updatedPet;
      _savePetData();
      print('DECAY: State updated! Follow button active: ${buttonState['isActive']}');
    } else {
      print('DECAY: No change detected');
    }
  }

  // 수동으로 decay 적용 (액션 전에 호출)
  void _ensureDecayApplied() {
    final decayedPet = state.applyDecay();
    if (state != decayedPet) {
      state = decayedPet;
      _savePetData();
    }
  }

  // Firebase에 펫 데이터 저장
  Future<void> _savePetData() async {
    if (_userId == null) return;
    
    try {
      await _petService.updatePet(_userId, state);
    } catch (e) {
      // 에러 발생해도 로컬 상태는 업데이트 유지 (디버그용 출력 제거)
    }
  }

  // 레벨업 계산 (GAME_DETAIL.md 기준)
  Map<String, int> _calculateLevelUp(int currentExp, int currentLevel) {
    const int baseXpMultiplier = 50;
    int exp = currentExp;
    int level = currentLevel;
    
    // 연속 레벨업 처리 (여러 레벨을 한 번에 올릴 수 있음)
    while (true) {
      // Level 0는 특별 케이스 (첫 번째 레벨업까지 50 XP)
      int requiredForNextLevel = (level == 0) ? 50 : (level + 1) * baseXpMultiplier;
      
      if (exp >= requiredForNextLevel) {
        // 레벨업! 경험치 리셋하고 잉여 경험치 이월
        exp = exp - requiredForNextLevel;
        level++;
      } else {
        // 더 이상 레벨업 불가
        break;
      }
    }
    
    return {
      'level': level,
      'experience': exp,
    };
  }

  // 펫 상태 업데이트 공통 로직
  void _updatePet(Pet updatedPet) {
    // 새로운 레벨링 시스템 적용
    final levelData = _calculateLevelUp(updatedPet.experience, updatedPet.growthStage);
    final newLevel = levelData['level']!;
    final newExp = levelData['experience']!;
    
    // lastUpdateTime을 현재 시간으로 업데이트
    state = updatedPet.copyWith(
      growthStage: newLevel,
      experience: newExp,
      lastUpdateTime: DateTime.now(),
    );
    
    // Firebase에 변경사항 저장
    _savePetData();
  }

  // CLEAN 액션 (출석체크)
  void performCleanAction() {
    // 액션 전에 decay 적용
    _ensureDecayApplied();
    
    final today = DateTime.now();

    // 오늘 이미 출석했는지 확인
    if (state.lastAttendanceDate != null &&
        state.lastAttendanceDate!.year == today.year &&
        state.lastAttendanceDate!.month == today.month &&
        state.lastAttendanceDate!.day == today.day) {
      return; // 이미 출석했으면 아무것도 하지 않음
    }

    _updatePet(
      state.copyWith(
        experience: state.experience + 5, // +5 경험치
        cleanliness: (state.cleanliness + 20).clamp(0, 100), // 청결도 +20 (최대 100)
        lastAttendanceDate: today, // 마지막 출석 날짜 기록
      ),
    );
  }

  // PLAY 액션 (일기 쓰기)
  Future<void> performPlayAction(String answer, String question) async {
    // 액션 전에 decay 적용
    _ensureDecayApplied();
    
    _updatePet(
      state.copyWith(
        experience: state.experience + 10, // +10 경험치
        happiness: (state.happiness + 20).clamp(0, 100), // 행복도 +20 (최대 100)
        lastReflectionDate: DateTime.now(),
      ),
    );
    
    // 회고 기록을 Firebase에 저장
    if (_userId != null) {
      try {
        final reflection = Reflection(
          id: uuid.v4(), // 고유 ID 생성
          type: 'play',
          question: question,
          answer: answer,
          timestamp: DateTime.now(),
        );
        await _reflectionService.addReflection(_userId, reflection);
      } catch (e) {
        // 에러 발생해도 펫 상태는 업데이트 유지
      }
    }
  }

  // FEED 액션 (주제 회고)
  Future<void> performFeedAction(String answer, String question) async {
    // 액션 전에 decay 적용
    _ensureDecayApplied();
    
    _updatePet(
      state.copyWith(
        experience: state.experience + 15, // +15 경험치
        hunger: (state.hunger + 20).clamp(0, 100), // 배고픔 +20 (최대 100)
        lastReflectionDate: DateTime.now(),
      ),
    );
    
    // 회고 기록을 Firebase에 저장
    if (_userId != null) {
      try {
        final reflection = Reflection(
          id: uuid.v4(), // 고유 ID 생성
          type: 'feed',
          question: question,
          answer: answer,
          timestamp: DateTime.now(),
        );
        await _reflectionService.addReflection(_userId, reflection);
      } catch (e) {
        // 에러 발생해도 펫 상태는 업데이트 유지
      }
    }
  }

  /// FOLLOW BUTTON ACTION
  /// 
  /// Handles the follow button press action.
  /// The button can only be pressed when it's in the active state.
  /// When pressed, it starts/resets the timer cycle and updates the activation time.
  void performFollowAction() {
    // 액션 전에 decay 적용
    _ensureDecayApplied();
    
    // Check if button is currently active
    final buttonState = state.getFollowButtonState();
    if (!buttonState['isActive']) {
      return; // Button is not active, ignore press
    }
    
    // Button is active - process the follow action
    _updatePet(
      state.copyWith(
        // Update follow button state - start new cycle
        followButtonLastActivated: DateTime.now(),
        followButtonIsActive: true,
      ),
    );
  }

  /// Update follow button state based on timer
  /// This method is called by the real-time timer to update the button state
  void updateFollowButtonState() {
    final buttonState = state.getFollowButtonState();
    final isCurrentlyActive = buttonState['isActive'];
    
    // Update the state if it has changed
    if (state.followButtonIsActive != isCurrentlyActive) {
      state = state.copyWith(
        followButtonIsActive: isCurrentlyActive,
      );
      _savePetData();
    }
  }

  // 펫 이름 업데이트 메서드
  void updatePetName(String newName) {
    _updatePet(state.copyWith(name: newName));
  }
}

// 펫 상태를 제공하는 StateNotifierProvider (Firebase 통합)
final petNotifierProvider = StateNotifierProvider<PetNotifier, Pet>((ref) {
  final petService = ref.watch(petServiceProvider);
  final reflectionService = ref.watch(reflectionServiceProvider);
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) {
      return PetNotifier(petService, reflectionService, user?.uid);
    },
    loading: () => PetNotifier(petService, reflectionService, null),
    error: (error, stack) => PetNotifier(petService, reflectionService, null),
  );
});

// 회고 기록 목록을 제공하는 StreamProvider (Firebase에서 관리)
final reflectionsProvider = StreamProvider<List<Reflection>>((ref) {
  final reflectionService = ref.watch(reflectionServiceProvider);
  final userId = ref.watch(userUidProvider);
  
  if (userId == null) {
    return Stream.value(<Reflection>[]);
  }
  
  return reflectionService.getReflectionsStream(userId);
});

// 사용자 UID 제공 (Firebase Auth에서 가져옴)
final userUidProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (error, stack) => null,
  );
});
