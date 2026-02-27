import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { requireUser } from "./helpers/errors";

/**
 * Système d'avis — le client note le restaurant (1-5) et optionnellement le livreur.
 * Après soumission, la moyenne du restaurant et du livreur est recalculée.
 */

/** Soumettre un avis après livraison */
export const submit = mutation({
  args: {
    orderId: v.id("orders"),
    rating: v.number(), // 1-5 restaurant
    driverRating: v.optional(v.number()), // 1-5 livreur
    comment: v.optional(v.string()),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);

    // Vérifier la commande
    const order = await ctx.db.get(args.orderId);
    if (!order) throw new Error("Commande introuvable");
    if (order.clientId !== user._id) throw new Error("Ce n'est pas votre commande");
    if (order.status !== "delivered") throw new Error("La commande n'est pas encore livrée");

    // Vérifier qu'il n'y a pas déjà un avis
    const existing = await ctx.db
      .query("reviews")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .unique();
    if (existing) throw new Error("Vous avez déjà noté cette commande");

    // Valider les notes
    if (args.rating < 1 || args.rating > 5) throw new Error("Note restaurant entre 1 et 5");
    if (args.driverRating !== undefined && (args.driverRating < 1 || args.driverRating > 5)) {
      throw new Error("Note livreur entre 1 et 5");
    }

    // Créer l'avis
    const reviewId = await ctx.db.insert("reviews", {
      orderId: args.orderId,
      clientId: user._id,
      restaurantId: order.restaurantId,
      livreurId: order.livreurId,
      rating: Math.round(args.rating),
      driverRating: args.driverRating !== undefined ? Math.round(args.driverRating) : undefined,
      comment: args.comment?.trim() || undefined,
      createdAt: Date.now(),
    });

    // Mettre à jour la note de chaque plat commandé
    const seenItems = new Set<string>();
    for (const item of order.items) {
      const mid = (item as any).menuItemId;
      if (!mid || seenItems.has(mid)) continue;
      seenItems.add(mid);
      const menuItem = await ctx.db.get(mid);
      if (menuItem) {
        const oldRating = (menuItem as any).rating ?? 0;
        const oldCount = (menuItem as any).totalRatings ?? 0;
        const newAvg = oldCount === 0
          ? Math.round(args.rating)
          : (oldRating * oldCount + Math.round(args.rating)) / (oldCount + 1);
        await ctx.db.patch(mid, {
          rating: Math.round(newAvg * 10) / 10,
          totalRatings: oldCount + 1,
        });
      }
    }

    // Recalculer la moyenne du restaurant
    const restaurantReviews = await ctx.db
      .query("reviews")
      .withIndex("by_restaurant", (q) => q.eq("restaurantId", order.restaurantId))
      .collect();
    const avgRestaurant =
      restaurantReviews.reduce((sum, r) => sum + r.rating, 0) / restaurantReviews.length;
    await ctx.db.patch(order.restaurantId, {
      rating: Math.round(avgRestaurant * 10) / 10, // 1 décimale
      totalRatings: restaurantReviews.length,
    });

    // Recalculer la moyenne du livreur (si noté et livreur existe)
    if (args.driverRating !== undefined && order.livreurId) {
      const driverReviews = await ctx.db
        .query("reviews")
        .withIndex("by_driver", (q) => q.eq("livreurId", order.livreurId))
        .collect();
      const ratedReviews = driverReviews.filter((r) => r.driverRating !== undefined);
      if (ratedReviews.length > 0) {
        const avgDriver =
          ratedReviews.reduce((sum, r) => sum + (r.driverRating ?? 0), 0) / ratedReviews.length;
        // Mettre à jour le driverProfile
        const driverProfile = await ctx.db
          .query("driverProfiles")
          .withIndex("by_user", (q) => q.eq("userId", order.livreurId!))
          .unique();
        if (driverProfile) {
          await ctx.db.patch(driverProfile._id, {
            rating: Math.round(avgDriver * 10) / 10,
          });
        }
      }
    }

    return { reviewId };
  },
});

/** Vérifier si une commande a déjà un avis */
export const hasReview = query({
  args: {
    orderId: v.id("orders"),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requireUser(ctx, args.token);
    const review = await ctx.db
      .query("reviews")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .unique();
    return review !== null;
  },
});

/** Avis d'un restaurant (pour affichage côté client) */
export const byRestaurant = query({
  args: {
    restaurantId: v.id("restaurants"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const reviews = await ctx.db
      .query("reviews")
      .withIndex("by_restaurant", (q) => q.eq("restaurantId", args.restaurantId))
      .order("desc")
      .take(args.limit ?? 20);

    // Enrichir avec le nom du client
    const enriched = [];
    for (const review of reviews) {
      const client = await ctx.db.get(review.clientId);
      enriched.push({
        ...review,
        clientName: client?.name ?? "Client",
      });
    }
    return enriched;
  },
});

/** Avis reçus par un livreur */
export const byDriver = query({
  args: {
    livreurId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const reviews = await ctx.db
      .query("reviews")
      .withIndex("by_driver", (q) => q.eq("livreurId", args.livreurId))
      .order("desc")
      .take(args.limit ?? 20);

    const enriched = [];
    for (const review of reviews) {
      const client = await ctx.db.get(review.clientId);
      enriched.push({
        ...review,
        clientName: client?.name ?? "Client",
      });
    }
    return enriched;
  },
});

/** Avis du restaurant du propriétaire (authentifié) */
export const myRestaurantReviews = query({
  args: {
    restaurantId: v.id("restaurants"),
    token: v.optional(v.string()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const reviews = await ctx.db
      .query("reviews")
      .withIndex("by_restaurant", (q) => q.eq("restaurantId", args.restaurantId))
      .order("desc")
      .take(args.limit ?? 20);

    const enriched = [];
    for (const review of reviews) {
      const client = await ctx.db.get(review.clientId);
      const order = await ctx.db.get(review.orderId);
      enriched.push({
        ...review,
        clientName: client?.name ?? "Client",
        orderShortId: order ? `#${String(order._id).slice(-4).toUpperCase()}` : "#???",
      });
    }
    return enriched;
  },
});

/** Avis reçus par le livreur connecté */
export const myDriverReviews = query({
  args: {
    token: v.optional(v.string()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);

    const reviews = await ctx.db
      .query("reviews")
      .withIndex("by_driver", (q) => q.eq("livreurId", user._id))
      .order("desc")
      .take(args.limit ?? 20);

    const enriched = [];
    for (const review of reviews) {
      const client = await ctx.db.get(review.clientId);
      enriched.push({
        ...review,
        clientName: client?.name ?? "Client",
      });
    }
    return enriched;
  },
});
