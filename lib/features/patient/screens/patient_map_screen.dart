// // // Patient Map Screen with proper location permission handling
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:permission_handler/permission_handler.dart';
// //
// // import '../../../data/models/user_model.dart';
// // import '../../../services/firestore_service.dart';
// // import '../../../services/location_service.dart';
// //
// // class PatientMapScreen extends ConsumerStatefulWidget {
// //   const PatientMapScreen({super.key});
// //
// //   @override
// //   ConsumerState<PatientMapScreen> createState() => _PatientMapScreenState();
// // }
// //
// // class _PatientMapScreenState extends ConsumerState<PatientMapScreen> {
// //   final FirestoreService _firestoreService = FirestoreService();
// //   final LocationService _locationService = LocationService();
// //
// //   GoogleMapController? _mapController;
// //   Position? _currentPosition;
// //   Set<Marker> _markers = {};
// //   List<UserModel> _nearbyDoctors = [];
// //   bool _isLoading = true;
// //   String? _error;
// //   bool _locationPermissionGranted = false;
// //   bool _isRequestingPermission = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeMap();
// //   }
// //
// //   Future<void> _initializeMap() async {
// //     await _requestLocationPermission();
// //     if (_locationPermissionGranted) {
// //       await _getCurrentLocationAndNearbyDoctors();
// //     }
// //   }
// //
// //   Future<void> _requestLocationPermission() async {
// //     setState(() => _isRequestingPermission = true);
// //
// //     try {
// //       // Check if location services are enabled
// //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //       if (!serviceEnabled) {
// //         setState(() {
// //           _error = 'خدمات الموقع غير مفعلة. يرجى تفعيلها من الإعدادات.';
// //           _isRequestingPermission = false;
// //         });
// //         return;
// //       }
// //
// //       // Check current permission status
// //       LocationPermission permission = await Geolocator.checkPermission();
// //
// //       if (permission == LocationPermission.denied) {
// //         // Request permission
// //         permission = await Geolocator.requestPermission();
// //         if (permission == LocationPermission.denied) {
// //           setState(() {
// //             _error = 'تم رفض إذن الموقع. يرجى السماح بالوصول للموقع لعرض الخريطة.';
// //             _isRequestingPermission = false;
// //           });
// //           return;
// //         }
// //       }
// //
// //       if (permission == LocationPermission.deniedForever) {
// //         setState(() {
// //           _error = 'تم رفض إذن الموقع نهائياً. يرجى السماح بالوصول من إعدادات التطبيق.';
// //           _isRequestingPermission = false;
// //         });
// //         return;
// //       }
// //
// //       setState(() {
// //         _locationPermissionGranted = true;
// //         _isRequestingPermission = false;
// //       });
// //
// //     } catch (e) {
// //       setState(() {
// //         _error = 'خطأ في طلب إذن الموقع: $e';
// //         _isRequestingPermission = false;
// //       });
// //     }
// //   }
// //
// //   Future<void> _getCurrentLocationAndNearbyDoctors() async {
// //     if (!_locationPermissionGranted) return;
// //
// //     setState(() => _isLoading = true);
// //
// //     try {
// //       // Get current location
// //       _currentPosition = await _locationService.getCurrentLocation();
// //
// //       // Get nearby doctors
// //       _nearbyDoctors = await _firestoreService.getNearbyDoctors(
// //         latitude: _currentPosition!.latitude,
// //         longitude: _currentPosition!.longitude,
// //         radiusKm: 50.0,
// //       );
// //
// //       // Create markers
// //       _createMarkers();
// //
// //       // Move camera to current location
// //       if (_mapController != null && _currentPosition != null) {
// //         await _mapController!.animateCamera(
// //           CameraUpdate.newLatLng(
// //             LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
// //           ),
// //         );
// //       }
// //
// //       setState(() {
// //         _isLoading = false;
// //         _error = null;
// //       });
// //
// //     } catch (e) {
// //       setState(() {
// //         _error = 'خطأ في جلب الموقع أو الأطباء: $e';
// //         _isLoading = false;
// //       });
// //     }
// //   }
// //
// //   void _createMarkers() {
// //     _markers.clear();
// //
// //     // Add current location marker
// //     if (_currentPosition != null) {
// //       _markers.add(
// //         Marker(
// //           markerId: const MarkerId('current_location'),
// //           position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
// //           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
// //           infoWindow: const InfoWindow(
// //             title: 'موقعك الحالي',
// //             snippet: 'أنت هنا',
// //           ),
// //         ),
// //       );
// //     }
// //
// //     // Add doctor markers
// //     for (int i = 0; i < _nearbyDoctors.length; i++) {
// //       final doctor = _nearbyDoctors[i];
// //       if (doctor.location != null) {
// //         final distance = _locationService.calculateDistance(
// //           _currentPosition!.latitude,
// //           _currentPosition!.longitude,
// //           doctor.location!.latitude,
// //           doctor.location!.longitude,
// //         );
// //
// //         _markers.add(
// //           Marker(
// //             markerId: MarkerId('doctor_${doctor.uid}'),
// //             position: LatLng(doctor.location!.latitude, doctor.location!.longitude),
// //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
// //             infoWindow: InfoWindow(
// //               title: 'د. ${doctor.name}',
// //               snippet: '${doctor.specialization ?? 'طبيب عام'} - ${distance.toStringAsFixed(1)} كم',
// //             ),
// //             onTap: () => _showDoctorDetails(doctor, distance),
// //           ),
// //         );
// //       }
// //     }
// //   }
// //
// //   void _showDoctorDetails(UserModel doctor, double distance) {
// //     // Calculate ETA based on distance (assuming average speed of 50 km/h in city)
// //     final etaMinutes = (distance / 50 * 60).round();
// //     final etaText = etaMinutes < 60
// //         ? '${etaMinutes} دقيقة'
// //         : '${(etaMinutes / 60).floor()} ساعة و ${etaMinutes % 60} دقيقة';
// //
// //     showModalBottomSheet(
// //       context: context,
// //       builder: (context) => Container(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               children: [
// //                 CircleAvatar(
// //                   radius: 30,
// //                   backgroundImage: doctor.profileImage != null
// //                       ? NetworkImage(doctor.profileImage!)
// //                       : null,
// //                   child: doctor.profileImage == null
// //                       ? Text(doctor.name.substring(0, 1))
// //                       : null,
// //                 ),
// //                 const SizedBox(width: 16),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'د. ${doctor.name}',
// //                         style: const TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       if (doctor.specialization != null)
// //                         Text(
// //                           doctor.specialization!,
// //                           style: const TextStyle(color: Colors.grey),
// //                         ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         children: [
// //                           Icon(Icons.location_on, size: 16, color: Colors.blue),
// //                           const SizedBox(width: 4),
// //                           Text(
// //                             '${distance.toStringAsFixed(1)} كم',
// //                             style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         children: [
// //                           Icon(Icons.access_time, size: 16, color: Colors.orange),
// //                           const SizedBox(width: 4),
// //                           Text(
// //                             'الوقت المتوقع: $etaText',
// //                             style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
// //                           ),
// //                         ],
// //                       ),
// //                       if (doctor.rating != null && doctor.rating! > 0) ...[
// //                         const SizedBox(height: 4),
// //                         Row(
// //                           children: [
// //                             Icon(Icons.star, size: 16, color: Colors.amber),
// //                             const SizedBox(width: 4),
// //                             Text(
// //                               '${doctor.rating!.toStringAsFixed(1)} ⭐',
// //                               style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //                 if (doctor.verified == true)
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                     decoration: BoxDecoration(
// //                       color: Colors.green,
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: const Text(
// //                       'محقق',
// //                       style: TextStyle(color: Colors.white, fontSize: 12),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: ElevatedButton.icon(
// //                     onPressed: () {
// //                       Navigator.pop(context);
// //                       // Navigate to emergency request screen with selected doctor
// //                       Navigator.pushNamed(
// //                         context,
// //                         '/patient/emergency-request',
// //                         arguments: {'selectedDoctor': doctor},
// //                       );
// //                     },
// //                     icon: const Icon(Icons.emergency),
// //                     label: const Text('طلب طوارئ'),
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.red,
// //                       foregroundColor: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: OutlinedButton.icon(
// //                     onPressed: () {
// //                       Navigator.pop(context);
// //                       // Navigate to appointment booking
// //                       Navigator.pushNamed(
// //                         context,
// //                         '/patient/appointment',
// //                         arguments: {'doctor': doctor},
// //                       );
// //                     },
// //                     icon: const Icon(Icons.calendar_today),
// //                     label: const Text('حجز موعد'),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _refreshMap() async {
// //     if (_locationPermissionGranted) {
// //       await _getCurrentLocationAndNearbyDoctors();
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('خريطة الأطباء'),
// //         backgroundColor: Colors.red[600],
// //         foregroundColor: Colors.white,
// //         actions: [
// //           IconButton(
// //             onPressed: _refreshMap,
// //             icon: const Icon(Icons.refresh),
// //           ),
// //         ],
// //       ),
// //       body: _buildBody(),
// //       floatingActionButton: _locationPermissionGranted
// //           ? FloatingActionButton(
// //               onPressed: () async {
// //                 if (_currentPosition != null && _mapController != null) {
// //                   await _mapController!.animateCamera(
// //                     CameraUpdate.newLatLngZoom(
// //                       LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
// //                       15.0,
// //                     ),
// //                   );
// //                 }
// //               },
// //               backgroundColor: Colors.red[600],
// //               child: const Icon(Icons.my_location, color: Colors.white),
// //             )
// //           : null,
// //     );
// //   }
// //
// //   Widget _buildBody() {
// //     if (_isRequestingPermission) {
// //       return const Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(),
// //             SizedBox(height: 16),
// //             Text('جاري طلب إذن الموقع...'),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     if (!_locationPermissionGranted) {
// //       return Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(
// //                 Icons.location_off,
// //                 size: 80,
// //                 color: Colors.grey,
// //               ),
// //               const SizedBox(height: 20),
// //               Text(
// //                 _error ?? 'يحتاج التطبيق إلى إذن الموقع لعرض الخريطة',
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(fontSize: 16),
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton.icon(
// //                 onPressed: () async {
// //                   await openAppSettings();
// //                 },
// //                 icon: const Icon(Icons.settings),
// //                 label: const Text('فتح الإعدادات'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.red[600],
// //                   foregroundColor: Colors.white,
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //               OutlinedButton.icon(
// //                 onPressed: _requestLocationPermission,
// //                 icon: const Icon(Icons.refresh),
// //                 label: const Text('إعادة المحاولة'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     if (_isLoading) {
// //       return const Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(),
// //             SizedBox(height: 16),
// //             Text('جاري تحميل الخريطة...'),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     if (_error != null) {
// //       return Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(
// //                 Icons.error_outline,
// //                 size: 80,
// //                 color: Colors.red,
// //               ),
// //               const SizedBox(height: 20),
// //               Text(
// //                 _error!,
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(fontSize: 16),
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton.icon(
// //                 onPressed: _refreshMap,
// //                 icon: const Icon(Icons.refresh),
// //                 label: const Text('إعادة المحاولة'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     return Stack(
// //       children: [
// //         GoogleMap(
// //           initialCameraPosition: CameraPosition(
// //             target: _currentPosition != null
// //                 ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
// //                 : const LatLng(24.7136, 46.6753), // Default to Riyadh
// //             zoom: 15.0,
// //           ),
// //           markers: _markers,
// //           myLocationEnabled: true,
// //           myLocationButtonEnabled: false, // We have our own FAB
// //           zoomControlsEnabled: true,
// //           mapToolbarEnabled: true,
// //           compassEnabled: true,
// //           mapType: MapType.normal,
// //           buildingsEnabled: true,
// //           trafficEnabled: false,
// //           onMapCreated: (GoogleMapController controller) {
// //             _mapController = controller;
// //           },
// //           onTap: (LatLng position) {
// //             // Handle map tap if needed
// //           },
// //         ),
// //         Positioned(
// //           top: 16,
// //           left: 16,
// //           right: 16,
// //           child: Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(8),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.1),
// //                   blurRadius: 4,
// //                   offset: const Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: Text(
// //               'تم العثور على ${_nearbyDoctors.length} طبيب بالقرب منك',
// //               style: const TextStyle(fontWeight: FontWeight.bold),
// //               textAlign: TextAlign.center,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class PatientMapScreen extends StatefulWidget {
  final double doctorLat;
  final double doctorLng;

  const PatientMapScreen({
    super.key,
    required this.doctorLat,
    required this.doctorLng,
  });

  @override
  State<PatientMapScreen> createState() => _PatientMapScreenState();
}

class _PatientMapScreenState extends State<PatientMapScreen> {
  final MapController _mapController = MapController();
  Position? _patientPosition;
  LatLng? _doctorPosition;
  List<LatLng> _routePoints = [];
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStreamSub;
  String _distanceText = '';
  LatLng? _customMarker;
  List<LatLng> _routeFromCustom = [];
  String _customDistanceText = '';

  @override
  void initState() {
    super.initState();
    _doctorPosition = LatLng(widget.doctorLat, widget.doctorLng);
    _initialize();
  }

  Future<void> _initialize() async {
    await _getPatientLocation();

    // Doctor marker
    _markers.add(
      Marker(
        point: _doctorPosition!,
        width: 80,
        height: 80,
        child: const Icon(Icons.local_hospital, color: Colors.green, size: 40),
      ),
    );

    // Patient marker
    _markers.add(
      Marker(
        point: LatLng(_patientPosition!.latitude, _patientPosition!.longitude),
        width: 80,
        height: 80,
        child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
      ),
    );

    await _getRoute();
    _startLocationStream();
  }

  Future<void> _getPatientLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'خدمات الموقع غير مفعلة';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'تم رفض إذن الموقع';
      }
    }

    _patientPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  void _startLocationStream() {
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      _patientPosition = position;
      _updatePatientMarker();
      await _getRoute();
      setState(() {});
    });
  }

  void _updatePatientMarker() {
    // إزالة الـ marker القديم للمريض بناءً على موقعه
    _markers.removeWhere((m) =>
    m.point.latitude == _patientPosition!.latitude &&
        m.point.longitude == _patientPosition!.longitude);
    // إضافة marker جديد للمريض
    _markers.add(
      Marker(
        point: LatLng(_patientPosition!.latitude, _patientPosition!.longitude),
        width: 80,
        height: 80,
        child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
      ),
    );
  }

  Future<void> _getRoute() async {
    if (_patientPosition == null || _doctorPosition == null) return;

    final doctorLat = _doctorPosition!.latitude;
    final doctorLng = _doctorPosition!.longitude;
    final patientLat = _patientPosition!.latitude;
    final patientLng = _patientPosition!.longitude;

    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '$doctorLng,$doctorLat;$patientLng,$patientLat?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;
          _routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
          _calculateDistance();
          setState(() {});
        }
      }
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  void _calculateDistance() {
    if (_patientPosition == null || _doctorPosition == null) return;
    final distance = Geolocator.distanceBetween(
      _patientPosition!.latitude,
      _patientPosition!.longitude,
      _doctorPosition!.latitude,
      _doctorPosition!.longitude,
    );
    _distanceText = (distance / 1000).toStringAsFixed(2) + ' كم';
  }

  Future<void> _getRouteFromCustom() async {
    if (_customMarker == null || _doctorPosition == null) return;

    final doctorLat = _doctorPosition!.latitude;
    final doctorLng = _doctorPosition!.longitude;
    final customLat = _customMarker!.latitude;
    final customLng = _customMarker!.longitude;

    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '$doctorLng,$doctorLat;$customLng,$customLat?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;
          _routeFromCustom = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

          // Distance
          final distance = Geolocator.distanceBetween(
            _customMarker!.latitude,
            _customMarker!.longitude,
            _doctorPosition!.latitude,
            _doctorPosition!.longitude,
          );
          _customDistanceText = (distance / 1000).toStringAsFixed(2) + ' كم';
          setState(() {});
        }
      }
    } catch (e) {
      print('Error getting custom route: $e');
    }
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_patientPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة الطوارئ'),
        backgroundColor: Colors.red[600],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_patientPosition!.latitude, _patientPosition!.longitude),
              initialZoom: 13,
              onTap: (tapPosition, point) async {
                _customMarker = point;
                _markers.add(
                  Marker(
                    point: point,
                    width: 80,
                    height: 80,
                    child:const Icon(Icons.location_on, color: Colors.purple, size: 40),
                  ),
                );
                await _getRouteFromCustom();
                setState(() {});
              },
            ),
            children: [
              TileLayer(
                // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
               urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.app',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              if (_routeFromCustom.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeFromCustom,
                      color: Colors.purple,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(markers: _markers.toList()),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'المسافة بينك وبين الطبيب: $_distanceText',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_customMarker != null)
                    Text(
                      'المسافة من النقطة المضافة للطبيب: $_customDistanceText',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
