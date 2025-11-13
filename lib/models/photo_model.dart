import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String storagePath;
  final DateTime? timestamp;
  final List<String> sharedWith;
  final List<String> likes;

  PhotoModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.storagePath,
    this.timestamp,
    required this.sharedWith,
    required this.likes,
  });

  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      storagePath: data['storagePath'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'sharedWith': sharedWith,
      'likes': likes,
    };
  }
}