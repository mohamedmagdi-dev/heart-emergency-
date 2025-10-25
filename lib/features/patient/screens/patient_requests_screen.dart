// // Patient requests status screen
// import 'package:flutter/material.dart';
// import '../../../data/models/doctor_request_model.dart';
// import '../../../data/models/user_model.dart';
// import '../../../services/doctor_request_service.dart';
//
// class PatientRequestsScreen extends StatefulWidget {
//   const PatientRequestsScreen({super.key});
//
//   @override
//   State<PatientRequestsScreen> createState() => _PatientRequestsScreenState();
// }
//
// class _PatientRequestsScreenState extends State<PatientRequestsScreen> {
//   final DoctorRequestService _doctorRequestService = DoctorRequestService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFEF2F2),
//       appBar: AppBar(
//         title: const Text(
//           'طلباتي للأطباء',
//           style: TextStyle(
//             fontFamily: 'Janna',
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.red[600],
//         elevation: 0,
//       ),
//       body: StreamBuilder<List<DoctorRequestModel>>(
//         stream: _doctorRequestService.getRequestsByPatient(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: Colors.red[300],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'خطأ في تحميل الطلبات',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[600],
//                       fontFamily: 'Janna',
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     snapshot.error.toString(),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[500],
//                       fontFamily: 'Janna',
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final requests = snapshot.data ?? [];
//
//           if (requests.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.inbox_outlined,
//                     size: 64,
//                     color: Colors.grey[400],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'لا توجد طلبات',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[600],
//                       fontFamily: 'Janna',
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'يمكنك إرسال طلبات للأطباء من صفحة الحجز',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[500],
//                       fontFamily: 'Janna',
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final request = requests[index];
//               return _buildRequestCard(request);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildRequestCard(DoctorRequestModel request) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Doctor info
//             FutureBuilder<UserModel?>(
//               future: _doctorRequestService.getUserDetails(request.doctorId),
//               builder: (context, snapshot) {
//                 final doctor = snapshot.data;
//                 return Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: Colors.blue[100],
//                       backgroundImage: doctor?.profileImage != null
//                           ? NetworkImage(doctor!.profileImage!)
//                           : null,
//                       child: doctor?.profileImage == null
//                           ? Text(
//                               doctor?.name.substring(0, 1) ?? 'د',
//                               style: TextStyle(
//                                 color: Colors.blue[700],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : null,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'د. ${doctor?.name ?? 'طبيب'}',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: 'Janna',
//                             ),
//                           ),
//                           if (doctor?.specialization != null)
//                             Text(
//                               doctor!.specialization!,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                                 fontFamily: 'Janna',
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     _buildStatusChip(request.status),
//                   ],
//                 );
//               },
//             ),
//
//             const SizedBox(height: 16),
//
//             // Request message
//             if (request.message != null && request.message!.isNotEmpty) ...[
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'رسالتك:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                         fontFamily: 'Janna',
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       request.message!,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'Janna',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//
//             // Response message
//             if (request.responseMessage != null && request.responseMessage!.isNotEmpty) ...[
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: _getResponseColor(request.status).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _getResponseColor(request.status).withOpacity(0.3),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'رد الطبيب:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: _getResponseColor(request.status),
//                         fontFamily: 'Janna',
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       request.responseMessage!,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: _getResponseColor(request.status),
//                         fontFamily: 'Janna',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//
//             // Request time
//             Row(
//               children: [
//                 Icon(
//                   Icons.access_time,
//                   size: 16,
//                   color: Colors.grey[500],
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   _formatDateTime(request.createdAt),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[500],
//                     fontFamily: 'Janna',
//                   ),
//                 ),
//                 const Spacer(),
//                 if (request.status == DoctorRequestStatus.accepted)
//                   TextButton.icon(
//                     onPressed: () {
//                       // TODO: Navigate to chat or contact screen
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('سيتم إضافة ميزة التواصل قريباً'),
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.chat, size: 16),
//                     label: const Text(
//                       'تواصل مع الطبيب',
//                       style: TextStyle(fontSize: 12),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusChip(DoctorRequestStatus status) {
//     Color backgroundColor;
//     Color textColor;
//     String text;
//
//     switch (status) {
//       case DoctorRequestStatus.pending:
//         backgroundColor = Colors.orange[100]!;
//         textColor = Colors.orange[800]!;
//         text = 'معلق';
//         break;
//       case DoctorRequestStatus.accepted:
//         backgroundColor = Colors.green[100]!;
//         textColor = Colors.green[800]!;
//         text = 'مقبول';
//         break;
//       case DoctorRequestStatus.rejected:
//         backgroundColor = Colors.red[100]!;
//         textColor = Colors.red[800]!;
//         text = 'مرفوض';
//         break;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: textColor,
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           fontFamily: 'Janna',
//         ),
//       ),
//     );
//   }
//
//   Color _getResponseColor(DoctorRequestStatus status) {
//     switch (status) {
//       case DoctorRequestStatus.pending:
//         return Colors.orange;
//       case DoctorRequestStatus.accepted:
//         return Colors.green;
//       case DoctorRequestStatus.rejected:
//         return Colors.red;
//     }
//   }
//
//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
//
//     if (difference.inMinutes < 1) {
//       return 'الآن';
//     } else if (difference.inMinutes < 60) {
//       return 'منذ ${difference.inMinutes} دقيقة';
//     } else if (difference.inHours < 24) {
//       return 'منذ ${difference.inHours} ساعة';
//     } else {
//       return 'منذ ${difference.inDays} يوم';
//     }
//   }
// }
// Patient requests status screen

import 'package:flutter/material.dart';

import '../../../data/models/doctor_request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/doctor_request_service.dart';

class PatientRequestsScreen extends StatefulWidget {
  const PatientRequestsScreen({super.key});

  @override
  State<PatientRequestsScreen> createState() => _PatientRequestsScreenState();
}

class _PatientRequestsScreenState extends State<PatientRequestsScreen> {
  final DoctorRequestService _doctorRequestService = DoctorRequestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلباتي للأطباء',
          style: TextStyle(fontFamily: 'Janna', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.red[600],
        elevation: 0,
      ),
      body: StreamBuilder<List<DoctorRequestModel>>(
        stream: _doctorRequestService.getRequestsByPatient(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'خطأ في تحميل الطلبات',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontFamily: 'Janna',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: 'Janna',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontFamily: 'Janna',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يمكنك إرسال طلبات للأطباء من صفحة الحجز',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: 'Janna',
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(DoctorRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info
            FutureBuilder<UserModel?>(
              future: _doctorRequestService.getUserDetails(request.doctorId),
              builder: (context, snapshot) {
                final doctor = snapshot.data;
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      backgroundImage: doctor?.profileImage != null
                          ? NetworkImage(doctor!.profileImage!)
                          : null,
                      child: doctor?.profileImage == null
                          ? Text(
                              doctor?.name.substring(0, 1) ?? 'د',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'د. ${doctor?.name ?? 'طبيب'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Janna',
                            ),
                          ),
                          if (doctor?.specialization != null)
                            Text(
                              doctor!.specialization!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Janna',
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildStatusChip(request.status),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Request message
            if (request.message != null && request.message!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رسالتك:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontFamily: 'Janna',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.message!,
                      style: const TextStyle(fontSize: 14, fontFamily: 'Janna'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Response message
            if (request.responseMessage != null &&
                request.responseMessage!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getResponseColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getResponseColor(request.status).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رد الطبيب:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getResponseColor(request.status),
                        fontFamily: 'Janna',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.responseMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getResponseColor(request.status),
                        fontFamily: 'Janna',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Request time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(request.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'Janna',
                  ),
                ),
                const Spacer(),
                if (request.status == DoctorRequestStatus.accepted)
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to chat or contact screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم إضافة ميزة التواصل قريباً'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text(
                      'تواصل مع الطبيب',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(DoctorRequestStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case DoctorRequestStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'معلق';
        break;
      case DoctorRequestStatus.accepted:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'مقبول';
        break;
      case DoctorRequestStatus.rejected:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        text = 'مرفوض';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Janna',
        ),
      ),
    );
  }

  Color _getResponseColor(DoctorRequestStatus status) {
    switch (status) {
      case DoctorRequestStatus.pending:
        return Colors.orange;
      case DoctorRequestStatus.accepted:
        return Colors.green;
      case DoctorRequestStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}
