import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/detectionmapmodel.dart';

class MapDataProvider with ChangeNotifier {
  List<Detection> _detections = [];
  bool _isLoading = false;
  String? _error;

  // Filter state
  int _days = 30;
  String? _selectedClass;
  String? _selectedDistrict;
  List<String> _districts = [];

  // Getters
  List<Detection> get detections => _detections;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get days => _days;
  String? get selectedClass => _selectedClass;
  String? get selectedDistrict => _selectedDistrict;
  List<String> get districts => _districts;

  // Initialize the provider
  Future<void> initialize() async {
    await fetchDetections();
    await fetchDistricts();
  }

  // Fetch detections from the API
  Future<void> fetchDetections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Build query parameters based on current filters
      final queryParams = <String, String>{};
      if (_days != 30) {
        queryParams['days'] = _days.toString();
      }
      if (_selectedClass != null && _selectedClass!.isNotEmpty) {
        queryParams['class'] = _selectedClass!;
      }
      if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
        queryParams['district'] = _selectedDistrict!;
      }

      final uri = Uri.parse('https://fastapitest-1qsv.onrender.com/map_data')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Parse detections and filter out unknown class
        _detections = data
            .map((item) => Detection.fromJson(item))
            .where((detection) => detection.detectionClass != 'unknown')
            .toList();
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch available districts
  Future<void> fetchDistricts() async {
    try {
      final response = await http.get(Uri.parse('https://fastapitest-1qsv.onrender.com/uganda_districts'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _districts = List<String>.from(data);
      }
    } catch (e) {
      // Just log the error, don't set _error as that would affect the UI
      print('Error fetching districts: $e');
    }
    notifyListeners();
  }

  // Update filters and fetch new data
  void updateFilters({int? days, String? detectionClass, String? district}) {
    bool changed = false;

    if (days != null && _days != days) {
      _days = days;
      changed = true;
    }

    if (detectionClass != _selectedClass) {
      _selectedClass = detectionClass;
      changed = true;
    }

    if (district != _selectedDistrict) {
      _selectedDistrict = district;
      changed = true;
    }

    if (changed) {
      fetchDetections();
    }
  }

  // Clear all filters
  void clearFilters() {
    _days = 30;
    _selectedClass = null;
    _selectedDistrict = null;
    fetchDetections();
  }
}
