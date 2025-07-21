// lib/screens/my_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      default:
        return 'assets/images/egg_state0.png';
    }
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
                color: Colors.white.withOpacity(0.8),
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusScaleBar('경험치', pet.experience, Colors.purple),
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
