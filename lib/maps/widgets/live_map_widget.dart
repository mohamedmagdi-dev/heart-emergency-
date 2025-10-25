// Live map widget with DiDi-like functionality
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/live_tracking_service.dart';
import '../../data/models/request_model.dart';

class LiveMapWidget extends ConsumerStatefulWidget {
  final RequestModel request;
  final bool isDoctorView;
  final VoidCallback? onTrackingStarted;
  final VoidCallback? onTrackingStopped;

  const LiveMapWidget({
    super.key,
    required this.request,
    this.isDoctorView = false,
    this.onTrackingStarted,
    this.onTrackingStopped,
  });

  @override
  ConsumerState<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends ConsumerState<LiveMapWidget> {
  GoogleMapController? _mapController;
  final LiveTrackingService _trackingService = LiveTrackingService();
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  Position? _currentPosition;
  List<LatLng> _currentRoute = [];
  double _currentPrice = 0.0;
  String _trackingStatus = 'stopped';
  String _eta = 'غير محدد';
  
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<LatLng>>? _routeSubscription;
  StreamSubscription<double>? _priceSubscription;
  StreamSubscription<String>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _setupTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _routeSubscription?.cancel();
    _priceSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  void _initializeMap() {
    // Set initial markers
    _updateMarkers();
  }

  void _setupTracking() {
    // Listen to position updates
    _positionSubscription = _trackingService.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
        _eta = _trackingService.getEstimatedArrival(
          LatLng(
            widget.request.patientLocation.latitude,
            widget.request.patientLocation.longitude,
          ),
        );
      });
      _updateMarkers();
    });

    // Listen to route updates
    _routeSubscription = _trackingService.routeStream.listen((route) {
      setState(() {
        _currentRoute = route;
      });
      _updatePolylines();
    });

    // Listen to price updates
    _priceSubscription = _trackingService.priceStream.listen((price) {
      setState(() {
        _currentPrice = price;
      });
    });

    // Listen to status updates
    _statusSubscription = _trackingService.statusStream.listen((status) {
      setState(() {
        _trackingStatus = status;
      });
    });
  }

  void _updateMarkers() {
    _markers.clear();

    // Patient location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('patient_location'),
        position: LatLng(
          widget.request.patientLocation.latitude,
          widget.request.patientLocation.longitude,
        ),
        infoWindow: const InfoWindow(title: 'موقع المريض'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Doctor location marker (if tracking)
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('doctor_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'موقع الطبيب'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  void _updatePolylines() {
    _polylines.clear();

    if (_currentRoute.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _currentRoute,
          color: Colors.blue,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }
  }

  Future<void> _startTracking() async {
    try {
      await _trackingService.startTracking(
        requestId: widget.request.id,
        destination: LatLng(
          widget.request.patientLocation.latitude,
          widget.request.patientLocation.longitude,
        ),
        doctorId: widget.request.doctorId,
      );
      
      widget.onTrackingStarted?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم بدء التتبع المباشر'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في بدء التتبع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopTracking() async {
    try {
      await _trackingService.stopTracking();
      
      widget.onTrackingStopped?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف التتبع المباشر'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إيقاف التتبع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _centerMapOnRoute() {
    if (_mapController != null && _currentRoute.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList(_currentRoute),
          100.0,
        ),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
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
                  // Status and price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _trackingStatus == 'tracking_started' ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _trackingStatus == 'tracking_started' ? 'متصل' : 'غير متصل',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Price
                      Text(
                        '${_currentPrice.toStringAsFixed(2)} ريال',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ETA and distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'الوقت المتوقع: $_eta',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      
                      if (_currentPosition != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
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
                    onPressed: _trackingStatus == 'tracking_started' ? _stopTracking : _startTracking,
                    icon: Icon(_trackingStatus == 'tracking_started' ? Icons.stop : Icons.play_arrow),
                    label: Text(_trackingStatus == 'tracking_started' ? 'إيقاف التتبع' : 'بدء التتبع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _trackingStatus == 'tracking_started' ? Colors.red : Colors.green,
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
                  onPressed: _centerMapOnRoute,
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
