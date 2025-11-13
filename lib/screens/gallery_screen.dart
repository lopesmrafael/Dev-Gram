import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/photo_service.dart';
import '../widgets/photo_grid_item.dart';
import '../widgets/add_photo_dialog.dart';
import '../utils/dialogs.dart';

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

  void _showAddPhotoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[800],
      builder: (context) => const AddPhotoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('DevGram', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: PhotoService.getUserPhotos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.grey[300]),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma foto ainda\nToque no + para adicionar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final photos = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final doc = photos[index];
              final photo = doc.data() as Map<String, dynamic>;

              return PhotoGridItem(
                doc: doc,
                photo: photo,
                onTap: () => Dialogs.showPhotoDetail(context, photo),
                onLongPress: () => Dialogs.showShareDialog(context, doc.id),
                onDelete: () => _handleDelete(context, doc.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPhotoDialog(context),
        backgroundColor: Colors.grey[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}