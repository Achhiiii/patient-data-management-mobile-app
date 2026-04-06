import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/patient.dart';

class ManageAllergiesSheet extends StatefulWidget {
  final Patient patient;
  final List<Allergy> allergies;
  final void Function(List<Allergy>) onUpdated;

  const ManageAllergiesSheet({
    super.key,
    required this.patient,
    required this.allergies,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required Patient patient,
    required List<Allergy> allergies,
    required void Function(List<Allergy>) onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageAllergiesSheet(
        patient: patient,
        allergies: allergies,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ManageAllergiesSheet> createState() => _ManageAllergiesSheetState();
}

class _ManageAllergiesSheetState extends State<ManageAllergiesSheet> {
  late List<Allergy> _allergies;
  bool _showAddForm = false;

  // Add form controllers
  final _nameController = TextEditingController();
  final _reactionController = TextEditingController();
  AllergySeverity _newSeverity = AllergySeverity.moderate;

  @override
  void initState() {
    super.initState();
    _allergies = List.from(widget.allergies);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _buildDragHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHeader(),
                  const SizedBox(height: 20),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  ..._buildAllergyList(),
                  if (_allergies.isEmpty && !_showAddForm)
                    _buildEmptyState(),
                  const SizedBox(height: 12),
                  if (_showAddForm) ...[
                    const SizedBox(height: 4),
                    _buildAddForm(),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Add Allergy',
                      onPressed: _addAllergy,
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => setState(() => _showAddForm = false),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildAddButton(),
                    const SizedBox(height: 12),
                    _buildSaveButton(),
                  ],
                ],
              ),
            ),
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
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage Allergies', style: AppTextStyles.headlineSm),
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
            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem('Critical', AppColors.error),
        const SizedBox(width: 12),
        _legendItem('Moderate', AppColors.warning),
        const SizedBox(width: 12),
        _legendItem('Mild', AppColors.observationBlue),
        const Spacer(),
        _legendItem('Active', AppColors.stableGreen),
        const SizedBox(width: 12),
        _legendItem('Resolved', AppColors.onSurfaceVariant),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }

  List<Widget> _buildAllergyList() {
    return _allergies.asMap().entries.map((entry) {
      final allergy = entry.value;
      final isActive = allergy.status == AllergyStatus.active;

      late Color severityColor;
      late String severityLabel;
      switch (allergy.severity) {
        case AllergySeverity.critical:
          severityColor = AppColors.error;
          severityLabel = 'Critical';
        case AllergySeverity.moderate:
          severityColor = AppColors.warning;
          severityLabel = 'Moderate';
        case AllergySeverity.mild:
          severityColor = AppColors.observationBlue;
          severityLabel = 'Mild';
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [BoxShadow(
                  color: AppColors.onSurface.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? severityColor.withAlpha(20) : AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.block_rounded,
                color: isActive ? severityColor : AppColors.onSurfaceVariant,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allergy.allergenName,
                    style: AppTextStyles.labelLg.copyWith(
                      color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: severityColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          severityLabel,
                          style: AppTextStyles.labelSm.copyWith(
                            color: severityColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.stableGreenContainer
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Resolved',
                          style: AppTextStyles.labelSm.copyWith(
                            color: isActive ? AppColors.stableGreen : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (allergy.reactionDescription != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      allergy.reactionDescription!,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _toggleStatus(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.errorContainer : AppColors.stableGreenContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Resolve' : 'Reactivate',
                  style: AppTextStyles.labelSm.copyWith(
                    color: isActive ? AppColors.error : AppColors.stableGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Allergy', style: AppTextStyles.headlineSm.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          _fieldLabel('ALLERGEN NAME *'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('e.g. Penicillin, Peanuts, Latex'),
          ),
          const SizedBox(height: 14),
          _fieldLabel('SEVERITY *'),
          const SizedBox(height: 8),
          Row(
            children: AllergySeverity.values.map((s) {
              final isSelected = _newSeverity == s;
              late Color color;
              late String label;
              switch (s) {
                case AllergySeverity.critical:
                  color = AppColors.error;
                  label = 'Critical';
                case AllergySeverity.moderate:
                  color = AppColors.warning;
                  label = 'Moderate';
                case AllergySeverity.mild:
                  color = AppColors.observationBlue;
                  label = 'Mild';
              }
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _newSeverity = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: s != AllergySeverity.mild ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withAlpha(20) : AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: color, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSelected ? color : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _fieldLabel('REACTION DESCRIPTION'),
          const SizedBox(height: 6),
          TextField(
            controller: _reactionController,
            maxLines: 2,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('Describe what happens when exposed...'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => setState(() => _showAddForm = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Text(
              'Add New Allergy',
              style: AppTextStyles.buttonLabel.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GradientButton(
      label: 'Save Changes',
      onPressed: () {
        widget.onUpdated(_allergies);
        Navigator.pop(context);
      },
      icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 40,
              color: AppColors.stableGreen.withAlpha(150),
            ),
            const SizedBox(height: 8),
            Text(
              'No allergies recorded',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleStatus(int index) {
    setState(() {
      final allergy = _allergies[index];
      _allergies[index] = allergy.copyWith(
        status: allergy.status == AllergyStatus.active
            ? AllergyStatus.resolved
            : AllergyStatus.active,
      );
    });
  }

  void _addAllergy() {
    if (_nameController.text.isEmpty) return;

    final currentUser = AuthService.instance.currentUser;
    final newAllergy = Allergy(
      id: const Uuid().v4(),
      patientId: widget.patient.id,
      allergenName: _nameController.text.trim(),
      severity: _newSeverity,
      reactionDescription: _reactionController.text.isEmpty
          ? null
          : _reactionController.text.trim(),
      status: AllergyStatus.active,
      recordedBy: currentUser?.clinicalIdentifier ?? 'unknown',
      createdAt: DateTime.now(),
    );

    setState(() {
      _allergies.add(newAllergy);
      _showAddForm = false;
      _nameController.clear();
      _reactionController.clear();
      _newSeverity = AllergySeverity.moderate;
    });
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
