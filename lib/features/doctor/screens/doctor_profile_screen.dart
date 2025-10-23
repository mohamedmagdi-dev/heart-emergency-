import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../common/widgets/local_file_viewer.dart';
import '../widgets/certificate_uploader.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('لم يتم العثور على المستخدم'));
          }
          return _buildProfile(context, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  // Widget _buildProfile(BuildContext context, UserModel user) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(16),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.05),
  //                 blurRadius: 10,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: Row(
  //             children: [
  //               CircleAvatar(
  //                 radius: 36,
  //                 backgroundColor: Colors.green[100],
  //                 backgroundImage: user.profileImage != null
  //                     ? NetworkImage(user.profileImage!)
  //                     : null,
  //                 child: user.profileImage == null
  //                     ? Text(
  //                         user.name.isNotEmpty
  //                             ? user.name.substring(0, 1)
  //                             : 'د',
  //                         style: TextStyle(
  //                           color: Colors.green[700],
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       )
  //                     : null,
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'د. ${user.name}',
  //                       style: const TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     if (user.specialization != null) ...[
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         user.specialization!,
  //                         style: const TextStyle(color: Colors.grey),
  //                       ),
  //                     ],
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         Icon(
  //                           Icons.verified,
  //                           color: (user.verified ?? false)
  //                               ? Colors.green
  //                               : Colors.grey,
  //                           size: 18,
  //                         ),
  //                         const SizedBox(width: 6),
  //                         Text(
  //                           (user.verified ?? false) ? 'موثق' : 'غير موثق',
  //                           style: const TextStyle(fontSize: 12),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         _infoTile(
  //           title: 'البريد الإلكتروني',
  //           value: user.email,
  //           icon: Icons.email,
  //         ),
  //         _infoTile(title: 'رقم الهاتف', value: user.phone, icon: Icons.phone),
  //         if (user.location != null)
  //           _infoTile(
  //             title: 'الموقع',
  //             value:
  //                 '(${user.location!.latitude.toStringAsFixed(5)}, ${user.location!.longitude.toStringAsFixed(5)})',
  //             icon: Icons.location_on,
  //           ),
  //         if (user.rating != null)
  //           _infoTile(
  //             title: 'التقييم',
  //             value: user.rating!.toStringAsFixed(1),
  //             icon: Icons.star,
  //           ),
  //         if (user.certificates != null && user.certificates!.isNotEmpty)
  //           // Container(
  //           //   padding: const EdgeInsets.all(16),
  //           //   decoration: BoxDecoration(
  //           //     borderRadius: BorderRadius.circular(12),
  //           //     boxShadow: [
  //           //       BoxShadow(
  //           //         color: Colors.black.withOpacity(0.05),
  //           //         blurRadius: 10,
  //           //         offset: const Offset(0, 2),
  //           //       ),
  //           //     ],
  //           //   ),
  //           //   child: Column(
  //           //     crossAxisAlignment: CrossAxisAlignment.start,
  //           //     children: [
  //           //       const Text(
  //           //         'الشهادات',
  //           //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           //       ),
  //           //       const SizedBox(height: 8),
  //           //       ...user.certificates!.map(
  //           //         (c) => Padding(
  //           //           padding: const EdgeInsets.symmetric(vertical: 4),
  //           //           child: Text(
  //           //             c,
  //           //             style: const TextStyle(color: Colors.blue),
  //           //           ),
  //           //         ),
  //           //       ),
  //           //     ],
  //           //   ),
  //           // ),
  //           _buildCertificatesSection(context, user.certificates!),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildProfile(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الصورة والمعلومات الأساسية
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.green[100],
                  backgroundImage: user.profileImage != null
                      ? _getImageProvider(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Text(
                    user.name.isNotEmpty
                        ? user.name.substring(0, 1)
                        : 'د',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د. ${user.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.specialization!,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: (user.verified ?? false)
                                ? Colors.green
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (user.verified ?? false) ? 'موثق' : 'غير موثق',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // المعلومات
          _infoTile(
            title: 'البريد الإلكتروني',
            value: user.email,
            icon: Icons.email,
          ),
          _infoTile(
              title: 'رقم الهاتف',
              value: user.phone,
              icon: Icons.phone
          ),

          if (user.location != null)
            _infoTile(
              title: 'الموقع',
              value: '(${user.location!.latitude.toStringAsFixed(5)}, ${user
                  .location!.longitude.toStringAsFixed(5)})',
              icon: Icons.location_on,
            ),

          if (user.rating != null)
            _infoTile(
              title: 'التقييم',
              value: user.rating!.toStringAsFixed(1),
              icon: Icons.star,
            ),

          // الشهادات - مهم نضيف مسافات كافية
          if (user.certificates != null && user.certificates!.isNotEmpty)
            _buildCertificatesSection(context, user.certificates!),

          // مسافة إضافية في الآخر علشان ميحصلش overflow
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // دالة علشان نفرق بين الـ local path والـ URL
  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

// دالة علشان نعرف نوع الملف
  bool _isLocalFile(String path) {
    return path.startsWith('file://') ||
        path.startsWith('/data/') ||
        !path.startsWith('http');
  }

  Widget _infoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//   // داخل كلاس DoctorProfileScreen (أو الـ State)
//
// // 1. دالة لعرض الملف بملء الشاشة عند الضغط
//   void _showFullScreenFile(BuildContext context, String filePath) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.black,
//         child: Stack(
//           children: [
//             Center(
//               // نستخدم LocalFileViewer الذي تم إصلاحه
//               child: LocalFileViewer(filePath: filePath, fit: BoxFit.contain),
//             ),
//             Positioned(
//               // زر الإغلاق
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
  void _showFullScreenFile(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: _isLocalFile(filePath)
                        ? FutureBuilder<File?>(
                      future: _getLocalFile(filePath),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return InteractiveViewer(
                            child: Image.file(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    )
                        : InteractiveViewer(
                      child: Image.network(
                        filePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                        Icons.close, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
    );
  }

// 2. دالة بناء قسم الشهادات التفاعلي (استخدم هذه بدلاً من الكود القديم)
//   Widget _buildCertificatesSection(BuildContext context, List<String> certificates) {
//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'الشهادات والوثائق',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: certificates.length,
//             itemBuilder: (context, index) {
//               final filePath = certificates[index];
//               final fileName = filePath.split('/').last;
//
//               return ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 // استخدام LocalFileViewer كـ Leading لعرض مصغر (Thumbnail)
//                 leading: LocalFileViewer(
//                   filePath: filePath,
//                   width: 40,
//                   height: 40,
//                 ),
//                 title: Text(
//                   fileName,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 trailing: const Icon(Icons.remove_red_eye, color: Colors.grey),
//                 // عند الضغط يفتح الملف بملء الشاشة
//                 onTap: () => _showFullScreenFile(context, filePath),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// استبدل _buildCertificatesSection بهذا الكود
//   Widget _buildCertificatesSection(BuildContext context, List<String> certificates) {
//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'الشهادات والوثائق',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           // استخدم الـ Widget الجديد
//           CertificatesList(
//             certificateUrls: certificates,
//             onCertificateTap: (url) => _showFullScreenImage(context, url),
//           ),
//         ],
//       ),
//     );
//   }

// دالة علشان نجيب الـ local file
  Future<File?> _getLocalFile(String filePath) async {
    try {
      // تنظيف الـ path
      String cleanPath = filePath.replaceFirst('file://', '');
      final file = File(cleanPath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting local file: $e');
      return null;
    }
  }

  // Widget _buildCertificatesSection(BuildContext context, List<String> certificates) {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'الشهادات والوثائق',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 12),
  //
  //         // استخدم ListView.builder مع ارتفاع محدد
  //         Container(
  //           constraints: BoxConstraints(
  //             maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% من الشاشة
  //           ),
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             physics: const AlwaysScrollableScrollPhysics(),
  //             itemCount: certificates.length,
  //             itemBuilder: (context, index) {
  //               final filePath = certificates[index];
  //               final fileName = filePath.split('/').last;
  //
  //               return Container(
  //                 margin: const EdgeInsets.only(bottom: 8),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: Colors.grey[300]!),
  //                 ),
  //                 child: ListTile(
  //                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                   leading: Container(
  //                     width: 50,
  //                     height: 50,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(6),
  //                       color: Colors.grey[100],
  //                     ),
  //                     child: _isLocalFile(filePath)
  //                         ? FutureBuilder<File?>(
  //                       future: _getLocalFile(filePath),
  //                       builder: (context, snapshot) {
  //                         if (snapshot.hasData && snapshot.data != null) {
  //                           return Image.file(
  //                             snapshot.data!,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Icon(Icons.description, color: Colors.grey[600]);
  //                             },
  //                           );
  //                         }
  //                         return Icon(Icons.description, color: Colors.grey[600]);
  //                       },
  //                     )
  //                         : Image.network(
  //                       filePath,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (context, error, stackTrace) {
  //                         return Icon(Icons.description, color: Colors.grey[600]);
  //                       },
  //                     ),
  //                   ),
  //                   title: Text(
  //                     fileName,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(fontSize: 14),
  //                   ),
  //                   trailing: Icon(Icons.visibility, color: Colors.green[700]),
  //                   onTap: () => _showFullScreenFile(context, filePath),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildCertificatesSection(BuildContext context,
      List<String> certificates) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الشهادات والوثائق',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // قائمة عرض الشهادات
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery
                  .of(context)
                  .size
                  .height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final fileUrl = certificates[index];
                final fileName = fileUrl
                    .split('/')
                    .last;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        fileUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.description, color: Colors.grey[600]),
                      ),
                    ),
                    title: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Icon(Icons.visibility, color: Colors.green[700]),
                    onTap: () => _showFullScreenImage(context, fileUrl),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

//
// // عدّل _showFullScreenFile لتستخدم الـ URL بدل الـ Path
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
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                        Icons.close, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
