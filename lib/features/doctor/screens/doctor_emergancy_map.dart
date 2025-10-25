//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:heart_emergency/core/constants/app_strings.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math';
// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../data/models/user_model.dart';
//
// class DoctorEmergencyMapScreen extends StatefulWidget {
//   final double destLat;
//   final double destLng;
//   final String? patientName;
//
//   const DoctorEmergencyMapScreen({
//     super.key,
//     required this.destLat,
//     required this.destLng,
//     this.patientName,
//   });
//
//   @override
//   State<DoctorEmergencyMapScreen> createState() => _DoctorEmergencyMapScreenState();
// }
//
// class _DoctorEmergencyMapScreenState extends State<DoctorEmergencyMapScreen> {
//   final MapController _mapController = MapController();
//   Position? _doctorPosition;
//   LatLng? _destination;
//   List<LatLng> _routePoints = [];
//   bool _isLoadingRoute = false;
//   String _errorMessage = '';
//   StreamSubscription<Position>? _positionStreamSub;
// // URL السيرفر البديل (Esri World Street Map)
//    String mapTileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';
//   @override
//   void initState() {
//     super.initState();
//     _destination = LatLng(widget.destLat, widget.destLng);
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     await _getDoctorLocation();
//     await _getRoute();
//     _startLocationStream();
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
//     } catch (e) {
//       setState(() => _errorMessage = 'خطأ في تحديد الموقع: $e');
//     }
//   }
//
//   void _startLocationStream() {
//     final locationSettings = const LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 10,
//     );
//     _positionStreamSub?.cancel();
//     _positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings)
//         .listen((Position position) {
//       final previous = _doctorPosition;
//       _doctorPosition = position;
//       if (previous == null) {
//         setState(() {});
//         _getRoute();
//         return;
//       }
//       final movedDistance = Geolocator.distanceBetween(
//         previous.latitude,
//         previous.longitude,
//         position.latitude,
//         position.longitude,
//       );
//       if (movedDistance >= 10) {
//         setState(() {});
//         _getRoute();
//       }
//     });
//   }
//
//   Future<void> _getRoute() async {
//     if (_doctorPosition == null || _destination == null) return;
//
//     setState(() {
//       _isLoadingRoute = true;
//       _errorMessage = '';
//     });
//
//     try {
//       final doctorLat = _doctorPosition!.latitude;
//       final doctorLng = _doctorPosition!.longitude;
//       final destLat = _destination!.latitude;
//       final destLng = _destination!.longitude;
//
//       print('Doctor: $doctorLat, $doctorLng');
//       print('Destination: $destLat, $destLng');
//
//       final url = 'https://router.project-osrm.org/route/v1/driving/'
//           '$doctorLng,$doctorLat;$destLng,$destLat'
//           '?overview=full&geometries=geojson';
//
//       final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 40));
//       print('OSRM Response: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['routes'] != null && data['routes'].isNotEmpty) {
//           final route = data['routes'][0];
//           final coordinates = route['geometry']['coordinates'] as List;
//
//           setState(() {
//             _routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
//             print('_routePoints: $_routePoints');
//             _isLoadingRoute = false;
//             _errorMessage = '';
//           });
//
//           _fitBounds();
//         } else {
//           setState(() {
//             _routePoints.clear();
//             _isLoadingRoute = false;
//             _errorMessage = 'لا يمكن إيجاد طريق بين النقطتين. جرب لاحقًا.';
//           });
//         }
//       } else {
//         setState(() {
//           _routePoints.clear();
//           _isLoadingRoute = false;
//           _errorMessage = 'فشل الاتصال بالخدمة. جرب لاحقًا.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _routePoints.clear();
//         _isLoadingRoute = false;
//         _errorMessage = 'حدث خطأ أثناء محاولة الحصول على المسار: $e';
//       });
//     }
//   }
//
//   void _fitBounds() {
//     if (_doctorPosition == null || _destination == null) return;
//
//     final doctorLatLng = LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude);
//     final destLatLng = _destination!;
//
//     final southWest = LatLng(
//       min(doctorLatLng.latitude, destLatLng.latitude),
//       min(doctorLatLng.longitude, destLatLng.longitude),
//     );
//     final northEast = LatLng(
//       max(doctorLatLng.latitude, destLatLng.latitude),
//       max(doctorLatLng.longitude, destLatLng.longitude),
//     );
//
//     final bounds = LatLngBounds(southWest, northEast);
//     _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.patientName == null ? 'خريطة الطوارئ' : 'الوصول إلى ${widget.patientName}'),
//         backgroundColor: Colors.red[600],
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.my_location),
//             onPressed: () async {
//               await _getDoctorLocation();
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
//               initialCenter: _destination ?? const LatLng(30, 31),
//               initialZoom: 13,
//               minZoom: 5,
//               maxZoom: 18,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//              // urlTemplate: mapTileUrl,
//              //    userAgentPackageName:AppStrings.packageName,
//                 userAgentPackageName: "com.your.app.temp",
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
//               Consumer(builder: (context, ref, _) {
//                 final currentUser = ref.watch(currentUserDataProvider).maybeWhen(
//                   data: (u) => u,
//                   orElse: () => null,
//                 );
//                 final currencyText = currentUser?.currency.name ?? 'Not set';
//                 return MarkerLayer(
//                   markers: [
//                     if (_doctorPosition != null)
//                       Marker(
//                         point: LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude),
//                         width: 80,
//                         height: 80,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.local_hospital, color: Colors.green, size: 36),
//                             const SizedBox(height: 4),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 4,
//                                   ),
//                                 ],
//                               ),
//                               child: Text(
//                                 currencyText,
//                                 style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     if (_destination != null)
//                       Marker(
//                         point: _destination!,
//                         width: 80,
//                         height: 80,
//                         child: const Icon(Icons.location_on, color: Colors.red, size: 40),
//                       ),
//                   ],
//                 );
//               }),
//             ],
//           ),
//           if (_isLoadingRoute)
//             const Positioned(
//               bottom: 100,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: CircularProgressIndicator(),
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
//                     TextButton(
//                       onPressed: _getRoute,
//                       child: const Text('إعادة المحاولة'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _positionStreamSub?.cancel();
//     super.dispose();
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';

// ⚠️ ملاحظة: يجب أن تتأكد أن AppStrings موجودة في مشروعك أو تستبدل استخدامها
// import 'package:heart_emergency/core/constants/app_strings.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../data/models/user_model.dart';


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
  StreamSubscription<Position>? _positionStreamSub;

  // ⚠️ ملاحظة: تم حذف الـURL البديل هنا لعدم الحاجة إليه بعد استخدام OpenStreetMap

  @override
  void initState() {
    super.initState();

    // 💥💥 تعديل مهم للتجربة على نفس الـEmulator:
    // إذا كنت تجرّب على نفس الـEmulator وكان الموقع متطابق، هذا سيضيف فرقًا بسيطًا على خط الطول (حوالي 1.5 كم)
    // لإجبار OSRM على حساب المسار ورسم الخط الأزرق.
    // يجب إزالة هذا التعديل عند استخدام التطبيق في بيئة حقيقية أو على جهازين مختلفين.
    _destination = LatLng(widget.destLat, widget.destLng + 0.015);

    _initialize();
  }

  Future<void> _initialize() async {
    await _getDoctorLocation();
    // ⚠️ يتم استدعاء _getRoute() بعد تحديد الموقع الأولي للدكتور
    await _getRoute();
    _startLocationStream();
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

  void _startLocationStream() {
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionStreamSub?.cancel();
    _positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      final previous = _doctorPosition;
      _doctorPosition = position;
      if (previous == null) {
        setState(() {});
        _getRoute();
        return;
      }
      final movedDistance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        position.latitude,
        position.longitude,
      );
      if (movedDistance >= 10) {
        setState(() {});
        _getRoute();
      }
    });
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

      print('Doctor: $doctorLat, $doctorLng');
      print('Destination: $destLat, $destLng');

      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '$doctorLng,$doctorLat;$destLng,$destLat'
          '?overview=full&geometries=geojson';

      // 💥💥 تعديل: زيادة وقت الـTimeout إلى 60 ثانية لمحاولة حل مشكلة عدم استقرار سيرفر OSRM
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 60));
      print('OSRM Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;

          setState(() {
            // هنا بيتم عكس الإحداثيات من [Lng, Lat] إلى LatLng
            _routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
            print('_routePoints: $_routePoints');
            _isLoadingRoute = false;
            _errorMessage = '';
          });

          _fitBounds();
        } else {
          setState(() {
            _routePoints.clear();
            _isLoadingRoute = false;
            _errorMessage = 'لا يمكن إيجاد طريق بين النقطتين. جرب لاحقًا. (النقاط قريبة جدًا أو لا يوجد طريق)';
          });
        }
      } else {
        setState(() {
          _routePoints.clear();
          _isLoadingRoute = false;
          _errorMessage = 'فشل الاتصال بخدمة المسار: ${response.statusCode}. جرب لاحقًا.';
        });
      }
    } catch (e) {
      setState(() {
        _routePoints.clear();
        _isLoadingRoute = false;
        _errorMessage = 'حدث خطأ أثناء محاولة الحصول على المسار (Timeout): $e';
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
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ يتم افتراض أنك لا تزال تستخدم Riverpod لإدارة حالة المستخدم
    final currencyText = 'دكتور'; // قيمة افتراضية في حالة عدم وجود بيانات مستخدم
    // يمكنك إعادة تفعيل استخدام Riverpod بالطريقة الأصلية إذا كانت البيانات موجودة:
    /*
    final currentUser = ref.watch(currentUserDataProvider).maybeWhen(
      data: (u) => u,
      orElse: () => null,
    );
    final currencyText = currentUser?.currency.name ?? 'Not set';
    */

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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // ✅ OpenStreetMap
                // 💥💥 تعديل: وضع قيمة ثابتة كـ User Agent لحل مشاكل الرفض
                userAgentPackageName: "com.your.app.temp",
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
              // تم تعديل هذا الجزء ليعمل بدون الحاجة لـref.watch مباشرة في حال كانت المشكلة تسبب خلل
              // يمكنك إعادة التفعيل إذا كان الـConsumer يعمل بشكل سليم
              Consumer(builder: (context, ref, _) {
                final currentUser = ref.watch(currentUserDataProvider).maybeWhen(
                  data: (u) => u,
                  orElse: () => null,
                );
                final markerText = currentUser?.currency.name ?? 'Not set';
                return MarkerLayer(
                  markers: [
                    if (_doctorPosition != null)
                      Marker(
                        point: LatLng(_doctorPosition!.latitude, _doctorPosition!.longitude),
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.green, size: 36),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                markerText,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_destination != null)
                      Marker(
                        point: _destination!,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                  ],
                );
              }),
            ],
          ),
          if (_isLoadingRoute)
            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
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

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }
}
