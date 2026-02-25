import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';

class PromoBanner extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const PromoBanner({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
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
    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: widget.onPageChanged,
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _BannerCard(banner: banner),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
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
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerData banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: banner.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Emoji décoratif en arrière-plan
          Positioned(
            right: -8,
            top: -8,
            child: Text(
              banner.emoji,
              style: const TextStyle(fontSize: 90),
            ),
          ),
          // Contenu
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
                    banner.tag,
                    style: AmaraTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  banner.title,
                  style: AmaraTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  banner.subtitle,
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

class _BannerData {
  final String title;
  final String subtitle;
  final String tag;
  final String emoji;
  final Color bgColor;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.emoji,
    required this.bgColor,
  });
}

const _banners = [
  _BannerData(
    title: 'Livraison gratuite',
    subtitle: 'Sur votre 1ère commande',
    tag: 'OFFRE SPÉCIALE',
    emoji: '🛵',
    bgColor: AmaraColors.primary,
  ),
  _BannerData(
    title: 'Cuisine africaine',
    subtitle: 'Authenticité à portée de main',
    tag: 'NOUVEAU',
    emoji: '🍲',
    bgColor: Color(0xFF5B4FCF),
  ),
  _BannerData(
    title: '-20% ce soir',
    subtitle: 'Restaurants partenaires sélectionnés',
    tag: 'PROMO',
    emoji: '🌙',
    bgColor: Color(0xFF1A7F5E),
  ),
];
