// // Rate Doctor Screen
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//
// import '../../../data/models/user_model.dart';
// import '../../../services/rating_service.dart';
//
// class RateDoctorScreen extends StatefulWidget {
//   final UserModel doctor;
//   final String? requestId;
//
//   const RateDoctorScreen({super.key, required this.doctor, this.requestId});
//
//   @override
//   State<RateDoctorScreen> createState() => _RateDoctorScreenState();
// }
//
// class _RateDoctorScreenState extends State<RateDoctorScreen> {
//   final RatingService _ratingService = RatingService();
//   final TextEditingController _commentController = TextEditingController();
//
//   double _rating = 0.0;
//   bool _isSubmitting = false;
//   bool _hasRatedBefore = false;
//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'تقييم الطبيب',
//           style: TextStyle(fontFamily: 'Janna', fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         foregroundColor: Colors.blue[600],
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Doctor Info Card
//             _buildDoctorInfoCard(),
//
//             const SizedBox(height: 24),
//
//             // Rating Section
//             _buildRatingSection(),
//
//             const SizedBox(height: 24),
//
//             // Comment Section
//             _buildCommentSection(),
//
//             const SizedBox(height: 32),
//
//             // Submit Button
//             _buildSubmitButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDoctorInfoCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.blue[100],
//             backgroundImage: widget.doctor.profileImage != null
//                 ? NetworkImage(widget.doctor.profileImage!)
//                 : null,
//             child: widget.doctor.profileImage == null
//                 ? Text(
//                     widget.doctor.name.substring(0, 1),
//                     style: TextStyle(
//                       color: Colors.blue[700],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                   )
//                 : null,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'د. ${widget.doctor.name}',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Janna',
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 if (widget.doctor.specialization != null)
//                   Text(
//                     widget.doctor.specialization!,
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                       fontFamily: 'Janna',
//                     ),
//                   ),
//                 const SizedBox(height: 8),
//                 if (widget.doctor.rating != null)
//                   Row(
//                     children: [
//                       Icon(Icons.star, size: 16, color: Colors.amber[600]),
//                       const SizedBox(width: 4),
//                       Text(
//                         widget.doctor.rating!.toStringAsFixed(1),
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 12,
//                           fontFamily: 'Janna',
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRatingSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'كيف تقيم تجربتك مع هذا الطبيب؟',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Janna',
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           RatingBar.builder(
//             initialRating: 0,
//             minRating: 1,
//             direction: Axis.horizontal,
//             allowHalfRating: true,
//             itemCount: 5,
//             itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
//             itemBuilder: (context, _) =>
//                 Icon(Icons.star, color: Colors.amber[600]),
//             onRatingUpdate: (rating) {
//               setState(() {
//                 _rating = rating;
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//           if (_rating > 0)
//             Text(
//               _getRatingText(_rating),
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//                 fontFamily: 'Janna',
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCommentSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
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
//             'تعليق (اختياري)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'Janna',
//             ),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _commentController,
//             maxLines: 4,
//             decoration: const InputDecoration(
//               hintText: 'اكتب تعليقك هنا...',
//               border: OutlineInputBorder(),
//               hintStyle: TextStyle(fontFamily: 'Janna'),
//             ),
//             style: const TextStyle(fontFamily: 'Janna'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isSubmitting ? null : _submitRating,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue[600],
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: _isSubmitting
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : const Text(
//                 'إرسال التقييم',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Janna',
//                 ),
//               ),
//       ),
//     );
//   }
//
//   // Future<void> _submitRating() async {
//   //   if (_rating == 0) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('يرجى اختيار تقييم'),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //     return;
//   //   }
//   //
//   //   setState(() => _isSubmitting = true);
//   //
//   //   try {
//   //     await _ratingService.createRating(
//   //       toUserId: widget.doctor.uid,
//   //       role: 'doctor',
//   //       rating: _rating,
//   //       comment: _commentController.text.trim().isNotEmpty
//   //           ? _commentController.text.trim()
//   //           : null,
//   //       requestId: widget.requestId,
//   //     );
//   //
//   //     // Mark the related request as rated to hide rate button later
//   //     if (widget.requestId != null) {
//   //       try {
//   //         await FirebaseFirestore.instance
//   //             .collection('requests')
//   //             .doc(widget.requestId)
//   //             .update({'isRated': true, 'updatedAt': FieldValue.serverTimestamp()});
//   //       } catch (_) {}
//   //     }
//   //
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('تم إرسال التقييم بنجاح'),
//   //           backgroundColor: Colors.green,
//   //         ),
//   //       );
//   //       Navigator.of(context).pop(true);
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text('خطأ في إرسال التقييم: $e'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() => _isSubmitting = false);
//   //     }
//   //   }
//   // }
//   Future<void> _submitRating() async {
//     if (_rating == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('يرجى اختيار تقييم'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       await _ratingService.createRating(
//         toUserId: widget.doctor.uid,
//         role: 'doctor',
//         rating: _rating,
//         comment: _commentController.text.trim().isNotEmpty
//             ? _commentController.text.trim()
//             : null,
//         requestId: widget.requestId,
//       );
//
//       // هنا علشان نخلي الزر يتغير في الداشبورد
//       if (widget.requestId != null) {
//         try {
//           await FirebaseFirestore.instance
//               .collection('requests')
//               .doc(widget.requestId)
//               .update({
//             'isRated': true,  // بنضيف حقل جديد علشان نعرف إن الطلب اتعمل له تقييم
//             'updatedAt': FieldValue.serverTimestamp()
//           });
//         } catch (_) {}
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم إرسال التقييم بنجاح ✅'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.of(context).pop(true); // بنرجع مع قيمة true علشان نعرف إن التقييم تم
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في إرسال التقييم: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }
//
//   String _getRatingText(double rating) {
//     if (rating >= 4.5) return 'ممتاز';
//     if (rating >= 3.5) return 'جيد جداً';
//     if (rating >= 2.5) return 'جيد';
//     if (rating >= 1.5) return 'مقبول';
//     return 'ضعيف';
//   }
// }
// Rate Doctor Screen
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../data/models/user_model.dart';
import '../../../services/rating_service.dart';

class RateDoctorScreen extends StatefulWidget {
  final UserModel doctor;
  final String? requestId;

  const RateDoctorScreen({super.key, required this.doctor, this.requestId});

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  final RatingService _ratingService = RatingService();
  final TextEditingController _commentController = TextEditingController();

  double _rating = 0.0;
  bool _isSubmitting = false;
  bool _hasRatedBefore = false;

  @override
  void initState() {
    super.initState();
    _checkExistingRating();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // دالة علشان نشوف إذا في تقييم موجود للطلب ده
  // Future<void> _checkExistingRating() async {
  //   if (widget.requestId == null) return;
  //
  //   try {
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) return;
  //
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('ratings')
  //         .where('requestId', isEqualTo: widget.requestId)
  //         .where('fromUserId', isEqualTo: currentUser.uid)
  //         .limit(1)
  //         .get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       final ratingData = querySnapshot.docs.first.data();
  //       setState(() {
  //         _hasRatedBefore = true;
  //         _rating = (ratingData['rating'] as num).toDouble();
  //         _commentController.text = ratingData['comment'] ?? '';
  //       });
  //
  //       print('✅ Found existing rating: $_rating');
  //     }
  //   } catch (e) {
  //     print('❌ Error checking existing rating: $e');
  //   }
  // }
  Future<void> _checkExistingRating() async {
    if (widget.requestId == null) {
      print('⚠️ No requestId provided');
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('⚠️ No current user');
        return;
      }

      print('🔍 Checking for existing rating...');
      print('📝 RequestId: ${widget.requestId}');
      print('👤 FromUserId: ${currentUser.uid}');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('requestId', isEqualTo: widget.requestId)
          .where('fromUserId', isEqualTo: currentUser.uid)
          .get(); // ✅ شيلنا limit(1) علشان نتأكد إننا بنجيب كل النتايج

      print('📊 Found ${querySnapshot.docs.length} ratings');

      if (querySnapshot.docs.isNotEmpty) {
        final ratingData = querySnapshot.docs.first.data();

        print('✅ Rating found!');
        print('⭐ Rating: ${ratingData['rating']}');
        print('💬 Comment: ${ratingData['comment']}');

        setState(() {
          _hasRatedBefore = true;
          _rating = (ratingData['rating'] as num).toDouble();
          _commentController.text = ratingData['comment'] ?? '';
        });
      } else {
        print('❌ No rating found');
      }
    } catch (e) {
      print('❌ Error checking existing rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _hasRatedBefore ? 'تقييمك للطبيب' : 'تقييم الطبيب',
          style: const TextStyle(fontFamily: 'Janna', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: _hasRatedBefore
          ? _buildRatingSummary()
          : _buildRatingForm(),
    );
  }

  Widget _buildRatingSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Doctor Info Card
          _buildDoctorInfoCard(),

          const SizedBox(height: 24),

          // Rating Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'لقد قمت بتقييم هذا الطبيب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontFamily: 'Janna',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // النجوم
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: Colors.amber[600]),
                  onRatingUpdate: (rating) {
                    // مش بنسمح يتغير علشان ده مجرد عرض
                  },
                  ignoreGestures: true,
                ),

                const SizedBox(height: 8),
                Text(
                  _getRatingText(_rating),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    fontFamily: 'Janna',
                  ),
                ),

                // التعليق إذا موجود
                if (_commentController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تعليقك:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Janna',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _commentController.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Janna',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // زر الرجوع
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'رجوع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Janna',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Doctor Info Card
          _buildDoctorInfoCard(),

          const SizedBox(height: 24),

          // Rating Section
          _buildRatingSection(),

          const SizedBox(height: 24),

          // Comment Section
          _buildCommentSection(),

          const SizedBox(height: 32),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
    return Container(
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
            radius: 30,
            backgroundColor: Colors.blue[100],
            backgroundImage: widget.doctor.profileImage != null
                ? NetworkImage(widget.doctor.profileImage!)
                : null,
            child: widget.doctor.profileImage == null
                ? Text(
              widget.doctor.name.substring(0, 1),
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
                  'د. ${widget.doctor.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Janna',
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.doctor.specialization != null)
                  Text(
                    widget.doctor.specialization!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'Janna',
                    ),
                  ),
                const SizedBox(height: 8),
                if (widget.doctor.rating != null)
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.doctor.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontFamily: 'Janna',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
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
      child: Column(
        children: [
          const Text(
            'كيف تقيم تجربتك مع هذا الطبيب؟',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Janna',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) =>
                Icon(Icons.star, color: Colors.amber[600]),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_rating > 0)
            Text(
              _getRatingText(_rating),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: 'Janna',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تعليق (اختياري)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Janna',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'اكتب تعليقك هنا...',
              border: OutlineInputBorder(),
              hintStyle: TextStyle(fontFamily: 'Janna'),
            ),
            style: const TextStyle(fontFamily: 'Janna'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRating,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'إرسال التقييم',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Janna',
          ),
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تقييم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _ratingService.createRating(
        toUserId: widget.doctor.uid,
        role: 'doctor',
        rating: _rating,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        requestId: widget.requestId,
      );

      // Mark the related request as rated to hide rate button later
      if (widget.requestId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('requests')
              .doc(widget.requestId)
              .update({'isRated': true, 'updatedAt': FieldValue.serverTimestamp()});
        } catch (_) {}
      }

      if (mounted) {
        // هنا بنغير الـ state علشان يظهر الشكل الجديد
        setState(() {
          _hasRatedBefore = true;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال التقييم بنجاح ✅'),
            backgroundColor: Colors.green,
          ),
        );

        // مش بنعمل pop علشان اليوزر يشوف التقييم اللي عمله
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إرسال التقييم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'ممتاز';
    if (rating >= 3.5) return 'جيد جداً';
    if (rating >= 2.5) return 'جيد';
    if (rating >= 1.5) return 'مقبول';
    return 'ضعيف';
  }
}