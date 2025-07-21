// lib/constants/app_constants.dart

import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Experience thresholds for growth stages
  static const int stage1Threshold = 20;
  static const int stage2Threshold = 40;
  static const int stage3Threshold = 60;

  // Stat rewards for actions
  static const int cleanExperience = 5;
  static const int cleanCleanliness = 20;
  static const int playExperience = 10;
  static const int playHappiness = 20;
  static const int feedExperience = 15;
  static const int feedHunger = 20;

  // Pet image dimensions
  static const double petImageSize = 250.0;
  static const double smallPetImageSize = 100.0;

  // Status bar dimensions
  static const double statusBarWidth = 100.0;
  static const double statusBarHeight = 10.0;

  // Animation durations
  static const Duration petImageTransition = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 2);

  // Spacing constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Colors
  static const Color primaryBorder = Colors.black87;
  static const Color secondaryBorder = Colors.black54;
  static const Color warningColor = Colors.orange;
  static const Color successColor = Colors.green;
  static const Color dangerColor = Colors.red;

  // Status colors
  static const Color experienceColor = Colors.purple;
  static const Color hungerColor = Colors.orange;
  static const Color happinessColor = Colors.pink;
  static const Color cleanlinessColor = Colors.lightBlue;

  // Typography sizes
  static const double titleFontSize = 24.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
}

/// Screen size breakpoints for responsive design
class ScreenBreakpoints {
  ScreenBreakpoints._();

  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1200.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

/// Growth stage configuration
class GrowthStageConfig {
  GrowthStageConfig._();

  static const Map<int, String> stageNames = {
    0: 'Initial Egg',
    1: 'Cracked Egg',
    2: 'Pre-hatch Egg',
    3: 'Baby Pet',
  };

  static const Map<int, String> imagePaths = {
    0: 'assets/images/egg_state0.png',
    1: 'assets/images/egg_state1.png',
    2: 'assets/images/egg_state2.png',
    3: 'assets/images/egg_state3.png',
  };

  static String getImagePath(int stage) => 
      imagePaths[stage] ?? imagePaths[0]!;

  static String getStageName(int stage) => 
      stageNames[stage] ?? 'Unknown';
}