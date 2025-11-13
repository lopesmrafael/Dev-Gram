import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/photo_model.dart';

class PhotoService {
  static final _photosCollection = FirebaseFirestore.instance.collection('fotos');

  static Stream<QuerySnapshot> getUserPhotos() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _photosCollection
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  static Future<void> addPhoto({
    required String imageUrl,
    required String storagePath,
  }) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    
    await _photosCollection.add({
      'userId': userId,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'timestamp': FieldValue.serverTimestamp(),
      'sharedWith': [],
      'likes': [],
    });
  }

  static Future<void> deletePhoto(String photoId) async {
    await _photosCollection.doc(photoId).delete();
  }

  static Future<void> toggleLike(String photoId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await _photosCollection.doc(photoId).get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      
      await _photosCollection.doc(photoId).update({'likes': likes});
    }
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
}