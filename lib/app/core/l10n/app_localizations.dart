import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'Amara'**
  String get appName;

  /// Slogan de l'application
  ///
  /// In fr, this message translates to:
  /// **'La saveur africaine, livrée chez vous'**
  String get tagline;

  /// No description provided for @splashLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get splashLoading;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// No description provided for @onboarding1Title.
  ///
  /// In fr, this message translates to:
  /// **'La cuisine africaine\nà portée de main'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez des centaines de plats authentiques préparés par les meilleurs restaurants africains de votre ville.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In fr, this message translates to:
  /// **'Livraison rapide\net fiable'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In fr, this message translates to:
  /// **'Suivez votre commande en temps réel et recevez vos plats chauds directement à votre porte en moins de 45 min.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In fr, this message translates to:
  /// **'Paiement simple\net sécurisé'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money, carte bancaire ou cash — choisissez le moyen de paiement qui vous convient.'**
  String get onboarding3Desc;

  /// No description provided for @authWelcomeTo.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur'**
  String get authWelcomeTo;

  /// No description provided for @authPhoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Amara 🍛'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre numéro de téléphone\npour continuer'**
  String get authPhoneSubtitle;

  /// No description provided for @authPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'06 00 00 00 00'**
  String get authPhoneHint;

  /// No description provided for @authPhoneSmsInfo.
  ///
  /// In fr, this message translates to:
  /// **'Un code de vérification sera envoyé par SMS sur ce numéro.'**
  String get authPhoneSmsInfo;

  /// No description provided for @authContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get authContinue;

  /// No description provided for @authOrWith.
  ///
  /// In fr, this message translates to:
  /// **'ou continuer avec'**
  String get authOrWith;

  /// No description provided for @authGoogleButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get authGoogleButton;

  /// No description provided for @otpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé au\n{phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpResendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get otpResend;

  /// No description provided for @otpVerify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get otpVerify;

  /// No description provided for @otpError.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect, réessayez'**
  String get otpError;

  /// No description provided for @otpResent.
  ///
  /// In fr, this message translates to:
  /// **'Code renvoyé !'**
  String get otpResent;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre profil'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Dites-nous comment vous appeler'**
  String get profileSubtitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom et nom *'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex: Kofi Mensah'**
  String get profileNameHint;

  /// No description provided for @profileEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email (optionnel)'**
  String get profileEmailLabel;

  /// No description provided for @profileEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get profileEmailHint;

  /// No description provided for @profileSave.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti ! 🚀'**
  String get profileSave;

  /// No description provided for @profileNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get profileNameRequired;

  /// No description provided for @profileNameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 2 caractères'**
  String get profileNameTooShort;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get profileEmailInvalid;

  /// No description provided for @homeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonne journée, {name} 👋'**
  String homeGreeting(String name);

  /// No description provided for @homeLocation.
  ///
  /// In fr, this message translates to:
  /// **'Abidjan, Côte d\'Ivoire'**
  String get homeLocation;

  /// No description provided for @homeSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Chercher un restaurant, un plat...'**
  String get homeSearchHint;

  /// No description provided for @homeCuisines.
  ///
  /// In fr, this message translates to:
  /// **'Cuisines'**
  String get homeCuisines;

  /// No description provided for @homePopular.
  ///
  /// In fr, this message translates to:
  /// **'Populaires près de vous'**
  String get homePopular;

  /// No description provided for @homeNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux arrivants'**
  String get homeNew;

  /// No description provided for @homeSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get homeSeeAll;

  /// No description provided for @categoryAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get categoryAll;

  /// No description provided for @categoryStew.
  ///
  /// In fr, this message translates to:
  /// **'Ragoût'**
  String get categoryStew;

  /// No description provided for @categoryGrill.
  ///
  /// In fr, this message translates to:
  /// **'Grillades'**
  String get categoryGrill;

  /// No description provided for @categoryRice.
  ///
  /// In fr, this message translates to:
  /// **'Riz'**
  String get categoryRice;

  /// No description provided for @categorySalad.
  ///
  /// In fr, this message translates to:
  /// **'Salade'**
  String get categorySalad;

  /// No description provided for @categoryPizza.
  ///
  /// In fr, this message translates to:
  /// **'Pizza'**
  String get categoryPizza;

  /// No description provided for @categoryBurger.
  ///
  /// In fr, this message translates to:
  /// **'Burger'**
  String get categoryBurger;

  /// No description provided for @categoryDrink.
  ///
  /// In fr, this message translates to:
  /// **'Boisson'**
  String get categoryDrink;

  /// No description provided for @categoryDessert.
  ///
  /// In fr, this message translates to:
  /// **'Dessert'**
  String get categoryDessert;

  /// No description provided for @categoryChicken.
  ///
  /// In fr, this message translates to:
  /// **'Poulet'**
  String get categoryChicken;

  /// No description provided for @categoryFish.
  ///
  /// In fr, this message translates to:
  /// **'Poisson'**
  String get categoryFish;

  /// No description provided for @categoryVegetarian.
  ///
  /// In fr, this message translates to:
  /// **'Végétarien'**
  String get categoryVegetarian;

  /// No description provided for @categoryPasta.
  ///
  /// In fr, this message translates to:
  /// **'Pâtes'**
  String get categoryPasta;

  /// No description provided for @categorySpicy.
  ///
  /// In fr, this message translates to:
  /// **'Épicé'**
  String get categorySpicy;

  /// No description provided for @categoryLocal.
  ///
  /// In fr, this message translates to:
  /// **'Plats locaux'**
  String get categoryLocal;

  /// No description provided for @categoryAfrican.
  ///
  /// In fr, this message translates to:
  /// **'Africain'**
  String get categoryAfrican;

  /// No description provided for @restaurantOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get restaurantOpen;

  /// No description provided for @restaurantClosed.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get restaurantClosed;

  /// No description provided for @restaurantFeatured.
  ///
  /// In fr, this message translates to:
  /// **'⭐ Populaire'**
  String get restaurantFeatured;

  /// No description provided for @restaurantFreeDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get restaurantFreeDelivery;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get navExplore;

  /// No description provided for @navOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @promoTag1.
  ///
  /// In fr, this message translates to:
  /// **'OFFRE SPÉCIALE'**
  String get promoTag1;

  /// No description provided for @promoTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Livraison gratuite'**
  String get promoTitle1;

  /// No description provided for @promoSubtitle1.
  ///
  /// In fr, this message translates to:
  /// **'Sur votre 1ère commande'**
  String get promoSubtitle1;

  /// No description provided for @promoTag2.
  ///
  /// In fr, this message translates to:
  /// **'NOUVEAU'**
  String get promoTag2;

  /// No description provided for @promoTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine africaine'**
  String get promoTitle2;

  /// No description provided for @promoSubtitle2.
  ///
  /// In fr, this message translates to:
  /// **'Authenticité à portée de main'**
  String get promoSubtitle2;

  /// No description provided for @promoTag3.
  ///
  /// In fr, this message translates to:
  /// **'PROMO'**
  String get promoTag3;

  /// No description provided for @promoTitle3.
  ///
  /// In fr, this message translates to:
  /// **'-20% ce soir'**
  String get promoTitle3;

  /// No description provided for @promoSubtitle3.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants partenaires sélectionnés'**
  String get promoSubtitle3;

  /// No description provided for @pageNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Page introuvable'**
  String get pageNotFound;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get errorRequired;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau, réessayez'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorGeneric;

  /// No description provided for @profileScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get profileScreenTitle;

  /// No description provided for @profileMenuPersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profileMenuPersonalInfo;

  /// No description provided for @profileMenuFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get profileMenuFavorites;

  /// No description provided for @profileMenuAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Mes adresses'**
  String get profileMenuAddresses;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileMenuLanguage;

  /// No description provided for @profileMenuHelpFaq.
  ///
  /// In fr, this message translates to:
  /// **'Aide & FAQ'**
  String get profileMenuHelpFaq;

  /// No description provided for @profileMenuLegal.
  ///
  /// In fr, this message translates to:
  /// **'Legal'**
  String get profileMenuLegal;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileNotLoggedInTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous'**
  String get profileNotLoggedInTitle;

  /// No description provided for @profileNotLoggedInSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à votre profil, vos commandes et vos favoris.'**
  String get profileNotLoggedInSubtitle;

  /// No description provided for @profileNotLoggedInButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get profileNotLoggedInButton;

  /// No description provided for @languageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la langue de l\'application'**
  String get languageSubtitle;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get languageEnglish;

  /// No description provided for @homeHeaderQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Qu\'est-ce qui vous\nfait envie aujourd\'hui ?'**
  String get homeHeaderQuestion;

  /// No description provided for @homeCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get homeCategories;

  /// No description provided for @homeAllRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Tous les restaurants'**
  String get homeAllRestaurants;

  /// No description provided for @homeErrorLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les restaurants. Vérifiez votre connexion.'**
  String get homeErrorLoad;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant\ndans votre secteur'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Essayez de modifier votre adresse\nou revenez plus tard.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeEmptyAction.
  ///
  /// In fr, this message translates to:
  /// **'Changer de secteur'**
  String get homeEmptyAction;

  /// No description provided for @homeEmptyCategoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant\npour cette catégorie'**
  String get homeEmptyCategoryTitle;

  /// No description provided for @homeEmptyCategorySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Essayez une autre catégorie'**
  String get homeEmptyCategorySubtitle;

  /// No description provided for @homeEmptyCategoryAction.
  ///
  /// In fr, this message translates to:
  /// **'Voir tous les restaurants'**
  String get homeEmptyCategoryAction;

  /// No description provided for @cartMyCart.
  ///
  /// In fr, this message translates to:
  /// **'Mon panier'**
  String get cartMyCart;

  /// No description provided for @cartRestaurantCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 restaurant} other{{count} restaurants}}'**
  String cartRestaurantCount(int count);

  /// No description provided for @cartItemCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 article} other{{count} articles}}'**
  String cartItemCount(int count);

  /// No description provided for @authLoginTab.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authLoginTab;

  /// No description provided for @authSignupTab.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get authSignupTab;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour découvrir les saveurs africaines.'**
  String get authLoginSubtitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte et commencez à commander.'**
  String get authSignupSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'amanda.samantha@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'••••••••'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLoginButton;

  /// No description provided for @authFullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Jean Kouassi'**
  String get authFullNameHint;

  /// No description provided for @authPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneFieldHint.
  ///
  /// In fr, this message translates to:
  /// **'+225 07 00 00 00 00'**
  String get authPhoneFieldHint;

  /// No description provided for @authPasswordMinHint.
  ///
  /// In fr, this message translates to:
  /// **'Min. 6 caractères'**
  String get authPasswordMinHint;

  /// No description provided for @authSignupButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get authSignupButton;

  /// No description provided for @authOrContinueWith.
  ///
  /// In fr, this message translates to:
  /// **'ou continuer avec'**
  String get authOrContinueWith;

  /// No description provided for @authEmailAndPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Email et mot de passe requis'**
  String get authEmailAndPasswordRequired;

  /// No description provided for @authAllFieldsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Tous les champs sont requis'**
  String get authAllFieldsRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit avoir au moins 6 caractères'**
  String get authPasswordMinLength;

  /// No description provided for @authLoginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get authLoginError;

  /// No description provided for @authSignupError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'inscription'**
  String get authSignupError;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email pour recevoir un code de vérification.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authSendCode.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get authSendCode;

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get authNewPasswordTitle;

  /// No description provided for @authNewPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un nouveau mot de passe sécurisé.'**
  String get authNewPasswordSubtitle;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get authNewPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authResetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get authResetPassword;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get authPasswordMismatch;

  /// No description provided for @authOtpSubtitleEmail.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé à\n{email}'**
  String authOtpSubtitleEmail(String email);

  /// No description provided for @authCodeResent.
  ///
  /// In fr, this message translates to:
  /// **'Code renvoyé à {email}'**
  String authCodeResent(String email);

  /// No description provided for @authSendFailed.
  ///
  /// In fr, this message translates to:
  /// **'Envoi échoué'**
  String get authSendFailed;

  /// No description provided for @authOtpIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect, réessayez'**
  String get authOtpIncorrect;

  /// No description provided for @authOtpNetworkError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Vérifiez votre connexion et réessayez.'**
  String get authOtpNetworkError;

  /// No description provided for @authResendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans '**
  String get authResendIn;

  /// No description provided for @authResendCode.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get authResendCode;

  /// No description provided for @authVerify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get authVerify;

  /// No description provided for @authVerification.
  ///
  /// In fr, this message translates to:
  /// **'Vérification'**
  String get authVerification;

  /// No description provided for @authEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un email valide'**
  String get authEmailInvalid;

  /// No description provided for @authForgotPasswordDesc.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre adresse email pour recevoir un code de réinitialisation.'**
  String get authForgotPasswordDesc;

  /// No description provided for @authNewPasswordDesc.
  ///
  /// In fr, this message translates to:
  /// **'Définissez votre nouveau mot de passe pour {email}'**
  String authNewPasswordDesc(String email);

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé avec succès'**
  String get authPasswordResetSuccess;

  /// No description provided for @ordersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get ordersTitle;

  /// No description provided for @ordersTabPastItems.
  ///
  /// In fr, this message translates to:
  /// **'Anciens articles'**
  String get ordersTabPastItems;

  /// No description provided for @ordersTabOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get ordersTabOrders;

  /// No description provided for @ordersDeliveryFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de livraison : {fee} · {time}'**
  String ordersDeliveryFee(String fee, String time);

  /// No description provided for @ordersStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get ordersStatusPending;

  /// No description provided for @ordersStatusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmee'**
  String get ordersStatusConfirmed;

  /// No description provided for @ordersStatusPreparing.
  ///
  /// In fr, this message translates to:
  /// **'En preparation'**
  String get ordersStatusPreparing;

  /// No description provided for @ordersStatusReady.
  ///
  /// In fr, this message translates to:
  /// **'Prete'**
  String get ordersStatusReady;

  /// No description provided for @ordersStatusPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Recuperee'**
  String get ordersStatusPickedUp;

  /// No description provided for @ordersStatusDelivering.
  ///
  /// In fr, this message translates to:
  /// **'En livraison'**
  String get ordersStatusDelivering;

  /// No description provided for @ordersStatusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livree'**
  String get ordersStatusDelivered;

  /// No description provided for @ordersStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulee'**
  String get ordersStatusCancelled;

  /// No description provided for @ordersStatusUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnue'**
  String get ordersStatusUnknown;

  /// No description provided for @ordersToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get ordersToday;

  /// No description provided for @ordersYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get ordersYesterday;

  /// No description provided for @ordersItemCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 article} other{{count} articles}}'**
  String ordersItemCount(int count);

  /// No description provided for @ordersCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la commande ?'**
  String get ordersCancelTitle;

  /// No description provided for @ordersCancelMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant n\'a pas encore accepte votre commande. Voulez-vous l\'annuler ?'**
  String get ordersCancelMessage;

  /// No description provided for @ordersCancelNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get ordersCancelNo;

  /// No description provided for @ordersCancelYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui, annuler'**
  String get ordersCancelYes;

  /// No description provided for @ordersCancelledByClient.
  ///
  /// In fr, this message translates to:
  /// **'Annulee par le client'**
  String get ordersCancelledByClient;

  /// No description provided for @ordersCancelledSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulee'**
  String get ordersCancelledSuccess;

  /// No description provided for @ordersCancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get ordersCancelButton;

  /// No description provided for @ordersReorderButton.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get ordersReorderButton;

  /// No description provided for @ordersLoginRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connexion requise'**
  String get ordersLoginRequired;

  /// No description provided for @ordersLoginMessage.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour voir vos commandes'**
  String get ordersLoginMessage;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vos futures commandes apparaitront ici'**
  String get ordersEmptyMessage;

  /// No description provided for @ordersConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get ordersConnectionError;

  /// No description provided for @orderTrackingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de commande'**
  String get orderTrackingTitle;

  /// No description provided for @orderTrackingPickupOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commande à emporter'**
  String get orderTrackingPickupOrder;

  /// No description provided for @orderTrackingClientInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations client'**
  String get orderTrackingClientInfo;

  /// No description provided for @orderTrackingRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant'**
  String get orderTrackingRestaurant;

  /// No description provided for @orderTrackingRestaurantAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du restaurant'**
  String get orderTrackingRestaurantAddress;

  /// No description provided for @orderTrackingSeeOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get orderTrackingSeeOnMap;

  /// No description provided for @orderTrackingRecipientName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du destinataire'**
  String get orderTrackingRecipientName;

  /// No description provided for @orderTrackingPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get orderTrackingPhone;

  /// No description provided for @orderTrackingPhoneNotProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get orderTrackingPhoneNotProvided;

  /// No description provided for @orderTrackingConfirmPickup.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai recupere ma commande'**
  String get orderTrackingConfirmPickup;

  /// No description provided for @orderTrackingOrderDetail.
  ///
  /// In fr, this message translates to:
  /// **'Detail de la commande'**
  String get orderTrackingOrderDetail;

  /// No description provided for @orderTrackingOrderCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Commande terminee · {date}'**
  String orderTrackingOrderCompleted(String date);

  /// No description provided for @orderTrackingReviewSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Avis soumis — merci !'**
  String get orderTrackingReviewSubmitted;

  /// No description provided for @orderTrackingRateEstablishment.
  ///
  /// In fr, this message translates to:
  /// **'Noter cet etablissement'**
  String get orderTrackingRateEstablishment;

  /// No description provided for @orderTrackingDidYouLike.
  ///
  /// In fr, this message translates to:
  /// **'Avez-vous aime {name} ?'**
  String orderTrackingDidYouLike(String name);

  /// No description provided for @orderTrackingYourOrder.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande'**
  String get orderTrackingYourOrder;

  /// No description provided for @orderTrackingTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get orderTrackingTotal;

  /// No description provided for @orderTrackingViewReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Voir le reçu'**
  String get orderTrackingViewReceipt;

  /// No description provided for @orderTrackingYourDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Votre livraison'**
  String get orderTrackingYourDelivery;

  /// No description provided for @orderTrackingByDriver.
  ///
  /// In fr, this message translates to:
  /// **'par {name}'**
  String orderTrackingByDriver(String name);

  /// No description provided for @orderTrackingDefaultDriver.
  ///
  /// In fr, this message translates to:
  /// **'Livreur Amara'**
  String get orderTrackingDefaultDriver;

  /// No description provided for @orderTrackingReorder.
  ///
  /// In fr, this message translates to:
  /// **'Commander a nouveau'**
  String get orderTrackingReorder;

  /// No description provided for @orderTrackingOrderCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulee · {date}'**
  String orderTrackingOrderCancelled(String date);

  /// No description provided for @orderTrackingCancelledBadge.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande a ete annulee'**
  String get orderTrackingCancelledBadge;

  /// No description provided for @orderTrackingDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get orderTrackingDelivery;

  /// No description provided for @orderTrackingPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get orderTrackingPayment;

  /// No description provided for @orderTrackingPaymentMobileMoney.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money'**
  String get orderTrackingPaymentMobileMoney;

  /// No description provided for @orderTrackingPaymentCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte bancaire'**
  String get orderTrackingPaymentCard;

  /// No description provided for @orderTrackingPaymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Especes'**
  String get orderTrackingPaymentCash;

  /// No description provided for @orderTrackingPaymentNotSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Non spécifié'**
  String get orderTrackingPaymentNotSpecified;

  /// No description provided for @orderTrackingStepPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get orderTrackingStepPending;

  /// No description provided for @orderTrackingStepPreparation.
  ///
  /// In fr, this message translates to:
  /// **'Preparation'**
  String get orderTrackingStepPreparation;

  /// No description provided for @orderTrackingStepReady.
  ///
  /// In fr, this message translates to:
  /// **'Prete'**
  String get orderTrackingStepReady;

  /// No description provided for @orderTrackingStepDelivering.
  ///
  /// In fr, this message translates to:
  /// **'En livraison'**
  String get orderTrackingStepDelivering;

  /// No description provided for @orderTrackingStepDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livree'**
  String get orderTrackingStepDelivered;

  /// No description provided for @orderTrackingStepOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Commandee'**
  String get orderTrackingStepOrdered;

  /// No description provided for @orderTrackingStepPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Recuperee'**
  String get orderTrackingStepPickedUp;

  /// No description provided for @orderTrackingChefCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulee'**
  String get orderTrackingChefCancelled;

  /// No description provided for @orderTrackingChefPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente de confirmation'**
  String get orderTrackingChefPending;

  /// No description provided for @orderTrackingChefPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Le chef prepare votre commande'**
  String get orderTrackingChefPreparing;

  /// No description provided for @orderTrackingChefReady.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande est prete !'**
  String get orderTrackingChefReady;

  /// No description provided for @orderTrackingChefPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Commande recuperee !'**
  String get orderTrackingChefPickedUp;

  /// No description provided for @orderTrackingChefDelivering.
  ///
  /// In fr, this message translates to:
  /// **'Votre livreur est en route'**
  String get orderTrackingChefDelivering;

  /// No description provided for @orderTrackingChefDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Commande livree !'**
  String get orderTrackingChefDelivered;

  /// No description provided for @orderTrackingChefProcessing.
  ///
  /// In fr, this message translates to:
  /// **'En cours de traitement'**
  String get orderTrackingChefProcessing;

  /// No description provided for @orderTrackingSubCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande a ete annulee.'**
  String get orderTrackingSubCancelled;

  /// No description provided for @orderTrackingSubPendingPickup.
  ///
  /// In fr, this message translates to:
  /// **'{restaurant} va bientot confirmer votre commande.'**
  String orderTrackingSubPendingPickup(String restaurant);

  /// No description provided for @orderTrackingSubPreparingPickup.
  ///
  /// In fr, this message translates to:
  /// **'Votre repas sera pret dans ~{minutes} min.'**
  String orderTrackingSubPreparingPickup(int minutes);

  /// No description provided for @orderTrackingSubReadyPickup.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous chez {restaurant} pour recuperer votre commande !'**
  String orderTrackingSubReadyPickup(String restaurant);

  /// No description provided for @orderTrackingSubPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Bon appetit !'**
  String get orderTrackingSubPickedUp;

  /// No description provided for @orderTrackingSubPendingDelivery.
  ///
  /// In fr, this message translates to:
  /// **'{restaurant} va bientot confirmer votre commande.'**
  String orderTrackingSubPendingDelivery(String restaurant);

  /// No description provided for @orderTrackingSubPreparingDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Votre repas sera pret dans ~{minutes} min.\nBon appetit bientot !'**
  String orderTrackingSubPreparingDelivery(int minutes);

  /// No description provided for @orderTrackingSubReadyDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Un livreur va bientot recuperer votre commande.'**
  String get orderTrackingSubReadyDelivery;

  /// No description provided for @orderTrackingSubDeliveringDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande est en chemin. Restez disponible !'**
  String get orderTrackingSubDeliveringDelivery;

  /// No description provided for @orderTrackingSubDeliveredDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande a ete livree. Bon appetit !'**
  String get orderTrackingSubDeliveredDelivery;

  /// No description provided for @orderTrackingSummaryOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commande'**
  String get orderTrackingSummaryOrder;

  /// No description provided for @orderTrackingSummaryMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get orderTrackingSummaryMode;

  /// No description provided for @orderTrackingSummaryTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'A emporter'**
  String get orderTrackingSummaryTakeaway;

  /// No description provided for @orderTrackingSummaryNotProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseignee'**
  String get orderTrackingSummaryNotProvided;

  /// No description provided for @orderTrackingMapDriver.
  ///
  /// In fr, this message translates to:
  /// **'Livreur'**
  String get orderTrackingMapDriver;

  /// No description provided for @orderTrackingMapYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get orderTrackingMapYou;

  /// No description provided for @orderTrackingMapFollow.
  ///
  /// In fr, this message translates to:
  /// **'Suivre'**
  String get orderTrackingMapFollow;

  /// No description provided for @orderTrackingLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger\nla commande'**
  String get orderTrackingLoadError;

  /// No description provided for @orderTrackingRetry.
  ///
  /// In fr, this message translates to:
  /// **'Reessayer'**
  String get orderTrackingRetry;

  /// No description provided for @orderTrackingRateOrder.
  ///
  /// In fr, this message translates to:
  /// **'Noter cette commande'**
  String get orderTrackingRateOrder;

  /// No description provided for @orderTrackingTodayAt.
  ///
  /// In fr, this message translates to:
  /// **'aujourd\'hui a {time}'**
  String orderTrackingTodayAt(String time);

  /// No description provided for @orderTrackingYesterdayAt.
  ///
  /// In fr, this message translates to:
  /// **'hier a {time}'**
  String orderTrackingYesterdayAt(String time);

  /// No description provided for @orderTrackingDateAt.
  ///
  /// In fr, this message translates to:
  /// **'le {date} a {time}'**
  String orderTrackingDateAt(String date, String time);

  /// No description provided for @receiptTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get receiptTitle;

  /// No description provided for @receiptBrandSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraison de cuisine africaine'**
  String get receiptBrandSubtitle;

  /// No description provided for @receiptOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'REÇU DE COMMANDE'**
  String get receiptOrderTitle;

  /// No description provided for @receiptDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get receiptDate;

  /// No description provided for @receiptRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant'**
  String get receiptRestaurant;

  /// No description provided for @receiptMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get receiptMode;

  /// No description provided for @receiptModeTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'À emporter'**
  String get receiptModeTakeaway;

  /// No description provided for @receiptModeDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get receiptModeDelivery;

  /// No description provided for @receiptAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get receiptAddress;

  /// No description provided for @receiptPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get receiptPayment;

  /// No description provided for @receiptPaymentMobileMoney.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money'**
  String get receiptPaymentMobileMoney;

  /// No description provided for @receiptPaymentCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte bancaire'**
  String get receiptPaymentCard;

  /// No description provided for @receiptPaymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Cash'**
  String get receiptPaymentCash;

  /// No description provided for @receiptPaymentNotSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Non spécifié'**
  String get receiptPaymentNotSpecified;

  /// No description provided for @receiptQty.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get receiptQty;

  /// No description provided for @receiptArticle.
  ///
  /// In fr, this message translates to:
  /// **'Article'**
  String get receiptArticle;

  /// No description provided for @receiptPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get receiptPrice;

  /// No description provided for @receiptSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get receiptSubtotal;

  /// No description provided for @receiptDeliveryFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de livraison'**
  String get receiptDeliveryFee;

  /// No description provided for @receiptFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get receiptFree;

  /// No description provided for @receiptTotal.
  ///
  /// In fr, this message translates to:
  /// **'TOTAL'**
  String get receiptTotal;

  /// No description provided for @receiptThankYou.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour votre commande !'**
  String get receiptThankYou;

  /// No description provided for @receiptFooter.
  ///
  /// In fr, this message translates to:
  /// **'Amara — La saveur de l\'Afrique livrée chez vous'**
  String get receiptFooter;

  /// No description provided for @receiptDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le reçu'**
  String get receiptDownload;

  /// No description provided for @receiptGenerationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la génération du reçu'**
  String get receiptGenerationError;

  /// No description provided for @orderConfirmSent.
  ///
  /// In fr, this message translates to:
  /// **'Commande envoyee !'**
  String get orderConfirmSent;

  /// No description provided for @orderConfirmThankYou.
  ///
  /// In fr, this message translates to:
  /// **'Merci d\'avoir commande chez {restaurant}. Notre cuisine prepare votre repas. Nous vous informerons des qu\'il sera pret.'**
  String orderConfirmThankYou(String restaurant);

  /// No description provided for @orderConfirmOrderNumber.
  ///
  /// In fr, this message translates to:
  /// **'N DE COMMANDE'**
  String get orderConfirmOrderNumber;

  /// No description provided for @orderConfirmRecipientName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du destinataire'**
  String get orderConfirmRecipientName;

  /// No description provided for @orderConfirmClientName.
  ///
  /// In fr, this message translates to:
  /// **'Client Amara'**
  String get orderConfirmClientName;

  /// No description provided for @orderConfirmOrderDetail.
  ///
  /// In fr, this message translates to:
  /// **'Detail de la commande'**
  String get orderConfirmOrderDetail;

  /// No description provided for @orderConfirmNoItems.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article'**
  String get orderConfirmNoItems;

  /// No description provided for @orderConfirmTrackOrder.
  ///
  /// In fr, this message translates to:
  /// **'Suivre ma commande'**
  String get orderConfirmTrackOrder;

  /// No description provided for @orderConfirmBackHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour a l\'accueil'**
  String get orderConfirmBackHome;

  /// No description provided for @reviewThankYou.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour votre avis !'**
  String get reviewThankYou;

  /// No description provided for @reviewFeedbackHelps.
  ///
  /// In fr, this message translates to:
  /// **'Votre retour aide la communaute'**
  String get reviewFeedbackHelps;

  /// No description provided for @reviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis'**
  String get reviewTitle;

  /// No description provided for @reviewExperienceQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Comment etait votre experience ?'**
  String get reviewExperienceQuestion;

  /// No description provided for @reviewRestaurantRating.
  ///
  /// In fr, this message translates to:
  /// **'Note du restaurant'**
  String get reviewRestaurantRating;

  /// No description provided for @reviewDriverRating.
  ///
  /// In fr, this message translates to:
  /// **'Note du livreur'**
  String get reviewDriverRating;

  /// No description provided for @reviewOptional.
  ///
  /// In fr, this message translates to:
  /// **'(optionnel)'**
  String get reviewOptional;

  /// No description provided for @reviewCommentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Un commentaire ? (optionnel)'**
  String get reviewCommentLabel;

  /// No description provided for @reviewCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre experience...'**
  String get reviewCommentHint;

  /// No description provided for @reviewSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer mon avis'**
  String get reviewSubmit;

  /// No description provided for @reviewSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get reviewSkip;

  /// No description provided for @reviewRatingBad.
  ///
  /// In fr, this message translates to:
  /// **'Mauvais'**
  String get reviewRatingBad;

  /// No description provided for @reviewRatingAverage.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get reviewRatingAverage;

  /// No description provided for @reviewRatingGood.
  ///
  /// In fr, this message translates to:
  /// **'Bien'**
  String get reviewRatingGood;

  /// No description provided for @reviewRatingVeryGood.
  ///
  /// In fr, this message translates to:
  /// **'Tres bien'**
  String get reviewRatingVeryGood;

  /// No description provided for @reviewRatingExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get reviewRatingExcellent;

  /// No description provided for @favoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get favoritesTitle;

  /// No description provided for @favoritesLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get favoritesLoadError;

  /// No description provided for @favoritesLoadErrorMessage.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les restaurants.'**
  String get favoritesLoadErrorMessage;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur le coeur d\'un restaurant pour l\'ajouter à vos favoris.'**
  String get favoritesEmptyMessage;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} selectionne{count, plural, =1{} other{s}}'**
  String notificationsSelectedCount(int count);

  /// No description provided for @notificationsDeleteAllTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer ?'**
  String get notificationsDeleteAllTitle;

  /// No description provided for @notificationsDeleteAllMessage.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos notifications seront supprimees.'**
  String get notificationsDeleteAllMessage;

  /// No description provided for @notificationsCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get notificationsCancel;

  /// No description provided for @notificationsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get notificationsDelete;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsSelect.
  ///
  /// In fr, this message translates to:
  /// **'Selectionner'**
  String get notificationsSelect;

  /// No description provided for @notificationsDeleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get notificationsDeleteAll;

  /// No description provided for @notificationsDeselectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout desélectionner'**
  String get notificationsDeselectAll;

  /// No description provided for @notificationsSelectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout selectionner'**
  String get notificationsSelectAll;

  /// No description provided for @notificationsDeleteCount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ({count})'**
  String notificationsDeleteCount(int count);

  /// No description provided for @notificationsSectionToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get notificationsSectionToday;

  /// No description provided for @notificationsSectionThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get notificationsSectionThisWeek;

  /// No description provided for @notificationsSectionOlder.
  ///
  /// In fr, this message translates to:
  /// **'Plus ancien'**
  String get notificationsSectionOlder;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vos notifications apparaitront ici'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationsConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get notificationsConnectionError;

  /// No description provided for @addressesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes adresses'**
  String get addressesTitle;

  /// No description provided for @addressesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune adresse'**
  String get addressesEmpty;

  /// No description provided for @addressesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une adresse de livraison pour commander plus rapidement.'**
  String get addressesEmptySubtitle;

  /// No description provided for @addressesAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addressesAdd;

  /// No description provided for @addressesEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'adresse'**
  String get addressesEditTitle;

  /// No description provided for @addressesNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle adresse'**
  String get addressesNewTitle;

  /// No description provided for @addressesLabelField.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'adresse'**
  String get addressesLabelField;

  /// No description provided for @addressesLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Maison, Bureau, Chez Maman'**
  String get addressesLabelHint;

  /// No description provided for @addressesAddressField.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get addressesAddressField;

  /// No description provided for @addressesAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une adresse...'**
  String get addressesAddressHint;

  /// No description provided for @addressesComplementField.
  ///
  /// In fr, this message translates to:
  /// **'Infos complémentaires'**
  String get addressesComplementField;

  /// No description provided for @addressesComplementHint.
  ///
  /// In fr, this message translates to:
  /// **'Bâtiment, étage, apt, code, instructions...'**
  String get addressesComplementHint;

  /// No description provided for @addressesSaveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get addressesSaveChanges;

  /// No description provided for @addressesAddAddress.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter l\'adresse'**
  String get addressesAddAddress;

  /// No description provided for @addressesModified.
  ///
  /// In fr, this message translates to:
  /// **'Adresse modifiée'**
  String get addressesModified;

  /// No description provided for @addressesAdded.
  ///
  /// In fr, this message translates to:
  /// **'Adresse ajoutée'**
  String get addressesAdded;

  /// No description provided for @addressesDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get addressesDefault;

  /// No description provided for @addressesEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get addressesEdit;

  /// No description provided for @addressesSetDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get addressesSetDefault;

  /// No description provided for @addressesDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get addressesDelete;

  /// No description provided for @personalInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get personalInfoSave;

  /// No description provided for @personalInfoEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get personalInfoEdit;

  /// No description provided for @personalInfoFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get personalInfoFullName;

  /// No description provided for @personalInfoEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get personalInfoEmail;

  /// No description provided for @personalInfoPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get personalInfoPhone;

  /// No description provided for @personalInfoBirthDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get personalInfoBirthDate;

  /// No description provided for @personalInfoBirthDateEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Non renseignée'**
  String get personalInfoBirthDateEmpty;

  /// No description provided for @personalInfoMemberSince.
  ///
  /// In fr, this message translates to:
  /// **'Membre depuis'**
  String get personalInfoMemberSince;

  /// No description provided for @personalInfoMemberAmara.
  ///
  /// In fr, this message translates to:
  /// **'Membre Amara'**
  String get personalInfoMemberAmara;

  /// No description provided for @personalInfoUpdateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour échouée'**
  String get personalInfoUpdateFailed;

  /// No description provided for @personalInfoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour'**
  String get personalInfoUpdated;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide & FAQ'**
  String get helpTitle;

  /// No description provided for @helpHeaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment pouvons-nous\nvous aider ?'**
  String get helpHeaderTitle;

  /// No description provided for @helpHeaderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez des réponses à vos questions ou contactez notre support.'**
  String get helpHeaderSubtitle;

  /// No description provided for @helpFaqSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Questions fréquentes'**
  String get helpFaqSectionTitle;

  /// No description provided for @helpNeedHelp.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d\'aide ?'**
  String get helpNeedHelp;

  /// No description provided for @helpFaqQ1.
  ///
  /// In fr, this message translates to:
  /// **'Comment passer une commande ?'**
  String get helpFaqQ1;

  /// No description provided for @helpFaqA1.
  ///
  /// In fr, this message translates to:
  /// **'Parcourez les restaurants depuis l\'accueil, choisissez vos plats, ajoutez-les au panier puis validez votre commande. Vous pouvez suivre la livraison en temps réel.'**
  String get helpFaqA1;

  /// No description provided for @helpFaqQ2.
  ///
  /// In fr, this message translates to:
  /// **'Quels sont les délais de livraison ?'**
  String get helpFaqQ2;

  /// No description provided for @helpFaqA2.
  ///
  /// In fr, this message translates to:
  /// **'La livraison prend en moyenne 30 à 45 minutes selon la distance et la préparation du restaurant. Vous pouvez suivre votre commande en temps réel depuis l\'onglet Commandes.'**
  String get helpFaqA2;

  /// No description provided for @helpFaqQ3.
  ///
  /// In fr, this message translates to:
  /// **'Comment annuler une commande ?'**
  String get helpFaqQ3;

  /// No description provided for @helpFaqA3.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez annuler votre commande depuis l\'onglet Commandes tant qu\'elle n\'a pas été prise en charge par le restaurant. Rendez-vous dans le détail de la commande et appuyez sur \"Annuler\".'**
  String get helpFaqA3;

  /// No description provided for @helpFaqQ4.
  ///
  /// In fr, this message translates to:
  /// **'Quels moyens de paiement acceptez-vous ?'**
  String get helpFaqQ4;

  /// No description provided for @helpFaqA4.
  ///
  /// In fr, this message translates to:
  /// **'Amara accepte le paiement par Mobile Money (Orange Money, MTN Money, Wave), carte bancaire (Visa, Mastercard) et le paiement en espèces à la livraison.'**
  String get helpFaqA4;

  /// No description provided for @helpFaqQ5.
  ///
  /// In fr, this message translates to:
  /// **'Comment ajouter une adresse de livraison ?'**
  String get helpFaqQ5;

  /// No description provided for @helpFaqA5.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous dans votre Profil > Mes adresses, puis appuyez sur \"Ajouter\". Vous pouvez enregistrer plusieurs adresses et définir une adresse par défaut.'**
  String get helpFaqA5;

  /// No description provided for @helpFaqQ6.
  ///
  /// In fr, this message translates to:
  /// **'Ma commande n\'est pas arrivée, que faire ?'**
  String get helpFaqQ6;

  /// No description provided for @helpFaqA6.
  ///
  /// In fr, this message translates to:
  /// **'Contactez notre support via le chat en bas de cette page ou appelez-nous. Nous ferons le nécessaire pour résoudre votre problème rapidement.'**
  String get helpFaqA6;

  /// No description provided for @helpFaqQ7.
  ///
  /// In fr, this message translates to:
  /// **'Comment devenir restaurant partenaire ?'**
  String get helpFaqQ7;

  /// No description provided for @helpFaqA7.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-nous un email à partenaires@amara.app avec le nom de votre restaurant, votre localisation et votre menu. Notre équipe vous recontactera sous 48h.'**
  String get helpFaqA7;

  /// No description provided for @helpContactChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat en direct'**
  String get helpContactChat;

  /// No description provided for @helpContactChatSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Réponse en quelques minutes'**
  String get helpContactChatSubtitle;

  /// No description provided for @helpContactChatSoon.
  ///
  /// In fr, this message translates to:
  /// **'Chat bientôt disponible'**
  String get helpContactChatSoon;

  /// No description provided for @helpContactEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get helpContactEmail;

  /// No description provided for @helpContactEmailAddress.
  ///
  /// In fr, this message translates to:
  /// **'support@amara.app'**
  String get helpContactEmailAddress;

  /// No description provided for @helpContactPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get helpContactPhone;

  /// No description provided for @helpContactPhoneNumber.
  ///
  /// In fr, this message translates to:
  /// **'+225 07 00 00 00 00'**
  String get helpContactPhoneNumber;

  /// No description provided for @legalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions legales'**
  String get legalTitle;

  /// No description provided for @legalTabCgu.
  ///
  /// In fr, this message translates to:
  /// **'CGU'**
  String get legalTabCgu;

  /// No description provided for @legalTabPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialite'**
  String get legalTabPrivacy;

  /// No description provided for @legalTabNotices.
  ///
  /// In fr, this message translates to:
  /// **'Mentions'**
  String get legalTabNotices;

  /// No description provided for @legalLastUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Derniere mise a jour : {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @legalCguTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Article 1 — Objet'**
  String get legalCguTitle1;

  /// No description provided for @legalCguBody1.
  ///
  /// In fr, this message translates to:
  /// **'Les presentes Conditions Generales d\'Utilisation (ci-apres « CGU ») regissent l\'acces et l\'utilisation de l\'application mobile Amara (ci-apres « l\'Application ») editee par Amara Technologies SAS.\n\nL\'Application est destinee aux particuliers (ci-apres « le Client » ou « l\'Utilisateur ») souhaitant commander des repas aupres de restaurants partenaires pour une livraison a domicile ou un retrait sur place.'**
  String get legalCguBody1;

  /// No description provided for @legalCguTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Article 2 — Acceptation des CGU'**
  String get legalCguTitle2;

  /// No description provided for @legalCguBody2.
  ///
  /// In fr, this message translates to:
  /// **'L\'inscription et l\'utilisation de l\'Application impliquent l\'acceptation pleine et entiere des presentes CGU. L\'Utilisateur reconnait en avoir pris connaissance et s\'engage a les respecter.\n\nAmara Technologies se reserve le droit de modifier les presentes CGU a tout moment. Les modifications entrent en vigueur des leur publication dans l\'Application. L\'utilisation continuee de l\'Application apres modification vaut acceptation des nouvelles CGU.'**
  String get legalCguBody2;

  /// No description provided for @legalCguTitle3.
  ///
  /// In fr, this message translates to:
  /// **'Article 3 — Inscription et compte'**
  String get legalCguTitle3;

  /// No description provided for @legalCguBody3.
  ///
  /// In fr, this message translates to:
  /// **'3.1. Pour acceder aux services de l\'Application, l\'Utilisateur doit creer un compte en fournissant des informations exactes et completes (nom, adresse email, numero de telephone).\n\n3.2. L\'Utilisateur est seul responsable de la confidentialite de ses identifiants de connexion. Toute activite realisee depuis son compte est presumee effectuee par lui.\n\n3.3. L\'Utilisateur doit etre age d\'au moins 16 ans pour creer un compte. Les mineurs doivent obtenir l\'autorisation de leurs parents ou tuteurs legaux.\n\n3.4. En cas de suspicion d\'utilisation non autorisee, l\'Utilisateur doit en informer immediatement Amara Technologies a l\'adresse : support@amara-food.com.'**
  String get legalCguBody3;

  /// No description provided for @legalCguTitle4.
  ///
  /// In fr, this message translates to:
  /// **'Article 4 — Services proposes'**
  String get legalCguTitle4;

  /// No description provided for @legalCguBody4.
  ///
  /// In fr, this message translates to:
  /// **'L\'Application permet a l\'Utilisateur de :\n\n• Parcourir les restaurants partenaires et leurs menus\n• Consulter les fiches detaillees des plats (description, prix, allergenes)\n• Ajouter des articles au panier et passer commande\n• Choisir entre la livraison a domicile et le retrait en restaurant\n• Suivre l\'etat de sa commande en temps reel\n• Enregistrer ses adresses de livraison favorites\n• Consulter l\'historique de ses commandes\n• Laisser des avis et notes sur les restaurants\n• Recevoir des notifications sur l\'avancement de ses commandes\n• Beneficier de promotions et offres speciales'**
  String get legalCguBody4;

  /// No description provided for @legalCguTitle5.
  ///
  /// In fr, this message translates to:
  /// **'Article 5 — Commandes et paiement'**
  String get legalCguTitle5;

  /// No description provided for @legalCguBody5.
  ///
  /// In fr, this message translates to:
  /// **'5.1. L\'Utilisateur passe commande en selectionnant les articles souhaites dans le menu d\'un restaurant partenaire, puis en validant son panier.\n\n5.2. Les prix affiches dans l\'Application sont exprimes en Francs CFA (FCFA) et incluent le prix des articles. Les frais de livraison sont indiques separement avant la validation de la commande.\n\n5.3. Le paiement peut etre effectue par les moyens de paiement proposes dans l\'Application (paiement mobile, especes a la livraison, carte bancaire selon disponibilite).\n\n5.4. La commande est confirmee une fois le paiement accepte ou, en cas de paiement a la livraison, une fois la commande validee par le restaurant.'**
  String get legalCguBody5;

  /// No description provided for @legalCguTitle6.
  ///
  /// In fr, this message translates to:
  /// **'Article 6 — Livraison'**
  String get legalCguTitle6;

  /// No description provided for @legalCguBody6.
  ///
  /// In fr, this message translates to:
  /// **'6.1. Les delais de livraison indiques dans l\'Application sont estimatifs et peuvent varier en fonction de la distance, de la demande et des conditions de circulation.\n\n6.2. L\'Utilisateur doit s\'assurer de fournir une adresse de livraison exacte et d\'etre disponible pour recevoir sa commande.\n\n6.3. En cas d\'absence du Client lors de la livraison, le livreur tentera de le contacter. Si le Client reste injoignable, la commande pourra etre annulee sans remboursement des frais de livraison.\n\n6.4. Amara Technologies ne saurait etre tenue responsable des retards de livraison lies a des circonstances independantes de sa volonte (conditions meteo, embouteillages, force majeure).'**
  String get legalCguBody6;

  /// No description provided for @legalCguTitle7.
  ///
  /// In fr, this message translates to:
  /// **'Article 7 — Annulation et remboursement'**
  String get legalCguTitle7;

  /// No description provided for @legalCguBody7.
  ///
  /// In fr, this message translates to:
  /// **'7.1. L\'Utilisateur peut annuler sa commande tant que celle-ci n\'a pas ete acceptee par le restaurant.\n\n7.2. Une fois la commande acceptee et en preparation, l\'annulation n\'est plus possible sauf accord du restaurant.\n\n7.3. En cas de probleme avec la commande (article manquant, erreur, qualite non conforme), l\'Utilisateur peut signaler le probleme via l\'Application dans un delai de 24 heures. Amara Technologies etudiera la reclamation et pourra proposer un remboursement partiel ou total, un avoir, ou une nouvelle livraison.\n\n7.4. Les remboursements sont effectues par le meme moyen de paiement que celui utilise lors de la commande, dans un delai de 5 a 10 jours ouvrables.'**
  String get legalCguBody7;

  /// No description provided for @legalCguTitle8.
  ///
  /// In fr, this message translates to:
  /// **'Article 8 — Obligations de l\'Utilisateur'**
  String get legalCguTitle8;

  /// No description provided for @legalCguBody8.
  ///
  /// In fr, this message translates to:
  /// **'L\'Utilisateur s\'engage a :\n\n• Fournir des informations exactes lors de l\'inscription et de la commande\n• Utiliser l\'Application de maniere loyale et conforme aux presentes CGU\n• Ne pas utiliser l\'Application a des fins frauduleuses ou illicites\n• Ne pas publier de contenu injurieux, diffamatoire ou contraire aux bonnes moeurs dans les avis\n• Respecter les livreurs et le personnel des restaurants partenaires\n• Ne pas tenter de contourner les systemes de securite de l\'Application'**
  String get legalCguBody8;

  /// No description provided for @legalCguTitle9.
  ///
  /// In fr, this message translates to:
  /// **'Article 9 — Propriete intellectuelle'**
  String get legalCguTitle9;

  /// No description provided for @legalCguBody9.
  ///
  /// In fr, this message translates to:
  /// **'9.1. L\'Application, son design, ses fonctionnalites, ses algorithmes, son code source et l\'ensemble des contenus associes sont la propriete exclusive d\'Amara Technologies SAS et sont proteges par les lois relatives a la propriete intellectuelle.\n\n9.2. Toute reproduction, representation, modification ou distribution de l\'Application ou de ses contenus, en tout ou en partie, sans autorisation prealable ecrite, est interdite.'**
  String get legalCguBody9;

  /// No description provided for @legalCguTitle10.
  ///
  /// In fr, this message translates to:
  /// **'Article 10 — Responsabilite'**
  String get legalCguTitle10;

  /// No description provided for @legalCguBody10.
  ///
  /// In fr, this message translates to:
  /// **'10.1. Amara Technologies agit en tant qu\'intermediaire entre l\'Utilisateur et les restaurants partenaires. La preparation et la qualite des plats relevent de la seule responsabilite des restaurants.\n\n10.2. Amara Technologies s\'efforce d\'assurer la disponibilite et le bon fonctionnement de l\'Application, sans garantir une disponibilite ininterrompue.\n\n10.3. Amara Technologies ne saurait etre tenue responsable des dommages directs ou indirects resultant de l\'utilisation ou de l\'impossibilite d\'utiliser l\'Application.'**
  String get legalCguBody10;

  /// No description provided for @legalCguTitle11.
  ///
  /// In fr, this message translates to:
  /// **'Article 11 — Suspension et resiliation'**
  String get legalCguTitle11;

  /// No description provided for @legalCguBody11.
  ///
  /// In fr, this message translates to:
  /// **'11.1. Amara Technologies peut suspendre ou supprimer le compte de l\'Utilisateur en cas de :\n\n• Violation des presentes CGU\n• Comportement frauduleux ou abusif\n• Avis de contenus offensants repetes\n• Non-paiement des commandes\n\n11.2. L\'Utilisateur peut supprimer son compte a tout moment en contactant le support Amara a support@amara-food.com ou depuis les parametres de l\'Application.'**
  String get legalCguBody11;

  /// No description provided for @legalCguTitle12.
  ///
  /// In fr, this message translates to:
  /// **'Article 12 — Droit applicable et litiges'**
  String get legalCguTitle12;

  /// No description provided for @legalCguBody12.
  ///
  /// In fr, this message translates to:
  /// **'Les presentes CGU sont regies par le droit ivoirien. En cas de litige relatif a l\'interpretation ou a l\'execution des presentes, les parties s\'efforceront de trouver une solution amiable. A defaut, le litige sera soumis aux tribunaux competents d\'Abidjan, Cote d\'Ivoire.'**
  String get legalCguBody12;

  /// No description provided for @legalPrivacyTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Article 1 — Responsable du traitement'**
  String get legalPrivacyTitle1;

  /// No description provided for @legalPrivacyBody1.
  ///
  /// In fr, this message translates to:
  /// **'Le responsable du traitement des donnees personnelles collectees via l\'Application Amara est :\n\nAmara Technologies SAS\nSiege social : Abidjan, Cote d\'Ivoire\nEmail : privacy@amara-food.com'**
  String get legalPrivacyBody1;

  /// No description provided for @legalPrivacyTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Article 2 — Donnees collectees'**
  String get legalPrivacyTitle2;

  /// No description provided for @legalPrivacyBody2.
  ///
  /// In fr, this message translates to:
  /// **'Dans le cadre de l\'utilisation de l\'Application, les donnees suivantes sont collectees :\n\n• Donnees d\'identification : nom, prenom, adresse email, numero de telephone\n• Donnees de livraison : adresses enregistrees, instructions de livraison\n• Donnees de commandes : historique des commandes, articles commandes, montants\n• Donnees de paiement : mode de paiement utilise (les donnees bancaires ne sont pas stockees par Amara)\n• Donnees de geolocalisation : position pour la livraison (avec consentement)\n• Donnees d\'utilisation : restaurants favoris, preferences alimentaires\n• Donnees techniques : adresse IP, type d\'appareil, version de l\'application, logs de connexion\n• Avis et evaluations : notes et commentaires laisses sur les restaurants'**
  String get legalPrivacyBody2;

  /// No description provided for @legalPrivacyTitle3.
  ///
  /// In fr, this message translates to:
  /// **'Article 3 — Finalites du traitement'**
  String get legalPrivacyTitle3;

  /// No description provided for @legalPrivacyBody3.
  ///
  /// In fr, this message translates to:
  /// **'Les donnees collectees sont utilisees pour :\n\n• Creer et gerer le compte de l\'Utilisateur\n• Traiter et suivre les commandes\n• Assurer la livraison a l\'adresse indiquee\n• Permettre le paiement securise\n• Envoyer des notifications sur l\'etat des commandes\n• Proposer des recommandations personnalisees de restaurants et de plats\n• Envoyer des offres promotionnelles (avec consentement)\n• Ameliorer l\'Application et l\'experience utilisateur\n• Assurer la securite de la plateforme et prevenir la fraude\n• Repondre aux demandes du support client\n• Respecter les obligations legales et reglementaires'**
  String get legalPrivacyBody3;

  /// No description provided for @legalPrivacyTitle4.
  ///
  /// In fr, this message translates to:
  /// **'Article 4 — Base legale du traitement'**
  String get legalPrivacyTitle4;

  /// No description provided for @legalPrivacyBody4.
  ///
  /// In fr, this message translates to:
  /// **'Le traitement des donnees personnelles est fonde sur :\n\n• L\'execution du contrat : traitement des commandes, livraison, paiement\n• Le consentement de l\'Utilisateur : geolocalisation, notifications marketing, cookies\n• L\'interet legitime d\'Amara Technologies : amelioration des services, prevention de la fraude, statistiques anonymisees\n• Le respect des obligations legales : comptabilite, fiscalite'**
  String get legalPrivacyBody4;

  /// No description provided for @legalPrivacyTitle5.
  ///
  /// In fr, this message translates to:
  /// **'Article 5 — Partage des donnees'**
  String get legalPrivacyTitle5;

  /// No description provided for @legalPrivacyBody5.
  ///
  /// In fr, this message translates to:
  /// **'Les donnees personnelles peuvent etre partagees avec :\n\n• Les restaurants partenaires : nom, adresse de livraison et details de la commande (necessaire pour la preparation)\n• Les livreurs : nom, adresse de livraison et numero de telephone (necessaire pour la livraison)\n• Les prestataires de paiement : informations necessaires au traitement du paiement\n• Les equipes internes d\'Amara Technologies : support, technique, marketing\n• Les prestataires techniques : hebergement, infrastructure cloud\n• Les autorites competentes en cas d\'obligation legale\n\nAmara Technologies ne vend ni ne loue les donnees personnelles de l\'Utilisateur a des tiers a des fins commerciales.'**
  String get legalPrivacyBody5;

  /// No description provided for @legalPrivacyTitle6.
  ///
  /// In fr, this message translates to:
  /// **'Article 6 — Duree de conservation'**
  String get legalPrivacyTitle6;

  /// No description provided for @legalPrivacyBody6.
  ///
  /// In fr, this message translates to:
  /// **'Les donnees personnelles sont conservees pendant :\n\n• Donnees de compte : pendant toute la duree d\'utilisation du compte, puis 3 ans apres la suppression\n• Donnees de commandes : 5 ans a compter de la date de la commande (obligation comptable)\n• Donnees de geolocalisation : duree de la session de commande uniquement\n• Donnees techniques (logs) : 12 mois\n• Avis et evaluations : tant que le compte est actif ou jusqu\'a demande de suppression\n\nA l\'expiration de ces delais, les donnees sont supprimees ou anonymisees de maniere irreversible.'**
  String get legalPrivacyBody6;

  /// No description provided for @legalPrivacyTitle7.
  ///
  /// In fr, this message translates to:
  /// **'Article 7 — Securite des donnees'**
  String get legalPrivacyTitle7;

  /// No description provided for @legalPrivacyBody7.
  ///
  /// In fr, this message translates to:
  /// **'Amara Technologies met en oeuvre les mesures techniques et organisationnelles appropriees pour proteger les donnees personnelles, notamment :\n\n• Chiffrement des donnees en transit (HTTPS/TLS)\n• Chiffrement des mots de passe (hachage bcrypt)\n• Authentification par token securise\n• Stockage securise des informations sensibles sur l\'appareil\n• Acces restreint aux donnees selon le principe du moindre privilege\n• Hebergement sur infrastructure cloud certifiee'**
  String get legalPrivacyBody7;

  /// No description provided for @legalPrivacyTitle8.
  ///
  /// In fr, this message translates to:
  /// **'Article 8 — Droits de l\'Utilisateur'**
  String get legalPrivacyTitle8;

  /// No description provided for @legalPrivacyBody8.
  ///
  /// In fr, this message translates to:
  /// **'Conformement a la reglementation applicable, l\'Utilisateur dispose des droits suivants :\n\n• Droit d\'acces : obtenir la confirmation du traitement de ses donnees et en obtenir une copie\n• Droit de rectification : faire corriger les donnees inexactes ou incompletes\n• Droit de suppression : demander l\'effacement de ses donnees dans les conditions prevues par la loi\n• Droit a la portabilite : recevoir ses donnees dans un format structure et couramment utilise\n• Droit d\'opposition : s\'opposer au traitement de ses donnees pour des motifs legitimes\n• Droit a la limitation : demander la suspension du traitement dans certains cas\n• Droit de retrait du consentement : retirer son consentement a tout moment pour les traitements bases sur celui-ci\n\nPour exercer ces droits, l\'Utilisateur peut adresser sa demande a :\nprivacy@amara-food.com\n\nAmara Technologies s\'engage a repondre dans un delai de 30 jours.'**
  String get legalPrivacyBody8;

  /// No description provided for @legalPrivacyTitle9.
  ///
  /// In fr, this message translates to:
  /// **'Article 9 — Geolocalisation'**
  String get legalPrivacyTitle9;

  /// No description provided for @legalPrivacyBody9.
  ///
  /// In fr, this message translates to:
  /// **'L\'Application peut utiliser la geolocalisation de l\'appareil de l\'Utilisateur pour :\n\n• Identifier les restaurants a proximite\n• Estimer les delais et frais de livraison\n• Permettre le suivi de la livraison en temps reel\n\nL\'acces a la geolocalisation est soumis au consentement de l\'Utilisateur via les parametres de son appareil. L\'Utilisateur peut desactiver la geolocalisation a tout moment, mais certaines fonctionnalites pourront etre limitees.'**
  String get legalPrivacyBody9;

  /// No description provided for @legalPrivacyTitle10.
  ///
  /// In fr, this message translates to:
  /// **'Article 10 — Notifications'**
  String get legalPrivacyTitle10;

  /// No description provided for @legalPrivacyBody10.
  ///
  /// In fr, this message translates to:
  /// **'L\'Application peut envoyer des notifications push pour :\n\n• Informer de l\'avancement d\'une commande (confirmation, preparation, livraison)\n• Signaler des promotions ou offres speciales\n• Communiquer des informations importantes relatives au compte\n\nL\'Utilisateur peut gerer ses preferences de notification depuis les parametres de son appareil.'**
  String get legalPrivacyBody10;

  /// No description provided for @legalPrivacyTitle11.
  ///
  /// In fr, this message translates to:
  /// **'Article 11 — Modification de la politique'**
  String get legalPrivacyTitle11;

  /// No description provided for @legalPrivacyBody11.
  ///
  /// In fr, this message translates to:
  /// **'Amara Technologies se reserve le droit de modifier la presente politique de confidentialite a tout moment. L\'Utilisateur sera informe de toute modification substantielle par notification dans l\'Application. L\'utilisation continuee de l\'Application apres modification vaut acceptation de la politique mise a jour.'**
  String get legalPrivacyBody11;

  /// No description provided for @legalNoticesTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Editeur de l\'Application'**
  String get legalNoticesTitle1;

  /// No description provided for @legalNoticesBody1.
  ///
  /// In fr, this message translates to:
  /// **'Amara Technologies SAS\nSociete par Actions Simplifiee au capital de 1 000 000 FCFA\nSiege social : Abidjan, Cocody, Cote d\'Ivoire\nRCCM : CI-ABJ-2026-B-XXXXX\n\nDirecteur de la publication : Equipe Amara Technologies\nEmail : contact@amara-food.com\nTelephone : +225 XX XX XX XX XX'**
  String get legalNoticesBody1;

  /// No description provided for @legalNoticesTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Hebergement'**
  String get legalNoticesTitle2;

  /// No description provided for @legalNoticesBody2.
  ///
  /// In fr, this message translates to:
  /// **'L\'Application et ses donnees sont hebergees par :\n\nConvex, Inc.\nSan Francisco, CA, Etats-Unis\nSite web : https://convex.dev\n\nInfrastructure cloud : Region EU-West-1 (Union Europeenne)\n\nDistribution de l\'Application :\n• Apple App Store (iOS) — Apple Inc.\n• Google Play Store (Android) — Google LLC'**
  String get legalNoticesBody2;

  /// No description provided for @legalNoticesTitle3.
  ///
  /// In fr, this message translates to:
  /// **'Propriete intellectuelle'**
  String get legalNoticesTitle3;

  /// No description provided for @legalNoticesBody3.
  ///
  /// In fr, this message translates to:
  /// **'L\'ensemble des elements composant l\'Application Amara (design, textes, logos, icones, images, fonctionnalites, code source) est la propriete exclusive d\'Amara Technologies SAS ou fait l\'objet d\'une autorisation d\'utilisation.\n\nToute reproduction, representation, modification ou distribution, totale ou partielle, des elements de l\'Application sans autorisation prealable ecrite d\'Amara Technologies est interdite et constitue une contrefacon sanctionnee par la loi.\n\nLa marque « Amara » ainsi que le logo associe sont des marques deposees. Leur utilisation non autorisee est strictement interdite.'**
  String get legalNoticesBody3;

  /// No description provided for @legalNoticesTitle4.
  ///
  /// In fr, this message translates to:
  /// **'Donnees personnelles'**
  String get legalNoticesTitle4;

  /// No description provided for @legalNoticesBody4.
  ///
  /// In fr, this message translates to:
  /// **'Amara Technologies s\'engage a respecter la legislation en vigueur relative a la protection des donnees personnelles.\n\nPour toute question relative au traitement de vos donnees personnelles, veuillez consulter notre Politique de confidentialite accessible depuis l\'onglet « Confidentialite » de cette page, ou nous contacter a : privacy@amara-food.com.\n\nAutorite de controle : Commission Nationale de l\'Informatique et des Libertes de Cote d\'Ivoire (ARTCI).'**
  String get legalNoticesBody4;

  /// No description provided for @legalNoticesTitle5.
  ///
  /// In fr, this message translates to:
  /// **'Limitation de responsabilite'**
  String get legalNoticesTitle5;

  /// No description provided for @legalNoticesBody5.
  ///
  /// In fr, this message translates to:
  /// **'Amara Technologies agit en tant que plateforme d\'intermediation entre les Utilisateurs et les restaurants partenaires.\n\nAmara Technologies ne pourra etre tenue responsable :\n\n• De la qualite, du gout ou de la conformite des plats prepares par les restaurants\n• Des allergenes non declares par les restaurants partenaires\n• Des retards de livraison lies a des circonstances exterieures\n• Des interruptions temporaires du service pour maintenance ou mise a jour\n• De tout dysfonctionnement lie a l\'appareil ou au reseau de l\'Utilisateur\n• Des pertes ou dommages indirects lies a l\'utilisation de l\'Application'**
  String get legalNoticesBody5;

  /// No description provided for @legalNoticesTitle6.
  ///
  /// In fr, this message translates to:
  /// **'Droit applicable'**
  String get legalNoticesTitle6;

  /// No description provided for @legalNoticesBody6.
  ///
  /// In fr, this message translates to:
  /// **'Les presentes mentions legales sont regies par le droit ivoirien.\n\nPour toute reclamation, vous pouvez nous contacter :\n• Par email : support@amara-food.com\n• Par courrier : Amara Technologies SAS, Abidjan, Cocody, Cote d\'Ivoire\n\nEn cas de litige, les parties s\'efforceront de trouver une solution amiable prealablement a toute action judiciaire. A defaut d\'accord amiable, les tribunaux d\'Abidjan seront competents.'**
  String get legalNoticesBody6;

  /// No description provided for @legalNoticesTitle7.
  ///
  /// In fr, this message translates to:
  /// **'Credits'**
  String get legalNoticesTitle7;

  /// No description provided for @legalNoticesBody7.
  ///
  /// In fr, this message translates to:
  /// **'• Design et developpement : Amara Technologies SAS\n• Framework : Flutter (Google)\n• Typographie : Urbanist (Google Fonts)\n• Icones : Material Design Icons (Google)\n• Infrastructure : Convex (Convex, Inc.)'**
  String get legalNoticesBody7;

  /// No description provided for @legalDateMarch2026.
  ///
  /// In fr, this message translates to:
  /// **'1er mars 2026'**
  String get legalDateMarch2026;

  /// No description provided for @errorDialogDefaultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Oups !'**
  String get errorDialogDefaultTitle;

  /// No description provided for @errorDialogDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get errorDialogDismiss;

  /// No description provided for @errorDialogDeliveryAddress.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez renseigner votre adresse de livraison avant de commander.'**
  String get errorDialogDeliveryAddress;

  /// No description provided for @errorDialogRestaurantNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce restaurant n\'est plus disponible. Veuillez réessayer.'**
  String get errorDialogRestaurantNotFound;

  /// No description provided for @errorDialogSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré. Veuillez vous reconnecter.'**
  String get errorDialogSessionExpired;

  /// No description provided for @errorDialogAlreadyReviewed.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà donné votre avis sur cette commande.'**
  String get errorDialogAlreadyReviewed;

  /// No description provided for @errorDialogInvalidTransition.
  ///
  /// In fr, this message translates to:
  /// **'Cette action n\'est plus disponible. Rafraîchissez la page.'**
  String get errorDialogInvalidTransition;

  /// No description provided for @errorDialogEmptyCart.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide. Ajoutez des articles avant de commander.'**
  String get errorDialogEmptyCart;

  /// No description provided for @errorDialogOrderNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande est introuvable. Elle a peut-être été supprimée.'**
  String get errorDialogOrderNotFound;

  /// No description provided for @errorDialogNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de se connecter au serveur. Vérifiez votre connexion internet et réessayez.'**
  String get errorDialogNetwork;

  /// No description provided for @errorDialogTimeout.
  ///
  /// In fr, this message translates to:
  /// **'La connexion a pris trop de temps. Vérifiez votre connexion internet et réessayez.'**
  String get errorDialogTimeout;

  /// No description provided for @errorDialogFallback.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get errorDialogFallback;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In fr, this message translates to:
  /// **'Vos plats\npréférés livrés'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Desc.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez des centaines de plats authentiques préparés par les meilleurs restaurants africains de votre ville.'**
  String get onboardingSlide1Desc;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In fr, this message translates to:
  /// **'Livraison\nrapide'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In fr, this message translates to:
  /// **'Suivez votre commande en temps réel et recevez vos plats chauds directement à votre porte en moins de 45 min.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In fr, this message translates to:
  /// **'Paiement\nsimple & sécurisé'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money, carte bancaire ou cash — choisissez le moyen de paiement qui vous convient le mieux.'**
  String get onboardingSlide3Desc;

  /// No description provided for @onboardingStartButton.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStartButton;

  /// No description provided for @searchExplore.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get searchExplore;

  /// No description provided for @searchSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les meilleurs restaurants autour de vous'**
  String get searchSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant, plat, cuisine…'**
  String get searchHint;

  /// No description provided for @searchSortRecommended.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé'**
  String get searchSortRecommended;

  /// No description provided for @searchSortRating.
  ///
  /// In fr, this message translates to:
  /// **'Mieux notés'**
  String get searchSortRating;

  /// No description provided for @searchSortDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get searchSortDistance;

  /// No description provided for @searchSortDeliveryTime.
  ///
  /// In fr, this message translates to:
  /// **'Rapidité'**
  String get searchSortDeliveryTime;

  /// No description provided for @searchSortPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix livraison'**
  String get searchSortPrice;

  /// No description provided for @searchFilterReset.
  ///
  /// In fr, this message translates to:
  /// **'Reset'**
  String get searchFilterReset;

  /// No description provided for @searchFilterFreeDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison gratuite'**
  String get searchFilterFreeDelivery;

  /// No description provided for @searchFilterOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get searchFilterOpen;

  /// No description provided for @searchFilterTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'À emporter'**
  String get searchFilterTakeaway;

  /// No description provided for @searchFilterBestRated.
  ///
  /// In fr, this message translates to:
  /// **'Mieux notés'**
  String get searchFilterBestRated;

  /// No description provided for @searchFilterPromo.
  ///
  /// In fr, this message translates to:
  /// **'Promo'**
  String get searchFilterPromo;

  /// No description provided for @searchSectionTopRated.
  ///
  /// In fr, this message translates to:
  /// **'Mieux notés'**
  String get searchSectionTopRated;

  /// No description provided for @searchSectionPromo.
  ///
  /// In fr, this message translates to:
  /// **'Promo'**
  String get searchSectionPromo;

  /// No description provided for @searchSectionAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous les restaurants'**
  String get searchSectionAll;

  /// No description provided for @searchNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsQuery.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant trouvé pour \"{query}\"'**
  String searchNoResultsQuery(String query);

  /// No description provided for @searchNoResultsFilters.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant correspond à vos filtres'**
  String get searchNoResultsFilters;

  /// No description provided for @searchResetButton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get searchResetButton;

  /// No description provided for @searchErrorConnection.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get searchErrorConnection;

  /// No description provided for @searchResultCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} restaurant{count, plural, =1{} other{s}}'**
  String searchResultCount(int count);

  /// No description provided for @searchSortBy.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get searchSortBy;

  /// No description provided for @searchFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get searchFilters;

  /// No description provided for @searchFilterFreeDeliverySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Uniquement avec livraison offerte'**
  String get searchFilterFreeDeliverySubtitle;

  /// No description provided for @searchFilterOpenNow.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert maintenant'**
  String get searchFilterOpenNow;

  /// No description provided for @searchFilterOpenNowSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Masquer les restaurants fermés'**
  String get searchFilterOpenNowSubtitle;

  /// No description provided for @searchFilterMinRating.
  ///
  /// In fr, this message translates to:
  /// **'Note minimale'**
  String get searchFilterMinRating;

  /// No description provided for @searchFilterAllRatings.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les notes'**
  String get searchFilterAllRatings;

  /// No description provided for @searchFilterRatingAndUp.
  ///
  /// In fr, this message translates to:
  /// **'{rating} ★ et plus'**
  String searchFilterRatingAndUp(String rating);

  /// No description provided for @searchFilterApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get searchFilterApply;

  /// No description provided for @searchFreeDeliveryBadge.
  ///
  /// In fr, this message translates to:
  /// **'Livraison gratuite'**
  String get searchFreeDeliveryBadge;

  /// No description provided for @searchFreeDeliveryShort.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get searchFreeDeliveryShort;

  /// No description provided for @restaurantAllCategory.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get restaurantAllCategory;

  /// No description provided for @restaurantNoDishFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plat trouvé pour \"{query}\"'**
  String restaurantNoDishFound(String query);

  /// No description provided for @restaurantSearchDish.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un plat...'**
  String get restaurantSearchDish;

  /// No description provided for @restaurantShareText.
  ///
  /// In fr, this message translates to:
  /// **'Découvre ce restaurant sur Amara !'**
  String get restaurantShareText;

  /// No description provided for @restaurantLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le restaurant'**
  String get restaurantLoadError;

  /// No description provided for @restaurantRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get restaurantRetry;

  /// No description provided for @restaurantAlreadyOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà commandé ici'**
  String get restaurantAlreadyOrdered;

  /// No description provided for @restaurantReviewsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} avis'**
  String restaurantReviewsCount(int count);

  /// No description provided for @restaurantReviews.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get restaurantReviews;

  /// No description provided for @restaurantClients.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get restaurantClients;

  /// No description provided for @restaurantDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get restaurantDelivery;

  /// No description provided for @restaurantAsapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Au plus tôt'**
  String get restaurantAsapTitle;

  /// No description provided for @restaurantAsapDescription.
  ///
  /// In fr, this message translates to:
  /// **'Remplissez votre panier pour obtenir une estimation plus précise en fonction des articles sélectionnés, des conditions en temps réel et des options de livraison lors du paiement. Cette estimation correspond à l\'heure d\'arrivée au plus tôt, avant la sélection d\'articles.'**
  String get restaurantAsapDescription;

  /// No description provided for @restaurantService.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get restaurantService;

  /// No description provided for @restaurantServiceDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get restaurantServiceDelivery;

  /// No description provided for @restaurantServiceTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'À emporter'**
  String get restaurantServiceTakeaway;

  /// No description provided for @restaurantServiceDineIn.
  ///
  /// In fr, this message translates to:
  /// **'Sur place'**
  String get restaurantServiceDineIn;

  /// No description provided for @restaurantPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get restaurantPayment;

  /// No description provided for @restaurantMinOrder.
  ///
  /// In fr, this message translates to:
  /// **'Min. commande'**
  String get restaurantMinOrder;

  /// No description provided for @restaurantCurrentPromos.
  ///
  /// In fr, this message translates to:
  /// **'Promotions en cours'**
  String get restaurantCurrentPromos;

  /// No description provided for @restaurantCodeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code \"{code}\" copié !'**
  String restaurantCodeCopied(String code);

  /// No description provided for @restaurantInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos du restaurant'**
  String get restaurantInfo;

  /// No description provided for @restaurantScheduleInfo.
  ///
  /// In fr, this message translates to:
  /// **'Horaires & informations'**
  String get restaurantScheduleInfo;

  /// No description provided for @restaurantOpenNow.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert maintenant'**
  String get restaurantOpenNow;

  /// No description provided for @restaurantCurrentlyClosed.
  ///
  /// In fr, this message translates to:
  /// **'Actuellement fermé'**
  String get restaurantCurrentlyClosed;

  /// No description provided for @restaurantOpeningHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires d\'ouverture'**
  String get restaurantOpeningHours;

  /// No description provided for @restaurantToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get restaurantToday;

  /// No description provided for @restaurantMostLoved.
  ///
  /// In fr, this message translates to:
  /// **'Les plus aimés'**
  String get restaurantMostLoved;

  /// No description provided for @restaurantByPopularity.
  ///
  /// In fr, this message translates to:
  /// **'Par popularité'**
  String get restaurantByPopularity;

  /// No description provided for @restaurantOrders.
  ///
  /// In fr, this message translates to:
  /// **'{count} commandes'**
  String restaurantOrders(String count);

  /// No description provided for @restaurantUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get restaurantUnavailable;

  /// No description provided for @menuItemPopularBadge.
  ///
  /// In fr, this message translates to:
  /// **'⭐ Populaire'**
  String get menuItemPopularBadge;

  /// No description provided for @menuItemVegetarianBadge.
  ///
  /// In fr, this message translates to:
  /// **'🌱 Végétarien'**
  String get menuItemVegetarianBadge;

  /// No description provided for @menuItemSpicyBadge.
  ///
  /// In fr, this message translates to:
  /// **'🌶️ Épicé'**
  String get menuItemSpicyBadge;

  /// No description provided for @menuItemExtraOptions.
  ///
  /// In fr, this message translates to:
  /// **'+{price} F options'**
  String menuItemExtraOptions(String price);

  /// No description provided for @menuItemRatingReviews.
  ///
  /// In fr, this message translates to:
  /// **'{rating} ({count} avis)'**
  String menuItemRatingReviews(String rating, int count);

  /// No description provided for @menuItemCustomers.
  ///
  /// In fr, this message translates to:
  /// **'{count} clients'**
  String menuItemCustomers(String count);

  /// No description provided for @menuItemPerfectWith.
  ///
  /// In fr, this message translates to:
  /// **'Parfait avec ce plat 😋'**
  String get menuItemPerfectWith;

  /// No description provided for @menuItemIngredientsAndSides.
  ///
  /// In fr, this message translates to:
  /// **'Ingrédients & accompagnements'**
  String get menuItemIngredientsAndSides;

  /// No description provided for @menuItemChooseOneOption.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez 1 option'**
  String get menuItemChooseOneOption;

  /// No description provided for @menuItemUpToChoices.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'à {max} choix'**
  String menuItemUpToChoices(int max);

  /// No description provided for @menuItemRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get menuItemRequired;

  /// No description provided for @menuItemOptional.
  ///
  /// In fr, this message translates to:
  /// **'Optionnel'**
  String get menuItemOptional;

  /// No description provided for @menuItemIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Inclus'**
  String get menuItemIncluded;

  /// No description provided for @menuItemNoteForRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Note pour le restaurant'**
  String get menuItemNoteForRestaurant;

  /// No description provided for @menuItemNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: sans oignons, cuisson bien cuite, sauce à part...'**
  String get menuItemNoteHint;

  /// No description provided for @menuItemAddToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get menuItemAddToCart;

  /// No description provided for @cartCarts.
  ///
  /// In fr, this message translates to:
  /// **'Paniers'**
  String get cartCarts;

  /// No description provided for @cartEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide'**
  String get cartEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des plats depuis un restaurant\npour commencer votre commande'**
  String get cartEmptySubtitle;

  /// No description provided for @cartExploreRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Explorer les restaurants'**
  String get cartExploreRestaurants;

  /// No description provided for @cartDeliverTo.
  ///
  /// In fr, this message translates to:
  /// **'Livrer à l\'adresse Cocody, Abidjan'**
  String get cartDeliverTo;

  /// No description provided for @cartViewCart.
  ///
  /// In fr, this message translates to:
  /// **'Voir le panier'**
  String get cartViewCart;

  /// No description provided for @cartShowStoreOffer.
  ///
  /// In fr, this message translates to:
  /// **'Afficher l\'offre du magasin'**
  String get cartShowStoreOffer;

  /// No description provided for @cartClearCart.
  ///
  /// In fr, this message translates to:
  /// **'Vider ce panier'**
  String get cartClearCart;

  /// No description provided for @cartCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cartCancel;

  /// No description provided for @cartAddItems.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des articles'**
  String get cartAddItems;

  /// No description provided for @cartSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get cartSubtotal;

  /// No description provided for @cartProceedToPayment.
  ///
  /// In fr, this message translates to:
  /// **'Passer au paiement'**
  String get cartProceedToPayment;

  /// No description provided for @cartOptionsSelected.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 option sélectionnée} other{{count} options sélectionnées}}'**
  String cartOptionsSelected(int count);

  /// No description provided for @checkoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get checkoutTitle;

  /// No description provided for @checkoutInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide'**
  String get checkoutInvalidCode;

  /// No description provided for @checkoutEditInfo.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les informations'**
  String get checkoutEditInfo;

  /// No description provided for @checkoutDeliveryAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de livraison'**
  String get checkoutDeliveryAddress;

  /// No description provided for @checkoutSearchAddress.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une adresse...'**
  String get checkoutSearchAddress;

  /// No description provided for @checkoutStreetDistrict.
  ///
  /// In fr, this message translates to:
  /// **'Rue / Quartier'**
  String get checkoutStreetDistrict;

  /// No description provided for @checkoutStreetHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Rue 123, à côté du marché...'**
  String get checkoutStreetHint;

  /// No description provided for @checkoutDriverInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Instructions pour le livreur'**
  String get checkoutDriverInstructions;

  /// No description provided for @checkoutInstructionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Bâtiment B, 2ème étage, porte 5...'**
  String get checkoutInstructionsHint;

  /// No description provided for @checkoutPhoneNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get checkoutPhoneNumber;

  /// No description provided for @checkoutSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get checkoutSave;

  /// No description provided for @checkoutServiceMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode de service'**
  String get checkoutServiceMode;

  /// No description provided for @checkoutDeliveryMode.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get checkoutDeliveryMode;

  /// No description provided for @checkoutTakeawayMode.
  ///
  /// In fr, this message translates to:
  /// **'À emporter'**
  String get checkoutTakeawayMode;

  /// No description provided for @checkoutDeliverTo.
  ///
  /// In fr, this message translates to:
  /// **'Livrer à'**
  String get checkoutDeliverTo;

  /// No description provided for @checkoutPickupAt.
  ///
  /// In fr, this message translates to:
  /// **'À emporter chez'**
  String get checkoutPickupAt;

  /// No description provided for @checkoutPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get checkoutPhone;

  /// No description provided for @checkoutOrderSummary.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif de la commande'**
  String get checkoutOrderSummary;

  /// No description provided for @checkoutCodeApplied.
  ///
  /// In fr, this message translates to:
  /// **'Code \"{code}\" appliqué'**
  String checkoutCodeApplied(String code);

  /// No description provided for @checkoutFreeDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison offerte'**
  String get checkoutFreeDelivery;

  /// No description provided for @checkoutRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get checkoutRemove;

  /// No description provided for @checkoutAddPromoCode.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un code promotionnel'**
  String get checkoutAddPromoCode;

  /// No description provided for @checkoutSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get checkoutSubtotal;

  /// No description provided for @checkoutServiceFee.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get checkoutServiceFee;

  /// No description provided for @checkoutDeliveryFee.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get checkoutDeliveryFee;

  /// No description provided for @checkoutFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get checkoutFree;

  /// No description provided for @checkoutDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Réduction'**
  String get checkoutDiscount;

  /// No description provided for @checkoutTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get checkoutTotal;

  /// No description provided for @checkoutPaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement'**
  String get checkoutPaymentMethod;

  /// No description provided for @checkoutNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible'**
  String get checkoutNotAvailable;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commander et payer'**
  String get checkoutPlaceOrder;

  /// No description provided for @checkoutPromoCode.
  ///
  /// In fr, this message translates to:
  /// **'Code promotionnel'**
  String get checkoutPromoCode;

  /// No description provided for @checkoutPromoHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code promo'**
  String get checkoutPromoHint;

  /// No description provided for @checkoutApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get checkoutApply;

  /// No description provided for @movementYouSeem.
  ///
  /// In fr, this message translates to:
  /// **'Vous semblez être à'**
  String get movementYouSeem;

  /// No description provided for @movementSearchHere.
  ///
  /// In fr, this message translates to:
  /// **'Chercher ici'**
  String get movementSearchHere;

  /// No description provided for @movementDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get movementDismiss;

  /// No description provided for @restaurantCardMin.
  ///
  /// In fr, this message translates to:
  /// **'Min {amount} F'**
  String restaurantCardMin(String amount);

  /// No description provided for @restaurantCardCustomers.
  ///
  /// In fr, this message translates to:
  /// **'{count} clients'**
  String restaurantCardCustomers(String count);

  /// No description provided for @notifOrderSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande envoyee'**
  String get notifOrderSentTitle;

  /// No description provided for @notifOrderSentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande a ete envoyee au restaurant. En attente de confirmation.'**
  String get notifOrderSentMessage;

  /// No description provided for @notifConfirmedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande confirmee'**
  String get notifConfirmedTitle;

  /// No description provided for @notifConfirmedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande a ete acceptee par le restaurant.'**
  String get notifConfirmedMessage;

  /// No description provided for @notifPreparingTitle.
  ///
  /// In fr, this message translates to:
  /// **'En preparation'**
  String get notifPreparingTitle;

  /// No description provided for @notifPreparingMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant prepare votre commande.'**
  String get notifPreparingMessage;

  /// No description provided for @notifReadyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande prete'**
  String get notifReadyTitle;

  /// No description provided for @notifReadyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande est prete !'**
  String get notifReadyMessage;

  /// No description provided for @notifPickedUpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande recuperee'**
  String get notifPickedUpTitle;

  /// No description provided for @notifPickedUpMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le livreur a recupere votre commande.'**
  String get notifPickedUpMessage;

  /// No description provided for @notifDeliveringTitle.
  ///
  /// In fr, this message translates to:
  /// **'En livraison'**
  String get notifDeliveringTitle;

  /// No description provided for @notifDeliveringMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande est en route vers vous !'**
  String get notifDeliveringMessage;

  /// No description provided for @notifDeliveredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande livree'**
  String get notifDeliveredTitle;

  /// No description provided for @notifDeliveredMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande a ete livree. Bon appetit !'**
  String get notifDeliveredMessage;

  /// No description provided for @notifCancelledTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulee'**
  String get notifCancelledTitle;

  /// No description provided for @notifCancelledMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande a ete annulee.'**
  String get notifCancelledMessage;

  /// No description provided for @timeAgoJustNow.
  ///
  /// In fr, this message translates to:
  /// **'A l\'instant'**
  String get timeAgoJustNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {minutes} min'**
  String timeAgoMinutes(int minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {hours}h'**
  String timeAgoHours(int hours);

  /// No description provided for @timeAgoYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get timeAgoYesterday;

  /// No description provided for @timeAgoDays.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {days} jours'**
  String timeAgoDays(int days);

  /// No description provided for @locationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de livraison'**
  String get locationTitle;

  /// No description provided for @locationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez où vous faire livrer'**
  String get locationSubtitle;

  /// No description provided for @locationSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une adresse...'**
  String get locationSearchHint;

  /// No description provided for @locationNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour \"{query}\"'**
  String locationNoResult(String query);

  /// No description provided for @locationNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Adresse introuvable. Essayez d\'être plus précis.'**
  String get locationNotFound;

  /// No description provided for @locationOr.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get locationOr;

  /// No description provided for @locationLocating.
  ///
  /// In fr, this message translates to:
  /// **'Localisation en cours…'**
  String get locationLocating;

  /// No description provided for @locationUseGps.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ma position actuelle'**
  String get locationUseGps;

  /// No description provided for @locationGpsAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'GPS • Précision optimale'**
  String get locationGpsAccuracy;

  /// No description provided for @locationCurrentArea.
  ///
  /// In fr, this message translates to:
  /// **'Secteur actuel'**
  String get locationCurrentArea;

  /// No description provided for @locationAccessDenied.
  ///
  /// In fr, this message translates to:
  /// **'Accès à la localisation refusé.\nActivez-le dans vos Réglages.'**
  String get locationAccessDenied;

  /// No description provided for @locationSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get locationSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
