import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/providers/auth_provider.dart';
import '../../app/router/app_routes.dart';

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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _ProfileHeader(user: user)),

          // ── Sections ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _MenuSection(
                    title: 'Mon compte',
                    items: [
                      _MenuItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Mes commandes',
                        onTap: () => context.go(AppRoutes.orders),
                      ),
                      _MenuItem(
                        icon: Icons.favorite_rounded,
                        label: 'Mes favoris',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.location_on_rounded,
                        label: 'Mes adresses',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MenuSection(
                    title: 'Préférences',
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        label: 'Notifications',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.language_rounded,
                        label: 'Langue',
                        trailing: Text('Français',
                            style: AmaraTextStyles.caption
                                .copyWith(color: AmaraColors.muted)),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MenuSection(
                    title: 'Support',
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Aide & FAQ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'À propos d\'Amara',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Bouton déconnexion ─────────────────────────────────
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
    );
  }
}

// ─── Header avec avatar + infos user ──────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AppUser user;
  const _ProfileHeader({required this.user});

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AmaraColors.primary, Color(0xFFc41840)],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: user.imageUrl != null
                ? ClipOval(
                    child: Image.network(user.imageUrl!, fit: BoxFit.cover))
                : Center(
                    child: Text(
                      _initials,
                      style: AmaraTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: AmaraTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: AmaraTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          if (user.phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              user.phone,
              style: AmaraTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Badge rôle
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: Text(
              _roleLabel(user.role),
              style: AmaraTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'admin' => '⚙️ Admin',
      'restaurant' => '🍽️ Restaurateur',
      'livreur' => '🛵 Livreur',
      _ => '🛍️ Client',
    };
  }
}

// ─── Section de menu ───────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: AmaraTextStyles.labelSmall.copyWith(
                  color: AmaraColors.muted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AmaraColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AmaraColors.divider),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (i < items.length - 1)
                    Divider(
                        height: 1,
                        color: AmaraColors.divider,
                        indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AmaraColors.bgAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AmaraColors.textSecondary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AmaraTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              )),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AmaraColors.muted, size: 20),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AmaraColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AmaraColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: AmaraColors.error, size: 18),
            const SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: AmaraTextStyles.labelSmall.copyWith(
                color: AmaraColors.error,
                fontWeight: FontWeight.w700,
              ),
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
                  style: AmaraTextStyles.bodySmall
                      .copyWith(color: AmaraColors.textSecondary, height: 1.5),
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
                      style: AmaraTextStyles.labelMedium
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
