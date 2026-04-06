import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/patient.dart';

class NewVisitScreen extends StatefulWidget {
  final Patient patient;

  const NewVisitScreen({super.key, required this.patient});

  @override
  State<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  PatientStatus _selectedStatus = PatientStatus.stable;
  double _heartRate = 72;
  String? _tempRange;
  String? _validationError;

  final _complaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _bpController = TextEditingController(text: '120/80');
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _complaintController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _bpController.dispose();
    _weightController.dispose();
    super.dispose();
  }

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
            _buildPatientSummary(),
            const SizedBox(height: 24),
            _buildSectionLabel('Reason for Visit & Diagnosis', Icons.report_problem_outlined),
            const SizedBox(height: 14),
            _buildComplaintSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Vitals Recorded Today', Icons.monitor_heart_outlined),
            const SizedBox(height: 14),
            _buildVitalsSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Clinical Notes', Icons.notes_rounded),
            const SizedBox(height: 14),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Patient Status After Visit', Icons.flag_outlined),
            const SizedBox(height: 14),
            _buildStatusSelector(),
            if (_validationError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_validationError!, style: AppTextStyles.labelMd.copyWith(color: AppColors.error))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            GradientButton(
              label: 'Save Visit Record',
              onPressed: _saveVisit,
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurface,
              size: 18,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Visit', style: AppTextStyles.titleMd),
          Text(
            widget.patient.fullName,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSummary() {
    final p = widget.patient;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.signatureGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                p.initials,
                style: AppTextStyles.titleMd.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.fullName,
                  style: AppTextStyles.labelLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${p.age} yrs · ${p.genderLabel} · ${p.id}',
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                p.bloodGroup,
                style: AppTextStyles.titleMd.copyWith(color: Colors.white),
              ),
              Text(
                'Blood Group',
                style: AppTextStyles.labelSm.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('REASON FOR VISIT'),
          const SizedBox(height: 6),
          TextField(
            controller: _complaintController,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('Why is the patient visiting today?'),
          ),
          const SizedBox(height: 14),
          _fieldLabel('DIAGNOSIS *'),
          const SizedBox(height: 6),
          TextField(
            controller: _diagnosisController,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('e.g. Hypertension — Stage 1'),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
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
                    activeTrackColor: AppColors.error,
                    inactiveTrackColor: AppColors.surfaceContainerHighest,
                    thumbColor: AppColors.error,
                    overlayColor: AppColors.error.withAlpha(30),
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
                  color: AppColors.error.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_heartRate.round()} bpm',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.error,
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
                value: _tempRange,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(10),
                hint: Text(
                  'Select temperature range',
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
                ].map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t, style: AppTextStyles.bodyMd),
                )).toList(),
                onChanged: (v) => setState(() => _tempRange = v),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('BLOOD PRESSURE'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _bpController,
                      style: AppTextStyles.bodyMd,
                      decoration: _inputDec('120/80').copyWith(
                        suffixText: 'mmHg',
                        suffixStyle: AppTextStyles.labelSm,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('WEIGHT'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyMd,
                      decoration: _inputDec('kg').copyWith(
                        suffixText: 'kg',
                        suffixStyle: AppTextStyles.labelSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('CLINICAL NOTES'),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 5,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec(
              'Detailed findings, observations, treatment plan, and follow-up instructions...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: PatientStatus.values.map((status) {
        final isSelected = _selectedStatus == status;
        late Color color;
        late String label;
        late IconData icon;
        switch (status) {
          case PatientStatus.stable:
            color = AppColors.stableGreen;
            label = 'Stable';
            icon = Icons.check_circle_outline_rounded;
          case PatientStatus.observation:
            color = AppColors.observationBlue;
            label = 'Observation';
            icon = Icons.visibility_outlined;
          case PatientStatus.critical:
            color = AppColors.error;
            label = 'Critical';
            icon = Icons.warning_amber_rounded;
        }
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedStatus = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: status != PatientStatus.critical ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withAlpha(20) : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: color, width: 1.5)
                    : Border.all(color: Colors.transparent, width: 1.5),
                boxShadow: isSelected ? [] : [
                  BoxShadow(
                    color: AppColors.onSurface.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: isSelected ? color : AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected ? color : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
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

  void _saveVisit() {
    // Validate required fields
    if (_diagnosisController.text.trim().isEmpty) {
      setState(() => _validationError = 'Diagnosis is required before saving a visit.');
      return;
    }
    if (_bpController.text.trim().isEmpty) {
      setState(() => _validationError = 'Blood pressure is required.');
      return;
    }
    setState(() => _validationError = null);

    final currentUser = AuthService.instance.currentUser;
    final newVisit = Visit(
      id: const Uuid().v4(),
      patientId: widget.patient.id,
      recordedBy: currentUser?.clinicalIdentifier ?? 'unknown',
      visitDate: DateTime.now(),
      chiefComplaint: _complaintController.text.isEmpty
          ? null
          : _complaintController.text,
      diagnosis: _diagnosisController.text.isEmpty
          ? 'Unspecified'
          : _diagnosisController.text,
      notes: _notesController.text,
      heartRate: _heartRate.round(),
      temperature: _tempToDouble(_tempRange),
      bloodPressure: _bpController.text.isEmpty ? '120/80' : _bpController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      patientStatus: _selectedStatus,
    );
    Navigator.pop(context, newVisit);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.onSurface.withAlpha(8),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
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

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
    );
  }
}
