import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/patient.dart';
import '../../services/patient_service.dart';
import 'visit_history_screen.dart';
import 'new_visit_screen.dart';
import 'widgets/prescribe_medication_sheet.dart';
import 'widgets/manage_allergies_sheet.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await PatientService.instance.getFullPatient(widget.patientId);
    if (mounted) {
      setState(() {
        _patient = patient;
        _isLoading = false;
      });
    }
  }

  List<Allergy> get _activeAllergies => (_patient?.allergies ?? [])
      .where((a) => a.status == AllergyStatus.active)
      .toList();

  List<Medication> get _activeMedications =>
      (_patient?.medications ?? [])
          .where((m) => m.status == MedicationStatus.active)
          .toList();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_patient == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: const Center(child: Text('Patient not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildVisitSummaryCard(),
                const SizedBox(height: 16),
                _buildCurrentMedications(),
                const SizedBox(height: 16),
                _buildCriticalAllergies(),
                const SizedBox(height: 16),
                _buildVitalSigns(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildNewVisitFab(context),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      backgroundColor: AppColors.primary,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisitHistoryScreen(patient: _patient!),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: Colors.white, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    'Visit History',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _buildPatientHeader()),
                  _buildLargeAvatar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    final p = _patient!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          p.fullName,
          style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _headerChip(Icons.cake_outlined, '${p.age} yrs'),
            const SizedBox(width: 6),
            _headerChip(Icons.person_outline_rounded, p.genderLabel),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.phone_outlined, color: Colors.white70, size: 13),
            const SizedBox(width: 4),
            Text(p.phone, style: AppTextStyles.bodySm.copyWith(color: Colors.white70)),
            const SizedBox(width: 10),
            const Icon(Icons.bloodtype_outlined, color: Colors.white70, size: 13),
            const SizedBox(width: 4),
            Text(p.bloodGroup, style: AppTextStyles.bodySm.copyWith(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),
        _buildStatusBadge(p.status),
      ],
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildLargeAvatar() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(30),
        border: Border.all(color: Colors.white.withAlpha(80), width: 2),
      ),
      child: Center(
        child: Text(
          _patient!.initials,
          style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PatientStatus status) {
    late Color bg, text;
    late String label;
    late IconData icon;
    switch (status) {
      case PatientStatus.stable:
        bg = AppColors.stableGreenContainer;
        text = AppColors.stableGreen;
        label = 'Stable';
        icon = Icons.check_circle_outline_rounded;
      case PatientStatus.critical:
        bg = AppColors.errorContainer;
        text = AppColors.error;
        label = 'Critical';
        icon = Icons.warning_amber_rounded;
      case PatientStatus.observation:
        bg = AppColors.observationBlueContainer;
        text = AppColors.observationBlue;
        label = 'Under Observation';
        icon = Icons.visibility_outlined;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: text, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── Visit Summary Card ──────────────────────────────────────────────────────

  Widget _buildVisitSummaryCard() {
    final visits = _patient!.visits;
    final latest = visits.isNotEmpty ? visits.last : null;

    return _sectionCard(
      icon: Icons.history_edu_rounded,
      title: 'Visit Summary',
      trailing: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitHistoryScreen(patient: _patient!),
            ),
          );
        },
        child: Text(
          'All ${visits.length} visits →',
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _infoChip('Total Visits', '${visits.length}'),
              const SizedBox(width: 10),
              _infoChip('Last Visit', latest?.formattedDate ?? 'None'),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 12),
            Text(
              'Primary Diagnosis',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 3),
            Text(
              _patient!.primaryDiagnosis,
              style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'Notes from last visit',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 3),
            Text(
              latest.notes,
              style: AppTextStyles.bodyMd,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'No visits recorded yet.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  // ── Current Medications ─────────────────────────────────────────────────────

  Widget _buildCurrentMedications() {
    final active = _activeMedications;
    final medications = _patient!.medications;
    final totalCount = medications.length;

    return _sectionCard(
      icon: Icons.medication_outlined,
      title: 'Current Medications',
      trailing: Row(
        children: [
          if (totalCount > active.length)
            GestureDetector(
              onTap: _showMedicationHistory,
              child: Text(
                '${totalCount - active.length} past →',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              PrescribeMedicationSheet.show(
                context,
                patient: _patient!,
                onPrescribed: (med) async {
                  await PatientService.instance.addMedication(med);
                  await _loadPatient();
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Prescribe',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: active.isEmpty
          ? Text(
              'No active medications.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            )
          : Column(
              children: active.asMap().entries.map((e) {
                final med = e.value;
                final isLast = e.key == active.length - 1;
                return Column(
                  children: [
                    _medicationRow(med, isActive: true),
                    if (!isLast) const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _medicationRow(Medication med, {required bool isActive}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withAlpha(15) : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.medication_rounded,
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                med.medicationName,
                style: AppTextStyles.labelLg.copyWith(
                  color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  decoration: isActive ? null : TextDecoration.lineThrough,
                ),
              ),
              Text(
                '${med.dosage} · ${med.frequency}',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        _medicationStatusPill(med.status),
      ],
    );
  }

  Widget _medicationStatusPill(MedicationStatus status) {
    late Color bg, text;
    late String label;
    switch (status) {
      case MedicationStatus.active:
        bg = AppColors.stableGreenContainer;
        text = AppColors.stableGreen;
        label = 'Active';
      case MedicationStatus.completed:
        bg = AppColors.surfaceContainerHighest;
        text = AppColors.onSurfaceVariant;
        label = 'Completed';
      case MedicationStatus.expired:
        bg = AppColors.warningContainer;
        text = AppColors.warning;
        label = 'Expired';
      case MedicationStatus.discontinued:
        bg = AppColors.errorContainer;
        text = AppColors.error;
        label = 'Stopped';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(color: text, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showMedicationHistory() {
    final medications = _patient!.medications;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Medication History', style: AppTextStyles.headlineSm),
            Text(
              'All past medications for ${_patient!.fullName}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: medications
                    .where((m) => m.status != MedicationStatus.active)
                    .map((med) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _medicationRow(med, isActive: false),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Active Allergies ────────────────────────────────────────────────────────

  Widget _buildCriticalAllergies() {
    final active = _activeAllergies;
    final totalActive = active.length;

    return _sectionCard(
      icon: Icons.warning_amber_rounded,
      title: 'Active Allergies',
      accentColor: AppColors.error,
      trailing: GestureDetector(
        onTap: () {
          ManageAllergiesSheet.show(
            context,
            patient: _patient!,
            allergies: _patient!.allergies,
            onUpdated: (updated) async {
              final existing = {for (final a in _patient!.allergies) a.id: a};
              for (final a in updated) {
                if (!existing.containsKey(a.id)) {
                  await PatientService.instance.addAllergy(a);
                } else if (existing[a.id]!.status != a.status) {
                  await PatientService.instance.updateAllergyStatus(a.id, a.status);
                }
              }
              await _loadPatient();
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, color: AppColors.error, size: 13),
              const SizedBox(width: 4),
              Text(
                'Manage${totalActive > 0 ? ' ($totalActive)' : ''}',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
      child: active.isEmpty
          ? Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.stableGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  'No active allergies recorded.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: active.map((a) => _allergyPill(a)).toList(),
            ),
    );
  }

  Widget _allergyPill(Allergy allergy) {
    late Color bg; late Color text; late String severityLabel;
    switch (allergy.severity) {
      case AllergySeverity.critical:
        bg = AppColors.errorContainer; text = AppColors.error; severityLabel = 'Critical';
      case AllergySeverity.moderate:
        bg = AppColors.warningContainer; text = AppColors.warning; severityLabel = 'Moderate';
      case AllergySeverity.mild:
        bg = AppColors.observationBlueContainer; text = AppColors.observationBlue; severityLabel = 'Mild';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_rounded, color: text, size: 12),
          const SizedBox(width: 5),
          Text(
            allergy.allergenName,
            style: AppTextStyles.labelMd.copyWith(color: text, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 5),
          Text(
            '· $severityLabel',
            style: AppTextStyles.labelSm.copyWith(color: text.withAlpha(180)),
          ),
        ],
      ),
    );
  }

  // ── Vital Signs ─────────────────────────────────────────────────────────────

  Widget _buildVitalSigns() {
    final visits = _patient!.visits;
    final latest = visits.isNotEmpty ? visits.last : null;
    final p = _patient!;

    return _sectionCard(
      icon: Icons.monitor_heart_outlined,
      title: 'Latest Vital Signs',
      trailing: latest != null
          ? Text(
              latest.formattedDate,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
            )
          : null,
      child: latest == null
          ? Text(
              'No vitals recorded. Add a visit to record vitals.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            )
          : GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _vitalCard('Heart Rate', '${latest.heartRate} bpm', Icons.favorite_outline_rounded, AppColors.error),
                _vitalCard('Blood Pressure', latest.bloodPressure, Icons.show_chart_rounded, AppColors.primary),
                _vitalCard('Weight', '${latest.weight} kg', Icons.monitor_weight_outlined, AppColors.observationBlue),
                _vitalCard('Blood Group', p.bloodGroup, Icons.bloodtype_outlined, const Color(0xFF5A3B00)),
              ],
            ),
    );
  }

  Widget _vitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.labelLg.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(label, style: AppTextStyles.labelSm, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────────

  Widget _buildNewVisitFab(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final newVisit = await Navigator.push<Visit>(
          context,
          MaterialPageRoute(
            builder: (_) => NewVisitScreen(patient: _patient!),
          ),
        );
        if (newVisit != null && mounted) {
          await PatientService.instance.addVisit(newVisit);
          await _loadPatient();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.signatureGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(64),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('New Visit', style: AppTextStyles.buttonLabel),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Color? accentColor,
    Widget? trailing,
  }) {
    final color = accentColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: AppTextStyles.headlineSm.copyWith(fontSize: 17)),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.labelLg),
        ],
      ),
    );
  }
}
