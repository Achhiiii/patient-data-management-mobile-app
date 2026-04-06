import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/patient.dart';
import '../../services/patient_service.dart';

// ── Local draft models (form-only, not persisted until Save) ─────────────────

class _AllergyDraft {
  String name;
  AllergySeverity severity;
  String reaction;
  _AllergyDraft({
    this.name = '',
    this.severity = AllergySeverity.moderate,
    this.reaction = '',
  });
}

class _MedicationDraft {
  String name;
  String dosage;
  String frequency;
  DateTime startDate;
  DateTime? endDate;
  bool hasEndDate;
  String notes;
  _MedicationDraft({
    this.name = '',
    this.dosage = '',
    this.frequency = '',
    DateTime? startDate,
    this.endDate,
    this.hasEndDate = false,
    this.notes = '',
  }) : startDate = startDate ?? DateTime.now();
}

// ── Screen ───────────────────────────────────────────────────────────────────

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  // ── Demographics ──────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _dateOfBirth;

  // ── Vitals ─────────────────────────────────────────────────────────────────
  double _heartRate = 72;
  String? _selectedTemperature;
  final _bloodPressureController = TextEditingController(text: '120/80');
  final _weightController = TextEditingController();

  // ── Visit details ──────────────────────────────────────────────────────────
  final _reasonController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  PatientStatus _patientStatus = PatientStatus.stable;

  // ── Allergies ──────────────────────────────────────────────────────────────
  final List<_AllergyDraft> _allergies = [];
  bool _showAllergyForm = false;
  final _allergyNameCtrl = TextEditingController();
  final _allergyReactionCtrl = TextEditingController();
  AllergySeverity _allergySeverity = AllergySeverity.moderate;
  String? _allergyFormError;

  // ── Medications ────────────────────────────────────────────────────────────
  final List<_MedicationDraft> _medications = [];
  bool _showMedicationForm = false;
  final _medNameCtrl = TextEditingController();
  final _medDosageCtrl = TextEditingController();
  final _medFrequencyCtrl = TextEditingController();
  DateTime _medStartDate = DateTime.now();
  DateTime? _medEndDate;
  bool _medHasEndDate = false;
  final _medNotesCtrl = TextEditingController();
  String? _medFormError;

  // ── Save state ─────────────────────────────────────────────────────────────
  bool _isSaving = false;
  String? _errorMessage;

  // ── Required field tracking ───────────────────────────────────────────────
  int get _completedFields {
    int c = 0;
    if (_nameController.text.isNotEmpty) c++;
    if (_dateOfBirth != null) c++;
    if (_selectedGender != null) c++;
    if (_phoneController.text.isNotEmpty) c++;
    if (_selectedBloodGroup != null) c++;
    if (_diagnosisController.text.isNotEmpty) c++;
    if (_bloodPressureController.text.isNotEmpty) c++;
    return c;
  }

  static const int _totalFields = 7;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bloodPressureController.dispose();
    _weightController.dispose();
    _reasonController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _allergyNameCtrl.dispose();
    _allergyReactionCtrl.dispose();
    _medNameCtrl.dispose();
    _medDosageCtrl.dispose();
    _medFrequencyCtrl.dispose();
    _medNotesCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickMedDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _medStartDate : (_medEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) { _medStartDate = picked; }
        else { _medEndDate = picked; }
      });
    }
  }

  double _tempToDouble(String? temp) {
    if (temp == null) return 37.0;
    if (temp.contains('Hypothermia')) return 35.0;
    if (temp.contains('Normal')) return 37.0;
    if (temp.contains('Low Fever')) return 38.0;
    if (temp.contains('Moderate Fever')) return 39.0;
    if (temp.contains('High Fever')) return 40.0;
    return 37.0;
  }

  // ── Allergy form actions ────────────────────────────────────────────────────

  void _submitAllergyDraft() {
    if (_allergyNameCtrl.text.trim().isEmpty) {
      setState(() => _allergyFormError = 'Allergen name is required.');
      return;
    }
    setState(() {
      _allergies.add(_AllergyDraft(
        name: _allergyNameCtrl.text.trim(),
        severity: _allergySeverity,
        reaction: _allergyReactionCtrl.text.trim(),
      ));
      _allergyNameCtrl.clear();
      _allergyReactionCtrl.clear();
      _allergySeverity = AllergySeverity.moderate;
      _showAllergyForm = false;
      _allergyFormError = null;
    });
  }

  void _removeAllergy(int index) {
    setState(() => _allergies.removeAt(index));
  }

  // ── Medication form actions ─────────────────────────────────────────────────

  void _submitMedicationDraft() {
    if (_medNameCtrl.text.trim().isEmpty) {
      setState(() => _medFormError = 'Medication name is required.');
      return;
    }
    if (_medDosageCtrl.text.trim().isEmpty) {
      setState(() => _medFormError = 'Dosage is required.');
      return;
    }
    if (_medFrequencyCtrl.text.trim().isEmpty) {
      setState(() => _medFormError = 'Frequency is required.');
      return;
    }
    setState(() {
      _medications.add(_MedicationDraft(
        name: _medNameCtrl.text.trim(),
        dosage: _medDosageCtrl.text.trim(),
        frequency: _medFrequencyCtrl.text.trim(),
        startDate: _medStartDate,
        endDate: _medHasEndDate ? _medEndDate : null,
        hasEndDate: _medHasEndDate,
        notes: _medNotesCtrl.text.trim(),
      ));
      _medNameCtrl.clear();
      _medDosageCtrl.clear();
      _medFrequencyCtrl.clear();
      _medStartDate = DateTime.now();
      _medEndDate = null;
      _medHasEndDate = false;
      _medNotesCtrl.clear();
      _showMedicationForm = false;
      _medFormError = null;
    });
  }

  void _removeMedication(int index) {
    setState(() => _medications.removeAt(index));
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _savePatient() async {
    // Validate open forms
    if (_showAllergyForm) {
      setState(() => _allergyFormError = 'Please add the allergy to the list or cancel.');
      return;
    }
    if (_showMedicationForm) {
      setState(() => _medFormError = 'Please add the prescription to the list or cancel.');
      return;
    }

    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Patient full name is required.');
      return;
    }
    if (_dateOfBirth == null) {
      setState(() => _errorMessage = 'Date of birth is required.');
      return;
    }
    if (_selectedGender == null) {
      setState(() => _errorMessage = 'Gender is required.');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Contact number is required.');
      return;
    }
    if (_selectedBloodGroup == null) {
      setState(() => _errorMessage = 'Blood group is required.');
      return;
    }
    if (_diagnosisController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Diagnosis is required for the initial visit.');
      return;
    }

    setState(() { _isSaving = true; _errorMessage = null; });

    try {
      const uuid = Uuid();
      final currentUser = AuthService.instance.currentUser!;
      final now = DateTime.now();
      final patientId = uuid.v4();

      final gender = Gender.values.firstWhere(
        (g) => g.name.toLowerCase() == _selectedGender!.toLowerCase(),
        orElse: () => Gender.other,
      );

      final patient = Patient(
        id: patientId,
        fullName: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: gender,
        phone: _phoneController.text.trim(),
        bloodGroup: _selectedBloodGroup!,
        status: _patientStatus,
        primaryDiagnosis: _diagnosisController.text.trim(),
        createdBy: currentUser.id,
        createdAt: now,
      );

      final firstVisit = Visit(
        id: uuid.v4(),
        patientId: patientId,
        recordedBy: currentUser.clinicalIdentifier,
        visitDate: now,
        chiefComplaint: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        notes: _notesController.text.trim(),
        heartRate: _heartRate.round(),
        temperature: _tempToDouble(_selectedTemperature),
        bloodPressure: _bloodPressureController.text.trim().isEmpty
            ? '120/80'
            : _bloodPressureController.text.trim(),
        weight: double.tryParse(_weightController.text) ?? 0.0,
        patientStatus: _patientStatus,
      );

      final allergies = _allergies.map((a) => Allergy(
        id: uuid.v4(),
        patientId: patientId,
        allergenName: a.name,
        severity: a.severity,
        reactionDescription: a.reaction.isEmpty ? null : a.reaction,
        status: AllergyStatus.active,
        recordedBy: currentUser.clinicalIdentifier,
        createdAt: now,
      )).toList();

      final medications = _medications.map((m) => Medication(
        id: uuid.v4(),
        patientId: patientId,
        medicationName: m.name,
        dosage: m.dosage,
        frequency: m.frequency,
        startDate: m.startDate,
        endDate: m.endDate,
        status: MedicationStatus.active,
        prescribedBy: currentUser.clinicalIdentifier,
        notes: m.notes.isEmpty ? null : m.notes,
      )).toList();

      await PatientService.instance.createPatient(
        patient: patient,
        firstVisit: firstVisit,
        allergies: allergies,
        medications: medications,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Failed to save patient. Please try again.';
        });
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildPageHeader(),
            const SizedBox(height: 8),
            _buildActiveSessionChip(),
            const SizedBox(height: 20),
            _buildValidationStatus(),
            const SizedBox(height: 24),
            _buildSectionLabel('Demographic Profile', Icons.person_outline_rounded),
            const SizedBox(height: 14),
            _buildDemographicSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Vital Signs', Icons.monitor_heart_outlined),
            const SizedBox(height: 14),
            _buildVitalsSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Visit Details', Icons.history_edu_rounded),
            const SizedBox(height: 14),
            _buildVisitDetailsSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Allergies', Icons.warning_amber_rounded),
            const SizedBox(height: 14),
            _buildAllergiesSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Prescriptions', Icons.medication_outlined),
            const SizedBox(height: 14),
            _buildMedicationsSection(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorBanner(_errorMessage!),
            ],
            const SizedBox(height: 32),
            GradientButton(
              label: _isSaving ? 'Saving...' : 'Save Patient Record',
              onPressed: _isSaving ? null : _savePatient,
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      leadingWidth: 40,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 18),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text('Clinical Precision', style: AppTextStyles.titleMd.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  // ── Page header ──────────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Patients', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('New Entry', style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Add Patient Record', style: AppTextStyles.headlineMd),
        const SizedBox(height: 4),
        Text(
          'Complete all required fields to register a new patient and record their initial visit.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildActiveSessionChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.stableGreenContainer, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.stableGreen)),
          const SizedBox(width: 6),
          Text('ACTIVE SESSION', style: AppTextStyles.labelSm.copyWith(color: AppColors.stableGreen, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    final progress = _completedFields / _totalFields;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REQUIRED FIELDS', style: AppTextStyles.labelSm.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              Text('$_completedFields / $_totalFields completed', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: progress == 1.0 ? AppColors.stableGreen : AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineSm),
      ],
    );
  }

  // ── Demographic section ──────────────────────────────────────────────────────

  Widget _buildDemographicSection() {
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('FULL NAME *'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: AppTextStyles.bodyMd,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: _inputDec('e.g. Johnson Kalule'),
        ),
        const SizedBox(height: 14),
        _fieldLabel('DATE OF BIRTH *'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDOB,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 10),
                Text(
                  _dateOfBirth != null ? _formatDate(_dateOfBirth!) : 'Select date of birth',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: _dateOfBirth != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _fieldLabel('GENDER *'),
        const SizedBox(height: 6),
        _dropdown(
          value: _selectedGender,
          hint: 'Select gender',
          items: ['Male', 'Female', 'Other'],
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
        const SizedBox(height: 14),
        _fieldLabel('CONTACT NUMBER *'),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.bodyMd,
          onChanged: (_) => setState(() {}),
          decoration: _inputDec('+256 700 000 000').copyWith(
            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.onSurfaceVariant, size: 18),
          ),
        ),
        const SizedBox(height: 14),
        _fieldLabel('BLOOD GROUP *'),
        const SizedBox(height: 6),
        _dropdown(
          value: _selectedBloodGroup,
          hint: 'e.g. O+, AB-',
          items: ['A+','A-','B+','B-','AB+','AB-','O+','O-'],
          onChanged: (v) => setState(() => _selectedBloodGroup = v),
        ),
      ],
    ));
  }

  // ── Vitals section ───────────────────────────────────────────────────────────

  Widget _buildVitalsSection() {
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('HEART RATE'),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.error,
                  inactiveTrackColor: AppColors.surfaceContainerHighest,
                  thumbColor: AppColors.error,
                  overlayColor: AppColors.error.withAlpha(30),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: _heartRate,
                  min: 40, max: 160,
                  onChanged: (v) => setState(() => _heartRate = v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.error.withAlpha(15), borderRadius: BorderRadius.circular(8)),
              child: Text('${_heartRate.round()} bpm',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _fieldLabel('TEMPERATURE'),
        const SizedBox(height: 6),
        _dropdown(
          value: _selectedTemperature,
          hint: 'Select temperature range',
          items: [
            'Below 36.0°C (Hypothermia)',
            '36.0 – 37.5°C (Normal)',
            '37.6 – 38.5°C (Low Fever)',
            '38.6 – 39.5°C (Moderate Fever)',
            'Above 39.5°C (High Fever)',
          ],
          onChanged: (v) => setState(() => _selectedTemperature = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('BLOOD PRESSURE *'),
                const SizedBox(height: 6),
                TextField(
                  controller: _bloodPressureController,
                  style: AppTextStyles.bodyMd,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDec('120/80').copyWith(suffixText: 'mmHg', suffixStyle: AppTextStyles.labelSm),
                ),
              ],
            )),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('WEIGHT'),
                const SizedBox(height: 6),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.bodyMd,
                  decoration: _inputDec('0.0').copyWith(suffixText: 'kg', suffixStyle: AppTextStyles.labelSm),
                ),
              ],
            )),
          ],
        ),
      ],
    ));
  }

  // ── Visit details section ────────────────────────────────────────────────────

  Widget _buildVisitDetailsSection() {
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('REASON FOR VISIT'),
        const SizedBox(height: 6),
        TextField(
          controller: _reasonController,
          style: AppTextStyles.bodyMd,
          decoration: _inputDec('Why is the patient visiting today?'),
        ),
        const SizedBox(height: 14),
        _fieldLabel('DIAGNOSIS *'),
        const SizedBox(height: 6),
        TextField(
          controller: _diagnosisController,
          style: AppTextStyles.bodyMd,
          onChanged: (_) => setState(() {}),
          decoration: _inputDec('e.g. Hypertension – Stage 1'),
        ),
        const SizedBox(height: 14),
        _fieldLabel('CLINICAL NOTES'),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: AppTextStyles.bodyMd,
          decoration: _inputDec('Findings, observations, treatment plan, follow-up instructions...').copyWith(alignLabelWithHint: true),
        ),
        const SizedBox(height: 16),
        _fieldLabel('PATIENT STATUS AFTER THIS VISIT'),
        const SizedBox(height: 10),
        Row(
          children: PatientStatus.values.map((status) {
            final isSelected = _patientStatus == status;
            late Color color; late String label; late IconData icon;
            switch (status) {
              case PatientStatus.stable:
                color = AppColors.stableGreen; label = 'Stable'; icon = Icons.check_circle_outline_rounded;
              case PatientStatus.observation:
                color = AppColors.observationBlue; label = 'Observation'; icon = Icons.visibility_outlined;
              case PatientStatus.critical:
                color = AppColors.error; label = 'Critical'; icon = Icons.warning_amber_rounded;
            }
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _patientStatus = status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: status != PatientStatus.critical ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(20) : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? Border.all(color: color, width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: isSelected ? color : AppColors.onSurfaceVariant, size: 18),
                      const SizedBox(height: 4),
                      Text(label, style: AppTextStyles.labelSm.copyWith(
                        color: isSelected ? color : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ));
  }

  // ── Allergies section ────────────────────────────────────────────────────────

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Committed list
        if (_allergies.isNotEmpty) ...[
          ..._allergies.asMap().entries.map((e) => _allergyChip(e.value, e.key)),
          const SizedBox(height: 10),
        ],
        // Inline form
        if (_showAllergyForm) ...[
          _allergyForm(),
          const SizedBox(height: 10),
        ],
        // Add button
        if (!_showAllergyForm)
          _addButton(
            label: _allergies.isEmpty ? 'Add Allergy' : 'Add Another Allergy',
            icon: Icons.add_circle_outline_rounded,
            color: AppColors.error,
            bg: AppColors.errorContainer,
            onTap: () => setState(() { _showAllergyForm = true; _allergyFormError = null; }),
          ),
      ],
    );
  }

  Widget _allergyChip(_AllergyDraft a, int index) {
    late Color color; late String label;
    switch (a.severity) {
      case AllergySeverity.critical: color = AppColors.error; label = 'Critical';
      case AllergySeverity.moderate: color = AppColors.warning; label = 'Moderate';
      case AllergySeverity.mild: color = AppColors.observationBlue; label = 'Mild';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.onSurface.withAlpha(8), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.block_rounded, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.name, style: AppTextStyles.labelLg),
              if (a.reaction.isNotEmpty)
                Text(a.reaction, style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(999)),
            child: Text(label, style: AppTextStyles.labelSm.copyWith(color: color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeAllergy(index),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allergyForm() {
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('New Allergy', style: AppTextStyles.headlineSm.copyWith(fontSize: 16)),
            GestureDetector(
              onTap: () => setState(() { _showAllergyForm = false; _allergyFormError = null; _allergyNameCtrl.clear(); _allergyReactionCtrl.clear(); }),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(7)),
                child: const Icon(Icons.close_rounded, size: 15, color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _fieldLabel('ALLERGEN NAME *'),
        const SizedBox(height: 6),
        TextField(controller: _allergyNameCtrl, style: AppTextStyles.bodyMd, decoration: _inputDec('e.g. Penicillin, Peanuts, Latex')),
        const SizedBox(height: 14),
        _fieldLabel('SEVERITY *'),
        const SizedBox(height: 8),
        Row(
          children: AllergySeverity.values.map((s) {
            final isSelected = _allergySeverity == s;
            late Color color; late String label;
            switch (s) {
              case AllergySeverity.critical: color = AppColors.error; label = 'Critical';
              case AllergySeverity.moderate: color = AppColors.warning; label = 'Moderate';
              case AllergySeverity.mild: color = AppColors.observationBlue; label = 'Mild';
            }
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _allergySeverity = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: s != AllergySeverity.mild ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(20) : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: color, width: 1.5) : null,
                  ),
                  child: Text(label, textAlign: TextAlign.center,
                      style: AppTextStyles.labelMd.copyWith(color: isSelected ? color : AppColors.onSurfaceVariant, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _fieldLabel('REACTION DESCRIPTION (Optional)'),
        const SizedBox(height: 6),
        TextField(
          controller: _allergyReactionCtrl,
          maxLines: 2,
          style: AppTextStyles.bodyMd,
          decoration: _inputDec('Describe what happens when exposed...'),
        ),
        if (_allergyFormError != null) ...[
          const SizedBox(height: 10),
          _buildErrorBanner(_allergyFormError!),
        ],
        const SizedBox(height: 14),
        GradientButton(
          label: 'Add to List',
          onPressed: _submitAllergyDraft,
          icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
        ),
      ],
    ));
  }

  // ── Medications section ──────────────────────────────────────────────────────

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_medications.isNotEmpty) ...[
          ..._medications.asMap().entries.map((e) => _medicationChip(e.value, e.key)),
          const SizedBox(height: 10),
        ],
        if (_showMedicationForm) ...[
          _medicationForm(),
          const SizedBox(height: 10),
        ],
        if (!_showMedicationForm)
          _addButton(
            label: _medications.isEmpty ? 'Add Prescription' : 'Add Another Prescription',
            icon: Icons.medication_rounded,
            color: AppColors.primary,
            bg: AppColors.primary.withAlpha(15),
            onTap: () => setState(() { _showMedicationForm = true; _medFormError = null; }),
          ),
      ],
    );
  }

  Widget _medicationChip(_MedicationDraft m, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.onSurface.withAlpha(8), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: AppTextStyles.labelLg),
              Text('${m.dosage} · ${m.frequency}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.stableGreenContainer, borderRadius: BorderRadius.circular(999)),
            child: Text('Active', style: AppTextStyles.labelSm.copyWith(color: AppColors.stableGreen, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeMedication(index),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationForm() {
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('New Prescription', style: AppTextStyles.headlineSm.copyWith(fontSize: 16)),
            GestureDetector(
              onTap: () => setState(() { _showMedicationForm = false; _medFormError = null; _medNameCtrl.clear(); _medDosageCtrl.clear(); _medFrequencyCtrl.clear(); _medNotesCtrl.clear(); }),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(7)),
                child: const Icon(Icons.close_rounded, size: 15, color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _fieldLabel('MEDICATION NAME *'),
        const SizedBox(height: 6),
        TextField(
          controller: _medNameCtrl,
          style: AppTextStyles.bodyMd,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDec('e.g. Lisinopril').copyWith(
            prefixIcon: const Icon(Icons.medication_rounded, color: AppColors.onSurfaceVariant, size: 18),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('DOSAGE *'),
            const SizedBox(height: 6),
            TextField(controller: _medDosageCtrl, style: AppTextStyles.bodyMd, decoration: _inputDec('e.g. 10mg')),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('FREQUENCY *'),
            const SizedBox(height: 6),
            TextField(controller: _medFrequencyCtrl, style: AppTextStyles.bodyMd, decoration: _inputDec('e.g. Once daily')),
          ])),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('START DATE'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickMedDate(isStart: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(_formatDate(_medStartDate), style: AppTextStyles.bodyMd),
                ]),
              ),
            ),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _fieldLabel('END DATE'),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() { _medHasEndDate = !_medHasEndDate; if (!_medHasEndDate) _medEndDate = null; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _medHasEndDate ? AppColors.primary.withAlpha(20) : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_medHasEndDate ? 'ON' : 'OFF',
                      style: AppTextStyles.labelSm.copyWith(
                        color: _medHasEndDate ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _medHasEndDate ? () => _pickMedDate(isStart: false) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: _medHasEndDate ? AppColors.surfaceContainerHighest : AppColors.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(Icons.event_outlined, size: 15,
                      color: _medHasEndDate ? AppColors.onSurfaceVariant : AppColors.onSurfaceVariant.withAlpha(100)),
                  const SizedBox(width: 8),
                  Text(
                    _medEndDate != null ? _formatDate(_medEndDate!) : 'Not set',
                    style: AppTextStyles.bodyMd.copyWith(
                        color: _medHasEndDate ? AppColors.onSurface : AppColors.onSurfaceVariant.withAlpha(100)),
                  ),
                ]),
              ),
            ),
          ])),
        ]),
        const SizedBox(height: 14),
        _fieldLabel('NOTES (Optional)'),
        const SizedBox(height: 6),
        TextField(
          controller: _medNotesCtrl,
          maxLines: 2,
          style: AppTextStyles.bodyMd,
          decoration: _inputDec('Special instructions, monitoring requirements...'),
        ),
        if (_medFormError != null) ...[
          const SizedBox(height: 10),
          _buildErrorBanner(_medFormError!),
        ],
        const SizedBox(height: 14),
        GradientButton(
          label: 'Add to List',
          onPressed: _submitMedicationDraft,
          icon: const Icon(Icons.medication_rounded, color: Colors.white, size: 16),
        ),
      ],
    ));
  }

  // ── Shared UI helpers ─────────────────────────────────────────────────────────

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.onSurface.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _addButton({required String label, required IconData icon, required Color color, required Color bg, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.buttonLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTextStyles.labelMd.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label, style: AppTextStyles.labelSm.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant));
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
    );
  }

  Widget _dropdown({required String? value, required String hint, required List<String> items, required void Function(String?) onChanged}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: BorderRadius.circular(10),
          hint: Text(hint, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          items: items.map((g) => DropdownMenuItem(value: g, child: Text(g, style: AppTextStyles.bodyMd))).toList(),
          onChanged: (v) { onChanged(v); setState(() {}); },
        ),
      ),
    );
  }
}
