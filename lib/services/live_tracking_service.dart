// Live tracking service for DiDi-like real-time map functionality
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTrackingService {
  static final LiveTrackingService _instance = LiveTrackingService._internal();
  factory LiveTrackingService() => _instance;
  LiveTrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<Position>? _positionStream;
  Timer? _pricingUpdateTimer;
  Timer? _routeUpdateTimer;
  
  bool _isTracking = false;
  String? _currentRequestId;
  Position? _currentPosition;
  List<LatLng> _currentRoute = [];
  double _currentPrice = 0.0;
  double _basePrice = 50.0; // Base price in local currency
  double _pricePerKm = 2.0; // Price per kilometer
  double _pricePerMinute = 1.0; // Price per minute
  
  // Stream controllers for real-time updates
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  final StreamController<List<LatLng>> _routeController = StreamController<List<LatLng>>.broadcast();
  final StreamController<double> _priceController = StreamController<double>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<Position> get positionStream => _positionController.stream;
  Stream<List<LatLng>> get routeStream => _routeController.stream;
  Stream<double> get priceStream => _priceController.stream;
  Stream<String> get statusStream => _statusController.stream;

  /// Start live tracking for a request
  Future<void> startTracking({
    required String requestId,
    required LatLng destination,
    String? doctorId,
  }) async {
    if (_isTracking) {
      await stopTracking();
    }

    _currentRequestId = requestId;
    _isTracking = true;

    try {
      // Start location tracking
      await _startLocationTracking();
      
      // Start pricing updates
      _startPricingUpdates();
      
      // Start route updates
      _startRouteUpdates(destination);
      
      // Update status
      _statusController.add('tracking_started');
      
      if (kDebugMode) {
        print('🚗 Live tracking started for request: $requestId');
      }
    } catch (e) {
      _statusController.add('tracking_error');
      if (kDebugMode) {
        print('❌ Error starting live tracking: $e');
      }
      rethrow;
    }
  }

  /// Stop live tracking
  Future<void> stopTracking() async {
    _isTracking = false;
    _currentRequestId = null;
    
    await _positionStream?.cancel();
    _pricingUpdateTimer?.cancel();
    _routeUpdateTimer?.cancel();
    
    _positionController.close();
    _routeController.close();
    _priceController.close();
    _statusController.close();
    
    if (kDebugMode) {
      print('🛑 Live tracking stopped');
    }
  }

  /// Start location tracking
  Future<void> _startLocationTracking() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _currentPosition = position;
      _positionController.add(position);
      
      // Update location in Firestore for real-time sharing
      _updateLocationInFirestore(position);
    });
  }

  /// Update location in Firestore
  Future<void> _updateLocationInFirestore(Position position) async {
    if (_currentRequestId == null) return;

    try {
      await _firestore.collection('requests').doc(_currentRequestId).update({
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating location in Firestore: $e');
      }
    }
  }

  /// Start pricing updates
  void _startPricingUpdates() {
    _pricingUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPosition != null && _currentRequestId != null) {
        _updatePricing();
      }
    });
  }

  /// Update pricing based on distance and time
  void _updatePricing() {
    if (_currentPosition == null) return;

    // Calculate dynamic pricing based on:
    // 1. Distance traveled
    // 2. Time elapsed
    // 3. Traffic conditions (simulated)
    // 4. Demand (simulated)
    
    final distance = _calculateDistanceTraveled();
    final timeElapsed = _calculateTimeElapsed();
    final trafficMultiplier = _getTrafficMultiplier();
    final demandMultiplier = _getDemandMultiplier();
    
    final distancePrice = distance * _pricePerKm;
    final timePrice = timeElapsed * _pricePerMinute;
    
    _currentPrice = (_basePrice + distancePrice + timePrice) * trafficMultiplier * demandMultiplier;
    
    _priceController.add(_currentPrice);
    
    // Update price in Firestore
    _updatePriceInFirestore(_currentPrice);
  }

  /// Start route updates
  void _startRouteUpdates(LatLng destination) {
    _routeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentPosition != null) {
        _updateRoute(destination);
      }
    });
  }

  /// Update route based on current position
  Future<void> _updateRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    try {
      // Use OSRM routing service to get updated route
      final route = await _getRouteFromOSRM(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        destination,
      );
      
      if (route.isNotEmpty) {
        _currentRoute = route;
        _routeController.add(route);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating route: $e');
      }
    }
  }

  /// Get route from OSRM service
  Future<List<LatLng>> _getRouteFromOSRM(LatLng start, LatLng end) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;
          
          return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        }
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting route from OSRM: $e');
      }
      return [];
    }
  }

  /// Calculate distance traveled
  double _calculateDistanceTraveled() {
    // This would normally track the total distance traveled
    // For now, we'll simulate based on time elapsed
    final timeElapsed = _calculateTimeElapsed();
    return timeElapsed * 0.5; // Assume average speed of 30 km/h
  }

  /// Calculate time elapsed since tracking started
  double _calculateTimeElapsed() {
    // This would normally track the actual time elapsed
    // For now, we'll simulate based on position updates
    return 5.0; // Simulate 5 minutes elapsed
  }

  /// Get traffic multiplier (simulated)
  double _getTrafficMultiplier() {
    final hour = DateTime.now().hour;
    
    // Higher multiplier during rush hours
    if (hour >= 7 && hour <= 9) return 1.5; // Morning rush
    if (hour >= 17 && hour <= 19) return 1.5; // Evening rush
    if (hour >= 12 && hour <= 14) return 1.2; // Lunch time
    
    return 1.0; // Normal traffic
  }

  /// Get demand multiplier (simulated)
  double _getDemandMultiplier() {
    // Simulate higher demand during certain hours
    final hour = DateTime.now().hour;
    
    if (hour >= 22 || hour <= 6) return 1.3; // Night time premium
    if (hour >= 10 && hour <= 16) return 1.1; // Business hours
    
    return 1.0; // Normal demand
  }

  /// Update price in Firestore
  Future<void> _updatePriceInFirestore(double price) async {
    if (_currentRequestId == null) return;

    try {
      await _firestore.collection('requests').doc(_currentRequestId).update({
        'currentPrice': price,
        'priceUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating price in Firestore: $e');
      }
    }
  }

  /// Get current tracking status
  Map<String, dynamic> getTrackingStatus() {
    return {
      'isTracking': _isTracking,
      'requestId': _currentRequestId,
      'currentPosition': _currentPosition,
      'currentRoute': _currentRoute,
      'currentPrice': _currentPrice,
      'basePrice': _basePrice,
      'pricePerKm': _pricePerKm,
      'pricePerMinute': _pricePerMinute,
    };
  }

  /// Update pricing parameters
  void updatePricingParameters({
    double? basePrice,
    double? pricePerKm,
    double? pricePerMinute,
  }) {
    if (basePrice != null) _basePrice = basePrice;
    if (pricePerKm != null) _pricePerKm = pricePerKm;
    if (pricePerMinute != null) _pricePerMinute = pricePerMinute;
  }

  /// Get estimated arrival time
  String getEstimatedArrival(LatLng destination) {
    if (_currentPosition == null || _currentRoute.isEmpty) return 'غير محدد';
    
    // Calculate ETA based on route and current position
    final remainingDistance = _calculateRemainingDistance(destination);
    final estimatedMinutes = (remainingDistance / 30 * 60).round(); // Assume 30 km/h average
    
    if (estimatedMinutes < 60) {
      return '${estimatedMinutes} دقيقة';
    } else {
      final hours = (estimatedMinutes / 60).floor();
      final minutes = estimatedMinutes % 60;
      return minutes > 0 ? '${hours}س ${minutes}د' : '${hours} ساعة';
    }
  }

  /// Calculate remaining distance to destination
  double _calculateRemainingDistance(LatLng destination) {
    if (_currentPosition == null) return 0.0;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      destination.latitude,
      destination.longitude,
    ) / 1000; // Convert to kilometers
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
    _positionController.close();
    _routeController.close();
    _priceController.close();
    _statusController.close();
  }
}

// Extension for LatLng
extension LatLngExtension on LatLng {
  double distanceTo(LatLng other) {
    return Geolocator.distanceBetween(
      latitude, longitude,
      other.latitude, other.longitude,
    ) / 1000; // Convert to kilometers
  }
}
