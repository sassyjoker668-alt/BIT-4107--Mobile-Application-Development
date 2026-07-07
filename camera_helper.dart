import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      return null;
    }
  }
}