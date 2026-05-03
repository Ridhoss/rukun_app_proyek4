import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  Future<String?> uploadFile(File file) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$_cloudName/upload",
      );

      final request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = _uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = json.decode(resBody);

        return data['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}