import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/router/app_routes.dart';

/// Écran de connexion / inscription avec email + password.
/// Remplace le flow OTP (non disponible dans le backend Convex actuel).
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Login
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginPassVisible = false;

  // Signup
  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPhoneCtrl = TextEditingController();
  final _signupPassCtrl = TextEditingController();
  bool _signupPassVisible = false;

  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() => _errorMsg = null));
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPhoneCtrl.dispose();
    _signupPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMsg = 'Email et mot de passe requis');
      return;
    }
    setState(() { _isLoading = true; _errorMsg = null; });
    await ref.read(authProvider.notifier).login(email: email, password: pass);
    if (!mounted) return;
    setState(() => _isLoading = false);
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      setState(() => _errorMsg = authState.error ?? 'Erreur de connexion');
    }
  }

  Future<void> _signup() async {
    final name = _signupNameCtrl.text.trim();
    final email = _signupEmailCtrl.text.trim();
    final phone = _signupPhoneCtrl.text.trim();
    final pass = _signupPassCtrl.text;
    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      setState(() => _errorMsg = 'Tous les champs sont requis');
      return;
    }
    if (pass.length < 6) {
      setState(() => _errorMsg = 'Le mot de passe doit avoir au moins 6 caractères');
      return;
    }
    setState(() { _isLoading = true; _errorMsg = null; });
    await ref.read(authProvider.notifier).signup(
      name: name, email: email, phone: phone, password: pass,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      setState(() => _errorMsg = authState.error ?? 'Erreur lors de l\'inscription');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Back
              GestureDetector(
                onTap: () => context.go(AppRoutes.onboarding),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AmaraColors.bgAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AmaraColors.divider),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AmaraColors.white, size: 18),
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 40),

              // Logo + titre
              Text('Amara 🍛',
                style: AmaraTextStyles.display1.copyWith(color: AmaraColors.primary),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              Text('La livraison africaine, à votre porte',
                style: AmaraTextStyles.bodyMedium.copyWith(color: AmaraColors.muted),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 36),

              // Tabs Connexion / Inscription
              Container(
                decoration: BoxDecoration(
                  color: AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: AmaraColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AmaraTextStyles.labelMedium.copyWith(color: Colors.white),
                  unselectedLabelStyle: AmaraTextStyles.labelMedium.copyWith(
                    color: AmaraColors.muted,
                  ),
                  tabs: const [
                    Tab(text: 'Connexion'),
                    Tab(text: 'Inscription'),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // Error message
              if (_errorMsg != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AmaraColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AmaraColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AmaraColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMsg!,
                          style: AmaraTextStyles.bodySmall.copyWith(
                            color: AmaraColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms),

              // Formulaires
              SizedBox(
                height: _tab.index == 0 ? 260 : 380,
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _LoginForm(
                      emailCtrl: _loginEmailCtrl,
                      passCtrl: _loginPassCtrl,
                      passVisible: _loginPassVisible,
                      onTogglePass: () => setState(() => _loginPassVisible = !_loginPassVisible),
                      onSubmit: _login,
                      isLoading: _isLoading,
                    ),
                    _SignupForm(
                      nameCtrl: _signupNameCtrl,
                      emailCtrl: _signupEmailCtrl,
                      phoneCtrl: _signupPhoneCtrl,
                      passCtrl: _signupPassCtrl,
                      passVisible: _signupPassVisible,
                      onTogglePass: () => setState(() => _signupPassVisible = !_signupPassVisible),
                      onSubmit: _signup,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Formulaire connexion ─────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool passVisible;
  final VoidCallback onTogglePass;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _LoginForm({
    required this.emailCtrl,
    required this.passCtrl,
    required this.passVisible,
    required this.onTogglePass,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AmaraField(
          controller: emailCtrl,
          hint: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _AmaraField(
          controller: passCtrl,
          hint: 'Mot de passe',
          icon: Icons.lock_outline_rounded,
          obscure: !passVisible,
          suffix: IconButton(
            icon: Icon(passVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AmaraColors.muted, size: 20),
            onPressed: onTogglePass,
          ),
        ),
        const SizedBox(height: 28),
        _SubmitButton(label: 'Se connecter', isLoading: isLoading, onTap: onSubmit),
      ],
    );
  }
}

// ─── Formulaire inscription ───────────────────────────────────────────────────

class _SignupForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;
  final bool passVisible;
  final VoidCallback onTogglePass;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _SignupForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.passVisible,
    required this.onTogglePass,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AmaraField(controller: nameCtrl, hint: 'Nom complet', icon: Icons.person_outline_rounded),
        const SizedBox(height: 14),
        _AmaraField(
          controller: emailCtrl, hint: 'Email', icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _AmaraField(
          controller: phoneCtrl, hint: 'Téléphone (ex: +2250700000000)',
          icon: Icons.phone_outlined, keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        _AmaraField(
          controller: passCtrl, hint: 'Mot de passe (min. 6 caractères)',
          icon: Icons.lock_outline_rounded,
          obscure: !passVisible,
          suffix: IconButton(
            icon: Icon(passVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AmaraColors.muted, size: 20),
            onPressed: onTogglePass,
          ),
        ),
        const SizedBox(height: 28),
        _SubmitButton(label: 'Créer mon compte', isLoading: isLoading, onTap: onSubmit),
      ],
    );
  }
}

// ─── Composants partagés ──────────────────────────────────────────────────────

class _AmaraField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _AmaraField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AmaraTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AmaraTextStyles.bodyMedium.copyWith(color: AmaraColors.muted),
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
          borderSide: const BorderSide(color: AmaraColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AmaraColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AmaraColors.primary,
          disabledBackgroundColor: AmaraColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label, style: AmaraTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }
}
