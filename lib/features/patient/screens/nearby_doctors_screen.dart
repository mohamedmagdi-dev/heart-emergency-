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

  // Future<void> _getUserLocationAndNearbyDoctors() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _error = null;
  //     });
  //
  //     // Get user's current location
  //     final location = await _locationService.getCurrentLocation();
  //     _userLatitude = location.latitude;
  //     _userLongitude = location.longitude;
  //
  //     // Get nearby doctors
  //     final doctors = await _firestoreService.getNearbyDoctors(
  //       latitude: _userLatitude!,
  //       longitude: _userLongitude!,
  //       radiusKm: 50.0, // 50km radius
  //     );
  //
  //     setState(() {
  //       _nearbyDoctors = doctors;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
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
            Text('جاري البحث عن الأطباء القريبين...'),
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
              'خطأ في تحميل الأطباء',
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
              onPressed: _getUserLocationAndNearbyDoctors,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_nearbyDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_hospital, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد أطباء قريبين',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يوجد أطباء متاحون في المنطقة القريبة منك',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getUserLocationAndNearbyDoctors,
              child: const Text('إعادة البحث'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _getUserLocationAndNearbyDoctors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _nearbyDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _nearbyDoctors[index];
          return _buildDoctorCard(doctor);
        },
      ),
    );
  }

  Widget _buildDoctorCard(UserModel doctor) {
    final distance = _calculateDistance(doctor);

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
          onTap: () => _showDoctorDetails(doctor),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: doctor.profileImage != null
                          ? NetworkImage(doctor.profileImage!)
                          : null,
                      child: doctor.profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.blue,
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
                          const SizedBox(height: 4),
                          Text(
                            'العملة: ${doctor.currency.name.isNotEmpty ? doctor.currency.name : 'Not set'}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
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
                          if (doctor.rating != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  doctor.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${doctor.reviews?.length ?? 0} تقييم)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                            color: doctor.available == true
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doctor.available == true ? 'متاح' : 'غير متاح',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance.toStringAsFixed(1)} كم',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _bookAppointment(doctor),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('حجز موعد'),
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

  void _showDoctorDetails(UserModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('د. ${doctor.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doctor.specialization != null) ...[
              Text('التخصص: ${doctor.specialization}'),
              const SizedBox(height: 8),
            ],
            if (doctor.rating != null) ...[
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text('التقييم: ${doctor.rating!.toStringAsFixed(1)}'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text('الحالة: ${doctor.available == true ? 'متاح' : 'غير متاح'}'),
            const SizedBox(height: 8),
            Text(
              'المسافة: ${_calculateDistance(doctor).toStringAsFixed(1)} كم',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (doctor.available == true)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _requestDoctor(doctor);
              },
              child: const Text('طلب طوارئ'),
            ),
        ],
      ),
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
