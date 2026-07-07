import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'image_service.dart';

class PhotoService {
  static final _photosCollection = FirebaseFirestore.instance.collection('fotos');

  static Stream<QuerySnapshot> getMyPhotos() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _photosCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getFeedPhotos() {
    return _photosCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getLikedPhotos() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _photosCollection
        .where('likes', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> addPhoto({
    required String imageUrl,
    required String storagePath,
    required bool isPublic,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    await _photosCollection.add({
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'timestamp': FieldValue.serverTimestamp(),
      'isPublic': isPublic,
      'sharedWith': [],
      'likes': [],
      'commentsCount': 0,
    });
  }

  static Future<void> deletePhoto(String photoId) async {
    final docRef = _photosCollection.doc(photoId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final storagePath = data['storagePath'] as String?;
      if (storagePath != null && storagePath.isNotEmpty) {
        await ImageService.deleteImage(storagePath);
      }
    }

    await docRef.delete();
  }

  static Future<void> toggleLike(String photoId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = _photosCollection.doc(photoId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      transaction.update(docRef, {'likes': likes});
    });
  }

  static Future<void> sharePhoto(String photoId, String email) async {
    final doc = await _photosCollection.doc(photoId).get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final sharedWith = List<String>.from(data['sharedWith'] ?? []);

      if (!sharedWith.contains(email)) {
        sharedWith.add(email);
        await _photosCollection.doc(photoId).update({'sharedWith': sharedWith});
      }
    }
  }

  static Stream<QuerySnapshot> getComments(String photoId) {
    return _photosCollection
    .doc(photoId)
    .collection('comentarios')
    .orderBy('timestamp', descending: false)
    .snapshots();
  }

  static Future<void> addComment(String photoId, String text) async {
    final user = FirebaseAuth.instance.currentUser!;
    final photoRef = _photosCollection.doc(photoId);
    final commentRef = photoRef.collection('comentarios').doc();

    final batch = FirebaseFirestore.instance.batch();
    batch.set(commentRef, {
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    batch.update(photoRef, {'commentsCount': FieldValue.increment(1)});

    await batch.commit();
  }

  static Future<void> deleteComment(String photoId, String commentId) async {
    final photoRef = _photosCollection.doc(photoId);
    final commentRef = photoRef.collection('comentarios').doc(commentId);

    final batch = FirebaseFirestore.instance.batch();
    batch.delete(commentRef);
    batch.update(photoRef, {'commentsCount': FieldValue.increment(-1)});

    await batch.commit();
  }
}
