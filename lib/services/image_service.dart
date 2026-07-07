import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }

  static String generateFileName() {
    return 'imagem_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  static String generateStoragePath(String fileName, String userId) {
    return '$userId/$fileName';
  }

  static Future<String> uploadImage({
    required XFile pickedFile,
    required String storagePath,
  }) async {
    final bytes = await pickedFile.readAsBytes();
    final storage = Supabase.instance.client.storage.from(SupabaseConfig.bucketName);

    await storage.uploadBinary(
      storagePath,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );

    return storage.getPublicUrl(storagePath);
  }

  static Future<void> deleteImage(String storagePath) async {
    try {
      await Supabase.instance.client.storage
          .from(SupabaseConfig.bucketName)
          .remove([storagePath]);
    } catch (_) {
    }
  }
}
