import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_notifier.dart';
import 'my_page.dart';
import 'pet_naming_screen.dart';

class UserChecker extends ConsumerWidget {
  const UserChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userUid = ref.watch(userUidProvider);
    
    if (userUid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder(
      future: ref.read(petServiceProvider).getPet(userUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            ),
          );
        }
        
        final pet = snapshot.data;
        
        // If pet doesn't exist or has default name, show naming screen
        if (pet == null || pet.name == '회고의 알') {
          return const PetNamingScreen();
        }
        
        // Pet exists with custom name, show main page
        return const MyPageScreen();
      },
    );
  }
}