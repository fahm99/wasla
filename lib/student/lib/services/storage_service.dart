import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    await _client.storage.from(bucket).uploadBinary(path, bytes);
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  static Future<String> uploadBytes({
    required String bucket,
    required String path,
    required List<int> bytes,
  }) async {
    await _client.storage
        .from(bucket)
        .uploadBinary(path, Uint8List.fromList(bytes));
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }

  static String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  static Future<String?> downloadFile({
    required String bucket,
    required String path,
    required String fileName,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      final bytes = await _client.storage.from(bucket).download(path);
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  static Future<String> uploadAvatar(File imageFile, String userId) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName =
        '$userId/avatar.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    final bytes = await imageFile.readAsBytes();
    await _client.storage.from('avatars').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('avatars').getPublicUrl(fileName);
  }
}
