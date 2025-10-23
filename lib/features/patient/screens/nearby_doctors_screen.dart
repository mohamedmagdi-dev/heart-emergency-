// // Nearby Doctors Screen for Patients
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../data/models/user_model.dart';
// import '../../../services/firestore_service.dart';
// import '../../../services/location_service.dart';
//
// class NearbyDoctorsScreen extends ConsumerStatefulWidget {
//   const NearbyDoctorsScreen({super.key});
//
//   @override
//   ConsumerState<NearbyDoctorsScreen> createState() =>
//       _NearbyDoctorsScreenState();
// }
//
// class _NearbyDoctorsScreenState extends ConsumerState<NearbyDoctorsScreen> {
//   final FirestoreService _firestoreService = FirestoreService();
//   final LocationService _locationService = LocationService();
//   List<UserModel> _nearbyDoctors = [];
//   bool _isLoading = true;
//   String? _error;
//   double? _userLatitude;
//   double? _userLongitude;
//
//   @override
//   void initState() {
//     super.initState();
//     _getUserLocationAndNearbyDoctors();
//   }
//   Future<void> _getUserLocationAndNearbyDoctors() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });
//
//       // جلب موقع المستخدم الحالي
//       final location = await _locationService.getCurrentLocation();
//       _userLatitude = location.latitude;
//       _userLongitude = location.longitude;
//
//       print('User location: $_userLatitude, $_userLongitude'); // Debug
//
//       // جلب الدكاترة القريبين
//       final doctors = await _firestoreService.getNearbyDoctors(
//         latitude: _userLatitude!,
//         longitude: _userLongitude!,
//         radiusKm: 50.0,
//       );
//
//       // Debug: print لكل دكتور والمسافة
//       for (var d in doctors) {
//         final dist = _locationService.calculateDistance(
//           _userLatitude!,
//           _userLongitude!,
//           d.location!.latitude,
//           d.location!.longitude,
//         );
//         print('Doctor ${d.name} at $dist km');
//       }
//
//       setState(() {
//         _nearbyDoctors = doctors;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//       print('Error fetching doctors: $_error'); // Debug
//     }
//   }
//
//   // Future<void> _getUserLocationAndNearbyDoctors() async {
//   //   try {
//   //     setState(() {
//   //       _isLoading = true;
//   //       _error = null;
//   //     });
//   //
//   //     // Get user's current location
//   //     final location = await _locationService.getCurrentLocation();
//   //     _userLatitude = location.latitude;
//   //     _userLongitude = location.longitude;
//   //
//   //     // Get nearby doctors
//   //     final doctors = await _firestoreService.getNearbyDoctors(
//   //       latitude: _userLatitude!,
//   //       longitude: _userLongitude!,
//   //       radiusKm: 50.0, // 50km radius
//   //     );
//   //
//   //     setState(() {
//   //       _nearbyDoctors = doctors;
//   //       _isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     setState(() {
//   //       _error = e.toString();
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الأطباء القريبين'),
//         backgroundColor: Colors.blue[600],
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             onPressed: _getUserLocationAndNearbyDoctors,
//             icon: const Icon(Icons.refresh),
//             tooltip: 'تحديث',
//           ),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('جاري البحث عن الأطباء القريبين...'),
//           ],
//         ),
//       );
//     }
//
//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, size: 64, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(
//               'خطأ في تحميل الأطباء',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _error!,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _getUserLocationAndNearbyDoctors,
//               child: const Text('إعادة المحاولة'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_nearbyDoctors.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.local_hospital, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'لا توجد أطباء قريبين',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'لا يوجد أطباء متاحون في المنطقة القريبة منك',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _getUserLocationAndNearbyDoctors,
//               child: const Text('إعادة البحث'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _getUserLocationAndNearbyDoctors,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _nearbyDoctors.length,
//         itemBuilder: (context, index) {
//           final doctor = _nearbyDoctors[index];
//           return _buildDoctorCard(doctor);
//         },
//       ),
//     );
//   }
//
//   Widget _buildDoctorCard(UserModel doctor) {
//     final distance = _calculateDistance(doctor);
//     final estimatedArrivalTime = _calculateEstimatedArrivalTime(distance);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () => _showDoctorDetails(doctor),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.blue[100],
//                       backgroundImage: doctor.profileImage != null
//                           ? NetworkImage(doctor.profileImage!)
//                           : null,
//                       child: doctor.profileImage == null
//                           ? const Icon(
//                               Icons.person,
//                               size: 30,
//                               color: Colors.blue,
//                             )
//                           : null,
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'د. ${doctor.name}',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           if (doctor.specialization != null) ...[
//                             Text(
//                               doctor.specialization!,
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                           ],
//                           // Currency information
//                           Row(
//                             children: [
//                               Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'العملة: ${doctor.currency.arabicName}',
//                                 style: TextStyle(
//                                   color: Colors.grey[700],
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (doctor.rating != null) ...[
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.star,
//                                   size: 16,
//                                   color: Colors.amber[600],
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   doctor.rating!.toStringAsFixed(1),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   '(${doctor.reviews?.length ?? 0} تقييم)',
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: doctor.available == true
//                                 ? Colors.green
//                                 : Colors.red,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             doctor.available == true ? 'متاح' : 'غير متاح',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         // Distance information
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               size: 16,
//                               color: Colors.grey[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${distance.toStringAsFixed(1)} كم',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         // Estimated arrival time
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: 16,
//                               color: Colors.blue[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               'الوصول خلال: $estimatedArrivalTime',
//                               style: TextStyle(
//                                 color: Colors.blue[600],
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: doctor.available == true
//                             ? () => _requestDoctor(doctor)
//                             : null,
//                         icon: const Icon(Icons.phone),
//                         label: const Text('طلب طوارئ'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () => _bookAppointment(doctor),
//                         icon: const Icon(Icons.calendar_today),
//                         label: const Text('حجز موعد'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   double _calculateDistance(UserModel doctor) {
//     if (_userLatitude == null || _userLongitude == null) return 0.0;
//     if (doctor.location == null) return 0.0;
//
//     // Use the LocationService to calculate distance
//     return _locationService.calculateDistance(
//       _userLatitude!,
//       _userLongitude!,
//       doctor.location!.latitude,
//       doctor.location!.longitude,
//     );
//   }
//
//   String _calculateEstimatedArrivalTime(double distanceKm) {
//     // Assuming average speed of 30 km/h in city traffic
//     const double averageSpeedKmh = 30.0;
//     final double estimatedTimeHours = distanceKm / averageSpeedKmh;
//     final int estimatedMinutes = (estimatedTimeHours * 60).round();
//
//     if (estimatedMinutes < 60) {
//       return '$estimatedMinutes دقيقة';
//     } else {
//       final int hours = estimatedMinutes ~/ 60;
//       final int minutes = estimatedMinutes % 60;
//       if (minutes == 0) {
//         return '$hours ساعة';
//       } else {
//         return '$hours ساعة و $minutes دقيقة';
//       }
//     }
//   }
//
//   void _showDoctorDetails(UserModel doctor) {
//     final distance = _calculateDistance(doctor);
//     final estimatedArrivalTime = _calculateEstimatedArrivalTime(distance);
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('د. ${doctor.name}'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (doctor.specialization != null) ...[
//               Text('التخصص: ${doctor.specialization}'),
//               const SizedBox(height: 8),
//             ],
//             Text('العملة: ${doctor.currency.arabicName}'),
//             const SizedBox(height: 8),
//             if (doctor.rating != null) ...[
//               Row(
//                 children: [
//                   Icon(Icons.star, size: 16, color: Colors.amber[600]),
//                   const SizedBox(width: 4),
//                   Text('التقييم: ${doctor.rating!.toStringAsFixed(1)}'),
//                 ],
//               ),
//               const SizedBox(height: 8),
//             ],
//             Text('الحالة: ${doctor.available == true ? 'متاح' : 'غير متاح'}'),
//             const SizedBox(height: 8),
//             Text('المسافة: ${distance.toStringAsFixed(1)} كم'),
//             const SizedBox(height: 8),
//             Text('الوصول خلال: $estimatedArrivalTime'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إغلاق'),
//           ),
//           if (doctor.available == true)
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _requestDoctor(doctor);
//               },
//               child: const Text('طلب طوارئ'),
//             ),
//         ],
//       ),
//     );
//   }
//
//   void _requestDoctor(UserModel doctor) {
//     // Navigate to emergency request with doctor pre-selected
//     context.push('/patient/emergency-request', extra: doctor);
//   }
//
//   void _bookAppointment(UserModel doctor) {
//     // Navigate to appointment booking with doctor pre-selected
//     context.push('/patient/doctor-appointment', extra: doctor);
//   }
// }
// Nearby Doctors Screen for Patients
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/location_service.dart';

class NearbyDoctorsScreen extends ConsumerStatefulWidget {
  const NearbyDoctorsScreen({super.key});

  @override
  ConsumerState<NearbyDoctorsScreen> createState() =>
      _NearbyDoctorsScreenState();
}

class _NearbyDoctorsScreenState extends ConsumerState<NearbyDoctorsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  List<UserModel> _nearbyDoctors = [];
  bool _isLoading = true;
  String? _error;
  double? _userLatitude;
  double? _userLongitude;

  @override
  void initState() {
    super.initState();
    _getUserLocationAndNearbyDoctors();
  }

  Future<void> _getUserLocationAndNearbyDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // جلب موقع المستخدم الحالي
      final location = await _locationService.getCurrentLocation();
      _userLatitude = location.latitude;
      _userLongitude = location.longitude;

      print('User location: $_userLatitude, $_userLongitude'); // Debug

      // جلب الدكاترة القريبين
      final doctors = await _firestoreService.getNearbyDoctors(
        latitude: _userLatitude!,
        longitude: _userLongitude!,
        radiusKm: 50.0,
      );

      // Debug: print لكل دكتور والمسافة
      for (var d in doctors) {
        final dist = _locationService.calculateDistance(
          _userLatitude!,
          _userLongitude!,
          d.location!.latitude,
          d.location!.longitude,
        );
        print('Doctor ${d.name} at $dist km');
      }

      setState(() {
        _nearbyDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error fetching doctors: $_error'); // Debug
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأطباء القريبين'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _getUserLocationAndNearbyDoctors,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _buildBody(screenSize, isPortrait),
    );
  }

  Widget _buildBody(Size screenSize, bool isPortrait) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري البحث عن الأطباء القريبين...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  Icons.error,
                  size: screenSize.width * 0.15,
                  color: Colors.red
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'خطأ في تحميل الأطباء',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: screenSize.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.01),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenSize.width * 0.035,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              SizedBox(
                width: screenSize.width * 0.5,
                child: ElevatedButton(
                  onPressed: _getUserLocationAndNearbyDoctors,
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_nearbyDoctors.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  Icons.local_hospital,
                  size: screenSize.width * 0.15,
                  color: Colors.grey
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'لا توجد أطباء قريبين',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: screenSize.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.01),
              Text(
                'لا يوجد أطباء متاحون في المنطقة القريبة منك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenSize.width * 0.035,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              SizedBox(
                width: screenSize.width * 0.5,
                child: ElevatedButton(
                  onPressed: _getUserLocationAndNearbyDoctors,
                  child: const Text('إعادة البحث'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _getUserLocationAndNearbyDoctors,
      child: isPortrait
          ? _buildPortraitLayout(screenSize)
          : _buildLandscapeLayout(screenSize),
    );
  }

  Widget _buildPortraitLayout(Size screenSize) {
    return ListView.builder(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      itemCount: _nearbyDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _nearbyDoctors[index];
        return _buildDoctorCard(doctor, screenSize, true);
      },
    );
  }

  Widget _buildLandscapeLayout(Size screenSize) {
    return GridView.builder(
      padding: EdgeInsets.all(screenSize.width * 0.02),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenSize.width * 0.02,
        mainAxisSpacing: screenSize.width * 0.02,
        childAspectRatio: 2.0,
      ),
      itemCount: _nearbyDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _nearbyDoctors[index];
        return _buildDoctorCard(doctor, screenSize, false);
      },
    );
  }

  Widget _buildDoctorCard(UserModel doctor, Size screenSize, bool isPortrait) {
    final distance = _calculateDistance(doctor);
    final estimatedArrivalTime = _calculateEstimatedArrivalTime(distance);
    final bool isSmallScreen = screenSize.width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: isPortrait ? screenSize.height * 0.02 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
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
          borderRadius: BorderRadius.circular(screenSize.width * 0.04),
          onTap: () => _showDoctorDetails(doctor, screenSize),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Info Row
                _buildDoctorInfoRow(doctor, distance, estimatedArrivalTime, screenSize, isPortrait),

                SizedBox(height: screenSize.height * 0.015),

                // Action Buttons
                _buildActionButtons(doctor, screenSize, isPortrait),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfoRow(UserModel doctor, double distance, String estimatedArrivalTime, Size screenSize, bool isPortrait) {
    final bool isSmallScreen = screenSize.width < 600;

    return Row(
      children: [
        // Doctor Avatar
        CircleAvatar(
          radius: isSmallScreen ? screenSize.width * 0.06 : screenSize.width * 0.04,
          backgroundColor: Colors.blue[100],
          backgroundImage: doctor.profileImage != null
              ? NetworkImage(doctor.profileImage!)
              : null,
          child: doctor.profileImage == null
              ? Icon(
            Icons.person,
            size: isSmallScreen ? screenSize.width * 0.06 : screenSize.width * 0.04,
            color: Colors.blue,
          )
              : null,
        ),

        SizedBox(width: screenSize.width * 0.04),

        // Doctor Details
        Expanded(
          child: _buildDoctorDetails(doctor, screenSize, isPortrait),
        ),

        // Status and Distance Info
        _buildStatusAndDistanceInfo(doctor, distance, estimatedArrivalTime, screenSize, isPortrait),
      ],
    );
  }

  Widget _buildDoctorDetails(UserModel doctor, Size screenSize, bool isPortrait) {
    final bool isSmallScreen = screenSize.width < 600;
    final double fontSizeSmall = isSmallScreen ? screenSize.width * 0.03 : screenSize.width * 0.025;
    final double fontSizeMedium = isSmallScreen ? screenSize.width * 0.035 : screenSize.width * 0.03;
    final double fontSizeLarge = isSmallScreen ? screenSize.width * 0.04 : screenSize.width * 0.035;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'د. ${doctor.name}',
          style: TextStyle(
            fontSize: fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: screenSize.height * 0.005),

        if (doctor.specialization != null) ...[
          Text(
            doctor.specialization!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: fontSizeMedium,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenSize.height * 0.005),
        ],

        // Currency information
        Row(
          children: [
            Icon(
                Icons.attach_money,
                size: fontSizeSmall,
                color: Colors.green[600]
            ),
            SizedBox(width: screenSize.width * 0.01),
            Flexible(
              child: Text(
                'العملة: ${doctor.currency.arabicName}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: fontSizeSmall,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        if (doctor.rating != null) ...[
          SizedBox(height: screenSize.height * 0.005),
          Row(
            children: [
              Icon(
                Icons.star,
                size: fontSizeSmall,
                color: Colors.amber[600],
              ),
              SizedBox(width: screenSize.width * 0.01),
              Text(
                doctor.rating!.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: fontSizeSmall,
                ),
              ),
              SizedBox(width: screenSize.width * 0.02),
              Flexible(
                child: Text(
                  '(${doctor.reviews?.length ?? 0} تقييم)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: fontSizeSmall * 0.9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusAndDistanceInfo(UserModel doctor, double distance, String estimatedArrivalTime, Size screenSize, bool isPortrait) {
    final bool isSmallScreen = screenSize.width < 600;
    final double fontSizeSmall = isSmallScreen ? screenSize.width * 0.025 : screenSize.width * 0.02;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.02,
            vertical: screenSize.height * 0.005,
          ),
          decoration: BoxDecoration(
            color: doctor.available == true ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
          ),
          child: Text(
            doctor.available == true ? 'متاح' : 'غير متاح',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSizeSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: screenSize.height * 0.008),

        // Distance information
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: fontSizeSmall,
              color: Colors.grey[600],
            ),
            SizedBox(width: screenSize.width * 0.01),
            Text(
              '${distance.toStringAsFixed(1)} كم',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: fontSizeSmall,
              ),
            ),
          ],
        ),

        SizedBox(height: screenSize.height * 0.005),

        // Estimated arrival time
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: fontSizeSmall,
              color: Colors.blue[600],
            ),
            SizedBox(width: screenSize.width * 0.01),
            Flexible(
              child: Text(
                'الوصول: $estimatedArrivalTime',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: fontSizeSmall,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserModel doctor, Size screenSize, bool isPortrait) {
    final bool isSmallScreen = screenSize.width < 600;
    final bool useColumnLayout = screenSize.width < 400;

    if (useColumnLayout) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: doctor.available == true
                  ? () => _requestDoctor(doctor)
                  : null,
              icon: const Icon(Icons.phone),
              label: const Text('طلب طوارئ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _bookAppointment(doctor),
              icon: const Icon(Icons.calendar_today),
              label: const Text('حجز موعد'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: isSmallScreen ? screenSize.height * 0.05 : screenSize.height * 0.06,
            child: ElevatedButton.icon(
              onPressed: doctor.available == true
                  ? () => _requestDoctor(doctor)
                  : null,
              icon: const Icon(Icons.phone),
              label: const Text('طلب طوارئ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: screenSize.width * 0.03),
        Expanded(
          child: SizedBox(
            height: isSmallScreen ? screenSize.height * 0.05 : screenSize.height * 0.06,
            child: OutlinedButton.icon(
              onPressed: () => _bookAppointment(doctor),
              icon: const Icon(Icons.calendar_today),
              label: const Text('حجز موعد'),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateDistance(UserModel doctor) {
    if (_userLatitude == null || _userLongitude == null) return 0.0;
    if (doctor.location == null) return 0.0;

    // Use the LocationService to calculate distance
    return _locationService.calculateDistance(
      _userLatitude!,
      _userLongitude!,
      doctor.location!.latitude,
      doctor.location!.longitude,
    );
  }

  String _calculateEstimatedArrivalTime(double distanceKm) {
    // Assuming average speed of 30 km/h in city traffic
    const double averageSpeedKmh = 30.0;
    final double estimatedTimeHours = distanceKm / averageSpeedKmh;
    final int estimatedMinutes = (estimatedTimeHours * 60).round();

    if (estimatedMinutes < 60) {
      return '$estimatedMinutes دقيقة';
    } else {
      final int hours = estimatedMinutes ~/ 60;
      final int minutes = estimatedMinutes % 60;
      if (minutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و $minutes دقيقة';
      }
    }
  }

  void _showDoctorDetails(UserModel doctor, Size screenSize) {
    final distance = _calculateDistance(doctor);
    final estimatedArrivalTime = _calculateEstimatedArrivalTime(distance);
    final bool isSmallScreen = screenSize.width < 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenSize.width * 0.04),
        ),
        child: Container(
          width: isSmallScreen ? screenSize.width * 0.9 : screenSize.width * 0.6,
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'د. ${doctor.name}',
                style: TextStyle(
                  fontSize: isSmallScreen ? screenSize.width * 0.05 : screenSize.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: screenSize.height * 0.02),

              if (doctor.specialization != null) ...[
                _buildDetailRow('التخصص:', doctor.specialization!, screenSize),
                SizedBox(height: screenSize.height * 0.015),
              ],

              _buildDetailRow('العملة:', doctor.currency.arabicName, screenSize),
              SizedBox(height: screenSize.height * 0.015),

              if (doctor.rating != null) ...[
                Row(
                  children: [
                    Icon(Icons.star, size: screenSize.width * 0.04, color: Colors.amber[600]),
                    SizedBox(width: screenSize.width * 0.02),
                    Text(
                      'التقييم: ${doctor.rating!.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: screenSize.width * 0.035),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.015),
              ],

              _buildDetailRow('الحالة:', doctor.available == true ? 'متاح' : 'غير متاح', screenSize),
              SizedBox(height: screenSize.height * 0.015),

              _buildDetailRow('المسافة:', '${distance.toStringAsFixed(1)} كم', screenSize),
              SizedBox(height: screenSize.height * 0.015),

              _buildDetailRow('الوصول خلال:', estimatedArrivalTime, screenSize),

              SizedBox(height: screenSize.height * 0.03),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                  if (doctor.available == true) ...[
                    SizedBox(width: screenSize.width * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _requestDoctor(doctor);
                      },
                      child: const Text('طلب طوارئ'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Size screenSize) {
    final bool isSmallScreen = screenSize.width < 600;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? screenSize.width * 0.035 : screenSize.width * 0.03,
          ),
        ),
        SizedBox(width: screenSize.width * 0.02),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? screenSize.width * 0.035 : screenSize.width * 0.03,
            ),
          ),
        ),
      ],
    );
  }

  void _requestDoctor(UserModel doctor) {
    // Navigate to emergency request with doctor pre-selected
    context.push('/patient/emergency-request', extra: doctor);
  }

  void _bookAppointment(UserModel doctor) {
    // Navigate to appointment booking with doctor pre-selected
    context.push('/patient/doctor-appointment', extra: doctor);
  }
}