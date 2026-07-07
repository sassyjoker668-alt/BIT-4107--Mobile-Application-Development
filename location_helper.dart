import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<bool> requestPermission() async {
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String> getLocationString() async {
    final position = await getCurrentLocation();
    if (position == null) return 'Location unavailable';
    return 'Lat: ${position.latitude.toStringAsFixed(4)}, '
        'Lng: ${position.longitude.toStringAsFixed(4)}';
  }
}