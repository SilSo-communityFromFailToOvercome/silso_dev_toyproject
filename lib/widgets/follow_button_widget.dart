// lib/widgets/follow_button_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pet_notifier.dart';
import '../models/pet.dart';

/// Follow Button Widget with Real-Time Timer Display
/// 
/// This widget creates a testButton that toggles between active and inactive states
/// based on a predefined timer cycle. It displays dynamic countdown text with millisecond precision.
/// 
/// Features:
/// - ACTIVE state (15 sec): Green button, user can press, shows countdown to deactivation
/// - INACTIVE state (30 sec): Gray button, disabled, shows countdown to reactivation
/// - Real-time updates every 100ms for smooth countdown display
/// - Millisecond precision timer showing format "sec : millisec"
/// - Automatic state management and Firebase persistence
class FollowButtonWidget extends ConsumerStatefulWidget {
  const FollowButtonWidget({super.key});

  @override
  ConsumerState<FollowButtonWidget> createState() => _FollowButtonWidgetState();
}

/// StatefulWidget implementation to handle real-time timer updates
/// 
/// REAL-TIME UPDATES IMPLEMENTATION:
/// - Uses Timer.periodic with 100ms interval for smooth countdown
/// - Updates UI state independently of PetNotifier's 30-second timer
/// - Automatically starts/stops timer based on widget lifecycle
/// - Ensures timer is properly disposed to prevent memory leaks
class _FollowButtonWidgetState extends ConsumerState<FollowButtonWidget> {
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Start real-time UI updates for smooth countdown display
    // 100ms interval provides smooth visual updates without excessive CPU usage
    _uiUpdateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Trigger UI rebuild to show updated countdown
      if (mounted) {
        setState(() {
          // State update triggers rebuild with fresh timer values
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up timer to prevent memory leaks
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petNotifierProvider);
    final petNotifier = ref.read(petNotifierProvider.notifier);
    
    return _buildFollowButtonSection(context, pet, petNotifier);
  }

  /// Main follow button section with button and timer display
  Widget _buildFollowButtonSection(BuildContext context, Pet pet, PetNotifier petNotifier) {
    final buttonState = pet.getFollowButtonState();
    final isActive = buttonState['isActive'] as bool;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B4513),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Follow Button
          _buildFollowButton(context, pet, petNotifier, isActive),
          
          const SizedBox(height: 12),
          
          // Timer Display Text
          _buildTimerDisplay(pet),
        ],
      ),
    );
  }

  /// Follow Button - Main Interactive Element
  /// 
  /// Active State:
  /// - Green background color
  /// - Enabled for user interaction
  /// - Shows "✅ Following" text
  /// - OnPressed triggers performFollowAction()
  /// 
  /// Inactive State:
  /// - Gray background color  
  /// - Disabled for user interaction
  /// - Shows "⏳ Follow Available In" text
  /// - OnPressed is null (button inactive)
  Widget _buildFollowButton(BuildContext context, Pet pet, PetNotifier petNotifier, bool isActive) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isActive ? () {
          // Button is active - user can press it
          petNotifier.performFollowAction();
          
          // Show feedback to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Following activated! Timer reset.',
                style: GoogleFonts.pixelifySans(fontSize: 14),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } : null, // Button is inactive - null disables it
        
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive 
              ? const Color(0xFF4CAF50) // Green when active
              : const Color(0xFF9E9E9E), // Gray when inactive
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF9E9E9E),
          disabledForegroundColor: Colors.white.withOpacity(0.6),
          elevation: isActive ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        child: Text(
          pet.getFollowButtonText(), // Dynamic text based on state
          style: GoogleFonts.pixelifySans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Timer Display - Shows Real-Time Remaining Time with Millisecond Precision
  /// 
  /// The timer text updates based on current button state with millisecond precision:
  /// - ACTIVE: "Active for 12 : 450 remaining" (countdown to deactivation)
  /// - INACTIVE: "Available in 08 : 125" (countdown to reactivation)
  /// 
  /// REAL-TIME UPDATES:
  /// - Updates every 100ms via Timer.periodic in widget state
  /// - Shows smooth countdown with millisecond precision
  /// - Format: "sec : millisec" (e.g., "12 : 450")
  /// - Uses getFormattedRemainingTime() method from Pet model
  /// 
  /// TEST PURPOSE: 
  /// When using testButton, this display shows decreasing seconds in real-time
  /// Demonstrates that followButtonActiveDurationSeconds variable controls countdown duration
  Widget _buildTimerDisplay(Pet pet) {
    final buttonState = pet.getFollowButtonState();
    final isActive = buttonState['isActive'] as bool;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFFF1F8E9) // Light green background when active
            : const Color(0xFFFAFAFA), // Light gray background when inactive
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive 
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : const Color(0xFF9E9E9E).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timer icon
          Icon(
            isActive ? Icons.timer : Icons.schedule,
            size: 16,
            color: isActive 
                ? const Color(0xFF4CAF50)
                : const Color(0xFF9E9E9E),
          ),
          
          const SizedBox(width: 8),
          
          // Timer text
          Text(
            pet.getTimerDisplayText(), // Dynamic timer text
            style: GoogleFonts.pixelifySans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive 
                  ? const Color(0xFF2E7D32) // Dark green when active
                  : const Color(0xFF757575), // Dark gray when inactive
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress Indicator Widget (Optional Enhancement)
/// 
/// Shows visual progress through the current cycle phase
/// Can be used to provide additional visual feedback
class FollowButtonProgressIndicator extends StatelessWidget {
  final Pet pet;
  
  const FollowButtonProgressIndicator({
    super.key, 
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final buttonState = pet.getFollowButtonState();
    final isActive = buttonState['isActive'] as bool;
    final remainingSeconds = buttonState['remainingSeconds'] as int;
    final totalCycleSeconds = buttonState['totalCycleSeconds'] as int;
    
    // Calculate progress (0.0 to 1.0)
    final progress = 1.0 - (remainingSeconds / totalCycleSeconds);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            isActive 
                ? const Color(0xFF4CAF50) // Green progress when active
                : const Color(0xFF9E9E9E), // Gray progress when inactive
          ),
        ),
      ),
    );
  }
}