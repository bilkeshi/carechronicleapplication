import 'package:care_chronicle_app/Screens/in%20app%20screens/homescreen%20widgets/Wound%20Capture%20AI/fulldetail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AlertLevel { green, yellow, red }

class Question {
  final String text;
  final List<String> options;
  final List<AlertLevel> alertLevels;

  Question({
    required this.text,
    required this.options,
    required this.alertLevels,
  });
}

class SeverityScreen extends StatefulWidget {
  final String woundType;
  final String imageUrl;
  final String imagePath;

  const SeverityScreen({
    Key? key,
    required this.woundType,
    required this.imagePath,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _SeverityScreenState createState() => _SeverityScreenState();
}

class _SeverityScreenState extends State<SeverityScreen> {
  int currentQuestionIndex = 0;
  List<AlertLevel> userResponses = [];
  late List<Question> questions;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    try {
      // Remove any confidence percentage from wound type
      String cleanWoundType = widget.woundType;
      questions = _getQuestionsForWoundType(cleanWoundType);

      if (questions.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'Unknown wound type: $cleanWoundType';
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error initializing assessment: ${e.toString()}';
      });
    }
  }

  List<Question> _getQuestionsForWoundType(String woundType) {
    switch (woundType) {
      case "Diabetic Wound":
        return [
          Question(
            text:
                'Is the ulcer site free from infection (no redness, pus, or increased warmth)?',
            options: ['Yes', 'No - Mild Symptoms', 'No - Severe Symptoms'],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text: 'How deep is the ulcer?',
            options: [
              'Shallow (superficial)',
              'Moderate (partially into dermis)',
              'Deep (through to muscle/bone)'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text: 'Is the ulcer healing or worsening in the last 7 days?',
            options: [
              'Healing well',
              'Slightly worsened',
              'Significantly worsened'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text:
                'Is there any presence of peripheral neuropathy (numbness or tingling)?',
            options: ['No', 'Yes - Mild', 'Yes - Severe'],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text:
                'Is there any evidence of systemic infection (fever, chills, increased heart rate)?',
            options: ['No', 'Yes - Some Symptoms', 'Yes - Multiple Symptoms'],
            alertLevels: [AlertLevel.green, AlertLevel.red, AlertLevel.red],
          ),
        ];

      case "Venous Wound":
        return [
          Question(
            text:
                'Is there any visible swelling or edema in the affected limb?',
            options: ['No swelling', 'Mild swelling', 'Severe swelling'],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text: 'How would you describe the ulcer\'s appearance?',
            options: [
              'Clean, shallow with granulation tissue visible',
              'Red and inflamed with some tissue breakdown',
              'Large, with necrotic tissue or heavy exudate'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text:
                'Are you experiencing any pain associated with the ulcer or surrounding area?',
            options: [
              'No pain or mild discomfort',
              'Moderate pain',
              'Severe pain or pain not relieved by medication'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text: 'Have you had any history of recurrent venous ulcers?',
            options: [
              'No',
              'Yes, but healing well',
              'Yes, with worsening symptoms'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text:
                'Are compression therapy and leg elevation being regularly applied?',
            options: [
              'Yes, consistently',
              'Occasionally',
              'No, or non-compliant'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
        ];

      case "Pressure Wound":
        return [
          Question(
            text: 'What is the current stage of the pressure ulcer?',
            options: [
              'Stage 1: Reddened, intact skin',
              'Stage 2: Partial thickness loss',
              'Stage 3/4: Full-thickness tissue loss'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text: 'What is your pain level?',
            options: [
              'No pain/mild discomfort',
              'Moderate pain',
              'Severe pain'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text: 'Is there any sign of infection (redness, warmth, drainage)?',
            options: [
              'No signs of infection',
              'Mild signs of infection',
              'Clear signs of infection present'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text: 'Is there any breakdown of surrounding skin?',
            options: [
              'No breakdown',
              'Minor breakdown',
              'Significant breakdown'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
          Question(
            text:
                'Is the ulcer receiving pressure relief (e.g., repositioning, support surfaces)?',
            options: [
              'Yes, consistently',
              'Occasionally',
              'No, or non-compliant'
            ],
            alertLevels: [AlertLevel.green, AlertLevel.yellow, AlertLevel.red],
          ),
        ];

      default:
        return []; // Empty list for unknown wound types
    }
  }

  AlertLevel calculateOverallAlertLevel() {
    int greenCount =
        userResponses.where((level) => level == AlertLevel.green).length;
    int redCount =
        userResponses.where((level) => level == AlertLevel.red).length;

    if (greenCount >= 3 && greenCount <= 5 && redCount == 0) {
      // If there are 3 to 5 green alerts and no red alerts
      return AlertLevel.green;
    } else if (redCount > 4) {
      // If there are any red alerts
      return AlertLevel.red;
    } else {
      // Otherwise, it's yellow
      return AlertLevel.yellow;
    }
  }

  void _handleResponse(int optionIndex) {
    setState(() {
      userResponses
          .add(questions[currentQuestionIndex].alertLevels[optionIndex]);

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        _showResultDialog();
      }
    });
  }

  Future<bool> _updateWoundRecord(String severityLevel,
      List<Map<String, dynamic>> assessmentResponses) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Authentication required');
      }

      // Get the most recent wound record for the current user
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wounds')
          .where('patientId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Create a new wound record if none exists
        await FirebaseFirestore.instance.collection('wounds').add({
          'patientId': user.uid,
          'woundType': widget.woundType,
          'imageUrl': widget.imageUrl,
          'imagePath': widget.imagePath,
          'severityLevel': severityLevel,
          'assessmentResponses': assessmentResponses,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastAssessmentDate': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing record
        final docRef = querySnapshot.docs.first.reference;
        await docRef.update({
          'severityLevel': severityLevel,
          'assessmentResponses': assessmentResponses,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastAssessmentDate': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      String errorMessage = 'Failed to save assessment data';

      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            errorMessage = 'You don\'t have permission to update this record';
            break;
          case 'not-found':
            errorMessage = 'The wound record could not be found';
            break;
          case 'unavailable':
            errorMessage =
                'Service temporarily unavailable. Please try again later';
            break;
          default:
            errorMessage = 'Error updating record: ${e.message}';
        }
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Save Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(errorMessage),
                  SizedBox(height: 16),
                  Text(
                    'Would you like to retry?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Return to the previous screen
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Retry the update
                    _updateWoundRecord(severityLevel, assessmentResponses);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7165D6),
                  ),
                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
      return false;
    }
  }

  void _showResultDialog() async {
    AlertLevel overallLevel = calculateOverallAlertLevel();
    String recommendation;
    Color color;
    String severityLevel;

    switch (overallLevel) {
      case AlertLevel.green:
        recommendation =
            'Green Zone: Healing well. Monitor everyday for 30 days.';
        severityLevel = 'Low Risk';
        color = Colors.green;
        break;
      case AlertLevel.yellow:
        recommendation =
            'Yellow Zone: Requires closer monitoring. If not healed in 14 days, notify healthcare providers.';
        severityLevel = 'Medium Risk';
        color = Colors.orange;
        break;
      case AlertLevel.red:
        recommendation =
            'Red Zone: Immediate attention required. Please notify hospital or health provider immediately.';
        severityLevel = 'High Risk';
        color = Colors.red;
        break;
    }

    // Create assessment data to store
    List<Map<String, dynamic>> assessmentResponses = [];
    for (int i = 0; i < questions.length; i++) {
      assessmentResponses.add({
        'question': questions[i].text,
        'selectedOption': questions[i].options[userResponses[i].index],
        'alertLevel': userResponses[i].toString().split('.').last,
      });
    }

    // Update Firestore document
    _updateWoundRecord(severityLevel, assessmentResponses);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7165D6)),
          ),
        );
      },
    );

    // Attempt to update the wound record
    bool updateSuccess =
        await _updateWoundRecord(severityLevel, assessmentResponses);

    // Dismiss loading dialog
    if (mounted) Navigator.of(context).pop();

    // Only show results dialog if update was successful
    if (updateSuccess && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Assessment Result'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    recommendation,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('View Full Details'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullDetailScreen(
                        woundType: widget.woundType,
                        responses: userResponses,
                        questions: questions,
                        alertLevel: overallLevel,
                        imagePath: widget.imagePath, // Pass imagePath
                        imageUrl: widget.imageUrl, // Pass imageUrl
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
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
        child: Padding(
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
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7165D6)),
              ),
              SizedBox(height: 24),
              Text(
                'Question ${currentQuestionIndex + 1}/${questions.length}:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                questions[currentQuestionIndex].text,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              ...questions[currentQuestionIndex].options.asMap().entries.map(
                (entry) {
                  int index = entry.key;
                  String option = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _handleResponse(index),
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF7165D6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Color(0xFF7165D6)),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
