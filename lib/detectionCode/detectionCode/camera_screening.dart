import 'dart:io';
import 'package:fammaize/constants/constants.dart';
import 'package:flutter/material.dart';
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

  // Camera-related variables
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

  // Initialize the camera
  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0], // Use the first camera (back camera)
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: kPrimary,
      ),
      body: Column(
        children: [
          // Camera Preview or Selected Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: image == null
                  ? _isCameraInitialized
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CameraPreview(_cameraController),
              )
                  : Center(
                child: CircularProgressIndicator(),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.all(16),
            color: kPrimary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Upload from Gallery
                IconButton(
                  icon: Icon(Icons.photo_library, color: Colors.white),
                  onPressed: () => chooseImage(),
                ),

                // Take a Picture
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () => captureImage(),
                ),

                // View Tips
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () => showTips(context),
                ),
              ],
            ),
          ),

          // Detection Result
          if (result.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: kPrimary,
              child: Text(
                result,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Choose Image from Gallery
  Future<void> chooseImage() async {
    XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        image = File(selectedImage.path);
      });
      performImageLabeling();
    }
  }

  // Capture Image from Camera
  Future<void> captureImage() async {
    if (!_isCameraInitialized) return;

    try {
      final XFile picture = await _cameraController.takePicture();
      setState(() {
        image = File(picture.path);
      });
      performImageLabeling();
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  // Perform Image Labeling
  Future<void> performImageLabeling() async {
    result = "";
    InputImage inputImage = InputImage.fromFilePath(image!.path);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      result += "$text (${(confidence * 100).toStringAsFixed(2)}%)\n";
    }
    setState(() {
      result = result;
    });
  }

  // Show Tips Dialog
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

  // Load Model
  Future<void> loadModel() async {
    final modelPath = await getModelPath('images/ml/flowers.tflite');
    final options = LocalLabelerOptions(
      confidenceThreshold: 0.8,
      modelPath: modelPath,
    );
    imageLabeler = ImageLabeler(options: options);
  }

  // Get Model Path
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