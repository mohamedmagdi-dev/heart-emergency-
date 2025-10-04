// FIXED: Unit tests for distance calculation using Haversine formula
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('Distance Calculation Tests', () {
    test('should calculate correct distance between two points', () {
      // Cairo to Alexandria (approximately 220 km)
      const lat1 = 30.0444; // Cairo
      const lon1 = 31.2357;
      const lat2 = 31.2001; // Alexandria  
      const lon2 = 29.9187;
      
      final distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
      
      // Should be approximately 180 km (with some tolerance)
      expect(distance, greaterThan(170));
      expect(distance, lessThan(190));
    });

    test('should return zero distance for same coordinates', () {
      const lat = 30.0444;
      const lon = 31.2357;
      
      final distance = Geolocator.distanceBetween(lat, lon, lat, lon) / 1000;
      
      expect(distance, equals(0.0));
    });

    test('should calculate distance for nearby points correctly', () {
      // Two points very close to each other (about 1 km apart)
      const lat1 = 30.0444;
      const lon1 = 31.2357;
      const lat2 = 30.0534; // About 1 km north
      const lon2 = 31.2357;
      
      final distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
      
      // Should be approximately 1 km
      expect(distance, greaterThan(0.8));
      expect(distance, lessThan(1.2));
    });

    test('should handle negative coordinates correctly', () {
      // Test with negative coordinates (Southern hemisphere)
      const lat1 = -33.8688; // Sydney
      const lon1 = 151.2093;
      const lat2 = -37.8136; // Melbourne
      const lon2 = 144.9631;
      
      final distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
      
      // Sydney to Melbourne is approximately 714 km
      expect(distance, greaterThan(700));
      expect(distance, lessThan(730));
    });
  });
}
