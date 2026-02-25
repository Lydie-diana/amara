import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _avatarFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    // TODO: Intégrer Convex — sauvegarder profil
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AmaraColors.bg,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Back
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

                        const SizedBox(height: 40),

                        // Title
                        Text('Votre profil', style: AmaraTextStyles.display2)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms)
                            .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 8),

                        Text(
                          'Dites-nous comment vous appeler',
                          style: AmaraTextStyles.bodyMedium.copyWith(
                            color: AmaraColors.muted,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 40),

                        // Avatar picker
                        Center(child: _buildAvatarPicker()),

                        const SizedBox(height: 40),

                        // Name field
                        _buildLabel('Prénom et nom *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: AmaraTextStyles.bodyLarge,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'ex: Kofi Mensah',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AmaraColors.muted,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Ce champ est requis';
                            }
                            if (v.trim().length < 2) {
                              return 'Minimum 2 caractères';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 24),

                        // Email field
                        _buildLabel('Email (optionnel)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: AmaraTextStyles.bodyLarge,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'votre@email.com',
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: AmaraColors.muted,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final emailRegex =
                                  RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(v)) {
                                return 'Email invalide';
                              }
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),

                        const Spacer(),

                        // Save button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "C'est parti ! 🚀",
                                  style: AmaraTextStyles.button,
                                ),
                        )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AmaraTextStyles.labelMedium.copyWith(color: AmaraColors.muted),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _avatarFile == null ? AmaraColors.primary : null,
              border: Border.all(
                color: AmaraColors.primary,
                width: 2,
              ),
            ),
            child: _avatarFile != null
                ? ClipOval(
                    child: Image.file(
                      _avatarFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AmaraColors.bg,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }
}
