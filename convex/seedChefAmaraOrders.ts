import { mutation } from "./_generated/server";
import { v } from "convex/values";

/**
 * Seed clients + commandes + reviews pour Chef Amara.
 * - 12 clients avec profils réalistes ivoiriens
 * - ~50 commandes avec statuts variés (delivered, confirmed, preparing, cancelled…)
 * - Reviews pour les commandes livrées → met à jour orderCount + rating des plats
 * Usage : npx convex run seedChefAmaraOrders:run '{"restaurantId":"ks77mgts7ske85zwxv3bkmcv1x81xwyd"}'
 */
export const run = mutation({
  args: { restaurantId: v.string() },
  handler: async (ctx, args) => {
    const restaurantId = args.restaurantId as any;

    // Vérifier que le restaurant existe
    const restaurant = await ctx.db.get(restaurantId);
    if (!restaurant) throw new Error("Restaurant non trouvé");

    // Récupérer tous les plats de Chef Amara
    const menuItems = await ctx.db
      .query("menuItems")
      .withIndex("by_restaurant", (q) => q.eq("restaurantId", restaurantId))
      .collect();

    if (menuItems.length === 0) throw new Error("Aucun plat trouvé — lancez d'abord seedChefAmara:run");

    // Indexer les plats par catégorie pour construire des commandes cohérentes
    const byCategory: Record<string, typeof menuItems> = {};
    for (const item of menuItems) {
      const cat = item.category as string;
      if (!byCategory[cat]) byCategory[cat] = [];
      byCategory[cat].push(item);
    }

    const now = Date.now();
    const DAY = 86400000;

    // ─── 1. CLIENTS ──────────────────────────────────────────────────────────

    const clientsData = [
      { name: "Kouamé Koffi", email: "kouame.koffi@gmail.com", phone: "0701234501", address: "Résidence Les Cocotiers, Cocody, Abidjan", lat: 5.3611, lng: -3.9989 },
      { name: "Aya Traoré", email: "aya.traore@yahoo.fr", phone: "0701234502", address: "Cité des Arts, Yopougon, Abidjan", lat: 5.3430, lng: -4.0720 },
      { name: "Didier Gbagbo", email: "didier.gbagbo@hotmail.com", phone: "0701234503", address: "Plateau, Boulevard de la République, Abidjan", lat: 5.3166, lng: -4.0228 },
      { name: "Mariam Coulibaly", email: "mariam.coulibaly@gmail.com", phone: "0701234504", address: "Riviera Palmeraie, Cocody, Abidjan", lat: 5.3827, lng: -3.9654 },
      { name: "Serge Bamba", email: "serge.bamba@gmail.com", phone: "0701234505", address: "Marcory Zone 4, Abidjan", lat: 5.2984, lng: -3.9878 },
      { name: "Fatou Diallo", email: "fatou.diallo@gmail.com", phone: "0701234506", address: "Adjamé Liberté, Abidjan", lat: 5.3699, lng: -4.0194 },
      { name: "Jean-Paul Kra", email: "jp.kra@outlook.com", phone: "0701234507", address: "Treichville, Abidjan", lat: 5.2908, lng: -4.0062 },
      { name: "Aminata Ouattara", email: "aminata.o@gmail.com", phone: "0701234508", address: "Deux Plateaux Vallon, Cocody, Abidjan", lat: 5.3755, lng: -3.9882 },
      { name: "Yves Zoro", email: "yves.zoro@gmail.com", phone: "0701234509", address: "Port-Bouët, Abidjan", lat: 5.2545, lng: -3.9466 },
      { name: "Nathalie Assi", email: "nathalie.assi@gmail.com", phone: "0701234510", address: "Bingerville, Abidjan", lat: 5.3585, lng: -3.8847 },
      { name: "Issiaka Sangaré", email: "issiaka.sangare@gmail.com", phone: "0701234511", address: "Abobo, Abidjan", lat: 5.4188, lng: -4.0234 },
      { name: "Claire Mensah", email: "claire.mensah@yahoo.fr", phone: "0701234512", address: "Angré, Cocody, Abidjan", lat: 5.3921, lng: -3.9761 },
    ];

    // Insérer les clients (en évitant les doublons par email)
    const clientIds: string[] = [];
    for (const c of clientsData) {
      const existing = await ctx.db
        .query("users")
        .withIndex("by_email", (q) => q.eq("email", c.email))
        .unique();
      if (existing) {
        clientIds.push(existing._id as string);
      } else {
        const id = await ctx.db.insert("users", {
          name: c.name,
          email: c.email,
          phone: c.phone,
          role: "client",
          isActive: true,
          onboardingCompleted: true,
          preferredLanguage: "fr",
          defaultAddress: c.address,
          defaultLatitude: c.lat,
          defaultLongitude: c.lng,
          createdAt: now - Math.floor(Math.random() * 60) * DAY,
          lastLoginAt: now - Math.floor(Math.random() * 3) * DAY,
        });
        clientIds.push(id as string);
      }
    }

    // ─── 2. COMMANDES ────────────────────────────────────────────────────────

    // Helper pour construire des items de commande
    const pickItems = (items: typeof menuItems, count: number) => {
      const shuffled = [...items].sort(() => Math.random() - 0.5);
      return shuffled.slice(0, count);
    };

    const paymentMethods = ["mobile_money", "cash", "card"] as const;
    const deliveredStatuses = ["delivered"] as const;
    const activeStatuses = ["confirmed", "preparing", "ready"] as const;
    const otherStatuses = ["pending", "cancelled"] as const;

    // ~55 commandes réparties sur 60 jours
    const orderConfigs = [
      // ── Commandes livrées (40) ────────────────────────────────────────────
      ...Array.from({ length: 40 }, (_, i) => ({
        clientIdx: i % clientIds.length,
        status: "delivered" as const,
        paymentStatus: "paid" as const,
        daysAgo: Math.floor(Math.random() * 55) + 1,
        itemCount: Math.floor(Math.random() * 3) + 1,
        withReview: i < 32, // 32 commandes ont un avis
      })),
      // ── En cours (8) ─────────────────────────────────────────────────────
      { clientIdx: 0, status: "preparing" as const, paymentStatus: "paid" as const, daysAgo: 0, itemCount: 2, withReview: false },
      { clientIdx: 1, status: "confirmed" as const, paymentStatus: "paid" as const, daysAgo: 0, itemCount: 1, withReview: false },
      { clientIdx: 2, status: "ready" as const, paymentStatus: "paid" as const, daysAgo: 0, itemCount: 3, withReview: false },
      { clientIdx: 3, status: "preparing" as const, paymentStatus: "paid" as const, daysAgo: 0, itemCount: 2, withReview: false },
      { clientIdx: 4, status: "confirmed" as const, paymentStatus: "paid" as const, daysAgo: 0, itemCount: 1, withReview: false },
      { clientIdx: 5, status: "pending" as const, paymentStatus: "pending" as const, daysAgo: 0, itemCount: 2, withReview: false },
      { clientIdx: 6, status: "preparing" as const, paymentStatus: "paid" as const, daysAgo: 0, itemCount: 1, withReview: false },
      { clientIdx: 7, status: "ready" as const, paymentStatus: "paid" as const, daysAgo: 0, itemCount: 2, withReview: false },
      // ── Annulées (7) ─────────────────────────────────────────────────────
      ...Array.from({ length: 7 }, (_, i) => ({
        clientIdx: i % clientIds.length,
        status: "cancelled" as const,
        paymentStatus: "refunded" as const,
        daysAgo: Math.floor(Math.random() * 30) + 2,
        itemCount: 1,
        withReview: false,
      })),
    ];

    const orderItemCounts: Record<string, number> = {}; // menuItemId → nb commandes
    const orderRatings: Record<string, number[]> = {};   // menuItemId → liste notes
    let ordersCreated = 0;
    let reviewsCreated = 0;

    const comments = [
      "Excellent ! La livraison était rapide et la nourriture encore chaude.",
      "Très bon plat, je recommande vivement. Je reviendrai !",
      "Saveurs authentiques, on se croirait dans une vraie cuisine africaine.",
      "Plat copieux et bien épicé. Parfait pour un repas en famille.",
      "La viande était tendre et bien marinée. Très satisfait.",
      "Commande conforme à la description. Bon rapport qualité-prix.",
      "Délicieux ! Le kedjenou est le meilleur que j'ai mangé à Abidjan.",
      "Service rapide et plats chauds. Je suis conquis !",
      "L'attiéké était frais et le poisson bien grillé. Top !",
      "Bon repas mais la livraison a pris un peu de temps.",
      "Super bon ! Mes enfants ont adoré. On commande chaque semaine.",
      "La sauce était onctueuse et bien relevée. Très bon.",
      "Poulet bien grillé avec un goût fumé authentique. Parfait.",
      "Bonne qualité générale. Je recommande le foutou sauce graine.",
      "Plat généreux, bien préparé. La portion était très grande !",
    ];

    for (const cfg of orderConfigs) {
      const clientId = clientIds[cfg.clientIdx];
      const client = clientsData[cfg.clientIdx];

      // Choisir des plats au hasard (favoriser plats principaux)
      const allItems = menuItems.filter(m => m.category !== "Boissons");
      const drinks = menuItems.filter(m => m.category === "Boissons");
      const mainItems = pickItems(allItems, Math.min(cfg.itemCount, allItems.length));
      // Ajouter une boisson 60% du temps
      if (drinks.length > 0 && Math.random() > 0.4) {
        mainItems.push(drinks[Math.floor(Math.random() * drinks.length)]);
      }

      const items = mainItems.map(m => ({
        menuItemId: m._id,
        name: m.name as string,
        quantity: Math.random() > 0.7 ? 2 : 1,
        unitPrice: m.price as number,
        imageUrl: m.imageUrl as string | undefined,
      }));

      const subtotal = items.reduce((s, i) => s + i.unitPrice * i.quantity, 0);
      const deliveryFee = 1000;
      const serviceFee = Math.round(subtotal * 0.02);
      const total = subtotal + deliveryFee + serviceFee;

      const createdAt = now - cfg.daysAgo * DAY - Math.floor(Math.random() * 12) * 3600000;
      const updatedAt = createdAt + Math.floor(Math.random() * 3) * 3600000;

      const orderId = await ctx.db.insert("orders", {
        clientId: clientId as any,
        restaurantId,
        items,
        subtotal,
        deliveryFee,
        serviceFee,
        total,
        deliveryAddress: client.address,
        deliveryLatitude: client.lat + (Math.random() - 0.5) * 0.01,
        deliveryLongitude: client.lng + (Math.random() - 0.5) * 0.01,
        status: cfg.status,
        paymentMethod: paymentMethods[Math.floor(Math.random() * paymentMethods.length)],
        paymentStatus: cfg.paymentStatus,
        clientName: client.name,
        clientPhone: client.phone,
        createdAt,
        updatedAt,
      });

      ordersCreated++;

      // Compter les items pour orderCount
      for (const item of items) {
        const key = item.menuItemId.toString();
        orderItemCounts[key] = (orderItemCounts[key] || 0) + item.quantity;
      }

      // ── Review pour les commandes livrées ──────────────────────────────────
      if (cfg.status === "delivered" && cfg.withReview) {
        // Note entre 3.5 et 5.0, biaisée vers le haut
        const rating = parseFloat((3.5 + Math.random() * 1.5).toFixed(1));
        const comment = Math.random() > 0.3
          ? comments[Math.floor(Math.random() * comments.length)]
          : undefined;

        await ctx.db.insert("reviews", {
          orderId,
          clientId: clientId as any,
          restaurantId,
          rating,
          comment,
          createdAt: updatedAt + 3600000,
        });

        reviewsCreated++;

        // Accumuler les notes pour les plats commandés
        for (const item of items) {
          const key = item.menuItemId.toString();
          if (!orderRatings[key]) orderRatings[key] = [];
          orderRatings[key].push(rating);
        }
      }
    }

    // ─── 3. MISE À JOUR orderCount + rating des plats ────────────────────────
    for (const menuItem of menuItems) {
      const key = (menuItem._id as any).toString();
      const count = orderItemCounts[key] || 0;
      const ratings = orderRatings[key] || [];
      const avgRating = ratings.length > 0
        ? parseFloat((ratings.reduce((a, b) => a + b, 0) / ratings.length).toFixed(1))
        : menuItem.rating as number;

      await ctx.db.patch(menuItem._id, {
        orderCount: ((menuItem.orderCount as number) || 0) + count,
        rating: avgRating,
        totalRatings: ((menuItem.totalRatings as number) || 0) + ratings.length,
      });
    }

    // ─── 4. MISE À JOUR rating du restaurant ─────────────────────────────────
    const allReviews = await ctx.db
      .query("reviews")
      .withIndex("by_restaurant", (q) => q.eq("restaurantId", restaurantId))
      .collect();

    if (allReviews.length > 0) {
      const avgRestaurantRating = parseFloat(
        (allReviews.reduce((s, r) => s + (r.rating as number), 0) / allReviews.length).toFixed(1)
      );
      await ctx.db.patch(restaurantId, {
        rating: avgRestaurantRating,
        totalRatings: allReviews.length,
      });
    }

    return {
      message: `✅ Seed terminé pour Chef Amara`,
      clients: clientIds.length,
      orders: ordersCreated,
      reviews: reviewsCreated,
      plats_mis_a_jour: menuItems.length,
    };
  },
});
