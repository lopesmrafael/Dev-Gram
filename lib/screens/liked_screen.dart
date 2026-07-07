import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/photo_service.dart';
import '../widgets/photo_grid_item.dart';
import '../utils/dialogs.dart';
import '../utils/app_theme.dart';

class LikedScreen extends StatelessWidget {
  const LikedScreen({super.key});

  Future<void> _handleDelete(BuildContext context, String photoId) async {
    final confirm = await Dialogs.showDeleteConfirmation(context);
    if (confirm != true) return;

    try {
      await PhotoService.deletePhoto(photoId);
      if (context.mounted) {
        Dialogs.showSnackBar(context, 'Foto deletada com sucesso');
      }
    } catch (e) {
      if (context.mounted) {
        Dialogs.showSnackBar(context, 'Erro ao deletar foto', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: PhotoService.getLikedPhotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Erro ao carregar curtidas: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Você ainda não curtiu nenhuma foto\nToque no ❤️ de uma foto do feed',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ),
          );
        }

        final photos = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(6),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final doc = photos[index];
            final photo = doc.data() as Map<String, dynamic>;

            return PhotoGridItem(
              key: ValueKey(doc.id),
              doc: doc,
              photo: photo,
              onTap: () => Dialogs.showPhotoDetail(context, photo, doc.id),
              onLongPress: () => Dialogs.showShareDialog(context, doc.id),
              onDelete: () => _handleDelete(context, doc.id),
            );
          },
        );
      },
    );
  }
}
