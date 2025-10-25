// Rated Doctors Screen for Patients
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/rating_model.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../services/rating_service.dart';

class RatedDoctorsScreen extends ConsumerStatefulWidget {
  const RatedDoctorsScreen({super.key});

  @override
  ConsumerState<RatedDoctorsScreen> createState() => _RatedDoctorsScreenState();
}

class _RatedDoctorsScreenState extends ConsumerState<RatedDoctorsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final RatingService _ratingService = RatingService();
  List<Map<String, dynamic>> _ratedDoctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRatedDoctors();
  }

  Future<void> _loadRatedDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final currentUserAsync = ref.read(currentUserDataProvider);
      final currentUser = currentUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      if (currentUser == null) {
        setState(() {
          _error = 'المستخدم غير مسجل الدخول';
          _isLoading = false;
        });
        return;
      }

      // Get all ratings by this patient
      final ratings = await _ratingService.getRatingsByPatient(currentUser.uid);

      // Get unique doctors and their latest ratings
      final Map<String, RatingModel> doctorRatings = {};
      for (final rating in ratings) {
        doctorRatings[rating.toUserId] = rating;
      }

      final List<Map<String, dynamic>> ratedDoctors = [];
      for (final entry in doctorRatings.entries) {
        final doctor = await _firestoreService.getUser(entry.key);
        if (doctor != null) {
          ratedDoctors.add({'doctor': doctor, 'rating': entry.value});
        }
      }

      // Sort by rating date (most recent first)
      ratedDoctors.sort(
        (a, b) => b['rating'].createdAt.compareTo(a['rating'].createdAt),
      );

      setState(() {
        _ratedDoctors = ratedDoctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأطباء المقيمين'),
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadRatedDoctors,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل الأطباء المقيمين...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRatedDoctors,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_ratedDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد تقييمات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'لم تقم بتقييم أي طبيب بعد',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/patient/dashboard'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRatedDoctors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _ratedDoctors.length,
        itemBuilder: (context, index) {
          final entry = _ratedDoctors[index];
          final doctor = entry['doctor'] as UserModel;
          final rating = entry['rating'] as RatingModel;
          return _buildRatedDoctorCard(doctor, rating);
        },
      ),
    );
  }

  Widget _buildRatedDoctorCard(UserModel doctor, RatingModel rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRatingDetails(doctor, rating),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.amber[100],
                      backgroundImage: doctor.profileImage != null
                          ? NetworkImage(doctor.profileImage!)
                          : null,
                      child: doctor.profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.amber,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'د. ${doctor.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (doctor.specialization != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialization!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < rating.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber[600],
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '${rating.rating}/5',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'مقيم',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDateTime(rating.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rating.comment!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rateDoctorAgain(doctor),
                        icon: const Icon(Icons.star),
                        label: const Text('تقييم مرة أخرى'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bookAppointment(doctor),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('حجز موعد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingDetails(UserModel doctor, RatingModel rating) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تقييم د. ${doctor.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star : Icons.star_border,
                    size: 20,
                    color: Colors.amber[600],
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${rating.rating}/5',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const Text(
                'التعليق:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(rating.comment!),
              const SizedBox(height: 16),
            ],
            Text(
              'تاريخ التقييم: ${_formatDateTime(rating.createdAt)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rateDoctorAgain(doctor);
            },
            child: const Text('تقييم مرة أخرى'),
          ),
        ],
      ),
    );
  }

  void _rateDoctorAgain(UserModel doctor) {
    // Navigate to rate doctor screen
    context.push('/patient/rate-doctor', extra: doctor);
  }

  void _bookAppointment(UserModel doctor) {
    // Navigate to appointment booking with doctor pre-selected
    context.push('/patient/doctor-appointment', extra: doctor);
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
