import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/providers/auth_provider.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  DateTime? _birthDate;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  Future<void> _pickBirthDate() async {
    if (!_isEditing) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AmaraColors.primary,
              onPrimary: Colors.white,
              surface: AmaraColors.bgCard,
              onSurface: AmaraColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non renseignée';
    final months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      appBar: AppBar(
        backgroundColor: AmaraColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Informations personnelles',
          style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () async {
              HapticFeedback.selectionClick();
              if (_isEditing) {
                setState(() => _isSaving = true);
                final error = await ref.read(authProvider.notifier).updateProfile(
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                );
                if (!mounted) return;
                setState(() => _isSaving = false);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error,
                          style: AmaraTextStyles.bodyMedium
                              .copyWith(color: Colors.white)),
                      backgroundColor: AmaraColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profil mis à jour',
                        style: AmaraTextStyles.bodyMedium
                            .copyWith(color: Colors.white)),
                    backgroundColor: AmaraColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
              setState(() => _isEditing = !_isEditing);
            },
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AmaraColors.primary,
                    ),
                  )
                : Text(
                    _isEditing ? 'Enregistrer' : 'Modifier',
                    style: AmaraTextStyles.labelMedium.copyWith(
                      color: AmaraColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildAvatar(user),
            const SizedBox(height: 32),

            _buildField(
              label: 'Nom complet',
              icon: Icons.person_outline_rounded,
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            _buildField(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildField(
              label: 'Téléphone',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Date de naissance
            GestureDetector(
              onTap: _pickBirthDate,
              child: _buildTapField(
                label: 'Date de naissance',
                value: _formatDate(_birthDate),
                icon: Icons.cake_outlined,
                showAction: _isEditing,
              ),
            ),
            const SizedBox(height: 20),
            _buildTapField(
              label: 'Membre depuis',
              value: _memberSince(user?.createdAt),
              icon: Icons.calendar_today_outlined,
              showAction: false,
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar avec CachedNetworkImage ──────────────────────────────────

  Widget _buildAvatar(AppUser? user) {
    final initials = _getInitials(user?.name ?? '');
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AmaraColors.bgAlt,
          border: Border.all(color: AmaraColors.divider, width: 2),
        ),
        child: ClipOval(
          child: user?.imageUrl != null && user!.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user.imageUrl!,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  placeholder: (_, __) => _buildInitials(initials),
                  errorWidget: (_, __, ___) => _buildInitials(initials),
                )
              : _buildInitials(initials),
        ),
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Container(
      color: AmaraColors.bgAlt,
      child: Center(
        child: Text(
          initials,
          style: AmaraTextStyles.h1.copyWith(
            color: AmaraColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 32,
          ),
        ),
      ),
    );
  }

  // ── Champ éditable avec label AU-DESSUS ──────────────────────────────

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AmaraTextStyles.labelMedium.copyWith(
              color: AmaraColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _isEditing ? AmaraColors.bgCard : AmaraColors.bgAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isEditing
                  ? AmaraColors.primary.withValues(alpha: 0.3)
                  : AmaraColors.divider,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: _isEditing,
            keyboardType: keyboardType,
            style: AmaraTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: _isEditing
                  ? AmaraColors.textPrimary
                  : AmaraColors.textSecondary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon,
                  color:
                      _isEditing ? AmaraColors.primary : AmaraColors.muted,
                  size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ── Champ non-éditable (tap) avec label AU-DESSUS ─────────────────────

  Widget _buildTapField({
    required String label,
    required String value,
    required IconData icon,
    required bool showAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AmaraTextStyles.labelMedium.copyWith(
              color: AmaraColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AmaraColors.bgAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: showAction
                  ? AmaraColors.primary.withValues(alpha: 0.3)
                  : AmaraColors.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color:
                      showAction ? AmaraColors.primary : AmaraColors.muted,
                  size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: AmaraTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: value == 'Non renseignée'
                        ? AmaraColors.muted
                        : AmaraColors.textSecondary,
                  ),
                ),
              ),
              if (showAction)
                const Icon(Icons.edit_calendar_rounded,
                    color: AmaraColors.primary, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  String _memberSince(int? createdAt) {
    if (createdAt == null) return 'Membre Amara';
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${months[date.month]} ${date.year}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
