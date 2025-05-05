import 'package:google_maps_flutter/google_maps_flutter.dart';

class Detection {
  final int id;
  final String result;
  final double confidence;
  final String detectionClass;
  final String district;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String imagePath;

  Detection({
    required this.id,
    required this.result,
    required this.confidence,
    required this.detectionClass,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.imagePath,
  });

  LatLng get position => LatLng(latitude, longitude);

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      id: json['id'] ?? 0,
      result: json['result'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0),
      detectionClass: json['class'] ?? 'unknown',
      district: json['district'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      timestamp: json['timestamp'] ?? '',
      imagePath: json['image_path'] ?? '',
    );
  }
}
