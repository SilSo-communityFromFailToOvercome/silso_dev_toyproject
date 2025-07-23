// lib/screens/community_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/community.dart';
import '../models/post.dart';
import '../models/community_membership.dart';
import '../constants/app_constants.dart';
import '../providers/community_providers.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/report_dialog.dart';

class CommunityDetailPage extends ConsumerStatefulWidget {
  final Community community;

  const CommunityDetailPage({
    super.key,
    required this.community,
  });

  @override
  ConsumerState<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage> {
  @override
  Widget build(BuildContext context) {
    final membershipAsync = ref.watch(userMembershipProvider(widget.community.id));
    final postsAsync = ref.watch(communityPostsProvider(widget.community.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showCommunityMenu(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Community header
          SliverToBoxAdapter(
            child: _buildCommunityHeader(context, membershipAsync),
          ),
          // Posts section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Text(
                    'Community Posts',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryBorder,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showCreatePostDialog(context),
                  ),
                ],
              ),
            ),
          ),
          // Posts list
          postsAsync.when(
            data: (posts) => _buildPostsList(context, posts),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Text('Error loading posts: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityHeader(BuildContext context, AsyncValue<CommunityMembership?> membershipAsync) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _getCategoryColor(widget.community.category).withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(widget.community.category).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    widget.community.category.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.community.name,
                      style: GoogleFonts.pixelifySans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryBorder,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.community.memberCount} members',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.community.description,
            style: GoogleFonts.pixelifySans(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          membershipAsync.when(
            data: (membership) => _buildJoinButton(context, membership),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, CommunityMembership? membership) {
    final isMember = membership != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleJoinLeave(context, isMember),
        style: ElevatedButton.styleFrom(
          backgroundColor: isMember ? Colors.grey : _getCategoryColor(widget.community.category),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isMember ? 'Leave Community' : 'Join Community',
          style: GoogleFonts.pixelifySans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, List<Post> posts) {
    if (posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to share your story!',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = posts[index];
          return _buildPostCard(context, post);
        },
        childCount: posts.length,
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  post.type.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  post.type.displayName,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(widget.community.category),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(post.createdAt),
                  style: GoogleFonts.pixelifySans(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: GoogleFonts.pixelifySans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryBorder,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildReactionButton(context, post, ReactionType.empathy),
                _buildReactionButton(context, post, ReactionType.support),
                _buildReactionButton(context, post, ReactionType.helpful),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.comment, size: 20),
                  onPressed: () {
                    // TODO: Navigate to post detail with comments
                  },
                ),
                Text(
                  '${post.commentCount}',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () => _showPostMenu(context, post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(BuildContext context, Post post, ReactionType reactionType) {
    final count = post.reactionCounts[reactionType] ?? 0;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _handleReaction(post.id, reactionType),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reactionType.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: GoogleFonts.pixelifySans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleJoinLeave(BuildContext context, bool isMember) async {
    final communityNotifier = ref.read(communityNotifierProvider.notifier);
    
    if (isMember) {
      await communityNotifier.leaveCommunity(widget.community.id);
    } else {
      await communityNotifier.joinCommunity(widget.community.id);
    }

    // Refresh membership status
    ref.invalidate(userMembershipProvider(widget.community.id));
  }

  void _handleReaction(String postId, ReactionType reactionType) async {
    final postNotifier = ref.read(postNotifierProvider.notifier);
    await postNotifier.addReaction(postId, reactionType);
  }

  void _showCommunityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Community Info'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show community info
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Community'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, 'Community', (reason) {
                  // TODO: Implement community reporting
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(communityId: widget.community.id),
    );
  }

  void _showPostMenu(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, 'Post', (reason) {
                  _reportPost(post.id, reason);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, String type, Function(String) onReport) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: type,
        onReport: onReport,
      ),
    );
  }

  void _reportPost(String postId, String reason) async {
    final postNotifier = ref.read(postNotifierProvider.notifier);
    await postNotifier.reportPost(postId, reason);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
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