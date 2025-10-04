import 'dart:math' as math;

double degreesToRadians(double degrees) => degrees * (math.pi / 180.0);

double haversineDistanceKm({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const double earthRadiusKm = 6371.0;
  final double dLat = degreesToRadians(lat2 - lat1);
  final double dLon = degreesToRadians(lon2 - lon1);
  final double a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(degreesToRadians(lat1)) *
              math.cos(degreesToRadians(lat2)) *
              math.sin(dLon / 2) *
              math.sin(dLon / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}
