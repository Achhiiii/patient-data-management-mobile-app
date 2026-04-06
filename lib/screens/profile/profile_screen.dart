import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  final _usernameController = TextEditingController(text: 'dr.smith.medical');
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Settings', style: AppTextStyles.headlineMd),
            const SizedBox(height: 10),
            _buildProviderAccessChip(),
            const SizedBox(height: 8),
            Text(
              'Manage your clinical credentials and security preferences for the Vitalis ecosystem.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            _buildIdentifierSection(),
            const SizedBox(height: 20),
            _buildSecuritySection(),
            const SizedBox(height: 28),
            GradientButton(
              label: 'Update Credentials',
              onPressed: () {},
              icon: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 16),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.add, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Vitalis Clinical',
            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, size: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProviderAccessChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PROVIDER ACCESS',
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildIdentifierSection() {
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
          Text(
            'Clinical Identifier (Username)',
            style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _usernameController,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              suffixIcon: const Icon(
                Icons.alternate_email_rounded,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
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
          Text(
            'Security Update',
            style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 14),
          _fieldLabel('NEW PASSWORD'),
          const SizedBox(height: 6),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: '••••••••••',
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureNew = !_obscureNew),
                child: Icon(
                  _obscureNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('CONFIRM PASSWORD'),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: '••••••••••',
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              prefixIcon: const Icon(
                Icons.shield_outlined,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: AppTextStyles.buttonLabel.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
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
}
