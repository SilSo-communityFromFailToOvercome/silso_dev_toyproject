import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_notifier.dart';
import 'my_page.dart';

class PetNamingScreen extends ConsumerStatefulWidget {
  const PetNamingScreen({super.key});

  @override
  ConsumerState<PetNamingScreen> createState() => _PetNamingScreenState();
}

class _PetNamingScreenState extends ConsumerState<PetNamingScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePetName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('펫 이름을 입력해주세요!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update the pet state with new name
      ref.read(petNotifierProvider.notifier).updatePetName(name);
      
      // Navigate to MyPage
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyPageScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // 베이지 배경
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                '🥚 펫 이름 짓기',
                style: GoogleFonts.pixelifySans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4513),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Subtitle
              Text(
                '새로운 친구의 이름을 지어주세요!',
                style: GoogleFonts.pixelifySans(
                  fontSize: 18,
                  color: const Color(0xFF8B4513),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Pet egg image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: const Icon(
                  Icons.egg,
                  size: 80,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 40),
              
              // Name input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameController,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 18,
                    color: const Color(0xFF8B4513),
                  ),
                  decoration: InputDecoration(
                    hintText: '펫 이름 입력',
                    hintStyle: GoogleFonts.pixelifySans(
                      fontSize: 18,
                      color: const Color(0xFF8B4513).withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  maxLength: 20,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePetName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '완료',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}