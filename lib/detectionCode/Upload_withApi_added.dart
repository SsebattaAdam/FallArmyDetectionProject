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

  // Store a global reference to the BuildContext
  late BuildContext _scaffoldContext;

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
  }

  @override
  Widget build(BuildContext context) {
    // Store the context for later use
    _scaffoldContext = context;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detect Fall Armyworm',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: kPrimary,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AnimatedSwitcher(
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
                          child: CircularProgressIndicator(),
                        )
                            : ClipRRect(
                          key: ValueKey('image'),
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fixed Buttons at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: kPrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.photo_library, color: Colors.black),
                    onPressed: _isProcessing ? null : () => chooseImage(),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.black),
                    onPressed: _isProcessing ? null : () => captureImage(),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.black),
                    onPressed: _isProcessing ? null : () => showTips(),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: kPrimary),
                    SizedBox(height: 16),
                    Text(
                      "Analyzing image...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

      // Show error message using the stored context
      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
        SnackBar(content: Text("Error capturing image: $e")),
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

        // Use the stored context
        ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode} - ${response.body}")),
        );
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        result = "Error: $e";
        recommendation = "Please check your connection and try again";
      });

      // Use the stored context
      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
        SnackBar(content: Text("Error connecting to API: $e")),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Modified to use the stored context
  void showTips() {
    showDialog(
      context: _scaffoldContext,
      builder: (context) => AlertDialog(
        title: Text("Tips for Detection"),
        content: Text(
          "1. Ensure the image is clear and well-lit.\n"
              "2. Focus on the leaves of the plant.\n"
              "3. Avoid blurry or distant shots.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
