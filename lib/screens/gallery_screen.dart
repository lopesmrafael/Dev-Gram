import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/photo_service.dart';
import '../widgets/photo_grid_item.dart';
import '../utils/dialogs.dart';
import '../utils/app_theme.dart';

/// Grade com as fotos publicadas pelo usuário logado (públicas e privadas).
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

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
      stream: PhotoService.getMyPhotos(),
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
              'Você ainda não publicou nenhuma foto\nToque no + para adicionar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
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
