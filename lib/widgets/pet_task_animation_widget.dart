// lib/widgets/pet_task_animation_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../providers/pet_notifier.dart';

/// Pet Task Animation Widget
/// 
/// ANIMATION PACKAGE CHOICE: Flutter's Built-in AnimatedSwitcher + Custom Image Sequence
/// 
/// WHY THIS CHOICE:
/// 1. No external dependencies - Works with existing pet evolution images
/// 2. Lightweight performance impact - Built into Flutter framework
/// 3. Flexible control - Can create contextual animations using existing assets
/// 4. Easy integration - Seamless with current Riverpod state management
/// 5. Custom animations - Perfect for task-specific pet behaviors
/// 
/// HOW ANIMATIONS ARE TRIGGERED:
/// 1. User completes task (CLEAN/PLAY/FEED) → PetNotifier updates pet.lastCompletedTask
/// 2. User returns to MY PAGE via Navigator.pop()
/// 3. MyPage rebuilds and detects pet.shouldShowTaskAnimation = true
/// 4. This widget automatically shows appropriate animation based on pet.currentAnimationType
/// 5. Animation completes → PetNotifier.clearAnimationState() resets trigger
/// 
/// HOW PET IMAGES ARE USED:
/// - Base pet image from current growth stage (egg_state0.png to egg_state6.png)
/// - Animation sequences created by combining pet images with visual effects:
///   * CLEAN: Sparkle effect + scale animation (cleaning/attendance completed)
///   * PLAY: Bounce effect + rotation (playful/happy after diary)
///   * FEED: Glow effect + scale pulse (satisfied after reflection)
/// - Each animation type has distinct visual characteristics matching task context
class PetTaskAnimationWidget extends ConsumerStatefulWidget {
  /// The pet object containing animation state and current growth stage
  final Pet pet;
  
  /// Base pet image path from MyPage (current growth stage)
  final String basePetImagePath;
  
  /// Animation completion callback to clear animation state
  final VoidCallback? onAnimationComplete;

  const PetTaskAnimationWidget({
    super.key,
    required this.pet,
    required this.basePetImagePath,
    this.onAnimationComplete,
  });

  @override
  ConsumerState<PetTaskAnimationWidget> createState() => _PetTaskAnimationWidgetState();
}

class _PetTaskAnimationWidgetState extends ConsumerState<PetTaskAnimationWidget>
    with TickerProviderStateMixin {
  
  // Animation controllers for different animation types
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  
  // Animation values
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleOpacity;
  
  Timer? _animationTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Start animation if should show
    if (widget.pet.shouldShowTaskAnimation) {
      _startTaskAnimation();
    }
  }
  
  /// Initialize all animation controllers and animations
  void _initializeAnimations() {
    // Bounce animation for PLAY (playful movement)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    
    // Scale animation for CLEAN and FEED
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    // Rotation animation for PLAY (playful spin)
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    
    // Sparkle opacity for CLEAN (cleaning effect)
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _sparkleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }
  
  /// Start the appropriate animation based on the completed task
  void _startTaskAnimation() {
    final animationType = widget.pet.currentAnimationType;
    
    switch (animationType) {
      case 'cleaning':
        _startCleaningAnimation();
        break;
      case 'playing':
        _startPlayingAnimation();
        break;
      case 'eating':
        _startEatingAnimation();
        break;
      default:
        _completeAnimation();
    }
  }
  
  /// CLEAN task animation - Sparkle and scale effect (attendance completed)
  void _startCleaningAnimation() {
    _sparkleController.forward();
    _scaleController.repeat(reverse: true);
    
    // Complete after 2.5 seconds
    _animationTimer = Timer(const Duration(milliseconds: 2500), () {
      _completeAnimation();
    });
  }
  
  /// PLAY task animation - Bounce and rotation effect (diary completed, playful mood)
  void _startPlayingAnimation() {
    _bounceController.forward();
    _rotationController.repeat(reverse: true);
    
    // Complete after 2 seconds
    _animationTimer = Timer(const Duration(milliseconds: 2000), () {
      _completeAnimation();
    });
  }
  
  /// FEED task animation - Glow and scale pulse effect (reflection completed, satisfied)
  void _startEatingAnimation() {
    _scaleController.repeat(reverse: true);
    
    // Complete after 2.2 seconds
    _animationTimer = Timer(const Duration(milliseconds: 2200), () {
      _completeAnimation();
    });
  }
  
  /// Complete animation and trigger cleanup
  void _completeAnimation() {
    // Stop all animations
    _bounceController.stop();
    _scaleController.stop();
    _rotationController.stop();
    _sparkleController.stop();
    _animationTimer?.cancel();
    
    // Clear animation state in PetNotifier
    ref.read(petNotifierProvider.notifier).clearAnimationState();
    
    // Trigger completion callback
    widget.onAnimationComplete?.call();
  }
  
  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.pet.shouldShowTaskAnimation) {
      // No animation - show normal pet image
      return _buildStaticPetImage();
    }
    
    // Show animated pet based on task type
    return _buildAnimatedPet();
  }
  
  /// Build static pet image (no animation)
  Widget _buildStaticPetImage() {
    return Image.asset(
      widget.basePetImagePath,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
    );
  }
  
  /// Build animated pet with task-specific effects
  Widget _buildAnimatedPet() {
    final animationType = widget.pet.currentAnimationType;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceController,
        _scaleController,
        _rotationController,
        _sparkleController,
      ]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background sparkle effect for CLEAN animation
            if (animationType == 'cleaning') _buildSparkleEffect(),
            
            // Background glow effect for FEED animation
            if (animationType == 'eating') _buildGlowEffect(),
            
            // Main pet image with transformations
            Transform.scale(
              scale: _getScaleValue(animationType),
              child: Transform.rotate(
                angle: _getRotationValue(animationType),
                child: Image.asset(
                  widget.basePetImagePath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Floating hearts for PLAY animation
            if (animationType == 'playing') _buildFloatingHearts(),
          ],
        );
      },
    );
  }
  
  /// Get scale transformation value based on animation type
  double _getScaleValue(String? animationType) {
    switch (animationType) {
      case 'cleaning':
      case 'eating':
        return _scaleAnimation.value;
      case 'playing':
        return _bounceAnimation.value;
      default:
        return 1.0;
    }
  }
  
  /// Get rotation transformation value based on animation type
  double _getRotationValue(String? animationType) {
    switch (animationType) {
      case 'playing':
        return _rotationAnimation.value;
      default:
        return 0.0;
    }
  }
  
  /// Build sparkle effect for CLEAN animation
  Widget _buildSparkleEffect() {
    return AnimatedOpacity(
      opacity: _sparkleOpacity.value,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.auto_awesome,
            size: 40,
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }
  
  /// Build glow effect for FEED animation
  Widget _buildGlowEffect() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 35,
            spreadRadius: 12,
          ),
        ],
      ),
    );
  }
  
  /// Build floating hearts for PLAY animation
  Widget _buildFloatingHearts() {
    return Positioned(
      top: 40,
      right: 40,
      child: AnimatedOpacity(
        opacity: _bounceAnimation.value - 0.2,
        duration: const Duration(milliseconds: 100),
        child: const Column(
          children: [
            Icon(Icons.favorite, color: Colors.pink, size: 20),
            SizedBox(height: 10),
            Icon(Icons.favorite, color: Colors.red, size: 16),
            SizedBox(height: 8),
            Icon(Icons.favorite, color: Colors.pink, size: 12),
          ],
        ),
      ),
    );
  }
}

/// Simple animation overlay widget for easier integration
class PetAnimationOverlay extends ConsumerWidget {
  final Pet pet;
  final String basePetImagePath;
  
  const PetAnimationOverlay({
    super.key,
    required this.pet,
    required this.basePetImagePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: PetTaskAnimationWidget(
        key: ValueKey(pet.shouldShowTaskAnimation ? pet.currentAnimationType : 'static'),
        pet: pet,
        basePetImagePath: basePetImagePath,
        onAnimationComplete: () {
          // Animation completed - state already cleared by widget
        },
      ),
    );
  }
}