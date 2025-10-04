// Local file storage service as alternative to Firebase Storage
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Uuid _uuid = const Uuid();

  // Get app documents directory
  Future<Directory> get _appDocDir async {
    return await getApplicationDocumentsDirectory();
  }

  // Create subdirectories for different file types
  Future<Directory> _getSubDirectory(String subDir) async {
    final appDir = await _appDocDir;
    final dir = Directory('${appDir.path}/$subDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // Save file locally and return local path
  Future<String> saveFile({
    required File file,
    required String category, // 'certificates', 'id_documents', 'profile_pictures'
    String? fileName,
  }) async {
    try {
      final dir = await _getSubDirectory(category);
      final extension = file.path.split('.').last;
      final uniqueFileName = fileName ?? '${_uuid.v4()}.$extension';
      final localPath = '${dir.path}/$uniqueFileName';
      
      // Copy file to local storage
      final savedFile = await file.copy(localPath);
      
      // Return the local path (we'll store this in Firestore)
      return savedFile.path;
    } catch (e) {
      throw 'فشل في حفظ الملف محلياً: $e';
    }
  }

  // Save doctor certificate
  Future<String> saveDoctorCertificate(File file, String doctorId) async {
    return await saveFile(
      file: file,
      category: 'certificates',
      fileName: '${doctorId}_cert_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
    );
  }

  // Save ID document
  Future<String> saveIdDocument(File file, String userId) async {
    return await saveFile(
      file: file,
      category: 'id_documents',
      fileName: '${userId}_id_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
    );
  }

  // Save profile picture
  Future<String> saveProfilePicture(File file, String userId) async {
    return await saveFile(
      file: file,
      category: 'profile_pictures',
      fileName: '${userId}_profile.${file.path.split('.').last}',
    );
  }

  // Get file from local storage
  Future<File?> getFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting local file: $e');
      return null;
    }
  }

  // Check if file exists locally
  Future<bool> fileExists(String localPath) async {
    try {
      final file = File(localPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Delete file from local storage
  Future<void> deleteFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting local file: $e');
    }
  }

  // Get file size
  Future<int> getFileSize(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get file as bytes (for sharing or uploading)
  Future<Uint8List?> getFileBytes(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading file bytes: $e');
      return null;
    }
  }

  // Create file hash for integrity checking
  Future<String> getFileHash(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final digest = sha256.convert(bytes);
        return digest.toString();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // Get all files in a category
  Future<List<File>> getFilesInCategory(String category) async {
    try {
      final dir = await _getSubDirectory(category);
      final files = <File>[];
      
      await for (final entity in dir.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }
      
      return files;
    } catch (e) {
      print('Error getting files in category: $e');
      return [];
    }
  }

  // Clean up old files (for maintenance)
  Future<void> cleanupOldFiles({int daysOld = 30}) async {
    try {
      final categories = ['certificates', 'id_documents', 'profile_pictures'];
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      for (final category in categories) {
        final files = await getFilesInCategory(category);
        for (final file in files) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            print('Deleted old file: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  // Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final categories = ['certificates', 'id_documents', 'profile_pictures'];
      final stats = <String, dynamic>{};
      int totalSize = 0;
      int totalFiles = 0;
      
      for (final category in categories) {
        final files = await getFilesInCategory(category);
        int categorySize = 0;
        
        for (final file in files) {
          final size = await file.length();
          categorySize += size;
        }
        
        stats[category] = {
          'files': files.length,
          'size': categorySize,
          'sizeFormatted': _formatBytes(categorySize),
        };
        
        totalSize += categorySize;
        totalFiles += files.length;
      }
      
      stats['total'] = {
        'files': totalFiles,
        'size': totalSize,
        'sizeFormatted': _formatBytes(totalSize),
      };
      
      return stats;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Backup files to external storage (if available)
  Future<bool> backupToExternalStorage() async {
    try {
      // This would require additional permissions and implementation
      // For now, just return true as placeholder
      return true;
    } catch (e) {
      print('Backup failed: $e');
      return false;
    }
  }
}