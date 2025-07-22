// lib/widgets/lottie_clean_animation_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../providers/pet_notifier.dart';
import '../constants/app_constants.dart';

/// Lottie Clean Animation Widget
/// 
/// DESIGN DECISION: Modal Overlay Pattern
/// - Shows as celebratory modal overlay after clean task completion
/// - Combines Lottie cleaning animation from local asset (assets/Wipe_clean_icon.json)
/// - Supports different message types: first-time completion vs already attended
/// - Auto-dismisses after animation completes with graceful fallback
/// 
/// INTEGRATION APPROACH:
/// - Triggered by existing PetNotifier animation system
/// - Uses same state management as existing animations
/// - Preserves current animation behavior while adding Lottie enhancement
/// - Fallback to existing sparkle animation if Lottie fails
/// 
/// HOW CLEAN ANIMATION IS TRIGGERED:
/// 1. User completes clean task → PetNotifier.performCleanAction()
/// 2. pet.currentAnimationType = 'cleaning' + shouldShowTaskAnimation = true
/// 3. User returns to MY PAGE via Navigator.pop()
/// 4. Enhanced PetAnimationOverlay detects cleaning animation state
/// 5. This widget shows modal with Lottie animation
/// 6. Animation completes → clearAnimationState() resets trigger
/// Message type for different clean animation contexts
enum CleanAnimationType {
  /// First time completing clean task today - celebratory
  firstTime,
  /// Already completed clean task today - friendly reminder
  alreadyCompleted,
}

class LottieCleanAnimationWidget extends ConsumerStatefulWidget {
  /// Callback when animation completes
  final VoidCallback? onAnimationComplete;
  
  /// Path to the local Lottie animation asset
  final String animationAssetPath;
  
  /// Type of clean animation message to show
  final CleanAnimationType animationType;
  
  /// Whether to dismiss immediately on tap (for already completed case)
  final bool quickDismiss;

  const LottieCleanAnimationWidget({
    super.key,
    this.onAnimationComplete,
    this.animationAssetPath = 'assets/animations/Wipe_clean_icon.json',
    this.animationType = CleanAnimationType.firstTime,
    this.quickDismiss = false,
  });
  
  /// Factory constructor for already completed case
  const LottieCleanAnimationWidget.alreadyCompleted({
    Key? key,
    VoidCallback? onAnimationComplete,
    String animationAssetPath = 'assets/animations/Wipe_clean_icon.json',
  }) : this(
    key: key,
    onAnimationComplete: onAnimationComplete,
    animationAssetPath: animationAssetPath,
    animationType: CleanAnimationType.alreadyCompleted,
    quickDismiss: true,
  );

  @override
  ConsumerState<LottieCleanAnimationWidget> createState() => _LottieCleanAnimationWidgetState();
}

class _LottieCleanAnimationWidgetState extends ConsumerState<LottieCleanAnimationWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _modalController;
  late AnimationController _sparkleController;
  late Animation<double> _modalScaleAnimation;
  late Animation<double> _modalOpacityAnimation;
  late Animation<double> _sparkleOpacity;
  
  bool _isAnimationComplete = false;
  bool _showLottie = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
  }

  /// Initialize modal and sparkle animations to complement Lottie
  void _initializeAnimations() {
    // Modal entrance/exit animation
    _modalController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _modalScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.elasticOut),
    );
    
    _modalOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOut),
    );
    
    // Sparkle effect animation (complements Lottie)
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _sparkleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }

  /// Start the modal and complementary animations
  void _startAnimation() {
    // Show modal with entrance animation
    _modalController.forward();
    
    // Start sparkle effect slightly delayed to complement Lottie
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _sparkleController.forward();
      }
    });
  }

  /// Handle Lottie animation completion
  void _onLottieAnimationComplete() {
    if (!_isAnimationComplete) {
      _isAnimationComplete = true;
      
      // For already completed case, dismiss quickly
      // For first time case, wait longer for celebration
      final delayDuration = widget.quickDismiss 
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 800);
      
      Future.delayed(delayDuration, () {
        if (mounted) {
          _dismissModal();
        }
      });
    }
  }

  /// Dismiss the modal with exit animation
  void _dismissModal() {
    _modalController.reverse().then((_) {
      if (mounted) {
        // Clear animation state in PetNotifier
        ref.read(petNotifierProvider.notifier).clearAnimationState();
        
        // Trigger completion callback
        widget.onAnimationComplete?.call();
        
        // Remove modal from widget tree
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  /// Handle Lottie loading errors gracefully
  void _onLottieError() {
    setState(() {
      _showLottie = false;
    });
    
    // Still show success message and sparkle effect
    // Auto-dismiss after shorter duration since no Lottie animation
    final fallbackDuration = widget.quickDismiss 
      ? const Duration(milliseconds: 1200)
      : const Duration(milliseconds: 2000);
      
    Future.delayed(fallbackDuration, () {
      if (mounted) {
        _dismissModal();
      }
    });
  }

  @override
  void dispose() {
    _modalController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_modalController, _sparkleController]),
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _dismissModal, // Allow tap to dismiss
            child: Container(
              color: Colors.black.withOpacity(0.4 * _modalOpacityAnimation.value),
              child: Center(
                child: Transform.scale(
                  scale: _modalScaleAnimation.value,
                  child: Opacity(
                    opacity: _modalOpacityAnimation.value,
                    child: _buildAnimationContainer(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the main animation container with Lottie and effects
  Widget _buildAnimationContainer() {
    return Container(
      width: 320,
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main animation area
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background sparkle effect (complements Lottie)
                _buildSparkleBackground(),
                
                // Main Lottie animation or fallback
                _buildMainAnimation(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Success message
          _buildSuccessMessage(),
          
          const SizedBox(height: 8),
          
          // Subtitle with tap hint
          _buildSubtitle(),
        ],
      ),
    );
  }

  /// Build background sparkle effect
  Widget _buildSparkleBackground() {
    return AnimatedOpacity(
      opacity: _sparkleOpacity.value * 0.7,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppConstants.cleanlinessColor.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 15,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  /// Build main Lottie animation or fallback
  Widget _buildMainAnimation() {
    if (_showLottie) {
      return Lottie.asset(
        widget.animationAssetPath,
        width: 180,
        height: 180,
        fit: BoxFit.contain,
        repeat: false, // Play once
        onLoaded: (composition) {
          // Calculate animation duration and set completion callback
          final duration = composition.duration;
          Future.delayed(duration, _onLottieAnimationComplete);
        },
        errorBuilder: (context, error, stackTrace) {
          _onLottieError();
          return _buildFallbackAnimation();
        },
      );
    } else {
      return _buildFallbackAnimation();
    }
  }

  /// Build fallback animation if Lottie fails
  Widget _buildFallbackAnimation() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppConstants.cleanlinessColor.withOpacity(0.1),
        border: Border.all(
          color: AppConstants.cleanlinessColor,
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.cleaning_services,
        size: 80,
        color: AppConstants.cleanlinessColor,
      ),
    );
  }

  /// Build success message text based on animation type
  Widget _buildSuccessMessage() {
    final message = widget.animationType == CleanAnimationType.alreadyCompleted
      ? 'You already checked attendance :))'
      : 'Pet is squeaky clean!';
      
    return Text(
      message,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppConstants.cleanlinessColor,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build subtitle with tap hint based on animation type
  Widget _buildSubtitle() {
    final subtitle = widget.animationType == CleanAnimationType.alreadyCompleted
      ? 'Come back tomorrow for next check-in'
      : 'Tap anywhere to continue';
      
    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Modal helper function to show Lottie clean animation
/// 
/// Usage: Call from enhanced PetAnimationOverlay when cleaning animation is triggered
void showLottieCleanAnimation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Controlled dismissal through animation completion
    barrierColor: Colors.transparent, // Custom backdrop in widget
    builder: (BuildContext context) {
      return const LottieCleanAnimationWidget();
    },
  );
}