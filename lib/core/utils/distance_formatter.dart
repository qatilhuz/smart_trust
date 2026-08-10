class DistanceFormatter {
  DistanceFormatter._();

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(1)} km';
  }
}
