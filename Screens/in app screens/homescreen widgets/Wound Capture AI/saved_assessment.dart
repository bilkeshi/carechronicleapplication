import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssessmentDetailScreen extends StatefulWidget {
  final String assessmentId;

  const AssessmentDetailScreen({Key? key, required this.assessmentId})
      : super(key: key);

  @override
  _AssessmentDetailScreenState createState() => _AssessmentDetailScreenState();
}

class _AssessmentDetailScreenState extends State<AssessmentDetailScreen> {
  Map<String, dynamic>? assessmentData;
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        // Detect scroll state
      });
    });
    loadAssessmentDetails();
  }

  Future<void> loadAssessmentDetails() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      // Handle case when user is not logged in (Optional)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User not logged in")));
      return;
    }

    var docSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(userId)
        .collection('assessments')
        .doc(widget.assessmentId)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        assessmentData = docSnapshot.data();
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Assessment not found")));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Assessment Details'),
            backgroundColor: Color(0xFF7165D6)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (assessmentData == null) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Assessment Details'),
            backgroundColor: Color(0xFF7165D6)),
        body: Center(child: Text("No data available")),
      );
    }

    // Extract assessment data
    String woundType = assessmentData!['woundType'];
    String severity = assessmentData!['severity'];
    List<dynamic> responses = assessmentData!['responses'];
    List<dynamic> questions = assessmentData!['questions'];
    String imagePath = assessmentData!['imagePath'];

    // Color for severity based on alert level
    Color alertColor = getSeverityColor(severity);

    return Scaffold(
      backgroundColor: Colors.white, // Keep the background white for contrast
      appBar: AppBar(
        title: Text('Assessment Details'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white, // Set header background color
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
                      woundType,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: alertColor),
                      textAlign: TextAlign.center,
                    ),
                    Divider(height: 20),

                    // Display Image if available
                    if (imagePath.isNotEmpty)
                      Column(
                        children: [
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(
                                  imagePath), // Convert the path string to a File object
                              height: 230,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image Error: $error'); // For debugging
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 40),
                                      SizedBox(height: 8),
                                      Text(
                                        'Error loading image',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      if (error != null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            error.toString(),
                                            style: TextStyle(
                                              color: Colors.red[700],
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 24),
                    // Display Severity
                    Text('Severity',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: alertColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: alertColor),
                      ),
                      child: Text(
                        getSeverityText(severity),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: alertColor),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Display Responses & Questions
                    Text('Response Summary',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ...List.generate(
                      questions.length,
                      (index) => Card(
                        margin: EdgeInsets.only(bottom: 16),
                        color: Colors.white.withOpacity(0.8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Question ${index + 1}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600])),
                              SizedBox(height: 8),
                              Text(questions[index],
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text(
                                'Response: ${responses[index]}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: getSeverityColor(severity)),
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
          ],
        ),
      ),
    );
  }

  Color getSeverityColor(String severity) {
    if (severity.toLowerCase().contains('red')) {
      return Colors.red;
    } else if (severity.toLowerCase().contains('yellow')) {
      return Colors.orange;
    } else if (severity.toLowerCase().contains('green')) {
      return Colors.green;
    }
    return Colors.grey; // Default color if none of the conditions match
  }

  String getSeverityText(String severity) {
    if (severity.toLowerCase().contains('red')) {
      return 'High Risk Zone: Requires immediate medical attention';
    } else if (severity.toLowerCase().contains('yellow')) {
      return 'Caution Zone: Monitor closely and follow care plan';
    } else if (severity.toLowerCase().contains('green')) {
      return 'Safe Zone: Continue with prescribed care routine';
    }
    return 'Unknown Status'; // Default if severity doesn't match
  }
}
