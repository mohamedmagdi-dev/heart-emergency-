// // Admin Commissions Screen - Display total admin commissions from all doctors
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../../data/models/earnings_model.dart';
// import '../../../data/models/user_model.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../services/earnings_service.dart';
// import '../../../services/admin_service.dart';
//
// class AdminCommissionsScreen extends ConsumerStatefulWidget {
//   const AdminCommissionsScreen({super.key});
//
//   @override
//   ConsumerState<AdminCommissionsScreen> createState() => _AdminCommissionsScreenState();
// }
//
// class _AdminCommissionsScreenState extends ConsumerState<AdminCommissionsScreen> {
//   final EarningsService _earningsService = EarningsService();
//   final AdminService _adminService = AdminService();
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUserAsync = ref.watch(currentUserDataProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('عمولات الإدارة'),
//         backgroundColor: Colors.purple[600],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       body: currentUserAsync.when(
//         data: (user) {
//           if (user == null || user.role != 'admin') {
//             return const Center(child: Text('غير مصرح لك بالوصول'));
//           }
//           return _buildCommissionsContent();
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text('خطأ في تحميل البيانات: $error'),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => ref.refresh(currentUserDataProvider),
//                 child: const Text('إعادة المحاولة'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCommissionsContent() {
//     return RefreshIndicator(
//       onRefresh: () async {
//         setState(() {});
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           children: [
//             _buildTotalCommissionsCard(),
//             const SizedBox(height: 16),
//             _buildDoctorsCommissionsList(),
//             const SizedBox(height: 16),
//             _buildCommissionsBreakdown(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTotalCommissionsCard() {
//     return FutureBuilder<double>(
//       future: _calculateTotalCommissions(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildCommissionsLoadingCard();
//         }
//
//         if (snapshot.hasError) {
//           return _buildCommissionsErrorCard();
//         }
//
//         final totalCommissions = snapshot.data ?? 0.0;
//
//         return Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.purple[400]!, Colors.purple[600]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.purple.withOpacity(0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.account_balance,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'إجمالي عمولات الإدارة',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       '12% من كل طلب',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'إجمالي العمولات',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '${totalCommissions.toStringAsFixed(2)} EGP',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.trending_up,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDoctorsCommissionsList() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'عمولات الأطباء',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('doctor_earnings')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (snapshot.hasError) {
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.red[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.red[200]!),
//                   ),
//                   child: const Text(
//                     'خطأ في تحميل عمولات الأطباء',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 );
//               }
//
//               final docs = snapshot.data?.docs ?? [];
//               if (docs.isEmpty) {
//                 return Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey[200]!),
//                   ),
//                   child: const Column(
//                     children: [
//                       Icon(Icons.inbox, size: 48, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         'لا توجد عمولات حتى الآن',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               return ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: docs.length,
//                 itemBuilder: (context, index) {
//                   final doc = docs[index];
//                   final earnings = DoctorEarnings.fromMap(doc.data() as Map<String, dynamic>);
//                   return _buildDoctorCommissionCard(earnings);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDoctorCommissionCard(DoctorEarnings earnings) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.purple.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.person,
//                   color: Colors.purple,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'طبيب ${earnings.doctorId.substring(0, 8)}...',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       'آخر تحديث: ${_formatDateTime(earnings.lastUpdated)}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 '${earnings.platformCommission.toStringAsFixed(2)} ${earnings.currency}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildCommissionDetail(
//                   'إجمالي الأرباح',
//                   '${earnings.totalEarnings.toStringAsFixed(2)} ${earnings.currency}',
//                   Colors.green,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildCommissionDetail(
//                   'الطلبات المكتملة',
//                   earnings.totalRequests.toString(),
//                   Colors.blue,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCommissionDetail(String label, String value, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10,
//               color: color.withOpacity(0.8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCommissionsBreakdown() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'تفاصيل العمولات',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 _buildBreakdownRow(
//                   'معدل العمولة',
//                   '12%',
//                   Colors.purple,
//                 ),
//                 const Divider(),
//                 _buildBreakdownRow(
//                   'من كل طلب مكتمل',
//                   'يتم خصم 12% من السعر الإجمالي',
//                   Colors.grey,
//                 ),
//                 const Divider(),
//                 _buildBreakdownRow(
//                   'صافي الأرباح للطبيب',
//                   '88% من السعر الإجمالي',
//                   Colors.green,
//                 ),
//                 const Divider(),
//                 _buildBreakdownRow(
//                   'عمولة الإدارة',
//                   '12% من السعر الإجمالي',
//                   Colors.purple,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBreakdownRow(String label, String value, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCommissionsLoadingCard() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   Widget _buildCommissionsErrorCard() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.red[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.red[200]!),
//       ),
//       child: const Center(
//         child: Text(
//           'خطأ في تحميل العمولات',
//           style: TextStyle(color: Colors.red, fontSize: 16),
//         ),
//       ),
//     );
//   }
//
//   Future<double> _calculateTotalCommissions() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('doctor_earnings')
//           .get();
//
//       double totalCommissions = 0.0;
//       for (final doc in snapshot.docs) {
//         final earnings = DoctorEarnings.fromMap(doc.data());
//         totalCommissions += earnings.platformCommission;
//       }
//
//       return totalCommissions;
//     } catch (e) {
//       print('Error calculating total commissions: $e');
//       return 0.0;
//     }
//   }
//
//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
//
//     if (difference.inDays > 0) {
//       return 'منذ ${difference.inDays} يوم';
//     } else if (difference.inHours > 0) {
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inMinutes > 0) {
//       return 'منذ ${difference.inMinutes} دقيقة';
//     } else {
//       return 'الآن';
//     }
//   }
// }
// Admin Commissions Screen - Display total admin commissions from all doctors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/earnings_model.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/earnings_service.dart';
import '../../../services/admin_service.dart';

class AdminCommissionsScreen extends ConsumerStatefulWidget {
  const AdminCommissionsScreen({super.key});

  @override
  ConsumerState<AdminCommissionsScreen> createState() => _AdminCommissionsScreenState();
}

class _AdminCommissionsScreenState extends ConsumerState<AdminCommissionsScreen> {
  final EarningsService _earningsService = EarningsService();
  final AdminService _adminService = AdminService();
  final double _commissionRate = 0.12; // 12% commission rate

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('عمولات الإدارة'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null || user.role != 'admin') {
            return const Center(child: Text('غير مصرح لك بالوصول'));
          }
          return _buildCommissionsContent(isMobile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: isMobile ? 48.0 : 64.0, color: Colors.red),
                SizedBox(height: isMobile ? 12.0 : 16.0),
                Text(
                  'خطأ في تحميل البيانات: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isMobile ? 14.0 : 16.0),
                ),
                SizedBox(height: isMobile ? 12.0 : 16.0),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentUserDataProvider),
                  child: Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontSize: isMobile ? 14.0 : 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionsContent(bool isMobile) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12.0 : 24.0,
          vertical: 16.0,
        ),
        child: Column(
          children: [
            _buildTotalCommissionsCard(isMobile),
            SizedBox(height: isMobile ? 16.0 : 24.0),
            _buildDoctorsCommissionsList(isMobile),
            SizedBox(height: isMobile ? 16.0 : 24.0),
            _buildCommissionsBreakdown(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCommissionsCard(bool isMobile) {
    return FutureBuilder<double>(
      future: _calculateTotalCommissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCommissionsLoadingCard(isMobile);
        }

        if (snapshot.hasError) {
          return _buildCommissionsErrorCard(isMobile);
        }

        final totalCommissions = snapshot.data ?? 0.0;

        return Container(
          margin: EdgeInsets.all(isMobile ? 8.0 : 16.0),
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[400]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isMobile ? 12.0 : 16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: isMobile ? 24.0 : 32.0,
                  ),
                  SizedBox(width: isMobile ? 8.0 : 12.0),
                  Expanded(
                    child: Text(
                      'إجمالي عمولات الإدارة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 18.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8.0 : 12.0,
                      vertical: isMobile ? 4.0 : 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(_commissionRate * 100).toStringAsFixed(0)}% من كل طلب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 10.0 : 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16.0 : 24.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي العمولات',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isMobile ? 14.0 : 16.0,
                          ),
                        ),
                        SizedBox(height: isMobile ? 6.0 : 8.0),
                        Text(
                          '${totalCommissions.toStringAsFixed(2)} EGP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 24.0 : 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: isMobile ? 24.0 : 32.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorsCommissionsList(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 4.0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عمولات الأطباء',
            style: TextStyle(
              fontSize: isMobile ? 18.0 : 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8.0 : 12.0),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctor_earnings')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Container(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    'خطأ في تحميل عمولات الأطباء',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isMobile ? 14.0 : 16.0,
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: isMobile ? 36.0 : 48.0,
                        color: Colors.grey,
                      ),
                      SizedBox(height: isMobile ? 12.0 : 16.0),
                      Text(
                        'لا توجد عمولات حتى الآن',
                        style: TextStyle(
                          fontSize: isMobile ? 14.0 : 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final earnings = DoctorEarnings.fromMap(doc.data() as Map<String, dynamic>);
                  return _buildDoctorCommissionCard(earnings, isMobile);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildDoctorCommissionCard(DoctorEarnings earnings, bool isMobile) {
  //   return FutureBuilder<DocumentSnapshot>(
  //     future: FirebaseFirestore.instance
  //         .collection('doctors')
  //         .doc(earnings.doctorId)
  //         .get(),
  //     builder: (context, doctorSnapshot) {
  //       String doctorName = 'طبيب ${earnings.doctorId.substring(0, 8)}...';
  //
  //       if (doctorSnapshot.connectionState == ConnectionState.done &&
  //           doctorSnapshot.hasData &&
  //           doctorSnapshot.data!.exists) {
  //         final doctorData = doctorSnapshot.data!.data() as Map<String, dynamic>?;
  //         if (doctorData != null) {
  //           // Try different possible field names for doctor name
  //           doctorName = doctorData['name'] ??
  //               doctorData['fullName'] ??
  //               doctorData['displayName'] ??
  //               doctorName;
  //         }
  //       }

  Widget _buildDoctorCommissionCard(DoctorEarnings earnings, bool isMobile) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(earnings.doctorId)
          .get(),
      builder: (context, doctorSnapshot) {
        String doctorName = 'طبيب غير معروف';

        if (doctorSnapshot.connectionState == ConnectionState.done &&
            doctorSnapshot.hasData &&
            doctorSnapshot.data!.exists) {
          final doctorData = doctorSnapshot.data!.data() as Map<String, dynamic>?;
          if (doctorData != null) {
            // Get doctor name from users collection
            doctorName = doctorData['name'] ??
                doctorData['fullName'] ??
                doctorData['displayName'] ??
                'د. ${earnings.doctorId.substring(0, 8)}';
          }
        }
        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 8.0 : 12.0),
          padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 8.0 : 12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 6.0 : 8.0),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.purple,
                      size: isMobile ? 16.0 : 20.0,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8.0 : 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: TextStyle(
                            fontSize: isMobile ? 14.0 : 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'آخر تحديث: ${_formatDateTime(earnings.lastUpdated)}',
                          style: TextStyle(
                            fontSize: isMobile ? 10.0 : 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${earnings.platformCommission.toStringAsFixed(2)} ${earnings.currency}',
                    style: TextStyle(
                      fontSize: isMobile ? 14.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 8.0 : 12.0),
              isMobile ? _buildMobileCommissionDetails(earnings) : _buildDesktopCommissionDetails(earnings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileCommissionDetails(DoctorEarnings earnings) {
    return Column(
      children: [
        _buildCommissionDetail(
          'إجمالي الأرباح',
          '${earnings.totalEarnings.toStringAsFixed(2)} ${earnings.currency}',
          Colors.green,
          true,
        ),
        SizedBox(height: 6),
        _buildCommissionDetail(
          'الطلبات المكتملة',
          earnings.totalRequests.toString(),
          Colors.blue,
          true,
        ),
      ],
    );
  }

  Widget _buildDesktopCommissionDetails(DoctorEarnings earnings) {
    return Row(
      children: [
        Expanded(
          child: _buildCommissionDetail(
            'إجمالي الأرباح',
            '${earnings.totalEarnings.toStringAsFixed(2)} ${earnings.currency}',
            Colors.green,
            false,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildCommissionDetail(
            'الطلبات المكتملة',
            earnings.totalRequests.toString(),
            Colors.blue,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionDetail(String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6.0 : 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12.0 : 14.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 8.0 : 10.0,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionsBreakdown(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 4.0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل العمولات',
            style: TextStyle(
              fontSize: isMobile ? 18.0 : 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8.0 : 12.0),
          Container(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 8.0 : 12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildBreakdownRow(
                  'معدل العمولة',
                  '${(_commissionRate * 100).toStringAsFixed(0)}%',
                  Colors.purple,
                  isMobile,
                ),
                Divider(height: isMobile ? 16.0 : 20.0),
                _buildBreakdownRow(
                  'من كل طلب مكتمل',
                  'يتم خصم ${(_commissionRate * 100).toStringAsFixed(0)}% من السعر الإجمالي',
                  Colors.grey,
                  isMobile,
                ),
                Divider(height: isMobile ? 16.0 : 20.0),
                _buildBreakdownRow(
                  'صافي الأرباح للطبيب',
                  '${((1 - _commissionRate) * 100).toStringAsFixed(0)}% من السعر الإجمالي',
                  Colors.green,
                  isMobile,
                ),
                Divider(height: isMobile ? 16.0 : 20.0),
                _buildBreakdownRow(
                  'عمولة الإدارة',
                  '${(_commissionRate * 100).toStringAsFixed(0)}% من السعر الإجمالي',
                  Colors.purple,
                  isMobile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color color, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6.0 : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 14.0 : 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 14.0 : 16.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionsLoadingCard(bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 8.0 : 16.0),
      padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(isMobile ? 12.0 : 16.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCommissionsErrorCard(bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 8.0 : 16.0),
      padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(isMobile ? 12.0 : 16.0),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Text(
          'خطأ في تحميل العمولات',
          style: TextStyle(
            color: Colors.red,
            fontSize: isMobile ? 14.0 : 16.0,
          ),
        ),
      ),
    );
  }

  Future<double> _calculateTotalCommissions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctor_earnings')
          .get();

      double totalCommissions = 0.0;
      for (final doc in snapshot.docs) {
        final earnings = DoctorEarnings.fromMap(doc.data());
        totalCommissions += earnings.platformCommission;
      }

      return totalCommissions;
    } catch (e) {
      print('Error calculating total commissions: $e');
      return 0.0;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}