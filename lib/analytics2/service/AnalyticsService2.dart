import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalyticsApiService2 {
  final String baseUrl;

  AnalyticsApiService2({
    required this.baseUrl
  });

  Future<Map<String, dynamic>> getAnalyticsData({
    int days = 30,
    String? classFilter,
    String? districtFilter,
  }) async {
    try {
      final queryParams = {
        'days': days.toString(),
        if (classFilter != null) 'class': classFilter,
        if (districtFilter != null) 'district': districtFilter,
      };

      final uri = Uri.parse('$baseUrl/api/analytics_data')
          .replace(queryParameters: queryParams);

      print('Fetching analytics data from: $uri');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. The server might be starting up.');
        },
      );

      if (response.statusCode == 200) {
        // Parse and validate the response
        final jsonData = json.decode(response.body);

        // Ensure class_distribution is properly formatted
        if (jsonData['class_distribution'] != null) {
          final classDistribution = jsonData['class_distribution'];
          // Convert all values to integers to avoid type issues
          final Map<String, int> typedClassDistribution = {};
          classDistribution.forEach((key, value) {
            typedClassDistribution[key.toString()] =
            value is int ? value : int.parse(value.toString());
          });
          jsonData['class_distribution'] = typedClassDistribution;
        }

        return jsonData;
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching analytics data: $e');
      rethrow;
    }
  }

  Future<List<String>> getUgandaDistricts() async {
    try {
      final uri = Uri.parse('$baseUrl/api/uganda_districts');

      print('Fetching districts from: $uri');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. The server might be starting up.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((district) => district.toString()).toList();
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching districts: $e');
      rethrow;
    }
  }
}
