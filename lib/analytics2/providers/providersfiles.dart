import 'package:flutter/foundation.dart';
import '../service/AnalyticsService2.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsApiService2 analyticsService;

  Map<String, dynamic>? _analyticsData;
  List<String> _districts = [];
  bool _isLoading = false;
  String? _error;

  // Filter state
  int _selectedDays = 30;
  String? _selectedClass;
  String? _selectedDistrict;

  AnalyticsProvider({required this.analyticsService});

  // Getters
  Map<String, dynamic>? get analyticsData => _analyticsData;
  List<String> get districts => _districts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get selectedDays => _selectedDays;
  String? get selectedClass => _selectedClass;
  String? get selectedDistrict => _selectedDistrict;

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([
      fetchAnalyticsData(),
      fetchDistricts(),
    ]);
  }

  // Fetch analytics data
  Future<void> fetchAnalyticsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await analyticsService.getAnalyticsData(
        days: _selectedDays,
        classFilter: _selectedClass,
        districtFilter: _selectedDistrict,
      );

      // Process and normalize data to ensure consistent types
      _processAnalyticsData(data);

      _analyticsData = data;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error in provider: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process and normalize analytics data
  void _processAnalyticsData(Map<String, dynamic> data) {
    // Ensure class_distribution values are integers
    if (data['class_distribution'] != null) {
      final Map<String, dynamic> rawDistribution = data['class_distribution'];
      final Map<String, int> processedDistribution = {};

      rawDistribution.forEach((key, value) {
        processedDistribution[key] = value is int ? value : int.parse(value.toString());
      });

      data['class_distribution'] = processedDistribution;
    }

    // Process other numeric fields as needed
    if (data['total_detections'] != null) {
      data['total_detections'] = data['total_detections'] is int
          ? data['total_detections']
          : int.parse(data['total_detections'].toString());
    }

    if (data['districts_affected'] != null) {
      data['districts_affected'] = data['districts_affected'] is int
          ? data['districts_affected']
          : int.parse(data['districts_affected'].toString());
    }

    // Process time series data
    if (data['time_series'] != null && data['time_series']['data'] != null) {
      final Map<String, dynamic> timeSeriesData = data['time_series']['data'];

      timeSeriesData.forEach((className, values) {
        if (values is List) {
          final List<int> processedValues = [];
          for (var value in values) {
            processedValues.add(value is int ? value : int.parse(value.toString()));
          }
          timeSeriesData[className] = processedValues;
        }
      });
    }
  }

  // Fetch districts
  Future<void> fetchDistricts() async {
    try {
      _districts = await analyticsService.getUgandaDistricts();
    } catch (e) {
      print('Error fetching districts: $e');
      // Don't set error here to avoid blocking the UI if only districts fail
    }
    notifyListeners();
  }

  // Update filters
  void updateFilters({
    int? days,
    String? classFilter,
    String? districtFilter,
  }) {
    bool changed = false;

    if (days != null && days != _selectedDays) {
      _selectedDays = days;
      changed = true;
    }

    if (classFilter != _selectedClass) {
      _selectedClass = classFilter;
      changed = true;
    }

    if (districtFilter != _selectedDistrict) {
      _selectedDistrict = districtFilter;
      changed = true;
    }

    if (changed) {
      fetchAnalyticsData();
    }
  }
}
