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
  return Restaurant(
    id: id,
    name: restaurantName,
    description: d['description'] as String? ?? '',
    cuisine: cuisineList.join(', '),
    imageEmoji: _cuisineEmoji(cuisineList.firstOrNull ?? ''),
    imageUrl: AmaraImages.restaurantImage(restaurantName),
    rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (d['totalRatings'] as num?)?.toInt() ?? 0,
    deliveryTime: '${d['estimatedDeliveryTime'] ?? 30} min',
    deliveryFee: deliveryFeeStr,
    isOpen: d['isOpen'] as bool? ?? false,
    isFeatured: d['isVerified'] as bool? ?? false,
    address: d['address'] as String? ?? '',
    phone: '',
    minOrder: (d['minOrderAmount'] as num?)?.toDouble() ?? 0,
    tags: cuisineList,
    likePercent: 0,
    totalCustomers: 0,
    hasOrdered: false,
    paymentMethods: const ['Mobile Money', 'Cash'],
    serviceModes: const [ServiceMode.delivery, ServiceMode.takeaway],
    schedule: schedule,
    promos: const [],
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
    final item = MenuItem(
      id: d['_id'] as String? ?? '',
      name: itemName,
      description: d['description'] as String? ?? '',
      price: (d['price'] as num?)?.toDouble() ?? 0,
      imageEmoji: _tagEmoji(itemTags.firstOrNull ?? ''),
      imageUrl: AmaraImages.menuItemImage(itemName, itemTags),
      categoryId: cat,
      isPopular: false,
      likeCount: 0,
      optionGroups: const [],
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

// ─── Mock data (fallback si Convex vide) ─────────────────────────────────────

Restaurant _mockRestaurant(String id) {
  final scheduleDefault = [
    const DaySchedule(day: 'Lundi', open: '10:00', close: '22:00'),
    const DaySchedule(day: 'Mardi', open: '10:00', close: '22:00'),
    const DaySchedule(day: 'Mercredi', open: '10:00', close: '22:00'),
    const DaySchedule(day: 'Jeudi', open: '10:00', close: '22:30'),
    const DaySchedule(day: 'Vendredi', open: '10:00', close: '23:00'),
    const DaySchedule(day: 'Samedi', open: '09:00', close: '23:00'),
    const DaySchedule(day: 'Dimanche', open: '11:00', close: '21:00'),
  ];

  final data = {
    '1': Restaurant(
      id: '1', name: 'Chez Mama Africa',
      description: 'La cuisine ivoirienne authentique, des recettes transmises de génération en génération.',
      cuisine: 'Cuisine Ivoirienne', imageEmoji: '🍲',
      imageUrl: AmaraImages.chezMamaAfrica,
      rating: 4.8, reviewCount: 312, deliveryTime: '25-35 min', deliveryFee: 'Gratuit',
      isOpen: true, isFeatured: true, address: 'Cocody, Abidjan', phone: '+225 07 00 00 00',
      minOrder: 2000, tags: ['Africain', 'Ivoirien'], likePercent: 97, totalCustomers: 1842,
      hasOrdered: true, paymentMethods: ['Mobile Money', 'Cash'],
      serviceModes: [ServiceMode.delivery, ServiceMode.takeaway],
      schedule: scheduleDefault,
      promos: const [
        RestaurantPromo(id: 'p1', title: 'Livraison offerte', description: 'Sur votre 1ère commande', emoji: '🛵', code: 'MAMA1'),
        RestaurantPromo(id: 'p2', title: '-15% le midi', description: 'Lun-Ven de 11h à 14h', emoji: '☀️', code: 'MIDI15'),
      ],
    ),
    '2': Restaurant(
      id: '2', name: 'Saveurs du Sahel',
      description: 'Voyage culinaire au cœur de l\'Afrique de l\'Ouest. Thiéboudienne, Yassa, Maafé.',
      cuisine: 'Cuisine Sénégalaise', imageEmoji: '🥘',
      imageUrl: AmaraImages.saveursDuSahel,
      rating: 4.6, reviewCount: 187, deliveryTime: '30-45 min', deliveryFee: '500 F',
      isOpen: true, address: 'Plateau, Abidjan', phone: '+225 05 00 00 00',
      minOrder: 3000, tags: ['Sénégalais', 'Poisson', 'Riz'], likePercent: 94, totalCustomers: 972,
      paymentMethods: ['Mobile Money', 'Cash'],
      serviceModes: [ServiceMode.delivery, ServiceMode.takeaway, ServiceMode.dineIn],
      schedule: scheduleDefault,
      promos: const [
        RestaurantPromo(id: 'p3', title: '-20% ce week-end', description: 'Sur tous les plats', emoji: '🎉', code: 'WE20'),
      ],
    ),
    '3': Restaurant(
      id: '3', name: 'Terroir Camerounais',
      description: 'Ndolé, Poulet DG, Eru — la richesse de la cuisine camerounaise.',
      cuisine: 'Cuisine Camerounaise', imageEmoji: '🍛',
      imageUrl: AmaraImages.terroirCamerounais,
      rating: 4.7, reviewCount: 256, deliveryTime: '20-30 min', deliveryFee: 'Gratuit',
      isOpen: false, address: 'Marcory, Abidjan', phone: '+225 01 00 00 00',
      minOrder: 2500, tags: ['Camerounais', 'Ndolé'], likePercent: 96, totalCustomers: 1203,
      hasOrdered: true, paymentMethods: ['Mobile Money', 'Cash', 'Wave'],
      serviceModes: [ServiceMode.delivery, ServiceMode.takeaway],
      schedule: scheduleDefault, promos: const [],
    ),
    '4': Restaurant(
      id: '4', name: 'Lagos Kitchen',
      description: 'Jollof Rice, Egusi Soup, Suya — la street food nigériane à son meilleur.',
      cuisine: 'Cuisine Nigériane', imageEmoji: '🫕',
      imageUrl: AmaraImages.lagosKitchen,
      rating: 4.5, reviewCount: 42, deliveryTime: '35-50 min', deliveryFee: '750 F',
      isOpen: true, address: 'Yopougon, Abidjan', phone: '+225 09 00 00 00',
      minOrder: 2000, tags: ['Nigérian', 'Épicé'], likePercent: 91, totalCustomers: 287,
      paymentMethods: ['Mobile Money', 'Cash'],
      serviceModes: [ServiceMode.delivery],
      schedule: scheduleDefault,
      promos: const [
        RestaurantPromo(id: 'p4', title: 'Bienvenue !', description: '-10% sur votre 1ère commande', emoji: '🎁', code: 'LAGOS10'),
      ],
    ),
    '5': Restaurant(
      id: '5', name: 'Marrakech Délices',
      description: 'Couscous, tagine, pastilla — la cuisine marocaine dans toute sa splendeur.',
      cuisine: 'Cuisine Marocaine', imageEmoji: '🍢',
      imageUrl: AmaraImages.marrakechDelices,
      rating: 4.4, reviewCount: 28, deliveryTime: '25-40 min', deliveryFee: 'Gratuit',
      isOpen: true, address: 'Riviera, Abidjan', phone: '+225 08 00 00 00',
      minOrder: 3500, tags: ['Marocain', 'Couscous'], likePercent: 89, totalCustomers: 163,
      paymentMethods: ['Cash', 'Carte bancaire'],
      serviceModes: [ServiceMode.delivery, ServiceMode.takeaway, ServiceMode.dineIn],
      schedule: scheduleDefault, promos: const [],
    ),
    '6': Restaurant(
      id: '6', name: 'Addis Flavors',
      description: 'L\'injera et les wots éthiopiens, un voyage sensoriel unique.',
      cuisine: 'Cuisine Éthiopienne', imageEmoji: '🧆',
      imageUrl: AmaraImages.addisEthiopian,
      rating: 4.6, reviewCount: 63, deliveryTime: '30-45 min', deliveryFee: '500 F',
      isOpen: true, address: 'Deux Plateaux, Abidjan', phone: '+225 06 00 00 00',
      minOrder: 2000, tags: ['Éthiopien', 'Végétarien'], likePercent: 93, totalCustomers: 418,
      paymentMethods: ['Mobile Money', 'Wave', 'Cash'],
      serviceModes: [ServiceMode.delivery, ServiceMode.takeaway],
      schedule: scheduleDefault, promos: const [],
    ),
  };

  return data[id] ?? Restaurant(
    id: '0', name: 'Restaurant', description: '', cuisine: '',
    imageEmoji: '🍽️', rating: 0, reviewCount: 0,
    deliveryTime: '–', deliveryFee: '–', isOpen: false, address: '', phone: '',
    minOrder: 0,
  );
}

List<MenuCategory> _mockMenu(String restaurantId) {
  return [
    MenuCategory(
      id: 'cat1', name: 'Plats populaires',
      items: [
        MenuItem(
          id: 'i1', name: 'Attiéké Poisson',
          description: 'Semoule de manioc avec poisson braisé, tomate et oignon frits.',
          price: 2500, imageEmoji: '🐟', imageUrl: AmaraImages.attieke, categoryId: 'cat1',
          isPopular: true, likeCount: 248,
          optionGroups: [
            MenuItemOptionGroup(
              id: 'og1', title: 'Choix du poisson', required: true, maxSelections: 1,
              options: [
                const MenuItemOption(id: 'o1', name: 'Tilapia'),
                const MenuItemOption(id: 'o2', name: 'Carpe'),
                const MenuItemOption(id: 'o3', name: 'Poisson fumé', extraPrice: 500),
              ],
            ),
          ],
        ),
        MenuItem(
          id: 'i2', name: 'Kedjenou de Poulet',
          description: 'Ragoût de poulet mijoté aux épices locales, servi avec attiéké.',
          price: 3500, imageEmoji: '🍗', imageUrl: AmaraImages.pouletBraise, categoryId: 'cat1',
          isPopular: true, isSpicy: true, likeCount: 201,
        ),
        MenuItem(
          id: 'i3', name: 'Foutou Banane + Sauce Graine',
          description: 'Foutou de banane plantain accompagné de la sauce aux graines de palme.',
          price: 2000, imageEmoji: '🍌', imageUrl: AmaraImages.foutou, categoryId: 'cat1', likeCount: 133,
        ),
      ],
    ),
    MenuCategory(
      id: 'cat2', name: 'Grillades',
      items: [
        MenuItem(
          id: 'i4', name: 'Poulet Braisé',
          description: 'Demi-poulet mariné et braisé au feu de bois, servi avec alloco.',
          price: 4000, imageEmoji: '🍗', imageUrl: AmaraImages.pouletBraise, categoryId: 'cat2', likeCount: 189,
        ),
        MenuItem(
          id: 'i5', name: 'Brochettes de Bœuf',
          description: '6 brochettes de bœuf marinées, avec pain et sauce pimentée.',
          price: 2500, imageEmoji: '🍢', imageUrl: AmaraImages.brochettes, categoryId: 'cat2', isSpicy: true, likeCount: 112,
        ),
      ],
    ),
    MenuCategory(
      id: 'cat3', name: 'Boissons',
      items: [
        MenuItem(
          id: 'i9', name: 'Jus de Bissap',
          description: 'Boisson fraîche à base de fleurs d\'hibiscus.',
          price: 800, imageEmoji: '🧃', imageUrl: AmaraImages.jus, categoryId: 'cat3',
          isVegetarian: true, likeCount: 145, isPopular: true,
        ),
        MenuItem(
          id: 'i11', name: 'Eau minérale',
          description: 'Bouteille 50cl.', price: 300, imageEmoji: '💧',
          imageUrl: AmaraImages.jus, categoryId: 'cat3', isVegetarian: true, likeCount: 210,
        ),
      ],
    ),
  ];
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Liste des restaurants d'une ville (depuis Convex, fallback mock)
final restaurantListProvider =
    FutureProvider.family<List<Restaurant>, String>((ref, city) async {
  try {
    final client = ref.read(convexClientProvider);
    final list = await client.getRestaurants(city: city);
    if (list.isEmpty) {
      // Convex vide → retourner les mocks pour la démo
      return ['1', '2', '3', '4', '5', '6']
          .map((id) => _mockRestaurant(id))
          .toList();
    }
    return list
        .map((d) => _restaurantFromConvex(Map<String, dynamic>.from(d as Map)))
        .toList();
  } catch (_) {
    // Pas de réseau → mock
    return ['1', '2', '3', '4', '5', '6']
        .map((id) => _mockRestaurant(id))
        .toList();
  }
});

/// Détail d'un restaurant par ID
final restaurantDetailProvider =
    FutureProvider.family<Restaurant, String>((ref, id) async {
  // Les IDs Convex sont longs (ex: k57abc...). Les IDs courts (1-6) → mock.
  if (RegExp(r'^\d+$').hasMatch(id)) {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockRestaurant(id);
  }
  try {
    final client = ref.read(convexClientProvider);
    final data = await client.getRestaurant(id);
    return _restaurantFromConvex(data);
  } catch (_) {
    return _mockRestaurant(id);
  }
});

/// Menu d'un restaurant
final restaurantMenuProvider =
    FutureProvider.family<List<MenuCategory>, String>((ref, restaurantId) async {
  if (RegExp(r'^\d+$').hasMatch(restaurantId)) {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMenu(restaurantId);
  }
  try {
    final client = ref.read(convexClientProvider);
    final items = await client.getMenu(restaurantId);
    if (items.isEmpty) return _mockMenu(restaurantId);
    return _menuFromConvex(items);
  } catch (_) {
    return _mockMenu(restaurantId);
  }
});
