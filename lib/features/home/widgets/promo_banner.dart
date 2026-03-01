import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/providers/promotions_provider.dart';

class PromoBanner extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const PromoBanner({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  ConsumerState<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends ConsumerState<PromoBanner> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(promotionsProvider(null));

    return promosAsync.when(
      loading: () => const SizedBox(height: 156),
      error: (_, __) => const SizedBox.shrink(),
      data: (promos) {
        if (promos.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 156,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: widget.onPageChanged,
                itemCount: promos.length,
                itemBuilder: (context, index) {
                  final promo = promos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _BannerCard(promo: promo),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                promos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: index == widget.currentIndex ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == widget.currentIndex
                        ? AmaraColors.primary
                        : AmaraColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Promotion promo;

  const _BannerCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: promo.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Text(
              promo.emoji,
              style: const TextStyle(fontSize: 90),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.tag,
                    style: AmaraTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  promo.title,
                  style: AmaraTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  promo.subtitle,
                  style: AmaraTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
