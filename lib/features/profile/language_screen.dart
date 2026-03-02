import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
import '../../app/providers/locale_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _languages = [
    _LanguageOption(code: 'fr', nativeName: 'Français', subtitle: 'French'),
    _LanguageOption(code: 'en', nativeName: 'English', subtitle: 'Anglais'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

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
          l10n.languageTitle,
          style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
              child: Text(
                l10n.languageSubtitle,
                style: AmaraTextStyles.bodySmall.copyWith(
                  color: AmaraColors.textSecondary,
                ),
              ),
            ),

            // Language cards
            ..._languages.map((lang) {
              final isSelected = currentLocale.languageCode == lang.code;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(lang.code));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AmaraColors.primary.withValues(alpha: 0.04)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AmaraColors.primary
                            : AmaraColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Language icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AmaraColors.primary.withValues(alpha: 0.1)
                                : AmaraColors.bgAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              lang.code.toUpperCase(),
                              style: AmaraTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? AmaraColors.primary
                                    : AmaraColors.textSecondary,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.nativeName,
                                style: AmaraTextStyles.labelMedium.copyWith(
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: AmaraColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.subtitle,
                                style: AmaraTextStyles.caption.copyWith(
                                  color: AmaraColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Radio indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AmaraColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AmaraColors.primary
                                  : AmaraColors.muted.withValues(alpha: 0.4),
                              width: isSelected ? 0 : 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 15)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String nativeName;
  final String subtitle;

  const _LanguageOption({
    required this.code,
    required this.nativeName,
    required this.subtitle,
  });
}
