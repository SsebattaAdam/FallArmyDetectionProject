import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fammaize/views/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'Analytics/AnalyticsService.dart';
import 'constants/constants.dart';
import 'detectionCode/results.dart';
import 'map/providerformap/providerformap.dart';

late List<CameraDescription> _cameras;
Widget defaultHome = main_page();

Future<void> main() async {
  // Ensure Flutter is initialized first
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize services in parallel
    await Future.wait([
      Firebase.initializeApp(),
      availableCameras().then((cameras) => _cameras = cameras),
      dotenv.load(fileName: ".env"), // Load environment variables
    ]);

    // Initialize analytics service
    await Get.putAsync(() => AnalyticsService().init());

    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AnalyticsService.to.logError(
        errorType: 'flutter_error',
        errorMessage: details.exception.toString(),
        screenName: details.context?.toString(),
      );
    };

    // Run app in the same zone
    runApp(const MyApp());

  } catch (error, stackTrace) {
    print('Error during initialization: $error');
    // Still run the app even if initialization fails
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MapDataProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 825),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fall Armyworm',
            theme: ThemeData(
              scaffoldBackgroundColor: kOffWhite,
              iconTheme: const IconThemeData(color: kDark),
              primarySwatch: Colors.grey,
            ),
            // Add analytics observer for automatic screen tracking
            navigatorObservers: [
              AnalyticsService.to.getObserver(),
            ],
            home: AuthWrapper(defaultHome: defaultHome),
            // Track route changes
            routingCallback: (routing) {
              if (routing?.current != null && routing?.previous != null) {
                AnalyticsService.to.logNavigation(
                  routing!.previous!,
                  routing.current!,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Widget defaultHome;
  const AuthWrapper({required this.defaultHome, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Track authentication state
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          final user = snapshot.data!;
          AnalyticsService.to.setUserId(user.uid);
          AnalyticsService.to.setUserProperty(
            name: 'user_email_domain',
            value: user.email?.split('@').last,
          );
          AnalyticsService.to.logLogin();
          return defaultHome;
        } else {
          // User is not logged in
          AnalyticsService.to.setUserId('anonymous_user');
          AnalyticsService.to.logEvent(
            name: 'anonymous_access',
            parameters: {'timestamp': DateTime.now().millisecondsSinceEpoch},
          );
          return defaultHome;
        }
      },
    );
  }
}

class RealTimeDetection extends StatefulWidget {
  const RealTimeDetection({super.key});

  @override
  State<RealTimeDetection> createState() => _RealTimeDetectionState();
}

class _RealTimeDetectionState extends State<RealTimeDetection> with WidgetsBindingObserver {
  late CameraController controller;
  bool isBusy = false;
  String result = "";
  String recommendation = "";
  bool _showTips = true; // Always show tips when screen opens
  File? _currentImageFile; // Track the current image file
  // API URL
  final String apiUrl = "https://fastapitest-1qsv.onrender.com/detect";
  // For controlling detection frequency
  int _frameSkip = 0;
  final int _processEveryNFrames = 30;
  // For tracking detection confidence
  double confidence = 0.0;
  // List of cameras
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isStreamActive = false;

  // Location data
  Position? _currentPosition;
  bool _isLocationLoading = false;
  String? _district;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCameraStream();
    _cleanUpImageFile(); // Clean up any existing image file
    controller.dispose();
    super.dispose();
  }

  // Clean up the image file
  void _cleanUpImageFile() {
    if (_currentImageFile != null && _currentImageFile!.existsSync()) {
      _currentImageFile!.deleteSync();
    }
    _currentImageFile = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCameraStream();
    } else if (state == AppLifecycleState.resumed) {
      _resetAndRestartCamera();
      _getCurrentLocation(); // Refresh location when app resumes
    }
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      'Alert',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: EdgeInsets.all(8),
      duration: Duration(seconds: 3),
    );
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied');
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });

      // Optionally determine district from coordinates
      // This could be done via a local lookup or API call
      // For now, we'll leave it empty and let the API determine it

    } catch (e) {
      print("Error getting location: $e");
      _showSnackBar('Error getting location. Please check your location settings.');
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  // Check if location is within Uganda's bounds
  bool _isLocationInUganda() {
    if (_currentPosition == null) return false;

    // Uganda's approximate bounds
    const UGANDA_LAT_MIN = -1.5;
    const UGANDA_LAT_MAX = 4.2;
    const UGANDA_LON_MIN = 29.5;
    const UGANDA_LON_MAX = 35.0;

    return _currentPosition!.latitude >= UGANDA_LAT_MIN &&
        _currentPosition!.latitude <= UGANDA_LAT_MAX &&
        _currentPosition!.longitude >= UGANDA_LON_MIN &&
        _currentPosition!.longitude <= UGANDA_LON_MAX;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      controller = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
      // Always show tips when coming back to this screen
      setState(() {
        _showTips = true;
      });
    } catch (e) {
      print("Error initializing camera: $e");
      _showSnackBar("Error initializing camera. Please restart the app.");
    }
  }

  Future<void> _startCameraStream() async {
    if (!_isStreamActive && _isCameraInitialized && mounted) {
      try {
        _frameSkip = 0;
        await controller.startImageStream((image) {
          if (!_showTips) { // Only process frames if tips are dismissed
            _frameSkip++;
            if (!isBusy && _frameSkip >= _processEveryNFrames) {
              _frameSkip = 0;
              isBusy = true;
              _processFrame(image);
            }
          }
        });
        _isStreamActive = true;
      } catch (e) {
        print("Error starting camera stream: $e");
      }
    }
  }

  Future<void> _stopCameraStream() async {
    if (_isStreamActive && _isCameraInitialized) {
      try {
        await controller.stopImageStream();
        _isStreamActive = false;
      } catch (e) {
        print("Error stopping camera stream: $e");
      }
    }
  }

  Future<void> _resetAndRestartCamera() async {
    if (_isCameraInitialized) {
      await _stopCameraStream();
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          isBusy = false;
          result = "";
          recommendation = "";
          confidence = 0.0;
          _showTips = true; // Always show tips when coming back
          _cleanUpImageFile(); // Clean up any existing image file
        });
      }
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      // Check if location is available
      if (_currentPosition == null) {
        _showSnackBar("Location data is required. Please enable location services.");
        await _getCurrentLocation();
        return;
      }

      // Check if location is within Uganda
      if (!_isLocationInUganda()) {
        _showSnackBar("Detection is only available within Uganda's boundaries.");
        return;
      }

      // Clean up previous image file if exists
      _cleanUpImageFile();
      // Convert CameraImage to File
      final File imageFile = await _convertImageToFile(image);
      _currentImageFile = imageFile; // Store the current image file
      // Send to API
      await _sendImageToAPI(imageFile);
    } catch (e) {
      print("Error processing frame: $e");
    } finally {
      if (mounted) {
        setState(() {
          isBusy = false;
        });
      }
    }
  }

  Future<File> _convertImageToFile(CameraImage image) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_frame_${DateTime.now().millisecondsSinceEpoch}.jpg');
    try {
      final XFile picture = await controller.takePicture();
      final bytes = await picture.readAsBytes();
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    } catch (e) {
      print("Error converting image: $e");
      throw e;
    }
  }

  Future<void> _sendImageToAPI(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Add location data
      if (_currentPosition != null) {
        request.fields['latitude'] = _currentPosition!.latitude.toString();
        request.fields['longitude'] = _currentPosition!.longitude.toString();

        // Add district if available
        if (_district != null && _district!.isNotEmpty) {
          request.fields['district'] = _district!;
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String detectionResult = jsonResponse['result'];
        String description = jsonResponse['description'];
        double detectedConfidence = jsonResponse['confidence'].toDouble();

        setState(() {
          result = "$detectionResult (${detectedConfidence.toStringAsFixed(2)}%)";
          recommendation = description;
          confidence = detectedConfidence;
        });

        // Stop camera stream before navigating
        await _stopCameraStream();

        // Navigate to results screen
        if (mounted) {
          await Get.to(() => DetectionResultScreen(
            image: imageFile,
            result: result,
            recommendation: recommendation,
          ));

          // When returning from results screen, reset everything
          if (mounted) {
            await _resetAndRestartCamera();
          }
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");

        // Check if the error is related to location data
        if (response.statusCode == 400 && response.body.contains("location data is required")) {
          _showSnackBar("Valid location data is required. Please ensure your location services are enabled.");
          await _getCurrentLocation();
        } else {
          _showSnackBar("Error analyzing image. Please try again.");
        }
      }
    } catch (e) {
      print("Exception in API call: $e");
      _showSnackBar("Connection error. Please check your internet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await _stopCameraStream();
          _cleanUpImageFile();
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text(
                  'Realtime Detection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () async {
                  await _stopCameraStream();
                  _cleanUpImageFile();
                  Get.back();
                },
              ),
            ),
            body: Stack(
              children: [
            // Camera Preview
            _isCameraInitialized
            ? Container(
            width: double.infinity,
              height: double.infinity,
              child: CameraPreview(controller),
            )
                : Center(child: CircularProgressIndicator(color: Colors.green)),

    // Targeting overlay
    if (_isCameraInitialized && !_showTips)
    Positioned.fill(
    child: Center(
    child: Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
    border: Border.all(color: Colors.green, width: 2),
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    ),
    ),

    // Processing indicator
    if (isBusy)
    Positioned.fill(
    child: Container(
    color: Colors.black.withOpacity(0.7),
    child: Center(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    CircularProgressIndicator(color: Colors.green),
    SizedBox(height: 16),
    Text(
    "Analyzing image...",
    style: TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ),
    ),

    // Location loading indicator
    if (_isLocationLoading)
    Positioned(
    top: 10,
    right: 10,
    child: Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: Colors.black54,
    borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    SizedBox(
    width: 16,
    height: 16,
    child: CircularProgressIndicator(
    color: Colors.white,
    strokeWidth: 2,
    ),
    ),
    SizedBox(width: 8),
    Text(
    "Getting location...",
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    ),
    ),
    ],
    ),
    ),
    ),

    // Location status indicator
    if (!_isLocationLoading && _currentPosition != null && !_showTips)
    Positioned(
    top: 10,
    right: 10,
    child: Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: _isLocationInUganda() ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons.location_on,
    color: Colors.white,
    size: 16,
    ),
    SizedBox(width: 4),
    Text(
    _isLocationInUganda() ? "Location OK" : "Outside Uganda",
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    ),
    ),
    ],
    ),
    ),
    ),

                // Instruction text
                if (_isCameraInitialized && !_showTips)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Point camera at corn leaf",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Tips Overlay (always shown when _showTips is true)
                if (_showTips && _isCameraInitialized)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
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
                                "Real-time Detection Tips",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                "1. Hold the camera steady for best results.\n"
                                    "2. Position the leaf inside the green square.\n"
                                    "3. Ensure good lighting conditions.\n"
                                    "4. Keep the camera 15-20cm from the leaf.\n"
                                    "5. Wait for automatic detection to occur.\n"
                                    "6. Location services must be enabled.",
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 20),

                              // Location status in tips
                              if (_currentPosition == null)
                                Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_off, color: Colors.orange),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Location services required. Please enable location.",
                                          style: TextStyle(color: Colors.orange[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (!_isLocationInUganda())
                                Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.red),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Your location appears to be outside Uganda. Detection may not work correctly.",
                                          style: TextStyle(color: Colors.red[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.green),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Location services enabled and within Uganda.",
                                          style: TextStyle(color: Colors.green[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (_currentPosition == null)
                                    ElevatedButton.icon(
                                      onPressed: _getCurrentLocation,
                                      icon: Icon(Icons.location_searching),
                                      label: Text("Get Location"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),

                                  ElevatedButton(
                                    onPressed: _currentPosition == null ? null : () {
                                      setState(() {
                                        _showTips = false;
                                      });
                                      _startCameraStream();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text(
                                      "Start Detection",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ),
    );
  }
}

