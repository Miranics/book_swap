import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService({required SupabaseClient client, required String bucketName})
      : _client = client,
        _bucketName = bucketName;

  final SupabaseClient _client;
  final String _bucketName;

  Future<String> uploadBookCover({
    required XFile file,
    required String userId,
  }) async {
    final Uint8List bytes = await file.readAsBytes();
    final String extension = _resolveExtension(file);
    final String objectPath = _buildObjectPath(userId, extension);

    await _client.storage.from(_bucketName).uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            contentType: _resolveMimeType(extension),
            upsert: false,
          ),
        );

    return _client.storage.from(_bucketName).getPublicUrl(objectPath);
  }

  String _buildObjectPath(String userId, String extension) {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'book_covers/$userId/cover_$timestamp.$extension';
  }

  String _resolveExtension(XFile file) {
    final String? name = file.name.isNotEmpty ? file.name : null;
    final String rawExtension =
        name != null ? p.extension(name).replaceFirst('.', '') : '';
    if (rawExtension.isNotEmpty) {
      return rawExtension;
    }
    final String pathExtension = p.extension(file.path).replaceFirst('.', '');
    return pathExtension.isNotEmpty ? pathExtension : 'jpg';
  }

  String _resolveMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
