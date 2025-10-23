// // lib/features/common/widgets/certificate_viewer.dart
// // Widget جديد لعرض الشهادات من Firebase Storage
//
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// class CertificateViewer extends StatelessWidget {
//   final String imageUrl;
//   final double? width;
//   final double? height;
//   final BoxFit fit;
//
//   const CertificateViewer({
//     super.key,
//     required this.imageUrl,
//     this.width,
//     this.height,
//     this.fit = BoxFit.cover,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // تحقق لو الرابط محلي ولا من Firebase
//     final isLocalFile = imageUrl.startsWith('/data/') ||
//         imageUrl.startsWith('file://') ||
//         !imageUrl.startsWith('http');
//
//     if (isLocalFile) {
//       // لو ملف محلي، استخدم LocalFileViewer
//       return Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.error_outline, color: Colors.red, size: 32),
//               SizedBox(height: 8),
//               Text(
//                 'ملف محلي - يجب رفعه على Firebase',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // لو رابط من Firebase، استخدم CachedNetworkImage
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       width: width,
//       height: height,
//       fit: fit,
//       placeholder: (context, url) => Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//       errorWidget: (context, url, error) => Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.broken_image, color: Colors.grey, size: 32),
//               SizedBox(height: 4),
//               Text('فشل تحميل الصورة', style: TextStyle(fontSize: 10)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Widget لعرض قائمة الشهادات
// class CertificatesList extends StatelessWidget {
//   final List<String> certificateUrls;
//   final Function(String)? onCertificateTap;
//
//   const CertificatesList({
//     super.key,
//     required this.certificateUrls,
//     this.onCertificateTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (certificateUrls.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Column(
//             children: [
//               Icon(Icons.folder_open, size: 48, color: Colors.grey),
//               SizedBox(height: 8),
//               Text(
//                 'لا توجد شهادات مرفوعة',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: certificateUrls.length,
//       itemBuilder: (context, index) {
//         final url = certificateUrls[index];
//         final fileName = _extractFileName(url);
//
//         return Card(
//           margin: const EdgeInsets.only(bottom: 8),
//           child: ListTile(
//             leading: ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: CertificateViewer(
//                 imageUrl: url,
//                 width: 50,
//                 height: 50,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             title: Text(
//               fileName,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             subtitle: const Text('اضغط للعرض بالحجم الكامل'),
//             trailing: const Icon(Icons.remove_red_eye, color: Colors.blue),
//             onTap: () {
//               if (onCertificateTap != null) {
//                 onCertificateTap!(url);
//               } else {
//                 _showFullScreenImage(context, url);
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   String _extractFileName(String url) {
//     try {
//       final uri = Uri.parse(url);
//       final pathSegments = uri.pathSegments;
//       if (pathSegments.isNotEmpty) {
//         return pathSegments.last;
//       }
//       return 'شهادة ${certificateUrls.indexOf(url) + 1}';
//     } catch (e) {
//       return 'شهادة ${certificateUrls.indexOf(url) + 1}';
//     }
//   }
//
//   void _showFullScreenImage(BuildContext context, String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.black,
//         child: Stack(
//           children: [
//             Center(
//               child: InteractiveViewer(
//                 child: CertificateViewer(
//                   imageUrl: imageUrl,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 40,
//               right: 20,
//               child: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/presentation/doctor/widgets/certificate_uploader.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget لعرض شهادة واحدة من Firebase Storage URL
class CertificateViewer extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CertificateViewer({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red[300], size: 40),
            const SizedBox(height: 8),
            Text(
              'فشل تحميل الصورة',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget لعرض قائمة الشهادات كـ Thumbnails
class CertificatesList extends StatelessWidget {
  final List<String> certificateUrls;
  final Function(String)? onCertificateTap;

  const CertificatesList({
    super.key,
    required this.certificateUrls,
    this.onCertificateTap,
  });

  @override
  Widget build(BuildContext context) {
    if (certificateUrls.isEmpty) {
      return Center(
        child: Text(
          'لا توجد شهادات',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: certificateUrls.length,
      itemBuilder: (context, index) {
        final url = certificateUrls[index];
        final fileName = _extractFileName(url);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            // Thumbnail من Firebase Storage
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CertificateViewer(
                imageUrl: url,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'الشهادة ${index + 1}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.remove_red_eye, color: Colors.green),
            onTap: () => onCertificateTap?.call(url),
          ),
        );
      },
    );
  }

  /// استخراج اسم الملف من URL
  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final lastSegment = segments.last;
        // إزالة الـ Token من اسم الملف
        final withoutToken = lastSegment.split('?').first;
        // فك التشفير (URL Decode)
        return Uri.decodeComponent(withoutToken);
      }
    } catch (e) {
      print('Error extracting filename: $e');
    }
    return 'شهادة';
  }
}

/// Dialog لعرض الشهادة بملء الشاشة
class FullScreenCertificateDialog extends StatelessWidget {
  final String imageUrl;

  const FullScreenCertificateDialog({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // الصورة بملء الشاشة مع إمكانية Zoom
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CertificateViewer(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // زر الإغلاق
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض الـ Dialog
  static void show(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => FullScreenCertificateDialog(imageUrl: imageUrl),
    );
  }
}