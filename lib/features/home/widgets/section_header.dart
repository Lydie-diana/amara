import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSubtitleTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSubtitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AmaraTextStyles.h3),
        if (subtitle != null)
          GestureDetector(
            onTap: onSubtitleTap,
            child: Text(
              subtitle!,
              style: AmaraTextStyles.labelSmall.copyWith(
                color: AmaraColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
