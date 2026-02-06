import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Wound Capture AI/severity_screen.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> saveReminderStatus(
      String woundType, TimeOfDay time, bool completed) async {
    if (userId.isEmpty) {
      print("User ID is empty. Cannot save reminder.");
      return;
    }

    try {
      final reminderRef = _firestore
          .collection('patients')
          .doc(userId)
          .collection('reminders')
          .doc(woundType);

      final currentTime = DateTime.now();
      final timeCompleted = completed ? currentTime.toIso8601String() : null;
      final isOverdue = time.hour * 60 + time.minute <
          currentTime.hour * 60 + currentTime.minute;

      print(
          "Saving reminder: $woundType at ${time.hour}:${time.minute}, Completed: $completed");

      await reminderRef.set({
        'woundType': woundType,
        'time': "${time.hour}:${time.minute}",
        'completed': completed,
        'timeCompleted': timeCompleted,
        'isOverdue': isOverdue,
      }, SetOptions(merge: true));

      print("Reminder successfully saved to Firestore!");
    } catch (e) {
      print("Error saving reminder: $e");
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  bool isWithinRange(int minutes) {
    final now = TimeOfDay.now();
    final nowInMinutes = now.hour * 60 + now.minute;
    final selfInMinutes = hour * 60 + minute;
    return (nowInMinutes - selfInMinutes).abs() <= minutes;
  }

  bool isOverdue() {
    final now = TimeOfDay.now();
    final nowInMinutes = now.hour * 60 + now.minute;
    final selfInMinutes = hour * 60 + minute;
    return nowInMinutes > selfInMinutes;
  }
}

// Enhanced Reminder class to support multiple wounds
class Reminder {
  final String woundType;
  final AlertLevel alertLevel;
  final DateTime assessmentDate;
  final String treatment;

  Reminder({
    required this.woundType,
    required this.alertLevel,
    required this.assessmentDate,
    required this.treatment,
  });

  factory Reminder.fromFirestore(Map<String, dynamic> data) {
    AlertLevel getAlertLevel(String severity) {
      if (severity.toLowerCase().contains('red')) {
        return AlertLevel.red;
      } else if (severity.toLowerCase().contains('yellow')) {
        return AlertLevel.yellow;
      } else if (severity.toLowerCase().contains('green')) {
        return AlertLevel.green;
      }
      return AlertLevel.yellow; // Default value if none of the conditions match
    }

    return Reminder(
      woundType: data['woundType'] ?? 'Unknown',
      alertLevel: getAlertLevel(data['severity'] ?? 'Unknown'),
      assessmentDate:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      treatment: 'Based on latest assessment',
    );
  }
}

// Extended AlertLevelHelper with wound-specific schedules
// Change from static field to static getter
class AlertLevelHelper {
  static Map<AlertLevel, Map<String, dynamic>> get levelDetails => {
        AlertLevel.green: {
          'color': Colors.green,
          'text': 'Healing Well',
          'severity': 1,
          'scheduleInterval': 12, // hours
        },
        AlertLevel.yellow: {
          'color': Colors.orange,
          'text': 'Monitor Closely',
          'severity': 2,
          'scheduleInterval': 8, // hours
        },
        AlertLevel.red: {
          'color': Colors.red,
          'text': 'Seek Medical Help',
          'severity': 3,
          'scheduleInterval': 6, // hours
        }
      };

  static Map<String, List<String>> woundTypeRecommendations = {
    'diabetic wound': [
      'Monitor blood glucose levels regularly',
      'Maintain proper foot hygiene',
      'Use appropriate offloading devices',
      'Check for any signs of infection daily',
      'Keep wound area clean and dry',
    ],
    'pressure wound': [
      'Reposition every 2 hours',
      'Use pressure-relieving mattress',
      'Maintain proper nutrition',
      'Keep skin clean and moisturized',
      'Monitor wound edges for changes',
    ],
    'venous wound': [
      'Elevate the legs to improve circulation',
      'Wear compression stockings as prescribed',
      'Keep the wound clean and dry',
      'Monitor for signs of infection',
      'Follow a balanced diet to promote healing',
    ],
  };
  static List<String> getRecommendations(String woundType) {
    return [
      'Keep the wound clean and dry',
      'Monitor for signs of infection',
      'Document changes in wound appearance',
      ...(woundTypeRecommendations[woundType.toLowerCase()] ??
          ['Consult healthcare provider for specific treatment plan'])
    ];
  }

  static List<Map<String, dynamic>> generateSchedule(AlertLevel level) {
    final interval = levelDetails[level]!['scheduleInterval'] as int;
    final times = <Map<String, dynamic>>[];

    for (var hour = 6; hour < 22; hour += interval) {
      times.add({
        'time': TimeOfDay(hour: hour, minute: 0),
        'completed': false,
      });
    }

    return times;
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Reminder> currentReminders = [];
  bool isLoading = true;
  String? errorMessage;
  String userId = '';
  Map<String, bool> expandedWounds = {};

  // Add map to track reminder completion status
  Map<String, Map<TimeOfDay, bool>> reminderStatus = {};

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      setState(() {
        errorMessage = 'No user logged in';
        isLoading = false;
      });
    } else {
      fetchLatestAssessments();
    }
  }

  Future<void> fetchLatestAssessments() async {
    try {
      final QuerySnapshot assessmentSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(userId)
          .collection('assessments')
          .orderBy('timestamp', descending: true)
          .get();

      if (assessmentSnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'No assessments found';
          isLoading = false;
        });
        return;
      }

      // Group assessments by wound type and get latest for each
      Map<String, Reminder> latestByType = {};

      for (var doc in assessmentSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final woundType = data['woundType'] as String;

        if (!latestByType.containsKey(woundType)) {
          latestByType[woundType] = Reminder.fromFirestore(data);
          expandedWounds[woundType] = false; // Initialize expansion state
        }
      }

      setState(() {
        currentReminders = latestByType.values.toList();
        isLoading = false;
        // Set first wound as expanded if multiple wounds exist
        if (currentReminders.isNotEmpty) {
          expandedWounds[currentReminders.first.woundType] = true;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching assessments: $e';
        isLoading = false;
      });
    }
  }

// Update reminder status method
  void updateReminderStatus(String label, TimeOfDay time, bool value) {
    setState(() {
      if (!reminderStatus.containsKey(label)) {
        reminderStatus[label] = {};
      }
      reminderStatus[label]![time] = value;
    });
    ReminderService().saveReminderStatus(label, time, value);
  }

  // Check if reminder is completed
  bool isReminderCompleted(String label, TimeOfDay time) {
    return reminderStatus[label]?[time] ?? false;
  }

  Widget _buildWoundCard(Reminder reminder) {
    final isExpanded = expandedWounds[reminder.woundType] ?? false;
    final recommendations =
        AlertLevelHelper.getRecommendations(reminder.woundType.split(' (')[0]);

    return Card(
      margin: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 8,
      ), // Remove top margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: Text(
              reminder.woundType.split(' (')[0],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7165D6),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAlertBadge(reminder.alertLevel),
                if (currentReminders.length > 1)
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Color(0xFF7165D6),
                    ),
                    onPressed: () {
                      setState(() {
                        expandedWounds[reminder.woundType] = !isExpanded;
                      });
                    },
                  ),
              ],
            ),
          ),
          if (isExpanded || currentReminders.length == 1)
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Treatment Plan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recommendations.map((recommendation) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: Colors.greenAccent,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      recommendation,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildReminderSchedule(reminder),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
      String label, TimeOfDay time, bool defaultCompleted) {
    final isOverdue = time.isOverdue();
    final isCompleted = isReminderCompleted(label, time);

    return Row(
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: isCompleted,
            onChanged: time.isWithinRange(30)
                ? (value) {
                    updateReminderStatus(label, time, value ?? false);
                    ReminderService()
                        .saveReminderStatus(label, time, value ?? false);
                  }
                : null,
            activeColor: Color(0xFF7165D6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isOverdue && !isCompleted
                      ? Colors.red
                      : (time.isWithinRange(30) ? Colors.black : Colors.grey),
                ),
              ),
              if (isOverdue && !isCompleted)
                GestureDetector(
                  onTap: () => _showOverdueDialog(label, time),
                  child: Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Overdue',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Build alert badge widget
  Widget _buildAlertBadge(AlertLevel level) {
    final levelInfo = AlertLevelHelper.levelDetails[level]!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: levelInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: levelInfo['color']),
      ),
      child: Text(
        levelInfo['text'],
        style: TextStyle(
          color: levelInfo['color'],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Show overdue dialog
  void _showOverdueDialog(String label, TimeOfDay time) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Overdue Reminder'),
          content: Text(
            label == 'Change Gauze'
                ? 'Have you changed your Gauze?'
                : 'Have you taken your required medicine?',
          ),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Yes, I did it'),
              onPressed: () {
                Navigator.of(context).pop();
                updateReminderStatus(label, time, true);
                _showConfirmationDialog(label);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(String label) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thank you for the update!'),
            content: Text(
              label == 'Change Gauze'
                  ? 'Don’t forget to change the gauze on time in the future.'
                  : 'Don’t forget to take your medicine on time in the future.',
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _buildReminderSchedule(Reminder reminder) {
    final schedule = AlertLevelHelper.generateSchedule(reminder.alertLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Care Schedule',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF444444),
          ),
        ),
        SizedBox(height: 12),
        ...schedule.map((time) {
          final timeOfDay = time['time'] as TimeOfDay;
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF7165D6).withOpacity(0.1),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: Color(0xFF7165D6),
                      ),
                      SizedBox(width: 8),
                      Text(
                        timeOfDay.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7165D6),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildReminderItem(
                        'Change Gauze',
                        timeOfDay,
                        time['completed'] as bool,
                      ),
                      Divider(height: 16),
                      _buildReminderItem(
                        'Take Medicine',
                        timeOfDay,
                        time['completed'] as bool,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Color(0xFF7165D6).withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7165D6),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete wound assessment to see your treatment plan and reminders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Color(0xFF7165D6),
            padding: EdgeInsets.only(
              top: 40,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reminders",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                if (currentReminders.length > 1)
                  Text(
                    "${currentReminders.length} Wounds",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7165D6),
                    ),
                  )
                : currentReminders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 15),
                        itemCount: currentReminders.length,
                        itemBuilder: (context, index) {
                          return _buildWoundCard(currentReminders[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
