import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/providers/location_provider.dart';
import 'location_picker_sheet.dart';

class HomeHeader extends ConsumerWidget {
  final Widget? searchBar;
  const HomeHeader({super.key, this.searchBar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.of(context).padding.top;
    final location = ref.watch(locationProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final initial = (user?.name.isNotEmpty == true)
        ? user!.name[0].toUpperCase()
        : 'A';
    final firstName = user?.name.split(' ').first ?? '';

    return Container(
      color: AmaraColors.primary,
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Localisation + actions ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openLocationPicker(context, ref),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: Colors.white, size: 15),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Livrer à',
                            style: AmaraTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                          Row(
                            children: [
                              if (location.isLoading)
                                _LoadingAddress()
                              else
                                Text(
                                  location.displayAddress,
                                  style: AmaraTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              const SizedBox(width: 2),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Notification
              GestureDetector(
                onTap: () {},
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 20),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF39C12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AmaraColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: AmaraColors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── Salutation ──────────────────────────────────────────────────────
          Text(
            firstName.isNotEmpty ? 'Bonjour, $firstName 👋' : 'Bonjour 👋',
            style: AmaraTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Qu'est-ce qui vous\nfait envie aujourd'hui ?",
            style: AmaraTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          if (searchBar != null) ...[
            const SizedBox(height: 16),
            searchBar!,
          ],
        ],
      ),
    );
  }

  void _openLocationPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
  }
}

class _LoadingAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
