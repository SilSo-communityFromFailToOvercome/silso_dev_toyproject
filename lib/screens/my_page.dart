// lib/screens/my_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_notifier.dart';
import '../models/pet.dart';
import '../constants/app_constants.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/pet_status_widget.dart';
import '../widgets/follow_button_widget.dart';
import './clean_page.dart';
import './play_page.dart';
import './feed_page.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  // growthStage 값에 따라 다른 알/펫 이미지 경로 반환 (곽곽 담당)
  String getPetImagePath(int growthStage) {
    switch (growthStage) {
      case 0:
        return 'assets/images/egg_state0.png'; // 초기 알
      case 1:
        return 'assets/images/egg_state1.png'; // 금 간 알
      case 2:
        return 'assets/images/egg_state2.png'; // 부화 직전 알
      case 3:
        return 'assets/images/egg_state3.png'; // 새끼 펫
      case 4:
        return 'assets/images/egg_state4.png'; // 성장한 펫
      case 5:
        return 'assets/images/egg_state5.png'; // 더 성장한 펫
      case 6:
        return 'assets/images/egg_state6.png'; // 완전히 성장한 펫
      default:
        // 레벨 7 이상은 최고 상태 이미지 사용
        return 'assets/images/egg_state6.png'; // 최고 성장 상태 (레벨 7+)
    }
  }

  // 경험치 계산 헬퍼 메서드 (GAME_DETAIL.md 기준)
  Map<String, int> _calculateExperience(int currentExp, int level) {
    // Formula: XP_Required_for_Next_Level = Current_Level * Base_XP_Multiplier
    const int baseXpMultiplier = 50;
    
    // Level 0는 특별 케이스 (첫 번째 레벨업까지 50 XP)
    int requiredForNextLevel = (level == 0) ? 50 : (level + 1) * baseXpMultiplier;
    
    // 현재 레벨에서의 진행도 계산
    int currentLevelExp = currentExp;
    int percentage = ((currentLevelExp / requiredForNextLevel) * 100).round().clamp(0, 100);
    
    return {
      'current': currentLevelExp,
      'required': requiredForNextLevel,
      'percentage': percentage,
    };
  }

  // 경험치 바 위젯
  Widget _buildExperienceBar(int totalExp, int level) {
    final expData = _calculateExperience(totalExp, level);
    final current = expData['current']!;
    final required = expData['required']!;
    final percentage = expData['percentage']!;
    
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // EXP 텍스트 정보
          Text(
            'EXP: $current / $required',
            style: GoogleFonts.pixelifySans(
              fontSize: 14,
              color: const Color(0xFF8B4513),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          // 경험치 바
          Container(
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF8B4513), width: 2),
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFF5F5DC), // 베이지 배경
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF32CD32), // 라임 그린 (레벨 제한 없음)
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 퍼센티지 표시
          Text(
            '$percentage%',
            style: GoogleFonts.pixelifySans(
              fontSize: 12,
              color: const Color(0xFF8B4513).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // 펫 상태 모달 표시
  void _showStatusModal(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Transparent background
                Container(color: Colors.transparent),
                // Modal positioned at top right
                Positioned(
                  top: 80,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping the modal itself
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.primaryBorder, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pet Status',
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryBorder,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppConstants.primaryBorder,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PetStatusWidget(
                            label: '배고픔',
                            value: pet.hunger,
                            color: AppConstants.hungerColor,
                          ),
                          PetStatusWidget(
                            label: '행복',
                            value: pet.happiness,
                            color: AppConstants.happinessColor,
                          ),
                          PetStatusWidget(
                            label: '청결',
                            value: pet.cleanliness,
                            color: AppConstants.cleanlinessColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petNotifierProvider); // 펫 데이터 watch

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.business, size: 24), // Company logo placeholder
        ),
        title: const Text('MY PAGE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu), // Menubar icon
            onPressed: () {
              // TODO: 메뉴바 기능 구현
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                // 펫 이름 표시 (큰 픽셀 폰트)
                Text(
                  pet.name,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'LV.${pet.growthStage}',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 18,
                    color: const Color(0xFF8B4513).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // 경험치 바 추가
                _buildExperienceBar(pet.experience, pet.growthStage),
                const SizedBox(height: 15),
                // 펫 이미지 표시 (곽곽 담당)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: Image.asset(
                    getPetImagePath(pet.growthStage),
                    key: ValueKey(pet.growthStage),
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                ActionButtonRow(
                  onCleanPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CleanPage(),
                      ),
                    );
                  },
                  onPlayPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayPage(),
                      ),
                    );
                  },
                  onFeedPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Follow Feature Button Section
                const FollowButtonWidget(),
                
                const SizedBox(height: 80), // Extra space for bottom navigation
                  ],
                ),
              ),
            ),
          ),
          // 펫 상태 버튼 (우측 상단)
          Positioned(
            top: 20,
            right: 20,
            child: Stack(
              children: [
                FloatingActionButton(
                  onPressed: () => _showStatusModal(context, pet),
                  backgroundColor: Colors.white,
                  foregroundColor: AppConstants.primaryBorder,
                  elevation: 4,
                  mini: true,
                  child: const Icon(Icons.pets, size: 20),
                ),
                // Status warning indicator
                if (pet.hasCriticalStats)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Icon(
                        Icons.priority_high,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (pet.hasLowStats)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Page'),
        ],
        currentIndex: 2, // My Page 선택된 상태
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          // TODO: 네비게이션 바 기능 구현
        },
      ),
    );
  }

}
