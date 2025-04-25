import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DetectionService {
  // Replace with your Flask API URL
  final String baseUrl = 'http://10.0.2.2:5000'; // Use this for Android emulator
  // Use 'http://localhost:5000' for iOS simulator or web

  // Submit a new detection
  Future<Map<String, dynamic>> submitDetection({
    required File imageFile,
    required String districtName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/detect'));
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      
      // Add other fields
      request.fields['district_name'] = districtName;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit detection: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit detection: $e');
    }
  }
}
