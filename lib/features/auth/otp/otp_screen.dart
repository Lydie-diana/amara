import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/router/app_routes.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String pendingUserId;
  final String email;

  const OtpScreen({
    super.key,
    required this.pendingUserId,
    required this.email,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer <= 0) {
        t.cancel();
      } else {
        setState(() => _resendTimer--);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify(String pin) async {
    if (pin.length != 6 || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).verifyEmail(
            pendingUserId: widget.pendingUserId,
            code: pin,
          );
      if (!mounted) return;
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        context.go(AppRoutes.home);
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = authState.error ?? 'Code incorrect, réessayez';
        });
        _pinController.clear();
        _focusNode.requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _pinController.clear();
      _focusNode.requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_resendTimer > 0) return;
    try {
      await ref.read(authProvider.notifier).resendVerification(widget.pendingUserId);
      if (!mounted) return;
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code renvoyé à ${widget.email}',
              style: AmaraTextStyles.bodyMedium),
          backgroundColor: AmaraColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du renvoi',
              style: AmaraTextStyles.bodyMedium),
          backgroundColor: AmaraColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 58,
      textStyle: AmaraTextStyles.h2.copyWith(letterSpacing: 0),
      decoration: BoxDecoration(
        color: AmaraColors.bgAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AmaraColors.divider, width: 1),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AmaraColors.primary, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AmaraColors.error, width: 1.5),
        color: AmaraColors.error.withValues(alpha: 0.08),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AmaraColors.primary.withValues(alpha: 0.4)),
        color: AmaraColors.primary.withValues(alpha: 0.08),
      ),
    );

    return Scaffold(
      body: Container(
        color: AmaraColors.bg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Back button
                GestureDetector(
                  onTap: () => context.go(AppRoutes.authPhone),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AmaraColors.bgAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AmaraColors.divider,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AmaraColors.white,
                      size: 18,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 48),

                // Header
                Text(
                  'Vérification',
                  style: AmaraTextStyles.display2,
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                RichText(
                  text: TextSpan(
                    style: AmaraTextStyles.bodyMedium.copyWith(
                      color: AmaraColors.muted,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Code envoyé à\n'),
                      TextSpan(
                        text: widget.email,
                        style: AmaraTextStyles.bodyLarge.copyWith(
                          color: AmaraColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 52),

                // PIN input
                Center(
                  child: Pinput(
                    controller: _pinController,
                    focusNode: _focusNode,
                    length: 6,
                    autofocus: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    forceErrorState: _hasError,
                    errorText: _hasError
                        ? (_errorMessage ?? 'Code incorrect, réessayez')
                        : null,
                    errorTextStyle: AmaraTextStyles.bodySmall.copyWith(
                      color: AmaraColors.error,
                    ),
                    pinAnimationType: PinAnimationType.slide,
                    onCompleted: _verify,
                    onChanged: (_) {
                      if (_hasError) {
                        setState(() {
                          _hasError = false;
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 40),

                // Resend code
                Center(
                  child: _resendTimer > 0
                      ? RichText(
                          text: TextSpan(
                            style: AmaraTextStyles.bodySmall,
                            children: [
                              const TextSpan(text: 'Renvoyer dans '),
                              TextSpan(
                                text: '${_resendTimer}s',
                                style: AmaraTextStyles.labelSmall.copyWith(
                                  color: AmaraColors.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : TextButton(
                          onPressed: _resend,
                          child: Text(
                            'Renvoyer le code',
                            style: AmaraTextStyles.labelMedium.copyWith(
                              color: AmaraColors.primary,
                            ),
                          ),
                        ),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                const Spacer(),

                // Verify button
                AnimatedOpacity(
                  opacity: _pinController.text.length == 6 ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _pinController.text.length == 6
                        ? () => _verify(_pinController.text)
                        : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text('Vérifier', style: AmaraTextStyles.button),
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
