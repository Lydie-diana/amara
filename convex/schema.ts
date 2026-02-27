import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // ============ UTILISATEURS ============
  users: defineTable({
    // Identité
    name: v.string(),
    email: v.string(),
    phone: v.string(),
    imageUrl: v.optional(v.string()),

    // Rôle : client, restaurant, livreur, admin, support, finance, ops
    role: v.union(
      v.literal("client"),
      v.literal("restaurant"),
      v.literal("livreur"),
      v.literal("admin"),
      v.literal("support"),
      v.literal("finance"),
      v.literal("ops")
    ),

    // Authentification
    externalId: v.optional(v.string()),
    passwordHash: v.optional(v.string()),

    // Statut du compte
    isActive: v.boolean(),
    createdAt: v.number(),

    // Adresse par défaut
    defaultAddress: v.optional(v.string()),
    defaultLatitude: v.optional(v.number()),
    defaultLongitude: v.optional(v.number()),
    defaultZoneId: v.optional(v.id("zones")),

    // Préférences et état
    preferredLanguage: v.optional(v.string()),
    lastLoginAt: v.optional(v.number()),
    onboardingCompleted: v.optional(v.boolean()),

    // Suspension
    suspendedAt: v.optional(v.number()),
    suspendedReason: v.optional(v.string()),
  })
    .index("by_email", ["email"])
    .index("by_phone", ["phone"])
    .index("by_externalId", ["externalId"])
    .index("by_role", ["role"]),

  // ============ SESSIONS D'AUTHENTIFICATION ============
  auth_sessions: defineTable({
    userId: v.id("users"),
    token: v.string(),
    expiresAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_token", ["token"])
    .index("by_userId", ["userId"]),

  // ============ RESTAURANTS ============
  restaurants: defineTable({
    ownerId: v.id("users"),
    name: v.string(),
    description: v.string(),
    phone: v.optional(v.string()),
    imageUrl: v.optional(v.string()),
    coverImageUrl: v.optional(v.string()),

    // Localisation
    address: v.string(),
    city: v.string(),
    country: v.string(),
    latitude: v.number(),
    longitude: v.number(),

    // Catégorie cuisine
    cuisineType: v.array(v.string()),

    // Horaires d'ouverture
    openingHours: v.object({
      monday: v.optional(v.object({ open: v.string(), close: v.string() })),
      tuesday: v.optional(v.object({ open: v.string(), close: v.string() })),
      wednesday: v.optional(v.object({ open: v.string(), close: v.string() })),
      thursday: v.optional(v.object({ open: v.string(), close: v.string() })),
      friday: v.optional(v.object({ open: v.string(), close: v.string() })),
      saturday: v.optional(v.object({ open: v.string(), close: v.string() })),
      sunday: v.optional(v.object({ open: v.string(), close: v.string() })),
    }),

    // Infos business
    rating: v.optional(v.number()),
    totalRatings: v.number(),
    isOpen: v.boolean(),
    isVerified: v.boolean(),
    deliveryFee: v.number(),
    minOrderAmount: v.number(),
    estimatedDeliveryTime: v.number(), // en minutes

    createdAt: v.number(),
  })
    .index("by_owner", ["ownerId"])
    .index("by_city", ["city"])
    .index("by_country", ["country"]),

  // ============ MENU / PLATS ============
  menuItems: defineTable({
    restaurantId: v.id("restaurants"),
    name: v.string(),
    description: v.string(),
    price: v.number(),
    imageUrl: v.optional(v.string()),
    category: v.string(), // Entrées, Plats, Desserts, Boissons
    isAvailable: v.boolean(),
    preparationTime: v.optional(v.number()), // en minutes
    tags: v.optional(v.array(v.string())), // épicé, végétarien, etc.
    // Options / compléments / accompagnements (style Uber Eats)
    optionGroups: v.optional(v.array(v.object({
      id: v.string(),
      title: v.string(),
      required: v.boolean(),
      maxSelections: v.number(), // 1 = choix unique, >1 = multi-choix
      options: v.array(v.object({
        id: v.string(),
        name: v.string(),
        extraPrice: v.number(), // 0 si inclus
      })),
    }))),
    // Stats par plat (mis à jour via orders + reviews)
    orderCount: v.optional(v.number()),     // nb de clients ayant commandé ce plat
    rating: v.optional(v.number()),          // note moyenne (1.0-5.0)
    totalRatings: v.optional(v.number()),    // nb d'avis incluant ce plat
    createdAt: v.number(),
  })
    .index("by_restaurant", ["restaurantId"])
    .index("by_category", ["restaurantId", "category"]),

  // ============ COMMANDES ============
  orders: defineTable({
    // Références
    clientId: v.id("users"),
    restaurantId: v.id("restaurants"),
    livreurId: v.optional(v.id("users")),

    // Contenu
    items: v.array(
      v.object({
        menuItemId: v.id("menuItems"),
        name: v.string(),
        quantity: v.number(),
        unitPrice: v.number(),
        imageUrl: v.optional(v.string()),
      })
    ),

    // Montants
    subtotal: v.number(),
    deliveryFee: v.number(),
    serviceFee: v.number(),
    total: v.number(),

    // Adresse de livraison
    deliveryAddress: v.string(),
    deliveryLatitude: v.number(),
    deliveryLongitude: v.number(),

    // Statut
    status: v.union(
      v.literal("pending"),        // En attente de confirmation restaurant
      v.literal("confirmed"),      // Confirmée par le restaurant
      v.literal("preparing"),      // En préparation
      v.literal("ready"),          // Prête pour le livreur
      v.literal("picked_up"),      // Récupérée par le livreur
      v.literal("delivering"),     // En cours de livraison
      v.literal("delivered"),      // Livrée
      v.literal("cancelled")       // Annulée
    ),

    // Paiement
    paymentMethod: v.union(
      v.literal("mobile_money"),
      v.literal("card"),
      v.literal("cash")
    ),
    paymentStatus: v.union(
      v.literal("pending"),
      v.literal("paid"),
      v.literal("failed"),
      v.literal("refunded")
    ),

    // Notes
    clientNote: v.optional(v.string()),

    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_client", ["clientId"])
    .index("by_restaurant", ["restaurantId"])
    .index("by_livreur", ["livreurId"])
    .index("by_status", ["status"]),

  // ============ FAVORIS ============
  favorites: defineTable({
    userId: v.id("users"),
    restaurantId: v.id("restaurants"),
    createdAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_user_restaurant", ["userId", "restaurantId"]),

  // ============ AVIS ============
  reviews: defineTable({
    orderId: v.id("orders"),
    clientId: v.id("users"),
    restaurantId: v.id("restaurants"),
    livreurId: v.optional(v.id("users")),
    rating: v.number(), // 1-5 (note restaurant)
    driverRating: v.optional(v.number()), // 1-5 (note livreur)
    comment: v.optional(v.string()),
    createdAt: v.number(),
  })
    .index("by_order", ["orderId"])
    .index("by_restaurant", ["restaurantId"])
    .index("by_driver", ["livreurId"])
    .index("by_client", ["clientId"]),

  // ============ LOCALISATION LIVREURS ============
  livreurLocations: defineTable({
    livreurId: v.id("users"),
    latitude: v.number(),
    longitude: v.number(),
    isAvailable: v.boolean(),
    updatedAt: v.number(),
  }).index("by_livreur", ["livreurId"]),

  // ============ PAIEMENTS ============
  payments: defineTable({
    orderId: v.id("orders"),
    amount: v.number(),
    method: v.union(
      v.literal("orange_money"),
      v.literal("mtn_money"),
      v.literal("wave"),
      v.literal("card"),
      v.literal("cash")
    ),
    status: v.union(
      v.literal("pending"),
      v.literal("completed"),
      v.literal("failed"),
      v.literal("refunded")
    ),
    transactionId: v.optional(v.string()),
    createdAt: v.number(),
  })
    .index("by_order", ["orderId"])
    .index("by_status", ["status"]),

  // ============ NOTIFICATIONS ============
  notifications: defineTable({
    userId: v.id("users"),
    title: v.string(),
    message: v.string(),
    type: v.union(
      v.literal("order_update"),
      v.literal("promotion"),
      v.literal("system")
    ),
    isRead: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_user_unread", ["userId", "isRead"]),

  // ============ REGLES METIER ============
  businessRules: defineTable({
    key: v.string(),
    value: v.string(),
    valueType: v.union(
      v.literal("string"),
      v.literal("number"),
      v.literal("boolean"),
      v.literal("json")
    ),
    category: v.union(
      v.literal("commission"),
      v.literal("delivery"),
      v.literal("orders"),
      v.literal("drivers"),
      v.literal("restaurants"),
      v.literal("payments"),
      v.literal("notifications")
    ),
    label: v.string(),
    description: v.string(),
    updatedAt: v.number(),
    updatedBy: v.optional(v.id("users")),
  })
    .index("by_key", ["key"])
    .index("by_category", ["category"]),

  // ============ ZONES ============
  zones: defineTable({
    name: v.string(),
    city: v.string(),
    boundary: v.array(
      v.object({
        latitude: v.number(),
        longitude: v.number(),
      })
    ),
    centerLatitude: v.number(),
    centerLongitude: v.number(),
    deliveryBaseFee: v.number(),
    isActive: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_city", ["city"])
    .index("by_name", ["name"]),

  // ============ TARIFICATION LIVRAISON INTER-ZONES ============
  zoneDeliveryPricing: defineTable({
    fromZoneId: v.id("zones"),
    toZoneId: v.id("zones"),
    deliveryFee: v.number(),
    estimatedMinutes: v.number(),
    isActive: v.boolean(),
  })
    .index("by_fromZone", ["fromZoneId"])
    .index("by_route", ["fromZoneId", "toZoneId"]),

  // ============ HISTORIQUE ETATS COMMANDE ============
  orderStateHistory: defineTable({
    orderId: v.id("orders"),
    fromStatus: v.string(),
    toStatus: v.string(),
    triggeredBy: v.optional(v.id("users")),
    triggeredByRole: v.optional(v.string()),
    reason: v.optional(v.string()),
    createdAt: v.number(),
  }).index("by_order", ["orderId"]),

  // ============ JOURNAUX D'AUDIT ============
  auditLogs: defineTable({
    userId: v.optional(v.id("users")),
    action: v.string(),
    resource: v.string(),
    resourceId: v.optional(v.string()),
    details: v.optional(v.string()),
    ipAddress: v.optional(v.string()),
    createdAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_action", ["action"])
    .index("by_resource", ["resource"])
    .index("by_createdAt", ["createdAt"]),

  // ============ PROFILS LIVREURS ============
  driverProfiles: defineTable({
    userId: v.id("users"),
    vehicleType: v.union(
      v.literal("moto"),
      v.literal("velo"),
      v.literal("voiture")
    ),
    vehiclePlate: v.optional(v.string()),
    licenseNumber: v.optional(v.string()),
    idCardUrl: v.optional(v.string()),
    licenseUrl: v.optional(v.string()),
    vehiclePhotoUrl: v.optional(v.string()),
    isVerified: v.boolean(),
    isOnline: v.boolean(),
    currentZoneId: v.optional(v.id("zones")),
    totalDeliveries: v.number(),
    rating: v.optional(v.number()),
    createdAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_zone", ["currentZoneId"])
    .index("by_online", ["isOnline"]),

  // ============ PROFILS RESTAURANTS ============
  restaurantProfiles: defineTable({
    userId: v.id("users"),
    restaurantId: v.id("restaurants"),
    businessRegistrationNumber: v.optional(v.string()),
    taxId: v.optional(v.string()),
    bankAccountName: v.optional(v.string()),
    bankAccountNumber: v.optional(v.string()),
    mobileMoneyNumber: v.optional(v.string()),
    isOnboardingComplete: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_restaurant", ["restaurantId"]),

  // ============ DEMANDES DE DISPATCH ============
  dispatchRequests: defineTable({
    orderId: v.id("orders"),
    driverId: v.id("users"),
    status: v.union(
      v.literal("pending"),
      v.literal("accepted"),
      v.literal("refused"),
      v.literal("expired")
    ),
    requestedAt: v.number(),
    respondedAt: v.optional(v.number()),
    expiresAt: v.number(),
  })
    .index("by_order", ["orderId"])
    .index("by_driver", ["driverId"])
    .index("by_status", ["status"]),

  // ============ PROMOTIONS (banners home) ============
  promotions: defineTable({
    title: v.string(),
    subtitle: v.string(),
    tag: v.string(),
    emoji: v.string(),
    bgColor: v.string(), // hex color e.g. "#E62050"
    city: v.optional(v.string()), // null = toutes les villes
    isActive: v.boolean(),
    sortOrder: v.number(),
    startsAt: v.optional(v.number()),
    endsAt: v.optional(v.number()),
    createdAt: v.number(),
  })
    .index("by_active", ["isActive"])
    .index("by_city", ["city"]),

  // ============ CATÉGORIES CUISINE (filtres home) ============
  foodCategories: defineTable({
    emoji: v.string(),
    label: v.string(),
    sortOrder: v.number(),
    isActive: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_active", ["isActive"]),

  // ============ SUGGESTIONS D'ADRESSES ============
  addressSuggestions: defineTable({
    address: v.string(),
    city: v.string(),
    country: v.string(),
    latitude: v.number(),
    longitude: v.number(),
    isActive: v.boolean(),
    sortOrder: v.optional(v.number()),
    createdAt: v.number(),
  })
    .index("by_city", ["city"])
    .index("by_country", ["country"])
    .index("by_active", ["isActive"]),

  // ============ LIMITATION DE DEBIT ============
  rateLimits: defineTable({
    key: v.string(),
    count: v.number(),
    windowStart: v.number(),
  }).index("by_key", ["key"]),
});
