import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }

  static String getImagePath(File? selectedImage, XFile? webSelectedImage) {
    if (kIsWeb && webSelectedImage != null) {
      return webSelectedImage.path;
    } else if (!kIsWeb && selectedImage != null) {
      return selectedImage.path;
    }
    return '';
  }

  static String generateFileName() {
    return 'imagem_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  static String generateStoragePath(String fileName) {
    return 'fotos/$fileName';
  }
}