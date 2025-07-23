// lib/screens/play_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'egg_flight_game_screen.dart';
import '../providers/pet_notifier.dart';
import '../models/pet.dart';
import '../constants/app_constants.dart';
import './history_page.dart';

class PlayPage extends ConsumerStatefulWidget {
  const PlayPage({super.key});

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
  final TextEditingController _textController = TextEditingController();
  final String _reflectionQuestion = "오늘 하루는 어땠어?"; // PLAY 질문

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petNotifierProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPetImage(pet),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildQuestionBubble(context),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDivider(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDiaryInputArea(context),
              const SizedBox(height: AppConstants.largePadding),
              _buildWriteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Daily Diary'),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'View diary history',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayHistoryPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPetImage(Pet pet) {
    return Center(
      child: Container(
        width: AppConstants.smallPetImageSize,
        height: AppConstants.smallPetImageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.smallPetImageSize / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.smallPetImageSize / 2),
          child: Image.asset(
            'assets/images/egg_state${pet.growthStage}.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.pets,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.happinessColor.withOpacity(0.1),
        border: Border.all(color: AppConstants.happinessColor, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: AppConstants.happinessColor,
            size: 24,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              _reflectionQuestion,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.happinessColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.happinessColor.withOpacity(0.2),
            AppConstants.happinessColor,
            AppConstants.happinessColor.withOpacity(0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryInputArea(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTextInputModal(context),
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 2),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          color: Colors.grey.shade50,
        ),
        child: _textController.text.isEmpty
            ? _buildPlaceholderText(context)
            : _buildDiaryText(context),
      ),
    );
  }

  Widget _buildPlaceholderText(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.edit_note,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Tap to write your diary...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDiaryText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppConstants.successColor,
              size: 20,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Diary written',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          _textController.text,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildWriteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showTextInputModal(context),
        icon: Icon(_textController.text.isEmpty ? Icons.edit : Icons.edit_note),
        label: Text(_textController.text.isEmpty ? 'Write Diary' : 'Edit Diary'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.happinessColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
      ),
    );
  }

  /// Show text input modal for diary writing
  void _showTextInputModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.defaultPadding,
              top: AppConstants.defaultPadding,
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildModalHeader(context),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildTextInput(context),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildModalButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Container(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: AppConstants.happinessColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            border: Border.all(color: AppConstants.happinessColor),
          ),
          child: Text(
            _reflectionQuestion,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppConstants.happinessColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 200,
        minHeight: 120,
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Write about your day honestly...',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            borderSide: const BorderSide(color: AppConstants.happinessColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildModalButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () async {
              await _submitDiaryAndStartGame(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.happinessColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
            ),
            child: const Text(
              'Save Diary',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitDiaryAndStartGame(BuildContext context) async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: AppConstants.smallPadding),
              Text('Please write something before saving!'),
            ],
          ),
          backgroundColor: AppConstants.warningColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading indicator while saving
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Save the diary without additional navigation
      await ref.read(petNotifierProvider.notifier).performPlayAction(
        _textController.text.trim(),
        _reflectionQuestion,
      );
      
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close modal
      
      // Brief delay to ensure modal is closed
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Launch the egg flight game
      if (mounted) {
        debugPrint('Launching egg flight game...');
        try {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EggFlightGameScreen(
                onGameComplete: () {
                  debugPrint('Egg flight game completed!');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Great job! Your pet is happy with your diary entry!'),
                        duration: Duration(seconds: 3),
                        backgroundColor: AppConstants.successColor,
                      ),
                    );
                  }
                },
              ),
            ),
          );
          debugPrint('Returned from egg flight game');
        } catch (gameError) {
          debugPrint('Error launching game: $gameError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not start game, but your diary was saved successfully!'),
                duration: Duration(seconds: 3),
                backgroundColor: AppConstants.warningColor,
              ),
            );
          }
        }
      }
      
      // Show success message after returning from game
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    'Diary saved! (+10 EXP, +20 Happiness)',
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
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: AppConstants.smallPadding),
              Text('Failed to save diary. Please try again.'),
            ],
          ),
          backgroundColor: AppConstants.warningColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

}
