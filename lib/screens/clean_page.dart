// lib/screens/clean_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/pet_notifier.dart'; // PetNotifierProvider 임포트

class CleanPage extends ConsumerStatefulWidget {
  const CleanPage({super.key});

  @override
  ConsumerState<CleanPage> createState() => _CleanPageState();
}

class _CleanPageState extends ConsumerState<CleanPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // PetNotifier를 읽어와서 performCleanAction 호출
    final petNotifier = ref.read(petNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('청소하기 (출석체크)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // 출석 체크 로직 (장장 담당)
          petNotifier.performCleanAction(); // 로컬 상태 업데이트
          Navigator.pop(context); // 메인 페이지로 돌아가기
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '펫이 깨끗해졌어요! (+5 경험치, 청결도 증가)',
                style: TextStyle(fontFamily: 'PixelFont'),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          color: Colors.black.withOpacity(0.5), // 모달 배경 효과
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent, // Material 위젯의 배경을 투명하게
            child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('출석체크', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay =
                            focusedDay; // update `_focusedDay` here as well
                      });
                      // 로컬 데모에서는 날짜 기록 로직은 생략
                      print('Selected day: $selectedDay');
                    },
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '화면을 탭하여 출석체크!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
