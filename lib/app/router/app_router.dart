import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_routes.dart';

// Feature imports
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/phone/phone_screen.dart';
// OTP et ProfileSetup retirés du flow — OTP avait pin==123456 (faille sécurité)
// ProfileSetup ne sauvegardait rien. À réintégrer quand le backend sera prêt.
import '../../features/shell/main_shell.dart';
import '../../features/restaurant/restaurant_detail_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/cart/cart_detail_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/order_confirmation/order_confirmation_screen.dart';
import '../../features/order_tracking/order_tracking_screen.dart';
import '../../features/review/review_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/profile/personal_info_screen.dart';
import '../../features/profile/my_addresses_screen.dart';
import '../../features/profile/help_faq_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.authPhone,
        pageBuilder: (context, state) => _buildSlideUpPage(
          state: state,
          child: const PhoneScreen(),
        ),
      ),
      // Routes OTP et ProfileSetup désactivées (voir commentaire imports)

      // Main app
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const MainShell(),
        ),
      ),

      // Restaurant detail
      GoRoute(
        path: AppRoutes.restaurant,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildSlideUpPage(
            state: state,
            child: RestaurantDetailScreen(restaurantId: id),
          );
        },
      ),

      // Cart (liste des paniers)
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (context, state) => _buildSlideUpPage(
          state: state,
          child: const CartScreen(),
        ),
      ),

      // Cart detail (détail panier d'un restaurant)
      GoRoute(
        path: AppRoutes.cartDetail,
        pageBuilder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId'] ?? '';
          return _buildSlideUpPage(
            state: state,
            child: CartDetailScreen(restaurantId: restaurantId),
          );
        },
      ),

      // Checkout (optionnel: ?restaurantId=xxx pour filtrer par restaurant)
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) {
          final restaurantId = state.uri.queryParameters['restaurantId'];
          return _buildSlideUpPage(
            state: state,
            child: CheckoutScreen(restaurantId: restaurantId),
          );
        },
      ),

      // Order confirmation
      GoRoute(
        path: AppRoutes.orderConfirmation,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'ORD000';
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPage(
            state: state,
            child: OrderConfirmationScreen(
              orderId: id,
              restaurantName: extra?['restaurantName'] as String? ?? 'Restaurant',
              orderItems: (extra?['items'] as List<dynamic>?)
                      ?.cast<Map<String, dynamic>>() ??
                  [],
            ),
          );
        },
      ),

      // Favorites
      GoRoute(
        path: AppRoutes.favorites,
        pageBuilder: (context, state) => _buildSlideUpPage(
          state: state,
          child: const FavoritesScreen(),
        ),
      ),

      // Profile sub-pages
      GoRoute(
        path: AppRoutes.personalInfo,
        pageBuilder: (context, state) => _buildSlideUpPage(
          state: state,
          child: const PersonalInfoScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.myAddresses,
        pageBuilder: (context, state) => _buildSlideUpPage(
          state: state,
          child: const MyAddressesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.helpFaq,
        pageBuilder: (context, state) => _buildSlideUpPage(
          state: state,
          child: const HelpFaqScreen(),
        ),
      ),

      // Order tracking
      GoRoute(
        path: AppRoutes.orderTracking,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildSlideUpPage(
            state: state,
            child: OrderTrackingScreen(orderId: id),
          );
        },
      ),

      // Review
      GoRoute(
        path: AppRoutes.review,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return _buildSlideUpPage(
            state: state,
            child: ReviewScreen(
              orderId: id,
              restaurantName:
                  extra?['restaurantName'] as String? ?? 'Restaurant',
              hasDriver: extra?['hasDriver'] as bool? ?? false,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF1F172B),
      body: Center(
        child: Text(
          'Page introuvable',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _buildSlideUpPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}
