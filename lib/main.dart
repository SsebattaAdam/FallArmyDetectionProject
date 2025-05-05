import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fammaize/views/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'Analytics/AnalyticsService.dart';
import 'constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:firebase_analytics/firebase_analytics.dart'; // For FirebaseAnalytics
import 'detectionCode/results.dart';


late List<CameraDescription> _cameras;
Widget defaultHome = main_page();

Future<void> main() async {
  // Record app start time for performance measurement
  final startTime = DateTime.now();

  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase and cameras in parallel
    await Future.wait([
      Firebase.initializeApp().then((_) {
        if (kDebugMode) {
          FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
          debugPrint('Firebase Analytics debug mode enabled');
        }
      }),
      availableCameras().then((cameras) => _cameras = cameras),
    ]);

    // Initialize analytics service
    await Get.putAsync(() => AnalyticsService().init());

    // Log startup performance
    final startupTime = DateTime.now().difference(startTime).inMilliseconds;
    await AnalyticsService.to.logAppStartupTime(startupTime);
    await AnalyticsService.to.logEvent(
      name: 'app_initialized',
      parameters: {
        'startup_time_ms': startupTime,
        'platform': Platform.operatingSystem,
      },
    );

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);
      await AnalyticsService.to.logError(
        errorType: 'flutter_error',
        errorMessage: details.exception.toString(),
        screenName: details.context?.toString(),
      );
    };

    // Run app with error zone
    runZonedGuarded(
          () => runApp(const MyApp()),
          (error, stackTrace) async {
        await AnalyticsService.to.logError(
          errorType: 'zone_error',
          errorMessage: error.toString(),
        );
      },
    );
  } catch (e, stack) {
    // Fallback error handling if initialization fails
    debugPrint('App initialization failed: $e');
    debugPrint(stack.toString());

    // Try to log the error even if analytics might not be available
    try {
      await AnalyticsService.to?.logError(
        errorType: 'init_error',
        errorMessage: e.toString(),
      );
    } catch (_) {}

    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
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

  // In your _RealTimeDetectionState class:

// Add this when the screen first loads
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    AnalyticsService.to.logScreenView(
      screenName: 'realtime_detection',
      screenClass: 'RealTimeDetection',
    );
  }

// Add this when processing starts
  Future<void> _processFrame(CameraImage image) async {
    try {
      AnalyticsService.to.logDetectionAttempt(
        method: 'realtime_camera',
        source: 'camera_stream',
      );
      // ... rest of your existing code
    } catch (e) {
      AnalyticsService.to.logDetectionError(
        method: 'realtime_camera',
        errorType: 'processing_error',
        errorMessage: e.toString(),
      );
      // ... rest of error handling
    }
  }

// Add this when getting API results
  Future<void> _sendImageToAPI(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Declare variables before using them
      final startTime = DateTime.now(); // For measuring processing time
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String detectionResult = jsonResponse['result']; // Define here
        double detectedConfidence = jsonResponse['confidence'].toDouble();

        setState(() {
          result = "$detectionResult (${detectedConfidence.toStringAsFixed(2)}%)";
          recommendation = jsonResponse['description'];
          confidence = detectedConfidence;
        });

        // Log detection result
        await AnalyticsService.to.logDetectionResult(
          method: 'api_call',
          result: detectionResult,
          confidence: detectedConfidence,
          isArmyworm: detectionResult.toLowerCase().contains('armyworm'),
          processingTimeMs: DateTime.now().difference(startTime).inMilliseconds,
        );
      }
    } catch (e) {
      // Error handling
    }
  }

  // API URL
  final String apiUrl = "https://newapi-uxzc.onrender.com/detect";

  // For controlling detection frequency
  int _frameSkip = 0;
  final int _processEveryNFrames = 30;

  // For tracking detection confidence
  double confidence = 0.0;

  // List of cameras
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isStreamActive = false;


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
                                "5. Wait for automatic detection to occur.",
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showTips = false;
                              });
                              _startCameraStream();
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
                              "Start Detection",
                              style: TextStyle(fontSize: 16),
                            ),
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
