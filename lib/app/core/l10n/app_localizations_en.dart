// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Amara';

  @override
  String get tagline => 'African flavors, delivered to you';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboarding1Title => 'African cuisine\nat your fingertips';

  @override
  String get onboarding1Desc =>
      'Discover hundreds of authentic dishes prepared by the best African restaurants in your city.';

  @override
  String get onboarding2Title => 'Fast & reliable\ndelivery';

  @override
  String get onboarding2Desc =>
      'Track your order in real time and receive your hot dishes directly at your door in less than 45 min.';

  @override
  String get onboarding3Title => 'Simple &\nsecure payment';

  @override
  String get onboarding3Desc =>
      'Mobile Money, bank card or cash — choose the payment method that suits you best.';

  @override
  String get authWelcomeTo => 'Welcome to';

  @override
  String get authPhoneTitle => 'Amara 🍛';

  @override
  String get authPhoneSubtitle => 'Enter your phone number\nto continue';

  @override
  String get authPhoneHint => '00 00 00 00 00';

  @override
  String get authPhoneSmsInfo =>
      'A verification code will be sent by SMS to this number.';

  @override
  String get authContinue => 'Continue';

  @override
  String get authOrWith => 'or continue with';

  @override
  String get authGoogleButton => 'Continue with Google';

  @override
  String get otpTitle => 'Verification';

  @override
  String otpSubtitle(String phone) {
    return 'Code sent to\n$phone';
  }

  @override
  String otpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpError => 'Incorrect code, please try again';

  @override
  String get otpResent => 'Code resent!';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileSubtitle => 'Tell us what to call you';

  @override
  String get profileNameLabel => 'First and last name *';

  @override
  String get profileNameHint => 'e.g. Kofi Mensah';

  @override
  String get profileEmailLabel => 'Email (optional)';

  @override
  String get profileEmailHint => 'your@email.com';

  @override
  String get profileSave => 'Let\'s go! 🚀';

  @override
  String get profileNameRequired => 'This field is required';

  @override
  String get profileNameTooShort => 'Minimum 2 characters';

  @override
  String get profileEmailInvalid => 'Invalid email';

  @override
  String homeGreeting(String name) {
    return 'Good day, $name 👋';
  }

  @override
  String get homeLocation => 'Abidjan, Côte d\'Ivoire';

  @override
  String get homeSearchHint => 'Search a restaurant, a dish...';

  @override
  String get homeCuisines => 'Cuisines';

  @override
  String get homePopular => 'Popular near you';

  @override
  String get homeNew => 'New arrivals';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryStew => 'Stew';

  @override
  String get categoryGrill => 'Grills';

  @override
  String get categoryRice => 'Rice';

  @override
  String get categorySalad => 'Salad';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryBurger => 'Burger';

  @override
  String get categoryDrink => 'Drink';

  @override
  String get categoryDessert => 'Dessert';

  @override
  String get restaurantOpen => 'Open';

  @override
  String get restaurantClosed => 'Closed';

  @override
  String get restaurantFeatured => '⭐ Popular';

  @override
  String get restaurantFreeDelivery => 'Free';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get promoTag1 => 'SPECIAL OFFER';

  @override
  String get promoTitle1 => 'Free delivery';

  @override
  String get promoSubtitle1 => 'On your 1st order';

  @override
  String get promoTag2 => 'NEW';

  @override
  String get promoTitle2 => 'African cuisine';

  @override
  String get promoSubtitle2 => 'Authenticity at your fingertips';

  @override
  String get promoTag3 => 'PROMO';

  @override
  String get promoTitle3 => '-20% tonight';

  @override
  String get promoSubtitle3 => 'Selected partner restaurants';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorNetwork => 'Network error, please try again';

  @override
  String get errorGeneric => 'An error occurred';
}
