import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import '../services/photo_service.dart';

class AddPhotoDialog extends StatefulWidget {
  const AddPhotoDialog({super.key});

  @override
  State<AddPhotoDialog> createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  File? _selectedImage;
  XFile? _webSelectedImage;

  Future<void> _pickImage() async {
    final picked = await ImageService.pickImage();
    if (picked == null) return;

    if (kIsWeb) {
      setState(() => _webSelectedImage = picked);
    } else {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _addPhoto() async {
    if (_selectedImage == null && _webSelectedImage == null) return;

    try {
      final localPath = ImageService.getImagePath(_selectedImage, _webSelectedImage);
      final fileName = ImageService.generateFileName();
      final storagePath = ImageService.generateStoragePath(fileName);

      await PhotoService.addPhoto(
        imageUrl: localPath,
        storagePath: storagePath,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao adicionar foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null || _webSelectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb && _webSelectedImage != null
                  ? Image.network(_webSelectedImage!.path, height: 200, fit: BoxFit.cover)
                  : Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _webSelectedImage = null;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Publicar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_camera, color: Colors.white, size: 24),
              label: const Text(
                'Selecionar Foto',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ],
      ),
    );
  }
}