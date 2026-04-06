import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/patient.dart';

class PatientService {
  static final PatientService instance = PatientService._();
  PatientService._();

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Creates a patient record + their first visit + any initial allergies/medications
  /// all inside a single DB transaction.
  Future<Patient> createPatient({
    required Patient patient,
    required Visit firstVisit,
    List<Allergy> allergies = const [],
    List<Medication> medications = const [],
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.insert('patients', patient.toMap());
      await txn.insert('visits', firstVisit.toMap());
      for (final a in allergies) {
        await txn.insert('allergies', a.toMap());
      }
      for (final m in medications) {
        await txn.insert('medications', m.toMap());
      }
    });
    return patient;
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns all patients (demographics + status/diagnosis only, no related data).
  /// Sorted by full_name ascending.
  Future<List<Patient>> getAllPatients() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('patients', orderBy: 'full_name ASC');
    return rows.map((r) => Patient.fromMap(r)).toList();
  }

  /// Returns a patient with all related visits, allergies, and medications loaded.
  Future<Patient?> getFullPatient(String id) async {
    final db = await DatabaseHelper.instance.database;

    final patientRows = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    if (patientRows.isEmpty) return null;

    final visitRows = await db.query(
      'visits',
      where: 'patient_id = ?',
      whereArgs: [id],
      orderBy: 'visit_date ASC',
    );
    final allergyRows = await db.query(
      'allergies',
      where: 'patient_id = ?',
      whereArgs: [id],
      orderBy: 'created_at ASC',
    );
    final medicationRows = await db.query(
      'medications',
      where: 'patient_id = ?',
      whereArgs: [id],
      orderBy: 'created_at ASC',
    );

    return Patient.fromMap(
      patientRows.first,
      visits: visitRows.map(Visit.fromMap).toList(),
      allergies: allergyRows.map(Allergy.fromMap).toList(),
      medications: medicationRows.map(Medication.fromMap).toList(),
    );
  }

  // ── Visits ─────────────────────────────────────────────────────────────────

  /// Saves a new visit and updates the patient's current status and diagnosis.
  Future<Visit> addVisit(Visit visit) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.insert('visits', visit.toMap());
      await txn.update(
        'patients',
        {
          'status': visit.patientStatus.name,
          'primary_diagnosis': visit.diagnosis,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [visit.patientId],
      );
    });
    return visit;
  }

  // ── Analytics ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalytics() async {
    final db = await DatabaseHelper.instance.database;

    final totalResult = await db.rawQuery('SELECT COUNT(*) as c FROM patients');
    final total = totalResult.first['c'] as int;

    final femaleResult = await db.rawQuery(
        "SELECT COUNT(*) as c FROM patients WHERE gender = 'female'");
    final female = femaleResult.first['c'] as int;

    final maleResult = await db.rawQuery(
        "SELECT COUNT(*) as c FROM patients WHERE gender = 'male'");
    final male = maleResult.first['c'] as int;

    // Age group counts based on date_of_birth
    final now = DateTime.now().millisecondsSinceEpoch;
    final y18 = DateTime(DateTime.now().year - 18).millisecondsSinceEpoch;
    final y35 = DateTime(DateTime.now().year - 35).millisecondsSinceEpoch;
    final y50 = DateTime(DateTime.now().year - 50).millisecondsSinceEpoch;
    final y70 = DateTime(DateTime.now().year - 70).millisecondsSinceEpoch;

    Future<int> ageCount(int from, int to) async {
      final r = await db.rawQuery(
        'SELECT COUNT(*) as c FROM patients WHERE date_of_birth >= ? AND date_of_birth < ?',
        [from, to],
      );
      return r.first['c'] as int;
    }

    final age0to18   = await ageCount(y18, now);
    final age19to35  = await ageCount(y35, y18);
    final age36to50  = await ageCount(y50, y35);
    final age51to70  = await ageCount(y70, y50);
    final age70plus  = await ageCount(0, y70);

    final criticalResult = await db.rawQuery(
        "SELECT COUNT(*) as c FROM patients WHERE status = 'critical'");
    final critical = criticalResult.first['c'] as int;

    final stableResult = await db.rawQuery(
        "SELECT COUNT(*) as c FROM patients WHERE status = 'stable'");
    final stable = stableResult.first['c'] as int;

    return {
      'total': total,
      'female': female,
      'male': male,
      'age0to18': age0to18,
      'age19to35': age19to35,
      'age36to50': age36to50,
      'age51to70': age51to70,
      'age70plus': age70plus,
      'critical': critical,
      'stable': stable,
    };
  }

  // ── Allergies ──────────────────────────────────────────────────────────────

  Future<Allergy> addAllergy(Allergy allergy) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('allergies', allergy.toMap());
    return allergy;
  }

  Future<void> updateAllergyStatus(String id, AllergyStatus status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'allergies',
      {'status': status.name, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Allergy>> getAllergiesForPatient(String patientId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'allergies',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at ASC',
    );
    return rows.map(Allergy.fromMap).toList();
  }

  // ── Medications ────────────────────────────────────────────────────────────

  Future<Medication> addMedication(Medication medication) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('medications', medication.toMap());
    return medication;
  }

  Future<List<Medication>> getMedicationsForPatient(String patientId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'medications',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at ASC',
    );
    return rows.map(Medication.fromMap).toList();
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deletePatient(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String generateId() => const Uuid().v4();
}
