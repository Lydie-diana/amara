import { mutation } from "./_generated/server";

/**
 * Seed pour Limbé, Cameroun — 6 restaurants + menus + promotions
 * Appel : npx convex run seedLimbe:run
 */
export const run = mutation({
  handler: async (ctx) => {
    // Trouver un owner existant (admin)
    const admin = await ctx.db
      .query("users")
      .filter((q) => q.eq(q.field("role"), "admin"))
      .first();

    const ownerId = admin
      ? admin._id
      : await ctx.db.insert("users", {
          name: "Admin Limbé",
          email: "admin-limbe@amara.cm",
          phone: "+237670000000",
          role: "admin",
          isActive: true,
          onboardingCompleted: true,
          preferredLanguage: "fr",
          createdAt: Date.now(),
        });

    const now = Date.now();

    // ═══════════════════════════════════════════════════════════════════
    // RESTAURANTS À LIMBÉ, CAMEROUN
    // ═══════════════════════════════════════════════════════════════════

    // 1. Le Bayou Tropical
    const r1 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Le Bayou Tropical",
      description:
        "Restaurant emblématique de Limbé au bord de la plage. Poissons frais grillés, crevettes géantes et plantains dorés. La cuisine côtière camerounaise dans toute sa splendeur.",
      cuisineType: ["Camerounais", "Fruits de mer"],
      address: "Down Beach Road, Limbé",
      city: "Limbé",
      country: "CM",
      latitude: 4.0186,
      longitude: 9.2043,
      openingHours: {
        monday: { open: "10:00", close: "22:00" },
        tuesday: { open: "10:00", close: "22:00" },
        wednesday: { open: "10:00", close: "22:00" },
        thursday: { open: "10:00", close: "22:00" },
        friday: { open: "10:00", close: "23:00" },
        saturday: { open: "09:00", close: "23:00" },
        sunday: { open: "11:00", close: "21:00" },
      },
      rating: 4.7,
      totalRatings: 89,
      isOpen: true,
      isVerified: true,
      deliveryFee: 500,
      minOrderAmount: 2000,
      estimatedDeliveryTime: 30,
      serviceModes: ["delivery", "takeaway"],
      paymentMethods: ["Mobile Money", "Cash"],
      createdAt: now,
    });

    // 2. Mama Ngono's Kitchen
    const r2 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Mama Ngono's Kitchen",
      description:
        "Cuisine camerounaise traditionnelle faite avec amour. Ndolé aux crevettes, Eru, Achu soup, Koki — les classiques du terroir préparés comme à la maison.",
      cuisineType: ["Camerounais"],
      address: "Church Street, Limbé Town",
      city: "Limbé",
      country: "CM",
      latitude: 4.0210,
      longitude: 9.2110,
      openingHours: {
        monday: { open: "07:00", close: "21:00" },
        tuesday: { open: "07:00", close: "21:00" },
        wednesday: { open: "07:00", close: "21:00" },
        thursday: { open: "07:00", close: "21:00" },
        friday: { open: "07:00", close: "22:00" },
        saturday: { open: "07:00", close: "22:00" },
        sunday: { open: "08:00", close: "20:00" },
      },
      rating: 4.9,
      totalRatings: 156,
      isOpen: true,
      isVerified: true,
      deliveryFee: 0,
      minOrderAmount: 1500,
      estimatedDeliveryTime: 25,
      serviceModes: ["delivery", "takeaway", "dineIn"],
      paymentMethods: ["Mobile Money", "Cash"],
      createdAt: now,
    });

    // 3. Mount Cameroon Grill
    const r3 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Mount Cameroon Grill",
      description:
        "Grillades et BBQ au feu de bois. Poulet braisé croustillant, soya épicé, brochettes de bœuf — l'esprit street food camerounais avec une touche raffinée.",
      cuisineType: ["Camerounais", "Grillades"],
      address: "Mile 4, Limbé",
      city: "Limbé",
      country: "CM",
      latitude: 4.0150,
      longitude: 9.2200,
      openingHours: {
        monday: { open: "12:00", close: "23:00" },
        tuesday: { open: "12:00", close: "23:00" },
        wednesday: { open: "12:00", close: "23:00" },
        thursday: { open: "12:00", close: "23:00" },
        friday: { open: "12:00", close: "00:00" },
        saturday: { open: "11:00", close: "00:00" },
        sunday: { open: "12:00", close: "22:00" },
      },
      rating: 4.5,
      totalRatings: 203,
      isOpen: true,
      isVerified: true,
      deliveryFee: 300,
      minOrderAmount: 2000,
      estimatedDeliveryTime: 35,
      serviceModes: ["delivery", "takeaway"],
      paymentMethods: ["Mobile Money", "Cash", "Carte"],
      createdAt: now,
    });

    // 4. Chez Pasto – Pizzeria & Pasta
    const r4 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Chez Pasto",
      description:
        "Pizzeria artisanale au four à bois avec une touche africaine. Pizzas, pâtes fraîches et salades gourmandes. L'Italie rencontre le Cameroun.",
      cuisineType: ["Italien", "Pizza"],
      address: "Botanic Garden Road, Limbé",
      city: "Limbé",
      country: "CM",
      latitude: 4.0230,
      longitude: 9.2080,
      openingHours: {
        monday: { open: "11:00", close: "22:00" },
        tuesday: { open: "11:00", close: "22:00" },
        wednesday: { open: "11:00", close: "22:00" },
        thursday: { open: "11:00", close: "22:00" },
        friday: { open: "11:00", close: "23:00" },
        saturday: { open: "10:00", close: "23:00" },
        sunday: { open: "12:00", close: "21:00" },
      },
      rating: 4.3,
      totalRatings: 67,
      isOpen: true,
      isVerified: true,
      deliveryFee: 500,
      minOrderAmount: 3000,
      estimatedDeliveryTime: 40,
      serviceModes: ["delivery", "takeaway", "dineIn"],
      paymentMethods: ["Mobile Money", "Cash", "Carte"],
      createdAt: now,
    });

    // 5. Atlantic Burger
    const r5 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Atlantic Burger",
      description:
        "Les meilleurs burgers de Limbé. Viande locale grillée à la flamme, buns maison, frites croustillantes. Fast food de qualité avec des ingrédients frais.",
      cuisineType: ["Américain", "Burger"],
      address: "Half Mile, Limbé",
      city: "Limbé",
      country: "CM",
      latitude: 4.0195,
      longitude: 9.2150,
      openingHours: {
        monday: { open: "10:00", close: "22:00" },
        tuesday: { open: "10:00", close: "22:00" },
        wednesday: { open: "10:00", close: "22:00" },
        thursday: { open: "10:00", close: "22:00" },
        friday: { open: "10:00", close: "23:30" },
        saturday: { open: "10:00", close: "23:30" },
        sunday: { open: "11:00", close: "21:30" },
      },
      rating: 4.4,
      totalRatings: 124,
      isOpen: true,
      isVerified: true,
      deliveryFee: 0,
      minOrderAmount: 2000,
      estimatedDeliveryTime: 20,
      serviceModes: ["delivery", "takeaway"],
      paymentMethods: ["Mobile Money", "Cash"],
      createdAt: now,
    });

    // 6. Jollof House
    const r6 = await ctx.db.insert("restaurants", {
      ownerId,
      name: "Jollof House",
      description:
        "Le temple du Jollof Rice à Limbé. Cuisine nigériane et ouest-africaine. Jollof fumé, Pepper Soup, Suya, Egusi — saveurs intenses et généreuses.",
      cuisineType: ["Nigérian", "Africain"],
      address: "Bota Road, Limbé",
      city: "Limbé",
      country: "CM",
      latitude: 4.0170,
      longitude: 9.1990,
      openingHours: {
        monday: { open: "11:00", close: "22:00" },
        tuesday: { open: "11:00", close: "22:00" },
        wednesday: { open: "11:00", close: "22:00" },
        thursday: { open: "11:00", close: "22:00" },
        friday: { open: "11:00", close: "23:00" },
        saturday: { open: "10:00", close: "23:00" },
        sunday: { open: "12:00", close: "21:00" },
      },
      rating: 4.6,
      totalRatings: 98,
      isOpen: true,
      isVerified: true,
      deliveryFee: 400,
      minOrderAmount: 2500,
      estimatedDeliveryTime: 35,
      serviceModes: ["delivery", "takeaway", "dineIn"],
      paymentMethods: ["Mobile Money", "Cash"],
      createdAt: now,
    });

    // ═══════════════════════════════════════════════════════════════════
    // MENUS
    // ═══════════════════════════════════════════════════════════════════

    const menuBase = { isAvailable: true, createdAt: now };

    // ── Le Bayou Tropical ──
    for (const item of [
      { name: "Poisson braisé (Bar)", description: "Bar entier braisé aux épices, servi avec plantain frit et piment", price: 3500, category: "Plats", tags: ["poisson", "épicé", "populaire"] },
      { name: "Crevettes géantes grillées", description: "Crevettes fraîches de l'Atlantique, marinées et grillées au charbon", price: 5000, category: "Plats", tags: ["fruits de mer", "populaire"] },
      { name: "Ndolé aux crevettes", description: "Feuilles de ndolé mijotées avec crevettes, arachides et poisson fumé", price: 3000, category: "Plats", tags: ["camerounais", "populaire"] },
      { name: "Plantain frit & haricots", description: "Plantain mûr doré accompagné de haricots rouges sautés", price: 1500, category: "Accompagnements", tags: ["végétarien"] },
      { name: "Eru", description: "Eru frais cuit à l'huile de palme avec viande et poisson fumé", price: 2500, category: "Plats", tags: ["camerounais"] },
      { name: "Jus de gingembre maison", description: "Gingembre frais, citron et sucre de canne", price: 500, category: "Boissons", tags: ["boisson"] },
      { name: "Cocktail tropical", description: "Mangue, ananas et fruit de la passion pressés", price: 800, category: "Boissons", tags: ["boisson"] },
    ]) {
      await ctx.db.insert("menuItems", { ...menuBase, restaurantId: r1, ...item });
    }

    // ── Mama Ngono's Kitchen ──
    for (const item of [
      { name: "Ndolé complet", description: "Ndolé aux crevettes, viande et poisson fumé, servi avec miondo", price: 2500, category: "Plats", tags: ["camerounais", "populaire"] },
      { name: "Poulet DG", description: "Poulet sauté aux légumes et plantain mûr — le plat star du Cameroun", price: 3000, category: "Plats", tags: ["camerounais", "populaire"] },
      { name: "Achu Soup & Yellow Fufu", description: "Soupe Achu traditionnelle du Nord-Ouest avec fufu jaune", price: 2000, category: "Plats", tags: ["camerounais"] },
      { name: "Koki", description: "Gâteau de haricots niébé cuit à la feuille de bananier", price: 1500, category: "Entrées", tags: ["camerounais", "végétarien"] },
      { name: "Eru & Water Fufu", description: "Eru épais aux épinards, crevettes sèches et water fufu", price: 2500, category: "Plats", tags: ["camerounais"] },
      { name: "Beignets haricots (Accra)", description: "Beignets croustillants aux haricots, frits à la perfection", price: 500, category: "Entrées", tags: ["camerounais", "végétarien"] },
      { name: "Okok", description: "Feuilles d'okok pilées, cuites au jus d'arachide avec manioc", price: 2000, category: "Plats", tags: ["camerounais"] },
      { name: "Jus de foléré", description: "Bissap camerounais à l'hibiscus, frais et épicé", price: 500, category: "Boissons", tags: ["boisson"] },
    ]) {
      await ctx.db.insert("menuItems", { ...menuBase, restaurantId: r2, ...item });
    }

    // ── Mount Cameroon Grill ──
    for (const item of [
      { name: "Poulet braisé entier", description: "Poulet entier mariné et braisé au charbon de bois, épices secrètes", price: 4000, category: "Grillades", tags: ["poulet", "populaire", "épicé"] },
      { name: "Soya (brochettes bœuf)", description: "Brochettes de bœuf épicées grillées au feu de bois, style street food", price: 1500, category: "Grillades", tags: ["boeuf", "épicé", "populaire"] },
      { name: "Côtes de porc braisées", description: "Côtes de porc marinées et grillées lentement, sauce piquante maison", price: 3500, category: "Grillades", tags: ["épicé"] },
      { name: "Demi-poulet braisé", description: "Demi-poulet braisé avec plantain et piment", price: 2500, category: "Grillades", tags: ["poulet"] },
      { name: "Poisson braisé (Maquereau)", description: "Maquereau entier braisé aux oignons et tomates", price: 2000, category: "Grillades", tags: ["poisson"] },
      { name: "Frites de plantain", description: "Plantain mûr coupé et frit à la perfection", price: 800, category: "Accompagnements", tags: ["végétarien"] },
      { name: "Bière locale (33 Export)", description: "Bière camerounaise bien fraîche", price: 700, category: "Boissons", tags: ["boisson"] },
    ]) {
      await ctx.db.insert("menuItems", { ...menuBase, restaurantId: r3, ...item });
    }

    // ── Chez Pasto ──
    for (const item of [
      { name: "Pizza Margherita", description: "Tomate, mozzarella, basilic frais — la classique au four à bois", price: 4000, category: "Pizzas", tags: ["végétarien", "populaire"] },
      { name: "Pizza Camerounaise", description: "Poulet fumé, oignons caramélisés, poivrons, piment et fromage fondant", price: 5000, category: "Pizzas", tags: ["populaire", "épicé"] },
      { name: "Pizza 4 Fromages", description: "Mozzarella, gorgonzola, parmesan et chèvre", price: 5500, category: "Pizzas", tags: ["végétarien"] },
      { name: "Spaghetti Bolognaise", description: "Pâtes fraîches, sauce tomate au bœuf mijoté", price: 3000, category: "Pâtes", tags: ["boeuf"] },
      { name: "Penne all'Arrabbiata", description: "Pâtes penne à la sauce tomate épicée et ail", price: 2800, category: "Pâtes", tags: ["végétarien", "épicé"] },
      { name: "Salade César", description: "Laitue croquante, poulet grillé, croutons, parmesan et sauce César", price: 2500, category: "Salades", tags: ["poulet"] },
      { name: "Tiramisu maison", description: "Tiramisu crémeux au café et mascarpone", price: 1500, category: "Desserts", tags: [] },
    ]) {
      await ctx.db.insert("menuItems", { ...menuBase, restaurantId: r4, ...item });
    }

    // ── Atlantic Burger ──
    for (const item of [
      { name: "Classic Burger", description: "Steak 150g, cheddar, laitue, tomate, oignons, sauce maison", price: 2500, category: "Burgers", tags: ["boeuf", "populaire"] },
      { name: "Double Smash Burger", description: "Double steak smashé, double cheddar, pickles, sauce spéciale", price: 3500, category: "Burgers", tags: ["boeuf", "populaire"] },
      { name: "Chicken Burger", description: "Filet de poulet pané croustillant, mayo épicée, salade", price: 2500, category: "Burgers", tags: ["poulet"] },
      { name: "Veggie Burger", description: "Galette de haricots noirs et légumes, avocat, tomate", price: 2000, category: "Burgers", tags: ["végétarien"] },
      { name: "Frites maison", description: "Frites coupées à la main, croustillantes et dorées", price: 1000, category: "Sides", tags: ["végétarien"] },
      { name: "Nuggets (6 pcs)", description: "Nuggets de poulet panés maison avec sauce dip", price: 1500, category: "Sides", tags: ["poulet"] },
      { name: "Milkshake vanille", description: "Milkshake crémeux à la vanille de Madagascar", price: 1200, category: "Boissons", tags: ["boisson"] },
      { name: "Milkshake chocolat", description: "Milkshake onctueux au chocolat noir", price: 1200, category: "Boissons", tags: ["boisson"] },
    ]) {
      await ctx.db.insert("menuItems", { ...menuBase, restaurantId: r5, ...item });
    }

    // ── Jollof House ──
    for (const item of [
      { name: "Jollof Rice au poulet", description: "Le fameux riz Jollof fumé nigérian, servi avec poulet grillé", price: 2500, category: "Plats", tags: ["poulet", "populaire", "épicé"] },
      { name: "Egusi Soup & Pounded Yam", description: "Soupe de graines de melon avec igname pilée", price: 3000, category: "Plats", tags: ["nigérian", "populaire"] },
      { name: "Pepper Soup (Catfish)", description: "Soupe de poisson-chat ultra épicée, parfumée aux herbes", price: 2500, category: "Plats", tags: ["poisson", "épicé"] },
      { name: "Suya (brochettes)", description: "Brochettes de bœuf épicées à la poudre de suya, style Lagos", price: 2000, category: "Entrées", tags: ["boeuf", "épicé", "populaire"] },
      { name: "Fried Rice & Chicken", description: "Riz frit aux légumes avec poulet croustillant", price: 2500, category: "Plats", tags: ["poulet"] },
      { name: "Moi Moi", description: "Gâteau de haricots cuit à la vapeur, savoureux et épicé", price: 800, category: "Entrées", tags: ["végétarien", "nigérian"] },
      { name: "Chapman", description: "Cocktail sans alcool nigérian, grenadine et agrumes", price: 800, category: "Boissons", tags: ["boisson"] },
    ]) {
      await ctx.db.insert("menuItems", { ...menuBase, restaurantId: r6, ...item });
    }

    // ═══════════════════════════════════════════════════════════════════
    // PROMOTIONS POUR LIMBÉ
    // ═══════════════════════════════════════════════════════════════════

    await ctx.db.insert("promotions", {
      title: "Livraison gratuite !",
      subtitle: "Sur votre 1ère commande à Limbé",
      tag: "NOUVEAU",
      emoji: "🚀",
      bgColor: "#E62050",
      city: "Limbé",
      isActive: true,
      sortOrder: 1,
      createdAt: now,
    });

    await ctx.db.insert("promotions", {
      title: "-20% Fruits de mer",
      subtitle: "Chez Le Bayou Tropical ce week-end",
      tag: "PROMO",
      emoji: "🦐",
      bgColor: "#1F172B",
      city: "Limbé",
      isActive: true,
      sortOrder: 2,
      createdAt: now,
    });

    await ctx.db.insert("promotions", {
      title: "Menu Découverte",
      subtitle: "Goûtez 3 plats camerounais pour 5000 F",
      tag: "OFFRE SPÉCIALE",
      emoji: "🍛",
      bgColor: "#27AE60",
      city: "Limbé",
      isActive: true,
      sortOrder: 3,
      createdAt: now,
    });

    await ctx.db.insert("promotions", {
      title: "Happy Hour Grillades",
      subtitle: "Poulet braisé à moitié prix de 17h à 19h",
      tag: "PROMO",
      emoji: "🍗",
      bgColor: "#F39C12",
      city: "Limbé",
      isActive: true,
      sortOrder: 4,
      createdAt: now,
    });

    return {
      message: `Seed Limbé OK — 6 restaurants, ${7+8+7+7+8+7} plats, 4 promos`,
      restaurants: [r1, r2, r3, r4, r5, r6],
    };
  },
});
