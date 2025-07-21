class Detection {
  final int id;
  final String districtName;
  final double latitude;
  final double longitude;
  final String detectionType;
  final double confidence;
  final DateTime detectionDate;
  final String imageUrl;

  Detection({
    required this.id,
    required this.districtName,
    required this.latitude,
    required this.longitude,
    required this.detectionType,
    required this.confidence,
    required this.detectionDate,
    this.imageUrl = '',
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      id: json['id'],
      districtName: json['district_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      detectionType: json['detection_type'],
      confidence: json['confidence'],
      detectionDate: DateTime.parse(json['detection_date']),
      imageUrl: json['image_url'] ?? '',
    );
  }

  String get formattedDetectionType {
    return detectionType
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String get formattedConfidence {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  String get formattedDate {
    return '${detectionDate.day}/${detectionDate.month}/${detectionDate.year}';
  }

  // Get marker color based on detection type
  int get markerColor {
    switch (detectionType) {
      case 'fall-armyworm-egg':
        return 0xFFFF5252; // Red
      case 'fall-armyworm-larval-damage':
        return 0xFFFF9800; // Orange
      case 'fall-armyworm-frass':
        return 0xFFFFEB3B; // Yellow
      case 'healthy-maize':
        return 0xFF4CAF50; // Green
      default:
        return 0xFF2196F3; // Blue
    }
  }
}
