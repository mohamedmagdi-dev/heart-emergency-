// // Image upload service for handling local images to Firebase Storage
// import 'dart:io';
// import 'package:path/path.dart' as path;
// import 'package:uuid/uuid.dart';
// import 'firebase_storage_service.dart';
//
// class ImageUploadService {
//   static final ImageUploadService _instance = ImageUploadService._internal();
//   factory ImageUploadService() => _instance;
//   ImageUploadService._internal();
//
//   final FirebaseStorageService _storageService = FirebaseStorageService();
//
//   // Check if a path is a local file path
//   bool isLocalFilePath(String? path) {
//     if (path == null || path.isEmpty) return false;
//     return path.startsWith('file://') || path.startsWith('/') || path.contains(':\\');
//   }
//
//   // Upload local image to Firebase Storage and return download URL
//   Future<String> uploadLocalImageToStorage(String localPath, {String? userId}) async {
//     try {
//       // Remove file:// prefix if present
//       String cleanPath = localPath.replaceFirst('file://', '');
//
//       // Create a File object from the path
//       final file = File(cleanPath);
//
//       // Determine folder path based on file type or use a default
//       String folderPath = 'images';
//       if (userId != null) {
//         folderPath = 'users/$userId/images';
//       }
//
//       // Generate a unique filename using the original extension
//       final extension = path.extension(cleanPath);
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
//
//       // Upload to Firebase Storage
//       final downloadUrl = await _storageService.uploadFile(
//         file: file,
//         folderPath: folderPath,
//         fileName: fileName,
//       );
//
//       return downloadUrl;
//     } catch (e) {
//       throw 'فشل في رفع الصورة: $e';
//     }
//   }
// // fire base upload folder
//   // 📍 Inside ImageUploadService.dart
//
// // Final method for uploading any local file (Image, PDF, Document) to Firebase Storage
//   Future<String> uploadLocalFileToStorage(
//       String localPath,
//       {required String storageFolder} // Use a required folder for better organization
//       ) async {
//     try {
//       // 1. IMPROVED PATH CLEANING: Handle file:// and file:/// prefixes
//       String cleanPath = localPath.replaceFirst('file:///', '').replaceFirst('file://', '');
//
//       // 2. FILE OBJECT CREATION
//       final file = File(cleanPath);
//
//       // 3. CHECK FILE EXISTENCE
//       if (!await file.exists()) {
//         // Throw a specific error if the local file is missing
//         throw 'الملف المحلي غير موجود: $localPath';
//       }
//
//       // 4. DETERMINE FILE NAME AND EXTENSION
//       final extension = path.extension(cleanPath);
//       // Use the current timestamp and a unique ID for the filename
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}$extension';
//
//       // 5. UPLOAD TO FIREBASE STORAGE using the injected service
//       // Note: The uploadFile in FirebaseStorageService will handle the fullPath construction
//       final downloadUrl = await _storageService.uploadFile(
//         file: file,
//         folderPath: storageFolder, // Use the provided specific folder (e.g., 'certificates/user_id')
//         fileName: fileName,
//       );
//
//       return downloadUrl;
//     } catch (e) {
//       // Catch the error and rethrow a meaningful message
//       throw 'فشل في رفع الملف إلى السحابة: $e';
//     }
//   }
//
// // ⚠️ Note: The old method uploadLocalImageToStorage is now obsolete.
// // You should rename it to the function above, or delete it and create the one above.
// // The rest of the ImageUploadService methods (like processImagePathsInMap) look fine for general processing.
//
//
//
//   // Process any image paths in a map, uploading local images to Firebase Storage
//   Future<Map<String, dynamic>> processImagePathsInMap(
//     Map<String, dynamic> data,
//     {String? userId, List<String>? imageFieldKeys}
//   ) async {
//     // Create a copy of the data to modify
//     final Map<String, dynamic> processedData = Map.from(data);
//
//     // Default image field keys to check if not provided
//     final keysToCheck = imageFieldKeys ?? ['image', 'imageUrl', 'profileImage', 'photo', 'picture'];
//
//     // Process each field that might contain an image path
//     for (final key in processedData.keys.toList()) {
//       final value = processedData[key];
//
//       // Check if this is a field that might contain an image
//       if (value is String &&
//           (keysToCheck.contains(key) || key.toLowerCase().contains('image') || key.toLowerCase().contains('photo'))) {
//
//         // If it's a local file path, upload it and replace with download URL
//         if (isLocalFilePath(value)) {
//           final downloadUrl = await uploadLocalImageToStorage(value, userId: userId);
//           processedData[key] = downloadUrl;
//         }
//       }
//
//       // Handle lists of images
//       if (value is List &&
//           (key.toLowerCase().contains('image') || key.toLowerCase().contains('photo') || key.toLowerCase().contains('picture'))) {
//
//         List<dynamic> processedList = [];
//         for (final item in value) {
//           if (item is String && isLocalFilePath(item)) {
//             final downloadUrl = await uploadLocalImageToStorage(item, userId: userId);
//             processedList.add(downloadUrl);
//           } else {
//             processedList.add(item);
//           }
//         }
//         processedData[key] = processedList;
//       }
//     }
//
//     return processedData;
//   }
// }
// lib/services/image_upload_service.dart

// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:path/path.dart' as path;
//
// class ImageUploadService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   /// رفع ملف محلي إلى Firebase Storage
//   /// [localFilePath] مسار الملف المحلي
//   /// [storageFolder] المجلد في Storage (مثال: certificates/userId)
//   Future<String> uploadLocalFileToStorage(
//       String localFilePath, {
//         required String storageFolder,
//         Function(double)? onProgress,
//       }) async {
//     try {
//       // التأكد من وجود المستخدم
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         throw 'يجب تسجيل الدخول أولاً';
//       }
//
//       // التأكد من وجود الملف
//       final file = File(localFilePath);
//       if (!await file.exists()) {
//         throw 'الملف غير موجود: $localFilePath';
//       }
//
//       // استخراج اسم الملف وامتداده
//       final fileName = path.basename(localFilePath);
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileExtension = path.extension(fileName);
//       final uniqueFileName = '${timestamp}_${currentUser.uid}$fileExtension';
//
//       // بناء المسار الكامل في Storage
//       final storagePath = '$storageFolder/$uniqueFileName';
//
//       print('🔄 بدء رفع الملف إلى: $storagePath');
//
//       // إنشاء Reference للملف في Storage
//       final storageRef = _storage.ref().child(storagePath);
//
//       // رفع الملف مع متابعة التقدم
//       final uploadTask = storageRef.putFile(file);
//
//       // الاستماع لتقدم الرفع
//       uploadTask.snapshotEvents.listen((taskSnapshot) {
//         final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
//         if (onProgress != null) {
//           onProgress(progress);
//         }
//         print('📊 تقدم الرفع: ${(progress * 100).toStringAsFixed(1)}%');
//       });
//
//       // انتظار اكتمال الرفع
//       final snapshot = await uploadTask;
//
//       // الحصول على رابط التحميل
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//
//       print('✅ تم رفع الملف بنجاح: $downloadUrl');
//
//       return downloadUrl;
//     } on FirebaseException catch (e) {
//       print('❌ خطأ Firebase: ${e.code} - ${e.message}');
//       throw _handleFirebaseStorageError(e);
//     } catch (e) {
//       print('❌ خطأ عام: $e');
//       throw 'فشل رفع الملف: $e';
//     }
//   }
//
//   /// رفع عدة ملفات دفعة واحدة
//   Future<List<String>> uploadMultipleFiles(
//       List<String> filePaths, {
//         required String storageFolder,
//         Function(int, int)? onProgress,
//       }) async {
//     final uploadedUrls = <String>[];
//
//     for (int i = 0; i < filePaths.length; i++) {
//       try {
//         final url = await uploadLocalFileToStorage(
//           filePaths[i],
//           storageFolder: storageFolder,
//         );
//         uploadedUrls.add(url);
//
//         if (onProgress != null) {
//           onProgress(i + 1, filePaths.length);
//         }
//       } catch (e) {
//         print('❌ فشل رفع الملف ${i + 1}: $e');
//         // يمكنك اختيار: إما التوقف أو المتابعة
//         rethrow; // سيتوقف عند أول خطأ
//       }
//     }
//
//     return uploadedUrls;
//   }
//
//   /// حذف ملف من Storage
//   Future<void> deleteFile(String downloadUrl) async {
//     try {
//       final ref = _storage.refFromURL(downloadUrl);
//       await ref.delete();
//       print('✅ تم حذف الملف بنجاح');
//     } on FirebaseException catch (e) {
//       print('❌ خطأ في حذف الملف: ${e.code} - ${e.message}');
//       throw _handleFirebaseStorageError(e);
//     }
//   }
//
//   /// حذف عدة ملفات
//   Future<void> deleteMultipleFiles(List<String> downloadUrls) async {
//     for (final url in downloadUrls) {
//       try {
//         await deleteFile(url);
//       } catch (e) {
//         print('❌ فشل حذف الملف: $url');
//         // المتابعة لحذف باقي الملفات
//       }
//     }
//   }
//
//   /// معالجة أخطاء Firebase Storage
//   String _handleFirebaseStorageError(FirebaseException e) {
//     switch (e.code) {
//       case 'storage/unauthorized':
//         return 'ليس لديك صلاحية لرفع الملفات. تأكد من تسجيل الدخول.';
//       case 'storage/canceled':
//         return 'تم إلغاء عملية الرفع';
//       case 'storage/unknown':
//         return 'حدث خطأ غير معروف أثناء رفع الملف';
//       case 'storage/object-not-found':
//         return 'الملف غير موجود';
//       case 'storage/bucket-not-found':
//         return 'Firebase Storage غير متوفر';
//       case 'storage/project-not-found':
//         return 'مشروع Firebase غير موجود';
//       case 'storage/quota-exceeded':
//         return 'تم تجاوز الحد المسموح من المساحة';
//       case 'storage/unauthenticated':
//         return 'يجب تسجيل الدخول أولاً';
//       case 'storage/retry-limit-exceeded':
//         return 'فشل الرفع بعد عدة محاولات';
//       case 'storage/invalid-checksum':
//         return 'الملف تالف أو معطوب';
//       default:
//         return 'خطأ في رفع الملف: ${e.message ?? e.code}';
//     }
//   }
// }
// lib/services/image_upload_service.dart
// lib/services/image_upload_service.dart - مع إعادة المحاولة
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// رفع ملف محلي إلى Firebase Storage مع إعادة المحاولة
  Future<String> uploadLocalFileToStorage(
      String localFilePath, {
        required String storageFolder,
        Function(double)? onProgress,
        int maxRetries = 3, // عدد المحاولات
      }) async {
    int attempt = 0;
    Exception? lastError;

    while (attempt < maxRetries) {
      try {
        attempt++;
        print('🔄 محاولة الرفع #$attempt...');

        // التأكد من وجود المستخدم
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          throw Exception('يجب تسجيل الدخول أولاً');
        }

        // تنظيف المسار
        String cleanPath = localFilePath
            .replaceFirst('file:///', '')
            .replaceFirst('file://', '');

        // التأكد من وجود الملف
        final file = File(cleanPath);
        if (!await file.exists()) {
          throw Exception('الملف غير موجود: $localFilePath');
        }

        // استخراج معلومات الملف
        final fileName = path.basename(cleanPath);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileExtension = path.extension(fileName);
        final uniqueFileName = '${timestamp}_${currentUser.uid}$fileExtension';

        // بناء المسار في Storage
        final storagePath = '$storageFolder/$uniqueFileName';

        print('📁 المسار: $storagePath');

        // إنشاء Reference
        final storageRef = _storage.ref().child(storagePath);

        // رفع الملف
        final uploadTask = storageRef.putFile(
          file,
          SettableMetadata(
            contentType: _getContentType(fileExtension),
          ),
        );

        // متابعة التقدم
        uploadTask.snapshotEvents.listen((taskSnapshot) {
          final progress =
              taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          if (onProgress != null) {
            onProgress(progress);
          }
          print('📊 تقدم: ${(progress * 100).toStringAsFixed(1)}%');
        });

        // انتظار اكتمال الرفع
        final snapshot = await uploadTask;

        // الحصول على رابط التحميل
        final downloadUrl = await snapshot.ref.getDownloadURL();

        print('✅ تم الرفع بنجاح في المحاولة #$attempt');
        return downloadUrl;

      } on FirebaseException catch (e) {
        lastError = e;
        print('❌ المحاولة #$attempt فشلت: ${e.code} - ${e.message}');

        // إذا كان الخطأ 404، انتظر قليلاً قبل المحاولة مرة أخرى
        if (e.code == 'object-not-found' && attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }

        // أخطاء أخرى لا تحتاج retry
        if (e.code == 'unauthorized' || e.code == 'unauthenticated') {
          throw Exception(_handleFirebaseStorageError(e));
        }

      } catch (e) {
        lastError = e as Exception?;
        print('❌ خطأ عام في المحاولة #$attempt: $e');

        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
      }
    }

    // إذا فشلت كل المحاولات
    throw Exception(
      'فشل رفع الملف بعد $maxRetries محاولات. آخر خطأ: ${lastError?.toString() ?? "غير معروف"}',
    );
  }

  /// تحديد نوع المحتوى بناءً على الامتداد
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

  /// رفع عدة ملفات
  Future<List<String>> uploadMultipleFiles(
      List<String> filePaths, {
        required String storageFolder,
        Function(int, int)? onProgress,
      }) async {
    final uploadedUrls = <String>[];

    for (int i = 0; i < filePaths.length; i++) {
      try {
        print('📤 رفع الملف ${i + 1}/${filePaths.length}...');

        final url = await uploadLocalFileToStorage(
          filePaths[i],
          storageFolder: storageFolder,
        );

        uploadedUrls.add(url);

        if (onProgress != null) {
          onProgress(i + 1, filePaths.length);
        }
      } catch (e) {
        print('❌ فشل رفع الملف ${i + 1}: $e');
        rethrow;
      }
    }

    return uploadedUrls;
  }

  /// حذف ملف
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      print('✅ تم حذف الملف');
    } on FirebaseException catch (e) {
      throw Exception(_handleFirebaseStorageError(e));
    }
  }

  /// حذف عدة ملفات
  Future<void> deleteMultipleFiles(List<String> downloadUrls) async {
    for (final url in downloadUrls) {
      try {
        await deleteFile(url);
      } catch (e) {
        print('⚠️ تجاهل خطأ حذف: $e');
      }
    }
  }

  /// التحقق من مسار محلي
  bool isLocalFilePath(String? path) {
    if (path == null || path.isEmpty) return false;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return false;
    }
    return path.startsWith('file://') ||
        path.startsWith('/') ||
        path.contains(':\\');
  }

  /// معالجة الصور في Map
  Future<Map<String, dynamic>> processImagePathsInMap(
      Map<String, dynamic> data, {
        String? userId,
        List<String>? imageFieldKeys,
      }) async {
    final Map<String, dynamic> processedData = Map.from(data);

    final keysToCheck = imageFieldKeys ??
        [
          'image',
          'imageUrl',
          'profileImage',
          'photo',
          'picture',
          'avatar',
          'thumbnail'
        ];

    for (final key in processedData.keys.toList()) {
      final value = processedData[key];

      // معالجة String واحد
      if (value is String &&
          (keysToCheck.contains(key) ||
              key.toLowerCase().contains('image') ||
              key.toLowerCase().contains('photo') ||
              key.toLowerCase().contains('picture'))) {
        if (isLocalFilePath(value)) {
          try {
            final downloadUrl = await uploadLocalFileToStorage(
              value,
              storageFolder: userId != null ? 'users/$userId/images' : 'images',
            );
            processedData[key] = downloadUrl;
            print('✅ تم رفع الصورة: $key');
          } catch (e) {
            print('❌ فشل رفع الصورة $key: $e');
            rethrow;
          }
        }
      }

      // معالجة قائمة
      if (value is List &&
          (key.toLowerCase().contains('image') ||
              key.toLowerCase().contains('photo') ||
              key.toLowerCase().contains('picture') ||
              key.toLowerCase().contains('certificate'))) {
        List<dynamic> processedList = [];

        for (final item in value) {
          if (item is String && isLocalFilePath(item)) {
            try {
              final downloadUrl = await uploadLocalFileToStorage(
                item,
                storageFolder:
                userId != null ? 'users/$userId/images' : 'images',
              );
              processedList.add(downloadUrl);
            } catch (e) {
              print('❌ فشل رفع صورة من القائمة: $e');
              rethrow;
            }
          } else {
            processedList.add(item);
          }
        }

        processedData[key] = processedList;
      }
    }

    return processedData;
  }

  /// معالجة أخطاء Storage
  String _handleFirebaseStorageError(FirebaseException e) {
    switch (e.code) {
      case 'storage/unauthorized':
      case 'storage/unauthenticated':
        return 'ليس لديك صلاحية لرفع الملفات. تأكد من تسجيل الدخول.';
      case 'storage/canceled':
        return 'تم إلغاء عملية الرفع';
      case 'storage/unknown':
        return 'حدث خطأ غير معروف';
      case 'storage/object-not-found':
        return 'الملف غير موجود في Firebase Storage. تأكد من تفعيل Storage.';
      case 'storage/bucket-not-found':
        return 'Firebase Storage غير متوفر. تأكد من تفعيله في Console.';
      case 'storage/quota-exceeded':
        return 'تم تجاوز الحد المسموح من المساحة';
      case 'storage/retry-limit-exceeded':
        return 'فشل الرفع بعد عدة محاولات';
      default:
        return 'خطأ: ${e.message ?? e.code}';
    }
  }
}