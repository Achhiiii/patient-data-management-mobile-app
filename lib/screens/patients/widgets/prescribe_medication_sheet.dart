import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/patient.dart';

class PrescribeMedicationSheet extends StatefulWidget {
  final Patient patient;
  final void Function(Medication medication) onPrescribed;

  const PrescribeMedicationSheet({
    super.key,
    required this.patient,
    required this.onPrescribed,
  });

  static Future<void> show(
    BuildContext context, {
    required Patient patient,
    required void Function(Medication) onPrescribed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrescribeMedicationSheet(
        patient: patient,
        onPrescribed: onPrescribed,
      ),
    );
  }

  @override
  State<PrescribeMedicationSheet> createState() =>
      _PrescribeMedicationSheetState();
}

class _PrescribeMedicationSheetState extends State<PrescribeMedicationSheet> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _notesController = TextEditingController();
  bool _hasEndDate = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildDragHandle(),
          const SizedBox(height: 20),
          _buildSheetHeader(),
          const SizedBox(height: 20),
          _buildForm(),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Prescribe Medication',
            onPressed: _prescribe,
            icon: const Icon(Icons.medication_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.medication_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prescribe Medication', style: AppTextStyles.headlineSm),
              Text(
                widget.patient.fullName,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('MEDICATION NAME *'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: AppTextStyles.bodyMd,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDec('e.g. Lisinopril').copyWith(
            prefixIcon: const Icon(
              Icons.medication_rounded,
              color: AppColors.onSurfaceVariant,
              size: 18,
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
                  _fieldLabel('DOSAGE *'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _dosageController,
                    style: AppTextStyles.bodyMd,
                    decoration: _inputDec('e.g. 10mg'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('FREQUENCY *'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _frequencyController,
                    style: AppTextStyles.bodyMd,
                    decoration: _inputDec('e.g. Once daily'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('START DATE'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickDate(isStart: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(_startDate),
                            style: AppTextStyles.bodyMd,
                          ),
                        ],
                      ),
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
                  Row(
                    children: [
                      _fieldLabel('END DATE'),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() {
                          _hasEndDate = !_hasEndDate;
                          if (!_hasEndDate) _endDate = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _hasEndDate
                                ? AppColors.primary.withAlpha(20)
                                : AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _hasEndDate ? 'ON' : 'OFF',
                            style: AppTextStyles.labelSm.copyWith(
                              color: _hasEndDate ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _hasEndDate ? () => _pickDate(isStart: false) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: _hasEndDate
                            ? AppColors.surfaceContainerHighest
                            : AppColors.surfaceContainerHighest.withAlpha(100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 15,
                            color: _hasEndDate
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurfaceVariant.withAlpha(100),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null ? _formatDate(_endDate!) : 'Not set',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: _hasEndDate
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _fieldLabel('NOTES (OPTIONAL)'),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: AppTextStyles.bodyMd,
          decoration: _inputDec('Special instructions, monitoring requirements...'),
        ),
      ],
    );
  }

  void _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _prescribe() {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) return;

    final currentUser = AuthService.instance.currentUser;
    final medication = Medication(
      id: const Uuid().v4(),
      patientId: widget.patient.id,
      medicationName: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim().isEmpty
          ? 'As directed'
          : _frequencyController.text.trim(),
      startDate: _startDate,
      endDate: _hasEndDate ? _endDate : null,
      status: MedicationStatus.active,
      prescribedBy: currentUser?.clinicalIdentifier ?? 'unknown',
      notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
    );

    widget.onPrescribed(medication);
    Navigator.pop(context);
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

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
