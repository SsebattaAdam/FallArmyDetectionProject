import 'package:fammaize/common/app_style.dart';
import 'package:fammaize/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SprayingConditionsCard extends StatefulWidget {
  @override
  _SprayingConditionsCardState createState() => _SprayingConditionsCardState();
}

class _SprayingConditionsCardState extends State<SprayingConditionsCard> {
  String _location = "Fetching location...";
  String _sprayingCondition = "Loading...";
  String _time = DateFormat('h:mm a').format(DateTime.now());
  String _date = DateFormat('EEEE, MMM d').format(DateTime.now());
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndSprayingConditions();
  }

  Future<void> _fetchWeatherAndSprayingConditions() async {
    try {
      // Check location services and permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isError = true;
          _location = "Location services are disabled.";
          _sprayingCondition = "Cannot determine spraying conditions.";
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
            _sprayingCondition = " spraying conditions failed";
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
        final temperature = data['main']['temp'];
        final humidity = data['main']['humidity'];
        final windSpeed = data['wind']['speed'];
        final location = data['name'];

        // Determine spraying conditions
        String condition;
        if (temperature > 10 && temperature < 30 && humidity > 50 && windSpeed < 15) {
          condition = "Suitable for spraying.";
        } else {
          condition = "Not suitable for spraying.";
        }

        setState(() {
          _location = location;
          _sprayingCondition = condition;
          _time = DateFormat('h:mm a').format(DateTime.now());
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _sprayingCondition = "Failed to fetch data";
          _location = "Unknown";
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _sprayingCondition = "Error: $e";
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
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Failed to fetch spraying conditions.",
                    style: TextStyle(
                      color:  kPrimaryLight,
                      fontSize: 12,
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
                        Icons.access_time,
                        color:  Colors.green[800],
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Time: $_time",
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
                        "Location: $_location",
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
                        Icons.water_drop,
                        color:  Colors.green[800],
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Spraying Condition: $_sprayingCondition",
                        style: TextStyle(
                          color:  kPrimaryLight,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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