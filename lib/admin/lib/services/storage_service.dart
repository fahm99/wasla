import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wasla_provider/shared/config/env_config.dart';

class StorageService {
  StorageService();

  Future<String?> uploadFile({
    required String bucket,
    required String path,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return _uploadBytes(bucket: bucket, path: path, bytes: bytes);
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    return _uploadBytes(bucket: bucket, path: path, bytes: bytes);
  }

  Future<String?> _uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      final uri = Uri.parse('${EnvConfig.apiUrl}/api/storage/$bucket/$path');
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/octet-stream';
      request.bodyBytes = bytes;

      final response = await http.Response.fromStream(
        await request.send(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return '${EnvConfig.apiUrl}/storage/$bucket/$path';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateFile({
    required String bucket,
    required String path,
    required String filePath,
  }) async {
    return uploadFile(bucket: bucket, path: path, filePath: filePath);
  }

  Future<String?> updateBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    return uploadBytes(bucket: bucket, path: path, bytes: bytes);
  }

  Future<bool> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final uri = Uri.parse('${EnvConfig.apiUrl}/api/storage/$bucket/$path');
      final response = await http.delete(uri);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return '${EnvConfig.apiUrl}/storage/$bucket/$path';
  }

  Future<List<String>> listFiles({
    required String bucket,
    String? path,
  }) async {
    try {
      final queryParams = <String, String>{'bucket': bucket};
      if (path != null) queryParams['path'] = path;

      final uri = Uri.parse('${EnvConfig.apiUrl}/api/storage/list')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> files =
            response.body.isNotEmpty ? response.body as List<dynamic> : [];
        return files.map((f) => f.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
