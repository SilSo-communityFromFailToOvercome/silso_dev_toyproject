// lib/providers/pet_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // UUID 생성을 위해 추가
import '../models/pet.dart';
import '../models/reflection.dart';

// Uuid 인스턴스 생성
final uuid = Uuid();

// 펫 상태를 관리하는 StateNotifier
class PetNotifier extends StateNotifier<Pet> {
  PetNotifier() : super(_initialPet); // 초기 펫 상태 설정

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

  // 펫 상태 업데이트 공통 로직
  void _updatePet(Pet updatedPet) {
    // 성장 단계 계산
    int newGrowthStage = updatedPet.growthStage;
    if (updatedPet.experience >= 20 && updatedPet.growthStage < 1) {
      newGrowthStage = 1;
    } else if (updatedPet.experience >= 40 && updatedPet.growthStage < 2) {
      newGrowthStage = 2;
    } else if (updatedPet.experience >= 60 && updatedPet.growthStage < 3) {
      newGrowthStage = 3;
    }
    state = updatedPet.copyWith(growthStage: newGrowthStage);
    print(
      '펫 업데이트 완료: EXP=${state.experience}, Stage=${state.growthStage}, Hunger=${state.hunger}, Happiness=${state.happiness}, Cleanliness=${state.cleanliness}',
    );
  }

  // CLEAN 액션 (출석체크)
  void performCleanAction() {
    final today = DateTime.now();

    // 오늘 이미 출석했는지 확인
    if (state.lastAttendanceDate != null &&
        state.lastAttendanceDate!.year == today.year &&
        state.lastAttendanceDate!.month == today.month &&
        state.lastAttendanceDate!.day == today.day) {
      print('오늘 이미 출석체크를 완료했습니다.');
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
}

// 펫 상태를 제공하는 StateNotifierProvider
final petNotifierProvider = StateNotifierProvider<PetNotifier, Pet>((ref) {
  return PetNotifier();
});

// 회고 기록 목록을 제공하는 Provider (로컬에서 관리)
final reflectionsProvider = Provider<List<Reflection>>((ref) {
  // PetNotifier에서 관리하는 _reflections 목록을 반환
  final petNotifier = ref.watch(petNotifierProvider.notifier);
  // 최신 기록부터 보여주기 위해 정렬
  return [...petNotifier.reflections]
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
});

// 더미 사용자 UID (로컬 데모용) - 실제 사용되지 않지만, 기존 코드 구조 유지를 위해 남겨둠
final userUidProvider = Provider<String>((ref) => 'dummy_user_id_123');
