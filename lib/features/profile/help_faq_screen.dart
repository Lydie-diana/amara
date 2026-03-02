import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  int _expandedIndex = -1;

  List<_FaqItem> _buildFaqItems(AppLocalizations l10n) => [
    _FaqItem(
      question: l10n.helpFaqQ1,
      answer: l10n.helpFaqA1,
      icon: Icons.shopping_bag_outlined,
    ),
    _FaqItem(
      question: l10n.helpFaqQ2,
      answer: l10n.helpFaqA2,
      icon: Icons.timer_outlined,
    ),
    _FaqItem(
      question: l10n.helpFaqQ3,
      answer: l10n.helpFaqA3,
      icon: Icons.cancel_outlined,
    ),
    _FaqItem(
      question: l10n.helpFaqQ4,
      answer: l10n.helpFaqA4,
      icon: Icons.payment_outlined,
    ),
    _FaqItem(
      question: l10n.helpFaqQ5,
      answer: l10n.helpFaqA5,
      icon: Icons.location_on_outlined,
    ),
    _FaqItem(
      question: l10n.helpFaqQ6,
      answer: l10n.helpFaqA6,
      icon: Icons.report_problem_outlined,
    ),
    _FaqItem(
      question: l10n.helpFaqQ7,
      answer: l10n.helpFaqA7,
      icon: Icons.restaurant_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final faqItems = _buildFaqItems(l10n);

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
          l10n.helpTitle,
          style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            _buildHeader(l10n),
            const SizedBox(height: 28),

            // ── FAQ ───────────────────────────────────────────────────
            Text(l10n.helpFaqSectionTitle,
                style:
                    AmaraTextStyles.h2.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            ...List.generate(faqItems.length, (index) {
              final item = faqItems[index];
              final isExpanded = _expandedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FaqCard(
                  item: item,
                  isExpanded: isExpanded,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _expandedIndex = isExpanded ? -1 : index;
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: 32),

            // ── Contact support ───────────────────────────────────────
            Text(l10n.helpNeedHelp,
                style:
                    AmaraTextStyles.h2.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            _ContactOption(
              icon: Icons.chat_bubble_outline_rounded,
              label: l10n.helpContactChat,
              subtitle: l10n.helpContactChatSubtitle,
              color: AmaraColors.primary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.helpContactChatSoon,
                        style: AmaraTextStyles.bodyMedium
                            .copyWith(color: Colors.white)),
                    backgroundColor: AmaraColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _ContactOption(
              icon: Icons.email_outlined,
              label: l10n.helpContactEmail,
              subtitle: l10n.helpContactEmailAddress,
              color: AmaraColors.warning,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ContactOption(
              icon: Icons.phone_outlined,
              label: l10n.helpContactPhone,
              subtitle: l10n.helpContactPhoneNumber,
              color: AmaraColors.success,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AmaraColors.primary, AmaraColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded,
              color: Colors.white, size: 44),
          const SizedBox(height: 12),
          Text(
            l10n.helpHeaderTitle,
            style: AmaraTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helpHeaderSubtitle,
            style: AmaraTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Modèle FAQ ─────────────────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  final IconData icon;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}

// ─── Carte FAQ ──────────────────────────────────────────────────────────────────

class _FaqCard extends StatelessWidget {
  final _FaqItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FaqCard({
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? AmaraColors.primary.withValues(alpha: 0.3)
                : AmaraColors.divider,
          ),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: AmaraColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AmaraColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? AmaraColors.primary.withValues(alpha: 0.1)
                        : AmaraColors.bgAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon,
                      size: 18,
                      color: isExpanded
                          ? AmaraColors.primary
                          : AmaraColors.muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.question,
                    style: AmaraTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isExpanded
                          ? AmaraColors.primary
                          : AmaraColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? AmaraColors.primary : AmaraColors.muted,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12, left: 48),
                child: Text(
                  item.answer,
                  style: AmaraTextStyles.bodyMedium.copyWith(
                    color: AmaraColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Option contact ─────────────────────────────────────────────────────────────

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AmaraColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AmaraTextStyles.labelLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AmaraTextStyles.bodySmall
                          .copyWith(color: AmaraColors.textSecondary)),
                ],
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
