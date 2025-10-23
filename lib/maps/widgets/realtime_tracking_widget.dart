// Real-time tracking widget for enhanced location sharing
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/realtime_location_service.dart';
import '../../data/models/request_model.dart';

class RealtimeTrackingWidget extends ConsumerStatefulWidget {
  final RequestModel request;
  final String userType; // 'doctor' or 'patient'
  final String userId;
  final VoidCallback? onTrackingStarted;
  final VoidCallback? onTrackingStopped;

  const RealtimeTrackingWidget({
    super.key,
    required this.request,
    required this.userType,
    required this.userId,
    this.onTrackingStarted,
    this.onTrackingStopped,
  });

  @override
  ConsumerState<RealtimeTrackingWidget> createState() => _RealtimeTrackingWidgetState();
}

class _RealtimeTrackingWidgetState extends ConsumerState<RealtimeTrackingWidget> {
  GoogleMapController? _mapController;
  final RealtimeLocationService _locationService = RealtimeLocationService();
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  Position? _currentPosition;
  Position? _otherUserPosition;
  bool _isTracking = false;
  String _eta = 'غير محدد';
  double _distance = 0.0;
  
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<Map<String, dynamic>>? _locationUpdateSubscription;
  StreamSubscription<Map<String, dynamic>>? _requestLocationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _locationUpdateSubscription?.cancel();
    _requestLocationSubscription?.cancel();
    super.dispose();
  }

  void _initializeTracking() {
    // Listen to position updates
    _positionSubscription = _locationService.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
      _updateMarkers();
      _updateDistanceAndETA();
    });

    // Listen to location update notifications
    _locationUpdateSubscription = _locationService.locationUpdateStream.listen((update) {
      if (update['type'] == 'location_update') {
        _showLocationUpdateNotification(update);
      }
    });

    // Listen to request location updates
    _requestLocationSubscription = _locationService.getRequestLocationUpdates(widget.request.id)
        .listen((locationData) {
      _updateOtherUserLocation(locationData);
    });
  }

  void _updateMarkers() {
    _markers.clear();

    // Current user marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('${widget.userType}_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: InfoWindow(
            title: widget.userType == 'doctor' ? 'موقع الطبيب' : 'موقع المريض',
            snippet: 'دقة: ${_currentPosition!.accuracy.toStringAsFixed(1)} م',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.userType == 'doctor' ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    // Other user marker
    if (_otherUserPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('${widget.userType == 'doctor' ? 'patient' : 'doctor'}_location'),
          position: LatLng(_otherUserPosition!.latitude, _otherUserPosition!.longitude),
          infoWindow: InfoWindow(
            title: widget.userType == 'doctor' ? 'موقع المريض' : 'موقع الطبيب',
            snippet: 'دقة: ${_otherUserPosition!.accuracy.toStringAsFixed(1)} م',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.userType == 'doctor' ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    // Request destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          widget.request.patientLocation.latitude,
          widget.request.patientLocation.longitude,
        ),
        infoWindow: const InfoWindow(title: 'الوجهة'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  void _updateOtherUserLocation(Map<String, dynamic> locationData) {
    final otherUserType = widget.userType == 'doctor' ? 'patient' : 'doctor';
    final otherLocation = locationData['${otherUserType}Location'];
    
    if (otherLocation != null) {
      setState(() {
        _otherUserPosition = Position(
          latitude: otherLocation['latitude'],
          longitude: otherLocation['longitude'],
          timestamp: DateTime.now(),
          accuracy: otherLocation['accuracy'] ?? 0.0,
          altitude: otherLocation['altitude'] ?? 0.0,
          heading: otherLocation['heading'] ?? 0.0,
          speed: otherLocation['speed'] ?? 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      });
      _updateMarkers();
      _updateDistanceAndETA();
    }
  }

  void _updateDistanceAndETA() {
    if (_currentPosition != null && _otherUserPosition != null) {
      setState(() {
        _distance = _locationService.calculateDistance(_currentPosition!, _otherUserPosition!);
        _eta = _locationService.calculateETA(_currentPosition!, _otherUserPosition!);
      });
    }
  }

  void _showLocationUpdateNotification(Map<String, dynamic> update) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث موقع ${update['userType'] == 'doctor' ? 'الطبيب' : 'المريض'}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _startTracking() async {
    try {
      await _locationService.startLocationSharing(
        requestId: widget.request.id,
        userId: widget.userId,
        userType: widget.userType,
      );
      
      setState(() {
        _isTracking = true;
      });
      
      widget.onTrackingStarted?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم بدء مشاركة الموقع'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في بدء مشاركة الموقع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopTracking() async {
    try {
      await _locationService.stopLocationSharing();
      
      setState(() {
        _isTracking = false;
      });
      
      widget.onTrackingStopped?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف مشاركة الموقع'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إيقاف مشاركة الموقع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _centerMapOnBothLocations() {
    if (_mapController != null && _currentPosition != null && _otherUserPosition != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _currentPosition!.latitude < _otherUserPosition!.latitude 
              ? _currentPosition!.latitude 
              : _otherUserPosition!.latitude,
          _currentPosition!.longitude < _otherUserPosition!.longitude 
              ? _currentPosition!.longitude 
              : _otherUserPosition!.longitude,
        ),
        northeast: LatLng(
          _currentPosition!.latitude > _otherUserPosition!.latitude 
              ? _currentPosition!.latitude 
              : _otherUserPosition!.latitude,
          _currentPosition!.longitude > _otherUserPosition!.longitude 
              ? _currentPosition!.longitude 
              : _otherUserPosition!.longitude,
        ),
      );
      
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.request.patientLocation.latitude,
                widget.request.patientLocation.longitude,
              ),
              zoom: 15.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
            compassEnabled: true,
            mapType: MapType.normal,
            buildingsEnabled: true,
            trafficEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // Top info panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tracking status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isTracking ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isTracking ? 'مشاركة نشطة' : 'غير نشط',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        widget.userType == 'doctor' ? 'وضع الطبيب' : 'وضع المريض',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Distance and ETA
                  if (_distance > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.straighten, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              '${(_distance / 1000).toStringAsFixed(1)} كم',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(height: 4),
                            Text(
                              _eta,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Start/Stop tracking button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTracking ? _stopTracking : _startTracking,
                    icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                    label: Text(_isTracking ? 'إيقاف المشاركة' : 'بدء المشاركة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Center map button
                FloatingActionButton(
                  onPressed: _centerMapOnBothLocations,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.center_focus_strong),
                ),
              ],
            ),
          ),

          // My location button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      15.0,
                    ),
                  );
                }
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
