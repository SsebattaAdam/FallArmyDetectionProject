class District {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int detectionCount;

  District({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.detectionCount = 0,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      detectionCount: json['detection_count'] ?? 0,
    );
  }
}
