// lib/providers/pet_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // UUID 생성을 위해 추가
import '../models/pet.dart';
import '../models/reflection.dart';
import '../services/pet_service.dart';
import '../screens/auth/auth_wrapper.dart';

// Uuid 인스턴스 생성
final uuid = Uuid();

// PetService 인스턴스 제공
final petServiceProvider = Provider<PetService>((ref) => PetService());

// 펫 상태를 관리하는 StateNotifier
class PetNotifier extends StateNotifier<Pet> {
  final PetService _petService;
  final String? _userId;
  
  PetNotifier(this._petService, this._userId) : super(_initialPet) {
    _loadPetData(); // 초기화 시 Firebase에서 펫 데이터 로드
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

  // 로컬 회고 기록 목록 (더미 데이터)
  final List<Reflection> _reflections = [];

  // 외부에서 회고 기록에 접근할 수 있도록 getter 제공
  List<Reflection> get reflections => _reflections;

  // Firebase에서 펫 데이터 로드
  Future<void> _loadPetData() async {
    if (_userId == null) return;
    
    try {
      final pet = await _petService.getPet(_userId);
      if (pet != null) {
        state = pet;
      } else {
        // 펫이 존재하지 않으면 새로 생성
        await _petService.createPet(_userId, _initialPet);
      }
    } catch (e) {
      // 에러 발생 시 로컬 상태 유지 (디버그용 출력 제거)
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
    
    state = updatedPet.copyWith(
      growthStage: newLevel,
      experience: newExp,
    );
    
    // Firebase에 변경사항 저장
    _savePetData();
  }

  // CLEAN 액션 (출석체크)
  void performCleanAction() {
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
  void performPlayAction(String answer, String question) {
    _updatePet(
      state.copyWith(
        experience: state.experience + 10, // +10 경험치
        happiness: (state.happiness + 20).clamp(0, 100), // 행복도 +20 (최대 100)
        lastReflectionDate: DateTime.now(),
      ),
    );
    // 회고 기록 저장
    _reflections.add(
      Reflection(
        id: uuid.v4(), // 고유 ID 생성
        type: 'play',
        question: question,
        answer: answer,
        timestamp: DateTime.now(),
      ),
    );
  }

  // FEED 액션 (주제 회고)
  void performFeedAction(String answer, String question) {
    _updatePet(
      state.copyWith(
        experience: state.experience + 15, // +15 경험치
        hunger: (state.hunger + 20).clamp(0, 100), // 배고픔 +20 (최대 100)
        lastReflectionDate: DateTime.now(),
      ),
    );
    // 회고 기록 저장
    _reflections.add(
      Reflection(
        id: uuid.v4(), // 고유 ID 생성
        type: 'feed',
        question: question,
        answer: answer,
        timestamp: DateTime.now(),
      ),
    );
  }

  // 펫 이름 업데이트 메서드
  void updatePetName(String newName) {
    _updatePet(state.copyWith(name: newName));
  }
}

// 펫 상태를 제공하는 StateNotifierProvider (Firebase 통합)
final petNotifierProvider = StateNotifierProvider<PetNotifier, Pet>((ref) {
  final petService = ref.watch(petServiceProvider);
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) {
      return PetNotifier(petService, user?.uid);
    },
    loading: () => PetNotifier(petService, null),
    error: (error, stack) => PetNotifier(petService, null),
  );
});

// 회고 기록 목록을 제공하는 Provider (로컬에서 관리)
final reflectionsProvider = Provider<List<Reflection>>((ref) {
  // PetNotifier에서 관리하는 _reflections 목록을 반환
  final petNotifier = ref.watch(petNotifierProvider.notifier);
  // 최신 기록부터 보여주기 위해 정렬
  return [...petNotifier.reflections]
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
