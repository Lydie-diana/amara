import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/providers/location_provider.dart';
import '../../../app/providers/notification_provider.dart';
import '../../../app/router/app_routes.dart';
import 'location_picker_sheet.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.of(context).padding.top;
    final location = ref.watch(locationProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final initial = (user?.name.isNotEmpty == true)
        ? user!.name[0].toUpperCase()
        : 'A';
    final firstName = user?.name.split(' ').first ?? 'Gourmet';

    return Container(
      color: AmaraColors.bg,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne avatar + nom + notif ──
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AmaraColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: AmaraColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName 👋',
                            style: AmaraTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AmaraColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () => _openLocationPicker(context),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    color: AmaraColors.primary, size: 14),
                                const SizedBox(width: 3),
                                if (location.isLoading)
                                  _LoadingAddress()
                                else
                                  Flexible(
                                    child: Text(
                                      location.displayAddress,
                                      style: AmaraTextStyles.caption.copyWith(
                                        color: AmaraColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                const SizedBox(width: 2),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    color: AmaraColors.textSecondary, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  final unreadAsync =
                      ref.watch(unreadNotificationCountProvider);
                  final unread = unreadAsync.valueOrNull ?? 0;

                  return GestureDetector(
                    onTap: () => context.push(AppRoutes.notifications),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                AmaraColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.notifications_outlined,
                              color: AmaraColors.primary, size: 21),
                        ),
                        if (unread > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              decoration: BoxDecoration(
                                color: AmaraColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  unread > 99 ? '99+' : '$unread',
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
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          // ── Message accroche ──
          Text(
            'Qu\'est-ce qui vous\nfait envie aujourd\'hui ?',
            style: AmaraTextStyles.h1.copyWith(
              fontWeight: FontWeight.w800,
              color: AmaraColors.textPrimary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  void _openLocationPicker(BuildContext context) {
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
      height: 10,
      decoration: BoxDecoration(
        color: AmaraColors.divider,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
