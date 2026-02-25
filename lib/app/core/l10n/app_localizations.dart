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
