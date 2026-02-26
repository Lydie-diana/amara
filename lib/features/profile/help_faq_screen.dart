import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  int _expandedIndex = -1;

  static const _faqItems = [
    _FaqItem(
      question: 'Comment passer une commande ?',
      answer:
          'Parcourez les restaurants depuis l\'accueil, choisissez vos plats, ajoutez-les au panier puis validez votre commande. Vous pouvez suivre la livraison en temps réel.',
      icon: Icons.shopping_bag_outlined,
    ),
    _FaqItem(
      question: 'Quels sont les délais de livraison ?',
      answer:
          'La livraison prend en moyenne 30 à 45 minutes selon la distance et la préparation du restaurant. Vous pouvez suivre votre commande en temps réel depuis l\'onglet Commandes.',
      icon: Icons.timer_outlined,
    ),
    _FaqItem(
      question: 'Comment annuler une commande ?',
      answer:
          'Vous pouvez annuler votre commande depuis l\'onglet Commandes tant qu\'elle n\'a pas été prise en charge par le restaurant. Rendez-vous dans le détail de la commande et appuyez sur "Annuler".',
      icon: Icons.cancel_outlined,
    ),
    _FaqItem(
      question: 'Quels moyens de paiement acceptez-vous ?',
      answer:
          'Amara accepte le paiement par Mobile Money (Orange Money, MTN Money, Wave), carte bancaire (Visa, Mastercard) et le paiement en espèces à la livraison.',
      icon: Icons.payment_outlined,
    ),
    _FaqItem(
      question: 'Comment ajouter une adresse de livraison ?',
      answer:
          'Rendez-vous dans votre Profil > Mes adresses, puis appuyez sur "Ajouter". Vous pouvez enregistrer plusieurs adresses et définir une adresse par défaut.',
      icon: Icons.location_on_outlined,
    ),
    _FaqItem(
      question: 'Ma commande n\'est pas arrivée, que faire ?',
      answer:
          'Contactez notre support via le chat en bas de cette page ou appelez-nous. Nous ferons le nécessaire pour résoudre votre problème rapidement.',
      icon: Icons.report_problem_outlined,
    ),
    _FaqItem(
      question: 'Comment devenir restaurant partenaire ?',
      answer:
          'Envoyez-nous un email à partenaires@amara.app avec le nom de votre restaurant, votre localisation et votre menu. Notre équipe vous recontactera sous 48h.',
      icon: Icons.restaurant_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Aide & FAQ',
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
            _buildHeader(),
            const SizedBox(height: 28),

            // ── FAQ ───────────────────────────────────────────────────
            Text('Questions fréquentes',
                style:
                    AmaraTextStyles.h2.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            ...List.generate(_faqItems.length, (index) {
              final item = _faqItems[index];
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
            Text('Besoin d\'aide ?',
                style:
                    AmaraTextStyles.h2.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            _ContactOption(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat en direct',
              subtitle: 'Réponse en quelques minutes',
              color: AmaraColors.primary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chat bientôt disponible',
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
              label: 'Email',
              subtitle: 'support@amara.app',
              color: AmaraColors.warning,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ContactOption(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              subtitle: '+225 07 00 00 00 00',
              color: AmaraColors.success,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Comment pouvons-nous\nvous aider ?',
            style: AmaraTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Trouvez des réponses à vos questions ou contactez notre support.',
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
