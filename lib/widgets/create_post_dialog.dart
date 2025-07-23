// lib/widgets/create_post_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../constants/app_constants.dart';
import '../providers/community_providers.dart';

class CreatePostDialog extends ConsumerStatefulWidget {
  final String communityId;

  const CreatePostDialog({
    super.key,
    required this.communityId,
  });

  @override
  ConsumerState<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends ConsumerState<CreatePostDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  PostType _selectedType = PostType.story;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postNotifierProvider);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - keyboardHeight - 100; // 100px padding

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: availableHeight > 400 ? availableHeight : 400,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Create Post',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryBorder,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            
            // Post type selection
            Text(
              'Post Type',
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryBorder,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PostType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  avatar: Text(type.emoji),
                  label: Text(
                    type.displayName,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppConstants.primaryBorder,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: AppConstants.primaryBorder,
                  side: BorderSide(
                    color: isSelected ? AppConstants.primaryBorder : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Title input
            Text(
              'Title',
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryBorder,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'What\'s your story about?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLength: 100,
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Content input
            Text(
              'Content',
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryBorder,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Share your experience, ask for advice, or offer support...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(height: 16),

            // Tags input
            Text(
              'Tags (optional)',
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryBorder,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Add a tag',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: _addTag,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(_tagController.text),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: GoogleFonts.pixelifySans(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: AppConstants.primaryBorder.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
            ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Fixed action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.pixelifySans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: postState.isLoading ? null : _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryBorder,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: postState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Post',
                              style: GoogleFonts.pixelifySans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag) && _tags.length < 5) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final postNotifier = ref.read(postNotifierProvider.notifier);
    
    await postNotifier.createPost(
      communityId: widget.communityId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _selectedType,
      tags: _tags,
    );

    if (mounted) {
      final postState = ref.read(postNotifierProvider);
      if (postState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${postState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}