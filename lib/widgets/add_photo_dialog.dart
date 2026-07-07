import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/image_service.dart';
import '../services/photo_service.dart';
import '../utils/app_theme.dart';

class AddPhotoDialog extends StatefulWidget {
  const AddPhotoDialog({super.key});

  @override
  State<AddPhotoDialog> createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  XFile? _picked;
  bool _isPublic = true;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImageService.pickImage();
    if (picked == null) return;
    setState(() => _picked = picked);
  }

  Future<void> _addPhoto() async {
    if (_picked == null || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final fileName = ImageService.generateFileName();
      final storagePath = ImageService.generateStoragePath(fileName, userId);

      // Upload real do arquivo para o Firebase Storage.
      final downloadUrl = await ImageService.uploadImage(
        pickedFile: _picked!,
        storagePath: storagePath,
      );

      await PhotoService.addPhoto(
        imageUrl: downloadUrl,
        storagePath: storagePath,
        isPublic: _isPublic,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao adicionar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao publicar foto: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildVisibilityToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _visibilityOption(
              label: 'Só eu',
              icon: Icons.lock_outline,
              selected: !_isPublic,
              onTap: () => setState(() => _isPublic = false),
            ),
          ),
          Expanded(
            child: _visibilityOption(
              label: 'Todos (Feed)',
              icon: Icons.public,
              selected: _isPublic,
              onTap: () => setState(() => _isPublic = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visibilityOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_picked != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(_picked!.path, height: 200, fit: BoxFit.cover, width: double.infinity)
                  : Image.file(File(_picked!.path), height: 200, fit: BoxFit.cover, width: double.infinity),
            ),
            const SizedBox(height: 16),
            _buildVisibilityToggle(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : () {
                            setState(() => _picked = null);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _addPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Publicar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_camera, color: Colors.white, size: 24),
              label: const Text('Selecionar Foto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
