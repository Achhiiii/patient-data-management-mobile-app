import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/patient.dart';

class VisitDetailsScreen extends StatelessWidget {
  final Visit visit;
  final Patient patient;

  const VisitDetailsScreen({
    super.key,
    required this.visit,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (visit.chiefComplaint != null) ...[
                  _buildInfoCard(
                    icon: Icons.report_problem_outlined,
                    title: 'Chief Complaint',
                    child: Text(visit.chiefComplaint!, style: AppTextStyles.bodyMd),
                  ),
                  const SizedBox(height: 14),
                ],
                _buildInfoCard(
                  icon: Icons.medical_information_outlined,
                  title: 'Diagnosis',
                  child: Text(
                    visit.diagnosis,
                    style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 14),
                _buildVitalsCard(),
                const SizedBox(height: 14),
                _buildInfoCard(
                  icon: Icons.notes_rounded,
                  title: 'Clinical Notes',
                  child: Text(
                    visit.notes,
                    style: AppTextStyles.bodyMd.copyWith(height: 1.6),
                  ),
                ),
                const SizedBox(height: 14),
                _buildMetaCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
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
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit.formattedDate,
                          style: AppTextStyles.headlineSm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _buildStatusBadge(visit.patientStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient.fullName,
                    style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalsCard() {
    return _buildInfoCard(
      icon: Icons.monitor_heart_outlined,
      title: 'Vitals at this Visit',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.7,
        children: [
          _vitalTile('Heart Rate', '${visit.heartRate} bpm', Icons.favorite_outline_rounded, AppColors.error),
          _vitalTile('Blood Pressure', visit.bloodPressure, Icons.show_chart_rounded, AppColors.primary),
          _vitalTile('Temperature', '${visit.temperature}°C', Icons.thermostat_outlined, AppColors.warning),
          _vitalTile('Weight', '${visit.weight} kg', Icons.monitor_weight_outlined, AppColors.observationBlue),
        ],
      ),
    );
  }

  Widget _vitalTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
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
              ),
              Text(
                label,
                style: AppTextStyles.labelSm,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline_rounded,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recorded by',
                  style: AppTextStyles.labelSm,
                ),
                Text(visit.recordedBy, style: AppTextStyles.labelLg),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Visit ID', style: AppTextStyles.labelSm),
              Text(
                visit.id,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headlineSm.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PatientStatus status) {
    late Color bg, text;
    late String label;
    switch (status) {
      case PatientStatus.stable:
        bg = AppColors.stableGreenContainer;
        text = AppColors.stableGreen;
        label = 'Stable';
      case PatientStatus.critical:
        bg = AppColors.errorContainer;
        text = AppColors.error;
        label = 'Critical';
      case PatientStatus.observation:
        bg = AppColors.observationBlueContainer;
        text = AppColors.observationBlue;
        label = 'Observation';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
