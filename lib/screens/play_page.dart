// lib/screens/play_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_notifier.dart'; // PetNotifierProvider 임포트
import './history_page.dart';

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
  final TextEditingController _textController = TextEditingController();
  final String _reflectionQuestion = "오늘 하루는 어땠어?"; // PLAY 질문

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petNotifierProvider); // 펫 정보 가져오기

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('일기쓰기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history), // 기록 히스토리 아이콘
            onPressed: () {
              // PLAY 및 FEED 페이지 모두 PlayHistoryPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlayHistoryPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: 메뉴바 기능 구현
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/egg_state${pet.growthStage}.png', // 현재 펫 이미지
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _reflectionQuestion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _showTextInputModal(context);
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: _textController.text.isEmpty
                    ? Text(
                        '탭하여 일기를 작성하세요...',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      )
                    : Text(
                        _textController.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 입력 모달 폼
  void _showTextInputModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _reflectionQuestion,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  maxLines: 10,
                  minLines: 5,
                  decoration: InputDecoration(
                    hintText: '오늘 하루 어땠는지 솔직하게 작성해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      // 플레이 액션 수행 (장장 담당)
                      ref
                          .read(petNotifierProvider.notifier)
                          .performPlayAction(
                            _textController.text,
                            _reflectionQuestion,
                          );
                      Navigator.pop(context); // 모달 닫기
                      Navigator.pop(context); // 메인 페이지로 돌아가기
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '일기 기록 완료! (+10 경험치, 행복도 증가)',
                            style: TextStyle(fontFamily: 'PixelFont'),
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('내용을 작성해주세요!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '완료하기',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
