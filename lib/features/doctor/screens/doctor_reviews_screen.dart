import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/rating_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/rating_service.dart';

class DoctorReviewsScreen extends StatelessWidget {
  final String doctorId;

  const DoctorReviewsScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final ratingService = RatingService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييماتي للمرضى'),
      ),
      body: StreamBuilder<List<RatingModel>>(
        stream: ratingService.getRatingsByUser(doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لم تقم بتقييم أي مريض بعد.'));
          }

          final ratings = snapshot.data!;

          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final rating = ratings[index];
              return FutureBuilder<UserModel?>(
                future: ratingService.getUserDetails(rating.toUserId),
                builder: (context, userSnapshot) {
                  final patient = userSnapshot.data;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: patient?.profileImage != null
                            ? NetworkImage(patient!.profileImage!)
                            : null,
                        child: patient?.profileImage == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(patient?.name ?? 'مريض غير معروف'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                                  (star) => Icon(
                                star < rating.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          if (rating.comment != null && rating.comment!.isNotEmpty)
                            Text(
                              rating.comment!,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          Text(
                            // 'تم بتاريخ: ${rating.createdAt.toDate().toString().split(' ').first}',

                            'تم بتاريخ: ${DateFormat('yyyy-MM-dd').format(rating.createdAt)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
