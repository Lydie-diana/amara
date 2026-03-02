import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/router/app_routes.dart';

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
    _tab.addListener(() {
      if (_tab.indexIsChanging) {
        setState(() => _errorMsg = null);
      }
    });
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
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
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
      setState(
          () => _errorMsg = 'Le mot de passe doit avoir au moins 6 caractères');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final pendingUserId = await ref.read(authProvider.notifier).signup(
          name: name,
          email: email,
          phone: phone,
          password: pass,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (pendingUserId != null) {
      context.go(AppRoutes.authOtp, extra: {
        'pendingUserId': pendingUserId,
        'email': email,
      });
    } else {
      final authState = ref.read(authProvider);
      setState(
          () => _errorMsg = authState.error ?? 'Erreur lors de l\'inscription');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _tab.index == 0;

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header : back + switch link ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go(AppRoutes.onboarding);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AmaraColors.bgAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AmaraColors.divider),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AmaraColors.textPrimary, size: 16),
                    ),
                  ),
                  const Spacer(),
                  // Lien switch
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _tab.animateTo(isLogin ? 1 : 0);
                      setState(() {});
                    },
                    child: Text(
                      isLogin ? 'Inscription' : 'Connexion',
                      style: AmaraTextStyles.labelMedium
                          .copyWith(color: AmaraColors.primary),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // ── Contenu scrollable ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Titre
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isLogin ? 'Connexion' : 'Inscription',
                        key: ValueKey(isLogin),
                        style: AmaraTextStyles.display1.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sous-titre
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isLogin
                            ? 'Connectez-vous pour découvrir les saveurs africaines.'
                            : 'Créez votre compte et commencez à commander.',
                        key: ValueKey('sub_$isLogin'),
                        style: AmaraTextStyles.bodyMedium
                            .copyWith(color: AmaraColors.textSecondary),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Error message
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

                    // Formulaires
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child:
                          isLogin ? _buildLoginForm() : _buildSignupForm(),
                    ),

                    const SizedBox(height: 32),

                    // Séparateur
                    _buildDivider(),

                    const SizedBox(height: 24),

                    // Boutons sociaux
                    _buildSocialButtons(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Login Form ──────────────────────────────────────────────────────────

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Email'),
        const SizedBox(height: 8),
        _AmaraField(
          controller: _loginEmailCtrl,
          hint: 'amanda.samantha@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildLabel('Mot de passe'),
        const SizedBox(height: 8),
        _AmaraField(
          controller: _loginPassCtrl,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: !_loginPassVisible,
          suffix: IconButton(
            icon: Icon(
                _loginPassVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AmaraColors.muted,
                size: 20),
            onPressed: () =>
                setState(() => _loginPassVisible = !_loginPassVisible),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(AppRoutes.forgotPassword);
            },
            child: Text(
              'Mot de passe oublié ?',
              style: AmaraTextStyles.bodySmall.copyWith(
                color: AmaraColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _SubmitButton(
            label: 'Se connecter', isLoading: _isLoading, onTap: _login),
      ],
    );
  }

  // ─── Signup Form ─────────────────────────────────────────────────────────

  Widget _buildSignupForm() {
    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Nom complet'),
        const SizedBox(height: 8),
        _AmaraField(
          controller: _signupNameCtrl,
          hint: 'Jean Kouassi',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        _buildLabel('Email'),
        const SizedBox(height: 8),
        _AmaraField(
          controller: _signupEmailCtrl,
          hint: 'jean@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildLabel('Téléphone'),
        const SizedBox(height: 8),
        _AmaraField(
          controller: _signupPhoneCtrl,
          hint: '+225 07 00 00 00 00',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildLabel('Mot de passe'),
        const SizedBox(height: 8),
        _AmaraField(
          controller: _signupPassCtrl,
          hint: 'Min. 6 caractères',
          icon: Icons.lock_outline_rounded,
          obscure: !_signupPassVisible,
          suffix: IconButton(
            icon: Icon(
                _signupPassVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AmaraColors.muted,
                size: 20),
            onPressed: () =>
                setState(() => _signupPassVisible = !_signupPassVisible),
          ),
        ),
        const SizedBox(height: 32),
        _SubmitButton(
            label: 'Créer mon compte', isLoading: _isLoading, onTap: _signup),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AmaraTextStyles.labelMedium.copyWith(
        color: AmaraColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
            child: Divider(color: AmaraColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou continuer avec',
            style: AmaraTextStyles.bodySmall
                .copyWith(color: AmaraColors.textSecondary),
          ),
        ),
        const Expanded(
            child: Divider(color: AmaraColors.divider, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

// ─── Champ de texte ────────────────────────────────────────────────────────

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
          borderSide: const BorderSide(color: AmaraColors.divider, width: 1),
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

// ─── Bouton submit ─────────────────────────────────────────────────────────

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label,
                style: AmaraTextStyles.labelLarge
                    .copyWith(color: Colors.white)),
      ),
    );
  }
}

// ─── Bouton social ─────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isApple = label == 'Apple';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AmaraColors.bgAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isApple)
              const Icon(Icons.apple_rounded,
                  color: AmaraColors.textPrimary, size: 22)
            else
              Text(
                'G',
                style: AmaraTextStyles.h2.copyWith(
                  color: AmaraColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AmaraTextStyles.labelMedium.copyWith(
                color: AmaraColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
