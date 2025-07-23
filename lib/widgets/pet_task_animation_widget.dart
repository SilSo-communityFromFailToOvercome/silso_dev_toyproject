// lib/widgets/pet_task_animation_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../providers/pet_notifier.dart';
import 'lottie_clean_animation_widget.dart';

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
  
  // FIX: Prevent repeated modal after tab closed - Animation lifecycle tracking
  bool _hasShownModal = false;
  bool _isAnimationComplete = false;
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // FIX: Only start animation once and if not already completed
    if (widget.pet.shouldShowTaskAnimation && !_hasShownModal && !_isAnimationComplete) {
      _hasShownModal = true;
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
    _animationTimer = Timer(const Duration(milliseconds: 1000), () {
      _completeAnimation();
    });
  }
  
  /// PLAY task animation - Enhanced bounce effect (diary completed, playful mood)
  /// FIX: Removed rotation animation and ensured single playback only
  void _startPlayingAnimation() {
    // Single bounce animation without rotation
    _bounceController.forward().then((_) {
      // Single playback complete - trigger completion
      if (!_isAnimationComplete && !_isDisposed) {
        _completeAnimation();
      }
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
  /// FIX: Enhanced completion with lifecycle tracking
  void _completeAnimation() {
    // Prevent multiple completions
    if (_isAnimationComplete || _isDisposed) return;
    _isAnimationComplete = true;
    
    // Stop all animations
    _bounceController.stop();
    _scaleController.stop();
    _rotationController.stop();
    _sparkleController.stop();
    _animationTimer?.cancel();
    
    // Clear animation state in PetNotifier
    try {
      ref.read(petNotifierProvider.notifier).clearAnimationState();
    } catch (e) {
      // Handle case where provider is no longer available
      print('DEBUG: Failed to clear animation state: $e');
    }
    
    // Trigger completion callback
    if (widget.onAnimationComplete != null && !_isDisposed) {
      widget.onAnimationComplete!.call();
    }
  }
  
  @override
  void dispose() {
    // FIX: Mark as disposed to prevent any pending callbacks
    _isDisposed = true;
    _isAnimationComplete = true;
    
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
  /// FIX: Added tap-to-dismiss functionality for anywhere screen tap
  Widget _buildAnimatedPet() {
    final animationType = widget.pet.currentAnimationType;
    
    return GestureDetector(
      onTap: () {
        // FIX: Anywhere screen tap to pop back to my_page
        print('DEBUG: Animation tapped - navigating back to my_page');
        if (!_isAnimationComplete) {
          _completeAnimation();
        }
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: AnimatedBuilder(
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
              
              // Main pet image with transformations (no rotation for PLAY)
              Transform.scale(
                scale: _getScaleValue(animationType),
                child: Image.asset(
                  widget.basePetImagePath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              
              // Floating hearts for PLAY animation
              if (animationType == 'playing') _buildFloatingHearts(),
            ],
          );
        },
      ),
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
  /// FIX: Removed rotation animation for all animation types
  double _getRotationValue(String? animationType) {
    // No rotation for any animation type - single playback only
    return 0.0;
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

/// Enhanced animation overlay widget with Lottie integration
/// 
/// INTEGRATION ENHANCEMENT: Now supports Lottie clean animations
/// - Detects when currentAnimationType == 'cleaning'
/// - Shows LottieCleanAnimationWidget as modal overlay for clean tasks
/// - Maintains existing built-in animations for other tasks (play, feed)
/// - Coordinates timing between Lottie and existing animation system
/// - Unified completion callback system preserves existing behavior
class PetAnimationOverlay extends ConsumerStatefulWidget {
  final Pet pet;
  final String basePetImagePath;
  
  const PetAnimationOverlay({
    super.key,
    required this.pet,
    required this.basePetImagePath,
  });

  @override
  ConsumerState<PetAnimationOverlay> createState() => _PetAnimationOverlayState();
}

class _PetAnimationOverlayState extends ConsumerState<PetAnimationOverlay> {
  // FIX: Prevent repeated modal after tab closed - Track modal display state
  bool _hasShownLottieModal = false;
  bool _isShowingModal = false;

  @override
  Widget build(BuildContext context) {
    // FIX: Enhanced debugging and prevention logic
    print('DEBUG PetAnimationOverlay: shouldShowTaskAnimation=${widget.pet.shouldShowTaskAnimation}, currentAnimationType=${widget.pet.currentAnimationType}');
    print('DEBUG PetAnimationOverlay: _hasShownLottieModal=$_hasShownLottieModal, _isShowingModal=$_isShowingModal');
    
    // FIX: Prevent duplicate Lottie animations and coordinate with built-in animations
    // CRITICAL: Clean animations are now handled in clean_page only, not here
    if (widget.pet.shouldShowTaskAnimation && 
        widget.pet.currentAnimationType == 'cleaning' && 
        !_hasShownLottieModal && 
        !_isShowingModal) {
      
      print('DEBUG PetAnimationOverlay: Would normally show Lottie modal, but skipping - handled in clean_page');
      
      // FIX: Clear the animation state immediately to prevent loops
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(petNotifierProvider.notifier).clearAnimationState();
          print('DEBUG PetAnimationOverlay: Cleared stale cleaning animation state');
        }
      });
      
      // Return static pet image - no modal needed
      return Image.asset(
        widget.basePetImagePath,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      );
    }
    
    // For non-cleaning animations, use existing system
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: PetTaskAnimationWidget(
        key: ValueKey(widget.pet.shouldShowTaskAnimation ? widget.pet.currentAnimationType : 'static'),
        pet: widget.pet,
        basePetImagePath: widget.basePetImagePath,
        onAnimationComplete: () {
          // FIX: Reset modal state when animation completes
          if (mounted) {
            setState(() {
              _hasShownLottieModal = false;
              _isShowingModal = false;
            });
          }
        },
      ),
    );
  }
  
  /// Show Lottie clean animation modal
  /// 
  /// DESIGN DECISION: Modal overlay pattern
  /// - Non-intrusive celebration of clean task completion
  /// - Uses existing navigation stack for smooth integration
  /// - Automatically clears animation state when complete
  /// FIX: Enhanced modal handling with proper state management
  void _showLottieCleanAnimation(BuildContext context) {
    if (!mounted || !_isShowingModal) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return LottieCleanAnimationWidget(
          onAnimationComplete: () {
            // FIX: Reset modal state when Lottie animation completes
            if (mounted) {
              setState(() {
                _isShowingModal = false;
              });
            }
          },
        );
      },
    ).then((_) {
      // FIX: Ensure modal state is reset when dialog closes
      if (mounted) {
        setState(() {
          _isShowingModal = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // FIX: Reset state flags on disposal
    _hasShownLottieModal = false;
    _isShowingModal = false;
    super.dispose();
  }
}