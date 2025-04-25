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
  bool _showTips = true; // Show tips by default when screen opens

  // Api Url
  final String apiUrl = "https://newapi-uxzc.onrender.com/detect";

  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
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
                              "4. Position the leaf in the center of the frame.",
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
                    onPressed: (_isProcessing || _showTips) ? null : () => chooseImage(),
                  ),
                  ActionButton(
                    icon: Icons.camera_alt,
                    label: "Capture",
                    onPressed: (_isProcessing || _showTips) ? null : () => captureImage(),
                  ),
                  ActionButton(
                    icon: Icons.info_outline,
                    label: "Tips",
                    onPressed: _isProcessing ? null : () {
                      setState(() {
                        _showTips = true;
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

        setState(() {
          result = "Error: Could not process image";
          recommendation = "Please try again with a clearer image";
        });

        Get.snackbar(
          'Error',
          'Failed to analyze image. Please try again with a clearer photo.',
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
          icon: Icon(icon, color: Colors.white, size: 28),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}