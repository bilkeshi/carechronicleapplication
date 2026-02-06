import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'severity_screen.dart';

class WoundModel {
  final String? id;
  final String patientId;
  final String imageUrl;
  final String type;
  final DateTime createdAt;

  WoundModel({
    this.id,
    required this.patientId,
    required this.imageUrl,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'imageUrl': imageUrl,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory WoundModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? {};
    return WoundModel(
      id: snapshot.id,
      patientId: data['patientId'],
      imageUrl: data['imageUrl'],
      type: data['type'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final String imageUrl;

  ResultScreen({required this.imagePath, required this.imageUrl});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class WoundValidator {
  // Threshold constant
  static const double MIN_WOUND_AREA_PERCENTAGE = 0.02;

  static bool _isValidWoundColor(img.Image image, int x, int y) {
    final pixel = image.getPixel(x, y);
    final r = img.getRed(pixel);
    final g = img.getGreen(pixel);
    final b = img.getBlue(pixel);

    bool isReddish =
        r > 150 && g < 150 && b < 150 && (r - g) > 50 && (r - b) > 50;
    bool isPinkish =
        r > 200 && g > 150 && b > 150 && (r - g) > 30 && (r - b) > 30;
    bool isDarkRed = r > 120 && r < 180 && g < 100 && b < 100 && (r - g) > 40;
    bool isBrownish = r > 120 && g > 60 && g < 150 && b < 100 && (r - b) > 40;

    return isReddish || isPinkish || isDarkRed || isBrownish;
  }

  static Future<ValidationResult> validateWoundPresence(img.Image image) async {
    int totalPixels = image.width * image.height;
    int woundlikePixels = 0;

    // Sample pixels at regular intervals
    for (int y = 0; y < image.height; y += 2) {
      for (int x = 0; x < image.width; x += 2) {
        if (_isValidWoundColor(image, x, y)) {
          woundlikePixels++;
        }
      }
    }

    double woundAreaPercentage = woundlikePixels / (totalPixels / 4);

    return ValidationResult(
        isValid: woundAreaPercentage >= MIN_WOUND_AREA_PERCENTAGE,
        reason: woundAreaPercentage >= MIN_WOUND_AREA_PERCENTAGE
            ? "Valid wound detected"
            : "No significant wound area detected");
  }
}

class ValidationResult {
  final bool isValid;
  final String reason;

  ValidationResult({required this.isValid, required this.reason});
}

class _ResultScreenState extends State<ResultScreen> {
  String _woundType = "Analyzing...";
  String _debugInfo = "";
  Interpreter? _interpreter;
  bool _isLoading = true;
  ui.Image? _segmentationMask;

  static const double CONFIDENCE_THRESHOLD = 0.75;
  static const double SEGMENTATION_THRESHOLD = 0.70;
  static const int MINIMUM_WOUND_PIXELS = 1000;
  static const double MINIMUM_WOUND_AREA_PERCENTAGE = 0.01;

  @override
  void initState() {
    super.initState();
    _loadModel().then((_) {
      _analyzeImage();
    }).catchError((e) {
      setState(() {
        _woundType = "Error loading model: ${e.toString()}";
        _isLoading = false;
      });
    });
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model/best_float32.tflite');
    } catch (e) {
      print("Error loading model: $e");
      throw Exception("Error loading model: $e");
    }
  }

  Future<void> _analyzeImage() async {
    try {
      if (_interpreter == null) {
        throw Exception("Interpreter is not initialized");
      }

      final imageFile = File(widget.imagePath);
      if (!await imageFile.exists()) {
        throw Exception("Image file does not exist");
      }

      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) throw Exception("Failed to decode image");

      final validationResult =
          await WoundValidator.validateWoundPresence(originalImage);
      if (!validationResult.isValid) {
        setState(() {
          _woundType = validationResult.reason;
          _isLoading = false;
        });
        return;
      }

      final resizedImage = img.copyResizeCropSquare(originalImage, 640);
      final inputSize = 1 * 640 * 640 * 3;
      final Float32List input = Float32List(inputSize);

      var pixelIndex = 0;
      for (var y = 0; y < resizedImage.height; y++) {
        for (var x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[pixelIndex++] = img.getRed(pixel) / 255.0;
          input[pixelIndex++] = img.getGreen(pixel) / 255.0;
          input[pixelIndex++] = img.getBlue(pixel) / 255.0;
        }
      }

      var inputArray = [
        input.reshape([1, 640, 640, 3])
      ];
      final outputBuffer1 = Float32List(1 * 39 * 8400).buffer;
      final outputBuffer2 = Float32List(1 * 160 * 160 * 32).buffer;

      Map<int, Object> outputs = {
        0: outputBuffer1,
        1: outputBuffer2,
      };

      _interpreter!.runForMultipleInputs(inputArray, outputs);

      Float32List outputArray = outputBuffer1.asFloat32List();
      double maxConfidence = -1.0;
      int detectedClass = -1;

      for (int box = 0; box < 8400; box++) {
        int baseIndex = box * 39;
        int classStartIndex = baseIndex + 5;

        for (int cls = 0; cls < 3; cls++) {
          int index = classStartIndex + cls;
          if (index < outputArray.length) {
            double confidence = 1.0 / (1.0 + exp(-outputArray[index]));
            if (confidence > maxConfidence) {
              maxConfidence = confidence;
              detectedClass = cls;
            }
          }
        }
      }

      Float32List rawMaskData = outputBuffer2.asFloat32List();
      int maskSize = 160 * 160;
      Float32List segmentationData = Float32List(maskSize);

      List<double> channelMaxValues = List.filled(32, 0.0);
      List<double> channelMinValues = List.filled(32, double.infinity);
      List<double> channelVariances = List.filled(32, 0.0);

      for (int pixel = 0; pixel < maskSize; pixel++) {
        for (int channel = 0; channel < 32; channel++) {
          int index = pixel * 32 + channel;
          double value = rawMaskData[index];
          channelMaxValues[channel] = max(channelMaxValues[channel], value);
          channelMinValues[channel] = min(channelMinValues[channel], value);
          channelVariances[channel] += value * value;
        }
      }

      int bestChannel = 0;
      double maxVariance = -1;
      for (int i = 0; i < 32; i++) {
        channelVariances[i] = channelVariances[i] / maskSize -
            pow(channelMaxValues[i] + channelMinValues[i], 2) / 4;
        if (channelVariances[i] > maxVariance) {
          maxVariance = channelVariances[i];
          bestChannel = i;
        }
      }

      int significantPixels = 0;
      for (int i = 0; i < maskSize; i++) {
        double value = rawMaskData[i * 32 + bestChannel];
        segmentationData[i] = value;
        if (value > SEGMENTATION_THRESHOLD) {
          significantPixels++;
        }
      }

      if (significantPixels < MINIMUM_WOUND_PIXELS) {
        setState(() {
          _woundType = "No significant wound area detected";
          _isLoading = false;
        });
        return;
      }

      _segmentationMask =
          await _createSegmentationMask(segmentationData, 640, 640);

      setState(() {
        if (maxConfidence > CONFIDENCE_THRESHOLD) {
          _woundType =
              "${_interpretResult(detectedClass)} (Confidence: ${(maxConfidence * 100).toStringAsFixed(1)}%)";
        } else {
          _woundType = "Unable to classify wound type with high confidence";
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Analysis error: $e");
      setState(() {
        _woundType = "Error analyzing image: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<ui.Image> _createSegmentationMask(
      Float32List maskData, int originalWidth, int originalHeight) async {
    final maskWidth = 160;
    final maskHeight = 160;
    final completer = Completer<ui.Image>();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
        Rect.fromLTWH(
            0, 0, originalWidth.toDouble(), originalHeight.toDouble()),
        Paint()..color = Colors.transparent);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < originalHeight; y++) {
      for (int x = 0; x < originalWidth; x++) {
        double scaleX = x * maskWidth / originalWidth;
        double scaleY = y * maskHeight / originalHeight;

        double value = maskData[(scaleY.toInt() * maskWidth + scaleX.toInt())];
        double sigmoidValue = 1.0 / (1.0 + exp(-value));

        if (sigmoidValue > SEGMENTATION_THRESHOLD) {
          paint.color = Color.fromRGBO(
            (sigmoidValue * 255).toInt(),
            0,
            (255 - sigmoidValue * 255).toInt(),
            0.5,
          );
          canvas.drawRect(
              Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
        }
      }
    }

    final picture = recorder.endRecording();
    picture.toImage(originalWidth, originalHeight).then((image) {
      completer.complete(image);
    });

    return completer.future;
  }

  String _interpretResult(int classIndex) {
    final Map<int, String> woundTypes = {
      0: "Diabetic Wound",
      1: "Venous Wound",
      2: "Pressure Wound",
    };
    return woundTypes[classIndex] ?? "Unknown Wound Type";
  }

  final woundConverter =
      FirebaseFirestore.instance.collection('wounds').withConverter<WoundModel>(
            fromFirestore: WoundModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore(),
          );

  Future<void> addWoundToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to add a wound');
      }

      final newWound = WoundModel(
        patientId: user.uid,
        imageUrl: widget.imageUrl,
        type: _woundType.split(' (')[0], // Remove confidence percentage
        createdAt: DateTime.now(),
      );

      await woundConverter.add(newWound);
    } catch (e) {
      print('Error adding wound: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save wound data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wound Analysis Result"),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    File(widget.imagePath),
                    height: 350,
                    width: 350,
                    fit: BoxFit.cover,
                  ),
                  if (_segmentationMask != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SegmentationPainter(mask: _segmentationMask!),
                      ),
                    ),
                ],
              ),
              if (_debugInfo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Debug Info: $_debugInfo",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                )
              else
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Wound Type",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _woundType,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
              if (!_isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _woundType = "Analyzing...";
                          _segmentationMask = null;
                          _debugInfo = "";
                        });
                        _analyzeImage();
                      },
                      child: Text("Re-Analyze"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7165D6),
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeverityScreen(
                              woundType: _woundType.split(' (')[0],
                              imagePath: widget.imagePath,
                              imageUrl: widget.imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Text("Next"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SegmentationPainter extends CustomPainter {
  final ui.Image mask;

  SegmentationPainter({required this.mask});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImageRect(
      mask,
      Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
