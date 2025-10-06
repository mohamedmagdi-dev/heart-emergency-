// import 'package:flutter/material.dart';
//
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../../data/models/request_model.dart';
// import '../../../data/models/user_model.dart';
//
// class DoctorEmergencyMapScreen extends StatefulWidget {
//   final RequestModel request;
//   final UserModel patient;
//
//   const DoctorEmergencyMapScreen({
//     super.key,
//     required this.request,
//     required this.patient,
//   });
//
//   @override
//   State<DoctorEmergencyMapScreen> createState() => _DoctorEmergencyMapScreenState();
// }
//
// class _DoctorEmergencyMapScreenState extends State<DoctorEmergencyMapScreen> {
//   final MapController _mapController = MapController();
//   Position? _doctorPosition;
//   List<LatLng> _routePoints = [];
//   bool _isLoadingRoute = false;
//   double? _distance;
//   double? _duration;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeMap();
//   }
//
//   Future<void> _initializeMap() async {
//     await _getDoctorLocation();
//     if (_doctorPosition != null) {
//       await _getRoute();
//     }
//   }
//
//   Future<void> _getDoctorLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         setState(() => _errorMessage = 'خدمات الموقع غير مفعلة');
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() => _errorMessage = 'تم رفض إذن الموقع');
//           return;
//         }
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
//       );
//
//       setState(() {
//         _doctorPosition = position;
//         _errorMessage = '';
//       });
//
//       // تحريك الكاميرا لعرض كل النقاط
//       _fitBounds();
//     } catch (e) {
//       setState(() => _errorMessage = 'خطأ في تحديد الموقع: $e');
//     }
//   }
//
//   Future<void> _getRoute() async {
//     if (_doctorPosition == null) return;
//
//     setState(() => _isLoadingRoute = true);
//
//     try {
//       final doctorLat = _doctorPosition!.latitude;
//       final doctorLng = _doctorPosition!.longitude;
//       final patientLat = widget.request.patientLocation.latitude;
//       final patientLng = widget.request.patientLocation.longitude;
//
//       // استخدام OSRM API للحصول على المسار
//       final url = 'https://router.project-osrm.org/route/v1/driving/'
//           '$doctorLng,$doctorLat;$patientLng,$patientLat'
//           '?overview=full&geometries=geojson';
//
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['routes'] != null && data['routes'].isNotEmpty) {
//           final route = data['routes'][0];
//           final coordinates = route['geometry']['coordinates'] as List;
//
//           setState(() {
//             _routePoints = coordinates
//                 .map((coord) => LatLng(coord[1], coord[0]))
//                 .toList();
//             _distance = route['distance'] / 1000; // تحويل لكيلومتر
//             _duration = route['duration'] / 60; // تحويل لدقائق
//             _isLoadingRoute = false;
//           });
//         }
//       } else {
//         setState(() {
//           _isLoadingRoute = false;
//           _errorMessage = 'خطأ في الحصول على المسار';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingRoute = false;
//         _errorMessage = 'خطأ: $e';
//       });
//     }
//   }
//
//   void _fitBounds() {
//     if (_doctorPosition == null) return;
//
//     final doctorLatLng = LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude);
//     final patientLatLng = LatLng(
//       widget.request.patientLocation.latitude,
//       widget.request.patientLocation.longitude,
//     );
//
//     final bounds = LatLngBounds(doctorLatLng, patientLatLng);
//     _mapController.fitCamera(
//       CameraFit.bounds(
//         bounds: bounds,
//         padding: const EdgeInsets.all(50),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('خريطة الطوارئ'),
//         backgroundColor: Colors.red[600],
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.my_location),
//             onPressed: () {
//               _getDoctorLocation();
//               _fitBounds();
//             },
//             tooltip: 'تحديث الموقع',
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _getRoute,
//             tooltip: 'تحديث المسار',
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // الخريطة
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _doctorPosition != null
//                   ? LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude)
//                   : LatLng(
//                 widget.request.patientLocation.latitude,
//                 widget.request.patientLocation.longitude,
//               ),
//               initialZoom: 13,
//               minZoom: 5,
//               maxZoom: 18,
//             ),
//             children: [
//               // طبقة الخريطة من OpenStreetMap
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.example.emergency_app',
//                 maxZoom: 19,
//               ),
//
//               // رسم المسار
//               if (_routePoints.isNotEmpty)
//                 PolylineLayer(
//                   polylines: [
//                     Polyline(
//                       points: _routePoints,
//                       color: Colors.blue,
//                       strokeWidth: 4,
//                     ),
//                   ],
//                 ),
//
//               // رسم خط مباشر (اختياري - يمكن حذفه إذا كان المسار موجود)
//               if (_doctorPosition != null && _routePoints.isEmpty)
//                 PolylineLayer(
//                   polylines: [
//                     Polyline(
//                       points: [
//                         LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude),
//                         LatLng(
//                           widget.request.patientLocation.latitude,
//                           widget.request.patientLocation.longitude,
//                         ),
//                       ],
//                       color: Colors.red.withOpacity(0.5),
//                       strokeWidth: 3,
//                       isDotted: true,
//                     ),
//                   ],
//                 ),
//
//               // العلامات (الطبيب والمريض)
//               MarkerLayer(
//                 markers: [
//                   // علامة الطبيب
//                   if (_doctorPosition != null)
//                     Marker(
//                       point: LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude),
//                       width: 80,
//                       height: 80,
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 3),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.local_hospital,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: const Text(
//                               'أنت',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   // علامة المريض
//                   Marker(
//                     point: LatLng(
//                       widget.request.patientLocation.latitude,
//                       widget.request.patientLocation.longitude,
//                     ),
//                     width: 80,
//                     height: 80,
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 3),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.person_pin_circle,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             widget.patient.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//
//           // معلومات المسافة والوقت
//           if (_distance != null && _duration != null)
//             Positioned(
//               top: 16,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildInfoItem(
//                       Icons.straighten,
//                       '${_distance!.toStringAsFixed(1)} كم',
//                       'المسافة',
//                       Colors.blue,
//                     ),
//                     Container(width: 1, height: 40, color: Colors.grey[300]),
//                     _buildInfoItem(
//                       Icons.access_time,
//                       '${_duration!.toStringAsFixed(0)} دقيقة',
//                       'الوقت المتوقع',
//                       Colors.orange,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // مؤشر التحميل
//           if (_isLoadingRoute)
//             Positioned(
//               bottom: 100,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                       ),
//                     ],
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(width: 16),
//                       Text('جاري حساب المسار...'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//           // رسالة الخطأ
//           if (_errorMessage.isNotEmpty)
//             Positioned(
//               bottom: 100,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.red),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.error, color: Colors.red[600]),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(color: Colors.red[900]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // بطاقة معلومات المريض
//           Positioned(
//             bottom: 16,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: Colors.red[100],
//                         child: Text(
//                           widget.patient.name.substring(0, 1),
//                           style: TextStyle(
//                             color: Colors.red[700],
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.patient.name,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'حالة طوارئ - ${_getUrgencyText(widget.request.urgencyLevel)}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.red[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'الأعراض:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           widget.request.symptoms,
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             // فتح تطبيق الخرائط
//                             // يمكن استخدام url_launcher
//                           },
//                           icon: const Icon(Icons.navigation),
//                           label: const Text('التنقل'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             // الاتصال بالمريض
//                           },
//                           icon: const Icon(Icons.phone),
//                           label: const Text('اتصال'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(IconData icon, String value, String label, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _getUrgencyText(String urgencyLevel) {
//     switch (urgencyLevel) {
//       case 'low':
//         return 'منخفض';
//       case 'medium':
//         return 'متوسط';
//       case 'high':
//         return 'عالي';
//       case 'critical':
//         return 'حرج';
//       default:
//         return 'متوسط';
//     }
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math';
// import '../../../data/models/request_model.dart';
// import '../../../data/models/user_model.dart';
//
// class DoctorEmergencyMapScreen extends StatefulWidget {
//   final RequestModel request;
//   final UserModel patient;
//
//   const DoctorEmergencyMapScreen({
//     super.key,
//     required this.request,
//     required this.patient,
//   });
//
//   @override
//   State<DoctorEmergencyMapScreen> createState() => _DoctorEmergencyMapScreenState();
// }
//
// class _DoctorEmergencyMapScreenState extends State<DoctorEmergencyMapScreen> {
//   final MapController _mapController = MapController();
//   Position? _doctorPosition;
//   List<LatLng> _routePoints = [];
//   bool _isLoadingRoute = false;
//   double? _distance;
//   double? _duration;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeMap();
//   }
//
//   Future<void> _initializeMap() async {
//     await _getDoctorLocation();
//     if (_doctorPosition != null) {
//       await _getRoute();
//     }
//   }
//
//   Future<void> _getDoctorLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         setState(() => _errorMessage = 'خدمات الموقع غير مفعلة');
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() => _errorMessage = 'تم رفض إذن الموقع');
//           return;
//         }
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
//       );
//
//       setState(() {
//         _doctorPosition = position;
//         _errorMessage = '';
//       });
//
//       _fitBounds();
//     } catch (e) {
//       setState(() => _errorMessage = 'خطأ في تحديد الموقع: $e');
//     }
//   }
//
//   Future<void> _getRoute() async {
//     if (_doctorPosition == null) return;
//
//     setState(() => _isLoadingRoute = true);
//
//     try {
//       final doctorLat = _doctorPosition!.latitude;
//       final doctorLng = _doctorPosition!.longitude;
//       final patientLat = widget.request.patientLocation.latitude;
//       final patientLng = widget.request.patientLocation.longitude;
//
//       final url = 'https://router.project-osrm.org/route/v1/driving/'
//           '$doctorLng,$doctorLat;$patientLng,$patientLat'
//           '?overview=full&geometries=geojson';
//
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['routes'] != null && data['routes'].isNotEmpty) {
//           final route = data['routes'][0];
//           final coordinates = route['geometry']['coordinates'] as List;
//
//           setState(() {
//             _routePoints = coordinates
//                 .map((coord) => LatLng(coord[1], coord[0]))
//                 .toList();
//             _distance = route['distance'] / 1000;
//             _duration = route['duration'] / 60;
//             _isLoadingRoute = false;
//           });
//         }
//       } else {
//         setState(() {
//           _isLoadingRoute = false;
//           _errorMessage = 'خطأ في الحصول على المسار';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingRoute = false;
//         _errorMessage = 'خطأ: $e';
//       });
//     }
//   }
//
//   void _fitBounds() {
//     if (_doctorPosition == null) return;
//
//     final doctorLatLng = LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude);
//     final patientLatLng = LatLng(
//       widget.request.patientLocation.latitude,
//       widget.request.patientLocation.longitude,
//     );
//
//     final southWest = LatLng(
//       min(doctorLatLng.latitude, patientLatLng.latitude),
//       min(doctorLatLng.longitude, patientLatLng.longitude),
//     );
//     final northEast = LatLng(
//       max(doctorLatLng.latitude, patientLatLng.latitude),
//       max(doctorLatLng.longitude, patientLatLng.longitude),
//     );
//
//     final bounds = LatLngBounds(southWest, northEast);
//     _mapController.fitCamera(
//       CameraFit.bounds(
//         bounds: bounds,
//         padding: const EdgeInsets.all(50),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('خريطة الطوارئ'),
//         backgroundColor: Colors.red[600],
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.my_location),
//             onPressed: () {
//               _getDoctorLocation();
//               _fitBounds();
//             },
//             tooltip: 'تحديث الموقع',
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _getRoute,
//             tooltip: 'تحديث المسار',
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _doctorPosition != null
//                   ? LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude)
//                   : LatLng(
//                 widget.request.patientLocation.latitude,
//                 widget.request.patientLocation.longitude,
//               ),
//               initialZoom: 13,
//               minZoom: 5,
//               maxZoom: 18,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 maxZoom: 19,
//               ),
//               if (_routePoints.isNotEmpty)
//                 PolylineLayer(
//                   polylines: [
//                     Polyline(
//                       points: _routePoints,
//                       color: Colors.blue,
//                       strokeWidth: 4,
//                     ),
//                   ],
//                 ),
//               if (_doctorPosition != null && _routePoints.isEmpty)
//                 PolylineLayer(
//                   polylines: [
//                     Polyline(
//                       points: [
//                         LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude),
//                         LatLng(
//                           widget.request.patientLocation.latitude,
//                           widget.request.patientLocation.longitude,
//                         ),
//                       ],
//                       color: Colors.red.withOpacity(0.5),
//                       strokeWidth: 3,
//                       // isDotted: true, // Remove this! Not supported
//                     ),
//                   ],
//                 ),
//               MarkerLayer(
//                 markers: [
//                   if (_doctorPosition != null)
//                     Marker(
//                       point: LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude),
//                       width: 80,
//                       height: 80,
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 3),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.local_hospital,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: const Text(
//                               'أنت',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   Marker(
//                     point: LatLng(
//                       widget.request.patientLocation.latitude,
//                       widget.request.patientLocation.longitude,
//                     ),
//                     width: 80,
//                     height: 80,
//                     child: Column(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 3),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.person_pin_circle,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             widget.patient.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           if (_distance != null && _duration != null)
//             Positioned(
//               top: 16,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildInfoItem(
//                       Icons.straighten,
//                       '${_distance!.toStringAsFixed(1)} كم',
//                       'المسافة',
//                       Colors.blue,
//                     ),
//                     Container(width: 1, height: 40, color: Colors.grey[300]),
//                     _buildInfoItem(
//                       Icons.access_time,
//                       '${_duration!.toStringAsFixed(0)} دقيقة',
//                       'الوقت المتوقع',
//                       Colors.orange,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           if (_isLoadingRoute)
//             Positioned(
//               bottom: 100,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                       ),
//                     ],
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(width: 16),
//                       Text('جاري حساب المسار...'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           if (_errorMessage.isNotEmpty)
//             Positioned(
//               bottom: 100,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.red),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.error, color: Colors.red[600]),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(color: Colors.red[900]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           Positioned(
//             bottom: 16,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: Colors.red[100],
//                         child: Text(
//                           widget.patient.name.substring(0, 1),
//                           style: TextStyle(
//                             color: Colors.red[700],
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.patient.name,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'حالة طوارئ - ${_getUrgencyText(widget.request.urgencyLevel)}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.red[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'الأعراض:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           widget.request.symptoms,
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             // فتح تطبيق الخرائط
//                             // يمكن استخدام url_launcher
//                           },
//                           icon: const Icon(Icons.navigation),
//                           label: const Text('التنقل'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             // الاتصال بالمريض
//                           },
//                           icon: const Icon(Icons.phone),
//                           label: const Text('اتصال'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(IconData icon, String value, String label, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _getUrgencyText(String urgencyLevel) {
//     switch (urgencyLevel) {
//       case 'low':
//         return 'منخفض';
//       case 'medium':
//         return 'متوسط';
//       case 'high':
//         return 'عالي';
//       case 'critical':
//         return 'حرج';
//       default:
//         return 'متوسط';
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class DoctorEmergencyMapScreen extends StatefulWidget {
  final double destLat;
  final double destLng;
  final String? patientName;

  const DoctorEmergencyMapScreen({
    super.key,
    required this.destLat,
    required this.destLng,
    this.patientName,
  });

  @override
  State<DoctorEmergencyMapScreen> createState() => _DoctorEmergencyMapScreenState();
}

class _DoctorEmergencyMapScreenState extends State<DoctorEmergencyMapScreen> {
  final MapController _mapController = MapController();
  Position? _doctorPosition;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _destination = LatLng(widget.destLat, widget.destLng);
    _initialize();
  }

  Future<void> _initialize() async {
    await _getDoctorLocation();
    await _getRoute();
  }

  Future<void> _getDoctorLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _errorMessage = 'خدمات الموقع غير مفعلة');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _errorMessage = 'تم رفض إذن الموقع');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _doctorPosition = position;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() => _errorMessage = 'خطأ في تحديد الموقع: $e');
    }
  }

  Future<void> _getRoute() async {
    if (_doctorPosition == null || _destination == null) return;

    setState(() {
      _isLoadingRoute = true;
      _errorMessage = '';
    });

    try {
      final doctorLat = _doctorPosition!.latitude;
      final doctorLng = _doctorPosition!.longitude;
      final destLat = _destination!.latitude;
      final destLng = _destination!.longitude;

      final url = 'https://routing.openstreetmap.de/routed-car/route/v1/driving/'
          '$doctorLng,$doctorLat;$destLng,$destLat'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;

          setState(() {
            _routePoints = coordinates
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList();
            _isLoadingRoute = false;
            _errorMessage = '';
          });
          _fitBounds();
        } else {
          setState(() {
            _isLoadingRoute = false;
            _errorMessage = 'لا يمكن إيجاد طريق بين النقطتين. جرب لاحقًا.';
            _routePoints.clear();
          });
        }
      } else {
        setState(() {
          _isLoadingRoute = false;
          _errorMessage = 'فشل الاتصال بالخدمة. تحقق من الإنترنت أو جرب لاحقًا.';
          _routePoints.clear();
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingRoute = false;
        _errorMessage = 'حدث خطأ أثناء محاولة الحصول على المسار: $e';
        _routePoints.clear();
      });
    }
  }

  void _fitBounds() {
    if (_doctorPosition == null || _destination == null) return;

    final doctorLatLng = LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude);
    final destLatLng = _destination!;

    final southWest = LatLng(
      min(doctorLatLng.latitude, destLatLng.latitude),
      min(doctorLatLng.longitude, destLatLng.longitude),
    );
    final northEast = LatLng(
      max(doctorLatLng.latitude, destLatLng.latitude),
      max(doctorLatLng.longitude, destLatLng.longitude),
    );

    final bounds = LatLngBounds(southWest, northEast);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName == null ? 'خريطة الطوارئ' : 'الوصول إلى ${widget.patientName}'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              await _getDoctorLocation();
              _fitBounds();
            },
            tooltip: 'تحديث الموقع',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getRoute,
            tooltip: 'تحديث المسار',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _destination ?? const LatLng(30, 31),
              initialZoom: 13,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                maxZoom: 19,
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
              MarkerLayer(
                markers: [
                  if (_doctorPosition != null)
                    Marker(
                      point: LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.local_hospital, color: Colors.green, size: 36),
                    ),
                  if (_destination != null)
                    Marker(
                      point: _destination!,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),
          if (_isLoadingRoute)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('جاري حساب المسار...'),
                    ],
                  ),
                ),
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                    TextButton(
                      onPressed: _getRoute,
                      child: const Text('إعادة المحاولة'),
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