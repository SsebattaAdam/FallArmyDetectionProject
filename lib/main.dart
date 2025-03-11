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
import 'constants/constants.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

late List<CameraDescription> _cameras;
Widget defaultHome = main_page();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
          home: AuthWrapper(defaultHome: defaultHome), // Wrap the defaultHome with AuthWrapper
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

        // If the user is logged in, proceed to the defaultHome
        if (snapshot.hasData && snapshot.data != null) {
          return defaultHome;
        } else {
          // If the user is not logged in, proceed to the defaultHome (or replace with a LoginScreen)
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

class _RealTimeDetectionState extends State<RealTimeDetection> {
  late CameraController controller;
  bool isBusy = false;
  String result = "";
  late ImageLabeler imageLabeler;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    controller = CameraController(
      _cameras[0],
      ResolutionPreset.max,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await controller.initialize();
    if (!mounted) return;
    controller.startImageStream((image) {
      if (!isBusy) {
        isBusy = true;
        _doImageLabeling(image);
      }
    });
    setState(() {});
  }

  Future<void> _loadModel() async {
    final modelPath = await _getModelPath('images/ml/fallarmyworm_matadata.tflite');
    final options = LocalLabelerOptions(confidenceThreshold: 0.8, modelPath: modelPath);
    imageLabeler = ImageLabeler(options: options);
  }

  Future<String> _getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<void> _doImageLabeling(CameraImage img) async {
    result = "";
    InputImage? inputImg = _inputImageFromCameraImage(img);
    if (inputImg != null) {
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImg);
      for (ImageLabel label in labels) {
        result += "${label.label} (${label.confidence.toStringAsFixed(2)})\n";
      }
      setState(() => isBusy = false);
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || image.planes.isEmpty) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation!,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryLight,
        title: const Text('Realtime Detection', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            controller.value.isInitialized
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 300,
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Image.asset("images/f1.png", fit: BoxFit.fill),
                ),
              ],
            )
                : const CircularProgressIndicator(),
            Card(
              color: kPrimaryLight,
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Center(
                  child: Text(result, style: const TextStyle(fontSize: 35, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
