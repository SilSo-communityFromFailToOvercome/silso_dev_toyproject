// lib/screens/my_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_notifier.dart'; // PetNotifierProvider 임포트
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

  // 펫 상태 스케일 바 위젯
  Widget _buildStatusScaleBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $value%',
            style: const TextStyle(fontSize: 14),
          ), // 폰트 테마에서 상속
          const SizedBox(height: 4),
          Container(
            height: 10,
            width: 100, // 스케일 바 고정 너비
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              color: Colors.grey[300],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(width: value / 100 * 100, color: color),
            ),
          ),
        ],
      ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      'CLEAN',
                      Icons.cleaning_services,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CleanPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      context,
                      'PLAY',
                      Icons.videogame_asset,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlayPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(context, 'FEED', Icons.restaurant, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedPage(),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          // 펫 상태 스케일 바 (우측 상단)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusScaleBar('배고픔', pet.hunger, Colors.orange),
                  _buildStatusScaleBar('행복', pet.happiness, Colors.pink),
                  _buildStatusScaleBar('청결', pet.cleanliness, Colors.lightBlue),
                ],
              ),
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

  // 액션 버튼 위젯
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
