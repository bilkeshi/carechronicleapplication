import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String name;
  final DateTime dob;
  final String gender;
  final Map<String, dynamic> email;

  Patient(
      {required this.name,
      required this.dob,
      required this.gender,
      required this.email});

  factory Patient.fromFirestore(Map<String, dynamic> data) {
    return Patient(
      name: data['name'],
      dob: (data['dob'] as Timestamp).toDate(),
      gender: data['gender'],
      email: data['email'],
    );
  }
}

class Wound {
  final String type;
  final Timestamp assessmentDate;
  final Map<String, dynamic> woundSize;
  final String severity;
  final String responses;
  final DocumentReference patientId;
  final String? imageUrl;

  Wound({
    required this.type,
    required this.assessmentDate,
    required this.woundSize,
    required this.severity,
    required this.responses,
    required this.patientId,
    this.imageUrl,
  });

  factory Wound.fromFirestore(Map<String, dynamic> data) {
    return Wound(
      type: data['type'],
      assessmentDate: data['assessmentDate'],
      woundSize: data['woundSize'],
      severity: data['severity'],
      responses: data['responses'],
      patientId: data['patientId'],
      imageUrl: data['imageUrl'],
    );
  }
}

class Treatment {
  final DocumentReference woundId;
  final Timestamp treatmentDate;
  final String type;
  final String description;

  Treatment({
    required this.woundId,
    required this.treatmentDate,
    required this.type,
    required this.description,
  });

  factory Treatment.fromFirestore(Map<String, dynamic> data) {
    return Treatment(
      woundId: data['woundId'],
      treatmentDate: data['treatmentDate'],
      type: data['type'],
      description: data['description'],
    );
  }
}

class HealingProgress {
  final DocumentReference woundId;
  final Timestamp date;
  final double sizeReduction;
  final String notes;

  HealingProgress(
      {required this.woundId,
      required this.date,
      required this.sizeReduction,
      required this.notes});

  factory HealingProgress.fromFirestore(Map<String, dynamic> data) {
    return HealingProgress(
      woundId: data['woundId'],
      date: data['date'],
      sizeReduction: data['sizeReduction'],
      notes: data['notes'],
    );
  }
}
