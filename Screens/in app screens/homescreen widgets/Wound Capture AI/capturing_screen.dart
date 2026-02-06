import 'dart:io';

import 'package:camera/camera.dart';
import 'package:care_chronicle_app/Screens/in%20app%20screens/homescreen%20widgets/Wound%20Capture%20AI/result_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  CameraDescription? _selectedCamera;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _selectedCamera = _cameras?.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(
        _selectedCamera!, ResolutionPreset.high,
        enableAudio: false);
    await _cameraController?.initialize();

    if (!mounted) return;
    setState(() {});
  }

  // Capture image from camera
  Future<void> _captureImage() async {
    if (_cameraController!.value.isInitialized) {
      final file = await _cameraController!.takePicture();
      setState(() {
        _imagePath = file.path;
      });

      // Upload image to Firebase Storage
      String imageUrl = await _uploadImageToStorage(file.path);

      // Navigate to result screen and pass the image URL
      _navigateToResultScreen(imageUrl);
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImageToStorage(String imagePath) async {
    File imageFile = File(imagePath);

    // Create a reference for the image
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('wound_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the image
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

    // Get the image URL
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  // Navigate to result screen
  void _navigateToResultScreen(String imageUrl) {
    if (_imagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(imagePath: _imagePath!, imageUrl: imageUrl),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Wound Image Capture"),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text("Capture Image",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7165D6),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  onPressed: _captureImage,
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo, color: Colors.black),
                  label: Text("Select from Gallery",
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 15),
                  ),
                  onPressed: _pickImageFromGallery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });

      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImageToStorage(pickedFile.path);

      // Navigate to result screen and pass the image URL
      _navigateToResultScreen(imageUrl);
    }
  }
}
