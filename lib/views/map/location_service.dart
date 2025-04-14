import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }

  // Get camera position for current location
  Future<CameraPosition> getCurrentCameraPosition() async {
    final position = await getCurrentLocation();
    return CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.0,
    );
  }

  // Get nearest district from a list of districts
  String getNearestDistrict(Position position, List<Map<String, dynamic>> districts) {
    if (districts.isEmpty) {
      return '';
    }

    double minDistance = double.infinity;
    String nearestDistrict = districts.first['name'];

    for (var district in districts) {
      final double districtLat = district['latitude'];
      final double districtLng = district['longitude'];
      
      final double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        districtLat,
        districtLng,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestDistrict = district['name'];
      }
    }

    return nearestDistrict;
  }
}
