import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_model.dart';
import '../services/convex_client.dart';
import '../core/constants/app_images.dart';
import 'location_provider.dart';

// ─── Mapping Convex → Restaurant Flutter ─────────────────────────────────────

/// Convertit un document Convex `restaurants` en objet `Restaurant` Flutter.
Restaurant _restaurantFromConvex(Map<String, dynamic> d) {
  final id = d['_id'] as String? ?? '';
  final cuisineList = (d['cuisineType'] as List?)?.cast<String>() ?? [];
  final hours = d['openingHours'] as Map<String, dynamic>?;

  // Construire le planning horaire
  final dayNames = {
    'monday': 'Lundi', 'tuesday': 'Mardi', 'wednesday': 'Mercredi',
    'thursday': 'Jeudi', 'friday': 'Vendredi', 'saturday': 'Samedi',
    'sunday': 'Dimanche',
  };
  final schedule = <DaySchedule>[];
  if (hours != null) {
    for (final entry in dayNames.entries) {
      final slot = hours[entry.key] as Map<String, dynamic>?;
      schedule.add(DaySchedule(
        day: entry.value,
        open: slot?['open'] as String? ?? '',
        close: slot?['close'] as String? ?? '',
        isClosed: slot == null,
      ));
    }
  }

  final deliveryFeeRaw = (d['deliveryFee'] as num?)?.toDouble() ?? 0;
  final deliveryFeeStr = deliveryFeeRaw == 0
      ? 'Gratuit'
      : '${deliveryFeeRaw.toStringAsFixed(0)} F';

  final restaurantName = d['name'] as String? ?? '';
  final convexImageUrl = d['imageUrl'] as String?;

  return Restaurant(
    id: id,
    name: restaurantName,
    description: d['description'] as String? ?? '',
    cuisine: cuisineList.join(', '),
    imageEmoji: _cuisineEmoji(cuisineList.firstOrNull ?? ''),
    imageUrl: (convexImageUrl != null && convexImageUrl.isNotEmpty)
        ? convexImageUrl
        : AmaraImages.restaurantImage(restaurantName),
    rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (d['totalRatings'] as num?)?.toInt() ?? 0,
    deliveryTime: '${d['estimatedDeliveryTime'] ?? 30} min',
    deliveryFee: deliveryFeeStr,
    isOpen: d['isOpen'] as bool? ?? false,
    isFeatured: d['isVerified'] as bool? ?? false,
    address: d['address'] as String? ?? '',
    phone: (d['phone'] as String?)?.isNotEmpty == true
        ? d['phone'] as String
        : '',
    minOrder: (d['minOrderAmount'] as num?)?.toDouble() ?? 0,
    tags: cuisineList,
    likePercent: 0,
    totalCustomers: 0,
    hasOrdered: false,
    paymentMethods: (d['paymentMethods'] as List?)?.cast<String>() ?? const [],
    serviceModes: ((d['serviceModes'] as List?)?.cast<String>() ?? [])
        .map((s) {
          if (s == 'takeaway') return ServiceMode.takeaway;
          if (s == 'dineIn') return ServiceMode.dineIn;
          return ServiceMode.delivery;
        })
        .toList(),
    schedule: schedule,
    promos: const [],
    latitude: (d['latitude'] as num?)?.toDouble(),
    longitude: (d['longitude'] as num?)?.toDouble(),
  );
}

/// Convertit une liste de `menuItems` Convex en `List<MenuCategory>`.
List<MenuCategory> _menuFromConvex(List<dynamic> items) {
  final Map<String, List<MenuItem>> byCategory = {};
  for (final raw in items) {
    final d = Map<String, dynamic>.from(raw as Map);
    final cat = d['category'] as String? ?? 'Autres';
    final itemName = d['name'] as String? ?? '';
    final itemTags = (d['tags'] as List?)?.cast<String>() ?? [];
    // Parser les optionGroups depuis Convex (si présents)
    final rawGroups = d['optionGroups'] as List?;
    final optionGroups = rawGroups != null
        ? rawGroups.map((g) {
            final group = Map<String, dynamic>.from(g as Map);
            final rawOpts = group['options'] as List? ?? [];
            return MenuItemOptionGroup(
              id: group['id'] as String,
              title: group['title'] as String,
              required: group['required'] as bool? ?? false,
              maxSelections: (group['maxSelections'] as num?)?.toInt() ?? 1,
              options: rawOpts.map((o) {
                final opt = Map<String, dynamic>.from(o as Map);
                return MenuItemOption(
                  id: opt['id'] as String,
                  name: opt['name'] as String,
                  extraPrice: (opt['extraPrice'] as num?)?.toDouble() ?? 0,
                );
              }).toList(),
            );
          }).toList()
        : <MenuItemOptionGroup>[];

    final convexImageUrl = d['imageUrl'] as String?;
    final item = MenuItem(
      id: d['_id'] as String? ?? '',
      name: itemName,
      description: d['description'] as String? ?? '',
      price: (d['price'] as num?)?.toDouble() ?? 0,
      imageEmoji: _tagEmoji(itemTags.firstOrNull ?? ''),
      imageUrl: (convexImageUrl != null && convexImageUrl.isNotEmpty)
          ? convexImageUrl
          : AmaraImages.menuItemImage(itemName, itemTags),
      categoryId: cat,
      isAvailable: d['isAvailable'] as bool? ?? true,
      isPopular: itemTags.contains('populaire'),
      isVegetarian: itemTags.contains('végétarien'),
      isSpicy: itemTags.contains('épicé'),
      orderCount: (d['orderCount'] as num?)?.toInt() ?? 0,
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (d['totalRatings'] as num?)?.toInt() ?? 0,
      optionGroups: optionGroups,
      discountPercent: (d['discountPercent'] as num?)?.toDouble(),
      discountStartDate: (d['discountStartDate'] as num?)?.toInt(),
      discountEndDate: (d['discountEndDate'] as num?)?.toInt(),
    );
    byCategory.putIfAbsent(cat, () => []).add(item);
  }
  return byCategory.entries
      .map((e) => MenuCategory(id: e.key, name: e.key, items: e.value))
      .toList();
}

String _cuisineEmoji(String cuisine) {
  final c = cuisine.toLowerCase();
  if (c.contains('ivoirien') || c.contains('ivoir')) return '🍲';
  if (c.contains('sénégal') || c.contains('senegal')) return '🥘';
  if (c.contains('cameroun')) return '🍛';
  if (c.contains('nigérian') || c.contains('nigerian')) return '🫕';
  if (c.contains('maroc')) return '🍢';
  if (c.contains('éthiop') || c.contains('ethiop')) return '🧆';
  if (c.contains('pizza') || c.contains('italien')) return '🍕';
  if (c.contains('burger') || c.contains('américain')) return '🍔';
  return '🍽️';
}

String _tagEmoji(String tag) {
  final t = tag.toLowerCase();
  if (t.contains('épicé') || t.contains('spicy')) return '🌶️';
  if (t.contains('végétar')) return '🥗';
  if (t.contains('poisson') || t.contains('fish')) return '🐟';
  if (t.contains('poulet') || t.contains('chicken')) return '🍗';
  if (t.contains('boeuf') || t.contains('beef')) return '🥩';
  if (t.contains('riz') || t.contains('rice')) return '🍚';
  if (t.contains('boisson') || t.contains('drink')) return '🥤';
  return '🍽️';
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Liste des restaurants selon la position GPS de l'utilisateur.
/// Utilise les coordonnées GPS si disponibles, sinon fallback par ville.
final restaurantListProvider = FutureProvider<List<Restaurant>>((ref) async {
  final location = ref.watch(locationProvider);
  final client = ref.read(convexClientProvider);

  // Si position GPS disponible → requête par coordonnées (triée par distance)
  if (location.hasLocation) {
    try {
      var list = await client.getRestaurantsNearby(
        latitude: location.latitude!,
        longitude: location.longitude!,
        radiusKm: 15,
      );
      // Si aucun résultat dans 15km → élargir à 50km
      if (list.isEmpty) {
        list = await client.getRestaurantsNearby(
          latitude: location.latitude!,
          longitude: location.longitude!,
          radiusKm: 50,
        );
      }
      return list
          .map((d) => _restaurantFromConvex(Map<String, dynamic>.from(d as Map)))
          .toList();
    } catch (_) {
      // Fallback sur ville si erreur réseau
    }
  }

  // Fallback : requête par ville
  final list = await client.getRestaurants(city: location.city);
  return list
      .map((d) => _restaurantFromConvex(Map<String, dynamic>.from(d as Map)))
      .toList();
});

/// Détail d'un restaurant par ID — rafraîchi toutes les 8 secondes
final restaurantDetailProvider =
    StreamProvider.family<Restaurant, String>((ref, id) async* {
  final client = ref.read(convexClientProvider);

  // Première émission immédiate
  final data = await client.getRestaurant(id);
  yield _restaurantFromConvex(data);

  // Puis rafraîchissement toutes les 8 secondes
  await for (final _ in Stream.periodic(const Duration(seconds: 8))) {
    try {
      final updated = await client.getRestaurant(id);
      yield _restaurantFromConvex(updated);
    } catch (_) {
      // Ignore les erreurs réseau ponctuelles
    }
  }
});

/// Menu d'un restaurant — rafraîchi toutes les 8 secondes pour les mises à jour temps réel
final restaurantMenuProvider =
    StreamProvider.family<List<MenuCategory>, String>((ref, restaurantId) async* {
  final client = ref.read(convexClientProvider);

  // Première émission immédiate
  final items = await client.getMenu(restaurantId);
  yield _menuFromConvex(items);

  // Puis rafraîchissement toutes les 8 secondes
  await for (final _ in Stream.periodic(const Duration(seconds: 8))) {
    try {
      final updated = await client.getMenu(restaurantId);
      yield _menuFromConvex(updated);
    } catch (_) {
      // Ignore les erreurs réseau ponctuelles
    }
  }
});
