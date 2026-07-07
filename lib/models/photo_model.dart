import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String userId;
  final String userEmail;
  final String imageUrl;
  final String storagePath;
  final DateTime? timestamp;
  final bool isPublic;
  final List<String> sharedWith;
  final List<String> likes;
  final int commentsCount;

  PhotoModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.imageUrl,
    required this.storagePath,
    this.timestamp,
    required this.isPublic,
    required this.sharedWith,
    required this.likes,
    this.commentsCount = 0,
  });

  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      storagePath: data['storagePath'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isPublic: data['isPublic'] ?? false,
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'likes': likes,
      'commentsCount': commentsCount,
    };
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String userEmail;
  final String text;
  final DateTime? timestamp;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.text,
    this.timestamp,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
