import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/patient.dart';
import 'visit_details_screen.dart';

class VisitHistoryScreen extends StatelessWidget {
  final Patient patient;

  const VisitHistoryScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final visits = patient.visits.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: visits.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                return _buildTimelineItem(context, visits[index], index, visits.length);
              },
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
          Text('Visit History', style: AppTextStyles.titleMd),
          Text(
            patient.fullName,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${patient.visits.length} Visit${patient.visits.length != 1 ? 's' : ''}',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Visit visit,
    int index,
    int total,
  ) {
    final isFirst = index == 0;
    final isLast = index == total - 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VisitDetailsScreen(
              visit: visit,
              patient: patient,
            ),
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Timeline spine ─────────────────────────────────────────────
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  if (!isFirst)
                    Container(width: 2, height: 12, color: AppColors.primary.withAlpha(40)),
                  _buildTimelineDot(visit.patientStatus, isFirst),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.primary.withAlpha(40),
                      ),
                    ),
                  if (isLast) const SizedBox(height: 40),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ── Visit card ─────────────────────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isFirst
                      ? AppColors.surfaceContainerLowest
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withAlpha(isFirst ? 12 : 7),
                      blurRadius: isFirst ? 14 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isFirst
                      ? Border.all(
                          color: AppColors.primary.withAlpha(40),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            visit.formattedDate,
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isFirst)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Latest',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        _buildStatusPill(visit.patientStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (visit.chiefComplaint != null) ...[
                      Text(
                        visit.chiefComplaint!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      visit.diagnosis,
                      style: AppTextStyles.labelLg,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // ── Vitals summary row ──────────────────────────────────
                    Row(
                      children: [
                        _vitalChip(Icons.favorite_outline_rounded, '${visit.heartRate} bpm', AppColors.error),
                        const SizedBox(width: 8),
                        _vitalChip(Icons.show_chart_rounded, visit.bloodPressure, AppColors.primary),
                        const SizedBox(width: 8),
                        _vitalChip(Icons.thermostat_outlined, '${visit.temperature}°C', AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          visit.recordedBy,
                          style: AppTextStyles.labelSm,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineDot(PatientStatus status, bool isFirst) {
    Color color;
    switch (status) {
      case PatientStatus.stable:
        color = AppColors.stableGreen;
      case PatientStatus.critical:
        color = AppColors.error;
      case PatientStatus.observation:
        color = AppColors.observationBlue;
    }

    return Container(
      width: isFirst ? 16 : 12,
      height: isFirst ? 16 : 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.surface, width: 2),
        boxShadow: isFirst
            ? [BoxShadow(color: color.withAlpha(80), blurRadius: 6)]
            : null,
      ),
    );
  }

  Widget _vitalChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(PatientStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 56,
            color: AppColors.onSurfaceVariant.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No visits recorded',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record the first visit to see history here',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
