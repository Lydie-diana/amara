/// Horaires d'un jour de la semaine.
class DaySchedule {
  final String day;
  final String open;
  final String close;
  final bool isClosed;

  const DaySchedule({
    required this.day,
    required this.open,
    required this.close,
    this.isClosed = false,
  });

  String get display => isClosed ? 'Fermé' : '$open – $close';
}

/// Mode de service.
enum ServiceMode { delivery, takeaway, dineIn }

/// Promo du restaurant.
class RestaurantPromo {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String code;
  final bool isActive;

  const RestaurantPromo({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.code,
    this.isActive = true,
  });
}

/// Modèle restaurant complet (détail).
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String cuisine;
  final String imageEmoji;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryFee;
  final bool isOpen;
  final bool isFeatured;
  final String address;
  final String phone;
  final double minOrder;
  final List<String> tags;

  // Nouveaux champs
  final int likePercent;          // % de clients satisfaits
  final int totalCustomers;       // nb total de clients fidèles
  final bool hasOrdered;          // l'utilisateur a-t-il déjà commandé ?
  final List<String> paymentMethods; // ['Mobile Money', 'Carte', 'Cash']
  final List<ServiceMode> serviceModes; // livraison / emporter / sur place
  final List<DaySchedule> schedule;
  final List<RestaurantPromo> promos;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisine,
    required this.imageEmoji,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.isOpen,
    required this.address,
    required this.phone,
    required this.minOrder,
    this.isFeatured = false,
    this.tags = const [],
    this.likePercent = 95,
    this.totalCustomers = 0,
    this.hasOrdered = false,
    this.paymentMethods = const ['Mobile Money', 'Cash'],
    this.serviceModes = const [ServiceMode.delivery, ServiceMode.takeaway],
    this.schedule = const [],
    this.promos = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      cuisine: json['cuisine'] as String? ?? '',
      imageEmoji: json['imageEmoji'] as String? ?? '🍽️',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      deliveryTime: json['deliveryTime'] as String? ?? '30-45 min',
      deliveryFee: json['deliveryFee'] as String? ?? '500 F',
      isOpen: json['isOpen'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      minOrder: (json['minOrder'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      likePercent: (json['likePercent'] as num?)?.toInt() ?? 95,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      hasOrdered: json['hasOrdered'] as bool? ?? false,
      paymentMethods:
          List<String>.from(json['paymentMethods'] as List? ?? ['Mobile Money', 'Cash']),
    );
  }
}

/// Catégorie de menu.
class MenuCategory {
  final String id;
  final String name;
  final List<MenuItem> items;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.items,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    return MenuCategory(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      items: itemsJson
          .map((i) => MenuItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Option d'accompagnement (ex: type de sauce, de féculent).
class MenuItemOption {
  final String id;
  final String name;
  final double extraPrice; // 0 si inclus

  const MenuItemOption({
    required this.id,
    required this.name,
    this.extraPrice = 0,
  });

  String get priceLabel =>
      extraPrice == 0 ? 'Inclus' : '+${extraPrice.toStringAsFixed(0)} F';
}

/// Groupe d'options pour un plat (ex: "Choix du féculent", "Sauce").
class MenuItemOptionGroup {
  final String id;
  final String title;
  final bool required;
  final int maxSelections; // 1 = choix unique, >1 = multiple
  final List<MenuItemOption> options;

  const MenuItemOptionGroup({
    required this.id,
    required this.title,
    required this.options,
    this.required = false,
    this.maxSelections = 1,
  });
}

/// Plat / article de menu.
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageEmoji;
  final bool isAvailable;
  final bool isPopular;
  final bool isVegetarian;
  final bool isSpicy;
  final String categoryId;
  final int likeCount;    // nb de likes du plat
  final List<MenuItemOptionGroup> optionGroups; // accompagnements/options

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageEmoji,
    required this.categoryId,
    this.isAvailable = true,
    this.isPopular = false,
    this.isVegetarian = false,
    this.isSpicy = false,
    this.likeCount = 0,
    this.optionGroups = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageEmoji: json['imageEmoji'] as String? ?? '🍽️',
      categoryId: json['categoryId'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      isPopular: json['isPopular'] as bool? ?? false,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isSpicy: json['isSpicy'] as bool? ?? false,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
    );
  }

  String get formattedPrice => '${price.toStringAsFixed(0)} F';
}
