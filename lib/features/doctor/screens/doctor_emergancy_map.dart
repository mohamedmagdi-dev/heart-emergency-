

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



