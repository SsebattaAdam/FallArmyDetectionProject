import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detection_model.dart';
import 'district_model.dart';

class MapService {
  // Replace with your Flask API URL
  final String baseUrl = 'http://10.0.2.2:5000'; // Use this for Android emulator
  // Use 'http://localhost:5000' for iOS simulator or web

  // Fetch all districts
  Future<List<District>> fetchDistricts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/districts'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => District.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load districts: $e');
    }
  }

  // Fetch all detections
  Future<List<Detection>> fetchDetections() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/detections'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Detection.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load detections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load detections: $e');
    }
  }

  // Fetch detections by district
  Future<List<Detection>> fetchDetectionsByDistrict(String districtName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/detections/district/$districtName'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Detection.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load detections for district: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load detections for district: $e');
    }
  }

  // Fetch detection counts by district
  Future<Map<String, int>> fetchDetectionCounts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/detections/counts'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception('Failed to load detection counts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load detection counts: $e');
    }
  }
}
