import 'package:flutter/material.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum PatientStatus { stable, critical, observation }

enum Gender { male, female, other }

enum AllergySeverity { mild, moderate, critical }

enum AllergyStatus { active, resolved }

enum MedicationStatus { active, completed, expired, discontinued }

// ─── Visit ───────────────────────────────────────────────────────────────────

class Visit {
  final String id;
  final String patientId;
  final String recordedBy;
  final DateTime visitDate;
  final String? chiefComplaint;
  final String diagnosis;
  final String notes;
  final int heartRate;
  final double temperature;
  final String bloodPressure;
  final double weight;
  final PatientStatus patientStatus;

  const Visit({
    required this.id,
    required this.patientId,
    required this.recordedBy,
    required this.visitDate,
    this.chiefComplaint,
    required this.diagnosis,
    required this.notes,
    required this.heartRate,
    required this.temperature,
    required this.bloodPressure,
    required this.weight,
    required this.patientStatus,
  });

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[visitDate.month - 1]} ${visitDate.day}, ${visitDate.year}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'recorded_by': recordedBy,
        'visit_date': visitDate.millisecondsSinceEpoch,
        'chief_complaint': chiefComplaint,
        'diagnosis': diagnosis,
        'notes': notes,
        'heart_rate': heartRate,
        'temperature': temperature,
        'blood_pressure': bloodPressure,
        'weight': weight,
        'patient_status': patientStatus.name,
      };

  factory Visit.fromMap(Map<String, dynamic> map) => Visit(
        id: map['id'] as String,
        patientId: map['patient_id'] as String,
        recordedBy: map['recorded_by'] as String,
        visitDate: DateTime.fromMillisecondsSinceEpoch(map['visit_date'] as int),
        chiefComplaint: map['chief_complaint'] as String?,
        diagnosis: map['diagnosis'] as String,
        notes: map['notes'] as String,
        heartRate: map['heart_rate'] as int,
        temperature: (map['temperature'] as num).toDouble(),
        bloodPressure: map['blood_pressure'] as String,
        weight: (map['weight'] as num).toDouble(),
        patientStatus: PatientStatus.values.firstWhere(
          (e) => e.name == map['patient_status'],
          orElse: () => PatientStatus.stable,
        ),
      );
}

// ─── Allergy ─────────────────────────────────────────────────────────────────

class Allergy {
  final String id;
  final String patientId;
  final String allergenName;
  final AllergySeverity severity;
  final String? reactionDescription;
  final AllergyStatus status;
  final String recordedBy;
  final DateTime createdAt;

  const Allergy({
    required this.id,
    required this.patientId,
    required this.allergenName,
    required this.severity,
    this.reactionDescription,
    required this.status,
    required this.recordedBy,
    required this.createdAt,
  });

  Allergy copyWith({AllergyStatus? status}) => Allergy(
        id: id,
        patientId: patientId,
        allergenName: allergenName,
        severity: severity,
        reactionDescription: reactionDescription,
        status: status ?? this.status,
        recordedBy: recordedBy,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'allergen_name': allergenName,
        'severity': severity.name,
        'reaction_description': reactionDescription,
        'status': status.name,
        'recorded_by': recordedBy,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

  factory Allergy.fromMap(Map<String, dynamic> map) => Allergy(
        id: map['id'] as String,
        patientId: map['patient_id'] as String,
        allergenName: map['allergen_name'] as String,
        severity: AllergySeverity.values.firstWhere(
          (e) => e.name == map['severity'],
          orElse: () => AllergySeverity.moderate,
        ),
        reactionDescription: map['reaction_description'] as String?,
        status: AllergyStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => AllergyStatus.active,
        ),
        recordedBy: map['recorded_by'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );
}

// ─── Medication ───────────────────────────────────────────────────────────────

class Medication {
  final String id;
  final String patientId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final MedicationStatus status;
  final String prescribedBy;
  final String? notes;

  const Medication({
    required this.id,
    required this.patientId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.prescribedBy,
    this.notes,
  });

  Medication copyWith({MedicationStatus? status, DateTime? endDate}) => Medication(
        id: id,
        patientId: patientId,
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        prescribedBy: prescribedBy,
        notes: notes,
      );

  String get formattedStartDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'patient_id': patientId,
        'medication_name': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'start_date': startDate.millisecondsSinceEpoch,
        'end_date': endDate?.millisecondsSinceEpoch,
        'status': status.name,
        'prescribed_by': prescribedBy,
        'notes': notes,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
        id: map['id'] as String,
        patientId: map['patient_id'] as String,
        medicationName: map['medication_name'] as String,
        dosage: map['dosage'] as String,
        frequency: map['frequency'] as String,
        startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
        endDate: map['end_date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
            : null,
        status: MedicationStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => MedicationStatus.active,
        ),
        prescribedBy: map['prescribed_by'] as String,
        notes: map['notes'] as String?,
      );
}

// ─── Patient ─────────────────────────────────────────────────────────────────

class Patient {
  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String phone;
  final String bloodGroup;
  final PatientStatus status;
  final String primaryDiagnosis;
  final String createdBy;
  final DateTime createdAt;
  final List<Visit> visits;
  final List<Allergy> allergies;
  final List<Medication> medications;

  const Patient({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    required this.bloodGroup,
    required this.status,
    required this.primaryDiagnosis,
    required this.createdBy,
    required this.createdAt,
    this.visits = const [],
    this.allergies = const [],
    this.medications = const [],
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  int get age {
    final today = DateTime.now();
    int a = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      a--;
    }
    return a;
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  String get genderLabel {
    switch (gender) {
      case Gender.male:   return 'Male';
      case Gender.female: return 'Female';
      case Gender.other:  return 'Other';
    }
  }

  Color get avatarColor {
    const colors = [
      Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFF00695C),
      Color(0xFFC62828), Color(0xFF37474F), Color(0xFF0277BD),
      Color(0xFF2E7D32), Color(0xFF4A148C), Color(0xFF00838F),
      Color(0xFF6D4C41),
    ];
    final hash = fullName.codeUnits.fold(0, (sum, c) => sum + c);
    return colors[hash % colors.length];
  }

  Visit? get latestVisit =>
      visits.isNotEmpty ? visits.last : null;

  List<Allergy> get activeAllergies =>
      allergies.where((a) => a.status == AllergyStatus.active).toList();

  List<Allergy> get criticalActiveAllergies => allergies
      .where((a) =>
          a.severity == AllergySeverity.critical &&
          a.status == AllergyStatus.active)
      .toList();

  List<Medication> get activeMedications =>
      medications.where((m) => m.status == MedicationStatus.active).toList();

  // ── DB mapping ────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
        'gender': gender.name,
        'phone': phone,
        'blood_group': bloodGroup,
        'primary_diagnosis': primaryDiagnosis,
        'status': status.name,
        'created_by': createdBy,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

  factory Patient.fromMap(
    Map<String, dynamic> map, {
    List<Visit> visits = const [],
    List<Allergy> allergies = const [],
    List<Medication> medications = const [],
  }) =>
      Patient(
        id: map['id'] as String,
        fullName: map['full_name'] as String,
        dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['date_of_birth'] as int),
        gender: Gender.values.firstWhere(
          (e) => e.name == map['gender'],
          orElse: () => Gender.other,
        ),
        phone: map['phone'] as String,
        bloodGroup: map['blood_group'] as String,
        primaryDiagnosis: map['primary_diagnosis'] as String? ?? '',
        status: PatientStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => PatientStatus.stable,
        ),
        createdBy: map['created_by'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        visits: visits,
        allergies: allergies,
        medications: medications,
      );

  Patient copyWith({
    PatientStatus? status,
    String? primaryDiagnosis,
    List<Visit>? visits,
    List<Allergy>? allergies,
    List<Medication>? medications,
  }) =>
      Patient(
        id: id,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        bloodGroup: bloodGroup,
        status: status ?? this.status,
        primaryDiagnosis: primaryDiagnosis ?? this.primaryDiagnosis,
        createdBy: createdBy,
        createdAt: createdAt,
        visits: visits ?? this.visits,
        allergies: allergies ?? this.allergies,
        medications: medications ?? this.medications,
      );
}
