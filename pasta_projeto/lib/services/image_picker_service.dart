import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  final ImagePicker _picker = ImagePicker();

  ImagePickerService._internal();

  factory ImagePickerService() {
    return _instance;
  }

  /// Seleciona uma imagem da galeria do dispositivo
  /// Retorna o caminho da imagem ou null se o usuário cancelar
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      return pickedFile?.path;
    } catch (e) {
      print('Erro ao selecionar imagem da galeria: $e');
      return null;
    }
  }

  /// Seleciona uma imagem da câmera do dispositivo
  /// Retorna o caminho da imagem ou null se o usuário cancelar
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      return pickedFile?.path;
    } catch (e) {
      print('Erro ao capturar imagem da câmera: $e');
      return null;
    }
  }

  /// Permite ao usuário escolher entre galeria ou câmera
  /// Retorna o caminho da imagem ou null se o usuário cancelar
  Future<String?> pickImage({
    bool allowCamera = true,
    bool allowGallery = true,
  }) async {
    if (allowCamera && allowGallery) {
      // Usuário pode escolher entre galeria ou câmera
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      return pickedFile?.path;
    } else if (allowCamera) {
      return pickImageFromCamera();
    } else if (allowGallery) {
      return pickImageFromGallery();
    }
    return null;
  }

  /// Verifica se o arquivo de imagem existe
  static bool imageFileExists(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return false;
    return File(imagePath).existsSync();
  }

  /// Retorna uma Uri a partir de um caminho de arquivo
  static Uri? pathToUri(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (!File(imagePath).existsSync()) return null;
    return Uri.file(imagePath);
  }

  /// Obtém o tamanho do arquivo de imagem em bytes
  static int? getImageFileSize(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      return File(imagePath).lengthSync();
    } catch (_) {
      return null;
    }
  }
}
