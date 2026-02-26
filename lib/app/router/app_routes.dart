class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String authPhone = '/auth/phone';
  static const String authOtp = '/auth/otp';
  static const String authProfile = '/auth/profile';

  // Main
  static const String home = '/home';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Restaurant
  static const String restaurant = '/restaurant/:id';
  static const String restaurantPath = '/restaurant';

  // Cart & Checkout
  static const String cart = '/cart';
  static const String cartDetail = '/cart/:restaurantId';
  static const String cartDetailPath = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order/:id/confirmation';
  static const String orderConfirmationPath = '/order';
  static const String orderTracking = '/order/:id/tracking';
  static const String orderTrackingPath = '/order';

  // Favorites
  static const String favorites = '/favorites';

  // Menu item detail
  static const String menuItemDetail = '/menu-item';

  // Profile sub-pages
  static const String personalInfo = '/profile/personal-info';
  static const String myAddresses = '/profile/addresses';
  static const String helpFaq = '/profile/help-faq';
}
