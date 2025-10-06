import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/request_service.dart';
import '../../../data/models/request_model.dart';

class DoctorStatisticsScreen extends ConsumerWidget {
  const DoctorStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('غير مسجل الدخول'));
          final service = RequestService();
          return StreamBuilder<List<RequestModel>>(
            stream: service.getDoctorEmergencyRequests(user.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;
              final accepted = data.where((r) => r.status == RequestStatus.accepted).length;
              final rejected = data.where((r) => r.status == RequestStatus.rejected).length;
              final completed = data.where((r) => r.status == RequestStatus.completed).length;
              final total = data.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _statCard('إجمالي الطلبات', total, Colors.blue),
                    const SizedBox(height: 12),
                    _statCard('المقبولة', accepted, Colors.orange),
                    const SizedBox(height: 12),
                    _statCard('المرفوضة', rejected, Colors.red),
                    const SizedBox(height: 12),
                    _statCard('المكتملة', completed, Colors.green),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final labels = ['Total', 'Accepted', 'Rejected', 'Completed'];
                                    final idx = value.toInt();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(labels[idx], style: const TextStyle(fontSize: 10)),
                                    );
                                  },
                                  reservedSize: 26,
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: total.toDouble(), color: Colors.blue, width: 18)]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: accepted.toDouble(), color: Colors.orange, width: 18)]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: rejected.toDouble(), color: Colors.red, width: 18)]),
                              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: completed.toDouble(), color: Colors.green, width: 18)]),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.analytics, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        ],
      ),
    );
  }
}


