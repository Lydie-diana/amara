import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_model.dart';
import '../services/convex_client.dart';
import '../core/constants/app_images.dart';

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
    paymentMethods: const ['Mobile Money', 'Cash'],
    serviceModes: const [ServiceMode.delivery, ServiceMode.takeaway],
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
      isPopular: (d['isPopular'] as bool?) ?? false,
      likeCount: (d['likeCount'] as num?)?.toInt() ?? 0,
      optionGroups: optionGroups,
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

/// Liste des restaurants d'une ville (depuis Convex uniquement)
final restaurantListProvider =
    FutureProvider.family<List<Restaurant>, String>((ref, city) async {
  final client = ref.read(convexClientProvider);
  final list = await client.getRestaurants(city: city);
  return list
      .map((d) => _restaurantFromConvex(Map<String, dynamic>.from(d as Map)))
      .toList();
});

/// Détail d'un restaurant par ID (Convex uniquement)
final restaurantDetailProvider =
    FutureProvider.family<Restaurant, String>((ref, id) async {
  final client = ref.read(convexClientProvider);
  final data = await client.getRestaurant(id);
  return _restaurantFromConvex(data);
});

/// Menu d'un restaurant (Convex uniquement)
final restaurantMenuProvider =
    FutureProvider.family<List<MenuCategory>, String>((ref, restaurantId) async {
  final client = ref.read(convexClientProvider);
  final items = await client.getMenu(restaurantId);
  return _menuFromConvex(items);
});
