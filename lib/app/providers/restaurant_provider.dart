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
    phone: (d['phone'] as String?)?.isNotEmpty == true
        ? d['phone'] as String
        : '+225 0${(id.hashCode.abs() % 9) + 1} ${10 + (id.hashCode.abs() % 89)} ${10 + (id.hashCode.abs() % 89)} ${10 + (id.hashCode.abs() % 89)}',
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

    final item = MenuItem(
      id: d['_id'] as String? ?? '',
      name: itemName,
      description: d['description'] as String? ?? '',
      price: (d['price'] as num?)?.toDouble() ?? 0,
      imageEmoji: _tagEmoji(itemTags.firstOrNull ?? ''),
      imageUrl: AmaraImages.menuItemImage(itemName, itemTags),
      categoryId: cat,
      isPopular: (d['isPopular'] as bool?) ?? false,
      likeCount: (d['likeCount'] as num?)?.toInt() ?? (50 + itemName.hashCode.abs() % 450),
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
  switch (restaurantId) {
    case '3': // Terroir Camerounais
      return [
        MenuCategory(
          id: 'cat1', name: 'Spécialités',
          items: [
            MenuItem(
              id: 'c1', name: 'Ndolé aux Crevettes',
              description: 'Feuilles de ndolé aux crevettes fumées et arachides. Servi avec plantain.',
              price: 4000, imageEmoji: '🥬', imageUrl: AmaraImages.ragout, categoryId: 'cat1',
              isPopular: true, likeCount: 312,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Accompagnement', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Plantain mûr'),
                    const MenuItemOption(id: 'o2', name: 'Miondo / bâton de manioc'),
                    const MenuItemOption(id: 'o3', name: 'Riz blanc', extraPrice: 300),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'c2', name: 'Poulet DG',
              description: 'Poulet Directeur Général : sauté aux plantains et légumes frais, sauce tomate.',
              price: 4500, imageEmoji: '🍗', imageUrl: AmaraImages.pouletBraise, categoryId: 'cat1',
              isPopular: true, isSpicy: true, likeCount: 287,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Taille de la portion', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Normal'),
                    const MenuItemOption(id: 'o2', name: 'Large', extraPrice: 800),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Suppléments', required: false, maxSelections: 3,
                  options: [
                    const MenuItemOption(id: 'o3', name: 'Plantain mûr extra', extraPrice: 300),
                    const MenuItemOption(id: 'o4', name: 'Avocat', extraPrice: 400),
                    const MenuItemOption(id: 'o5', name: 'Œuf au plat', extraPrice: 200),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'c3', name: 'Eru au Bœuf',
              description: 'Légumes eru mijotés avec bœuf fumé et huile de palme. Servi avec waterfufu.',
              price: 3500, imageEmoji: '🥩', imageUrl: AmaraImages.brochettes, categoryId: 'cat1',
              likeCount: 198,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Accompagnement', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Waterfufu'),
                    const MenuItemOption(id: 'o2', name: 'Garri'),
                    const MenuItemOption(id: 'o3', name: 'Riz blanc', extraPrice: 300),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'c4', name: 'Thiéboudienne',
              description: 'Riz au poisson sénégalais cuisiné à la camerounaise, légumes fondants.',
              price: 3000, imageEmoji: '🍚', imageUrl: AmaraImages.thiebs, categoryId: 'cat1',
              likeCount: 154, isVegetarian: false,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat2', name: 'Entrées',
          items: [
            MenuItem(
              id: 'c5', name: 'Puff Puff',
              description: 'Beignets moelleux à la camerounaise, dorés et sucrés.',
              price: 800, imageEmoji: '🍩', imageUrl: AmaraImages.streetFood, categoryId: 'cat2',
              likeCount: 223, isVegetarian: true, isPopular: true,
            ),
            MenuItem(
              id: 'c6', name: 'Koki',
              description: 'Gâteau de haricot vapeur assaisonné à l\'huile de palme.',
              price: 1000, imageEmoji: '🫘', imageUrl: AmaraImages.foutou, categoryId: 'cat2',
              likeCount: 89, isVegetarian: true,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat3', name: 'Accompagnements',
          items: [
            MenuItem(
              id: 'c7', name: 'Plantain Alloco',
              description: 'Tranches de plantain mûr frites, légèrement caramélisées.',
              price: 500, imageEmoji: '🍌', imageUrl: AmaraImages.foutou, categoryId: 'cat3',
              likeCount: 176, isVegetarian: true,
            ),
            MenuItem(
              id: 'c8', name: 'Riz Blanc',
              description: 'Riz parfumé cuit à la vapeur.',
              price: 400, imageEmoji: '🍚', imageUrl: AmaraImages.jollofRice, categoryId: 'cat3',
              likeCount: 92, isVegetarian: true,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat4', name: 'Boissons',
          items: [
            MenuItem(
              id: 'c9', name: 'Jus de Gingembre',
              description: 'Boisson fraîche au gingembre, citron et miel.',
              price: 700, imageEmoji: '🧃', imageUrl: AmaraImages.jus, categoryId: 'cat4',
              likeCount: 134, isVegetarian: true,
            ),
            MenuItem(
              id: 'c10', name: 'Eau minérale',
              description: 'Bouteille 50cl.', price: 300, imageEmoji: '💧',
              imageUrl: AmaraImages.jus, categoryId: 'cat4', isVegetarian: true, likeCount: 67,
            ),
          ],
        ),
      ];

    case '2': // Saveurs du Sahel
      return [
        MenuCategory(
          id: 'cat1', name: 'Spécialités',
          items: [
            MenuItem(
              id: 's1', name: 'Thiéboudienne',
              description: 'Le plat national sénégalais : riz au poisson, légumes et sauce tomate mijotée.',
              price: 4000, imageEmoji: '🐟', imageUrl: AmaraImages.thiebs, categoryId: 'cat1',
              isPopular: true, likeCount: 423,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Choix du poisson', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Thiof (mérou)'),
                    const MenuItemOption(id: 'o2', name: 'Capitaine', extraPrice: 300),
                    const MenuItemOption(id: 'o3', name: 'Crevettes', extraPrice: 500),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 's2', name: 'Yassa Poulet',
              description: 'Poulet mariné au citron et oignons caramélisés. Un classique sénégalais.',
              price: 3500, imageEmoji: '🍗', imageUrl: AmaraImages.pouletBraise, categoryId: 'cat1',
              isPopular: true, likeCount: 356,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Accompagnement', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Riz blanc'),
                    const MenuItemOption(id: 'o2', name: 'Fonio', extraPrice: 200),
                    const MenuItemOption(id: 'o3', name: 'Attiéké', extraPrice: 300),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Niveau de piment', required: false, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Sans piment'),
                    const MenuItemOption(id: 'o5', name: 'Piment doux'),
                    const MenuItemOption(id: 'o6', name: 'Piment fort'),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 's3', name: 'Maafé',
              description: 'Ragoût de viande à la sauce d\'arachide, servi avec riz blanc.',
              price: 3000, imageEmoji: '🥜', imageUrl: AmaraImages.ragout, categoryId: 'cat1',
              likeCount: 198, isSpicy: true,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Choix de la viande', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Bœuf'),
                    const MenuItemOption(id: 'o2', name: 'Agneau', extraPrice: 500),
                    const MenuItemOption(id: 'o3', name: 'Poulet'),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Suppléments', required: false, maxSelections: 2,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Banane plantain', extraPrice: 300),
                    const MenuItemOption(id: 'o5', name: 'Œuf dur', extraPrice: 200),
                    const MenuItemOption(id: 'o6', name: 'Portion de riz extra', extraPrice: 300),
                  ],
                ),
              ],
            ),
          ],
        ),
        MenuCategory(
          id: 'cat2', name: 'Grillades',
          items: [
            MenuItem(
              id: 's4', name: 'Brochettes Sénégalaises',
              description: '8 brochettes de bœuf marinées aux épices, avec oignons et piment.',
              price: 2500, imageEmoji: '🍢', imageUrl: AmaraImages.brochettes, categoryId: 'cat2',
              likeCount: 145, isSpicy: true,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat3', name: 'Boissons',
          items: [
            MenuItem(
              id: 's5', name: 'Jus de Bissap',
              description: 'Boisson fraîche à base de fleurs d\'hibiscus et menthe.',
              price: 700, imageEmoji: '🧃', imageUrl: AmaraImages.jus, categoryId: 'cat3',
              likeCount: 267, isVegetarian: true, isPopular: true,
            ),
            MenuItem(
              id: 's6', name: 'Thiakry',
              description: 'Dessert sénégalais au mil fermenté, sucré et crémeux.',
              price: 900, imageEmoji: '🍮', imageUrl: AmaraImages.dessert, categoryId: 'cat3',
              likeCount: 112, isVegetarian: true,
            ),
          ],
        ),
      ];

    case '4': // Lagos Kitchen
      return [
        MenuCategory(
          id: 'cat1', name: 'Plats Principaux',
          items: [
            MenuItem(
              id: 'l1', name: 'Jollof Rice',
              description: 'Le célèbre riz ouest-africain cuisiné à la tomate, poivron et épices.',
              price: 3000, imageEmoji: '🍚', imageUrl: AmaraImages.jollofRice, categoryId: 'cat1',
              isPopular: true, likeCount: 512,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Protéine', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Poulet grillé', extraPrice: 500),
                    const MenuItemOption(id: 'o2', name: 'Bœuf haché', extraPrice: 700),
                    const MenuItemOption(id: 'o3', name: 'Crevettes', extraPrice: 900),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'l2', name: 'Egusi Soup',
              description: 'Soupe épaisse aux graines de melon, épinards, viande et poisson fumé.',
              price: 3500, imageEmoji: '🥘', imageUrl: AmaraImages.ragout, categoryId: 'cat1',
              likeCount: 287, isSpicy: true,
            ),
            MenuItem(
              id: 'l3', name: 'Suya Beef',
              description: 'Brochettes de bœuf épicées au suya mix, servies avec oignons frais et tomate.',
              price: 4000, imageEmoji: '🍢', imageUrl: AmaraImages.brochettes, categoryId: 'cat1',
              isPopular: true, isSpicy: true, likeCount: 398,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat2', name: 'Street Food',
          items: [
            MenuItem(
              id: 'l4', name: 'Puff Puff',
              description: 'Beignets moelleux nigérians, légèrement sucrés et croustillants.',
              price: 600, imageEmoji: '🍩', imageUrl: AmaraImages.streetFood, categoryId: 'cat2',
              likeCount: 178, isVegetarian: true,
            ),
            MenuItem(
              id: 'l5', name: 'Chin Chin',
              description: 'Snack croquant à base de farine, œuf et sucre, frit à l\'huile.',
              price: 500, imageEmoji: '🍪', imageUrl: AmaraImages.streetFood, categoryId: 'cat2',
              likeCount: 134, isVegetarian: true,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat3', name: 'Boissons',
          items: [
            MenuItem(
              id: 'l6', name: 'Chapman',
              description: 'Cocktail sans alcool nigérian : Fanta, Angostura, citron et grenadine.',
              price: 800, imageEmoji: '🥤', imageUrl: AmaraImages.jus, categoryId: 'cat3',
              likeCount: 203, isVegetarian: true, isPopular: true,
            ),
          ],
        ),
      ];

    case '5': // Marrakech Délices — cuisine marocaine
      return [
        MenuCategory(
          id: 'cat1', name: 'Tajines',
          items: [
            MenuItem(
              id: 'm1', name: 'Tagine Poulet Citron',
              description: 'Poulet confit aux citrons confits, olives et coriandre fraîche.',
              price: 4500, imageEmoji: '🍲', imageUrl: AmaraImages.ragout, categoryId: 'cat1',
              isPopular: true, likeCount: 389,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Accompagnement', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Pain marocain'),
                    const MenuItemOption(id: 'o2', name: 'Semoule', extraPrice: 300),
                    const MenuItemOption(id: 'o3', name: 'Riz safrané', extraPrice: 400),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Extras', required: false, maxSelections: 2,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Olives confites', extraPrice: 200),
                    const MenuItemOption(id: 'o5', name: 'Harissa maison', extraPrice: 150),
                    const MenuItemOption(id: 'o6', name: 'Amandes grillées', extraPrice: 250),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'm2', name: 'Tagine Agneau Pruneaux',
              description: 'Agneau mijoté aux pruneaux, amandes grillées et miel.',
              price: 5500, imageEmoji: '🥩', imageUrl: AmaraImages.brochettes, categoryId: 'cat1',
              likeCount: 312,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Accompagnement', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Pain marocain'),
                    const MenuItemOption(id: 'o2', name: 'Semoule', extraPrice: 300),
                    const MenuItemOption(id: 'o3', name: 'Riz safrané', extraPrice: 400),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Taille', required: false, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Portion normale'),
                    const MenuItemOption(id: 'o5', name: 'Grande portion', extraPrice: 1000),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'm3', name: 'Tagine Légumes',
              description: 'Légumes de saison mijotés aux épices ras el hanout.',
              price: 3000, imageEmoji: '🥕', imageUrl: AmaraImages.ragout, categoryId: 'cat1',
              isVegetarian: true, likeCount: 198,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat2', name: 'Couscous',
          items: [
            MenuItem(
              id: 'm4', name: 'Couscous Royal',
              description: 'Semoule fine avec merguez, poulet, agneau et légumes fondants.',
              price: 5000, imageEmoji: '🍚', imageUrl: AmaraImages.couscous, categoryId: 'cat2',
              isPopular: true, likeCount: 445,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Suppléments viande', required: false, maxSelections: 3,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Merguez x2', extraPrice: 400),
                    const MenuItemOption(id: 'o2', name: 'Cuisse de poulet extra', extraPrice: 500),
                    const MenuItemOption(id: 'o3', name: 'Brochette d\'agneau', extraPrice: 700),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Sauces', required: false, maxSelections: 2,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Harissa'),
                    const MenuItemOption(id: 'o5', name: 'Sauce piquante', extraPrice: 100),
                    const MenuItemOption(id: 'o6', name: 'Bouillon extra'),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'm5', name: 'Couscous Végétarien',
              description: 'Semoule aux 7 légumes traditionnels et bouillon parfumé.',
              price: 3500, imageEmoji: '🥗', imageUrl: AmaraImages.couscous, categoryId: 'cat2',
              isVegetarian: true, likeCount: 167,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat3', name: 'Entrées',
          items: [
            MenuItem(
              id: 'm6', name: 'Pastilla au Poulet',
              description: 'Feuilleté croustillant poulet-amandes-cannelle, spécialité fassi.',
              price: 2500, imageEmoji: '🥟', imageUrl: AmaraImages.streetFood, categoryId: 'cat3',
              isPopular: true, likeCount: 278,
            ),
            MenuItem(
              id: 'm7', name: 'Harira',
              description: 'Soupe traditionnelle marocaine aux tomates, lentilles et pois chiches.',
              price: 1200, imageEmoji: '🍲', imageUrl: AmaraImages.ragout, categoryId: 'cat3',
              likeCount: 203,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat4', name: 'Boissons',
          items: [
            MenuItem(
              id: 'm8', name: 'Thé à la Menthe',
              description: 'Thé vert à la menthe fraîche, servi à la marocaine.',
              price: 600, imageEmoji: '🍵', imageUrl: AmaraImages.jus, categoryId: 'cat4',
              isVegetarian: true, likeCount: 334, isPopular: true,
            ),
            MenuItem(
              id: 'm9', name: 'Jus d\'Orange Frais',
              description: 'Oranges pressées à la minute.',
              price: 800, imageEmoji: '🍊', imageUrl: AmaraImages.jus, categoryId: 'cat4',
              isVegetarian: true, likeCount: 156,
            ),
          ],
        ),
      ];

    case '6': // Addis Flavors — cuisine éthiopienne
      return [
        MenuCategory(
          id: 'cat1', name: 'Spécialités',
          items: [
            MenuItem(
              id: 'a1', name: 'Doro Wat',
              description: 'Ragoût de poulet épicé au berbéré, avec œufs durs. Plat national éthiopien.',
              price: 4000, imageEmoji: '🍗', imageUrl: AmaraImages.injera, categoryId: 'cat1',
              isPopular: true, isSpicy: true, likeCount: 467,
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Nombre d\'injera', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: '2 injera (standard)'),
                    const MenuItemOption(id: 'o2', name: '4 injera', extraPrice: 300),
                    const MenuItemOption(id: 'o3', name: '6 injera', extraPrice: 500),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Accompagnements', required: false, maxSelections: 2,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Salade verte', extraPrice: 200),
                    const MenuItemOption(id: 'o5', name: 'Ayib (fromage frais)', extraPrice: 300),
                    const MenuItemOption(id: 'o6', name: 'Gomen (épinards)', extraPrice: 250),
                  ],
                ),
              ],
            ),
            MenuItem(
              id: 'a2', name: 'Tibs de Bœuf',
              description: 'Bœuf sauté au beurre clarifié avec oignons, tomates et piment.',
              price: 4500, imageEmoji: '🥩', imageUrl: AmaraImages.brochettes, categoryId: 'cat1',
              isSpicy: true, likeCount: 312,
            ),
            MenuItem(
              id: 'a3', name: 'Kitfo',
              description: 'Bœuf haché au beurre clarifié et épices mitmita. La tartare éthiopienne.',
              price: 5000, imageEmoji: '🥩', imageUrl: AmaraImages.brochettes, categoryId: 'cat1',
              likeCount: 234,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat2', name: 'Végétarien',
          items: [
            MenuItem(
              id: 'a4', name: 'Beyaynet Végétarien',
              description: 'Plateau injera avec 6 wots végétariens : lentilles, pois chiches, épinards...',
              price: 3500, imageEmoji: '🥗', imageUrl: AmaraImages.ragout, categoryId: 'cat2',
              isVegetarian: true, isPopular: true, likeCount: 289,
            ),
            MenuItem(
              id: 'a5', name: 'Misir Wat',
              description: 'Lentilles rouges mijotées aux épices berbéré et berbéré doux.',
              price: 2500, imageEmoji: '🫘', imageUrl: AmaraImages.ragout, categoryId: 'cat2',
              isVegetarian: true, likeCount: 201,
            ),
          ],
        ),
        MenuCategory(
          id: 'cat3', name: 'Boissons',
          items: [
            MenuItem(
              id: 'a6', name: 'Café Éthiopien Bunna',
              description: 'Cérémonie du café éthiopien : grains torréfiés et moulus sur place.',
              price: 800, imageEmoji: '☕', imageUrl: AmaraImages.jus, categoryId: 'cat3',
              isVegetarian: true, likeCount: 378, isPopular: true,
            ),
            MenuItem(
              id: 'a7', name: 'Tej',
              description: 'Hydromel éthiopien traditionnel, légèrement sucré.',
              price: 1000, imageEmoji: '🍯', imageUrl: AmaraImages.jus, categoryId: 'cat3',
              likeCount: 145,
            ),
          ],
        ),
      ];

    default: // Restaurant 1 (Chez Mama Africa) et autres
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
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Accompagnement', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Attiéké'),
                    const MenuItemOption(id: 'o2', name: 'Riz blanc', extraPrice: 200),
                    const MenuItemOption(id: 'o3', name: 'Foutou banane', extraPrice: 300),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Niveau de piment', required: false, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Doux'),
                    const MenuItemOption(id: 'o5', name: 'Moyen'),
                    const MenuItemOption(id: 'o6', name: 'Très piquant'),
                  ],
                ),
              ],
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
              optionGroups: [
                MenuItemOptionGroup(
                  id: 'og1', title: 'Accompagnement', required: true, maxSelections: 1,
                  options: [
                    const MenuItemOption(id: 'o1', name: 'Alloco (plantain frit)'),
                    const MenuItemOption(id: 'o2', name: 'Attiéké'),
                    const MenuItemOption(id: 'o3', name: 'Frites', extraPrice: 300),
                  ],
                ),
                MenuItemOptionGroup(
                  id: 'og2', title: 'Sauces', required: false, maxSelections: 2,
                  options: [
                    const MenuItemOption(id: 'o4', name: 'Sauce piment'),
                    const MenuItemOption(id: 'o5', name: 'Mayonnaise'),
                    const MenuItemOption(id: 'o6', name: 'Sauce tomate-oignon'),
                  ],
                ),
              ],
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
