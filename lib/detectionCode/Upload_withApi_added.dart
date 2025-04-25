import 'dart:io';
import 'dart:convert';
import 'package:fammaize/constants/constants.dart';
import 'package:fammaize/detectionCode/results.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class UploadCaptureScreenapi extends StatefulWidget {
  const UploadCaptureScreenapi({super.key});

  @override
  State<UploadCaptureScreenapi> createState() => _UploadCaptureScreenapiState();
}

class _UploadCaptureScreenapiState extends State<UploadCaptureScreenapi> {
  late ImagePicker imagePicker;
  File? image;
  String result = "";
  String recommendation = "";
  bool _isProcessing = false;
  bool _showTips = false; // Default to false, will check preferences
  bool _dontShowAgain = false; // Track "don't show again" checkbox

  // Api Url
  final String apiUrl = "https://fastapitest-1qsv.onrender.com/detect";
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;

  // Location variables
  Position? _currentPosition;
  bool _isLocationLoading = false;

  // Shared preferences key
  static const String PREF_SHOW_TIPS = 'show_detection_tips';

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    initializeCamera();
    _checkLocationPermission(); // Check location permission on startup
    _loadTipsPreference(); // Load user preference for tips
  }

  // Load user preference for showing tips
  Future<void> _loadTipsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final showTips = prefs.getBool(PREF_SHOW_TIPS);

    // If preference doesn't exist yet or is true, show tips
    setState(() {
      _showTips = showTips ?? true; // Default to true if not set
    });
  }

  // Save user preference for showing tips
  Future<void> _saveTipsPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PREF_SHOW_TIPS, value);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // Function to check and request location permissions
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      Get.snackbar(
        'Location Services Disabled',
        'Please enable location services to use this app.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        Get.snackbar(
          'Location Permission Denied',
          'Location permission is required for detection.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      Get.snackbar(
        'Location Permission Denied',
        'Location permissions are permanently denied. Please enable them in app settings.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      return;
    }

    // Permissions are granted, get the current position
    await _getCurrentLocation();
  }

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });
      print('Current location: ${position.latitude}, ${position.longitude}');
      // Check if location is within Uganda's boundaries
      bool isInUganda = _isLocationInUganda(position.latitude, position.longitude);
      if (!isInUganda) {
        Get.snackbar(
          'Location Outside Uganda',
          'Your current location appears to be outside Uganda. Detection may not work correctly.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
      });
      print('Error getting location: $e');
      Get.snackbar(
        'Location Error',
        'Could not get your current location. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Check if location is within Uganda's boundaries
  bool _isLocationInUganda(double latitude, double longitude) {
    // Uganda's approximate bounds
    const double UGANDA_LAT_MIN = -1.5;
    const double UGANDA_LAT_MAX = 4.2;
    const double UGANDA_LON_MIN = 29.5;
    const double UGANDA_LON_MAX = 35.0;
    return (latitude >= UGANDA_LAT_MIN && latitude <= UGANDA_LAT_MAX &&
        longitude >= UGANDA_LON_MIN && longitude <= UGANDA_LON_MAX);
  }

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error initializing camera: $e");
      Get.snackbar(
        'Error',
        'Failed to initialize camera. Please restart the app.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detect Fall Armyworm',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Add a refresh location button
          IconButton(
            icon: Icon(Icons.location_searching),
            onPressed: _isLocationLoading ? null : _getCurrentLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Stack(
          children: [
      // Camera or Image Preview
      Positioned.fill(
      child: AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: image == null
          ? _isCameraInitialized
          ? ClipRRect(
        key: ValueKey('camera'),
        borderRadius: BorderRadius.circular(12),
        child: CameraPreview(_cameraController),
      )
          : Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      )
          : ClipRRect(
        key: ValueKey('image'),
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          image!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    ),
    ),

    // Location Status Indicator
    Positioned(
    top: 10,
    right: 10,
    child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
    color: _currentPosition != null
    ? (_isLocationInUganda(_currentPosition!.latitude, _currentPosition!.longitude)
    ? Colors.green.withOpacity(0.8)
        : Colors.orange.withOpacity(0.8))
        : Colors.red.withOpacity(0.8),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    _currentPosition != null ? Icons.location_on : Icons.location_off,
    color: Colors.white,
    size: 16,
    ),
    SizedBox(width: 4),
    Text(
    _isLocationLoading
    ? "Getting location..."
        : (_currentPosition != null
    ? (_isLocationInUganda(_currentPosition!.latitude, _currentPosition!.longitude)
    ? "Location Ready"
        : "Outside Uganda")
        : "No Location"),
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ),

    // Tips Overlay
    if (_showTips && image == null && _isCameraInitialized)
    Positioned.fill(
    child: Container(
    color: Colors.black.withOpacity(0.7),
    child: Center(
    child: Container(
    margin: EdgeInsets.all(20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Text(
    "Tips for Detection",
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.green,
    ),
    ),
    SizedBox(height: 15),
    Text(
    "1. Ensure the image is clear and well-lit.\n"
    "2. Focus on the leaves of the plant.\n"
    "3. Avoid blurry or distant shots.\n"
    "4. Position the leaf in the center of the frame.\n"
    "5. Location services must be enabled for detection.",
    style: TextStyle(
    fontSize: 16,
    height: 1.5,
    ),
    ),
    SizedBox(height: 10),

    // Don't show again checkbox
    Row(
    children: [
    Checkbox(
    value: _dontShowAgain,
    activeColor: Colors.green,
    onChanged: (value) {
    setState(() {
    _dontShowAgain = value ?? false;
    });
    },
    ),
    Text(
    "Don't show again",
    style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    ),
    ),
    ],
    ),

    SizedBox(height: 10),
    ElevatedButton(
    onPressed: () {
    setState(() {
    _showTips = false;
    });

    // If "don't show again" is checked, save the preference
    if (_dontShowAgain) {
    _saveTipsPreference(false);
    }
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
    horizontal: 30,
    vertical: 12,
    ),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
    ),
    ),
    child: Text(
    "Got it!",
    style: TextStyle(fontSize: 16),
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ),

    // Processing Indicator
    if (_isProcessing)
    Positioned.fill(
    child: Container(
    color: Colors.black.withOpacity(0.7),
    child: Center(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    CircularProgressIndicator(color: Colors.green),
    SizedBox(height: 20),
    Text(
    "Analyzing image...",
    style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ),
    ),

    // Fixed Buttons at Bottom
    Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    decoration: BoxDecoration(
    color: Colors.green,
    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
    ),
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    ActionButton(
    icon: Icons.photo_library,
    label: "Gallery",
    onPressed: (_isProcessing || _showTips || _currentPosition == null)
    ? null
        : () => chooseImage(),
    ),
    ActionButton(
    icon: Icons.camera_alt,
    label: "Capture",
    onPressed: (_isProcessing || _showTips || _currentPosition == null)
    ? null
        : () => captureImage(),
    ),
    ActionButton(
    icon: Icons.info_outline,
    label: "Tips",
      onPressed: _isProcessing ? null : () {
        setState(() {
          _showTips = true;
          _dontShowAgain = false; // Reset checkbox when manually showing tips
        });
      },
    ),
    ],
    ),
    ),
    ),
          ],
      ),
    );
  }

  Future<void> chooseImage() async {
    if (_currentPosition == null) {
      Get.snackbar(
        'Location Required',
        'Please enable location services to continue.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        image = File(selectedImage.path);
      });
      await detectFallArmyworm();
    }
  }

  Future<void> captureImage() async {
    if (!_isCameraInitialized) return;
    if (_currentPosition == null) {
      Get.snackbar(
        'Location Required',
        'Please enable location services to continue.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      setState(() {
        _isProcessing = true;
      });
      final XFile picture = await _cameraController.takePicture();
      setState(() {
        image = File(picture.path);
      });
      await detectFallArmyworm();
    } catch (e) {
      print("Error capturing image: $e");
      setState(() {
        _isProcessing = false;
      });
      Get.snackbar(
        'Error',
        'Failed to capture image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> detectFallArmyworm() async {
    if (image == null) return;
    if (_currentPosition == null) {
      Get.snackbar(
        'Location Required',
        'Please enable location services to continue.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() {
      result = "";
      recommendation = "";
      _isProcessing = true;
    });
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath('file', image!.path),
      );
      // Add location data to request
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();
      // Add district (optional - you can leave it empty or implement district detection)
      request.fields['district'] = ""; // You can implement district detection if needed
      print('Sending request with location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        // Parse response
        var jsonResponse = json.decode(response.body);
        // Format result
        String detectionResult = jsonResponse['result'];
        String description = jsonResponse['description'];
        double confidence = jsonResponse['confidence'].toDouble();
        result = "$detectionResult (${confidence.toStringAsFixed(2)}%)";
        recommendation = description;
        // Navigate to results screen
        if (mounted) {
          Get.to(() => DetectionResultScreen(
            image: image!,
            result: result,
            recommendation: recommendation,
          ));
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
        // Try to parse error message if available
        String errorMessage = "Failed to analyze image. Please try again.";
        try {
          var errorResponse = json.decode(response.body);
          if (errorResponse.containsKey('error')) {
            errorMessage = errorResponse['error'];
          }
        } catch (e) {
          // If can't parse JSON, use default error message
        }
        setState(() {
          result = "Error: Could not process image";
          recommendation = errorMessage;
        });
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        result = "Error: $e";
        recommendation = "Please check your connection and try again";
      });
      Get.snackbar(
        'Connection Error',
        'Please check your internet connection and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // For testing purposes - use this method to send a request with hardcoded Uganda coordinates
  Future<void> detectWithHardcodedLocation() async {
    if (image == null) return;
    setState(() {
      result = "";
      recommendation = "";
      _isProcessing = true;
    });
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath('file', image!.path),
      );
      // Add hardcoded location data for testing (coordinates in Kampala, Uganda)
      request.fields['latitude'] = "0.3476";
      request.fields['longitude'] = "32.5825";
      request.fields['district'] = "Kampala";
      print('Sending request with hardcoded location: 0.3476, 32.5825');
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      // Process response as in the normal method
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String detectionResult = jsonResponse['result'];
        String description = jsonResponse['description'];
        double confidence = jsonResponse['confidence'].toDouble();
        result = "$detectionResult (${confidence.toStringAsFixed(2)}%)";
        recommendation = description;
        if (mounted) {
          Get.to(() => DetectionResultScreen(
            image: image!,
            result: result,
            recommendation: recommendation,
          ));
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
        String errorMessage = "Failed to analyze image. Please try again.";
        try {
          var errorResponse = json.decode(response.body);
          if (errorResponse.containsKey('error')) {
            errorMessage = errorResponse['error'];
          }
        } catch (e) {
          // If can't parse JSON, use default error message
        }
        setState(() {
          result = "Error: Could not process image";
          recommendation = errorMessage;
        });
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        result = "Error: $e";
        recommendation = "Please check your connection and try again";
      });
      Get.snackbar(
        'Connection Error',
        'Please check your internet connection and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

// Custom button widget for the bottom action buttons
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  const ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon,
              color: onPressed == null ? Colors.white.withOpacity(0.5) : Colors.white,
              size: 28
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: onPressed == null ? Colors.white.withOpacity(0.5) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
