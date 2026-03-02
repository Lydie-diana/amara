import 'package:flutter/material.dart';
import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';

/// Ecran des conditions legales — onglets CGU / Confidentialite / Mentions.
class LegalScreen extends StatelessWidget {
  final int initialTab;

  const LegalScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
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
          title: Text('Conditions legales',
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
            tabs: const [
              Tab(text: 'CGU'),
              Tab(text: 'Confidentialite'),
              Tab(text: 'Mentions'),
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
    return _LegalPage(
      lastUpdated: '1er mars 2026',
      sections: const [
        _LegalSection(
          title: 'Article 1 — Objet',
          body:
              'Les presentes Conditions Generales d\'Utilisation (ci-apres « CGU ») '
              'regissent l\'acces et l\'utilisation de l\'application mobile Amara '
              '(ci-apres « l\'Application ») editee par Amara Technologies SAS.\n\n'
              'L\'Application est destinee aux particuliers (ci-apres « le Client » '
              'ou « l\'Utilisateur ») souhaitant commander des repas aupres de '
              'restaurants partenaires pour une livraison a domicile ou un retrait '
              'sur place.',
        ),
        _LegalSection(
          title: 'Article 2 — Acceptation des CGU',
          body:
              'L\'inscription et l\'utilisation de l\'Application impliquent '
              'l\'acceptation pleine et entiere des presentes CGU. L\'Utilisateur '
              'reconnait en avoir pris connaissance et s\'engage a les respecter.\n\n'
              'Amara Technologies se reserve le droit de modifier les presentes CGU '
              'a tout moment. Les modifications entrent en vigueur des leur '
              'publication dans l\'Application. L\'utilisation continuee de '
              'l\'Application apres modification vaut acceptation des nouvelles CGU.',
        ),
        _LegalSection(
          title: 'Article 3 — Inscription et compte',
          body:
              '3.1. Pour acceder aux services de l\'Application, l\'Utilisateur '
              'doit creer un compte en fournissant des informations exactes et '
              'completes (nom, adresse email, numero de telephone).\n\n'
              '3.2. L\'Utilisateur est seul responsable de la confidentialite '
              'de ses identifiants de connexion. Toute activite realisee depuis '
              'son compte est presumee effectuee par lui.\n\n'
              '3.3. L\'Utilisateur doit etre age d\'au moins 16 ans pour creer '
              'un compte. Les mineurs doivent obtenir l\'autorisation de leurs '
              'parents ou tuteurs legaux.\n\n'
              '3.4. En cas de suspicion d\'utilisation non autorisee, l\'Utilisateur '
              'doit en informer immediatement Amara Technologies a l\'adresse : '
              'support@amara-food.com.',
        ),
        _LegalSection(
          title: 'Article 4 — Services proposes',
          body:
              'L\'Application permet a l\'Utilisateur de :\n\n'
              '• Parcourir les restaurants partenaires et leurs menus\n'
              '• Consulter les fiches detaillees des plats (description, prix, allergenes)\n'
              '• Ajouter des articles au panier et passer commande\n'
              '• Choisir entre la livraison a domicile et le retrait en restaurant\n'
              '• Suivre l\'etat de sa commande en temps reel\n'
              '• Enregistrer ses adresses de livraison favorites\n'
              '• Consulter l\'historique de ses commandes\n'
              '• Laisser des avis et notes sur les restaurants\n'
              '• Recevoir des notifications sur l\'avancement de ses commandes\n'
              '• Beneficier de promotions et offres speciales',
        ),
        _LegalSection(
          title: 'Article 5 — Commandes et paiement',
          body:
              '5.1. L\'Utilisateur passe commande en selectionnant les articles '
              'souhaites dans le menu d\'un restaurant partenaire, puis en validant '
              'son panier.\n\n'
              '5.2. Les prix affiches dans l\'Application sont exprimes en Francs '
              'CFA (FCFA) et incluent le prix des articles. Les frais de livraison '
              'sont indiques separement avant la validation de la commande.\n\n'
              '5.3. Le paiement peut etre effectue par les moyens de paiement '
              'proposes dans l\'Application (paiement mobile, especes a la livraison, '
              'carte bancaire selon disponibilite).\n\n'
              '5.4. La commande est confirmee une fois le paiement accepte ou, en '
              'cas de paiement a la livraison, une fois la commande validee par '
              'le restaurant.',
        ),
        _LegalSection(
          title: 'Article 6 — Livraison',
          body:
              '6.1. Les delais de livraison indiques dans l\'Application sont '
              'estimatifs et peuvent varier en fonction de la distance, de la '
              'demande et des conditions de circulation.\n\n'
              '6.2. L\'Utilisateur doit s\'assurer de fournir une adresse de '
              'livraison exacte et d\'etre disponible pour recevoir sa commande.\n\n'
              '6.3. En cas d\'absence du Client lors de la livraison, le livreur '
              'tentera de le contacter. Si le Client reste injoignable, la commande '
              'pourra etre annulee sans remboursement des frais de livraison.\n\n'
              '6.4. Amara Technologies ne saurait etre tenue responsable des '
              'retards de livraison lies a des circonstances independantes de '
              'sa volonte (conditions meteo, embouteillages, force majeure).',
        ),
        _LegalSection(
          title: 'Article 7 — Annulation et remboursement',
          body:
              '7.1. L\'Utilisateur peut annuler sa commande tant que celle-ci '
              'n\'a pas ete acceptee par le restaurant.\n\n'
              '7.2. Une fois la commande acceptee et en preparation, l\'annulation '
              'n\'est plus possible sauf accord du restaurant.\n\n'
              '7.3. En cas de probleme avec la commande (article manquant, erreur, '
              'qualite non conforme), l\'Utilisateur peut signaler le probleme via '
              'l\'Application dans un delai de 24 heures. Amara Technologies '
              'etudiera la reclamation et pourra proposer un remboursement partiel '
              'ou total, un avoir, ou une nouvelle livraison.\n\n'
              '7.4. Les remboursements sont effectues par le meme moyen de paiement '
              'que celui utilise lors de la commande, dans un delai de 5 a 10 jours '
              'ouvrables.',
        ),
        _LegalSection(
          title: 'Article 8 — Obligations de l\'Utilisateur',
          body:
              'L\'Utilisateur s\'engage a :\n\n'
              '• Fournir des informations exactes lors de l\'inscription et de la commande\n'
              '• Utiliser l\'Application de maniere loyale et conforme aux presentes CGU\n'
              '• Ne pas utiliser l\'Application a des fins frauduleuses ou illicites\n'
              '• Ne pas publier de contenu injurieux, diffamatoire ou contraire aux bonnes moeurs dans les avis\n'
              '• Respecter les livreurs et le personnel des restaurants partenaires\n'
              '• Ne pas tenter de contourner les systemes de securite de l\'Application',
        ),
        _LegalSection(
          title: 'Article 9 — Propriete intellectuelle',
          body:
              '9.1. L\'Application, son design, ses fonctionnalites, ses algorithmes, '
              'son code source et l\'ensemble des contenus associes sont la propriete '
              'exclusive d\'Amara Technologies SAS et sont proteges par les lois '
              'relatives a la propriete intellectuelle.\n\n'
              '9.2. Toute reproduction, representation, modification ou distribution '
              'de l\'Application ou de ses contenus, en tout ou en partie, sans '
              'autorisation prealable ecrite, est interdite.',
        ),
        _LegalSection(
          title: 'Article 10 — Responsabilite',
          body:
              '10.1. Amara Technologies agit en tant qu\'intermediaire entre '
              'l\'Utilisateur et les restaurants partenaires. La preparation et '
              'la qualite des plats relevent de la seule responsabilite des '
              'restaurants.\n\n'
              '10.2. Amara Technologies s\'efforce d\'assurer la disponibilite et '
              'le bon fonctionnement de l\'Application, sans garantir une '
              'disponibilite ininterrompue.\n\n'
              '10.3. Amara Technologies ne saurait etre tenue responsable des '
              'dommages directs ou indirects resultant de l\'utilisation ou de '
              'l\'impossibilite d\'utiliser l\'Application.',
        ),
        _LegalSection(
          title: 'Article 11 — Suspension et resiliation',
          body:
              '11.1. Amara Technologies peut suspendre ou supprimer le compte '
              'de l\'Utilisateur en cas de :\n\n'
              '• Violation des presentes CGU\n'
              '• Comportement frauduleux ou abusif\n'
              '• Avis de contenus offensants repetes\n'
              '• Non-paiement des commandes\n\n'
              '11.2. L\'Utilisateur peut supprimer son compte a tout moment en '
              'contactant le support Amara a support@amara-food.com ou depuis '
              'les parametres de l\'Application.',
        ),
        _LegalSection(
          title: 'Article 12 — Droit applicable et litiges',
          body:
              'Les presentes CGU sont regies par le droit ivoirien. En cas de '
              'litige relatif a l\'interpretation ou a l\'execution des presentes, '
              'les parties s\'efforceront de trouver une solution amiable. A defaut, '
              'le litige sera soumis aux tribunaux competents d\'Abidjan, '
              'Cote d\'Ivoire.',
        ),
      ],
    );
  }
}

// ─── Politique de Confidentialite ────────────────────────────────────────────

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return _LegalPage(
      lastUpdated: '1er mars 2026',
      sections: const [
        _LegalSection(
          title: 'Article 1 — Responsable du traitement',
          body:
              'Le responsable du traitement des donnees personnelles collectees '
              'via l\'Application Amara est :\n\n'
              'Amara Technologies SAS\n'
              'Siege social : Abidjan, Cote d\'Ivoire\n'
              'Email : privacy@amara-food.com',
        ),
        _LegalSection(
          title: 'Article 2 — Donnees collectees',
          body:
              'Dans le cadre de l\'utilisation de l\'Application, les donnees '
              'suivantes sont collectees :\n\n'
              '• Donnees d\'identification : nom, prenom, adresse email, numero de telephone\n'
              '• Donnees de livraison : adresses enregistrees, instructions de livraison\n'
              '• Donnees de commandes : historique des commandes, articles commandes, montants\n'
              '• Donnees de paiement : mode de paiement utilise (les donnees bancaires ne sont pas stockees par Amara)\n'
              '• Donnees de geolocalisation : position pour la livraison (avec consentement)\n'
              '• Donnees d\'utilisation : restaurants favoris, preferences alimentaires\n'
              '• Donnees techniques : adresse IP, type d\'appareil, version de l\'application, logs de connexion\n'
              '• Avis et evaluations : notes et commentaires laisses sur les restaurants',
        ),
        _LegalSection(
          title: 'Article 3 — Finalites du traitement',
          body:
              'Les donnees collectees sont utilisees pour :\n\n'
              '• Creer et gerer le compte de l\'Utilisateur\n'
              '• Traiter et suivre les commandes\n'
              '• Assurer la livraison a l\'adresse indiquee\n'
              '• Permettre le paiement securise\n'
              '• Envoyer des notifications sur l\'etat des commandes\n'
              '• Proposer des recommandations personnalisees de restaurants et de plats\n'
              '• Envoyer des offres promotionnelles (avec consentement)\n'
              '• Ameliorer l\'Application et l\'experience utilisateur\n'
              '• Assurer la securite de la plateforme et prevenir la fraude\n'
              '• Repondre aux demandes du support client\n'
              '• Respecter les obligations legales et reglementaires',
        ),
        _LegalSection(
          title: 'Article 4 — Base legale du traitement',
          body:
              'Le traitement des donnees personnelles est fonde sur :\n\n'
              '• L\'execution du contrat : traitement des commandes, livraison, paiement\n'
              '• Le consentement de l\'Utilisateur : geolocalisation, notifications marketing, cookies\n'
              '• L\'interet legitime d\'Amara Technologies : amelioration des services, prevention de la fraude, statistiques anonymisees\n'
              '• Le respect des obligations legales : comptabilite, fiscalite',
        ),
        _LegalSection(
          title: 'Article 5 — Partage des donnees',
          body:
              'Les donnees personnelles peuvent etre partagees avec :\n\n'
              '• Les restaurants partenaires : nom, adresse de livraison et details de la commande (necessaire pour la preparation)\n'
              '• Les livreurs : nom, adresse de livraison et numero de telephone (necessaire pour la livraison)\n'
              '• Les prestataires de paiement : informations necessaires au traitement du paiement\n'
              '• Les equipes internes d\'Amara Technologies : support, technique, marketing\n'
              '• Les prestataires techniques : hebergement, infrastructure cloud\n'
              '• Les autorites competentes en cas d\'obligation legale\n\n'
              'Amara Technologies ne vend ni ne loue les donnees personnelles '
              'de l\'Utilisateur a des tiers a des fins commerciales.',
        ),
        _LegalSection(
          title: 'Article 6 — Duree de conservation',
          body:
              'Les donnees personnelles sont conservees pendant :\n\n'
              '• Donnees de compte : pendant toute la duree d\'utilisation du compte, puis 3 ans apres la suppression\n'
              '• Donnees de commandes : 5 ans a compter de la date de la commande (obligation comptable)\n'
              '• Donnees de geolocalisation : duree de la session de commande uniquement\n'
              '• Donnees techniques (logs) : 12 mois\n'
              '• Avis et evaluations : tant que le compte est actif ou jusqu\'a demande de suppression\n\n'
              'A l\'expiration de ces delais, les donnees sont supprimees ou '
              'anonymisees de maniere irreversible.',
        ),
        _LegalSection(
          title: 'Article 7 — Securite des donnees',
          body:
              'Amara Technologies met en oeuvre les mesures techniques et '
              'organisationnelles appropriees pour proteger les donnees '
              'personnelles, notamment :\n\n'
              '• Chiffrement des donnees en transit (HTTPS/TLS)\n'
              '• Chiffrement des mots de passe (hachage bcrypt)\n'
              '• Authentification par token securise\n'
              '• Stockage securise des informations sensibles sur l\'appareil\n'
              '• Acces restreint aux donnees selon le principe du moindre privilege\n'
              '• Hebergement sur infrastructure cloud certifiee',
        ),
        _LegalSection(
          title: 'Article 8 — Droits de l\'Utilisateur',
          body:
              'Conformement a la reglementation applicable, l\'Utilisateur '
              'dispose des droits suivants :\n\n'
              '• Droit d\'acces : obtenir la confirmation du traitement de ses donnees et en obtenir une copie\n'
              '• Droit de rectification : faire corriger les donnees inexactes ou incompletes\n'
              '• Droit de suppression : demander l\'effacement de ses donnees dans les conditions prevues par la loi\n'
              '• Droit a la portabilite : recevoir ses donnees dans un format structure et couramment utilise\n'
              '• Droit d\'opposition : s\'opposer au traitement de ses donnees pour des motifs legitimes\n'
              '• Droit a la limitation : demander la suspension du traitement dans certains cas\n'
              '• Droit de retrait du consentement : retirer son consentement a tout moment pour les traitements bases sur celui-ci\n\n'
              'Pour exercer ces droits, l\'Utilisateur peut adresser sa demande a :\n'
              'privacy@amara-food.com\n\n'
              'Amara Technologies s\'engage a repondre dans un delai de 30 jours.',
        ),
        _LegalSection(
          title: 'Article 9 — Geolocalisation',
          body:
              'L\'Application peut utiliser la geolocalisation de l\'appareil '
              'de l\'Utilisateur pour :\n\n'
              '• Identifier les restaurants a proximite\n'
              '• Estimer les delais et frais de livraison\n'
              '• Permettre le suivi de la livraison en temps reel\n\n'
              'L\'acces a la geolocalisation est soumis au consentement de '
              'l\'Utilisateur via les parametres de son appareil. L\'Utilisateur '
              'peut desactiver la geolocalisation a tout moment, mais certaines '
              'fonctionnalites pourront etre limitees.',
        ),
        _LegalSection(
          title: 'Article 10 — Notifications',
          body:
              'L\'Application peut envoyer des notifications push pour :\n\n'
              '• Informer de l\'avancement d\'une commande (confirmation, preparation, livraison)\n'
              '• Signaler des promotions ou offres speciales\n'
              '• Communiquer des informations importantes relatives au compte\n\n'
              'L\'Utilisateur peut gerer ses preferences de notification depuis '
              'les parametres de son appareil.',
        ),
        _LegalSection(
          title: 'Article 11 — Modification de la politique',
          body:
              'Amara Technologies se reserve le droit de modifier la presente '
              'politique de confidentialite a tout moment. L\'Utilisateur sera '
              'informe de toute modification substantielle par notification dans '
              'l\'Application. L\'utilisation continuee de l\'Application apres '
              'modification vaut acceptation de la politique mise a jour.',
        ),
      ],
    );
  }
}

// ─── Mentions Legales ────────────────────────────────────────────────────────

class _LegalNoticesContent extends StatelessWidget {
  const _LegalNoticesContent();

  @override
  Widget build(BuildContext context) {
    return _LegalPage(
      lastUpdated: '1er mars 2026',
      sections: const [
        _LegalSection(
          title: 'Editeur de l\'Application',
          body:
              'Amara Technologies SAS\n'
              'Societe par Actions Simplifiee au capital de 1 000 000 FCFA\n'
              'Siege social : Abidjan, Cocody, Cote d\'Ivoire\n'
              'RCCM : CI-ABJ-2026-B-XXXXX\n\n'
              'Directeur de la publication : Equipe Amara Technologies\n'
              'Email : contact@amara-food.com\n'
              'Telephone : +225 XX XX XX XX XX',
        ),
        _LegalSection(
          title: 'Hebergement',
          body:
              'L\'Application et ses donnees sont hebergees par :\n\n'
              'Convex, Inc.\n'
              'San Francisco, CA, Etats-Unis\n'
              'Site web : https://convex.dev\n\n'
              'Infrastructure cloud : Region EU-West-1 (Union Europeenne)\n\n'
              'Distribution de l\'Application :\n'
              '• Apple App Store (iOS) — Apple Inc.\n'
              '• Google Play Store (Android) — Google LLC',
        ),
        _LegalSection(
          title: 'Propriete intellectuelle',
          body:
              'L\'ensemble des elements composant l\'Application Amara '
              '(design, textes, logos, icones, images, fonctionnalites, code source) '
              'est la propriete exclusive d\'Amara Technologies SAS ou fait l\'objet '
              'd\'une autorisation d\'utilisation.\n\n'
              'Toute reproduction, representation, modification ou distribution, '
              'totale ou partielle, des elements de l\'Application sans '
              'autorisation prealable ecrite d\'Amara Technologies est interdite '
              'et constitue une contrefacon sanctionnee par la loi.\n\n'
              'La marque « Amara » ainsi que le logo associe sont des marques '
              'deposees. Leur utilisation non autorisee est strictement interdite.',
        ),
        _LegalSection(
          title: 'Donnees personnelles',
          body:
              'Amara Technologies s\'engage a respecter la legislation en vigueur '
              'relative a la protection des donnees personnelles.\n\n'
              'Pour toute question relative au traitement de vos donnees '
              'personnelles, veuillez consulter notre Politique de confidentialite '
              'accessible depuis l\'onglet « Confidentialite » de cette page, ou '
              'nous contacter a : privacy@amara-food.com.\n\n'
              'Autorite de controle : Commission Nationale de l\'Informatique '
              'et des Libertes de Cote d\'Ivoire (ARTCI).',
        ),
        _LegalSection(
          title: 'Limitation de responsabilite',
          body:
              'Amara Technologies agit en tant que plateforme d\'intermediation '
              'entre les Utilisateurs et les restaurants partenaires.\n\n'
              'Amara Technologies ne pourra etre tenue responsable :\n\n'
              '• De la qualite, du gout ou de la conformite des plats prepares par les restaurants\n'
              '• Des allergenes non declares par les restaurants partenaires\n'
              '• Des retards de livraison lies a des circonstances exterieures\n'
              '• Des interruptions temporaires du service pour maintenance ou mise a jour\n'
              '• De tout dysfonctionnement lie a l\'appareil ou au reseau de l\'Utilisateur\n'
              '• Des pertes ou dommages indirects lies a l\'utilisation de l\'Application',
        ),
        _LegalSection(
          title: 'Droit applicable',
          body:
              'Les presentes mentions legales sont regies par le droit ivoirien.\n\n'
              'Pour toute reclamation, vous pouvez nous contacter :\n'
              '• Par email : support@amara-food.com\n'
              '• Par courrier : Amara Technologies SAS, Abidjan, Cocody, Cote d\'Ivoire\n\n'
              'En cas de litige, les parties s\'efforceront de trouver une '
              'solution amiable prealablement a toute action judiciaire. A defaut '
              'd\'accord amiable, les tribunaux d\'Abidjan seront competents.',
        ),
        _LegalSection(
          title: 'Credits',
          body:
              '• Design et developpement : Amara Technologies SAS\n'
              '• Framework : Flutter (Google)\n'
              '• Typographie : Urbanist (Google Fonts)\n'
              '• Icones : Material Design Icons (Google)\n'
              '• Infrastructure : Convex (Convex, Inc.)',
        ),
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
                'Derniere mise a jour : $lastUpdated',
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
