// lib/screens/clean_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/pet_notifier.dart';
import '../constants/app_constants.dart';

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
    final petNotifier = ref.read(petNotifierProvider.notifier);
    final pet = ref.watch(petNotifierProvider);
    
    // Check if already attended today
    final today = DateTime.now();
    final alreadyAttended = pet.lastAttendanceDate != null &&
        pet.lastAttendanceDate!.year == today.year &&
        pet.lastAttendanceDate!.month == today.month &&
        pet.lastAttendanceDate!.day == today.day;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
        onPressed: () => _performCheckIn(context, petNotifier),
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
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _performCheckIn(BuildContext context, PetNotifier petNotifier) {
    petNotifier.performCleanAction();
    Navigator.pop(context);
    
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
}
