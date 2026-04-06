import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedRole;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error = await AuthService.instance.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      clinicalIdentifier: _usernameController.text,
      role: _selectedRole?.toLowerCase() ?? 'doctor',
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildHeader(context),
                    const SizedBox(height: 28),
                    _buildForm(),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 4),
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
                      const SizedBox(height: 12),
                    ],
                    GradientButton(
                      label: _isLoading ? 'Creating account...' : 'Create Staff Account',
                      onPressed: _isLoading ? null : _register,
                    ),
                    const SizedBox(height: 20),
                    _buildLoginLink(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                'Back to Login',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vitalis Clinical', style: AppTextStyles.headlineSm),
                Text(
                  'SECURE STAFF PORTAL',
                  style: AppTextStyles.labelSm.copyWith(
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Create Staff Account', style: AppTextStyles.headlineMd),
        const SizedBox(height: 4),
        Text(
          'Register your clinical credentials to access the patient management system.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Personal Info ────────────────────────────────────────────────
          _sectionDivider('Personal Information'),
          const SizedBox(height: 14),
          _fieldLabel('FULL NAME *'),
          const SizedBox(height: 6),
          TextField(
            controller: _fullNameController,
            style: AppTextStyles.bodyMd,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDec('e.g. Dr. Jane Smith').copyWith(
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('STAFF EMAIL ADDRESS *'),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('staff.email@hospital.com').copyWith(
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Clinical Identity ────────────────────────────────────────────
          _sectionDivider('Clinical Identity'),
          const SizedBox(height: 14),
          _fieldLabel('CLINICAL IDENTIFIER (USERNAME) *'),
          const SizedBox(height: 6),
          TextField(
            controller: _usernameController,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('e.g. dr.jane.smith').copyWith(
              prefixIcon: const Icon(
                Icons.alternate_email_rounded,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('ROLE *'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(10),
                hint: Text(
                  'Select your role',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                items: ['Doctor', 'Nurse', 'Admin'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Icon(
                          _roleIcon(role),
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Text(role, style: AppTextStyles.bodyMd),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Security ─────────────────────────────────────────────────────
          _sectionDivider('Security'),
          const SizedBox(height: 14),
          _fieldLabel('PASSWORD *'),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('Min. 8 characters').copyWith(
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('CONFIRM PASSWORD *'),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: AppTextStyles.bodyMd,
            decoration: _inputDec('Re-enter your password').copyWith(
              prefixIcon: const Icon(
                Icons.shield_outlined,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
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
          const SizedBox(height: 14),
          // ── HIPAA notice ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By creating an account, you agree to handle all patient data in accordance with HIPAA regulations and your institution\'s data governance policy.',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              'Login',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionDivider(String label) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.primary.withAlpha(30),
          ),
        ),
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
      hintStyle: AppTextStyles.bodyMd.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'Doctor':
        return Icons.medical_services_outlined;
      case 'Nurse':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.admin_panel_settings_outlined;
    }
  }
}
