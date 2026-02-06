import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'severity_screen.dart';
import 'tracking_screen.dart';

class AssessmentProvider extends ChangeNotifier {
  List<Assessment> _assessments = [];
  bool isInitialized = false;

  List<Assessment> get assessments => isInitialized ? _assessments : [];

  Future<void> loadAssessmentsFromFirestore() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(userId)
          .collection('assessments')
          .orderBy('timestamp', descending: true)
          .get();

      _assessments = snapshot.docs
          .map((doc) => Assessment(
                woundType: doc['woundType'] ?? 'Unknown',
                severity:
                    _parseAlertLevel(doc['severity'] ?? 'AlertLevel.green'),
                responses: (doc['responses'] as List<dynamic>?)
                        ?.map((e) => _parseAlertLevel(e))
                        .toList() ??
                    [],
                questions: (doc['questions'] as List<dynamic>?)
                        ?.map((text) =>
                            Question(text: text, options: [], alertLevels: []))
                        .toList() ??
                    [],
                imagePath: doc['imagePath'] ?? '',
              ))
          .toList();

      isInitialized = true;
      print("Provider loaded ${_assessments.length} assessments"); // Debugging

      notifyListeners();
    } catch (e) {
      print('Error loading assessments: $e');
    }
  }

  static AlertLevel _parseAlertLevel(String value) {
    switch (value) {
      case 'AlertLevel.green':
        return AlertLevel.green;
      case 'AlertLevel.yellow':
        return AlertLevel.yellow;
      case 'AlertLevel.red':
        return AlertLevel.red;
      default:
        return AlertLevel.green;
    }
  }

  void setAssessments(List<Assessment> list) {
    _assessments = list; // Replace instead of adding
    notifyListeners();
  }

  Future<void> saveAssessmentsToFirestore(List<Assessment> assessments) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      for (var assessment in assessments) {
        print("Saving assessment: ${assessment.woundType}"); // Debugging

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(userId)
            .collection('assessments')
            .add({
          'woundType': assessment.woundType,
          'severity': assessment.severity.toString(),
          'responses': assessment.responses.map((e) => e.toString()).toList(),
          'questions': assessment.questions.map((q) => q.text).toList(),
          'imagePath': assessment.imagePath ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      print("All assessments saved successfully!");
    } catch (e) {
      print('Error saving assessments: $e');
    }
  }

  void initialize() {
    if (!isInitialized) {
      loadAssessmentsFromFirestore();
    }
  }

  // Helper method to merge new assessments with existing ones
  Future<void> addNewAssessments(List<Assessment> newAssessments) async {
    await saveAssessmentsToFirestore(newAssessments);
  }
}
