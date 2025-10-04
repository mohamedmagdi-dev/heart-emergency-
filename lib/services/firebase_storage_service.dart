// CHANGED_FOR_FIREBASE_INTEGRATION: Firebase Storage service for document uploads
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload file (certificate, ID, profile picture, etc.)
  Future<String> uploadFile({
    required File file,
    required String folderPath,
    String? fileName,
  }) async {
    try {
      final extension = path.extension(file.path);
      final uniqueFileName = fileName ?? '${_uuid.v4()}$extension';
      final fullPath = '$folderPath/$uniqueFileName';

      final ref = _storage.ref().child(fullPath);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(extension),
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'فشل رفع الملف: $e';
    }
  }

  // Upload doctor certificate
  Future<String> uploadDoctorCertificate(File file, String doctorId) async {
    return await uploadFile(
      file: file,
      folderPath: 'certificates/$doctorId',
    );
  }

  // Upload ID document
  Future<String> uploadIdDocument(File file, String userId) async {
    return await uploadFile(
      file: file,
      folderPath: 'ids/$userId',
    );
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(File file, String userId) async {
    return await uploadFile(
      file: file,
      folderPath: 'profiles/$userId',
      fileName: 'profile.jpg',
    );
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw 'فشل حذف الملف: $e';
    }
  }

  // Delete folder
  Future<void> deleteFolder(String folderPath) async {
    try {
      final listResult = await _storage.ref(folderPath).listAll();
      
      for (final item in listResult.items) {
        await item.delete();
      }
      
      for (final prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }
    } catch (e) {
      throw 'فشل حذف المجلد: $e';
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      return await ref.getMetadata();
    } catch (e) {
      throw 'فشل جلب معلومات الملف: $e';
    }
  }

  // Get content type based on extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}

