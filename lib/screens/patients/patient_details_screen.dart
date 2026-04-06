import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/patient.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMedicalHistory(),
                const SizedBox(height: 16),
                _buildCurrentMedications(),
                const SizedBox(height: 16),
                _buildAllergies(),
                const SizedBox(height: 16),
                _buildVitalSigns(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
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
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
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
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          patient.fullName,
          style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _headerChip(Icons.cake_outlined, '${patient.age} yrs'),
            const SizedBox(width: 8),
            _headerChip(Icons.person_outline_rounded, patient.genderLabel),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.phone_outlined, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              patient.phone,
              style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildStatusBadge(),
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
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    late Color bg;
    late Color text;
    late String label;
    late IconData icon;

    switch (patient.status) {
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
            ),
          ),
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
          patient.initials,
          style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMedicalHistory() {
    return _sectionCard(
      icon: Icons.history_edu_rounded,
      title: 'Medical History',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _infoChip('Total Visits', '${patient.totalVisits}'),
              const SizedBox(width: 12),
              _infoChip('Last Visit', patient.lastVisit),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Primary Diagnosis',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            patient.primaryDiagnosis,
            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Notes',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(patient.medicalHistory, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }

  Widget _buildCurrentMedications() {
    return _sectionCard(
      icon: Icons.medication_outlined,
      title: 'Current Medications',
      child: patient.medications.isEmpty
          ? Text(
              'No medications recorded.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            )
          : Column(
              children: patient.medications.asMap().entries.map((e) {
                final med = e.value;
                final isLast = e.key == patient.medications.length - 1;
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.medication_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(med.name, style: AppTextStyles.labelLg),
                              Text(
                                '${med.dosage} — ${med.frequency}',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!isLast) const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildAllergies() {
    return _sectionCard(
      icon: Icons.warning_amber_rounded,
      title: 'Critical Allergies',
      accentColor: AppColors.error,
      child: patient.allergies.isEmpty
          ? Text(
              'No known allergies.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: patient.allergies.map((allergy) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.block_rounded,
                        color: AppColors.error,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        allergy,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildVitalSigns() {
    final vitals = patient.vitalSigns;
    return _sectionCard(
      icon: Icons.monitor_heart_outlined,
      title: 'Vital Signs',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _vitalCard('Heart Rate', vitals.heartRate, Icons.favorite_outline_rounded, AppColors.error),
          _vitalCard('Blood Pressure', vitals.bloodPressure, Icons.show_chart_rounded, AppColors.primary),
          _vitalCard('Weight', vitals.weight, Icons.monitor_weight_outlined, AppColors.observationBlue),
          _vitalCard('Blood Group', vitals.bloodGroup, Icons.bloodtype_outlined, AppColors.warning),
        ],
      ),
    );
  }

  Widget _vitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.labelLg.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.labelLg),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Color? accentColor,
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
              Text(
                title,
                style: AppTextStyles.headlineSm.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
