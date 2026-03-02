import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/core/l10n/app_localizations.dart';
import '../../../app/providers/location_provider.dart';
import '../../../app/providers/restaurant_provider.dart';

/// Bannière affichée lorsqu'un déplacement significatif est détecté.
/// Style Uber Eats : slide-down depuis le haut, deux boutons d'action.
class MovementBanner extends ConsumerWidget {
  const MovementBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);

    if (!location.hasMovedSignificantly || location.newPosition == null) {
      return const SizedBox.shrink();
    }

    final newAddr = location.newPosition!.displayAddress;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AmaraColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AmaraColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AmaraColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.movementYouSeem,
                  style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.muted),
                ),
                Text(
                  newAddr,
                  style: AmaraTextStyles.bodyMedium.copyWith(
                    color: AmaraColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  await ref
                      .read(locationProvider.notifier)
                      .confirmNewLocation();
                  ref.invalidate(restaurantListProvider);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AmaraColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.movementSearchHere,
                    style: AmaraTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => ref.read(locationProvider.notifier).dismissMovement(),
                child: Text(
                  l10n.movementDismiss,
                  style: AmaraTextStyles.caption.copyWith(
                      color: AmaraColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.5, end: 0, duration: 350.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }
}
