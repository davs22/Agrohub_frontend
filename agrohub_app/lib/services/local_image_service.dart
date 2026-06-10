import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class LocalImageSelection {
  final String fileName;
  final String base64Data;

  const LocalImageSelection({
    required this.fileName,
    required this.base64Data,
  });
}

class LocalImageService {
  static Future<LocalImageSelection?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    return LocalImageSelection(
      fileName: file.name,
      base64Data: base64Encode(bytes),
    );
  }

  static Uint8List? decodeImage(String? base64Value) {
    if (base64Value == null || base64Value.trim().isEmpty) {
      return null;
    }

    try {
      return base64Decode(base64Value);
    } catch (_) {
      return null;
    }
  }
}
