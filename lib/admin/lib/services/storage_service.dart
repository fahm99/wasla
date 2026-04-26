import 'dart:typed_data';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  Future<String?> uploadFile({
    required String bucket,
    required String path,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      await _client.storage.from(bucket).uploadBinary(path, bytes);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(path, bytes);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateFile({
    required String bucket,
    required String path,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      await _client.storage.from(bucket).updateBinary(path, bytes);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      await _client.storage.from(bucket).updateBinary(path, bytes);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      return false;
    }
  }

  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<List<String>> listFiles({
    required String bucket,
    String? path,
  }) async {
    try {
      final files = await _client.storage.from(bucket).list(path: path);
      return files.map((f) => f.name).toList();
    } catch (e) {
      return [];
    }
  }
}
