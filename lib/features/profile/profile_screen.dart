import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/router/app_routes.dart';
import '../shell/main_shell.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: AmaraColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AmaraColors.primary),
        ),
      );
    }

    if (!authState.isAuthenticated || user == null) {
      return _NotLoggedIn(onLogin: () => context.go(AppRoutes.authPhone));
    }

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Titre ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mon Profil',
                  style: AmaraTextStyles.h1
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Avatar + infos ────────────────────────────────────────
            _ProfileAvatar(user: user),

            const SizedBox(height: 32),

            // ── Menu items + logout ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Informations personnelles',
                      onTap: () => context.push(AppRoutes.personalInfo),
                    ),
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Mes commandes',
                      onTap: () => ref.read(shellIndexProvider.notifier).state = 2,
                    ),
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.favorite_rounded,
                      label: 'Mes favoris',
                      onTap: () => context.push(AppRoutes.favorites),
                    ),
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.location_on_rounded,
                      label: 'Mes adresses',
                      onTap: () => context.push(AppRoutes.myAddresses),
                    ),
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.notifications_rounded,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.language_rounded,
                      label: 'Langue',
                      onTap: () {},
                    ),
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Aide & FAQ',
                      onTap: () => context.push(AppRoutes.helpFaq),
                    ),
                    const SizedBox(height: 40),

                    // ── Bouton déconnexion ─────────────────────────────
                    _LogoutButton(
                      onLogout: () async {
                        HapticFeedback.mediumImpact();
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go(AppRoutes.authPhone);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar centré ─────────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final AppUser user;
  const _ProfileAvatar({required this.user});

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AmaraColors.bgAlt,
            border: Border.all(color: AmaraColors.divider, width: 2),
          ),
          child: ClipOval(
            child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: user.imageUrl!,
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                    placeholder: (_, __) => Center(
                      child: Text(
                        _initials,
                        style: AmaraTextStyles.h1.copyWith(
                          color: AmaraColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Center(
                      child: Text(
                        _initials,
                        style: AmaraTextStyles.h1.copyWith(
                          color: AmaraColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      _initials,
                      style: AmaraTextStyles.h1.copyWith(
                        color: AmaraColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: AmaraTextStyles.bodyMedium
              .copyWith(color: AmaraColors.textSecondary),
        ),
      ],
    );
  }
}

// ─── Item de menu plat ─────────────────────────────────────────────────────────

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AmaraColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AmaraTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AmaraColors.muted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AmaraColors.divider.withValues(alpha: 0.6),
      indent: 56,
    );
  }
}

// ─── Bouton déconnexion ────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AmaraColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Se déconnecter',
              style: AmaraTextStyles.button,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Écran non connecté ────────────────────────────────────────────────────────

class _NotLoggedIn extends StatelessWidget {
  final VoidCallback onLogin;
  const _NotLoggedIn({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AmaraColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      color: AmaraColors.primary, size: 40),
                ),
                const SizedBox(height: 20),
                Text('Connectez-vous',
                    style: AmaraTextStyles.h2
                        .copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Accédez à votre profil, vos commandes et vos favoris.',
                  style: AmaraTextStyles.bodySmall.copyWith(
                      color: AmaraColors.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: onLogin,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AmaraColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Se connecter',
                      textAlign: TextAlign.center,
                      style: AmaraTextStyles.labelMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
