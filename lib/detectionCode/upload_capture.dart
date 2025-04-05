import 'dart:io';
import 'package:fammaize/constants/constants.dart';
import 'package:fammaize/detectionCode/results.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';

class UploadCaptureScreen extends StatefulWidget {
  const UploadCaptureScreen({super.key});

  @override
  State<UploadCaptureScreen> createState() => _UploadCaptureScreenState();
}

class _UploadCaptureScreenState extends State<UploadCaptureScreen> {
  late ImagePicker imagePicker;
  late ImageLabeler imageLabeler;
  File? image;
  String result = "";
  String recommendation = "";
  bool _isProcessing = false;
  bool _showTips = true; // Show tips by default when screen opens

  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    loadModel();
    initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    imageLabeler.close();
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
                        "Processing image...",
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
      await performImageLabeling();
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
      await performImageLabeling();
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

  Future<void> performImageLabeling() async {
    setState(() {
      result = "";
      recommendation = "";
      _isProcessing = true;
    });

    try {
      InputImage inputImage = InputImage.fromFilePath(image!.path);
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

      for (ImageLabel label in labels) {
        final String text = label.label;
        final double confidence = label.confidence;
        result += "$text (${(confidence * 100).toStringAsFixed(2)}%)\n";
      }

      // Add recommendation based on detection
      if (labels.isNotEmpty) {
        final topLabel = labels.first.label.toLowerCase();
        if (topLabel.contains("armyworm") || topLabel.contains("pest")) {
          recommendation = "This appears to be Fall Armyworm damage. Consider applying appropriate pesticides and consult with an agricultural extension officer.";
        } else if (topLabel.contains("healthy")) {
          recommendation = "Your maize plant appears healthy. Continue with regular care and monitoring.";
        } else {
          recommendation = "Results inconclusive. Please take another image with better lighting and focus.";
        }
      } else {
        recommendation = "No specific condition detected. Please take a clearer image.";
      }

      if (mounted) {
        Get.to(() => DetectionResultScreen(
          image: image!,
          result: result,
          recommendation: recommendation,
        ));
      }
    } catch (e) {
      print("Error in image labeling: $e");
      Get.snackbar(
        'Error',
        'Failed to analyze image. Please try again.',
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

  Future<void> loadModel() async {
    try {
      final modelPath = await getModelPath('images/ml/maizeleafclassifier_metadata.tflite');
      final options = LocalLabelerOptions(
        confidenceThreshold: 0.8,
        modelPath: modelPath,
      );
      imageLabeler = ImageLabeler(options: options);
    } catch (e) {
      print("Error loading model: $e");
      Get.snackbar(
        'Error',
        'Failed to load detection model. Please restart the app.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
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
