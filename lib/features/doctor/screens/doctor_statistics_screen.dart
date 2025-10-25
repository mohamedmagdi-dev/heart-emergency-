// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../data/models/request_model.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../services/request_service.dart';
//
// class DoctorStatisticsScreen extends ConsumerWidget {
//   const DoctorStatisticsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userAsync = ref.watch(currentUserDataProvider);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الإحصائيات'),
//         backgroundColor: Colors.green[700],
//         foregroundColor: Theme.of(context).scaffoldBackgroundColor,
//       ),
//       body: userAsync.when(
//         data: (user) {
//           if (user == null) return const Center(child: Text('غير مسجل الدخول'));
//           final service = RequestService();
//           return StreamBuilder<List<RequestModel>>(
//             stream: service.getDoctorEmergencyRequests(user.uid),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final data = snapshot.data!;
//               final accepted = data
//                   .where((r) => r.status == RequestStatus.accepted)
//                   .length;
//               final rejected = data
//                   .where((r) => r.status == RequestStatus.rejected)
//                   .length;
//               final completed = data
//                   .where((r) => r.status == RequestStatus.completed)
//                   .length;
//               final total = data.length;
//
//               return SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _statCard('إجمالي الطلبات', total, Colors.blue),
//                     const SizedBox(height: 12),
//                     _statCard('المقبولة', accepted, Colors.orange),
//                     const SizedBox(height: 12),
//                     _statCard('المرفوضة', rejected, Colors.red),
//                     const SizedBox(height: 12),
//                     _statCard('المكتملة', completed, Colors.green),
//                     const SizedBox(height: 24),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: SizedBox(
//                         height: 220,
//                         child: BarChart(
//                           BarChartData(
//                             alignment: BarChartAlignment.spaceAround,
//                             gridData: const FlGridData(show: false),
//                             borderData: FlBorderData(show: false),
//                             titlesData: FlTitlesData(
//                               leftTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false),
//                               ),
//                               topTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false),
//                               ),
//                               rightTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false),
//                               ),
//                               bottomTitles: AxisTitles(
//                                 sideTitles: SideTitles(
//                                   showTitles: true,
//                                   getTitlesWidget: (value, meta) {
//                                     final labels = [
//                                       'Total',
//                                       'Accepted',
//                                       'Rejected',
//                                       'Completed',
//                                     ];
//                                     final idx = value.toInt();
//                                     return Padding(
//                                       padding: const EdgeInsets.only(top: 6),
//                                       child: Text(
//                                         labels[idx],
//                                         style: const TextStyle(fontSize: 10),
//                                       ),
//                                     );
//                                   },
//                                   reservedSize: 26,
//                                 ),
//                               ),
//                             ),
//                             barGroups: [
//                               BarChartGroupData(
//                                 x: 0,
//                                 barRods: [
//                                   BarChartRodData(
//                                     toY: total.toDouble(),
//                                     color: Colors.blue,
//                                     width: 18,
//                                   ),
//                                 ],
//                               ),
//                               BarChartGroupData(
//                                 x: 1,
//                                 barRods: [
//                                   BarChartRodData(
//                                     toY: accepted.toDouble(),
//                                     color: Colors.orange,
//                                     width: 18,
//                                   ),
//                                 ],
//                               ),
//                               BarChartGroupData(
//                                 x: 2,
//                                 barRods: [
//                                   BarChartRodData(
//                                     toY: rejected.toDouble(),
//                                     color: Colors.red,
//                                     width: 18,
//                                   ),
//                                 ],
//                               ),
//                               BarChartGroupData(
//                                 x: 3,
//                                 barRods: [
//                                   BarChartRodData(
//                                     toY: completed.toDouble(),
//                                     color: Colors.green,
//                                     width: 18,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('خطأ: $e')),
//       ),
//     );
//   }
//
//   Widget _statCard(String title, int value, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(Icons.analytics, color: color),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Text(
//             '$value',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: color,
//               fontSize: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/request_service.dart';
import '../../../services/firestore_service.dart'; // ✅ أضف دي

class DoctorStatisticsScreen extends ConsumerWidget {
  const DoctorStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        backgroundColor: Colors.green[700],
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('غير مسجل الدخول'));
          final service = FirestoreService(); // ✅ استخدم FirestoreService بدل RequestService
          return StreamBuilder<List<RequestModel>>(
            // ✅ عدل الـ stream علشان يجيب كل الطلبات
            stream: service.getDoctorRequests(user.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;

              // ✅ عدل الإحصائيات علشان تشمل الحالات الجديدة
              final pending = data
                  .where((r) => r.status == RequestStatus.pending)
                  .length;
              final priceSet = data
                  .where((r) => r.status == RequestStatus.price_set)
                  .length;
              final accepted = data
                  .where((r) => r.status == RequestStatus.accepted)
                  .length;
              final rejected = data
                  .where((r) => r.status == RequestStatus.rejected)
                  .length;
              // final rejectedByDoctor = data
              //     .where((r) => r.status == RequestStatus.rejected_by_doctor)
              //     .length;
              final completed = data
                  .where((r) => r.status == RequestStatus.completed)
                  .length;
              final total = data.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _statCard('إجمالي الطلبات', total, Colors.blue),
                    const SizedBox(height: 12),
                    _statCard('في الانتظار', pending, Colors.orange),
                    const SizedBox(height: 12),
                    _statCard('تم تحديد السعر', priceSet, Colors.purple),
                    const SizedBox(height: 12),
                    _statCard('المقبولة', accepted, Colors.green),
                    const SizedBox(height: 12),
                    _statCard('المرفوضة', rejected, Colors.red),
                    const SizedBox(height: 12),
                    // _statCard('مرفوضة من الطبيب', rejectedByDoctor, Colors.red[700]!),
                    // const SizedBox(height: 12),
                    _statCard('المكتملة', completed, Colors.teal),
                    const SizedBox(height: 24),

                    // ✅ عدل الـ chart علشان يشمل الحالات الجديدة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        height: 280, // ✅ زود الارتفاع علشان الحالات الجديدة
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final labels = [
                                      'Total',
                                      'Pending',
                                      'Price Set',
                                      'Accepted',
                                      'Rejected',
                                      'Rej.Doc',
                                      'Completed',
                                    ];
                                    final idx = value.toInt();
                                    if (idx >= 0 && idx < labels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          labels[idx],
                                          style: const TextStyle(fontSize: 9), // ✅ صغر الخط
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: total.toDouble(), color: Colors.blue, width: 14)]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: pending.toDouble(), color: Colors.orange, width: 14)]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: priceSet.toDouble(), color: Colors.purple, width: 14)]),
                              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: accepted.toDouble(), color: Colors.green, width: 14)]),
                              BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: rejected.toDouble(), color: Colors.red, width: 14)]),
                              // BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: rejectedByDoctor.toDouble(), color: Colors.red[700]!, width: 14)]),
                              BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: completed.toDouble(), color: Colors.teal, width: 14)]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.analytics, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}