import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/patient_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isMonthly = true;
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = PatientService.instance.getAnalytics();
  }

  void _refresh() {
    setState(() {
      _analyticsFuture = PatientService.instance.getAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hospital Analytics', style: AppTextStyles.headlineMd),
                Text('Overview', style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(
                  'Patient demographic distribution and volume.',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                _buildTotalCensusCard(data),
                const SizedBox(height: 20),
                _buildGenderDistributionCard(data),
                const SizedBox(height: 20),
                _buildAgeGroupCard(data),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = AuthService.instance.currentUser;
    final initials = user != null
        ? user.fullName.trim().split(' ').take(2).map((p) => p[0].toUpperCase()).join()
        : '?';

    return AppBar(
      backgroundColor: AppColors.surface,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Clinical Precision',
            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, size: 22)),
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCensusCard(Map<String, dynamic> data) {
    final total = data['total'] as int? ?? 0;
    final critical = data['critical'] as int? ?? 0;
    final stable = data['stable'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL CENSUS',
                style: AppTextStyles.labelSm.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$total',
            style: AppTextStyles.displayLg.copyWith(
              color: AppColors.primary,
              fontSize: 48,
            ),
          ),
          Text(
            'Registered Patients',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statPill('$stable Stable', AppColors.stableGreen, AppColors.stableGreenContainer),
              const SizedBox(width: 8),
              _statPill('$critical Critical', AppColors.error, AppColors.errorContainer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTextStyles.labelMd.copyWith(color: text, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildGenderDistributionCard(Map<String, dynamic> data) {
    final total = (data['total'] as int? ?? 0);
    final female = data['female'] as int? ?? 0;
    final male = data['male'] as int? ?? 0;

    final femalePercent = total == 0 ? 0.0 : (female / total * 100);
    final malePercent = total == 0 ? 0.0 : (male / total * 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gender Distribution', style: AppTextStyles.headlineSm),
          const SizedBox(height: 20),
          if (total == 0)
            Center(
              child: Text(
                'No data yet',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: female.toDouble(),
                          color: AppColors.primary,
                          title: '',
                          radius: 52,
                        ),
                        PieChartSectionData(
                          value: male.toDouble(),
                          color: AppColors.surfaceContainerHighest,
                          title: '',
                          radius: 48,
                        ),
                      ],
                      centerSpaceRadius: 52,
                      sectionsSpace: 3,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$total',
                        style: AppTextStyles.titleMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: AppTextStyles.labelSm.copyWith(letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildGenderLegendItem(
              color: AppColors.primary,
              label: 'Female',
              percentage: '${femalePercent.toStringAsFixed(0)}%',
              count: '$female patients',
            ),
            const SizedBox(height: 10),
            _buildGenderLegendItem(
              color: AppColors.surfaceContainerHighest,
              label: 'Male',
              percentage: '${malePercent.toStringAsFixed(0)}%',
              count: '$male patients',
              textColor: AppColors.onSurface,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderLegendItem({
    required Color color,
    required String label,
    required String percentage,
    required String count,
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: AppTextStyles.labelLg),
          ),
          Text(
            percentage,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupCard(Map<String, dynamic> data) {
    final groups = [
      data['age0to18'] as int? ?? 0,
      data['age19to35'] as int? ?? 0,
      data['age36to50'] as int? ?? 0,
      data['age51to70'] as int? ?? 0,
      data['age70plus'] as int? ?? 0,
    ];
    final maxVal = groups.reduce((a, b) => a > b ? a : b);

    // Find largest group
    int largestIdx = 0;
    for (int i = 1; i < groups.length; i++) {
      if (groups[i] > groups[largestIdx]) largestIdx = i;
    }
    const groupLabels = ['0-18', '19-35', '36-50', '51-70', '70+'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Age Group\nDistribution', style: AppTextStyles.headlineSm),
              _buildToggle(),
            ],
          ),
          const SizedBox(height: 24),
          if (maxVal == 0)
            Center(
              child: Text(
                'No patient data yet',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal.toDouble() * 1.2 + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= groupLabels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(groupLabels[idx], style: AppTextStyles.labelSm),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.surfaceContainerHighest,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: groups.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble(),
                          color: e.key == largestIdx
                              ? AppColors.primary
                              : AppColors.surfaceContainerHighest,
                          width: 28,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (maxVal > 0) ...[
            Center(
              child: Text(
                '${groups[largestIdx]} patients',
                style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
              ),
            ),
            Center(
              child: Text(
                'largest age group (${groupLabels[largestIdx]})',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption('Monthly', _isMonthly, () => setState(() => _isMonthly = true)),
          _toggleOption('Weekly', !_isMonthly, () => setState(() => _isMonthly = false)),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
