import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/core/l10n/app_localizations.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/router/app_routes.dart';

class ForgotPasswordResetScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ForgotPasswordResetScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<ForgotPasswordResetScreen> createState() =>
      _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState
    extends ConsumerState<ForgotPasswordResetScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _passVisible = false;
  bool _confirmVisible = false;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.length < 6) {
      setState(
          () => _errorMsg = AppLocalizations.of(context).authPasswordMinLength);
      return;
    }
    if (pass != confirm) {
      setState(() => _errorMsg = AppLocalizations.of(context).authPasswordMismatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final error = await ref.read(authProvider.notifier).resetPassword(
          email: widget.email,
          code: widget.code,
          newPassword: pass,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMsg = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authPasswordResetSuccess,
              style: AmaraTextStyles.bodyMedium),
          backgroundColor: AmaraColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      context.go(AppRoutes.authPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AmaraColors.bgAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AmaraColors.divider),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AmaraColors.textPrimary,
                    size: 18,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 48),

              // Header
              Text(
                AppLocalizations.of(context).authNewPasswordTitle,
                style: AmaraTextStyles.display2.copyWith(
                  color: AmaraColors.textPrimary,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              Text(
                AppLocalizations.of(context).authNewPasswordDesc(widget.email),
                style: AmaraTextStyles.bodyMedium.copyWith(
                  color: AmaraColors.textSecondary,
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 40),

              // Error
              if (_errorMsg != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AmaraColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AmaraColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AmaraColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: AmaraTextStyles.bodySmall
                              .copyWith(color: AmaraColors.error),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms),

              // New password
              _buildField(
                controller: _passCtrl,
                hint: AppLocalizations.of(context).authNewPasswordLabel,
                icon: Icons.lock_outline_rounded,
                obscure: !_passVisible,
                suffix: IconButton(
                  icon: Icon(
                      _passVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AmaraColors.muted,
                      size: 20),
                  onPressed: () =>
                      setState(() => _passVisible = !_passVisible),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              // Confirm password
              _buildField(
                controller: _confirmCtrl,
                hint: AppLocalizations.of(context).authConfirmPasswordLabel,
                icon: Icons.lock_outline_rounded,
                obscure: !_confirmVisible,
                suffix: IconButton(
                  icon: Icon(
                      _confirmVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AmaraColors.muted,
                      size: 20),
                  onPressed: () =>
                      setState(() => _confirmVisible = !_confirmVisible),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const Spacer(),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AmaraColors.primary,
                    disabledBackgroundColor:
                        AmaraColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(AppLocalizations.of(context).authResetPassword,
                          style: AmaraTextStyles.labelLarge
                              .copyWith(color: Colors.white)),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: AmaraTextStyles.bodyLarge.copyWith(
        color: AmaraColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AmaraTextStyles.bodyMedium.copyWith(color: AmaraColors.muted),
        prefixIcon: Icon(icon, size: 18, color: AmaraColors.muted),
        suffixIcon: suffix,
        filled: true,
        fillColor: AmaraColors.bgAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AmaraColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AmaraColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
