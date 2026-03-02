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
  String get categoryChicken => 'Chicken';

  @override
  String get categoryFish => 'Fish';

  @override
  String get categoryVegetarian => 'Vegetarian';

  @override
  String get categoryPasta => 'Pasta';

  @override
  String get categorySpicy => 'Spicy';

  @override
  String get categoryLocal => 'Local dishes';

  @override
  String get categoryAfrican => 'African';

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

  @override
  String get profileScreenTitle => 'My Profile';

  @override
  String get profileMenuPersonalInfo => 'Personal information';

  @override
  String get profileMenuFavorites => 'My favorites';

  @override
  String get profileMenuAddresses => 'My addresses';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuLanguage => 'Language';

  @override
  String get profileMenuHelpFaq => 'Help & FAQ';

  @override
  String get profileMenuLegal => 'Legal';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileNotLoggedInTitle => 'Sign in';

  @override
  String get profileNotLoggedInSubtitle =>
      'Access your profile, orders, and favorites.';

  @override
  String get profileNotLoggedInButton => 'Sign in';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the app language';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get homeHeaderQuestion => 'What are you\ncraving today?';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeAllRestaurants => 'All restaurants';

  @override
  String get homeErrorLoad =>
      'Unable to load restaurants. Check your connection.';

  @override
  String get homeEmptyTitle => 'No restaurant\nin your area';

  @override
  String get homeEmptySubtitle =>
      'Try changing your address\nor come back later.';

  @override
  String get homeEmptyAction => 'Change area';

  @override
  String get homeEmptyCategoryTitle => 'No restaurant\nfor this category';

  @override
  String get homeEmptyCategorySubtitle => 'Try another category';

  @override
  String get homeEmptyCategoryAction => 'See all restaurants';

  @override
  String get cartMyCart => 'My cart';

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
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get authLoginTab => 'Login';

  @override
  String get authSignupTab => 'Sign up';

  @override
  String get authLoginSubtitle => 'Sign in to discover African flavors.';

  @override
  String get authSignupSubtitle => 'Create your account and start ordering.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'amanda.samantha@email.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authFullNameLabel => 'Full name';

  @override
  String get authFullNameHint => 'Jean Kouassi';

  @override
  String get authPhoneLabel => 'Phone';

  @override
  String get authPhoneFieldHint => '+225 07 00 00 00 00';

  @override
  String get authPasswordMinHint => 'Min. 6 characters';

  @override
  String get authSignupButton => 'Create my account';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get authEmailAndPasswordRequired => 'Email and password required';

  @override
  String get authAllFieldsRequired => 'All fields are required';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get authLoginError => 'Login error';

  @override
  String get authSignupError => 'Sign up error';

  @override
  String get authForgotPasswordTitle => 'Forgot password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email to receive a verification code.';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authNewPasswordTitle => 'New password';

  @override
  String get authNewPasswordSubtitle => 'Choose a new secure password.';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authResetPassword => 'Reset';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String authOtpSubtitleEmail(String email) {
    return 'Code sent to\n$email';
  }

  @override
  String authCodeResent(String email) {
    return 'Code resent to $email';
  }

  @override
  String get authSendFailed => 'Send failed';

  @override
  String get authOtpIncorrect => 'Incorrect code, please try again';

  @override
  String get authOtpNetworkError =>
      'An error occurred. Check your connection and try again.';

  @override
  String get authResendIn => 'Resend in ';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authVerify => 'Verify';

  @override
  String get authVerification => 'Verification';

  @override
  String get authEmailInvalid => 'Please enter a valid email';

  @override
  String get authForgotPasswordDesc =>
      'Enter your email address to receive a reset code.';

  @override
  String authNewPasswordDesc(String email) {
    return 'Set your new password for $email';
  }

  @override
  String get authPasswordResetSuccess => 'Password reset successfully';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersTabPastItems => 'Past items';

  @override
  String get ordersTabOrders => 'Orders';

  @override
  String ordersDeliveryFee(String fee, String time) {
    return 'Delivery fee: $fee · $time';
  }

  @override
  String get ordersStatusPending => 'Pending';

  @override
  String get ordersStatusConfirmed => 'Confirmed';

  @override
  String get ordersStatusPreparing => 'Preparing';

  @override
  String get ordersStatusReady => 'Ready';

  @override
  String get ordersStatusPickedUp => 'Picked up';

  @override
  String get ordersStatusDelivering => 'Delivering';

  @override
  String get ordersStatusDelivered => 'Delivered';

  @override
  String get ordersStatusCancelled => 'Cancelled';

  @override
  String get ordersStatusUnknown => 'Unknown';

  @override
  String get ordersToday => 'Today';

  @override
  String get ordersYesterday => 'Yesterday';

  @override
  String ordersItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get ordersCancelTitle => 'Cancel order?';

  @override
  String get ordersCancelMessage =>
      'The restaurant has not yet accepted your order. Do you want to cancel it?';

  @override
  String get ordersCancelNo => 'No';

  @override
  String get ordersCancelYes => 'Yes, cancel';

  @override
  String get ordersCancelledByClient => 'Cancelled by client';

  @override
  String get ordersCancelledSuccess => 'Order cancelled';

  @override
  String get ordersCancelButton => 'Cancel';

  @override
  String get ordersReorderButton => 'Reorder';

  @override
  String get ordersLoginRequired => 'Login required';

  @override
  String get ordersLoginMessage => 'Sign in to view your orders';

  @override
  String get ordersEmptyTitle => 'No orders';

  @override
  String get ordersEmptyMessage => 'Your future orders will appear here';

  @override
  String get ordersConnectionError => 'Connection error';

  @override
  String get orderTrackingTitle => 'Order tracking';

  @override
  String get orderTrackingPickupOrder => 'Pickup order';

  @override
  String get orderTrackingClientInfo => 'Client information';

  @override
  String get orderTrackingRestaurant => 'Restaurant';

  @override
  String get orderTrackingRestaurantAddress => 'Restaurant address';

  @override
  String get orderTrackingSeeOnMap => 'See on map';

  @override
  String get orderTrackingRecipientName => 'Recipient name';

  @override
  String get orderTrackingPhone => 'Phone';

  @override
  String get orderTrackingPhoneNotProvided => 'Not provided';

  @override
  String get orderTrackingConfirmPickup => 'I picked up my order';

  @override
  String get orderTrackingOrderDetail => 'Order details';

  @override
  String orderTrackingOrderCompleted(String date) {
    return 'Order completed · $date';
  }

  @override
  String get orderTrackingReviewSubmitted => 'Review submitted — thank you!';

  @override
  String get orderTrackingRateEstablishment => 'Rate this establishment';

  @override
  String orderTrackingDidYouLike(String name) {
    return 'Did you enjoy $name?';
  }

  @override
  String get orderTrackingYourOrder => 'Your order';

  @override
  String get orderTrackingTotal => 'Total';

  @override
  String get orderTrackingViewReceipt => 'View receipt';

  @override
  String get orderTrackingYourDelivery => 'Your delivery';

  @override
  String orderTrackingByDriver(String name) {
    return 'by $name';
  }

  @override
  String get orderTrackingDefaultDriver => 'Amara Driver';

  @override
  String get orderTrackingReorder => 'Order again';

  @override
  String orderTrackingOrderCancelled(String date) {
    return 'Order cancelled · $date';
  }

  @override
  String get orderTrackingCancelledBadge => 'This order has been cancelled';

  @override
  String get orderTrackingDelivery => 'Delivery';

  @override
  String get orderTrackingPayment => 'Payment';

  @override
  String get orderTrackingPaymentMobileMoney => 'Mobile Money';

  @override
  String get orderTrackingPaymentCard => 'Credit card';

  @override
  String get orderTrackingPaymentCash => 'Cash';

  @override
  String get orderTrackingPaymentNotSpecified => 'Not specified';

  @override
  String get orderTrackingStepPending => 'Pending';

  @override
  String get orderTrackingStepPreparation => 'Preparing';

  @override
  String get orderTrackingStepReady => 'Ready';

  @override
  String get orderTrackingStepDelivering => 'Delivering';

  @override
  String get orderTrackingStepDelivered => 'Delivered';

  @override
  String get orderTrackingStepOrdered => 'Ordered';

  @override
  String get orderTrackingStepPickedUp => 'Picked up';

  @override
  String get orderTrackingChefCancelled => 'Order cancelled';

  @override
  String get orderTrackingChefPending => 'Waiting for confirmation';

  @override
  String get orderTrackingChefPreparing => 'The chef is preparing your order';

  @override
  String get orderTrackingChefReady => 'Your order is ready!';

  @override
  String get orderTrackingChefPickedUp => 'Order picked up!';

  @override
  String get orderTrackingChefDelivering => 'Your driver is on the way';

  @override
  String get orderTrackingChefDelivered => 'Order delivered!';

  @override
  String get orderTrackingChefProcessing => 'Processing';

  @override
  String get orderTrackingSubCancelled => 'Your order has been cancelled.';

  @override
  String orderTrackingSubPendingPickup(String restaurant) {
    return '$restaurant will confirm your order soon.';
  }

  @override
  String orderTrackingSubPreparingPickup(int minutes) {
    return 'Your meal will be ready in ~$minutes min.';
  }

  @override
  String orderTrackingSubReadyPickup(String restaurant) {
    return 'Head to $restaurant to pick up your order!';
  }

  @override
  String get orderTrackingSubPickedUp => 'Enjoy your meal!';

  @override
  String orderTrackingSubPendingDelivery(String restaurant) {
    return '$restaurant will confirm your order soon.';
  }

  @override
  String orderTrackingSubPreparingDelivery(int minutes) {
    return 'Your meal will be ready in ~$minutes min.\nEnjoy soon!';
  }

  @override
  String get orderTrackingSubReadyDelivery =>
      'A driver will pick up your order soon.';

  @override
  String get orderTrackingSubDeliveringDelivery =>
      'Your order is on its way. Stay available!';

  @override
  String get orderTrackingSubDeliveredDelivery =>
      'Your order has been delivered. Enjoy!';

  @override
  String get orderTrackingSummaryOrder => 'Order';

  @override
  String get orderTrackingSummaryMode => 'Mode';

  @override
  String get orderTrackingSummaryTakeaway => 'Takeaway';

  @override
  String get orderTrackingSummaryNotProvided => 'Not provided';

  @override
  String get orderTrackingMapDriver => 'Driver';

  @override
  String get orderTrackingMapYou => 'You';

  @override
  String get orderTrackingMapFollow => 'Follow';

  @override
  String get orderTrackingLoadError => 'Unable to load\nthe order';

  @override
  String get orderTrackingRetry => 'Retry';

  @override
  String get orderTrackingRateOrder => 'Rate this order';

  @override
  String orderTrackingTodayAt(String time) {
    return 'today at $time';
  }

  @override
  String orderTrackingYesterdayAt(String time) {
    return 'yesterday at $time';
  }

  @override
  String orderTrackingDateAt(String date, String time) {
    return 'on $date at $time';
  }

  @override
  String get receiptTitle => 'Receipt';

  @override
  String get receiptBrandSubtitle => 'African cuisine delivery';

  @override
  String get receiptOrderTitle => 'ORDER RECEIPT';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptRestaurant => 'Restaurant';

  @override
  String get receiptMode => 'Mode';

  @override
  String get receiptModeTakeaway => 'Takeaway';

  @override
  String get receiptModeDelivery => 'Delivery';

  @override
  String get receiptAddress => 'Address';

  @override
  String get receiptPayment => 'Payment';

  @override
  String get receiptPaymentMobileMoney => 'Mobile Money';

  @override
  String get receiptPaymentCard => 'Credit card';

  @override
  String get receiptPaymentCash => 'Cash';

  @override
  String get receiptPaymentNotSpecified => 'Not specified';

  @override
  String get receiptQty => 'Qty';

  @override
  String get receiptArticle => 'Item';

  @override
  String get receiptPrice => 'Price';

  @override
  String get receiptSubtotal => 'Subtotal';

  @override
  String get receiptDeliveryFee => 'Delivery fee';

  @override
  String get receiptFree => 'Free';

  @override
  String get receiptTotal => 'TOTAL';

  @override
  String get receiptThankYou => 'Thank you for your order!';

  @override
  String get receiptFooter => 'Amara — African flavors delivered to you';

  @override
  String get receiptDownload => 'Download receipt';

  @override
  String get receiptGenerationError => 'Error generating receipt';

  @override
  String get orderConfirmSent => 'Order sent!';

  @override
  String orderConfirmThankYou(String restaurant) {
    return 'Thank you for ordering from $restaurant. Our kitchen is preparing your meal. We will notify you when it\'s ready.';
  }

  @override
  String get orderConfirmOrderNumber => 'ORDER NUMBER';

  @override
  String get orderConfirmRecipientName => 'Recipient name';

  @override
  String get orderConfirmClientName => 'Amara Client';

  @override
  String get orderConfirmOrderDetail => 'Order details';

  @override
  String get orderConfirmNoItems => 'No items';

  @override
  String get orderConfirmTrackOrder => 'Track my order';

  @override
  String get orderConfirmBackHome => 'Back to home';

  @override
  String get reviewThankYou => 'Thank you for your review!';

  @override
  String get reviewFeedbackHelps => 'Your feedback helps the community';

  @override
  String get reviewTitle => 'Your review';

  @override
  String get reviewExperienceQuestion => 'How was your experience?';

  @override
  String get reviewRestaurantRating => 'Restaurant rating';

  @override
  String get reviewDriverRating => 'Driver rating';

  @override
  String get reviewOptional => '(optional)';

  @override
  String get reviewCommentLabel => 'A comment? (optional)';

  @override
  String get reviewCommentHint => 'Share your experience...';

  @override
  String get reviewSubmit => 'Submit review';

  @override
  String get reviewSkip => 'Skip';

  @override
  String get reviewRatingBad => 'Bad';

  @override
  String get reviewRatingAverage => 'Average';

  @override
  String get reviewRatingGood => 'Good';

  @override
  String get reviewRatingVeryGood => 'Very good';

  @override
  String get reviewRatingExcellent => 'Excellent';

  @override
  String get favoritesTitle => 'My favorites';

  @override
  String get favoritesLoadError => 'Loading error';

  @override
  String get favoritesLoadErrorMessage => 'Unable to load restaurants.';

  @override
  String get favoritesEmptyTitle => 'No favorites';

  @override
  String get favoritesEmptyMessage =>
      'Tap the heart on a restaurant to add it to your favorites.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get notificationsDeleteAllTitle => 'Delete all?';

  @override
  String get notificationsDeleteAllMessage =>
      'All your notifications will be deleted.';

  @override
  String get notificationsCancel => 'Cancel';

  @override
  String get notificationsDelete => 'Delete';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsSelect => 'Select';

  @override
  String get notificationsDeleteAll => 'Delete all';

  @override
  String get notificationsDeselectAll => 'Deselect all';

  @override
  String get notificationsSelectAll => 'Select all';

  @override
  String notificationsDeleteCount(int count) {
    return 'Delete ($count)';
  }

  @override
  String get notificationsSectionToday => 'Today';

  @override
  String get notificationsSectionThisWeek => 'This week';

  @override
  String get notificationsSectionOlder => 'Older';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyMessage => 'Your notifications will appear here';

  @override
  String get notificationsConnectionError => 'Connection error';

  @override
  String get addressesTitle => 'My addresses';

  @override
  String get addressesEmpty => 'No address';

  @override
  String get addressesEmptySubtitle =>
      'Add a delivery address to order faster.';

  @override
  String get addressesAdd => 'Add';

  @override
  String get addressesEditTitle => 'Edit address';

  @override
  String get addressesNewTitle => 'New address';

  @override
  String get addressesLabelField => 'Address name';

  @override
  String get addressesLabelHint => 'E.g.: Home, Office, Mom\'s place';

  @override
  String get addressesAddressField => 'Address';

  @override
  String get addressesAddressHint => 'Search an address...';

  @override
  String get addressesComplementField => 'Additional info';

  @override
  String get addressesComplementHint =>
      'Building, floor, apt, code, instructions...';

  @override
  String get addressesSaveChanges => 'Save changes';

  @override
  String get addressesAddAddress => 'Add address';

  @override
  String get addressesModified => 'Address updated';

  @override
  String get addressesAdded => 'Address added';

  @override
  String get addressesDefault => 'Default';

  @override
  String get addressesEdit => 'Edit';

  @override
  String get addressesSetDefault => 'Set as default';

  @override
  String get addressesDelete => 'Delete';

  @override
  String get personalInfoTitle => 'Personal information';

  @override
  String get personalInfoSave => 'Save';

  @override
  String get personalInfoEdit => 'Edit';

  @override
  String get personalInfoFullName => 'Full name';

  @override
  String get personalInfoEmail => 'Email';

  @override
  String get personalInfoPhone => 'Phone';

  @override
  String get personalInfoBirthDate => 'Date of birth';

  @override
  String get personalInfoBirthDateEmpty => 'Not provided';

  @override
  String get personalInfoMemberSince => 'Member since';

  @override
  String get personalInfoMemberAmara => 'Amara member';

  @override
  String get personalInfoUpdateFailed => 'Update failed';

  @override
  String get personalInfoUpdated => 'Profile updated';

  @override
  String get helpTitle => 'Help & FAQ';

  @override
  String get helpHeaderTitle => 'How can we\nhelp you?';

  @override
  String get helpHeaderSubtitle =>
      'Find answers to your questions or contact our support.';

  @override
  String get helpFaqSectionTitle => 'Frequently asked questions';

  @override
  String get helpNeedHelp => 'Need help?';

  @override
  String get helpFaqQ1 => 'How do I place an order?';

  @override
  String get helpFaqA1 =>
      'Browse restaurants from the home screen, choose your dishes, add them to your cart and confirm your order. You can track your delivery in real time.';

  @override
  String get helpFaqQ2 => 'What are the delivery times?';

  @override
  String get helpFaqA2 =>
      'Delivery takes on average 30 to 45 minutes depending on distance and restaurant preparation time. You can track your order in real time from the Orders tab.';

  @override
  String get helpFaqQ3 => 'How do I cancel an order?';

  @override
  String get helpFaqA3 =>
      'You can cancel your order from the Orders tab as long as it hasn\'t been accepted by the restaurant. Go to the order details and tap \"Cancel\".';

  @override
  String get helpFaqQ4 => 'What payment methods do you accept?';

  @override
  String get helpFaqA4 =>
      'Amara accepts Mobile Money (Orange Money, MTN Money, Wave), credit cards (Visa, Mastercard) and cash on delivery.';

  @override
  String get helpFaqQ5 => 'How do I add a delivery address?';

  @override
  String get helpFaqA5 =>
      'Go to your Profile > My addresses, then tap \"Add\". You can save multiple addresses and set a default address.';

  @override
  String get helpFaqQ6 => 'My order hasn\'t arrived, what should I do?';

  @override
  String get helpFaqA6 =>
      'Contact our support via the chat at the bottom of this page or call us. We will do our best to resolve your issue quickly.';

  @override
  String get helpFaqQ7 => 'How can I become a partner restaurant?';

  @override
  String get helpFaqA7 =>
      'Send us an email at partners@amara.app with your restaurant name, location and menu. Our team will get back to you within 48 hours.';

  @override
  String get helpContactChat => 'Live chat';

  @override
  String get helpContactChatSubtitle => 'Response in a few minutes';

  @override
  String get helpContactChatSoon => 'Chat coming soon';

  @override
  String get helpContactEmail => 'Email';

  @override
  String get helpContactEmailAddress => 'support@amara.app';

  @override
  String get helpContactPhone => 'Phone';

  @override
  String get helpContactPhoneNumber => '+225 07 00 00 00 00';

  @override
  String get legalTitle => 'Legal terms';

  @override
  String get legalTabCgu => 'TOS';

  @override
  String get legalTabPrivacy => 'Privacy';

  @override
  String get legalTabNotices => 'Notices';

  @override
  String legalLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get legalCguTitle1 => 'Article 1 — Purpose';

  @override
  String get legalCguBody1 =>
      'These General Terms of Use (hereinafter \"TOS\") govern access to and use of the Amara mobile application (hereinafter \"the Application\") published by Amara Technologies SAS.\n\nThe Application is intended for individuals (hereinafter \"the Client\" or \"the User\") wishing to order meals from partner restaurants for home delivery or on-site pickup.';

  @override
  String get legalCguTitle2 => 'Article 2 — Acceptance of TOS';

  @override
  String get legalCguBody2 =>
      'Registration and use of the Application imply full and complete acceptance of these TOS. The User acknowledges having read them and agrees to comply with them.\n\nAmara Technologies reserves the right to modify these TOS at any time. Modifications take effect upon publication in the Application. Continued use of the Application after modification constitutes acceptance of the new TOS.';

  @override
  String get legalCguTitle3 => 'Article 3 — Registration and account';

  @override
  String get legalCguBody3 =>
      '3.1. To access the Application\'s services, the User must create an account by providing accurate and complete information (name, email address, phone number).\n\n3.2. The User is solely responsible for the confidentiality of their login credentials. Any activity carried out from their account is presumed to have been performed by them.\n\n3.3. The User must be at least 16 years old to create an account. Minors must obtain authorization from their parents or legal guardians.\n\n3.4. In case of suspected unauthorized use, the User must immediately inform Amara Technologies at: support@amara-food.com.';

  @override
  String get legalCguTitle4 => 'Article 4 — Services offered';

  @override
  String get legalCguBody4 =>
      'The Application allows the User to:\n\n• Browse partner restaurants and their menus\n• View detailed dish descriptions (description, price, allergens)\n• Add items to cart and place orders\n• Choose between home delivery and restaurant pickup\n• Track order status in real time\n• Save favorite delivery addresses\n• View order history\n• Leave reviews and ratings for restaurants\n• Receive notifications about order progress\n• Benefit from promotions and special offers';

  @override
  String get legalCguTitle5 => 'Article 5 — Orders and payment';

  @override
  String get legalCguBody5 =>
      '5.1. The User places an order by selecting desired items from a partner restaurant\'s menu, then confirming the cart.\n\n5.2. Prices displayed in the Application are in CFA Francs (FCFA) and include item prices. Delivery fees are shown separately before order confirmation.\n\n5.3. Payment can be made through payment methods offered in the Application (mobile payment, cash on delivery, credit card subject to availability).\n\n5.4. The order is confirmed once payment is accepted or, in case of cash on delivery, once the order is validated by the restaurant.';

  @override
  String get legalCguTitle6 => 'Article 6 — Delivery';

  @override
  String get legalCguBody6 =>
      '6.1. Delivery times shown in the Application are estimates and may vary depending on distance, demand and traffic conditions.\n\n6.2. The User must ensure they provide an accurate delivery address and are available to receive their order.\n\n6.3. If the Client is absent during delivery, the driver will attempt to contact them. If the Client remains unreachable, the order may be cancelled without refund of delivery fees.\n\n6.4. Amara Technologies cannot be held responsible for delivery delays due to circumstances beyond its control (weather conditions, traffic jams, force majeure).';

  @override
  String get legalCguTitle7 => 'Article 7 — Cancellation and refund';

  @override
  String get legalCguBody7 =>
      '7.1. The User can cancel their order as long as it has not been accepted by the restaurant.\n\n7.2. Once the order is accepted and being prepared, cancellation is no longer possible unless agreed by the restaurant.\n\n7.3. In case of a problem with the order (missing item, error, non-conforming quality), the User can report the issue through the Application within 24 hours. Amara Technologies will review the claim and may offer a partial or full refund, credit, or new delivery.\n\n7.4. Refunds are made through the same payment method used for the order, within 5 to 10 business days.';

  @override
  String get legalCguTitle8 => 'Article 8 — User obligations';

  @override
  String get legalCguBody8 =>
      'The User agrees to:\n\n• Provide accurate information during registration and ordering\n• Use the Application fairly and in accordance with these TOS\n• Not use the Application for fraudulent or illegal purposes\n• Not publish insulting, defamatory or immoral content in reviews\n• Respect drivers and partner restaurant staff\n• Not attempt to circumvent the Application\'s security systems';

  @override
  String get legalCguTitle9 => 'Article 9 — Intellectual property';

  @override
  String get legalCguBody9 =>
      '9.1. The Application, its design, features, algorithms, source code and all associated content are the exclusive property of Amara Technologies SAS and are protected by intellectual property laws.\n\n9.2. Any reproduction, representation, modification or distribution of the Application or its content, in whole or in part, without prior written authorization, is prohibited.';

  @override
  String get legalCguTitle10 => 'Article 10 — Liability';

  @override
  String get legalCguBody10 =>
      '10.1. Amara Technologies acts as an intermediary between the User and partner restaurants. The preparation and quality of dishes are the sole responsibility of the restaurants.\n\n10.2. Amara Technologies strives to ensure the availability and proper functioning of the Application, without guaranteeing uninterrupted availability.\n\n10.3. Amara Technologies cannot be held liable for direct or indirect damages resulting from the use or inability to use the Application.';

  @override
  String get legalCguTitle11 => 'Article 11 — Suspension and termination';

  @override
  String get legalCguBody11 =>
      '11.1. Amara Technologies may suspend or delete the User\'s account in case of:\n\n• Violation of these TOS\n• Fraudulent or abusive behavior\n• Repeated offensive content in reviews\n• Non-payment of orders\n\n11.2. The User can delete their account at any time by contacting Amara support at support@amara-food.com or from the Application settings.';

  @override
  String get legalCguTitle12 => 'Article 12 — Applicable law and disputes';

  @override
  String get legalCguBody12 =>
      'These TOS are governed by Ivorian law. In case of a dispute regarding the interpretation or execution of these terms, the parties will endeavor to find an amicable solution. Failing that, the dispute will be submitted to the competent courts of Abidjan, Ivory Coast.';

  @override
  String get legalPrivacyTitle1 => 'Article 1 — Data controller';

  @override
  String get legalPrivacyBody1 =>
      'The data controller for personal data collected through the Amara Application is:\n\nAmara Technologies SAS\nHeadquarters: Abidjan, Ivory Coast\nEmail: privacy@amara-food.com';

  @override
  String get legalPrivacyTitle2 => 'Article 2 — Data collected';

  @override
  String get legalPrivacyBody2 =>
      'In the course of using the Application, the following data is collected:\n\n• Identification data: name, first name, email address, phone number\n• Delivery data: saved addresses, delivery instructions\n• Order data: order history, ordered items, amounts\n• Payment data: payment method used (banking data is not stored by Amara)\n• Geolocation data: position for delivery (with consent)\n• Usage data: favorite restaurants, dietary preferences\n• Technical data: IP address, device type, application version, connection logs\n• Reviews and ratings: scores and comments left on restaurants';

  @override
  String get legalPrivacyTitle3 => 'Article 3 — Processing purposes';

  @override
  String get legalPrivacyBody3 =>
      'The collected data is used to:\n\n• Create and manage the User\'s account\n• Process and track orders\n• Ensure delivery to the specified address\n• Enable secure payment\n• Send notifications about order status\n• Offer personalized restaurant and dish recommendations\n• Send promotional offers (with consent)\n• Improve the Application and user experience\n• Ensure platform security and prevent fraud\n• Respond to customer support requests\n• Comply with legal and regulatory obligations';

  @override
  String get legalPrivacyTitle4 => 'Article 4 — Legal basis for processing';

  @override
  String get legalPrivacyBody4 =>
      'The processing of personal data is based on:\n\n• Contract execution: order processing, delivery, payment\n• User consent: geolocation, marketing notifications, cookies\n• Legitimate interest of Amara Technologies: service improvement, fraud prevention, anonymized statistics\n• Compliance with legal obligations: accounting, taxation';

  @override
  String get legalPrivacyTitle5 => 'Article 5 — Data sharing';

  @override
  String get legalPrivacyBody5 =>
      'Personal data may be shared with:\n\n• Partner restaurants: name, delivery address and order details (necessary for preparation)\n• Drivers: name, delivery address and phone number (necessary for delivery)\n• Payment providers: information necessary for payment processing\n• Internal Amara Technologies teams: support, technical, marketing\n• Technical providers: hosting, cloud infrastructure\n• Competent authorities in case of legal obligation\n\nAmara Technologies does not sell or rent User personal data to third parties for commercial purposes.';

  @override
  String get legalPrivacyTitle6 => 'Article 6 — Data retention';

  @override
  String get legalPrivacyBody6 =>
      'Personal data is retained for:\n\n• Account data: for the duration of account use, then 3 years after deletion\n• Order data: 5 years from the order date (accounting obligation)\n• Geolocation data: order session duration only\n• Technical data (logs): 12 months\n• Reviews and ratings: as long as the account is active or until deletion request\n\nUpon expiration of these periods, data is deleted or irreversibly anonymized.';

  @override
  String get legalPrivacyTitle7 => 'Article 7 — Data security';

  @override
  String get legalPrivacyBody7 =>
      'Amara Technologies implements appropriate technical and organizational measures to protect personal data, including:\n\n• Encryption of data in transit (HTTPS/TLS)\n• Password encryption (bcrypt hashing)\n• Secure token authentication\n• Secure storage of sensitive information on device\n• Restricted data access following the principle of least privilege\n• Hosting on certified cloud infrastructure';

  @override
  String get legalPrivacyTitle8 => 'Article 8 — User rights';

  @override
  String get legalPrivacyBody8 =>
      'In accordance with applicable regulations, the User has the following rights:\n\n• Right of access: obtain confirmation of data processing and obtain a copy\n• Right of rectification: correct inaccurate or incomplete data\n• Right of deletion: request erasure of data under conditions provided by law\n• Right to portability: receive data in a structured, commonly used format\n• Right of opposition: object to data processing for legitimate reasons\n• Right to restriction: request suspension of processing in certain cases\n• Right to withdraw consent: withdraw consent at any time for consent-based processing\n\nTo exercise these rights, the User can send their request to:\nprivacy@amara-food.com\n\nAmara Technologies commits to responding within 30 days.';

  @override
  String get legalPrivacyTitle9 => 'Article 9 — Geolocation';

  @override
  String get legalPrivacyBody9 =>
      'The Application may use the User\'s device geolocation to:\n\n• Identify nearby restaurants\n• Estimate delivery times and fees\n• Enable real-time delivery tracking\n\nAccess to geolocation is subject to User consent via device settings. The User can disable geolocation at any time, but some features may be limited.';

  @override
  String get legalPrivacyTitle10 => 'Article 10 — Notifications';

  @override
  String get legalPrivacyBody10 =>
      'The Application may send push notifications to:\n\n• Inform about order progress (confirmation, preparation, delivery)\n• Notify about promotions or special offers\n• Communicate important account-related information\n\nThe User can manage notification preferences from their device settings.';

  @override
  String get legalPrivacyTitle11 => 'Article 11 — Policy modification';

  @override
  String get legalPrivacyBody11 =>
      'Amara Technologies reserves the right to modify this privacy policy at any time. The User will be informed of any substantial modification by notification in the Application. Continued use of the Application after modification constitutes acceptance of the updated policy.';

  @override
  String get legalNoticesTitle1 => 'Application publisher';

  @override
  String get legalNoticesBody1 =>
      'Amara Technologies SAS\nSimplified Joint Stock Company with capital of 1,000,000 FCFA\nHeadquarters: Abidjan, Cocody, Ivory Coast\nRCCM: CI-ABJ-2026-B-XXXXX\n\nPublication director: Amara Technologies Team\nEmail: contact@amara-food.com\nPhone: +225 XX XX XX XX XX';

  @override
  String get legalNoticesTitle2 => 'Hosting';

  @override
  String get legalNoticesBody2 =>
      'The Application and its data are hosted by:\n\nConvex, Inc.\nSan Francisco, CA, United States\nWebsite: https://convex.dev\n\nCloud infrastructure: Region EU-West-1 (European Union)\n\nApplication distribution:\n• Apple App Store (iOS) — Apple Inc.\n• Google Play Store (Android) — Google LLC';

  @override
  String get legalNoticesTitle3 => 'Intellectual property';

  @override
  String get legalNoticesBody3 =>
      'All elements composing the Amara Application (design, texts, logos, icons, images, features, source code) are the exclusive property of Amara Technologies SAS or are used under authorization.\n\nAny reproduction, representation, modification or distribution, total or partial, of the Application elements without prior written authorization from Amara Technologies is prohibited and constitutes counterfeiting punishable by law.\n\nThe \"Amara\" brand and associated logo are registered trademarks. Their unauthorized use is strictly prohibited.';

  @override
  String get legalNoticesTitle4 => 'Personal data';

  @override
  String get legalNoticesBody4 =>
      'Amara Technologies is committed to complying with applicable legislation regarding the protection of personal data.\n\nFor any questions regarding the processing of your personal data, please refer to our Privacy Policy accessible from the \"Privacy\" tab of this page, or contact us at: privacy@amara-food.com.\n\nSupervisory authority: National Commission for Information Technology and Civil Liberties of Ivory Coast (ARTCI).';

  @override
  String get legalNoticesTitle5 => 'Limitation of liability';

  @override
  String get legalNoticesBody5 =>
      'Amara Technologies acts as an intermediation platform between Users and partner restaurants.\n\nAmara Technologies cannot be held responsible for:\n\n• The quality, taste or conformity of dishes prepared by restaurants\n• Allergens not declared by partner restaurants\n• Delivery delays related to external circumstances\n• Temporary service interruptions for maintenance or updates\n• Any malfunction related to the User\'s device or network\n• Indirect losses or damages related to the use of the Application';

  @override
  String get legalNoticesTitle6 => 'Applicable law';

  @override
  String get legalNoticesBody6 =>
      'These legal notices are governed by Ivorian law.\n\nFor any complaint, you can contact us:\n• By email: support@amara-food.com\n• By mail: Amara Technologies SAS, Abidjan, Cocody, Ivory Coast\n\nIn case of dispute, the parties will endeavor to find an amicable solution prior to any legal action. Failing amicable agreement, the courts of Abidjan will have jurisdiction.';

  @override
  String get legalNoticesTitle7 => 'Credits';

  @override
  String get legalNoticesBody7 =>
      '• Design and development: Amara Technologies SAS\n• Framework: Flutter (Google)\n• Typography: Urbanist (Google Fonts)\n• Icons: Material Design Icons (Google)\n• Infrastructure: Convex (Convex, Inc.)';

  @override
  String get legalDateMarch2026 => 'March 1, 2026';

  @override
  String get errorDialogDefaultTitle => 'Oops!';

  @override
  String get errorDialogDismiss => 'Got it';

  @override
  String get errorDialogDeliveryAddress =>
      'Please enter your delivery address before ordering.';

  @override
  String get errorDialogRestaurantNotFound =>
      'This restaurant is no longer available. Please try again.';

  @override
  String get errorDialogSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorDialogAlreadyReviewed =>
      'You have already reviewed this order.';

  @override
  String get errorDialogInvalidTransition =>
      'This action is no longer available. Please refresh the page.';

  @override
  String get errorDialogEmptyCart =>
      'Your cart is empty. Add items before ordering.';

  @override
  String get errorDialogOrderNotFound =>
      'This order cannot be found. It may have been deleted.';

  @override
  String get errorDialogNetwork =>
      'Unable to connect to the server. Check your internet connection and try again.';

  @override
  String get errorDialogTimeout =>
      'The connection took too long. Check your internet connection and try again.';

  @override
  String get errorDialogFallback => 'An error occurred. Please try again.';

  @override
  String get onboardingSlide1Title => 'Your favorite\ndishes delivered';

  @override
  String get onboardingSlide1Desc =>
      'Discover hundreds of authentic dishes prepared by the best African restaurants in your city.';

  @override
  String get onboardingSlide2Title => 'Fast\ndelivery';

  @override
  String get onboardingSlide2Desc =>
      'Track your order in real time and receive your hot dishes directly at your door in less than 45 min.';

  @override
  String get onboardingSlide3Title => 'Simple &\nsecure payment';

  @override
  String get onboardingSlide3Desc =>
      'Mobile Money, bank card or cash — choose the payment method that suits you best.';

  @override
  String get onboardingStartButton => 'Get Started';

  @override
  String get searchExplore => 'Explore';

  @override
  String get searchSubtitle => 'The best restaurants around you';

  @override
  String get searchHint => 'Restaurant, dish, cuisine...';

  @override
  String get searchSortRecommended => 'Recommended';

  @override
  String get searchSortRating => 'Top rated';

  @override
  String get searchSortDistance => 'Distance';

  @override
  String get searchSortDeliveryTime => 'Speed';

  @override
  String get searchSortPrice => 'Delivery price';

  @override
  String get searchFilterReset => 'Reset';

  @override
  String get searchFilterFreeDelivery => 'Free delivery';

  @override
  String get searchFilterOpen => 'Open';

  @override
  String get searchFilterTakeaway => 'Takeaway';

  @override
  String get searchFilterBestRated => 'Top rated';

  @override
  String get searchFilterPromo => 'Promo';

  @override
  String get searchSectionTopRated => 'Top rated';

  @override
  String get searchSectionPromo => 'Promo';

  @override
  String get searchSectionAll => 'All restaurants';

  @override
  String get searchNoResults => 'No results';

  @override
  String searchNoResultsQuery(String query) {
    return 'No restaurant found for \"$query\"';
  }

  @override
  String get searchNoResultsFilters => 'No restaurant matches your filters';

  @override
  String get searchResetButton => 'Reset';

  @override
  String get searchErrorConnection => 'Connection error';

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
  String get searchSortBy => 'Sort by';

  @override
  String get searchFilters => 'Filters';

  @override
  String get searchFilterFreeDeliverySubtitle => 'Only with free delivery';

  @override
  String get searchFilterOpenNow => 'Open now';

  @override
  String get searchFilterOpenNowSubtitle => 'Hide closed restaurants';

  @override
  String get searchFilterMinRating => 'Minimum rating';

  @override
  String get searchFilterAllRatings => 'All ratings';

  @override
  String searchFilterRatingAndUp(String rating) {
    return '$rating ★ and up';
  }

  @override
  String get searchFilterApply => 'Apply';

  @override
  String get searchFreeDeliveryBadge => 'Free delivery';

  @override
  String get searchFreeDeliveryShort => 'Free';

  @override
  String get restaurantAllCategory => 'All';

  @override
  String restaurantNoDishFound(String query) {
    return 'No dish found for \"$query\"';
  }

  @override
  String get restaurantSearchDish => 'Search a dish...';

  @override
  String get restaurantShareText => 'Check out this restaurant on Amara!';

  @override
  String get restaurantLoadError => 'Unable to load restaurant';

  @override
  String get restaurantRetry => 'Retry';

  @override
  String get restaurantAlreadyOrdered => 'You have already ordered here';

  @override
  String restaurantReviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String get restaurantReviews => 'Reviews';

  @override
  String get restaurantClients => 'Customers';

  @override
  String get restaurantDelivery => 'Delivery';

  @override
  String get restaurantAsapTitle => 'ASAP';

  @override
  String get restaurantAsapDescription =>
      'Fill your cart to get a more accurate estimate based on selected items, real-time conditions, and delivery options at checkout. This estimate is the earliest arrival time, before item selection.';

  @override
  String get restaurantService => 'Service';

  @override
  String get restaurantServiceDelivery => 'Delivery';

  @override
  String get restaurantServiceTakeaway => 'Takeaway';

  @override
  String get restaurantServiceDineIn => 'Dine in';

  @override
  String get restaurantPayment => 'Payment';

  @override
  String get restaurantMinOrder => 'Min. order';

  @override
  String get restaurantCurrentPromos => 'Current promotions';

  @override
  String restaurantCodeCopied(String code) {
    return 'Code \"$code\" copied!';
  }

  @override
  String get restaurantInfo => 'Restaurant info';

  @override
  String get restaurantScheduleInfo => 'Hours & information';

  @override
  String get restaurantOpenNow => 'Open now';

  @override
  String get restaurantCurrentlyClosed => 'Currently closed';

  @override
  String get restaurantOpeningHours => 'Opening hours';

  @override
  String get restaurantToday => 'Today';

  @override
  String get restaurantMostLoved => 'Most loved';

  @override
  String get restaurantByPopularity => 'By popularity';

  @override
  String restaurantOrders(String count) {
    return '$count orders';
  }

  @override
  String get restaurantUnavailable => 'Unavailable';

  @override
  String get menuItemPopularBadge => '⭐ Popular';

  @override
  String get menuItemVegetarianBadge => '🌱 Vegetarian';

  @override
  String get menuItemSpicyBadge => '🌶️ Spicy';

  @override
  String menuItemExtraOptions(String price) {
    return '+$price F options';
  }

  @override
  String menuItemRatingReviews(String rating, int count) {
    return '$rating ($count reviews)';
  }

  @override
  String menuItemCustomers(String count) {
    return '$count customers';
  }

  @override
  String get menuItemPerfectWith => 'Perfect with this dish 😋';

  @override
  String get menuItemIngredientsAndSides => 'Ingredients & sides';

  @override
  String get menuItemChooseOneOption => 'Choose 1 option';

  @override
  String menuItemUpToChoices(int max) {
    return 'Up to $max choices';
  }

  @override
  String get menuItemRequired => 'Required';

  @override
  String get menuItemOptional => 'Optional';

  @override
  String get menuItemIncluded => 'Included';

  @override
  String get menuItemNoteForRestaurant => 'Note for the restaurant';

  @override
  String get menuItemNoteHint =>
      'E.g.: no onions, well done, sauce on the side...';

  @override
  String get menuItemAddToCart => 'Add';

  @override
  String get cartCarts => 'Carts';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptySubtitle =>
      'Add dishes from a restaurant\nto start your order';

  @override
  String get cartExploreRestaurants => 'Explore restaurants';

  @override
  String get cartDeliverTo => 'Deliver to Cocody, Abidjan';

  @override
  String get cartViewCart => 'View cart';

  @override
  String get cartShowStoreOffer => 'View store menu';

  @override
  String get cartClearCart => 'Clear this cart';

  @override
  String get cartCancel => 'Cancel';

  @override
  String get cartAddItems => 'Add items';

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartProceedToPayment => 'Proceed to payment';

  @override
  String cartOptionsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count options selected',
      one: '1 option selected',
    );
    return '$_temp0';
  }

  @override
  String get checkoutTitle => 'Payment';

  @override
  String get checkoutInvalidCode => 'Invalid code';

  @override
  String get checkoutEditInfo => 'Edit information';

  @override
  String get checkoutDeliveryAddress => 'Delivery address';

  @override
  String get checkoutSearchAddress => 'Search an address...';

  @override
  String get checkoutStreetDistrict => 'Street / District';

  @override
  String get checkoutStreetHint => 'E.g.: Street 123, next to the market...';

  @override
  String get checkoutDriverInstructions => 'Instructions for the driver';

  @override
  String get checkoutInstructionsHint =>
      'E.g.: Building B, 2nd floor, door 5...';

  @override
  String get checkoutPhoneNumber => 'Phone number';

  @override
  String get checkoutSave => 'Save';

  @override
  String get checkoutServiceMode => 'Service mode';

  @override
  String get checkoutDeliveryMode => 'Delivery';

  @override
  String get checkoutTakeawayMode => 'Takeaway';

  @override
  String get checkoutDeliverTo => 'Deliver to';

  @override
  String get checkoutPickupAt => 'Pick up at';

  @override
  String get checkoutPhone => 'Phone';

  @override
  String get checkoutOrderSummary => 'Order summary';

  @override
  String checkoutCodeApplied(String code) {
    return 'Code \"$code\" applied';
  }

  @override
  String get checkoutFreeDelivery => 'Free delivery';

  @override
  String get checkoutRemove => 'Remove';

  @override
  String get checkoutAddPromoCode => 'Add a promo code';

  @override
  String get checkoutSubtotal => 'Subtotal';

  @override
  String get checkoutServiceFee => 'Service';

  @override
  String get checkoutDeliveryFee => 'Delivery';

  @override
  String get checkoutFree => 'Free';

  @override
  String get checkoutDiscount => 'Discount';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutPaymentMethod => 'Payment method';

  @override
  String get checkoutNotAvailable => 'Not available';

  @override
  String get checkoutPlaceOrder => 'Place order and pay';

  @override
  String get checkoutPromoCode => 'Promo code';

  @override
  String get checkoutPromoHint => 'Enter your promo code';

  @override
  String get checkoutApply => 'Apply';

  @override
  String get movementYouSeem => 'You seem to be at';

  @override
  String get movementSearchHere => 'Search here';

  @override
  String get movementDismiss => 'Dismiss';

  @override
  String restaurantCardMin(String amount) {
    return 'Min $amount F';
  }

  @override
  String restaurantCardCustomers(String count) {
    return '$count customers';
  }

  @override
  String get notifOrderSentTitle => 'Order sent';

  @override
  String get notifOrderSentMessage =>
      'Your order has been sent to the restaurant. Waiting for confirmation.';

  @override
  String get notifConfirmedTitle => 'Order confirmed';

  @override
  String get notifConfirmedMessage =>
      'Your order has been accepted by the restaurant.';

  @override
  String get notifPreparingTitle => 'Preparing';

  @override
  String get notifPreparingMessage => 'The restaurant is preparing your order.';

  @override
  String get notifReadyTitle => 'Order ready';

  @override
  String get notifReadyMessage => 'Your order is ready!';

  @override
  String get notifPickedUpTitle => 'Order picked up';

  @override
  String get notifPickedUpMessage => 'The driver has picked up your order.';

  @override
  String get notifDeliveringTitle => 'Delivering';

  @override
  String get notifDeliveringMessage => 'Your order is on its way to you!';

  @override
  String get notifDeliveredTitle => 'Order delivered';

  @override
  String get notifDeliveredMessage => 'Your order has been delivered. Enjoy!';

  @override
  String get notifCancelledTitle => 'Order cancelled';

  @override
  String get notifCancelledMessage => 'Your order has been cancelled.';

  @override
  String get timeAgoJustNow => 'Just now';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String get timeAgoYesterday => 'Yesterday';

  @override
  String timeAgoDays(int days) {
    return '$days days ago';
  }

  @override
  String get locationTitle => 'Delivery address';

  @override
  String get locationSubtitle => 'Choose where to deliver';

  @override
  String get locationSearchHint => 'Search an address...';

  @override
  String locationNoResult(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get locationNotFound => 'Address not found. Try being more specific.';

  @override
  String get locationOr => 'or';

  @override
  String get locationLocating => 'Locating…';

  @override
  String get locationUseGps => 'Use my current location';

  @override
  String get locationGpsAccuracy => 'GPS • Optimal accuracy';

  @override
  String get locationCurrentArea => 'Current area';

  @override
  String get locationAccessDenied =>
      'Location access denied.\nEnable it in your Settings.';

  @override
  String get locationSettings => 'Settings';
}
