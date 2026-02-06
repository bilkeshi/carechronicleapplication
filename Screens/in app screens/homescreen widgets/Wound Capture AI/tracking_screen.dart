import 'dart:io';

import 'package:care_chronicle_app/Screens/in%20app%20screens/homescreen%20widgets/Wound%20Capture%20AI/saved_assessment.dart';
import 'package:care_chronicle_app/widgets/navbar_roots.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'severity_screen.dart';

class Assessment {
  final String woundType;
  final AlertLevel severity;
  final List<AlertLevel> responses;
  final List<Question> questions;
  final String? imagePath;

  Assessment({
    required this.woundType,
    required this.severity,
    required this.responses,
    required this.questions,
    this.imagePath,
  });
}

class TrackingScreen extends StatefulWidget {
  final List<Assessment> assessments;

  TrackingScreen({required this.assessments});
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> assessments = [];
  Map<String, int> woundTypeCount = {};
  List<Map<String, dynamic>> recentAssessments = [];
  List<Map<String, dynamic>> oldAssessments = [];

  // Define the woundSeverityMap here
  Map<String, Map<String, int>> woundSeverityMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadAssessmentsFromFirestore();
  }

  Future<void> loadAssessmentsFromFirestore() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    var snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(userId)
        .collection('assessments')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      assessments =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()!}).toList();

      // Split assessments into recent and old
      final now = DateTime.now();
      recentAssessments = [];
      oldAssessments = [];

      for (var assessment in assessments) {
        final timestamp = (assessment['timestamp'] as Timestamp).toDate();
        final difference = now.difference(timestamp);

        if (difference.inDays <= 7) {
          recentAssessments.add(assessment);
        } else {
          oldAssessments.add(assessment);
        }
      }

      // Reset woundSeverityMap
      woundSeverityMap = {};

      // Calculate wound type distribution and severity map
      for (var assessment in assessments) {
        String type = assessment['woundType'] ?? 'Unknown';
        String severity = assessment['severity'] ?? 'Unknown';

        // Initialize wound type map if not already initialized
        if (!woundSeverityMap.containsKey(type)) {
          woundSeverityMap[type] = {};
        }

        // Increment the severity count for this wound type
        woundSeverityMap[type]?[severity] =
            (woundSeverityMap[type]?[severity] ?? 0) + 1;
      }
    });
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
      return 'High Risk Zone';
    } else if (severity.toLowerCase().contains('yellow')) {
      return 'Caution Zone';
    } else if (severity.toLowerCase().contains('green')) {
      return 'Safe Zone';
    }
    return 'Unknown Status'; // Default if severity doesn't match
  }

  String getSeverityDescription(String severity) {
    if (severity.toLowerCase().contains('red')) {
      return 'Requires immediate medical attention';
    } else if (severity.toLowerCase().contains('yellow')) {
      return 'Monitor closely and follow care plan';
    } else if (severity.toLowerCase().contains('green')) {
      return 'Continue with prescribed care routine';
    }
    return 'Status unavailable'; // Default if severity is unknown
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final timestamp = (assessment['timestamp'] as Timestamp).toDate();
    final severity = assessment['severity'] ?? 'Unknown';
    final imagePath = assessment['imagePath'];

    final severityColor = getSeverityColor(severity);
    final severityText = getSeverityText(severity);
    final severityDescription = getSeverityDescription(severity);
    final backgroundColor = severityColor.withOpacity(0.05);

    Widget buildImageWidget(String? path) {
      if (path == null || path.isEmpty) return Container();

      try {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          cacheWidth: 200,
          cacheHeight: 200,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading local image: $error');
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Image\nUnavailable',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } catch (e) {
        print('Exception while loading image: $e');
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.grey[400],
                size: 32,
              ),
              SizedBox(height: 4),
              Text(
                'Error\nLoading Image',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }
    }

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssessmentDetailScreen(
                assessmentId: assessment['id'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: backgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(timestamp),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('h:mm a').format(timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageWidth = imagePath != null ? 100.0 : 0.0;
                    final imageSpacing = imagePath != null ? 16.0 : 0.0;
                    final availableWidth =
                        constraints.maxWidth - imageWidth - imageSpacing;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imagePath != null && imagePath.isNotEmpty)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: buildImageWidget(imagePath),
                            ),
                          ),
                        if (imagePath != null) SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            width: availableWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assessment['woundType'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 12),
                                Wrap(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: severityColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: severityColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: severityColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            severityText,
                                            style: TextStyle(
                                              color: severityColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  severityDescription,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentList() {
    // Categorize assessments by wound type
    List<Map<String, dynamic>> venousWounds =
        assessments.where((a) => a['woundType'] == 'Venous Wound').toList();
    List<Map<String, dynamic>> diabeticWounds =
        assessments.where((a) => a['woundType'] == 'Diabetic Wound').toList();
    List<Map<String, dynamic>> pressureWounds =
        assessments.where((a) => a['woundType'] == 'Pressure Wound').toList();

    return assessments.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  "No assessments available",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        : ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Recent Assessments Section
              if (recentAssessments.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Recent Assessments',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
                ...recentAssessments.map(_buildAssessmentCard).toList(),
              ],

              // Divider for Previous Assessments
              if (oldAssessments.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                              Divider(thickness: 1, color: Colors.grey[300])),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Previous Assessments',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                      Expanded(
                          child:
                              Divider(thickness: 1, color: Colors.grey[300])),
                    ],
                  ),
                ),
                ...oldAssessments.map(_buildAssessmentCard).toList(),
              ],

              // Wound Type Categorization Section
              if (venousWounds.isNotEmpty) ...[
                _buildSectionHeader('Venous Wound'),
                ...venousWounds.map(_buildAssessmentCard).toList(),
              ],
              if (diabeticWounds.isNotEmpty) ...[
                _buildSectionHeader('Diabetic Wound'),
                ...diabeticWounds.map(_buildAssessmentCard).toList(),
              ],
              if (pressureWounds.isNotEmpty) ...[
                _buildSectionHeader('Pressure Wound'),
                ...pressureWounds.map(_buildAssessmentCard).toList(),
              ],
            ],
          );
  }

// Helper function for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildPieChart() {
    // Group assessments by wound type and date
    Map<String, List<Map<String, Map<String, int>>>> timeSeriesData = {};

    // Organize data by wound type and assessment date
    woundSeverityMap.forEach((woundType, severityMap) {
      if (!timeSeriesData.containsKey(woundType)) {
        timeSeriesData[woundType] = [];
      }
      timeSeriesData[woundType]?.add({DateTime.now().toString(): severityMap});
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Wound Severity Distribution',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7165D6),
              ),
            ),
            Text(
              'This chart shows the distribution of wound severity across the latest assessments. '
              'It provides insight into the overall healing status of wounds and helps monitor your progress over time.',
              style: TextStyle(
                fontSize: 12.2,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            Divider(height: 20),
            Text(
              'Track wound severity changes across multiple assessments',
              style: TextStyle(
                fontSize: 12.2,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ...timeSeriesData.entries.map((entry) {
              String woundType = entry.key;
              List<Map<String, Map<String, int>>> assessments = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$woundType',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...assessments.asMap().entries.map((assessment) {
                    int index = assessment.key;
                    var data = assessment.value;
                    String date = data.keys.first;
                    var severityMap = data.values.first;

                    return Column(
                      children: [
                        if (index > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    'Assessment ${index + 1}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              sections: _generatePieChartSections(severityMap),
                              centerSpaceColor: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(date))}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                  SizedBox(height: 32),
                ],
              );
            }).toList(),
            _buildLegendCard(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
      Map<String, int> severityMap) {
    List<PieChartSectionData> sections = [];
    int total = severityMap.values.reduce((a, b) => a + b);

    severityMap.forEach((severity, count) {
      double percentage = (count / total) * 100;
      sections.add(
        PieChartSectionData(
          color: getSeverityColor(severity),
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }

  Widget _buildLegendCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Green Zone:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Healing well. Monitor everyday for 30 days.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Yellow Zone:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Requires closer monitoring. If not healed in 14 days, notify healthcare providers.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Red Zone:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Immediate attention required. Please notify hospital or healthcare provider immediately.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavBarRoots()),
        );
        return false; // Prevents default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'CareWound Track',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFF7165D6),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                ),
                text: 'Assessments',
              ),
              Tab(
                icon: Icon(
                  Icons.pie_chart_outline,
                  color: Colors.white,
                ),
                text: 'Distribution',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAssessmentList(),
            _buildPieChart(),
          ],
        ),
      ),
    );
  }
}
