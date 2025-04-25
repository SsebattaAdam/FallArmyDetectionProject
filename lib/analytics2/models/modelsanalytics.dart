class AnalyticsData {
  final int totalDetections;
  final int districtsAffected;
  final double infestationRate;
  final double recentTrend;
  final Map<String, int> classDistribution;
  final Map<String, List<int>> timeSeriesData;
  final List<String> timeSeriesLabels;
  final Map<String, int> districtCounts;
  final Map<String, Map<String, int>> districtClassData;

  AnalyticsData({
    required this.totalDetections,
    required this.districtsAffected,
    required this.infestationRate,
    required this.recentTrend,
    required this.classDistribution,
    required this.timeSeriesData,
    required this.timeSeriesLabels,
    required this.districtCounts,
    required this.districtClassData,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    // Parse time series data
    final timeSeriesJson = json['time_series'];
    final timeSeriesLabels = List<String>.from(timeSeriesJson['labels']);

    final timeSeriesData = <String, List<int>>{};
    timeSeriesJson['data'].forEach((key, value) {
      timeSeriesData[key] = List<int>.from(value);
    });

    // Parse class distribution
    final classDistribution = <String, int>{};
    json['class_distribution'].forEach((key, value) {
      classDistribution[key] = value;
    });

    // Parse district counts
    final districtCounts = <String, int>{};
    json['district_counts'].forEach((key, value) {
      districtCounts[key] = value;
    });

    // Parse district class data
    final districtClassData = <String, Map<String, int>>{};
    json['district_class_data'].forEach((district, classData) {
      districtClassData[district] = {};
      (classData as Map<String, dynamic>).forEach((className, count) {
        districtClassData[district]![className] = count;
      });
    });

    return AnalyticsData(
      totalDetections: json['total_detections'],
      districtsAffected: json['districts_affected'],
      infestationRate: json['infestation_rate'].toDouble(),
      recentTrend: json['recent_trend'].toDouble(),
      classDistribution: classDistribution,
      timeSeriesData: timeSeriesData,
      timeSeriesLabels: timeSeriesLabels,
      districtCounts: districtCounts,
      districtClassData: districtClassData,
    );
  }
}
