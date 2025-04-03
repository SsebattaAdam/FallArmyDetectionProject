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
                    onPressed: _isProcessing ? null : () => showTips(context),
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
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> performImageLabeling() async {
    setState(() {
      result = "";
      recommendation = "";
      _isProcessing = true;
    });

    InputImage inputImage = InputImage.fromFilePath(image!.path);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      result += "$text (${(confidence * 100).toStringAsFixed(2)}%)\n";
    }

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      Get.to(() => DetectionResultScreen(
        image: image!,
        result: result,
        recommendation: recommendation,
      ));
    }
  }

  void showTips(BuildContext context) {
    showDialog(
      context: context,
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

  Future<void> loadModel() async {
    final modelPath = await getModelPath('images/ml/maizeleafclassifier_metadata.tflite');
    final options = LocalLabelerOptions(
      confidenceThreshold: 0.8,
      modelPath: modelPath,
    );
    imageLabeler = ImageLabeler(options: options);
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
