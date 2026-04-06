import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/patient.dart';
import '../../services/patient_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedTemperature;
  double _heartRate = 72;
  DateTime? _dateOfBirth;
  bool _isSaving = false;
  String? _errorMessage;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodPressureController = TextEditingController(text: '120/80');
  final _historyController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  int get _completedFields {
    int count = 0;
    if (_nameController.text.isNotEmpty) count++;
    if (_dateOfBirth != null) count++;
    if (_selectedGender != null) count++;
    if (_phoneController.text.isNotEmpty) count++;
    if (_selectedBloodGroup != null) count++;
    if (_bloodPressureController.text.isNotEmpty) count++;
    if (_historyController.text.isNotEmpty) count++;
    if (_allergiesController.text.isNotEmpty) count++;
    if (_medicationsController.text.isNotEmpty) count++;
    return count;
  }

  static const int _totalFields = 9;

  double _tempStringToDouble(String? temp) {
    if (temp == null) return 37.0;
    if (temp.contains('Hypothermia')) return 35.0;
    if (temp.contains('Normal')) return 37.0;
    if (temp.contains('Low Fever')) return 38.0;
    if (temp.contains('Moderate Fever')) return 39.0;
    if (temp.contains('High Fever')) return 40.0;
    return 37.0;
  }

  Future<void> _savePatient() async {
    if (_nameController.text.trim().isEmpty ||
        _dateOfBirth == null ||
        _selectedGender == null ||
        _phoneController.text.trim().isEmpty ||
        _selectedBloodGroup == null) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
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
        status: PatientStatus.stable,
        primaryDiagnosis: _historyController.text.trim(),
        createdBy: currentUser.id,
        createdAt: now,
      );

      final firstVisit = Visit(
        id: uuid.v4(),
        patientId: patientId,
        recordedBy: currentUser.clinicalIdentifier,
        visitDate: now,
        chiefComplaint: null,
        diagnosis: _historyController.text.trim().isEmpty
            ? 'Initial Registration'
            : _historyController.text.trim(),
        notes: _historyController.text.trim(),
        heartRate: _heartRate.round(),
        temperature: _tempStringToDouble(_selectedTemperature),
        bloodPressure: _bloodPressureController.text.trim().isEmpty
            ? '120/80'
            : _bloodPressureController.text.trim(),
        weight: 0.0,
        patientStatus: PatientStatus.stable,
      );

      // Parse simple allergy text into allergy records
      final allergies = <Allergy>[];
      if (_allergiesController.text.trim().isNotEmpty) {
        final allergenNames = _allergiesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);
        for (final name in allergenNames) {
          allergies.add(Allergy(
            id: uuid.v4(),
            patientId: patientId,
            allergenName: name,
            severity: AllergySeverity.moderate,
            status: AllergyStatus.active,
            recordedBy: currentUser.clinicalIdentifier,
            createdAt: now,
          ));
        }
      }

      // Parse simple medication text into medication records
      final medications = <Medication>[];
      if (_medicationsController.text.trim().isNotEmpty) {
        final medNames = _medicationsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty);
        for (final name in medNames) {
          medications.add(Medication(
            id: uuid.v4(),
            patientId: patientId,
            medicationName: name,
            dosage: 'As directed',
            frequency: 'As directed',
            startDate: now,
            status: MedicationStatus.active,
            prescribedBy: currentUser.clinicalIdentifier,
          ));
        }
      }

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

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bloodPressureController.dispose();
    _historyController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildPageHeader(),
              const SizedBox(height: 8),
              _buildActiveSessionChip(),
              const SizedBox(height: 24),
              _buildSectionLabel('Demographic Profile', Icons.person_outline_rounded),
              const SizedBox(height: 14),
              _buildDemographicSection(),
              const SizedBox(height: 20),
              _buildRecordSecurityBox(),
              const SizedBox(height: 20),
              _buildValidationStatus(),
              const SizedBox(height: 24),
              _buildSectionLabel('Patient Vitals', Icons.monitor_heart_outlined),
              const SizedBox(height: 14),
              _buildVitalsSection(),
              const SizedBox(height: 24),
              _buildSectionLabel('Clinical History & Medications', Icons.history_edu_rounded),
              const SizedBox(height: 14),
              _buildClinicalSection(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              GradientButton(
                label: _isSaving ? 'Saving...' : 'Save Patient Record',
                onPressed: _isSaving ? null : _savePatient,
                icon: const Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurface,
              size: 18,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text(
            'Clinical Precision',
            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Patients',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'New Entry',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Add Patient Record', style: AppTextStyles.headlineMd),
        const SizedBox(height: 4),
        Text(
          'Initialize a secure digital health record. All data is encrypted and HIPAA compliant.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildActiveSessionChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.stableGreenContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.stableGreen,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'ACTIVE SESSION',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.stableGreen,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
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

  Widget _buildDemographicSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('FULL NAME *'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: AppTextStyles.bodyMd,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('e.g. Johnson Kalule'),
          ),
          const SizedBox(height: 14),
          _fieldLabel('DATE OF BIRTH *'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDOB,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGender,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(10),
                hint: Text(
                  'Select gender',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                items: ['Male', 'Female', 'Other'].map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text(g, style: AppTextStyles.bodyMd),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('CONTACT NUMBER *'),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyMd,
            decoration: _inputDecoration('+1 (555) 000-0000').copyWith(
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('BLOOD GROUP *'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBloodGroup,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(10),
                hint: Text(
                  'e.g. O+, AB-',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                items: ['A+','A-','B+','B-','AB+','AB-','O+','O-'].map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text(g, style: AppTextStyles.bodyMd),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordSecurityBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.signatureGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Security',
                  style: AppTextStyles.labelLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This record will be auto-saved to the secure clinical cloud every 60 seconds.',
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    final progress = _completedFields / _totalFields;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VALIDATION STATUS',
                style: AppTextStyles.labelSm.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Required Fields',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                '$_completedFields/$_totalFields Completed',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('HEART RATE'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.surfaceContainerHighest,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withAlpha(30),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _heartRate,
                    min: 40,
                    max: 160,
                    onChanged: (v) => setState(() => _heartRate = v),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_heartRate.round()} bpm',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _fieldLabel('TEMPERATURE'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTemperature,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(10),
                hint: Text(
                  'Select range',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                items: [
                  'Below 36.0°C (Hypothermia)',
                  '36.0 – 37.5°C (Normal)',
                  '37.6 – 38.5°C (Low Fever)',
                  '38.6 – 39.5°C (Moderate Fever)',
                  'Above 39.5°C (High Fever)',
                ].map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t, style: AppTextStyles.bodyMd),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedTemperature = v),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('BLOOD PRESSURE'),
          const SizedBox(height: 6),
          TextField(
            controller: _bloodPressureController,
            style: AppTextStyles.bodyMd,
            decoration: _inputDecoration('120/80').copyWith(
              suffixText: 'mmHg',
              suffixStyle: AppTextStyles.labelSm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('MEDICAL HISTORY'),
          const SizedBox(height: 6),
          TextField(
            controller: _historyController,
            maxLines: 4,
            style: AppTextStyles.bodyMd,
            decoration: _inputDecoration(
              'Note any previous surgeries, chronic conditions, or significant diagnoses...',
            ).copyWith(alignLabelWithHint: true),
          ),
          const SizedBox(height: 4),
          Text(
            'Include approximate dates if known',
            style: AppTextStyles.labelSm,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'ALLERGIES',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _allergiesController,
            style: AppTextStyles.bodyMd,
            decoration: _inputDecoration('e.g. Penicillin, Peanuts'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.medication_rounded,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'CURRENT MEDICATIONS',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _medicationsController,
            style: AppTextStyles.bodyMd,
            decoration: _inputDecoration('e.g. Lisinopril 10mg QD'),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelSm.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
    );
  }
}
