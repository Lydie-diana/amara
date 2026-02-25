// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Amara';

  @override
  String get tagline => 'La saveur africaine, livrée chez vous';

  @override
  String get splashLoading => 'Chargement...';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboarding1Title => 'La cuisine africaine\nà portée de main';

  @override
  String get onboarding1Desc =>
      'Découvrez des centaines de plats authentiques préparés par les meilleurs restaurants africains de votre ville.';

  @override
  String get onboarding2Title => 'Livraison rapide\net fiable';

  @override
  String get onboarding2Desc =>
      'Suivez votre commande en temps réel et recevez vos plats chauds directement à votre porte en moins de 45 min.';

  @override
  String get onboarding3Title => 'Paiement simple\net sécurisé';

  @override
  String get onboarding3Desc =>
      'Mobile Money, carte bancaire ou cash — choisissez le moyen de paiement qui vous convient.';

  @override
  String get authWelcomeTo => 'Bienvenue sur';

  @override
  String get authPhoneTitle => 'Amara 🍛';

  @override
  String get authPhoneSubtitle =>
      'Entrez votre numéro de téléphone\npour continuer';

  @override
  String get authPhoneHint => '06 00 00 00 00';

  @override
  String get authPhoneSmsInfo =>
      'Un code de vérification sera envoyé par SMS sur ce numéro.';

  @override
  String get authContinue => 'Continuer';

  @override
  String get authOrWith => 'ou continuer avec';

  @override
  String get authGoogleButton => 'Continuer avec Google';

  @override
  String get otpTitle => 'Vérification';

  @override
  String otpSubtitle(String phone) {
    return 'Code envoyé au\n$phone';
  }

  @override
  String otpResendIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get otpResend => 'Renvoyer le code';

  @override
  String get otpVerify => 'Vérifier';

  @override
  String get otpError => 'Code incorrect, réessayez';

  @override
  String get otpResent => 'Code renvoyé !';

  @override
  String get profileTitle => 'Votre profil';

  @override
  String get profileSubtitle => 'Dites-nous comment vous appeler';

  @override
  String get profileNameLabel => 'Prénom et nom *';

  @override
  String get profileNameHint => 'ex: Kofi Mensah';

  @override
  String get profileEmailLabel => 'Email (optionnel)';

  @override
  String get profileEmailHint => 'votre@email.com';

  @override
  String get profileSave => 'C\'est parti ! 🚀';

  @override
  String get profileNameRequired => 'Ce champ est requis';

  @override
  String get profileNameTooShort => 'Minimum 2 caractères';

  @override
  String get profileEmailInvalid => 'Email invalide';

  @override
  String homeGreeting(String name) {
    return 'Bonne journée, $name 👋';
  }

  @override
  String get homeLocation => 'Abidjan, Côte d\'Ivoire';

  @override
  String get homeSearchHint => 'Chercher un restaurant, un plat...';

  @override
  String get homeCuisines => 'Cuisines';

  @override
  String get homePopular => 'Populaires près de vous';

  @override
  String get homeNew => 'Nouveaux arrivants';

  @override
  String get homeSeeAll => 'Voir tout';

  @override
  String get categoryAll => 'Tout';

  @override
  String get categoryStew => 'Ragoût';

  @override
  String get categoryGrill => 'Grillades';

  @override
  String get categoryRice => 'Riz';

  @override
  String get categorySalad => 'Salade';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryBurger => 'Burger';

  @override
  String get categoryDrink => 'Boisson';

  @override
  String get categoryDessert => 'Dessert';

  @override
  String get restaurantOpen => 'Ouvert';

  @override
  String get restaurantClosed => 'Fermé';

  @override
  String get restaurantFeatured => '⭐ Populaire';

  @override
  String get restaurantFreeDelivery => 'Gratuit';

  @override
  String get navHome => 'Accueil';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navProfile => 'Profil';

  @override
  String get promoTag1 => 'OFFRE SPÉCIALE';

  @override
  String get promoTitle1 => 'Livraison gratuite';

  @override
  String get promoSubtitle1 => 'Sur votre 1ère commande';

  @override
  String get promoTag2 => 'NOUVEAU';

  @override
  String get promoTitle2 => 'Cuisine africaine';

  @override
  String get promoSubtitle2 => 'Authenticité à portée de main';

  @override
  String get promoTag3 => 'PROMO';

  @override
  String get promoTitle3 => '-20% ce soir';

  @override
  String get promoSubtitle3 => 'Restaurants partenaires sélectionnés';

  @override
  String get pageNotFound => 'Page introuvable';

  @override
  String get errorRequired => 'Ce champ est requis';

  @override
  String get errorNetwork => 'Erreur réseau, réessayez';

  @override
  String get errorGeneric => 'Une erreur est survenue';
}
