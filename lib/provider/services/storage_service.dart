import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadFile({
    required File file,
    required String bucket,
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      final fullPath = path.substring(
          0, path.lastIndexOf('/') > 0 ? path.lastIndexOf('/') : 0);

      final result = await _supabase.storage.from(bucket).upload(
            '$fullPath/$fileName',
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // Simulate progress since supabase doesn't provide real progress
      if (onProgress != null) {
        for (double i = 0; i <= 1.0; i += 0.1) {
          await Future.delayed(const Duration(milliseconds: 50));
          onProgress(i.clamp(0, 1.0));
        }
      }

      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(result);
      return publicUrl;
    } catch (e) {
      throw Exception('فشل في رفع الملف: ${e.toString()}');
    }
  }

  Future<String> uploadImage({
    required File file,
    required String folder,
    void Function(double)? onProgress,
  }) async {
    return uploadFile(
      file: file,
      bucket: AppConstants.bucketCourseImages,
      path: '$folder/${file.uri.pathSegments.last}',
      onProgress: onProgress,
    );
  }

  Future<String> uploadVideo({
    required File file,
    required String folder,
    void Function(double)? onProgress,
  }) async {
    return uploadFile(
      file: file,
      bucket: AppConstants.bucketCourseVideos,
      path: '$folder/${file.uri.pathSegments.last}',
      onProgress: onProgress,
    );
  }

  Future<String> uploadDocument({
    required File file,
    required String folder,
    void Function(double)? onProgress,
  }) async {
    return uploadFile(
      file: file,
      bucket: AppConstants.bucketCourseFiles,
      path: '$folder/${file.uri.pathSegments.last}',
      onProgress: onProgress,
    );
  }

  Future<String> uploadAudio({
    required File file,
    required String folder,
    void Function(double)? onProgress,
  }) async {
    return uploadFile(
      file: file,
      bucket: AppConstants.bucketCourseAudio,
      path: '$folder/${file.uri.pathSegments.last}',
      onProgress: onProgress,
    );
  }

  Future<String> uploadAvatar({
    required File file,
    required String userId,
    void Function(double)? onProgress,
  }) async {
    return uploadFile(
      file: file,
      bucket: AppConstants.bucketAvatars,
      path: '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      onProgress: onProgress,
    );
  }

  Future<String> uploadPaymentProof({
    required File file,
    required String userId,
    void Function(double)? onProgress,
  }) async {
    return uploadFile(
      file: file,
      bucket: AppConstants.bucketPaymentProofs,
      path: '$userId/proof_${DateTime.now().millisecondsSinceEpoch}.jpg',
      onProgress: onProgress,
    );
  }

  Future<String> uploadCertificateFile({
    required File file,
    required String providerId,
    void Function(double)? onProgress,
  }) async {
    return uploadFile(
      file: file,
      bucket: AppConstants.bucketCertificates,
      path: '$providerId/cert_${DateTime.now().millisecondsSinceEpoch}.png',
      onProgress: onProgress,
    );
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      throw Exception('فشل في حذف الملف: ${e.toString()}');
    }
  }

  String getBucketForFileType(String type) {
    switch (type) {
      case AppConstants.lessonTypeVideo:
        return AppConstants.bucketCourseVideos;
      case AppConstants.lessonTypePdf:
      case AppConstants.lessonTypeDocument:
        return AppConstants.bucketCourseFiles;
      case AppConstants.lessonTypeAudio:
        return AppConstants.bucketCourseAudio;
      case AppConstants.lessonTypeImage:
        return AppConstants.bucketCourseImages;
      default:
        return AppConstants.bucketCourseFiles;
    }
  }
}
