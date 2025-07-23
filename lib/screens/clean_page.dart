// lib/screens/clean_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/pet_notifier.dart';
import '../constants/app_constants.dart';
import '../widgets/lottie_clean_animation_widget.dart';

class CleanPage extends ConsumerStatefulWidget {
  const CleanPage({super.key});

  @override
  ConsumerState<CleanPage> createState() => _CleanPageState();
}

class _CleanPageState extends ConsumerState<CleanPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isProcessingCheckIn = false; // Prevent multiple check-in attempts

  @override
  Widget build(BuildContext context) {
    final petNotifier = ref.read(petNotifierProvider.notifier);
    final pet = ref.watch(petNotifierProvider);
    
    // Check if already attended today
    final today = DateTime.now();
    final alreadyAttended = pet.lastAttendanceDate != null &&
        pet.lastAttendanceDate!.year == today.year &&
        pet.lastAttendanceDate!.month == today.month &&
        pet.lastAttendanceDate!.day == today.day;
    
    // DEBUG: Log attendance status
    print('DEBUG CleanPage - Today: ${today.toString()}');
    print('DEBUG CleanPage - Last Attendance Date: ${pet.lastAttendanceDate.toString()}');
    print('DEBUG CleanPage - Already Attended: $alreadyAttended');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // DEBUG: Reset button for testing
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              petNotifier.resetAttendanceForToday();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('DEBUG: Attendance status reset'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black.withOpacity(0.3),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: _buildCheckInCard(context, petNotifier, alreadyAttended),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInCard(BuildContext context, PetNotifier petNotifier, bool alreadyAttended) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        side: const BorderSide(color: AppConstants.primaryBorder, width: 2),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Daily Attendance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (alreadyAttended)
              _buildAlreadyAttendedMessage(context)
            else
              _buildAttendanceCalendar(context),
            const SizedBox(height: AppConstants.defaultPadding),
            if (!alreadyAttended)
              _buildCheckInButton(context, petNotifier)
            else
              _buildOkButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyAttendedMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: AppConstants.successColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppConstants.successColor,
            size: 48,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Already checked in today!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppConstants.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Come back tomorrow for your next check-in.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCalendar(BuildContext context) {
    return Flexible(
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left),
          rightChevronIcon: Icon(Icons.chevron_right),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppConstants.cleanlinessColor.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppConstants.cleanlinessColor,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(
            color: Colors.red.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context, PetNotifier petNotifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessingCheckIn ? null : () => _performCheckIn(context, petNotifier),
        icon: const Icon(Icons.cleaning_services),
        label: const Text('Check In Now!'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.cleanlinessColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildOkButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAlreadyAttendedAnimation(context),
        icon: const Icon(Icons.cleaning_services),
        label: const Text('Clean Again!'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.cleanlinessColor.withOpacity(0.7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
    );
  }
  
  /// Show Lottie animation for already attended case
  /// 
  /// IMPROVEMENT: Enhanced UX for repeated clean attempts
  /// - Shows same Lottie animation with different message
  /// - Quick dismiss on tap with friendly reminder
  /// - Maintains visual consistency with first-time experience
  void _showAlreadyAttendedAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return LottieCleanAnimationWidget.alreadyCompleted(
          onAnimationComplete: () {
            // Close the clean page after animation - only pop once
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  void _performCheckIn(BuildContext context, PetNotifier petNotifier) {
    // Prevent multiple simultaneous check-ins
    if (_isProcessingCheckIn) return;
    
    setState(() {
      _isProcessingCheckIn = true;
    });
    
    // FIX: Perform clean action WITHOUT setting animation triggers
    // We handle the animation locally in clean_page, not in MyPage
    petNotifier.performCleanAction();
    
    // Show immediate animation before navigation
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return LottieCleanAnimationWidget(
          onAnimationComplete: () {
            // Ensure callback only runs once per dialog
            if (!_isProcessingCheckIn) return;
            
            print('DEBUG: LottieCleanAnimationWidget completed in clean_page');
            
            // FIX: Clear any animation state that might have been set
            // This prevents duplicate modal triggers when returning to MyPage
            petNotifier.clearAnimationState();
            print('DEBUG: Animation state cleared after Lottie completion');
            
            // Close clean page after animation completes
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            
            // Show success snackbar on my_page with delayed execution
            Future.delayed(const Duration(milliseconds: 100), () {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: AppConstants.smallPadding),
                        const Expanded(
                          child: Text(
                            'Pet is now clean! (+5 EXP, +20 Cleanliness)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppConstants.successColor,
                    duration: AppConstants.snackBarDuration,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    ),
                  ),
                );
              }
            });
            
            // Reset processing state after completion
            if (mounted) {
              setState(() {
                _isProcessingCheckIn = false;
              });
            }
          },
        );
      },
    );
  }
}
