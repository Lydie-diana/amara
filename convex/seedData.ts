import { mutation } from "./_generated/server";

/**
 * Script de seed pour peupler la base de données Amara avec des données de démo.
 * Restaurants africains à Abidjan + menus complets.
 * Appel unique via : npx convex run seedData:run
 */
export const run = mutation({
  handler: async (ctx) => {
    // Vérifier si déjà seedé
    const existing = await ctx.db.query("restaurants").first();
    if (existing) {
      return { message: "Déjà seedé — aucune action." };
    }

    // ── Owner fictif (admin) ──────────────────────────────────────────────────
    const ownerId = await ctx.db.insert("users", {
      name: "Admin Amara",
      email: "admin@amara.ci",
      phone: "+2250700000000",
      role: "admin",
      isActive: true,
      onboardingCompleted: true,
      preferredLanguage: "fr",
      createdAt: Date.now(),
    });

    // ── Restaurants ───────────────────────────────────────────────────────────

    const r1 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Chez Mama Africa",
      description: "La cuisine ivoirienne authentique, des recettes transmises de génération en génération. Saveurs du terroir, épices sélectionnées, produits frais du marché d'Adjamé.",
      cuisineType: ["Ivoirien", "Africain"],
      address: "Boulevard de la Corniche, Cocody",
      city: "Abidjan",
      country: "CI",
      latitude: 5.3484,
      longitude: -4.0083,
      openingHours: {
        monday:    { open: "10:00", close: "22:00" },
        tuesday:   { open: "10:00", close: "22:00" },
        wednesday: { open: "10:00", close: "22:00" },
        thursday:  { open: "10:00", close: "22:30" },
        friday:    { open: "10:00", close: "23:00" },
        saturday:  { open: "09:00", close: "23:00" },
        sunday:    { open: "11:00", close: "21:00" },
      },
      rating: 4.8,
      totalRatings: 312,
      isOpen: true,
      isVerified: true,
      deliveryFee: 0,
      minOrderAmount: 2000,
      estimatedDeliveryTime: 30,
      createdAt: Date.now(),
    });

    const r2 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Saveurs du Sahel",
      description: "Voyage culinaire au cœur de l'Afrique de l'Ouest. Thiéboudienne, Yassa poulet, Maafé — les incontournables du Sénégal servis avec générosité.",
      cuisineType: ["Sénégalais", "Africain"],
      address: "Avenue Chardy, Le Plateau",
      city: "Abidjan",
      country: "CI",
      latitude: 5.3200,
      longitude: -4.0200,
      openingHours: {
        monday:    { open: "11:00", close: "22:00" },
        tuesday:   { open: "11:00", close: "22:00" },
        wednesday: { open: "11:00", close: "22:00" },
        thursday:  { open: "11:00", close: "22:00" },
        friday:    { open: "11:00", close: "23:00" },
        saturday:  { open: "10:00", close: "23:00" },
        sunday:    { open: "12:00", close: "21:00" },
      },
      rating: 4.6,
      totalRatings: 187,
      isOpen: true,
      isVerified: true,
      deliveryFee: 500,
      minOrderAmount: 3000,
      estimatedDeliveryTime: 40,
      createdAt: Date.now(),
    });

    const r3 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Terroir Camerounais",
      description: "Ndolé aux crevettes, Poulet DG, Eru, Koki — la richesse de la cuisine camerounaise dans chaque plat. Fait maison chaque matin, livré frais.",
      cuisineType: ["Camerounais", "Africain"],
      address: "Rue des Jardins, Marcory",
      city: "Abidjan",
      country: "CI",
      latitude: 5.3000,
      longitude: -3.9900,
      openingHours: {
        monday:    { open: "11:00", close: "21:00" },
        tuesday:   { open: "11:00", close: "21:00" },
        wednesday: { open: "11:00", close: "21:00" },
        thursday:  { open: "11:00", close: "21:00" },
        friday:    { open: "11:00", close: "22:00" },
        saturday:  { open: "10:00", close: "22:00" },
      },
      rating: 4.7,
      totalRatings: 256,
      isOpen: false,
      isVerified: true,
      deliveryFee: 0,
      minOrderAmount: 2500,
      estimatedDeliveryTime: 25,
      createdAt: Date.now(),
    });

    const r4 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Lagos Kitchen",
      description: "La chaleur de Lagos dans votre assiette. Jollof Rice fumé, Egusi Soup, Suya épicé — la street food nigériane authentique à Abidjan.",
      cuisineType: ["Nigérian", "Africain"],
      address: "Rue des Fleurs, Yopougon",
      city: "Abidjan",
      country: "CI",
      latitude: 5.3700,
      longitude: -4.0700,
      openingHours: {
        monday:    { open: "10:00", close: "22:00" },
        tuesday:   { open: "10:00", close: "22:00" },
        wednesday: { open: "10:00", close: "22:00" },
        thursday:  { open: "10:00", close: "22:00" },
        friday:    { open: "10:00", close: "23:00" },
        saturday:  { open: "09:00", close: "23:00" },
        sunday:    { open: "11:00", close: "21:00" },
      },
      rating: 4.5,
      totalRatings: 42,
      isOpen: true,
      isVerified: false,
      deliveryFee: 750,
      minOrderAmount: 2000,
      estimatedDeliveryTime: 45,
      createdAt: Date.now(),
    });

    const r5 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Marrakech Délices",
      description: "Couscous aux 7 légumes, tagine d'agneau aux pruneaux, pastilla au poulet — la cuisine marocaine dans toute sa splendeur. Des saveurs du Maghreb à Abidjan.",
      cuisineType: ["Marocain", "Maghrébin"],
      address: "Riviera Palmeraie, Cocody",
      city: "Abidjan",
      country: "CI",
      latitude: 5.3600,
      longitude: -3.9700,
      openingHours: {
        monday:    { open: "11:00", close: "22:00" },
        tuesday:   { open: "11:00", close: "22:00" },
        wednesday: { open: "11:00", close: "22:00" },
        thursday:  { open: "11:00", close: "22:00" },
        friday:    { open: "12:00", close: "23:00" },
        saturday:  { open: "11:00", close: "23:00" },
        sunday:    { open: "12:00", close: "21:00" },
      },
      rating: 4.4,
      totalRatings: 28,
      isOpen: true,
      isVerified: false,
      deliveryFee: 0,
      minOrderAmount: 3500,
      estimatedDeliveryTime: 35,
      createdAt: Date.now(),
    });

    const r6 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Addis Flavors",
      description: "L'injera et les wots éthiopiens, un voyage sensoriel unique. Cuisine végétarienne et carnée servie sur pain traditionnel. Doro Wat, Tibs, Kitfo.",
      cuisineType: ["Éthiopien", "Africain"],
      address: "Deux Plateaux Vallon, Cocody",
      city: "Abidjan",
      country: "CI",
      latitude: 5.3800,
      longitude: -3.9800,
      openingHours: {
        monday:    { open: "11:00", close: "22:00" },
        tuesday:   { open: "11:00", close: "22:00" },
        wednesday: { open: "11:00", close: "22:00" },
        thursday:  { open: "11:00", close: "22:00" },
        friday:    { open: "11:00", close: "22:30" },
        saturday:  { open: "10:00", close: "22:30" },
        sunday:    { open: "12:00", close: "21:00" },
      },
      rating: 4.6,
      totalRatings: 63,
      isOpen: true,
      isVerified: true,
      deliveryFee: 500,
      minOrderAmount: 2000,
      estimatedDeliveryTime: 40,
      createdAt: Date.now(),
    });

    // ── Menus ─────────────────────────────────────────────────────────────────

    // R1 — Chez Mama Africa (Ivoirien)
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Attiéké Poisson Braisé", description: "Semoule de manioc avec poisson tilapia braisé, tomate et oignon frits.", price: 2500, category: "Plats populaires", isAvailable: true, preparationTime: 15, tags: ["poisson", "local"], optionGroups: [
      { id: "og1", title: "Choix du poisson", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Tilapia", extraPrice: 0 },
        { id: "o2", name: "Carpe", extraPrice: 0 },
        { id: "o3", name: "Poisson fumé", extraPrice: 500 },
      ]},
      { id: "og2", title: "Sauces", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Sauce piment", extraPrice: 0 },
        { id: "o5", name: "Sauce tomate-oignon", extraPrice: 0 },
        { id: "o6", name: "Mayonnaise", extraPrice: 100 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Kedjenou de Poulet", description: "Ragoût de poulet mijoté aux épices locales en cocotte, servi avec attiéké.", price: 3500, category: "Plats populaires", isAvailable: true, preparationTime: 20, tags: ["poulet", "épicé"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Attiéké", extraPrice: 0 },
        { id: "o2", name: "Riz blanc", extraPrice: 200 },
        { id: "o3", name: "Foutou banane", extraPrice: 300 },
      ]},
      { id: "og2", title: "Niveau de piment", required: false, maxSelections: 1, options: [
        { id: "o4", name: "Doux", extraPrice: 0 },
        { id: "o5", name: "Moyen", extraPrice: 0 },
        { id: "o6", name: "Très piquant", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Foutou Banane + Sauce Graine", description: "Foutou de banane plantain accompagné de la sauce aux graines de palme.", price: 2000, category: "Plats populaires", isAvailable: true, preparationTime: 15, tags: ["végétarien", "local"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Poulet Braisé + Alloco", description: "Demi-poulet mariné et braisé au feu de bois, avec banane plantain frite.", price: 4000, category: "Grillades", isAvailable: true, preparationTime: 25, tags: ["poulet", "grillé"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Alloco (plantain frit)", extraPrice: 0 },
        { id: "o2", name: "Attiéké", extraPrice: 0 },
        { id: "o3", name: "Frites", extraPrice: 300 },
      ]},
      { id: "og2", title: "Sauces", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Sauce piment", extraPrice: 0 },
        { id: "o5", name: "Mayonnaise", extraPrice: 0 },
        { id: "o6", name: "Sauce tomate-oignon", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Poisson Braisé Entier", description: "Tilapia grillé au charbon, avec sauce tomate maison et attiéké.", price: 3000, category: "Grillades", isAvailable: true, preparationTime: 20, tags: ["poisson", "grillé"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Brochettes de Bœuf", description: "6 brochettes de bœuf marinées aux épices, avec pain et sauce pimentée.", price: 2500, category: "Grillades", isAvailable: true, preparationTime: 15, tags: ["boeuf", "épicé"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Alloco", description: "Banane plantain mûre frite, dorée et croustillante.", price: 500, category: "Accompagnements", isAvailable: true, preparationTime: 8, tags: ["végétarien"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Riz blanc", description: "Riz parfumé à la vapeur.", price: 500, category: "Accompagnements", isAvailable: true, preparationTime: 5, tags: ["végétarien"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Jus de Bissap", description: "Boisson fraîche à base de fleurs d'hibiscus, légèrement sucrée.", price: 800, category: "Boissons", isAvailable: true, preparationTime: 2, tags: ["végétarien", "boisson"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Jus de Gingembre", description: "Gingembre frais pressé, légèrement sucré et épicé.", price: 800, category: "Boissons", isAvailable: true, preparationTime: 2, tags: ["végétarien", "boisson"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Eau minérale", description: "Bouteille 50cl.", price: 300, category: "Boissons", isAvailable: true, preparationTime: 1, tags: ["boisson"], createdAt: Date.now() });

    // R2 — Saveurs du Sahel (Sénégalais)
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Thiéboudienne Rouge", description: "Riz au poisson emblématique du Sénégal, avec légumes et sauce tomate.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["poisson", "riz"], optionGroups: [
      { id: "og1", title: "Choix du poisson", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Thiof (mérou)", extraPrice: 0 },
        { id: "o2", name: "Capitaine", extraPrice: 300 },
        { id: "o3", name: "Crevettes", extraPrice: 500 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Yassa Poulet", description: "Poulet mariné à l'oignon et au citron, grillé puis mijoté. Servi avec riz.", price: 3000, category: "Spécialités", isAvailable: true, preparationTime: 25, tags: ["poulet"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Riz blanc", extraPrice: 0 },
        { id: "o2", name: "Fonio", extraPrice: 200 },
        { id: "o3", name: "Attiéké", extraPrice: 300 },
      ]},
      { id: "og2", title: "Niveau de piment", required: false, maxSelections: 1, options: [
        { id: "o4", name: "Sans piment", extraPrice: 0 },
        { id: "o5", name: "Piment doux", extraPrice: 0 },
        { id: "o6", name: "Piment fort", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Maafé de Bœuf", description: "Ragoût de bœuf à la pâte d'arachide, légumes, servi avec riz blanc.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["boeuf", "épicé"], optionGroups: [
      { id: "og1", title: "Choix de la viande", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Bœuf", extraPrice: 0 },
        { id: "o2", name: "Agneau", extraPrice: 500 },
        { id: "o3", name: "Poulet", extraPrice: 0 },
      ]},
      { id: "og2", title: "Suppléments", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Banane plantain", extraPrice: 300 },
        { id: "o5", name: "Œuf dur", extraPrice: 200 },
        { id: "o6", name: "Portion de riz extra", extraPrice: 300 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Thiébou Yapp", description: "Riz à la viande de bœuf, version terroir du thiéboudienne.", price: 3200, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["boeuf", "riz"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Bissap Royal", description: "Jus de bissap maison, concentré et parfumé à la menthe.", price: 1000, category: "Boissons", isAvailable: true, preparationTime: 2, tags: ["boisson"], createdAt: Date.now() });

    // R3 — Terroir Camerounais
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Ndolé aux Crevettes", description: "Feuilles de ndolé aux crevettes fumées et arachides. Plat national camerounais.", price: 4000, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["crevettes", "local"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Plantain mûr", extraPrice: 0 },
        { id: "o2", name: "Miondo (bâton de manioc)", extraPrice: 0 },
        { id: "o3", name: "Riz blanc", extraPrice: 300 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Poulet DG", description: "Poulet Directeur Général : sauté aux plantains et légumes. Festif et généreux.", price: 4500, category: "Spécialités", isAvailable: true, preparationTime: 35, tags: ["poulet", "épicé"], optionGroups: [
      { id: "og1", title: "Taille de la portion", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Normal", extraPrice: 0 },
        { id: "o2", name: "Large", extraPrice: 800 },
      ]},
      { id: "og2", title: "Suppléments", required: false, maxSelections: 3, options: [
        { id: "o3", name: "Plantain mûr extra", extraPrice: 300 },
        { id: "o4", name: "Avocat", extraPrice: 400 },
        { id: "o5", name: "Œuf au plat", extraPrice: 200 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Eru au Bœuf", description: "Légumes eru mijotés avec bœuf fumé et huile de palme rouge.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 25, tags: ["boeuf"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Waterfufu", extraPrice: 0 },
        { id: "o2", name: "Garri", extraPrice: 0 },
        { id: "o3", name: "Riz blanc", extraPrice: 300 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Koki de Haricots", description: "Gâteau de haricots à l'huile de palme, cuit à la vapeur dans des feuilles.", price: 1500, category: "Entrées", isAvailable: true, preparationTime: 15, tags: ["végétarien"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Plantains Mûrs Frits", description: "Plantains bien mûrs, frits à la perfection.", price: 800, category: "Accompagnements", isAvailable: true, preparationTime: 10, tags: ["végétarien"], createdAt: Date.now() });

    // R4 — Lagos Kitchen (Nigérian)
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Jollof Rice Fumé", description: "Le fameux Jollof rice nigérian, cuit au feu de bois avec poulet grillé.", price: 3000, category: "Spécialités", isAvailable: true, preparationTime: 25, tags: ["riz", "poulet"], optionGroups: [
      { id: "og1", title: "Protéine", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Poulet grillé", extraPrice: 500 },
        { id: "o2", name: "Bœuf haché", extraPrice: 700 },
        { id: "o3", name: "Crevettes", extraPrice: 900 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Egusi Soup + Fufu", description: "Soupe de graines de melon aux légumes et viande, avec fufu de manioc.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["épicé"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Fufu de manioc", extraPrice: 0 },
        { id: "o2", name: "Pounded yam", extraPrice: 200 },
        { id: "o3", name: "Semolina", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Suya Bœuf", description: "Brochettes de bœuf épicées à la nigériane, marinées au kilishi.", price: 3000, category: "Grillades", isAvailable: true, preparationTime: 20, tags: ["boeuf", "épicé", "grillé"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Puff Puff", description: "Beignets moelleux sucrés, la street food nigériane par excellence.", price: 1000, category: "Street Food", isAvailable: true, preparationTime: 10, tags: ["sucré"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Chapman Cocktail", description: "Boisson pétillante nigériane aux agrumes et grenadine. Sans alcool.", price: 1200, category: "Boissons", isAvailable: true, preparationTime: 2, tags: ["boisson"], createdAt: Date.now() });

    // R5 — Marrakech Délices (Marocain)
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Couscous Royal", description: "Couscous aux 7 légumes avec agneau, poulet et merguez. Le classique.", price: 5000, category: "Spécialités", isAvailable: true, preparationTime: 35, tags: ["agneau", "légumes"], optionGroups: [
      { id: "og1", title: "Suppléments viande", required: false, maxSelections: 3, options: [
        { id: "o1", name: "Merguez x2", extraPrice: 400 },
        { id: "o2", name: "Cuisse de poulet extra", extraPrice: 500 },
        { id: "o3", name: "Brochette d'agneau", extraPrice: 700 },
      ]},
      { id: "og2", title: "Sauces", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Harissa", extraPrice: 0 },
        { id: "o5", name: "Sauce piquante", extraPrice: 100 },
        { id: "o6", name: "Bouillon extra", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Tagine Agneau Pruneaux", description: "Agneau confit aux pruneaux, amandes et miel dans un tajine traditionnel.", price: 5500, category: "Spécialités", isAvailable: true, preparationTime: 40, tags: ["agneau", "sucré"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Pain marocain", extraPrice: 0 },
        { id: "o2", name: "Semoule", extraPrice: 300 },
        { id: "o3", name: "Riz safrané", extraPrice: 400 },
      ]},
      { id: "og2", title: "Taille", required: false, maxSelections: 1, options: [
        { id: "o4", name: "Portion normale", extraPrice: 0 },
        { id: "o5", name: "Grande portion", extraPrice: 1000 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Pastilla au Poulet", description: "Feuilleté croustillant au poulet, amandes et cannelle. Tradition fassi.", price: 4000, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["poulet", "sucré"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Harira", description: "Soupe traditionnelle marocaine aux lentilles, tomates et pois chiches.", price: 1500, category: "Entrées", isAvailable: true, preparationTime: 10, tags: ["végétarien", "soupe"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Thé à la Menthe", description: "Thé vert marocain à la menthe fraîche, sucré selon tradition.", price: 800, category: "Boissons", isAvailable: true, preparationTime: 5, tags: ["boisson"], createdAt: Date.now() });

    // R6 — Addis Flavors (Éthiopien)
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Doro Wat", description: "Ragoût de poulet épicé au berbéré, avec œufs durs. Plat de fête éthiopien.", price: 4000, category: "Spécialités", isAvailable: true, preparationTime: 35, tags: ["poulet", "épicé"], optionGroups: [
      { id: "og1", title: "Nombre d'injera", required: true, maxSelections: 1, options: [
        { id: "o1", name: "2 injera (standard)", extraPrice: 0 },
        { id: "o2", name: "4 injera", extraPrice: 300 },
        { id: "o3", name: "6 injera", extraPrice: 500 },
      ]},
      { id: "og2", title: "Accompagnements", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Salade verte", extraPrice: 200 },
        { id: "o5", name: "Ayib (fromage frais)", extraPrice: 300 },
        { id: "o6", name: "Gomen (épinards)", extraPrice: 250 },
      ]},
    ], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Tibs de Bœuf", description: "Bœuf sauté au beurre clarifié avec oignons, tomates et jalapeños.", price: 4500, category: "Spécialités", isAvailable: true, preparationTime: 20, tags: ["boeuf", "épicé"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Beyaynet Végétarien", description: "Plateau injera avec 6 wots végétariens : lentilles, pois, épinards…", price: 3500, category: "Végétarien", isAvailable: true, preparationTime: 15, tags: ["végétarien"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Kitfo", description: "Bœuf haché au beurre clarifié et épices mitmita. La tartare éthiopienne.", price: 5000, category: "Spécialités", isAvailable: true, preparationTime: 10, tags: ["boeuf"], createdAt: Date.now() });
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Café Éthiopien Bunna", description: "Café cérémonial éthiopien, torréfié et infusé selon la tradition.", price: 1000, category: "Boissons", isAvailable: true, preparationTime: 8, tags: ["boisson"], createdAt: Date.now() });

    return {
      message: "✅ Seed réussi !",
      restaurants: 6,
      menuItems: 36,
    };
  },
});

/**
 * Supprime tous les menuItems et les re-crée.
 * Usage : npx convex run seedData:reseedMenuItems
 */
export const reseedMenuItems = mutation({
  handler: async (ctx) => {
    // Supprimer tous les menuItems existants
    const allItems = await ctx.db.query("menuItems").collect();
    for (const item of allItems) {
      await ctx.db.delete(item._id);
    }

    // Récupérer les restaurants par nom
    const restaurants = await ctx.db.query("restaurants").collect();
    const byName = (n: string) => restaurants.find((r) => r.name === n)?._id;

    const r1 = byName("Chez Mama Africa");
    const r2 = byName("Saveurs du Sahel");
    const r3 = byName("Terroir Camerounais");
    const r4 = byName("Lagos Kitchen");
    const r5 = byName("Marrakech Délices");
    const r6 = byName("Addis Flavors");

    if (!r1 || !r2 || !r3 || !r4 || !r5 || !r6) {
      return { message: "❌ Restaurants non trouvés. Lancez d'abord seedData:run." };
    }

    let count = 0;

    // R1 — Chez Mama Africa
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Attiéké Poisson Braisé", description: "Semoule de manioc avec poisson tilapia braisé, tomate et oignon frits.", price: 2500, category: "Plats populaires", isAvailable: true, preparationTime: 15, tags: ["poisson", "local"], optionGroups: [
      { id: "og1", title: "Choix du poisson", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Tilapia", extraPrice: 0 },
        { id: "o2", name: "Carpe", extraPrice: 0 },
        { id: "o3", name: "Poisson fumé", extraPrice: 500 },
      ]},
      { id: "og2", title: "Sauces", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Sauce piment", extraPrice: 0 },
        { id: "o5", name: "Sauce tomate-oignon", extraPrice: 0 },
        { id: "o6", name: "Mayonnaise", extraPrice: 100 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Kedjenou de Poulet", description: "Ragoût de poulet mijoté aux épices locales en cocotte, servi avec attiéké.", price: 3500, category: "Plats populaires", isAvailable: true, preparationTime: 20, tags: ["poulet", "épicé"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Attiéké", extraPrice: 0 },
        { id: "o2", name: "Riz blanc", extraPrice: 200 },
        { id: "o3", name: "Foutou banane", extraPrice: 300 },
      ]},
      { id: "og2", title: "Niveau de piment", required: false, maxSelections: 1, options: [
        { id: "o4", name: "Doux", extraPrice: 0 },
        { id: "o5", name: "Moyen", extraPrice: 0 },
        { id: "o6", name: "Très piquant", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Foutou Banane + Sauce Graine", description: "Foutou de banane plantain accompagné de la sauce aux graines de palme.", price: 2000, category: "Plats populaires", isAvailable: true, preparationTime: 15, tags: ["végétarien", "local"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Poulet Braisé + Alloco", description: "Demi-poulet mariné et braisé au feu de bois, avec banane plantain frite.", price: 4000, category: "Grillades", isAvailable: true, preparationTime: 25, tags: ["poulet", "grillé"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Alloco (plantain frit)", extraPrice: 0 },
        { id: "o2", name: "Attiéké", extraPrice: 0 },
        { id: "o3", name: "Frites", extraPrice: 300 },
      ]},
      { id: "og2", title: "Sauces", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Sauce piment", extraPrice: 0 },
        { id: "o5", name: "Mayonnaise", extraPrice: 0 },
        { id: "o6", name: "Sauce tomate-oignon", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Poisson Braisé Entier", description: "Tilapia grillé au charbon, avec sauce tomate maison et attiéké.", price: 3000, category: "Grillades", isAvailable: true, preparationTime: 20, tags: ["poisson", "grillé"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Brochettes de Bœuf", description: "6 brochettes de bœuf marinées aux épices, avec pain et sauce pimentée.", price: 2500, category: "Grillades", isAvailable: true, preparationTime: 15, tags: ["boeuf", "épicé"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Alloco", description: "Banane plantain mûre frite, dorée et croustillante.", price: 500, category: "Accompagnements", isAvailable: true, preparationTime: 8, tags: ["végétarien"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Riz blanc", description: "Riz parfumé à la vapeur.", price: 500, category: "Accompagnements", isAvailable: true, preparationTime: 5, tags: ["végétarien"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Jus de Bissap", description: "Boisson fraîche à base de fleurs d'hibiscus.", price: 800, category: "Boissons", isAvailable: true, preparationTime: 2, tags: ["végétarien", "boisson"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r1, name: "Eau minérale", description: "Bouteille 50cl.", price: 300, category: "Boissons", isAvailable: true, preparationTime: 1, tags: ["boisson"], createdAt: Date.now() }); count++;

    // R2 — Saveurs du Sahel
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Thiéboudienne Rouge", description: "Riz au poisson emblématique du Sénégal, avec légumes et sauce tomate.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["poisson", "riz"], optionGroups: [
      { id: "og1", title: "Choix du poisson", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Thiof (mérou)", extraPrice: 0 },
        { id: "o2", name: "Capitaine", extraPrice: 300 },
        { id: "o3", name: "Crevettes", extraPrice: 500 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Yassa Poulet", description: "Poulet mariné à l'oignon et au citron, grillé puis mijoté.", price: 3000, category: "Spécialités", isAvailable: true, preparationTime: 25, tags: ["poulet"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Riz blanc", extraPrice: 0 },
        { id: "o2", name: "Fonio", extraPrice: 200 },
        { id: "o3", name: "Attiéké", extraPrice: 300 },
      ]},
      { id: "og2", title: "Niveau de piment", required: false, maxSelections: 1, options: [
        { id: "o4", name: "Sans piment", extraPrice: 0 },
        { id: "o5", name: "Piment doux", extraPrice: 0 },
        { id: "o6", name: "Piment fort", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Maafé de Bœuf", description: "Ragoût de bœuf à la pâte d'arachide, légumes.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["boeuf", "épicé"], optionGroups: [
      { id: "og1", title: "Choix de la viande", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Bœuf", extraPrice: 0 },
        { id: "o2", name: "Agneau", extraPrice: 500 },
        { id: "o3", name: "Poulet", extraPrice: 0 },
      ]},
      { id: "og2", title: "Suppléments", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Banane plantain", extraPrice: 300 },
        { id: "o5", name: "Œuf dur", extraPrice: 200 },
        { id: "o6", name: "Riz extra", extraPrice: 300 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Thiébou Yapp", description: "Riz à la viande de bœuf, version terroir.", price: 3200, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["boeuf", "riz"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r2, name: "Bissap Royal", description: "Jus de bissap maison, concentré et parfumé à la menthe.", price: 1000, category: "Boissons", isAvailable: true, preparationTime: 2, tags: ["boisson"], createdAt: Date.now() }); count++;

    // R3 — Terroir Camerounais
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Ndolé aux Crevettes", description: "Feuilles de ndolé aux crevettes fumées et arachides.", price: 4000, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["crevettes", "local"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Plantain mûr", extraPrice: 0 },
        { id: "o2", name: "Miondo (bâton de manioc)", extraPrice: 0 },
        { id: "o3", name: "Riz blanc", extraPrice: 300 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Poulet DG", description: "Poulet Directeur Général : sauté aux plantains et légumes.", price: 4500, category: "Spécialités", isAvailable: true, preparationTime: 35, tags: ["poulet", "épicé"], optionGroups: [
      { id: "og1", title: "Taille de la portion", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Normal", extraPrice: 0 },
        { id: "o2", name: "Large", extraPrice: 800 },
      ]},
      { id: "og2", title: "Suppléments", required: false, maxSelections: 3, options: [
        { id: "o3", name: "Plantain mûr extra", extraPrice: 300 },
        { id: "o4", name: "Avocat", extraPrice: 400 },
        { id: "o5", name: "Œuf au plat", extraPrice: 200 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Eru au Bœuf", description: "Légumes eru mijotés avec bœuf fumé et huile de palme.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 25, tags: ["boeuf"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Waterfufu", extraPrice: 0 },
        { id: "o2", name: "Garri", extraPrice: 0 },
        { id: "o3", name: "Riz blanc", extraPrice: 300 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Koki de Haricots", description: "Gâteau de haricots à l'huile de palme.", price: 1500, category: "Entrées", isAvailable: true, preparationTime: 15, tags: ["végétarien"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r3, name: "Plantains Mûrs Frits", description: "Plantains bien mûrs, frits à la perfection.", price: 800, category: "Accompagnements", isAvailable: true, preparationTime: 10, tags: ["végétarien"], createdAt: Date.now() }); count++;

    // R4 — Lagos Kitchen
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Jollof Rice Fumé", description: "Le fameux Jollof rice nigérian, cuit au feu de bois.", price: 3000, category: "Spécialités", isAvailable: true, preparationTime: 25, tags: ["riz", "poulet"], optionGroups: [
      { id: "og1", title: "Protéine", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Poulet grillé", extraPrice: 500 },
        { id: "o2", name: "Bœuf haché", extraPrice: 700 },
        { id: "o3", name: "Crevettes", extraPrice: 900 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Egusi Soup + Fufu", description: "Soupe de graines de melon aux légumes et viande.", price: 3500, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["épicé"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Fufu de manioc", extraPrice: 0 },
        { id: "o2", name: "Pounded yam", extraPrice: 200 },
        { id: "o3", name: "Semolina", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Suya Bœuf", description: "Brochettes de bœuf épicées à la nigériane.", price: 3000, category: "Grillades", isAvailable: true, preparationTime: 20, tags: ["boeuf", "épicé", "grillé"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Puff Puff", description: "Beignets moelleux sucrés, la street food nigériane.", price: 1000, category: "Street Food", isAvailable: true, preparationTime: 10, tags: ["sucré"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r4, name: "Chapman Cocktail", description: "Boisson pétillante aux agrumes et grenadine. Sans alcool.", price: 1200, category: "Boissons", isAvailable: true, preparationTime: 2, tags: ["boisson"], createdAt: Date.now() }); count++;

    // R5 — Marrakech Délices
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Couscous Royal", description: "Couscous aux 7 légumes avec agneau, poulet et merguez.", price: 5000, category: "Spécialités", isAvailable: true, preparationTime: 35, tags: ["agneau", "légumes"], optionGroups: [
      { id: "og1", title: "Suppléments viande", required: false, maxSelections: 3, options: [
        { id: "o1", name: "Merguez x2", extraPrice: 400 },
        { id: "o2", name: "Cuisse de poulet extra", extraPrice: 500 },
        { id: "o3", name: "Brochette d'agneau", extraPrice: 700 },
      ]},
      { id: "og2", title: "Sauces", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Harissa", extraPrice: 0 },
        { id: "o5", name: "Sauce piquante", extraPrice: 100 },
        { id: "o6", name: "Bouillon extra", extraPrice: 0 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Tagine Agneau Pruneaux", description: "Agneau confit aux pruneaux, amandes et miel dans un tajine traditionnel.", price: 5500, category: "Spécialités", isAvailable: true, preparationTime: 40, tags: ["agneau", "sucré"], optionGroups: [
      { id: "og1", title: "Accompagnement", required: true, maxSelections: 1, options: [
        { id: "o1", name: "Pain marocain", extraPrice: 0 },
        { id: "o2", name: "Semoule", extraPrice: 300 },
        { id: "o3", name: "Riz safrané", extraPrice: 400 },
      ]},
      { id: "og2", title: "Taille", required: false, maxSelections: 1, options: [
        { id: "o4", name: "Portion normale", extraPrice: 0 },
        { id: "o5", name: "Grande portion", extraPrice: 1000 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Pastilla au Poulet", description: "Feuilleté croustillant au poulet, amandes et cannelle.", price: 4000, category: "Spécialités", isAvailable: true, preparationTime: 30, tags: ["poulet", "sucré"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Harira", description: "Soupe traditionnelle marocaine aux lentilles.", price: 1500, category: "Entrées", isAvailable: true, preparationTime: 10, tags: ["végétarien", "soupe"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r5, name: "Thé à la Menthe", description: "Thé vert marocain à la menthe fraîche.", price: 800, category: "Boissons", isAvailable: true, preparationTime: 5, tags: ["boisson"], createdAt: Date.now() }); count++;

    // R6 — Addis Flavors
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Doro Wat", description: "Ragoût de poulet épicé au berbéré, avec œufs durs.", price: 4000, category: "Spécialités", isAvailable: true, preparationTime: 35, tags: ["poulet", "épicé"], optionGroups: [
      { id: "og1", title: "Nombre d'injera", required: true, maxSelections: 1, options: [
        { id: "o1", name: "2 injera (standard)", extraPrice: 0 },
        { id: "o2", name: "4 injera", extraPrice: 300 },
        { id: "o3", name: "6 injera", extraPrice: 500 },
      ]},
      { id: "og2", title: "Accompagnements", required: false, maxSelections: 2, options: [
        { id: "o4", name: "Salade verte", extraPrice: 200 },
        { id: "o5", name: "Ayib (fromage frais)", extraPrice: 300 },
        { id: "o6", name: "Gomen (épinards)", extraPrice: 250 },
      ]},
    ], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Tibs de Bœuf", description: "Bœuf sauté au beurre clarifié avec oignons et tomates.", price: 4500, category: "Spécialités", isAvailable: true, preparationTime: 20, tags: ["boeuf", "épicé"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Beyaynet Végétarien", description: "Plateau injera avec 6 wots végétariens.", price: 3500, category: "Végétarien", isAvailable: true, preparationTime: 15, tags: ["végétarien"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Kitfo", description: "Bœuf haché au beurre clarifié et épices mitmita.", price: 5000, category: "Spécialités", isAvailable: true, preparationTime: 10, tags: ["boeuf"], createdAt: Date.now() }); count++;
    await ctx.db.insert("menuItems", { restaurantId: r6, name: "Café Éthiopien Bunna", description: "Café cérémonial éthiopien, torréfié selon la tradition.", price: 1000, category: "Boissons", isAvailable: true, preparationTime: 8, tags: ["boisson"], createdAt: Date.now() }); count++;

    return {
      message: `✅ Reseed réussi ! ${allItems.length} items supprimés, ${count} items créés.`,
      deleted: allItems.length,
      created: count,
    };
  },
});
