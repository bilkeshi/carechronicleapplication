import 'dart:io';

import 'package:care_chronicle_app/Screens/in%20app%20screens/homescreen%20widgets/Wound%20Capture%20AI/tracking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'severity_screen.dart';

class FullDetailScreen extends StatefulWidget {
  final String woundType;
  final List<AlertLevel> responses;
  final List<Question> questions;
  final AlertLevel alertLevel;
  final String imagePath;
  final String imageUrl; // This will be used to display the image

  FullDetailScreen({
    required this.woundType,
    required this.responses,
    required this.questions,
    required this.alertLevel,
    required this.imagePath, // Add imagePath
    required this.imageUrl, // Add imageUrl
  });

  @override
  _FullAssessmentScreenState createState() => _FullAssessmentScreenState();
}

class _FullAssessmentScreenState extends State<FullDetailScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
          'wound_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL(); // Return the image URL
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      setState(() {
        // Detect whether the user has scrolled down
        _isScrolled = _scrollController.position.pixels > 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getAlertColor() {
    switch (widget.alertLevel) {
      case AlertLevel.green:
        return Colors.green;
      case AlertLevel.yellow:
        return Colors.orange;
      case AlertLevel.red:
        return Colors.red;
    }
  }

  String _getAlertText() {
    switch (widget.alertLevel) {
      case AlertLevel.green:
        return 'Green Zone: Healing well, monitor for 30 days';
      case AlertLevel.yellow:
        return 'Yellow Zone: Requires closer monitoring';
      case AlertLevel.red:
        return 'Red Zone: Immediate attention required';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wound Assessment'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.woundType,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7165D6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(height: 20),
                    // Use imageUrl here instead of TrackingData
                    if (widget.imageUrl.isNotEmpty)
                      Column(
                        children: [
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.imageUrl, // Use imageUrl
                              height: 230,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Text(
                                      'Error loading image',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 24),
                    Text(
                      'Severity',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getAlertColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getAlertColor()),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getAlertText(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getAlertColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Response Summary',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ...List.generate(
                      widget.questions.length,
                      (index) => Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.questions[index].text,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Response: ${widget.questions[index].options[widget.questions[index].alertLevels.indexOf(widget.responses[index])]}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getAlertColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Show button only if scrolled down
            if (_isScrolled)
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(0xFF7165D6)),
                          ),
                        ),
                        onPressed: () async {
                          String userId =
                              FirebaseAuth.instance.currentUser?.uid ?? '';

                          // Save assessment data to Firestore
                          DocumentReference assessmentRef =
                              await FirebaseFirestore.instance
                                  .collection('patients')
                                  .doc(userId)
                                  .collection('assessments')
                                  .add({
                            'woundType': widget.woundType,
                            'severity': widget.alertLevel.toString(),
                            'responses': widget.responses
                                .map((e) => e.toString())
                                .toList(),
                            'questions':
                                widget.questions.map((q) => q.text).toList(),
                            'imagePath': widget.imagePath, // Save imagePath
                            'imageUrl': widget.imageUrl, // Save imageUrl
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          print(
                              'Assessment saved with ID: ${assessmentRef.id}');

                          // Navigate to Tracking Screen after saving
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackingScreen(
                                assessments: [
                                  Assessment(
                                    woundType: widget.woundType,
                                    severity: widget.alertLevel,
                                    responses: widget.responses,
                                    questions: widget.questions,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Continue to Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF7165D6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
