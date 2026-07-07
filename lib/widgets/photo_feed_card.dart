import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/photo_service.dart';
import '../utils/app_theme.dart';
import '../utils/user_display.dart';
import 'comments_sheet.dart';
import 'like_animations.dart';

class PhotoFeedCard extends StatefulWidget {
  final DocumentSnapshot doc;
  final Map<String, dynamic> photo;

  final int index;

  const PhotoFeedCard({super.key, required this.doc, required this.photo, this.index = 0});

  @override
  State<PhotoFeedCard> createState() => _PhotoFeedCardState();
}

class _PhotoFeedCardState extends State<PhotoFeedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 60 * widget.index.clamp(0, 6));
    Future.delayed(delay, () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final likes = List<String>.from(widget.photo['likes'] ?? []);
    final isLiked = likes.contains(currentUserId);
    final commentsCount = widget.photo['commentsCount'] ?? 0;
    final userEmail = widget.photo['userEmail'] ?? '';
    final handle = UserDisplay.handle(userEmail);

    void likeOnce() {
      if (!isLiked) PhotoService.toggleLike(widget.doc.id);
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.accent.withOpacity(0.25),
                      child: Text(
                        UserDisplay.initial(userEmail),
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        handle,
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DoubleTapHeart(
                    onLike: likeOnce,
                    heartSize: 90,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        widget.photo['imageUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppTheme.surfaceColor,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppTheme.surfaceColor,
                          child: const Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AnimatedLikeButton(
                      isLiked: isLiked,
                      onTap: () => PhotoService.toggleLike(widget.doc.id),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => CommentsSheet.show(context, widget.doc.id, widget.photo['userId']),
                      child: const Icon(Icons.mode_comment_outlined, color: AppTheme.textPrimary, size: 22),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${likes.length} curtida${likes.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(height: 4),
              if (commentsCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => CommentsSheet.show(context, widget.doc.id, widget.photo['userId']),
                    child: Text(
                      'Ver ${commentsCount == 1 ? 'o comentário' : 'os $commentsCount comentários'}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
