import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import {
  requireRoleWithToken,
  NotFoundError,
} from "./helpers/errors";

// ============ QUERIES ============

/** Récupérer les demandes de dispatch en attente pour le livreur connecté */
export const pendingForDriver = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const requests = await ctx.db
      .query("dispatchRequests")
      .withIndex("by_driver", (q) => q.eq("driverId", user._id))
      .collect();

    // Filtrer les pending non expirés
    const now = Date.now();
    const pending = requests.filter(
      (r) => r.status === "pending" && r.expiresAt > now
    );

    // Enrichir avec les détails de la commande
    const enriched = await Promise.all(
      pending.map(async (r) => {
        const order = await ctx.db.get(r.orderId);
        if (!order) return null;

        const restaurant = await ctx.db.get(order.restaurantId);

        return {
          ...r,
          order: {
            _id: order._id,
            restaurantName: restaurant?.name ?? "Restaurant",
            restaurantAddress: restaurant?.address ?? "",
            restaurantLatitude: restaurant?.latitude ?? 0,
            restaurantLongitude: restaurant?.longitude ?? 0,
            deliveryAddress: order.deliveryAddress,
            deliveryLatitude: order.deliveryLatitude,
            deliveryLongitude: order.deliveryLongitude,
            total: order.total,
            deliveryFee: order.deliveryFee,
            itemCount: order.items.length,
            items: order.items,
          },
        };
      })
    );

    return enriched.filter(Boolean);
  },
});

/** Récupérer l'historique des dispatch du livreur */
export const myDispatchHistory = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    return await ctx.db
      .query("dispatchRequests")
      .withIndex("by_driver", (q) => q.eq("driverId", user._id))
      .order("desc")
      .collect();
  },
});

// ============ MUTATIONS ============

/** Créer une demande de dispatch (admin/ops/système) */
export const createDispatch = mutation({
  args: {
    orderId: v.id("orders"),
    driverId: v.id("users"),
    expiresInSeconds: v.optional(v.number()),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    // Vérifier que le livreur existe et est en ligne
    const driver = await ctx.db.get(args.driverId);
    if (!driver || driver.role !== "livreur") {
      throw new Error("Livreur non trouvé");
    }

    const driverProfile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", args.driverId))
      .unique();

    if (!driverProfile || !driverProfile.isOnline) {
      throw new Error("Le livreur n'est pas en ligne");
    }

    // Vérifier que la commande existe et est au bon statut
    const order = await ctx.db.get(args.orderId);
    if (!order) throw new NotFoundError("Commande");
    if (order.status !== "ready" && order.status !== "confirmed" && order.status !== "preparing") {
      throw new Error("La commande n'est pas prête pour le dispatch");
    }

    // Vérifier qu'il n'y a pas déjà un dispatch pending pour cette commande
    const existingForOrder = await ctx.db
      .query("dispatchRequests")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .collect();
    const hasPending = existingForOrder.some(
      (r) => r.status === "pending" && r.expiresAt > Date.now()
    );
    if (hasPending) {
      throw new Error("Un dispatch est déjà en cours pour cette commande");
    }

    const expiresIn = (args.expiresInSeconds ?? 60) * 1000; // défaut 60s

    const dispatchId = await ctx.db.insert("dispatchRequests", {
      orderId: args.orderId,
      driverId: args.driverId,
      status: "pending",
      requestedAt: Date.now(),
      expiresAt: Date.now() + expiresIn,
    });

    return dispatchId;
  },
});

/** Accepter une demande de dispatch */
export const acceptDispatch = mutation({
  args: {
    dispatchId: v.id("dispatchRequests"),
    token: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const dispatch = await ctx.db.get(args.dispatchId);
    if (!dispatch) throw new NotFoundError("Demande de dispatch");

    // Vérifier que c'est bien le bon livreur
    if (dispatch.driverId !== user._id) {
      throw new Error("Cette demande ne vous est pas destinée");
    }

    // Vérifier le statut
    if (dispatch.status !== "pending") {
      throw new Error("Cette demande n'est plus en attente");
    }

    // Vérifier l'expiration
    if (dispatch.expiresAt < Date.now()) {
      await ctx.db.patch(args.dispatchId, {
        status: "expired",
        respondedAt: Date.now(),
      });
      throw new Error("Cette demande a expiré");
    }

    // Accepter le dispatch
    await ctx.db.patch(args.dispatchId, {
      status: "accepted",
      respondedAt: Date.now(),
    });

    // Assigner le livreur à la commande
    const order = await ctx.db.get(dispatch.orderId);
    if (order) {
      await ctx.db.patch(dispatch.orderId, {
        livreurId: user._id,
        updatedAt: Date.now(),
      });
    }

    // Refuser tous les autres dispatch pending pour cette commande
    const otherDispatches = await ctx.db
      .query("dispatchRequests")
      .withIndex("by_order", (q) => q.eq("orderId", dispatch.orderId))
      .collect();
    for (const other of otherDispatches) {
      if (other._id !== args.dispatchId && other.status === "pending") {
        await ctx.db.patch(other._id, {
          status: "refused",
          respondedAt: Date.now(),
        });
      }
    }

    return { orderId: dispatch.orderId };
  },
});

/** Refuser une demande de dispatch */
export const refuseDispatch = mutation({
  args: {
    dispatchId: v.id("dispatchRequests"),
    token: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const dispatch = await ctx.db.get(args.dispatchId);
    if (!dispatch) throw new NotFoundError("Demande de dispatch");

    if (dispatch.driverId !== user._id) {
      throw new Error("Cette demande ne vous est pas destinée");
    }

    if (dispatch.status !== "pending") {
      throw new Error("Cette demande n'est plus en attente");
    }

    await ctx.db.patch(args.dispatchId, {
      status: "refused",
      respondedAt: Date.now(),
    });

    return { success: true };
  },
});
