import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/rating_service.dart';
import '../../../data/models/rating_model.dart';


class AdminRatingsScreen extends StatefulWidget {
  const AdminRatingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminRatingsScreen> createState() => _AdminRatingsScreenState();
}

class _AdminRatingsScreenState extends State<AdminRatingsScreen> {
  final RatingService _ratingService = RatingService();

  late Future<Map<String, dynamic>> _statsFuture;
  late Stream<List<RatingModel>> _ratingsStream;

  @override
  void initState() {
    super.initState();
    _statsFuture = _ratingService.getRatingStatistics();
    _ratingsStream = _ratingService.getAllRatings();
  }

  // ✅ تنسيق التاريخ
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 تقييمات المستخدمين'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // ================= الإحصائيات =================
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final stats = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      label: 'إجمالي التقييمات',
                      value: stats['totalRatings'].toString(),
                      icon: Icons.star_rate,
                      color: Colors.amber,
                    ),
                    _buildStatCard(
                      label: 'المتوسط العام',
                      value: stats['averageRating'].toStringAsFixed(1),
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      label: 'آخر أسبوع',
                      value: stats['recentRatings'].toString(),
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // ================= قائمة التقييمات =================
          Expanded(
            child: StreamBuilder<List<RatingModel>>(
              stream: _ratingsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد تقييمات بعد'));
                }

                final ratings = snapshot.data!;
                return ListView.builder(
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    final rating = ratings[index];
                    final date =
                    (rating.createdAt ?? DateTime.now());

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(Icons.star, color: Colors.amber[700], size: 30),
                        title: Text(
                          '⭐ ${rating.rating.toStringAsFixed(1)} - ${rating.role == "doctor" ? "تقييم لدكتور" : "تقييم لمريض"}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'من: ${rating.fromUserId}\nإلى: ${rating.toUserId}\n${rating.comment ?? ""}\n${_formatDate(date)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 كارت إحصائي صغير
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
