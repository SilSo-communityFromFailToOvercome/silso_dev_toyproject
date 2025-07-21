// lib/screens/feed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_notifier.dart';
import '../models/pet.dart';
import '../constants/app_constants.dart';
import './history_page.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedQuestion = '';

  final List<Map<String, dynamic>> _feedQuestions = [
    {
      'question': 'What small mistakes did you make today?',
      'icon': Icons.error_outline,
      'color': Colors.orange,
    },
    {
      'question': 'What didn\'t go according to plan?',
      'icon': Icons.schedule_outlined,
      'color': Colors.red,
    },
    {
      'question': 'What work/study aspect disappointed you?',
      'icon': Icons.work_outline,
      'color': Colors.purple,
    },
    {
      'question': 'What health management aspect was lacking?',
      'icon': Icons.health_and_safety_outlined,
      'color': Colors.green,
    },
    {
      'question': 'What relationship mistakes did you make?',
      'icon': Icons.people_outline,
      'color': Colors.blue,
    },
  ];

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
              _buildIntroMessage(context),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDivider(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildQuestionList(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Themed Reflection'),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'View reflection history',
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

  Widget _buildIntroMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.hungerColor.withOpacity(0.1),
        border: Border.all(color: AppConstants.hungerColor, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology_outlined,
            color: AppConstants.hungerColor,
            size: 24,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              'Reflect on today. Choose a topic to think about and share your thoughts.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.hungerColor,
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
            AppConstants.hungerColor.withOpacity(0.2),
            AppConstants.hungerColor,
            AppConstants.hungerColor.withOpacity(0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(BuildContext context) {
    return Column(
      children: _feedQuestions.asMap().entries.map((entry) {
        final questionData = entry.value;
        final question = questionData['question'] as String;
        final icon = questionData['icon'] as IconData;
        final color = questionData['color'] as Color;
        final isSelected = _selectedQuestion == question;
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: Card(
            elevation: isSelected ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              side: BorderSide(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              title: Text(
                question,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.arrow_forward_ios, color: color, size: 16)
                  : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              onTap: () {
                setState(() {
                  _selectedQuestion = question;
                });
                _showTextInputModal(context, question, color, icon);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Show text input modal for reflection writing
  void _showTextInputModal(BuildContext context, String question, Color themeColor, IconData icon) {
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
                _buildModalHeader(context, question, themeColor, icon),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildTextInput(context, themeColor),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildModalButtons(context, question, themeColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(BuildContext context, String question, Color themeColor, IconData icon) {
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
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(color: themeColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: themeColor, size: 24),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(BuildContext context, Color themeColor) {
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
          hintText: 'Share your thoughts on this topic...',
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
            borderSide: BorderSide(color: themeColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildModalButtons(BuildContext context, String question, Color themeColor) {
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
            onPressed: () => _submitReflection(context, question),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
            ),
            child: const Text(
              'Save Reflection',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _submitReflection(BuildContext context, String question) {
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

    ref.read(petNotifierProvider.notifier).performFeedAction(
      _textController.text.trim(),
      question,
    );
    
    Navigator.pop(context); // Close modal
    Navigator.pop(context); // Return to main page
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: Text(
                'Reflection saved! (+15 EXP, +20 Hunger)',
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
