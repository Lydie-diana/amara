import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/router/app_routes.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = ref.watch(cartProvider.select((c) => c.totalItems));

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        cartCount: cartTotal,
        onTap: _onTap,
        onCartTap: () => context.push(AppRoutes.cart),
      ),
    );
  }
}

// ─── Bottom Navigation avec panier ───────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final ValueChanged<int> onTap;
  final VoidCallback onCartTap;

  const _BottomNav({
    required this.currentIndex,
    required this.cartCount,
    required this.onTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AmaraColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                iconOutlined: Icons.home_outlined,
                label: 'Accueil',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.search_rounded,
                iconOutlined: Icons.search_outlined,
                label: 'Explorer',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              // Bouton Panier central — légèrement surélevé
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -8),
                    child: _CartNavItem(count: cartCount, onTap: onCartTap),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                iconOutlined: Icons.receipt_long_outlined,
                label: 'Commandes',
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                iconOutlined: Icons.person_outline_rounded,
                label: 'Profil',
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bouton panier central ────────────────────────────────────────────────────

class _CartNavItem extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CartNavItem({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AmaraColors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AmaraColors.primary.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AmaraColors.warning,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Item de navigation standard ─────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicateur rouge en haut quand sélectionné
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 20 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AmaraColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              isSelected ? icon : iconOutlined,
              color: isSelected ? AmaraColors.primary : AmaraColors.muted,
              size: 22,
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AmaraTextStyles.caption.copyWith(
                color: isSelected ? AmaraColors.primary : AmaraColors.muted,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
