import 'package:flutter/material.dart';
import '../services/photo_service.dart';

class Dialogs {
  static Future<bool?> showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text('Deletar Foto', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja deletar esta foto?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showShareDialog(BuildContext context, String photoId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text('Compartilhar Foto', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Email do usuário',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await PhotoService.sharePhoto(photoId, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Compartilhar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void showPhotoDetail(BuildContext context, Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[800],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              photo['imageUrl'],
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[700],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 60,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}