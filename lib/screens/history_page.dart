// lib/screens/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_notifier.dart';
import '../models/reflection.dart';
import '../constants/app_constants.dart';

class PlayHistoryPage extends ConsumerWidget {
  const PlayHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Firebase reflectionsProvider에서 회고 기록 목록 가져오기
    final reflectionsAsync = ref.watch(reflectionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reflection History'),
        centerTitle: true,
      ),
      body: reflectionsAsync.when(
        data: (reflections) => reflections.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: reflections.length,
                itemBuilder: (context, index) {
                  final reflection = reflections[index];
                  return _buildReflectionCard(context, reflection);
                },
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'Failed to load reflections',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Please try again later',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No reflections yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Start writing diary entries and reflections\nto see them here!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, Reflection reflection) {
    final isPlay = reflection.type == 'play';
    final cardColor = isPlay ? AppConstants.happinessColor : AppConstants.hungerColor;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          side: BorderSide(color: cardColor.withOpacity(0.3)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              border: Border.all(color: cardColor, width: 2),
            ),
            child: Center(
              child: Icon(
                isPlay ? Icons.edit_note : Icons.psychology,
                color: cardColor,
                size: 28,
              ),
            ),
          ),
          title: Text(
            reflection.question,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardColor.withOpacity(0.3)),
                ),
                child: Text(
                  reflection.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cardColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${reflection.timestamp} • ${reflection.timestamp}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: cardColor,
            size: 16,
          ),
          onTap: () => _showReflectionDetailModal(context, reflection),
        ),
      ),
    );
  }

  /// Show reflection detail modal
  void _showReflectionDetailModal(BuildContext context, Reflection reflection) {
    final isPlay = reflection.type == 'play';
    final themeColor = isPlay ? AppConstants.happinessColor : AppConstants.hungerColor;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            side: BorderSide(color: themeColor, width: 2),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalHeader(context, reflection, themeColor),
                const SizedBox(height: AppConstants.defaultPadding),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        reflection.answer,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildModalFooter(context, reflection, themeColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(BuildContext context, Reflection reflection, Color themeColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Icon(
            reflection.type == 'play' ? Icons.edit_note : Icons.psychology,
            color: themeColor,
            size: 24,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reflection.question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reflection.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildModalFooter(BuildContext context, Reflection reflection, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            'Written on ${reflection.timestamp} at ${reflection.timestamp}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
