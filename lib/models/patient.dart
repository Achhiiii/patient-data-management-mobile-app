import 'package:flutter/material.dart';

enum PatientStatus { stable, critical, observation }

enum Gender { male, female, other }

class VitalSigns {
  final String heartRate;
  final String bloodPressure;
  final String weight;
  final String bloodGroup;
  final String temperature;

  const VitalSigns({
    required this.heartRate,
    required this.bloodPressure,
    required this.weight,
    required this.bloodGroup,
    required this.temperature,
  });
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;

  const Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
  });
}

class Patient {
  final String id;
  final String fullName;
  final int age;
  final Gender gender;
  final String phone;
  final PatientStatus status;
  final String primaryDiagnosis;
  final String medicalHistory;
  final List<String> allergies;
  final List<Medication> medications;
  final VitalSigns vitalSigns;
  final String lastVisit;
  final int totalVisits;
  final Color avatarColor;

  const Patient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.status,
    required this.primaryDiagnosis,
    required this.medicalHistory,
    required this.allergies,
    required this.medications,
    required this.vitalSigns,
    required this.lastVisit,
    required this.totalVisits,
    required this.avatarColor,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String get genderLabel {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

// ─── Placeholder Data ───────────────────────────────────────────────────────

final List<Patient> placeholderPatients = [
  Patient(
    id: 'P-00124',
    fullName: 'John Doe',
    age: 45,
    gender: Gender.male,
    phone: '+256 700 123 456',
    status: PatientStatus.stable,
    primaryDiagnosis: 'Hypertension',
    medicalHistory:
        'Patient has a long history of hypertension managed with medication. '
        'Previous hospitalization in 2021 for hypertensive crisis. '
        'No history of stroke or cardiac events.',
    allergies: ['Penicillin', 'Sulfa Drugs'],
    medications: [
      Medication(name: 'Lisinopril', dosage: '10mg', frequency: 'Once daily'),
      Medication(name: 'Amlodipine', dosage: '5mg', frequency: 'Once daily'),
    ],
    vitalSigns: VitalSigns(
      heartRate: '72 bpm',
      bloodPressure: '138/88 mmHg',
      weight: '82 kg',
      bloodGroup: 'O+',
      temperature: '36.8°C',
    ),
    lastVisit: 'Jun 14, 2025',
    totalVisits: 12,
    avatarColor: Color(0xFF1565C0),
  ),
  Patient(
    id: 'P-00312',
    fullName: 'Sarah Jenkins',
    age: 32,
    gender: Gender.female,
    phone: '+256 701 654 321',
    status: PatientStatus.stable,
    primaryDiagnosis: 'Type 2 Diabetes Mellitus',
    medicalHistory:
        'Diagnosed with T2DM three years ago. Currently on oral hypoglycemic agents. '
        'Regular monitoring of HbA1c every three months. No diabetic complications noted.',
    allergies: ['Metformin (GI intolerance)'],
    medications: [
      Medication(name: 'Glibenclamide', dosage: '5mg', frequency: 'Twice daily'),
      Medication(name: 'Metformin XR', dosage: '500mg', frequency: 'Once daily with dinner'),
    ],
    vitalSigns: VitalSigns(
      heartRate: '80 bpm',
      bloodPressure: '120/78 mmHg',
      weight: '68 kg',
      bloodGroup: 'A+',
      temperature: '37.0°C',
    ),
    lastVisit: 'Jun 10, 2025',
    totalVisits: 8,
    avatarColor: Color(0xFF6A1B9A),
  ),
  Patient(
    id: 'P-00456',
    fullName: 'Michael Chen',
    age: 58,
    gender: Gender.male,
    phone: '+256 703 987 654',
    status: PatientStatus.observation,
    primaryDiagnosis: 'Acute Bronchitis',
    medicalHistory:
        'Presented with persistent cough and mild fever for 10 days. '
        'History of seasonal asthma since childhood, managed with inhalers. '
        'Non-smoker. No recent travel history.',
    allergies: ['Aspirin', 'NSAIDs'],
    medications: [
      Medication(name: 'Salbutamol Inhaler', dosage: '100mcg', frequency: 'PRN'),
      Medication(name: 'Amoxicillin', dosage: '500mg', frequency: 'Three times daily for 7 days'),
    ],
    vitalSigns: VitalSigns(
      heartRate: '88 bpm',
      bloodPressure: '130/82 mmHg',
      weight: '75 kg',
      bloodGroup: 'B+',
      temperature: '37.9°C',
    ),
    lastVisit: 'Jun 15, 2025',
    totalVisits: 4,
    avatarColor: Color(0xFF00695C),
  ),
  Patient(
    id: 'P-00521',
    fullName: 'Elena Rodriguez',
    age: 27,
    gender: Gender.female,
    phone: '+256 705 321 987',
    status: PatientStatus.stable,
    primaryDiagnosis: 'Iron Deficiency Anaemia',
    medicalHistory:
        'Presenting with fatigue, pallor, and exertional dyspnea. '
        'Confirmed iron deficiency anaemia on CBC. Dietary history reveals low red meat intake.',
    allergies: [],
    medications: [
      Medication(name: 'Ferrous Sulfate', dosage: '200mg', frequency: 'Twice daily'),
      Medication(name: 'Vitamin C', dosage: '500mg', frequency: 'Once daily'),
    ],
    vitalSigns: VitalSigns(
      heartRate: '92 bpm',
      bloodPressure: '110/70 mmHg',
      weight: '55 kg',
      bloodGroup: 'AB-',
      temperature: '36.5°C',
    ),
    lastVisit: 'Jun 8, 2025',
    totalVisits: 3,
    avatarColor: Color(0xFFC62828),
  ),
  Patient(
    id: 'P-00634',
    fullName: 'David Wilson',
    age: 71,
    gender: Gender.male,
    phone: '+256 707 246 801',
    status: PatientStatus.critical,
    primaryDiagnosis: 'Acute Myocardial Infarction',
    medicalHistory:
        'Admitted via emergency with severe chest pain radiating to the left arm. '
        'ECG confirmed ST-elevation MI. Known history of hyperlipidemia and smoking (40 pack-years). '
        'Previous CABG in 2018.',
    allergies: ['Heparin (HIT)', 'Clopidogrel'],
    medications: [
      Medication(name: 'Aspirin', dosage: '75mg', frequency: 'Once daily'),
      Medication(name: 'Atorvastatin', dosage: '80mg', frequency: 'Once daily at night'),
      Medication(name: 'Bisoprolol', dosage: '2.5mg', frequency: 'Once daily'),
    ],
    vitalSigns: VitalSigns(
      heartRate: '104 bpm',
      bloodPressure: '160/95 mmHg',
      weight: '91 kg',
      bloodGroup: 'O-',
      temperature: '37.4°C',
    ),
    lastVisit: 'Jun 16, 2025',
    totalVisits: 21,
    avatarColor: Color(0xFF37474F),
  ),
];
