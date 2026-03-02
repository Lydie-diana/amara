// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أمارا';

  @override
  String get tagline => 'النكهة الأفريقية، تُوصَّل إليك';

  @override
  String get splashLoading => 'جارٍ التحميل...';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ الآن';

  @override
  String get onboarding1Title => 'المطبخ الأفريقي\nفي متناول يدك';

  @override
  String get onboarding1Desc =>
      'اكتشف مئات الأطباق الأصيلة التي يعدّها أفضل المطاعم الأفريقية في مدينتك.';

  @override
  String get onboarding2Title => 'توصيل سريع\nوموثوق';

  @override
  String get onboarding2Desc =>
      'تتبّع طلبك في الوقت الفعلي واستقبل أطباقك الساخنة في أقل من 45 دقيقة.';

  @override
  String get onboarding3Title => 'دفع سهل\nوآمن';

  @override
  String get onboarding3Desc =>
      'Mobile Money أو بطاقة مصرفية أو نقداً — اختر طريقة الدفع المناسبة لك.';

  @override
  String get authWelcomeTo => 'مرحباً بك في';

  @override
  String get authPhoneTitle => 'أمارا 🍛';

  @override
  String get authPhoneSubtitle => 'أدخل رقم هاتفك\nللمتابعة';

  @override
  String get authPhoneHint => '00 00 00 00 00';

  @override
  String get authPhoneSmsInfo =>
      'سيتم إرسال رمز التحقق عبر الرسائل القصيرة إلى هذا الرقم.';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authOrWith => 'أو المتابعة بـ';

  @override
  String get authGoogleButton => 'المتابعة مع Google';

  @override
  String get otpTitle => 'التحقق';

  @override
  String otpSubtitle(String phone) {
    return 'تم إرسال الرمز إلى\n$phone';
  }

  @override
  String otpResendIn(int seconds) {
    return 'إعادة إرسال خلال $seconds ث';
  }

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String get otpVerify => 'تحقق';

  @override
  String get otpError => 'رمز غير صحيح، حاول مجدداً';

  @override
  String get otpResent => 'تم إعادة إرسال الرمز!';

  @override
  String get profileTitle => 'ملفك الشخصي';

  @override
  String get profileSubtitle => 'أخبرنا كيف ننادي عليك';

  @override
  String get profileNameLabel => 'الاسم الأول والأخير *';

  @override
  String get profileNameHint => 'مثال: كوفي منساه';

  @override
  String get profileEmailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get profileEmailHint => 'بريدك@example.com';

  @override
  String get profileSave => 'هيا نبدأ! 🚀';

  @override
  String get profileNameRequired => 'هذا الحقل مطلوب';

  @override
  String get profileNameTooShort => 'الحد الأدنى حرفان';

  @override
  String get profileEmailInvalid => 'بريد إلكتروني غير صالح';

  @override
  String homeGreeting(String name) {
    return 'يوم سعيد، $name 👋';
  }

  @override
  String get homeLocation => 'أبيدجان، كوت ديفوار';

  @override
  String get homeSearchHint => 'ابحث عن مطعم أو طبق...';

  @override
  String get homeCuisines => 'المطابخ';

  @override
  String get homePopular => 'الأكثر شعبية قربك';

  @override
  String get homeNew => 'وافدون جدد';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryStew => 'يخنة';

  @override
  String get categoryGrill => 'مشويات';

  @override
  String get categoryRice => 'أرز';

  @override
  String get categorySalad => 'سلطة';

  @override
  String get categoryPizza => 'بيتزا';

  @override
  String get categoryBurger => 'برغر';

  @override
  String get categoryDrink => 'مشروب';

  @override
  String get categoryDessert => 'حلوى';

  @override
  String get categoryChicken => 'Poulet';

  @override
  String get categoryFish => 'Poisson';

  @override
  String get categoryVegetarian => 'Végétarien';

  @override
  String get categoryPasta => 'Pâtes';

  @override
  String get categorySpicy => 'Épicé';

  @override
  String get categoryLocal => 'Plats locaux';

  @override
  String get categoryAfrican => 'Africain';

  @override
  String get restaurantOpen => 'مفتوح';

  @override
  String get restaurantClosed => 'مغلق';

  @override
  String get restaurantFeatured => '⭐ مشهور';

  @override
  String get restaurantFreeDelivery => 'مجاني';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشاف';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navProfile => 'الملف';

  @override
  String get promoTag1 => 'عرض خاص';

  @override
  String get promoTitle1 => 'توصيل مجاني';

  @override
  String get promoSubtitle1 => 'على طلبك الأول';

  @override
  String get promoTag2 => 'جديد';

  @override
  String get promoTitle2 => 'مطبخ أفريقي';

  @override
  String get promoSubtitle2 => 'الأصالة في متناولك';

  @override
  String get promoTag3 => 'خصم';

  @override
  String get promoTitle3 => '-20% الليلة';

  @override
  String get promoSubtitle3 => 'مطاعم شريكة مختارة';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorNetwork => 'خطأ في الشبكة، حاول مجدداً';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get profileScreenTitle => 'Mon Profil';

  @override
  String get profileMenuPersonalInfo => 'Informations personnelles';

  @override
  String get profileMenuFavorites => 'Mes favoris';

  @override
  String get profileMenuAddresses => 'Mes adresses';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuLanguage => 'Langue';

  @override
  String get profileMenuHelpFaq => 'Aide & FAQ';

  @override
  String get profileMenuLegal => 'Legal';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileNotLoggedInTitle => 'Connectez-vous';

  @override
  String get profileNotLoggedInSubtitle =>
      'Accédez à votre profil, vos commandes et vos favoris.';

  @override
  String get profileNotLoggedInButton => 'Se connecter';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Choisissez la langue de l\'application';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get homeHeaderQuestion =>
      'Qu\'est-ce qui vous\nfait envie aujourd\'hui ?';

  @override
  String get homeCategories => 'Catégories';

  @override
  String get homeAllRestaurants => 'Tous les restaurants';

  @override
  String get homeErrorLoad =>
      'Impossible de charger les restaurants. Vérifiez votre connexion.';

  @override
  String get homeEmptyTitle => 'Aucun restaurant\ndans votre secteur';

  @override
  String get homeEmptySubtitle =>
      'Essayez de modifier votre adresse\nou revenez plus tard.';

  @override
  String get homeEmptyAction => 'Changer de secteur';

  @override
  String get homeEmptyCategoryTitle => 'Aucun restaurant\npour cette catégorie';

  @override
  String get homeEmptyCategorySubtitle => 'Essayez une autre catégorie';

  @override
  String get homeEmptyCategoryAction => 'Voir tous les restaurants';

  @override
  String get cartMyCart => 'Mon panier';

  @override
  String cartRestaurantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count restaurants',
      one: '1 restaurant',
    );
    return '$_temp0';
  }

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get authLoginTab => 'Connexion';

  @override
  String get authSignupTab => 'Inscription';

  @override
  String get authLoginSubtitle =>
      'Connectez-vous pour découvrir les saveurs africaines.';

  @override
  String get authSignupSubtitle =>
      'Créez votre compte et commencez à commander.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'amanda.samantha@email.com';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authFullNameLabel => 'Nom complet';

  @override
  String get authFullNameHint => 'Jean Kouassi';

  @override
  String get authPhoneLabel => 'Téléphone';

  @override
  String get authPhoneFieldHint => '+225 07 00 00 00 00';

  @override
  String get authPasswordMinHint => 'Min. 6 caractères';

  @override
  String get authSignupButton => 'Créer mon compte';

  @override
  String get authOrContinueWith => 'ou continuer avec';

  @override
  String get authEmailAndPasswordRequired => 'Email et mot de passe requis';

  @override
  String get authAllFieldsRequired => 'Tous les champs sont requis';

  @override
  String get authPasswordMinLength =>
      'Le mot de passe doit avoir au moins 6 caractères';

  @override
  String get authLoginError => 'Erreur de connexion';

  @override
  String get authSignupError => 'Erreur lors de l\'inscription';

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get authForgotPasswordSubtitle =>
      'Entrez votre email pour recevoir un code de vérification.';

  @override
  String get authSendCode => 'Envoyer le code';

  @override
  String get authNewPasswordTitle => 'Nouveau mot de passe';

  @override
  String get authNewPasswordSubtitle =>
      'Choisissez un nouveau mot de passe sécurisé.';

  @override
  String get authNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get authConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get authResetPassword => 'Réinitialiser';

  @override
  String get authPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String authOtpSubtitleEmail(String email) {
    return 'Code envoyé à\n$email';
  }

  @override
  String authCodeResent(String email) {
    return 'Code renvoyé à $email';
  }

  @override
  String get authSendFailed => 'Envoi échoué';

  @override
  String get authOtpIncorrect => 'Code incorrect, réessayez';

  @override
  String get authOtpNetworkError =>
      'Une erreur est survenue. Vérifiez votre connexion et réessayez.';

  @override
  String get authResendIn => 'Renvoyer dans ';

  @override
  String get authResendCode => 'Renvoyer le code';

  @override
  String get authVerify => 'Vérifier';

  @override
  String get authVerification => 'Vérification';

  @override
  String get authEmailInvalid => 'Veuillez entrer un email valide';

  @override
  String get authForgotPasswordDesc =>
      'Entrez votre adresse email pour recevoir un code de réinitialisation.';

  @override
  String authNewPasswordDesc(String email) {
    return 'Définissez votre nouveau mot de passe pour $email';
  }

  @override
  String get authPasswordResetSuccess =>
      'Mot de passe réinitialisé avec succès';

  @override
  String get ordersTitle => 'Commandes';

  @override
  String get ordersTabPastItems => 'Anciens articles';

  @override
  String get ordersTabOrders => 'Commandes';

  @override
  String ordersDeliveryFee(String fee, String time) {
    return 'Frais de livraison : $fee · $time';
  }

  @override
  String get ordersStatusPending => 'En attente';

  @override
  String get ordersStatusConfirmed => 'Confirmee';

  @override
  String get ordersStatusPreparing => 'En preparation';

  @override
  String get ordersStatusReady => 'Prete';

  @override
  String get ordersStatusPickedUp => 'Recuperee';

  @override
  String get ordersStatusDelivering => 'En livraison';

  @override
  String get ordersStatusDelivered => 'Livree';

  @override
  String get ordersStatusCancelled => 'Annulee';

  @override
  String get ordersStatusUnknown => 'Inconnue';

  @override
  String get ordersToday => 'Aujourd\'hui';

  @override
  String get ordersYesterday => 'Hier';

  @override
  String ordersItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get ordersCancelTitle => 'Annuler la commande ?';

  @override
  String get ordersCancelMessage =>
      'Le restaurant n\'a pas encore accepte votre commande. Voulez-vous l\'annuler ?';

  @override
  String get ordersCancelNo => 'Non';

  @override
  String get ordersCancelYes => 'Oui, annuler';

  @override
  String get ordersCancelledByClient => 'Annulee par le client';

  @override
  String get ordersCancelledSuccess => 'Commande annulee';

  @override
  String get ordersCancelButton => 'Annuler';

  @override
  String get ordersReorderButton => 'Commander';

  @override
  String get ordersLoginRequired => 'Connexion requise';

  @override
  String get ordersLoginMessage => 'Connectez-vous pour voir vos commandes';

  @override
  String get ordersEmptyTitle => 'Aucune commande';

  @override
  String get ordersEmptyMessage => 'Vos futures commandes apparaitront ici';

  @override
  String get ordersConnectionError => 'Erreur de connexion';

  @override
  String get orderTrackingTitle => 'Suivi de commande';

  @override
  String get orderTrackingPickupOrder => 'Commande à emporter';

  @override
  String get orderTrackingClientInfo => 'Informations client';

  @override
  String get orderTrackingRestaurant => 'Restaurant';

  @override
  String get orderTrackingRestaurantAddress => 'Adresse du restaurant';

  @override
  String get orderTrackingSeeOnMap => 'Voir sur la carte';

  @override
  String get orderTrackingRecipientName => 'Nom du destinataire';

  @override
  String get orderTrackingPhone => 'Téléphone';

  @override
  String get orderTrackingPhoneNotProvided => 'Non renseigné';

  @override
  String get orderTrackingConfirmPickup => 'J\'ai recupere ma commande';

  @override
  String get orderTrackingOrderDetail => 'Detail de la commande';

  @override
  String orderTrackingOrderCompleted(String date) {
    return 'Commande terminee · $date';
  }

  @override
  String get orderTrackingReviewSubmitted => 'Avis soumis — merci !';

  @override
  String get orderTrackingRateEstablishment => 'Noter cet etablissement';

  @override
  String orderTrackingDidYouLike(String name) {
    return 'Avez-vous aime $name ?';
  }

  @override
  String get orderTrackingYourOrder => 'Votre commande';

  @override
  String get orderTrackingTotal => 'Total';

  @override
  String get orderTrackingViewReceipt => 'Voir le reçu';

  @override
  String get orderTrackingYourDelivery => 'Votre livraison';

  @override
  String orderTrackingByDriver(String name) {
    return 'par $name';
  }

  @override
  String get orderTrackingDefaultDriver => 'Livreur Amara';

  @override
  String get orderTrackingReorder => 'Commander a nouveau';

  @override
  String orderTrackingOrderCancelled(String date) {
    return 'Commande annulee · $date';
  }

  @override
  String get orderTrackingCancelledBadge => 'Cette commande a ete annulee';

  @override
  String get orderTrackingDelivery => 'Livraison';

  @override
  String get orderTrackingPayment => 'Paiement';

  @override
  String get orderTrackingPaymentMobileMoney => 'Mobile Money';

  @override
  String get orderTrackingPaymentCard => 'Carte bancaire';

  @override
  String get orderTrackingPaymentCash => 'Especes';

  @override
  String get orderTrackingPaymentNotSpecified => 'Non spécifié';

  @override
  String get orderTrackingStepPending => 'En attente';

  @override
  String get orderTrackingStepPreparation => 'Preparation';

  @override
  String get orderTrackingStepReady => 'Prete';

  @override
  String get orderTrackingStepDelivering => 'En livraison';

  @override
  String get orderTrackingStepDelivered => 'Livree';

  @override
  String get orderTrackingStepOrdered => 'Commandee';

  @override
  String get orderTrackingStepPickedUp => 'Recuperee';

  @override
  String get orderTrackingChefCancelled => 'Commande annulee';

  @override
  String get orderTrackingChefPending => 'En attente de confirmation';

  @override
  String get orderTrackingChefPreparing => 'Le chef prepare votre commande';

  @override
  String get orderTrackingChefReady => 'Votre commande est prete !';

  @override
  String get orderTrackingChefPickedUp => 'Commande recuperee !';

  @override
  String get orderTrackingChefDelivering => 'Votre livreur est en route';

  @override
  String get orderTrackingChefDelivered => 'Commande livree !';

  @override
  String get orderTrackingChefProcessing => 'En cours de traitement';

  @override
  String get orderTrackingSubCancelled => 'Votre commande a ete annulee.';

  @override
  String orderTrackingSubPendingPickup(String restaurant) {
    return '$restaurant va bientot confirmer votre commande.';
  }

  @override
  String orderTrackingSubPreparingPickup(int minutes) {
    return 'Votre repas sera pret dans ~$minutes min.';
  }

  @override
  String orderTrackingSubReadyPickup(String restaurant) {
    return 'Rendez-vous chez $restaurant pour recuperer votre commande !';
  }

  @override
  String get orderTrackingSubPickedUp => 'Bon appetit !';

  @override
  String orderTrackingSubPendingDelivery(String restaurant) {
    return '$restaurant va bientot confirmer votre commande.';
  }

  @override
  String orderTrackingSubPreparingDelivery(int minutes) {
    return 'Votre repas sera pret dans ~$minutes min.\nBon appetit bientot !';
  }

  @override
  String get orderTrackingSubReadyDelivery =>
      'Un livreur va bientot recuperer votre commande.';

  @override
  String get orderTrackingSubDeliveringDelivery =>
      'Votre commande est en chemin. Restez disponible !';

  @override
  String get orderTrackingSubDeliveredDelivery =>
      'Votre commande a ete livree. Bon appetit !';

  @override
  String get orderTrackingSummaryOrder => 'Commande';

  @override
  String get orderTrackingSummaryMode => 'Mode';

  @override
  String get orderTrackingSummaryTakeaway => 'A emporter';

  @override
  String get orderTrackingSummaryNotProvided => 'Non renseignee';

  @override
  String get orderTrackingMapDriver => 'Livreur';

  @override
  String get orderTrackingMapYou => 'Vous';

  @override
  String get orderTrackingMapFollow => 'Suivre';

  @override
  String get orderTrackingLoadError => 'Impossible de charger\nla commande';

  @override
  String get orderTrackingRetry => 'Reessayer';

  @override
  String get orderTrackingRateOrder => 'Noter cette commande';

  @override
  String orderTrackingTodayAt(String time) {
    return 'aujourd\'hui a $time';
  }

  @override
  String orderTrackingYesterdayAt(String time) {
    return 'hier a $time';
  }

  @override
  String orderTrackingDateAt(String date, String time) {
    return 'le $date a $time';
  }

  @override
  String get receiptTitle => 'Reçu';

  @override
  String get receiptBrandSubtitle => 'Livraison de cuisine africaine';

  @override
  String get receiptOrderTitle => 'REÇU DE COMMANDE';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptRestaurant => 'Restaurant';

  @override
  String get receiptMode => 'Mode';

  @override
  String get receiptModeTakeaway => 'À emporter';

  @override
  String get receiptModeDelivery => 'Livraison';

  @override
  String get receiptAddress => 'Adresse';

  @override
  String get receiptPayment => 'Paiement';

  @override
  String get receiptPaymentMobileMoney => 'Mobile Money';

  @override
  String get receiptPaymentCard => 'Carte bancaire';

  @override
  String get receiptPaymentCash => 'Cash';

  @override
  String get receiptPaymentNotSpecified => 'Non spécifié';

  @override
  String get receiptQty => 'Qté';

  @override
  String get receiptArticle => 'Article';

  @override
  String get receiptPrice => 'Prix';

  @override
  String get receiptSubtotal => 'Sous-total';

  @override
  String get receiptDeliveryFee => 'Frais de livraison';

  @override
  String get receiptFree => 'Gratuit';

  @override
  String get receiptTotal => 'TOTAL';

  @override
  String get receiptThankYou => 'Merci pour votre commande !';

  @override
  String get receiptFooter =>
      'Amara — La saveur de l\'Afrique livrée chez vous';

  @override
  String get receiptDownload => 'Télécharger le reçu';

  @override
  String get receiptGenerationError => 'Erreur lors de la génération du reçu';

  @override
  String get orderConfirmSent => 'Commande envoyee !';

  @override
  String orderConfirmThankYou(String restaurant) {
    return 'Merci d\'avoir commande chez $restaurant. Notre cuisine prepare votre repas. Nous vous informerons des qu\'il sera pret.';
  }

  @override
  String get orderConfirmOrderNumber => 'N DE COMMANDE';

  @override
  String get orderConfirmRecipientName => 'Nom du destinataire';

  @override
  String get orderConfirmClientName => 'Client Amara';

  @override
  String get orderConfirmOrderDetail => 'Detail de la commande';

  @override
  String get orderConfirmNoItems => 'Aucun article';

  @override
  String get orderConfirmTrackOrder => 'Suivre ma commande';

  @override
  String get orderConfirmBackHome => 'Retour a l\'accueil';

  @override
  String get reviewThankYou => 'Merci pour votre avis !';

  @override
  String get reviewFeedbackHelps => 'Votre retour aide la communaute';

  @override
  String get reviewTitle => 'Votre avis';

  @override
  String get reviewExperienceQuestion => 'Comment etait votre experience ?';

  @override
  String get reviewRestaurantRating => 'Note du restaurant';

  @override
  String get reviewDriverRating => 'Note du livreur';

  @override
  String get reviewOptional => '(optionnel)';

  @override
  String get reviewCommentLabel => 'Un commentaire ? (optionnel)';

  @override
  String get reviewCommentHint => 'Partagez votre experience...';

  @override
  String get reviewSubmit => 'Envoyer mon avis';

  @override
  String get reviewSkip => 'Passer';

  @override
  String get reviewRatingBad => 'Mauvais';

  @override
  String get reviewRatingAverage => 'Moyen';

  @override
  String get reviewRatingGood => 'Bien';

  @override
  String get reviewRatingVeryGood => 'Tres bien';

  @override
  String get reviewRatingExcellent => 'Excellent';

  @override
  String get favoritesTitle => 'Mes favoris';

  @override
  String get favoritesLoadError => 'Erreur de chargement';

  @override
  String get favoritesLoadErrorMessage =>
      'Impossible de charger les restaurants.';

  @override
  String get favoritesEmptyTitle => 'Aucun favori';

  @override
  String get favoritesEmptyMessage =>
      'Appuyez sur le coeur d\'un restaurant pour l\'ajouter à vos favoris.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count selectionne$_temp0';
  }

  @override
  String get notificationsDeleteAllTitle => 'Tout supprimer ?';

  @override
  String get notificationsDeleteAllMessage =>
      'Toutes vos notifications seront supprimees.';

  @override
  String get notificationsCancel => 'Annuler';

  @override
  String get notificationsDelete => 'Supprimer';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsSelect => 'Selectionner';

  @override
  String get notificationsDeleteAll => 'Tout supprimer';

  @override
  String get notificationsDeselectAll => 'Tout desélectionner';

  @override
  String get notificationsSelectAll => 'Tout selectionner';

  @override
  String notificationsDeleteCount(int count) {
    return 'Supprimer ($count)';
  }

  @override
  String get notificationsSectionToday => 'Aujourd\'hui';

  @override
  String get notificationsSectionThisWeek => 'Cette semaine';

  @override
  String get notificationsSectionOlder => 'Plus ancien';

  @override
  String get notificationsEmptyTitle => 'Aucune notification';

  @override
  String get notificationsEmptyMessage => 'Vos notifications apparaitront ici';

  @override
  String get notificationsConnectionError => 'Erreur de connexion';

  @override
  String get addressesTitle => 'Mes adresses';

  @override
  String get addressesEmpty => 'Aucune adresse';

  @override
  String get addressesEmptySubtitle =>
      'Ajoutez une adresse de livraison pour commander plus rapidement.';

  @override
  String get addressesAdd => 'Ajouter';

  @override
  String get addressesEditTitle => 'Modifier l\'adresse';

  @override
  String get addressesNewTitle => 'Nouvelle adresse';

  @override
  String get addressesLabelField => 'Nom de l\'adresse';

  @override
  String get addressesLabelHint => 'Ex: Maison, Bureau, Chez Maman';

  @override
  String get addressesAddressField => 'Adresse';

  @override
  String get addressesAddressHint => 'Rechercher une adresse...';

  @override
  String get addressesComplementField => 'Infos complémentaires';

  @override
  String get addressesComplementHint =>
      'Bâtiment, étage, apt, code, instructions...';

  @override
  String get addressesSaveChanges => 'Enregistrer les modifications';

  @override
  String get addressesAddAddress => 'Ajouter l\'adresse';

  @override
  String get addressesModified => 'Adresse modifiée';

  @override
  String get addressesAdded => 'Adresse ajoutée';

  @override
  String get addressesDefault => 'Par défaut';

  @override
  String get addressesEdit => 'Modifier';

  @override
  String get addressesSetDefault => 'Par défaut';

  @override
  String get addressesDelete => 'Supprimer';

  @override
  String get personalInfoTitle => 'Informations personnelles';

  @override
  String get personalInfoSave => 'Enregistrer';

  @override
  String get personalInfoEdit => 'Modifier';

  @override
  String get personalInfoFullName => 'Nom complet';

  @override
  String get personalInfoEmail => 'Email';

  @override
  String get personalInfoPhone => 'Téléphone';

  @override
  String get personalInfoBirthDate => 'Date de naissance';

  @override
  String get personalInfoBirthDateEmpty => 'Non renseignée';

  @override
  String get personalInfoMemberSince => 'Membre depuis';

  @override
  String get personalInfoMemberAmara => 'Membre Amara';

  @override
  String get personalInfoUpdateFailed => 'Mise à jour échouée';

  @override
  String get personalInfoUpdated => 'Profil mis à jour';

  @override
  String get helpTitle => 'Aide & FAQ';

  @override
  String get helpHeaderTitle => 'Comment pouvons-nous\nvous aider ?';

  @override
  String get helpHeaderSubtitle =>
      'Trouvez des réponses à vos questions ou contactez notre support.';

  @override
  String get helpFaqSectionTitle => 'Questions fréquentes';

  @override
  String get helpNeedHelp => 'Besoin d\'aide ?';

  @override
  String get helpFaqQ1 => 'Comment passer une commande ?';

  @override
  String get helpFaqA1 =>
      'Parcourez les restaurants depuis l\'accueil, choisissez vos plats, ajoutez-les au panier puis validez votre commande. Vous pouvez suivre la livraison en temps réel.';

  @override
  String get helpFaqQ2 => 'Quels sont les délais de livraison ?';

  @override
  String get helpFaqA2 =>
      'La livraison prend en moyenne 30 à 45 minutes selon la distance et la préparation du restaurant. Vous pouvez suivre votre commande en temps réel depuis l\'onglet Commandes.';

  @override
  String get helpFaqQ3 => 'Comment annuler une commande ?';

  @override
  String get helpFaqA3 =>
      'Vous pouvez annuler votre commande depuis l\'onglet Commandes tant qu\'elle n\'a pas été prise en charge par le restaurant. Rendez-vous dans le détail de la commande et appuyez sur \"Annuler\".';

  @override
  String get helpFaqQ4 => 'Quels moyens de paiement acceptez-vous ?';

  @override
  String get helpFaqA4 =>
      'Amara accepte le paiement par Mobile Money (Orange Money, MTN Money, Wave), carte bancaire (Visa, Mastercard) et le paiement en espèces à la livraison.';

  @override
  String get helpFaqQ5 => 'Comment ajouter une adresse de livraison ?';

  @override
  String get helpFaqA5 =>
      'Rendez-vous dans votre Profil > Mes adresses, puis appuyez sur \"Ajouter\". Vous pouvez enregistrer plusieurs adresses et définir une adresse par défaut.';

  @override
  String get helpFaqQ6 => 'Ma commande n\'est pas arrivée, que faire ?';

  @override
  String get helpFaqA6 =>
      'Contactez notre support via le chat en bas de cette page ou appelez-nous. Nous ferons le nécessaire pour résoudre votre problème rapidement.';

  @override
  String get helpFaqQ7 => 'Comment devenir restaurant partenaire ?';

  @override
  String get helpFaqA7 =>
      'Envoyez-nous un email à partenaires@amara.app avec le nom de votre restaurant, votre localisation et votre menu. Notre équipe vous recontactera sous 48h.';

  @override
  String get helpContactChat => 'Chat en direct';

  @override
  String get helpContactChatSubtitle => 'Réponse en quelques minutes';

  @override
  String get helpContactChatSoon => 'Chat bientôt disponible';

  @override
  String get helpContactEmail => 'Email';

  @override
  String get helpContactEmailAddress => 'support@amara.app';

  @override
  String get helpContactPhone => 'Téléphone';

  @override
  String get helpContactPhoneNumber => '+225 07 00 00 00 00';

  @override
  String get legalTitle => 'Conditions legales';

  @override
  String get legalTabCgu => 'CGU';

  @override
  String get legalTabPrivacy => 'Confidentialite';

  @override
  String get legalTabNotices => 'Mentions';

  @override
  String legalLastUpdated(String date) {
    return 'Derniere mise a jour : $date';
  }

  @override
  String get legalCguTitle1 => 'Article 1 — Objet';

  @override
  String get legalCguBody1 =>
      'Les presentes Conditions Generales d\'Utilisation (ci-apres « CGU ») regissent l\'acces et l\'utilisation de l\'application mobile Amara (ci-apres « l\'Application ») editee par Amara Technologies SAS.\n\nL\'Application est destinee aux particuliers (ci-apres « le Client » ou « l\'Utilisateur ») souhaitant commander des repas aupres de restaurants partenaires pour une livraison a domicile ou un retrait sur place.';

  @override
  String get legalCguTitle2 => 'Article 2 — Acceptation des CGU';

  @override
  String get legalCguBody2 =>
      'L\'inscription et l\'utilisation de l\'Application impliquent l\'acceptation pleine et entiere des presentes CGU. L\'Utilisateur reconnait en avoir pris connaissance et s\'engage a les respecter.\n\nAmara Technologies se reserve le droit de modifier les presentes CGU a tout moment. Les modifications entrent en vigueur des leur publication dans l\'Application. L\'utilisation continuee de l\'Application apres modification vaut acceptation des nouvelles CGU.';

  @override
  String get legalCguTitle3 => 'Article 3 — Inscription et compte';

  @override
  String get legalCguBody3 =>
      '3.1. Pour acceder aux services de l\'Application, l\'Utilisateur doit creer un compte en fournissant des informations exactes et completes (nom, adresse email, numero de telephone).\n\n3.2. L\'Utilisateur est seul responsable de la confidentialite de ses identifiants de connexion. Toute activite realisee depuis son compte est presumee effectuee par lui.\n\n3.3. L\'Utilisateur doit etre age d\'au moins 16 ans pour creer un compte. Les mineurs doivent obtenir l\'autorisation de leurs parents ou tuteurs legaux.\n\n3.4. En cas de suspicion d\'utilisation non autorisee, l\'Utilisateur doit en informer immediatement Amara Technologies a l\'adresse : support@amara-food.com.';

  @override
  String get legalCguTitle4 => 'Article 4 — Services proposes';

  @override
  String get legalCguBody4 =>
      'L\'Application permet a l\'Utilisateur de :\n\n• Parcourir les restaurants partenaires et leurs menus\n• Consulter les fiches detaillees des plats (description, prix, allergenes)\n• Ajouter des articles au panier et passer commande\n• Choisir entre la livraison a domicile et le retrait en restaurant\n• Suivre l\'etat de sa commande en temps reel\n• Enregistrer ses adresses de livraison favorites\n• Consulter l\'historique de ses commandes\n• Laisser des avis et notes sur les restaurants\n• Recevoir des notifications sur l\'avancement de ses commandes\n• Beneficier de promotions et offres speciales';

  @override
  String get legalCguTitle5 => 'Article 5 — Commandes et paiement';

  @override
  String get legalCguBody5 =>
      '5.1. L\'Utilisateur passe commande en selectionnant les articles souhaites dans le menu d\'un restaurant partenaire, puis en validant son panier.\n\n5.2. Les prix affiches dans l\'Application sont exprimes en Francs CFA (FCFA) et incluent le prix des articles. Les frais de livraison sont indiques separement avant la validation de la commande.\n\n5.3. Le paiement peut etre effectue par les moyens de paiement proposes dans l\'Application (paiement mobile, especes a la livraison, carte bancaire selon disponibilite).\n\n5.4. La commande est confirmee une fois le paiement accepte ou, en cas de paiement a la livraison, une fois la commande validee par le restaurant.';

  @override
  String get legalCguTitle6 => 'Article 6 — Livraison';

  @override
  String get legalCguBody6 =>
      '6.1. Les delais de livraison indiques dans l\'Application sont estimatifs et peuvent varier en fonction de la distance, de la demande et des conditions de circulation.\n\n6.2. L\'Utilisateur doit s\'assurer de fournir une adresse de livraison exacte et d\'etre disponible pour recevoir sa commande.\n\n6.3. En cas d\'absence du Client lors de la livraison, le livreur tentera de le contacter. Si le Client reste injoignable, la commande pourra etre annulee sans remboursement des frais de livraison.\n\n6.4. Amara Technologies ne saurait etre tenue responsable des retards de livraison lies a des circonstances independantes de sa volonte (conditions meteo, embouteillages, force majeure).';

  @override
  String get legalCguTitle7 => 'Article 7 — Annulation et remboursement';

  @override
  String get legalCguBody7 =>
      '7.1. L\'Utilisateur peut annuler sa commande tant que celle-ci n\'a pas ete acceptee par le restaurant.\n\n7.2. Une fois la commande acceptee et en preparation, l\'annulation n\'est plus possible sauf accord du restaurant.\n\n7.3. En cas de probleme avec la commande (article manquant, erreur, qualite non conforme), l\'Utilisateur peut signaler le probleme via l\'Application dans un delai de 24 heures. Amara Technologies etudiera la reclamation et pourra proposer un remboursement partiel ou total, un avoir, ou une nouvelle livraison.\n\n7.4. Les remboursements sont effectues par le meme moyen de paiement que celui utilise lors de la commande, dans un delai de 5 a 10 jours ouvrables.';

  @override
  String get legalCguTitle8 => 'Article 8 — Obligations de l\'Utilisateur';

  @override
  String get legalCguBody8 =>
      'L\'Utilisateur s\'engage a :\n\n• Fournir des informations exactes lors de l\'inscription et de la commande\n• Utiliser l\'Application de maniere loyale et conforme aux presentes CGU\n• Ne pas utiliser l\'Application a des fins frauduleuses ou illicites\n• Ne pas publier de contenu injurieux, diffamatoire ou contraire aux bonnes moeurs dans les avis\n• Respecter les livreurs et le personnel des restaurants partenaires\n• Ne pas tenter de contourner les systemes de securite de l\'Application';

  @override
  String get legalCguTitle9 => 'Article 9 — Propriete intellectuelle';

  @override
  String get legalCguBody9 =>
      '9.1. L\'Application, son design, ses fonctionnalites, ses algorithmes, son code source et l\'ensemble des contenus associes sont la propriete exclusive d\'Amara Technologies SAS et sont proteges par les lois relatives a la propriete intellectuelle.\n\n9.2. Toute reproduction, representation, modification ou distribution de l\'Application ou de ses contenus, en tout ou en partie, sans autorisation prealable ecrite, est interdite.';

  @override
  String get legalCguTitle10 => 'Article 10 — Responsabilite';

  @override
  String get legalCguBody10 =>
      '10.1. Amara Technologies agit en tant qu\'intermediaire entre l\'Utilisateur et les restaurants partenaires. La preparation et la qualite des plats relevent de la seule responsabilite des restaurants.\n\n10.2. Amara Technologies s\'efforce d\'assurer la disponibilite et le bon fonctionnement de l\'Application, sans garantir une disponibilite ininterrompue.\n\n10.3. Amara Technologies ne saurait etre tenue responsable des dommages directs ou indirects resultant de l\'utilisation ou de l\'impossibilite d\'utiliser l\'Application.';

  @override
  String get legalCguTitle11 => 'Article 11 — Suspension et resiliation';

  @override
  String get legalCguBody11 =>
      '11.1. Amara Technologies peut suspendre ou supprimer le compte de l\'Utilisateur en cas de :\n\n• Violation des presentes CGU\n• Comportement frauduleux ou abusif\n• Avis de contenus offensants repetes\n• Non-paiement des commandes\n\n11.2. L\'Utilisateur peut supprimer son compte a tout moment en contactant le support Amara a support@amara-food.com ou depuis les parametres de l\'Application.';

  @override
  String get legalCguTitle12 => 'Article 12 — Droit applicable et litiges';

  @override
  String get legalCguBody12 =>
      'Les presentes CGU sont regies par le droit ivoirien. En cas de litige relatif a l\'interpretation ou a l\'execution des presentes, les parties s\'efforceront de trouver une solution amiable. A defaut, le litige sera soumis aux tribunaux competents d\'Abidjan, Cote d\'Ivoire.';

  @override
  String get legalPrivacyTitle1 => 'Article 1 — Responsable du traitement';

  @override
  String get legalPrivacyBody1 =>
      'Le responsable du traitement des donnees personnelles collectees via l\'Application Amara est :\n\nAmara Technologies SAS\nSiege social : Abidjan, Cote d\'Ivoire\nEmail : privacy@amara-food.com';

  @override
  String get legalPrivacyTitle2 => 'Article 2 — Donnees collectees';

  @override
  String get legalPrivacyBody2 =>
      'Dans le cadre de l\'utilisation de l\'Application, les donnees suivantes sont collectees :\n\n• Donnees d\'identification : nom, prenom, adresse email, numero de telephone\n• Donnees de livraison : adresses enregistrees, instructions de livraison\n• Donnees de commandes : historique des commandes, articles commandes, montants\n• Donnees de paiement : mode de paiement utilise (les donnees bancaires ne sont pas stockees par Amara)\n• Donnees de geolocalisation : position pour la livraison (avec consentement)\n• Donnees d\'utilisation : restaurants favoris, preferences alimentaires\n• Donnees techniques : adresse IP, type d\'appareil, version de l\'application, logs de connexion\n• Avis et evaluations : notes et commentaires laisses sur les restaurants';

  @override
  String get legalPrivacyTitle3 => 'Article 3 — Finalites du traitement';

  @override
  String get legalPrivacyBody3 =>
      'Les donnees collectees sont utilisees pour :\n\n• Creer et gerer le compte de l\'Utilisateur\n• Traiter et suivre les commandes\n• Assurer la livraison a l\'adresse indiquee\n• Permettre le paiement securise\n• Envoyer des notifications sur l\'etat des commandes\n• Proposer des recommandations personnalisees de restaurants et de plats\n• Envoyer des offres promotionnelles (avec consentement)\n• Ameliorer l\'Application et l\'experience utilisateur\n• Assurer la securite de la plateforme et prevenir la fraude\n• Repondre aux demandes du support client\n• Respecter les obligations legales et reglementaires';

  @override
  String get legalPrivacyTitle4 => 'Article 4 — Base legale du traitement';

  @override
  String get legalPrivacyBody4 =>
      'Le traitement des donnees personnelles est fonde sur :\n\n• L\'execution du contrat : traitement des commandes, livraison, paiement\n• Le consentement de l\'Utilisateur : geolocalisation, notifications marketing, cookies\n• L\'interet legitime d\'Amara Technologies : amelioration des services, prevention de la fraude, statistiques anonymisees\n• Le respect des obligations legales : comptabilite, fiscalite';

  @override
  String get legalPrivacyTitle5 => 'Article 5 — Partage des donnees';

  @override
  String get legalPrivacyBody5 =>
      'Les donnees personnelles peuvent etre partagees avec :\n\n• Les restaurants partenaires : nom, adresse de livraison et details de la commande (necessaire pour la preparation)\n• Les livreurs : nom, adresse de livraison et numero de telephone (necessaire pour la livraison)\n• Les prestataires de paiement : informations necessaires au traitement du paiement\n• Les equipes internes d\'Amara Technologies : support, technique, marketing\n• Les prestataires techniques : hebergement, infrastructure cloud\n• Les autorites competentes en cas d\'obligation legale\n\nAmara Technologies ne vend ni ne loue les donnees personnelles de l\'Utilisateur a des tiers a des fins commerciales.';

  @override
  String get legalPrivacyTitle6 => 'Article 6 — Duree de conservation';

  @override
  String get legalPrivacyBody6 =>
      'Les donnees personnelles sont conservees pendant :\n\n• Donnees de compte : pendant toute la duree d\'utilisation du compte, puis 3 ans apres la suppression\n• Donnees de commandes : 5 ans a compter de la date de la commande (obligation comptable)\n• Donnees de geolocalisation : duree de la session de commande uniquement\n• Donnees techniques (logs) : 12 mois\n• Avis et evaluations : tant que le compte est actif ou jusqu\'a demande de suppression\n\nA l\'expiration de ces delais, les donnees sont supprimees ou anonymisees de maniere irreversible.';

  @override
  String get legalPrivacyTitle7 => 'Article 7 — Securite des donnees';

  @override
  String get legalPrivacyBody7 =>
      'Amara Technologies met en oeuvre les mesures techniques et organisationnelles appropriees pour proteger les donnees personnelles, notamment :\n\n• Chiffrement des donnees en transit (HTTPS/TLS)\n• Chiffrement des mots de passe (hachage bcrypt)\n• Authentification par token securise\n• Stockage securise des informations sensibles sur l\'appareil\n• Acces restreint aux donnees selon le principe du moindre privilege\n• Hebergement sur infrastructure cloud certifiee';

  @override
  String get legalPrivacyTitle8 => 'Article 8 — Droits de l\'Utilisateur';

  @override
  String get legalPrivacyBody8 =>
      'Conformement a la reglementation applicable, l\'Utilisateur dispose des droits suivants :\n\n• Droit d\'acces : obtenir la confirmation du traitement de ses donnees et en obtenir une copie\n• Droit de rectification : faire corriger les donnees inexactes ou incompletes\n• Droit de suppression : demander l\'effacement de ses donnees dans les conditions prevues par la loi\n• Droit a la portabilite : recevoir ses donnees dans un format structure et couramment utilise\n• Droit d\'opposition : s\'opposer au traitement de ses donnees pour des motifs legitimes\n• Droit a la limitation : demander la suspension du traitement dans certains cas\n• Droit de retrait du consentement : retirer son consentement a tout moment pour les traitements bases sur celui-ci\n\nPour exercer ces droits, l\'Utilisateur peut adresser sa demande a :\nprivacy@amara-food.com\n\nAmara Technologies s\'engage a repondre dans un delai de 30 jours.';

  @override
  String get legalPrivacyTitle9 => 'Article 9 — Geolocalisation';

  @override
  String get legalPrivacyBody9 =>
      'L\'Application peut utiliser la geolocalisation de l\'appareil de l\'Utilisateur pour :\n\n• Identifier les restaurants a proximite\n• Estimer les delais et frais de livraison\n• Permettre le suivi de la livraison en temps reel\n\nL\'acces a la geolocalisation est soumis au consentement de l\'Utilisateur via les parametres de son appareil. L\'Utilisateur peut desactiver la geolocalisation a tout moment, mais certaines fonctionnalites pourront etre limitees.';

  @override
  String get legalPrivacyTitle10 => 'Article 10 — Notifications';

  @override
  String get legalPrivacyBody10 =>
      'L\'Application peut envoyer des notifications push pour :\n\n• Informer de l\'avancement d\'une commande (confirmation, preparation, livraison)\n• Signaler des promotions ou offres speciales\n• Communiquer des informations importantes relatives au compte\n\nL\'Utilisateur peut gerer ses preferences de notification depuis les parametres de son appareil.';

  @override
  String get legalPrivacyTitle11 => 'Article 11 — Modification de la politique';

  @override
  String get legalPrivacyBody11 =>
      'Amara Technologies se reserve le droit de modifier la presente politique de confidentialite a tout moment. L\'Utilisateur sera informe de toute modification substantielle par notification dans l\'Application. L\'utilisation continuee de l\'Application apres modification vaut acceptation de la politique mise a jour.';

  @override
  String get legalNoticesTitle1 => 'Editeur de l\'Application';

  @override
  String get legalNoticesBody1 =>
      'Amara Technologies SAS\nSociete par Actions Simplifiee au capital de 1 000 000 FCFA\nSiege social : Abidjan, Cocody, Cote d\'Ivoire\nRCCM : CI-ABJ-2026-B-XXXXX\n\nDirecteur de la publication : Equipe Amara Technologies\nEmail : contact@amara-food.com\nTelephone : +225 XX XX XX XX XX';

  @override
  String get legalNoticesTitle2 => 'Hebergement';

  @override
  String get legalNoticesBody2 =>
      'L\'Application et ses donnees sont hebergees par :\n\nConvex, Inc.\nSan Francisco, CA, Etats-Unis\nSite web : https://convex.dev\n\nInfrastructure cloud : Region EU-West-1 (Union Europeenne)\n\nDistribution de l\'Application :\n• Apple App Store (iOS) — Apple Inc.\n• Google Play Store (Android) — Google LLC';

  @override
  String get legalNoticesTitle3 => 'Propriete intellectuelle';

  @override
  String get legalNoticesBody3 =>
      'L\'ensemble des elements composant l\'Application Amara (design, textes, logos, icones, images, fonctionnalites, code source) est la propriete exclusive d\'Amara Technologies SAS ou fait l\'objet d\'une autorisation d\'utilisation.\n\nToute reproduction, representation, modification ou distribution, totale ou partielle, des elements de l\'Application sans autorisation prealable ecrite d\'Amara Technologies est interdite et constitue une contrefacon sanctionnee par la loi.\n\nLa marque « Amara » ainsi que le logo associe sont des marques deposees. Leur utilisation non autorisee est strictement interdite.';

  @override
  String get legalNoticesTitle4 => 'Donnees personnelles';

  @override
  String get legalNoticesBody4 =>
      'Amara Technologies s\'engage a respecter la legislation en vigueur relative a la protection des donnees personnelles.\n\nPour toute question relative au traitement de vos donnees personnelles, veuillez consulter notre Politique de confidentialite accessible depuis l\'onglet « Confidentialite » de cette page, ou nous contacter a : privacy@amara-food.com.\n\nAutorite de controle : Commission Nationale de l\'Informatique et des Libertes de Cote d\'Ivoire (ARTCI).';

  @override
  String get legalNoticesTitle5 => 'Limitation de responsabilite';

  @override
  String get legalNoticesBody5 =>
      'Amara Technologies agit en tant que plateforme d\'intermediation entre les Utilisateurs et les restaurants partenaires.\n\nAmara Technologies ne pourra etre tenue responsable :\n\n• De la qualite, du gout ou de la conformite des plats prepares par les restaurants\n• Des allergenes non declares par les restaurants partenaires\n• Des retards de livraison lies a des circonstances exterieures\n• Des interruptions temporaires du service pour maintenance ou mise a jour\n• De tout dysfonctionnement lie a l\'appareil ou au reseau de l\'Utilisateur\n• Des pertes ou dommages indirects lies a l\'utilisation de l\'Application';

  @override
  String get legalNoticesTitle6 => 'Droit applicable';

  @override
  String get legalNoticesBody6 =>
      'Les presentes mentions legales sont regies par le droit ivoirien.\n\nPour toute reclamation, vous pouvez nous contacter :\n• Par email : support@amara-food.com\n• Par courrier : Amara Technologies SAS, Abidjan, Cocody, Cote d\'Ivoire\n\nEn cas de litige, les parties s\'efforceront de trouver une solution amiable prealablement a toute action judiciaire. A defaut d\'accord amiable, les tribunaux d\'Abidjan seront competents.';

  @override
  String get legalNoticesTitle7 => 'Credits';

  @override
  String get legalNoticesBody7 =>
      '• Design et developpement : Amara Technologies SAS\n• Framework : Flutter (Google)\n• Typographie : Urbanist (Google Fonts)\n• Icones : Material Design Icons (Google)\n• Infrastructure : Convex (Convex, Inc.)';

  @override
  String get legalDateMarch2026 => '1er mars 2026';

  @override
  String get errorDialogDefaultTitle => 'Oups !';

  @override
  String get errorDialogDismiss => 'Compris';

  @override
  String get errorDialogDeliveryAddress =>
      'Veuillez renseigner votre adresse de livraison avant de commander.';

  @override
  String get errorDialogRestaurantNotFound =>
      'Ce restaurant n\'est plus disponible. Veuillez réessayer.';

  @override
  String get errorDialogSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get errorDialogAlreadyReviewed =>
      'Vous avez déjà donné votre avis sur cette commande.';

  @override
  String get errorDialogInvalidTransition =>
      'Cette action n\'est plus disponible. Rafraîchissez la page.';

  @override
  String get errorDialogEmptyCart =>
      'Votre panier est vide. Ajoutez des articles avant de commander.';

  @override
  String get errorDialogOrderNotFound =>
      'Cette commande est introuvable. Elle a peut-être été supprimée.';

  @override
  String get errorDialogNetwork =>
      'Impossible de se connecter au serveur. Vérifiez votre connexion internet et réessayez.';

  @override
  String get errorDialogTimeout =>
      'La connexion a pris trop de temps. Vérifiez votre connexion internet et réessayez.';

  @override
  String get errorDialogFallback =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get onboardingSlide1Title => 'Vos plats\npréférés livrés';

  @override
  String get onboardingSlide1Desc =>
      'Découvrez des centaines de plats authentiques préparés par les meilleurs restaurants africains de votre ville.';

  @override
  String get onboardingSlide2Title => 'Livraison\nrapide';

  @override
  String get onboardingSlide2Desc =>
      'Suivez votre commande en temps réel et recevez vos plats chauds directement à votre porte en moins de 45 min.';

  @override
  String get onboardingSlide3Title => 'Paiement\nsimple & sécurisé';

  @override
  String get onboardingSlide3Desc =>
      'Mobile Money, carte bancaire ou cash — choisissez le moyen de paiement qui vous convient le mieux.';

  @override
  String get onboardingStartButton => 'Commencer';

  @override
  String get searchExplore => 'Explorer';

  @override
  String get searchSubtitle => 'Les meilleurs restaurants autour de vous';

  @override
  String get searchHint => 'Restaurant, plat, cuisine…';

  @override
  String get searchSortRecommended => 'Recommandé';

  @override
  String get searchSortRating => 'Mieux notés';

  @override
  String get searchSortDistance => 'Distance';

  @override
  String get searchSortDeliveryTime => 'Rapidité';

  @override
  String get searchSortPrice => 'Prix livraison';

  @override
  String get searchFilterReset => 'Reset';

  @override
  String get searchFilterFreeDelivery => 'Livraison gratuite';

  @override
  String get searchFilterOpen => 'Ouvert';

  @override
  String get searchFilterTakeaway => 'À emporter';

  @override
  String get searchFilterBestRated => 'Mieux notés';

  @override
  String get searchFilterPromo => 'Promo';

  @override
  String get searchSectionTopRated => 'Mieux notés';

  @override
  String get searchSectionPromo => 'Promo';

  @override
  String get searchSectionAll => 'Tous les restaurants';

  @override
  String get searchNoResults => 'Aucun résultat';

  @override
  String searchNoResultsQuery(String query) {
    return 'Aucun restaurant trouvé pour \"$query\"';
  }

  @override
  String get searchNoResultsFilters =>
      'Aucun restaurant correspond à vos filtres';

  @override
  String get searchResetButton => 'Réinitialiser';

  @override
  String get searchErrorConnection => 'Erreur de connexion';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count restaurant$_temp0';
  }

  @override
  String get searchSortBy => 'Trier par';

  @override
  String get searchFilters => 'Filtres';

  @override
  String get searchFilterFreeDeliverySubtitle =>
      'Uniquement avec livraison offerte';

  @override
  String get searchFilterOpenNow => 'Ouvert maintenant';

  @override
  String get searchFilterOpenNowSubtitle => 'Masquer les restaurants fermés';

  @override
  String get searchFilterMinRating => 'Note minimale';

  @override
  String get searchFilterAllRatings => 'Toutes les notes';

  @override
  String searchFilterRatingAndUp(String rating) {
    return '$rating ★ et plus';
  }

  @override
  String get searchFilterApply => 'Appliquer';

  @override
  String get searchFreeDeliveryBadge => 'Livraison gratuite';

  @override
  String get searchFreeDeliveryShort => 'Gratuit';

  @override
  String get restaurantAllCategory => 'Tous';

  @override
  String restaurantNoDishFound(String query) {
    return 'Aucun plat trouvé pour \"$query\"';
  }

  @override
  String get restaurantSearchDish => 'Rechercher un plat...';

  @override
  String get restaurantShareText => 'Découvre ce restaurant sur Amara !';

  @override
  String get restaurantLoadError => 'Impossible de charger le restaurant';

  @override
  String get restaurantRetry => 'Réessayer';

  @override
  String get restaurantAlreadyOrdered => 'Vous avez déjà commandé ici';

  @override
  String restaurantReviewsCount(int count) {
    return '$count avis';
  }

  @override
  String get restaurantReviews => 'Avis';

  @override
  String get restaurantClients => 'Clients';

  @override
  String get restaurantDelivery => 'Livraison';

  @override
  String get restaurantAsapTitle => 'Au plus tôt';

  @override
  String get restaurantAsapDescription =>
      'Remplissez votre panier pour obtenir une estimation plus précise en fonction des articles sélectionnés, des conditions en temps réel et des options de livraison lors du paiement. Cette estimation correspond à l\'heure d\'arrivée au plus tôt, avant la sélection d\'articles.';

  @override
  String get restaurantService => 'Service';

  @override
  String get restaurantServiceDelivery => 'Livraison';

  @override
  String get restaurantServiceTakeaway => 'À emporter';

  @override
  String get restaurantServiceDineIn => 'Sur place';

  @override
  String get restaurantPayment => 'Paiement';

  @override
  String get restaurantMinOrder => 'Min. commande';

  @override
  String get restaurantCurrentPromos => 'Promotions en cours';

  @override
  String restaurantCodeCopied(String code) {
    return 'Code \"$code\" copié !';
  }

  @override
  String get restaurantInfo => 'Infos du restaurant';

  @override
  String get restaurantScheduleInfo => 'Horaires & informations';

  @override
  String get restaurantOpenNow => 'Ouvert maintenant';

  @override
  String get restaurantCurrentlyClosed => 'Actuellement fermé';

  @override
  String get restaurantOpeningHours => 'Horaires d\'ouverture';

  @override
  String get restaurantToday => 'Aujourd\'hui';

  @override
  String get restaurantMostLoved => 'Les plus aimés';

  @override
  String get restaurantByPopularity => 'Par popularité';

  @override
  String restaurantOrders(String count) {
    return '$count commandes';
  }

  @override
  String get restaurantUnavailable => 'Indisponible';

  @override
  String get menuItemPopularBadge => '⭐ Populaire';

  @override
  String get menuItemVegetarianBadge => '🌱 Végétarien';

  @override
  String get menuItemSpicyBadge => '🌶️ Épicé';

  @override
  String menuItemExtraOptions(String price) {
    return '+$price F options';
  }

  @override
  String menuItemRatingReviews(String rating, int count) {
    return '$rating ($count avis)';
  }

  @override
  String menuItemCustomers(String count) {
    return '$count clients';
  }

  @override
  String get menuItemPerfectWith => 'Parfait avec ce plat 😋';

  @override
  String get menuItemIngredientsAndSides => 'Ingrédients & accompagnements';

  @override
  String get menuItemChooseOneOption => 'Choisissez 1 option';

  @override
  String menuItemUpToChoices(int max) {
    return 'Jusqu\'à $max choix';
  }

  @override
  String get menuItemRequired => 'Requis';

  @override
  String get menuItemOptional => 'Optionnel';

  @override
  String get menuItemIncluded => 'Inclus';

  @override
  String get menuItemNoteForRestaurant => 'Note pour le restaurant';

  @override
  String get menuItemNoteHint =>
      'Ex: sans oignons, cuisson bien cuite, sauce à part...';

  @override
  String get menuItemAddToCart => 'Ajouter';

  @override
  String get cartCarts => 'Paniers';

  @override
  String get cartEmpty => 'Votre panier est vide';

  @override
  String get cartEmptySubtitle =>
      'Ajoutez des plats depuis un restaurant\npour commencer votre commande';

  @override
  String get cartExploreRestaurants => 'Explorer les restaurants';

  @override
  String get cartDeliverTo => 'Livrer à l\'adresse Cocody, Abidjan';

  @override
  String get cartViewCart => 'Voir le panier';

  @override
  String get cartShowStoreOffer => 'Afficher l\'offre du magasin';

  @override
  String get cartClearCart => 'Vider ce panier';

  @override
  String get cartCancel => 'Annuler';

  @override
  String get cartAddItems => 'Ajouter des articles';

  @override
  String get cartSubtotal => 'Sous-total';

  @override
  String get cartProceedToPayment => 'Passer au paiement';

  @override
  String cartOptionsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count options sélectionnées',
      one: '1 option sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get checkoutTitle => 'Paiement';

  @override
  String get checkoutInvalidCode => 'Code invalide';

  @override
  String get checkoutEditInfo => 'Modifier les informations';

  @override
  String get checkoutDeliveryAddress => 'Adresse de livraison';

  @override
  String get checkoutSearchAddress => 'Rechercher une adresse...';

  @override
  String get checkoutStreetDistrict => 'Rue / Quartier';

  @override
  String get checkoutStreetHint => 'Ex: Rue 123, à côté du marché...';

  @override
  String get checkoutDriverInstructions => 'Instructions pour le livreur';

  @override
  String get checkoutInstructionsHint =>
      'Ex: Bâtiment B, 2ème étage, porte 5...';

  @override
  String get checkoutPhoneNumber => 'Numéro de téléphone';

  @override
  String get checkoutSave => 'Enregistrer';

  @override
  String get checkoutServiceMode => 'Mode de service';

  @override
  String get checkoutDeliveryMode => 'Livraison';

  @override
  String get checkoutTakeawayMode => 'À emporter';

  @override
  String get checkoutDeliverTo => 'Livrer à';

  @override
  String get checkoutPickupAt => 'À emporter chez';

  @override
  String get checkoutPhone => 'Téléphone';

  @override
  String get checkoutOrderSummary => 'Récapitulatif de la commande';

  @override
  String checkoutCodeApplied(String code) {
    return 'Code \"$code\" appliqué';
  }

  @override
  String get checkoutFreeDelivery => 'Livraison offerte';

  @override
  String get checkoutRemove => 'Retirer';

  @override
  String get checkoutAddPromoCode => 'Ajouter un code promotionnel';

  @override
  String get checkoutSubtotal => 'Sous-total';

  @override
  String get checkoutServiceFee => 'Service';

  @override
  String get checkoutDeliveryFee => 'Livraison';

  @override
  String get checkoutFree => 'Gratuit';

  @override
  String get checkoutDiscount => 'Réduction';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutPaymentMethod => 'Mode de paiement';

  @override
  String get checkoutNotAvailable => 'Non disponible';

  @override
  String get checkoutPlaceOrder => 'Commander et payer';

  @override
  String get checkoutPromoCode => 'Code promotionnel';

  @override
  String get checkoutPromoHint => 'Entrez votre code promo';

  @override
  String get checkoutApply => 'Appliquer';

  @override
  String get movementYouSeem => 'Vous semblez être à';

  @override
  String get movementSearchHere => 'Chercher ici';

  @override
  String get movementDismiss => 'Ignorer';

  @override
  String restaurantCardMin(String amount) {
    return 'Min $amount F';
  }

  @override
  String restaurantCardCustomers(String count) {
    return '$count clients';
  }

  @override
  String get notifOrderSentTitle => 'Commande envoyee';

  @override
  String get notifOrderSentMessage =>
      'Votre commande a ete envoyee au restaurant. En attente de confirmation.';

  @override
  String get notifConfirmedTitle => 'Commande confirmee';

  @override
  String get notifConfirmedMessage =>
      'Votre commande a ete acceptee par le restaurant.';

  @override
  String get notifPreparingTitle => 'En preparation';

  @override
  String get notifPreparingMessage => 'Le restaurant prepare votre commande.';

  @override
  String get notifReadyTitle => 'Commande prete';

  @override
  String get notifReadyMessage => 'Votre commande est prete !';

  @override
  String get notifPickedUpTitle => 'Commande recuperee';

  @override
  String get notifPickedUpMessage => 'Le livreur a recupere votre commande.';

  @override
  String get notifDeliveringTitle => 'En livraison';

  @override
  String get notifDeliveringMessage =>
      'Votre commande est en route vers vous !';

  @override
  String get notifDeliveredTitle => 'Commande livree';

  @override
  String get notifDeliveredMessage =>
      'Votre commande a ete livree. Bon appetit !';

  @override
  String get notifCancelledTitle => 'Commande annulee';

  @override
  String get notifCancelledMessage => 'Votre commande a ete annulee.';

  @override
  String get timeAgoJustNow => 'A l\'instant';

  @override
  String timeAgoMinutes(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String timeAgoHours(int hours) {
    return 'Il y a ${hours}h';
  }

  @override
  String get timeAgoYesterday => 'Hier';

  @override
  String timeAgoDays(int days) {
    return 'Il y a $days jours';
  }

  @override
  String get locationTitle => 'Adresse de livraison';

  @override
  String get locationSubtitle => 'Choisissez où vous faire livrer';

  @override
  String get locationSearchHint => 'Rechercher une adresse...';

  @override
  String locationNoResult(String query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get locationNotFound =>
      'Adresse introuvable. Essayez d\'être plus précis.';

  @override
  String get locationOr => 'ou';

  @override
  String get locationLocating => 'Localisation en cours…';

  @override
  String get locationUseGps => 'Utiliser ma position actuelle';

  @override
  String get locationGpsAccuracy => 'GPS • Précision optimale';

  @override
  String get locationCurrentArea => 'Secteur actuel';

  @override
  String get locationAccessDenied =>
      'Accès à la localisation refusé.\nActivez-le dans vos Réglages.';

  @override
  String get locationSettings => 'Réglages';
}
