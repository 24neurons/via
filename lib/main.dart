import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
    // Log available cameras for debugging
    for (var camera in cameras) {
      print('Camera: ${camera.name}, Lens Direction: ${camera.lensDirection}');
    }
  } catch (e) {
    print('Error fetching cameras: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isCameraInitialized = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (cameras.isNotEmpty) {
      initializeCamera();
    } else {
      setState(() {
        errorMessage = 'No cameras available';
      });
    }
  }

  Future<void> initializeCamera() async {
    // Select the back camera (or modify to select the desired camera)
    CameraDescription selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras[0], // Fallback to first camera if no back camera
    );

    controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
    );

    try {
      await controller!.initialize();
      if (!mounted) return;
      setState(() {
        isCameraInitialized = true;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing camera: $e';
      });
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera App'),
      ),
      body: Column(
        children: [
          if (errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(errorMessage),
              ),
            )
          else if (isCameraInitialized && controller != null)
            Expanded(
              child: CameraPreview(controller!),
            )
          else
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () {
                if (!isCameraInitialized && cameras.isNotEmpty) {
                  initializeCamera();
                }
              },
              child: Icon(Icons.camera_alt),
              tooltip: 'Open Camera',
            ),
          ),
        ],
      ),
    );
  }
}