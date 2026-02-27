import { v } from "convex/values";
import { internalMutation } from "./_generated/server";
import { internal } from "./_generated/api";

/**
 * Auto-dispatch : quand une commande passe à "ready",
 * cherche le livreur en ligne le plus proche et lui envoie un dispatch.
 *
 * Si le livreur refuse ou ne répond pas (expire), on passe au suivant
 * via retryAfterExpiry (déclenché par un scheduler après expiration).
 */

/** Distance Haversine en km entre deux points GPS */
function haversineKm(
  lat1: number, lon1: number,
  lat2: number, lon2: number
): number {
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

/** Trouver et envoyer un dispatch au meilleur livreur disponible */
export const findAndDispatch = internalMutation({
  args: {
    orderId: v.id("orders"),
    excludeDriverIds: v.optional(v.array(v.string())),
    attempt: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const order = await ctx.db.get(args.orderId);
    if (!order) return;

    // Ne dispatcher que si la commande est toujours "ready" et sans livreur
    if (order.status !== "ready" || order.livreurId) return;

    // Vérifier qu'il n'y a pas déjà un dispatch pending pour cette commande
    const existingDispatches = await ctx.db
      .query("dispatchRequests")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .collect();
    const hasPending = existingDispatches.some(
      (r) => r.status === "pending" && r.expiresAt > Date.now()
    );
    if (hasPending) return;

    const excludeIds = new Set(args.excludeDriverIds ?? []);
    const attempt = args.attempt ?? 1;

    // Max 5 tentatives
    if (attempt > 5) {
      console.log("[AutoDispatch] Max attempts reached for order", args.orderId);
      return;
    }

    // Récupérer tous les livreurs en ligne
    const onlineProfiles = await ctx.db
      .query("driverProfiles")
      .withIndex("by_online", (q) => q.eq("isOnline", true))
      .collect();

    // Récupérer le restaurant une seule fois
    const restaurant = await ctx.db.get(order.restaurantId);
    if (!restaurant) return;

    // Filtrer : pas exclus, pas déjà en livraison active, avec GPS, à moins de 10km
    const candidates = [];
    for (const profile of onlineProfiles) {
      if (excludeIds.has(profile.userId)) continue;

      // Vérifier que le livreur n'a pas déjà une commande active
      const activeOrders = await ctx.db
        .query("orders")
        .withIndex("by_livreur", (q) => q.eq("livreurId", profile.userId as any))
        .collect();
      const hasActive = activeOrders.some((o) =>
        ["ready", "picked_up", "delivering"].includes(o.status)
      );
      if (hasActive) continue;

      // Récupérer la position GPS du livreur
      const location = await ctx.db
        .query("livreurLocations")
        .withIndex("by_livreur", (q) => q.eq("livreurId", profile.userId))
        .unique();

      if (!location) continue;

      // Calculer la distance au restaurant
      const distance = haversineKm(
        location.latitude,
        location.longitude,
        restaurant.latitude,
        restaurant.longitude
      );

      // Max 10 km du restaurant
      if (distance > 10) continue;

      candidates.push({
        userId: profile.userId,
        distance,
        totalDeliveries: profile.totalDeliveries,
        rating: profile.rating ?? 0,
      });
    }

    if (candidates.length === 0) {
      console.log("[AutoDispatch] No drivers available, attempt", attempt, "— retrying in 30s");
      // Aucun livreur disponible, réessayer dans 30 secondes
      await ctx.scheduler.runAfter(
        30_000,
        internal.autoDispatch.findAndDispatch,
        {
          orderId: args.orderId,
          excludeDriverIds: [...excludeIds],
          attempt: attempt + 1,
        }
      );
      return;
    }

    // Trier par distance (plus proche d'abord), puis par note
    candidates.sort((a, b) => {
      if (a.distance !== b.distance) return a.distance - b.distance;
      return b.rating - a.rating;
    });

    const bestDriver = candidates[0];
    console.log("[AutoDispatch] Dispatching to", bestDriver.userId, "distance:", bestDriver.distance.toFixed(1), "km");

    // Créer le dispatch (60 secondes pour répondre)
    const expiresIn = 60_000;
    await ctx.db.insert("dispatchRequests", {
      orderId: args.orderId,
      driverId: bestDriver.userId as any,
      status: "pending",
      requestedAt: Date.now(),
      expiresAt: Date.now() + expiresIn,
    });

    // Programmer un retry si le dispatch expire (65s pour laisser le temps)
    const newExcludeIds = [...excludeIds, bestDriver.userId];
    await ctx.scheduler.runAfter(
      65_000,
      internal.autoDispatch.retryAfterExpiry,
      {
        orderId: args.orderId,
        excludeDriverIds: newExcludeIds,
        attempt: attempt + 1,
      }
    );
  },
});

/** Retry après expiration d'un dispatch — vérifie puis relance */
export const retryAfterExpiry = internalMutation({
  args: {
    orderId: v.id("orders"),
    excludeDriverIds: v.array(v.string()),
    attempt: v.number(),
  },
  handler: async (ctx, args) => {
    const order = await ctx.db.get(args.orderId);
    if (!order) return;

    // Abandonner si la commande n'est plus "ready" ou a déjà un livreur
    if (order.status !== "ready" || order.livreurId) return;

    // Marquer les dispatch expirés
    const dispatches = await ctx.db
      .query("dispatchRequests")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .collect();
    for (const d of dispatches) {
      if (d.status === "pending" && d.expiresAt < Date.now()) {
        await ctx.db.patch(d._id, {
          status: "expired",
          respondedAt: Date.now(),
        });
      }
    }

    // Vérifier s'il y a encore un pending non expiré
    const stillPending = dispatches.some(
      (d) => d.status === "pending" && d.expiresAt > Date.now()
    );
    if (stillPending) return;

    // Relancer la recherche de livreur
    await ctx.scheduler.runAfter(
      0,
      internal.autoDispatch.findAndDispatch,
      {
        orderId: args.orderId,
        excludeDriverIds: args.excludeDriverIds,
        attempt: args.attempt,
      }
    );
  },
});
