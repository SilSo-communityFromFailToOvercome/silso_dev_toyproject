// lib/screens/feed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_notifier.dart'; // PetNotifierProvider 임포트
import './history_page.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedQuestion = '';

  final List<String> _feedQuestions = [
    "Q1. 오늘 하루 사소한 실수는?",
    "Q2. 계획대로 되지 않은 일은?",
    "Q3. (직장/학교) 업무에서 아쉬웠던 부분은?",
    "Q4. 건강 관리하면서 아쉬웠던 부분은?",
    "Q5. 인간관계에서 아쉬웠던 실수는?",
  ];

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
        title: const Text('주제 회고하기'),
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
                  color: Colors.lightGreen[100],
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '오늘 하루 돌아볼까요? 생각 나눌 주제 하나를 작성해보아요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _feedQuestions.length,
                itemBuilder: (context, index) {
                  final question = _feedQuestions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedQuestion == question
                            ? Colors.blue
                            : Colors.grey,
                        width: _selectedQuestion == question ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        question,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedQuestion = question;
                        });
                        _showTextInputModal(context, question);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 입력 모달 폼 (FEED 용)
  void _showTextInputModal(BuildContext context, String question) {
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
                  question,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  maxLines: 10,
                  minLines: 5,
                  decoration: InputDecoration(
                    hintText: '이 질문에 대한 생각을 작성해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      // 피드 액션 수행 (장장 담당)
                      ref
                          .read(petNotifierProvider.notifier)
                          .performFeedAction(_textController.text, question);
                      Navigator.pop(context); // 모달 닫기
                      Navigator.pop(context); // 메인 페이지로 돌아가기
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '회고 기록 완료! (+15 경험치, 배고픔 증가)',
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
