import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/photo_service.dart';
import '../utils/app_theme.dart';
import 'like_animations.dart';

class PhotoGridItem extends StatelessWidget {
  final DocumentSnapshot doc;
  final Map<String, dynamic> photo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const PhotoGridItem({
    super.key,
    required this.doc,
    required this.photo,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  Widget _pill({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final likes = List<String>.from(photo['likes'] ?? []);
    final isLiked = likes.contains(userId);
    final commentsCount = photo['commentsCount'] ?? 0;
    final isPublic = photo['isPublic'] ?? false;
    final isOwner = photo['userId'] == userId;

    void likeOnce() {
      if (!isLiked) PhotoService.toggleLike(doc.id);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Positioned.fill(
            child: DoubleTapHeart(
              onLike: likeOnce,
              heartSize: 50,
              child: Material(
                color: AppTheme.surfaceColor,
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Image.network(
                    photo['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 32);
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Icon(
              isPublic ? Icons.public : Icons.lock_outline,
              color: Colors.white,
              size: 14,
              shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
            ),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            child: _pill(
              children: [
                AnimatedLikeButton(isLiked: isLiked, onTap: () => PhotoService.toggleLike(doc.id), size: 13),
                const SizedBox(width: 3),
                Text('${likes.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.mode_comment_outlined, color: Colors.white, size: 12),
                const SizedBox(width: 3),
                Text('$commentsCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (isOwner)
            Positioned(
              right: 6,
              bottom: 6,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
