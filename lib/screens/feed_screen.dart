import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/photo_service.dart';
import '../widgets/photo_feed_card.dart';
import '../utils/app_theme.dart';

// Feed público: mostra as fotos para qualquer usuario
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: PhotoService.getFeedPhotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma foto pública ainda\nSeja o primeiro a publicar no feed!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          );
        }

        final photos = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final doc = photos[index];
            final photo = doc.data() as Map<String, dynamic>;
            return PhotoFeedCard(key: ValueKey(doc.id), doc: doc, photo: photo, index: index);
          },
        );
      },
    );
  }
}
