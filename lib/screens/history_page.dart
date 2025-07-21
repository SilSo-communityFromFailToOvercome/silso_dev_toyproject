// lib/screens/play_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_notifier.dart'; // reflectionsProvider 임포트
import '../models/reflection.dart'; // Reflection 모델 임포트

class PlayHistoryPage extends ConsumerWidget {
  const PlayHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 로컬 reflectionsProvider에서 회고 기록 목록 가져오기
    final reflections = ref.watch(reflectionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('@dummy_user history'), // 더미 사용자 닉네임
        centerTitle: true,
      ),
      body: reflections.isEmpty
          ? const Center(
              child: Text(
                '아직 작성된 일기가 없어요.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: reflections.length,
              itemBuilder: (context, index) {
                final reflection = reflections[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          reflection.type == 'play'
                              ? 'P'
                              : 'F', // PLAY는 P, FEED는 F로 구분
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ), // 폰트 테마에서 상속
                        ),
                      ),
                    ),
                    title: Text(
                      reflection.question,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${reflection.timestamp.toLocal().year}-${reflection.timestamp.toLocal().month}-${reflection.timestamp.toLocal().day}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () {
                      _showReflectionDetailModal(context, reflection);
                    },
                  ),
                );
              },
            ),
    );
  }

  // 회고 상세 내용 모달 폼
  void _showReflectionDetailModal(BuildContext context, Reflection reflection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reflection.question,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      reflection.answer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '작성일: ${reflection.timestamp.toLocal().year}-${reflection.timestamp.toLocal().month}-${reflection.timestamp.toLocal().day}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
