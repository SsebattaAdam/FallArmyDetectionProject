import 'package:fammaize/common/app_style.dart';
import 'package:fammaize/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../constants/constants.dart';

class WeatherCard extends StatefulWidget {
  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String _location = "Fetching location...";
  String _temperature = "Loading...";
  String _description = "Loading...";
  String _date = DateFormat('EEEE, MMM d').format(DateTime.now());
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Check location services and permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isError = true;
          _location = "Location services are disabled.";
          _temperature = "Unavailable";
          _description = "Unavailable";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          setState(() {
            _isError = true;
            _location = "Location permissions are denied.";
            _temperature = "Unavailable";
            _description = "Unavailable";
          });
          return;
        }
      }

      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final latitude = position.latitude;
      final longitude = position.longitude;

      // Call the weather API
      const apiKey = '2fc5efd05ee7c7b54ada8fe60598bbb4'; // Replace with your API key
      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = "${data['main']['temp']}°C";
          _description = data['weather'][0]['description'];
          _location = data['name']; // City name
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _temperature = "Failed to fetch data";
          _description = "Unavailable";
          _location = "Unknown";
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _temperature = "Error: $e";
        _description = "Unavailable";
        _location = "Unknown";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.h,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color:  Colors.green[800],
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _date,
                  style: TextStyle(
                    color:  kPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_isError)
              Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color:  Colors.green[800],
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Failed to fetch weather data.",
                    style: TextStyle(
                      color:  kPrimaryLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.thermostat,
                        color:  Colors.green[800],
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _temperature,
                        style: TextStyle(
                          color:  kPrimaryLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.cloud,
                        color:  Colors.green[800],
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _description,
                        style: TextStyle(
                          color:  kPrimaryLight,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color:  Colors.green[800],
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _location,
                        style: TextStyle(
                          color:  kPrimaryLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}