// Real-time location sharing service for enhanced tracking
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealtimeLocationService {
  static final RealtimeLocationService _instance = RealtimeLocationService._internal();
  factory RealtimeLocationService() => _instance;
  RealtimeLocationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<Position>? _locationStream;
  Timer? _locationUpdateTimer;
  Timer? _batteryOptimizationTimer;
  
  bool _isSharing = false;
  String? _currentRequestId;
  Position? _currentPosition;
  DateTime? _lastUpdateTime;
  
  // Stream controllers for real-time updates
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  final StreamController<Map<String, dynamic>> _locationUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<Position> get positionStream => _positionController.stream;
  Stream<Map<String, dynamic>> get locationUpdateStream => _locationUpdateController.stream;

  /// Start real-time location sharing for a request
  Future<void> startLocationSharing({
    required String requestId,
    required String userId,
    required String userType, // 'doctor' or 'patient'
  }) async {
    if (_isSharing) {
      await stopLocationSharing();
    }

    _currentRequestId = requestId;
    _isSharing = true;

    try {
      // Request location permissions
      await _requestLocationPermissions();
      
      // Start location tracking
      await _startLocationTracking();
      
      // Start periodic updates to Firestore
      _startPeriodicUpdates(userId, userType);
      
      // Start battery optimization monitoring
      _startBatteryOptimizationMonitoring();
      
      if (kDebugMode) {
        print('📍 Real-time location sharing started for $userType: $userId');
      }
    } catch (e) {
      _isSharing = false;
      _currentRequestId = null;
      if (kDebugMode) {
        print('❌ Error starting location sharing: $e');
      }
      rethrow;
    }
  }

  /// Stop real-time location sharing
  Future<void> stopLocationSharing() async {
    _isSharing = false;
    _currentRequestId = null;
    
    await _locationStream?.cancel();
    _locationUpdateTimer?.cancel();
    _batteryOptimizationTimer?.cancel();
    
    if (kDebugMode) {
      print('🛑 Real-time location sharing stopped');
    }
  }

  /// Request location permissions
  Future<void> _requestLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمات الموقع غير مفعلة');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض إذن الموقع');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('تم رفض إذن الموقع نهائياً');
    }
  }

  /// Start location tracking
  Future<void> _startLocationTracking() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
      timeLimit: Duration(seconds: 10), // Timeout after 10 seconds
    );

    _locationStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(
          (Position position) {
            _currentPosition = position;
            _lastUpdateTime = DateTime.now();
            _positionController.add(position);
          },
          onError: (error) {
            if (kDebugMode) {
              print('❌ Location stream error: $error');
            }
          },
        );
  }

  /// Start periodic updates to Firestore
  void _startPeriodicUpdates(String userId, String userType) {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPosition != null && _currentRequestId != null) {
        _updateLocationInFirestore(userId, userType);
      }
    });
  }

  /// Update location in Firestore
  Future<void> _updateLocationInFirestore(String userId, String userType) async {
    if (_currentPosition == null || _currentRequestId == null) return;

    try {
      final locationData = {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'accuracy': _currentPosition!.accuracy,
        'altitude': _currentPosition!.altitude,
        'speed': _currentPosition!.speed,
        'heading': _currentPosition!.heading,
        'timestamp': FieldValue.serverTimestamp(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };

      // Update user's current location
      await _firestore.collection('users').doc(userId).update({
        'currentLocation': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'isOnline': true,
      });

      // Update request with location data
      await _firestore.collection('requests').doc(_currentRequestId).update({
        '${userType}Location': locationData,
        '${userType}LastUpdate': FieldValue.serverTimestamp(),
      });

      // Create location history entry
      await _firestore.collection('location_history').add({
        'requestId': _currentRequestId,
        'userId': userId,
        'userType': userType,
        'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'accuracy': _currentPosition!.accuracy,
        'speed': _currentPosition!.speed,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _locationUpdateController.add({
        'type': 'location_update',
        'userId': userId,
        'userType': userType,
        'position': _currentPosition,
        'timestamp': DateTime.now(),
      });

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating location in Firestore: $e');
      }
    }
  }

  /// Start battery optimization monitoring
  void _startBatteryOptimizationMonitoring() {
    _batteryOptimizationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkBatteryOptimization();
    });
  }

  /// Check and handle battery optimization
  void _checkBatteryOptimization() {
    if (_currentPosition == null) return;

    final now = DateTime.now();
    final timeSinceLastUpdate = _lastUpdateTime != null 
        ? now.difference(_lastUpdateTime!) 
        : const Duration(minutes: 10);

    // If no location update in the last 2 minutes, try to get a fresh location
    if (timeSinceLastUpdate > const Duration(minutes: 2)) {
      _getCurrentLocationOnce();
    }
  }

  /// Get current location once (for battery optimization)
  Future<void> _getCurrentLocationOnce() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      
      _currentPosition = position;
      _lastUpdateTime = DateTime.now();
      _positionController.add(position);
      
      if (kDebugMode) {
        print('📍 Fresh location obtained: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting fresh location: $e');
      }
    }
  }

  /// Get real-time location updates for a request
  Stream<Map<String, dynamic>> getRequestLocationUpdates(String requestId) {
    return _firestore
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return {};
      
      final data = snapshot.data()!;
      return {
        'doctorLocation': data['doctorLocation'],
        'patientLocation': data['patientLocation'],
        'doctorLastUpdate': data['doctorLastUpdate'],
        'patientLastUpdate': data['patientLastUpdate'],
        'timestamp': DateTime.now(),
      };
    });
  }

  /// Get location history for a request
  Future<List<Map<String, dynamic>>> getLocationHistory(String requestId) async {
    try {
      final querySnapshot = await _firestore
          .collection('location_history')
          .where('requestId', isEqualTo: requestId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'],
          'userType': data['userType'],
          'location': data['location'],
          'accuracy': data['accuracy'],
          'speed': data['speed'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting location history: $e');
      }
      return [];
    }
  }

  /// Calculate distance between two positions
  double calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  /// Calculate ETA based on current positions
  String calculateETA(Position currentPos, Position destinationPos) {
    final distance = calculateDistance(currentPos, destinationPos);
    final distanceKm = distance / 1000;
    
    // Assume average speed of 50 km/h in city
    final etaMinutes = (distanceKm / 50 * 60).round();
    
    if (etaMinutes < 60) {
      return '${etaMinutes} دقيقة';
    } else {
      final hours = (etaMinutes / 60).floor();
      final minutes = etaMinutes % 60;
      return minutes > 0 ? '${hours}س ${minutes}د' : '${hours} ساعة';
    }
  }

  /// Get current sharing status
  Map<String, dynamic> getSharingStatus() {
    return {
      'isSharing': _isSharing,
      'requestId': _currentRequestId,
      'currentPosition': _currentPosition,
      'lastUpdateTime': _lastUpdateTime,
      'isOnline': _isSharing && _lastUpdateTime != null 
          && DateTime.now().difference(_lastUpdateTime!) < const Duration(minutes: 2),
    };
  }

  /// Dispose resources
  void dispose() {
    stopLocationSharing();
    _positionController.close();
    _locationUpdateController.close();
  }
}
