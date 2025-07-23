// lib/screens/community_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/community.dart';
import '../constants/app_constants.dart';
import '../providers/community_providers.dart';
import 'community_detail_page.dart';

class CommunityPage extends ConsumerWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitiesAsync = ref.watch(communitiesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.business, size: 24),
        ),
        title: const Text('COMMUNITY'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement community search
            },
          ),
        ],
      ),
      body: communitiesAsync.when(
        data: (communities) => _buildCommunityList(context, ref, communities),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildCommunityList(BuildContext context, WidgetRef ref, List<Community> communities) {
    if (communities.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return CustomScrollView(
      slivers: [
        // Header section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join supportive communities',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBorder,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with others who understand your journey',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoryFilter(context, ref),
              ],
            ),
          ),
        ),
        // Communities grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final community = communities[index];
                return _buildCommunityCard(context, ref, community);
              },
              childCount: communities.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100), // Bottom padding for navigation
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: FailureCategory.values.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip(context, ref, null, 'All', Icons.apps);
          }
          
          final category = FailureCategory.values[index - 1];
          return _buildFilterChip(
            context, 
            ref, 
            category, 
            category.displayName,
            _getCategoryIcon(category),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, FailureCategory? category, String label, IconData icon) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          ref.read(selectedCategoryProvider.notifier).state = category;
        },
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : AppConstants.primaryBorder,
        ),
        label: Text(
          label,
          style: GoogleFonts.pixelifySans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppConstants.primaryBorder,
          ),
        ),
        backgroundColor: Colors.white,
        selectedColor: AppConstants.primaryBorder,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppConstants.primaryBorder : Colors.grey.shade300,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, WidgetRef ref, Community community) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityDetailPage(community: community),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(community.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        community.category.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      community.name,
                      style: GoogleFonts.pixelifySans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryBorder,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                community.description,
                style: GoogleFonts.pixelifySans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${community.memberCount} members',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(community.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      community.category.displayName,
                      style: GoogleFonts.pixelifySans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Communities Yet',
              style: GoogleFonts.pixelifySans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Communities are being set up.\nCheck back soon!',
              textAlign: TextAlign.center,
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  final communityService = ref.read(communityServiceProvider);
                  await communityService.initializeDefaultCommunities();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sample communities created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create communities: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Create Sample Communities',
                style: GoogleFonts.pixelifySans(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load communities',
              style: GoogleFonts.pixelifySans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh communities
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(FailureCategory category) {
    switch (category) {
      case FailureCategory.academic:
        return Icons.school;
      case FailureCategory.career:
        return Icons.work;
      case FailureCategory.employment:
        return Icons.people;
      case FailureCategory.entrepreneurship:
        return Icons.rocket_launch;
      case FailureCategory.relationship:
        return Icons.favorite;
      case FailureCategory.housing:
        return Icons.home;
      case FailureCategory.personal:
        return Icons.self_improvement;
      case FailureCategory.health:
        return Icons.health_and_safety;
      case FailureCategory.financial:
        return Icons.attach_money;
    }
  }

  Color _getCategoryColor(FailureCategory category) {
    switch (category) {
      case FailureCategory.academic:
        return Colors.blue;
      case FailureCategory.career:
        return Colors.purple;
      case FailureCategory.employment:
        return Colors.orange;
      case FailureCategory.entrepreneurship:
        return Colors.red;
      case FailureCategory.relationship:
        return Colors.pink;
      case FailureCategory.housing:
        return Colors.brown;
      case FailureCategory.personal:
        return Colors.green;
      case FailureCategory.health:
        return Colors.teal;
      case FailureCategory.financial:
        return Colors.amber;
    }
  }
}