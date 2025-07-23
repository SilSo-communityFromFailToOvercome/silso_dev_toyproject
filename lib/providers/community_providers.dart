// lib/providers/community_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/community_membership.dart';
import '../services/community_service.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';
import '../screens/auth/auth_wrapper.dart';
import 'pet_notifier.dart';

// Service providers
final communityServiceProvider = Provider<CommunityService>((ref) => CommunityService());
final postServiceProvider = Provider<PostService>((ref) => PostService());
final commentServiceProvider = Provider<CommentService>((ref) => CommentService());

// Selected category filter
final selectedCategoryProvider = StateProvider<FailureCategory?>((ref) => null);

// Communities stream provider
final communitiesProvider = StreamProvider<List<Community>>((ref) {
  final communityService = ref.watch(communityServiceProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory != null) {
    // For category filtering, we need to use a future provider since getCommunitiesByCategory is not a stream
    return Stream.fromFuture(communityService.getCommunitiesByCategory(selectedCategory));
  }

  return communityService.getCommunitiesStream();
});

// User memberships provider
final userMembershipsProvider = FutureProvider<List<CommunityMembership>>((ref) async {
  final communityService = ref.watch(communityServiceProvider);
  final userId = ref.watch(userUidProvider);

  if (userId == null) return [];

  return communityService.getUserMemberships(userId);
});

// Check if user is member of a specific community
final userMembershipProvider = FutureProvider.family<CommunityMembership?, String>((ref, communityId) async {
  final communityService = ref.watch(communityServiceProvider);
  final userId = ref.watch(userUidProvider);

  if (userId == null) return null;

  return communityService.getUserMembership(userId, communityId);
});

// Posts for a specific community
final communityPostsProvider = StreamProvider.family<List<Post>, String>((ref, communityId) {
  final postService = ref.watch(postServiceProvider);
  return postService.getPostsStream(communityId);
});

// Comments for a specific post
final postCommentsProvider = StreamProvider.family<List<Comment>, String>((ref, postId) {
  final commentService = ref.watch(commentServiceProvider);
  return commentService.getCommentsStream(postId);
});

// User's reaction to a specific post
final userPostReactionProvider = FutureProvider.family<ReactionType?, String>((ref, postId) async {
  final postService = ref.watch(postServiceProvider);
  final userId = ref.watch(userUidProvider);

  if (userId == null) return null;

  return postService.getUserReaction(postId, userId);
});

// User's reaction to a specific comment
final userCommentReactionProvider = FutureProvider.family<ReactionType?, String>((ref, commentId) async {
  final commentService = ref.watch(commentServiceProvider);
  final userId = ref.watch(userUidProvider);

  if (userId == null) return null;

  return commentService.getUserCommentReaction(commentId, userId);
});

// Community notifier for managing community actions
class CommunityNotifier extends StateNotifier<AsyncValue<void>> {
  final CommunityService _communityService;
  final String? _userId;

  CommunityNotifier(this._communityService, this._userId) : super(const AsyncValue.data(null));

  Future<void> joinCommunity(String communityId) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _communityService.joinCommunity(_userId, communityId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _communityService.leaveCommunity(_userId, communityId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final communityNotifierProvider = StateNotifierProvider<CommunityNotifier, AsyncValue<void>>((ref) {
  final communityService = ref.watch(communityServiceProvider);
  final userId = ref.watch(userUidProvider);
  return CommunityNotifier(communityService, userId);
});

// Post notifier for managing post actions
class PostNotifier extends StateNotifier<AsyncValue<void>> {
  final PostService _postService;
  final String? _userId;

  PostNotifier(this._postService, this._userId) : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String communityId,
    required String title,
    required String content,
    required PostType type,
    required List<String> tags,
  }) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _postService.createPost(
        authorId: _userId,
        authorName: 'User', // TODO: Get actual user name
        communityId: communityId,
        title: title,
        content: content,
        type: type,
        tags: tags,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addReaction(String postId, ReactionType reactionType) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    try {
      await _postService.addReactionToPost(postId, _userId, reactionType);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeReaction(String postId) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    try {
      await _postService.removeReactionFromPost(postId, _userId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> reportPost(String postId, String reason) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    try {
      await _postService.reportPost(postId, _userId, reason);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final postNotifierProvider = StateNotifierProvider<PostNotifier, AsyncValue<void>>((ref) {
  final postService = ref.watch(postServiceProvider);
  final userId = ref.watch(userUidProvider);
  return PostNotifier(postService, userId);
});

// Comment notifier for managing comment actions
class CommentNotifier extends StateNotifier<AsyncValue<void>> {
  final CommentService _commentService;
  final String? _userId;

  CommentNotifier(this._commentService, this._userId) : super(const AsyncValue.data(null));

  Future<void> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _commentService.createComment(
        postId: postId,
        authorId: _userId,
        authorName: 'User', // TODO: Get actual user name
        content: content,
        parentCommentId: parentCommentId,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addReaction(String commentId, ReactionType reactionType) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    try {
      await _commentService.addReactionToComment(commentId, _userId, reactionType);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeReaction(String commentId) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    try {
      await _commentService.removeReactionFromComment(commentId, _userId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> reportComment(String commentId, String reason) async {
    if (_userId == null) {
      state = AsyncValue.error('User not authenticated', StackTrace.current);
      return;
    }

    try {
      await _commentService.reportComment(commentId, _userId, reason);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final commentNotifierProvider = StateNotifierProvider<CommentNotifier, AsyncValue<void>>((ref) {
  final commentService = ref.watch(commentServiceProvider);
  final userId = ref.watch(userUidProvider);
  return CommentNotifier(commentService, userId);
});