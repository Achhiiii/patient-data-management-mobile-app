import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
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
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  late final TextEditingController _usernameController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _usernameController = TextEditingController(
      text: user?.clinicalIdentifier ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateCredentials() async {
    final newPass = _newPasswordController.text.isEmpty
        ? null
        : _newPasswordController.text;

    if (newPass != null && newPass != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'New passwords do not match.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final error = await AuthService.instance.updateCredentials(
      clinicalIdentifier: _usernameController.text,
      currentPassword: _currentPasswordController.text.isEmpty
          ? null
          : _currentPasswordController.text,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _successMessage = 'Credentials updated successfully.');
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

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
            _buildProviderAccessChip(user?.role ?? 'Provider'),
            const SizedBox(height: 8),
            if (user != null) ...[
              Text(
                user.fullName,
                style: AppTextStyles.titleMd,
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Manage your clinical credentials and security preferences.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            _buildIdentifierSection(),
            const SizedBox(height: 20),
            _buildSecuritySection(),
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
            if (_successMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.stableGreenContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.stableGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.stableGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            GradientButton(
              label: _isSaving ? 'Updating...' : 'Update Credentials',
              onPressed: _isSaving ? null : _updateCredentials,
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
    );
  }

  Widget _buildProviderAccessChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role.toUpperCase(),
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
            'Change Password',
            style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Leave blank to keep your current password.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          _fieldLabel('CURRENT PASSWORD'),
          const SizedBox(height: 6),
          TextField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: 'Your current password',
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
                child: Icon(
                  _obscureCurrent
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
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
          _fieldLabel('CONFIRM NEW PASSWORD'),
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
      onTap: _logout,
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
