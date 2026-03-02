import 'package:flutter/material.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';

/// Ecran des conditions legales — onglets CGU / Confidentialite / Mentions.
class LegalScreen extends StatelessWidget {
  final int initialTab;

  const LegalScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: AmaraColors.bg,
        appBar: AppBar(
          backgroundColor: AmaraColors.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(l10n.legalTitle,
              style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: false,
            labelColor: AmaraColors.primary,
            unselectedLabelColor: AmaraColors.muted,
            indicatorColor: AmaraColors.primary,
            indicatorWeight: 2.5,
            labelStyle: AmaraTextStyles.labelSmall
                .copyWith(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: AmaraTextStyles.labelSmall
                .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
            tabs: [
              Tab(text: l10n.legalTabCgu),
              Tab(text: l10n.legalTabPrivacy),
              Tab(text: l10n.legalTabNotices),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CguContent(),
            _PrivacyContent(),
            _LegalNoticesContent(),
          ],
        ),
      ),
    );
  }
}

// ─── CGU — Conditions Generales d'Utilisation ────────────────────────────────

class _CguContent extends StatelessWidget {
  const _CguContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _LegalPage(
      lastUpdated: l10n.legalDateMarch2026,
      sections: [
        _LegalSection(title: l10n.legalCguTitle1, body: l10n.legalCguBody1),
        _LegalSection(title: l10n.legalCguTitle2, body: l10n.legalCguBody2),
        _LegalSection(title: l10n.legalCguTitle3, body: l10n.legalCguBody3),
        _LegalSection(title: l10n.legalCguTitle4, body: l10n.legalCguBody4),
        _LegalSection(title: l10n.legalCguTitle5, body: l10n.legalCguBody5),
        _LegalSection(title: l10n.legalCguTitle6, body: l10n.legalCguBody6),
        _LegalSection(title: l10n.legalCguTitle7, body: l10n.legalCguBody7),
        _LegalSection(title: l10n.legalCguTitle8, body: l10n.legalCguBody8),
        _LegalSection(title: l10n.legalCguTitle9, body: l10n.legalCguBody9),
        _LegalSection(title: l10n.legalCguTitle10, body: l10n.legalCguBody10),
        _LegalSection(title: l10n.legalCguTitle11, body: l10n.legalCguBody11),
        _LegalSection(title: l10n.legalCguTitle12, body: l10n.legalCguBody12),
      ],
    );
  }
}

// ─── Politique de Confidentialite ────────────────────────────────────────────

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _LegalPage(
      lastUpdated: l10n.legalDateMarch2026,
      sections: [
        _LegalSection(title: l10n.legalPrivacyTitle1, body: l10n.legalPrivacyBody1),
        _LegalSection(title: l10n.legalPrivacyTitle2, body: l10n.legalPrivacyBody2),
        _LegalSection(title: l10n.legalPrivacyTitle3, body: l10n.legalPrivacyBody3),
        _LegalSection(title: l10n.legalPrivacyTitle4, body: l10n.legalPrivacyBody4),
        _LegalSection(title: l10n.legalPrivacyTitle5, body: l10n.legalPrivacyBody5),
        _LegalSection(title: l10n.legalPrivacyTitle6, body: l10n.legalPrivacyBody6),
        _LegalSection(title: l10n.legalPrivacyTitle7, body: l10n.legalPrivacyBody7),
        _LegalSection(title: l10n.legalPrivacyTitle8, body: l10n.legalPrivacyBody8),
        _LegalSection(title: l10n.legalPrivacyTitle9, body: l10n.legalPrivacyBody9),
        _LegalSection(title: l10n.legalPrivacyTitle10, body: l10n.legalPrivacyBody10),
        _LegalSection(title: l10n.legalPrivacyTitle11, body: l10n.legalPrivacyBody11),
      ],
    );
  }
}

// ─── Mentions Legales ────────────────────────────────────────────────────────

class _LegalNoticesContent extends StatelessWidget {
  const _LegalNoticesContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _LegalPage(
      lastUpdated: l10n.legalDateMarch2026,
      sections: [
        _LegalSection(title: l10n.legalNoticesTitle1, body: l10n.legalNoticesBody1),
        _LegalSection(title: l10n.legalNoticesTitle2, body: l10n.legalNoticesBody2),
        _LegalSection(title: l10n.legalNoticesTitle3, body: l10n.legalNoticesBody3),
        _LegalSection(title: l10n.legalNoticesTitle4, body: l10n.legalNoticesBody4),
        _LegalSection(title: l10n.legalNoticesTitle5, body: l10n.legalNoticesBody5),
        _LegalSection(title: l10n.legalNoticesTitle6, body: l10n.legalNoticesBody6),
        _LegalSection(title: l10n.legalNoticesTitle7, body: l10n.legalNoticesBody7),
      ],
    );
  }
}

// ─── Widgets reutilisables ───────────────────────────────────────────────────

class _LegalPage extends StatelessWidget {
  final String lastUpdated;
  final List<_LegalSection> sections;

  const _LegalPage({required this.lastUpdated, required this.sections});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AmaraColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AmaraColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.update_rounded,
                  size: 16, color: AmaraColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.legalLastUpdated(lastUpdated),
                style: AmaraTextStyles.bodySmall.copyWith(
                  color: AmaraColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...sections,
      ],
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;

  const _LegalSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AmaraColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AmaraTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AmaraColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: AmaraTextStyles.bodyMedium.copyWith(
              color: AmaraColors.textSecondary,
              fontSize: 13.5,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
