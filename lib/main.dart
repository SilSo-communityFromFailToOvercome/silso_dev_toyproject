// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts 임포트
import 'screens/my_page.dart'; // MyPageScreen 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MY PAGE 데모 (로컬)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // 기존 fontFamily 대신 GoogleFonts.pixelifySansTextTheme() 사용
        textTheme:
            GoogleFonts.pixelifySansTextTheme(
              Theme.of(context).textTheme, // 기존 테마를 기반으로 적용
            ).copyWith(
              // 필요에 따라 특정 TextTheme 속성만 오버라이드
              bodyLarge: const TextStyle(fontSize: 20, color: Colors.black),
              bodyMedium: const TextStyle(fontSize: 16, color: Colors.black),
              labelLarge: const TextStyle(fontSize: 18, color: Colors.white),
              titleLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          titleTextStyle: GoogleFonts.pixelifySans(
            // AppBar 제목에만 폰트 적용
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      home: const MyPageScreen(),
    );
  }
}
