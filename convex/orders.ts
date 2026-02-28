import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import {
  requireUser,
  requireRole,
  requireRoleWithToken,
  NotFoundError,
  ValidationError,
} from "./helpers/errors";
import { validateTransition } from "./orderStateMachine";
import { internal } from "./_generated/api";

// ============ QUERIES ============

/** Mes commandes (client) */
export const myOrders = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    return await ctx.db
      .query("orders")
      .withIndex("by_client", (q) => q.eq("clientId", user._id))
      .order("desc")
      .collect();
  },
});

/** Commandes d'un restaurant */
export const byRestaurant = query({
  args: { restaurantId: v.id("restaurants"), token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);

    // Vérifier que l'utilisateur est propriétaire ou admin/support
    if (
      user.role !== "admin" &&
      user.role !== "support" &&
      user.role !== "ops"
    ) {
      const restaurant = await ctx.db.get(args.restaurantId);
      if (!restaurant || restaurant.ownerId !== user._id) {
        throw new Error("Accès non autorisé aux commandes de ce restaurant");
      }
    }

    return await ctx.db
      .query("orders")
      .withIndex("by_restaurant", (q) =>
        q.eq("restaurantId", args.restaurantId)
      )
      .order("desc")
      .collect();
  },
});

/** Commandes par statut (admin/support/ops) */
export const byStatus = query({
  args: {
    token: v.optional(v.string()),
    status: v.union(
      v.literal("pending"),
      v.literal("confirmed"),
      v.literal("preparing"),
      v.literal("ready"),
      v.literal("picked_up"),
      v.literal("delivering"),
      v.literal("delivered"),
      v.literal("cancelled")
    ),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "support", "ops", "finance");
    return await ctx.db
      .query("orders")
      .withIndex("by_status", (q) => q.eq("status", args.status))
      .order("desc")
      .collect();
  },
});

/** Commandes du livreur connecté */
export const myDeliveries = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");
    return await ctx.db
      .query("orders")
      .withIndex("by_livreur", (q) => q.eq("livreurId", user._id))
      .order("desc")
      .collect();
  },
});

/** Détail d'une commande */
export const getById = query({
  args: { orderId: v.id("orders"), token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    const order = await ctx.db.get(args.orderId);
    if (!order) throw new NotFoundError("Commande");

    // Vérifier l'accès
    const isClient = order.clientId === user._id;
    const isLivreur = order.livreurId === user._id;
    const isAdmin = ["admin", "support", "ops", "finance"].includes(user.role);

    if (!isClient && !isLivreur && !isAdmin) {
      // Vérifier si c'est le restaurateur
      const restaurant = await ctx.db.get(order.restaurantId);
      if (!restaurant || restaurant.ownerId !== user._id) {
        throw new Error("Accès non autorisé à cette commande");
      }
    }

    return order;
  },
});

// ============ MUTATIONS ============

/** Créer une commande (client) */
export const create = mutation({
  args: {
    restaurantId: v.id("restaurants"),
    items: v.array(
      v.object({
        menuItemId: v.id("menuItems"),
        name: v.string(),
        quantity: v.number(),
        unitPrice: v.number(),
        imageUrl: v.optional(v.string()),
      })
    ),
    deliveryAddress: v.string(),
    deliveryLatitude: v.number(),
    deliveryLongitude: v.number(),
    paymentMethod: v.union(
      v.literal("mobile_money"),
      v.literal("card"),
      v.literal("cash")
    ),
    clientNote: v.optional(v.string()),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "client", "admin");

    const restaurant = await ctx.db.get(args.restaurantId);
    if (!restaurant) throw new NotFoundError("Restaurant");
    if (!restaurant.isOpen) throw new Error("Ce restaurant est fermé");

    // Calculer le subtotal
    const subtotal = args.items.reduce(
      (sum, item) => sum + item.unitPrice * item.quantity,
      0
    );

    // Lire les frais de service depuis les règles métier (pas hardcodé !)
    const serviceFeeRule = await ctx.db
      .query("businessRules")
      .withIndex("by_key", (q) => q.eq("key", "service_fee_percentage"))
      .unique();
    const serviceFeePercentage = serviceFeeRule
      ? Number(serviceFeeRule.value)
      : 5;
    const serviceFee = Math.round(subtotal * (serviceFeePercentage / 100));

    // Lire le montant minimum de commande
    const minOrderRule = await ctx.db
      .query("businessRules")
      .withIndex("by_key", (q) => q.eq("key", "min_order_amount_fcfa"))
      .unique();
    const minOrderAmount = minOrderRule ? Number(minOrderRule.value) : 1000;

    if (subtotal < minOrderAmount) {
      throw new ValidationError(
        "subtotal",
        `Le montant minimum de commande est ${minOrderAmount} FCFA`
      );
    }

    const total = subtotal + restaurant.deliveryFee + serviceFee;
    const now = Date.now();

    const orderId = await ctx.db.insert("orders", {
      clientId: user._id,
      restaurantId: args.restaurantId,
      items: args.items,
      subtotal,
      deliveryFee: restaurant.deliveryFee,
      serviceFee,
      total,
      deliveryAddress: args.deliveryAddress,
      deliveryLatitude: args.deliveryLatitude,
      deliveryLongitude: args.deliveryLongitude,
      status: "pending",
      paymentMethod: args.paymentMethod,
      paymentStatus: "pending",
      clientName: user.name,
      clientPhone: user.phone,
      clientNote: args.clientNote,
      createdAt: now,
      updatedAt: now,
    });

    // Enregistrer la première transition dans l'historique
    await ctx.scheduler.runAfter(
      0,
      internal.orderStateMachine.recordTransition,
      {
        orderId,
        fromStatus: "new",
        toStatus: "pending",
        triggeredBy: user._id,
        triggeredByRole: user.role,
      }
    );

    return orderId;
  },
});

/** Mettre à jour le statut d'une commande (avec validation state machine) */
export const updateStatus = mutation({
  args: {
    orderId: v.id("orders"),
    status: v.union(
      v.literal("confirmed"),
      v.literal("preparing"),
      v.literal("ready"),
      v.literal("picked_up"),
      v.literal("delivering"),
      v.literal("delivered"),
      v.literal("cancelled")
    ),
    reason: v.optional(v.string()),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    const order = await ctx.db.get(args.orderId);
    if (!order) throw new NotFoundError("Commande");

    // Valider la transition via la state machine
    validateTransition(order.status, args.status, user.role);

    const now = Date.now();

    await ctx.db.patch(args.orderId, {
      status: args.status,
      updatedAt: now,
    });

    // Incrémenter orderCount de chaque plat quand la commande est livrée
    if (args.status === "delivered") {
      const seen = new Set<string>();
      for (const item of order.items) {
        const mid = (item as any).menuItemId;
        if (!mid || seen.has(mid)) continue;
        seen.add(mid);
        const menuItem = await ctx.db.get(mid);
        if (menuItem) {
          await ctx.db.patch(mid, {
            orderCount: ((menuItem as any).orderCount ?? 0) + 1,
          });
        }
      }
    }

    // Enregistrer la transition
    await ctx.scheduler.runAfter(
      0,
      internal.orderStateMachine.recordTransition,
      {
        orderId: args.orderId,
        fromStatus: order.status,
        toStatus: args.status,
        triggeredBy: user._id,
        triggeredByRole: user.role,
        reason: args.reason,
      }
    );

    // Audit log
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: user._id,
      action: `order_${args.status}`,
      resource: "orders",
      resourceId: args.orderId,
      details: JSON.stringify({
        from: order.status,
        to: args.status,
        reason: args.reason,
      }),
    });

    // Auto-dispatch : quand la commande passe à "ready", chercher un livreur
    if (args.status === "ready") {
      await ctx.scheduler.runAfter(
        2_000,
        internal.autoDispatch.findAndDispatch,
        {
          orderId: args.orderId,
          excludeDriverIds: [],
          attempt: 1,
        }
      );
    }
  },
});

/** Relancer manuellement le dispatch pour une commande "ready" (debug/admin) */
export const retriggerDispatch = mutation({
  args: { orderId: v.id("orders") },
  handler: async (ctx, args) => {
    const order = await ctx.db.get(args.orderId);
    if (!order) throw new Error("Commande introuvable");
    if (order.status !== "ready") throw new Error("La commande n'est pas en statut ready");
    await ctx.scheduler.runAfter(
      0,
      internal.autoDispatch.findAndDispatch,
      {
        orderId: args.orderId,
        excludeDriverIds: [],
        attempt: 1,
      }
    );
  },
});

/** Assigner un livreur (admin ou système) */
export const assignLivreur = mutation({
  args: {
    token: v.optional(v.string()),
    orderId: v.id("orders"),
    livreurId: v.id("users"),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops");
    const order = await ctx.db.get(args.orderId);
    if (!order) throw new NotFoundError("Commande");

    await ctx.db.patch(args.orderId, {
      livreurId: args.livreurId,
      updatedAt: Date.now(),
    });
  },
});
