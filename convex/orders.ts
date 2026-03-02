import { v } from "convex/values";
import { mutation, query, internalMutation } from "./_generated/server";
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
    deliveryAddress: v.optional(v.string()),
    deliveryLatitude: v.optional(v.number()),
    deliveryLongitude: v.optional(v.number()),
    paymentMethod: v.union(
      v.literal("mobile_money"),
      v.literal("card"),
      v.literal("cash")
    ),
    clientNote: v.optional(v.string()),
    orderType: v.optional(v.union(v.literal("delivery"), v.literal("pickup"))),
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

    const isPickup = args.orderType === "pickup";
    const deliveryFee = isPickup ? 0 : restaurant.deliveryFee;
    const total = subtotal + deliveryFee + serviceFee;
    const now = Date.now();

    // Pour pickup : utiliser l'adresse et les coordonnées du restaurant
    const deliveryAddress = isPickup
      ? (restaurant as any).address ?? "À emporter"
      : (args.deliveryAddress ?? "");
    const deliveryLatitude = isPickup
      ? (restaurant as any).latitude ?? 5.3484
      : (args.deliveryLatitude ?? 5.3484);
    const deliveryLongitude = isPickup
      ? (restaurant as any).longitude ?? -4.0083
      : (args.deliveryLongitude ?? -4.0083);

    const orderId = await ctx.db.insert("orders", {
      clientId: user._id,
      restaurantId: args.restaurantId,
      orderType: args.orderType ?? "delivery",
      items: args.items,
      subtotal,
      deliveryFee,
      serviceFee,
      total,
      deliveryAddress,
      deliveryLatitude,
      deliveryLongitude,
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

    // Notification client : commande envoyée
    await ctx.scheduler.runAfter(0, internal.notifications.createInternal, {
      userId: user._id,
      title: "Commande envoyee",
      message: "Votre commande a ete envoyee au restaurant. En attente de confirmation.",
      type: "order_update" as const,
    });

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

    // Garde pickup : empêcher restaurant/client de faire picked_up/delivered sur une commande delivery
    if ((args.status === "picked_up" || args.status === "delivered") &&
        (user.role === "restaurant" || user.role === "client")) {
      const orderType = (order as any).orderType
        ?? (order.deliveryAddress === "À emporter" ? "pickup" : "delivery");
      if (orderType !== "pickup") {
        throw new Error("Seul le livreur peut gérer cette transition pour une commande en livraison");
      }
      // Vérifier que le client ne modifie que SA propre commande
      if (user.role === "client" && order.clientId !== user._id) {
        throw new Error("Vous ne pouvez modifier que vos propres commandes");
      }
    }

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

    // Notification client : changement de statut
    const statusNotifs: Record<string, { title: string; message: string }> = {
      confirmed: { title: "Commande confirmee", message: "Votre commande a ete acceptee par le restaurant." },
      preparing: { title: "En preparation", message: "Le restaurant prepare votre commande." },
      ready: { title: "Commande prete", message: "Votre commande est prete !" },
      picked_up: { title: "Commande recuperee", message: "Le livreur a recupere votre commande." },
      delivering: { title: "En livraison", message: "Votre commande est en route vers vous !" },
      delivered: { title: "Commande livree", message: "Votre commande a ete livree. Bon appetit !" },
      cancelled: { title: "Commande annulee", message: args.reason ?? "Votre commande a ete annulee." },
    };
    const notifContent = statusNotifs[args.status];
    if (notifContent) {
      await ctx.scheduler.runAfter(0, internal.notifications.createInternal, {
        userId: order.clientId,
        title: notifContent.title,
        message: notifContent.message,
        type: "order_update" as const,
      });
    }

    // Auto-dispatch : uniquement pour les commandes en livraison
    if (args.status === "ready") {
      const orderType = (order as any).orderType
        ?? (order.deliveryAddress === "À emporter" ? "pickup" : "delivery");
      if (orderType !== "pickup") {
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
    }

    // Auto-delivered : quand une commande pickup passe à picked_up, la finaliser après 2s
    if (args.status === "picked_up") {
      const orderType = (order as any).orderType
        ?? (order.deliveryAddress === "À emporter" ? "pickup" : "delivery");
      if (orderType === "pickup") {
        await ctx.scheduler.runAfter(
          2_000,
          internal.orders.autoCompletePickup,
          { orderId: args.orderId }
        );
      }
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

/** Auto-compléter une commande pickup après picked_up */
export const autoCompletePickup = internalMutation({
  args: { orderId: v.id("orders") },
  handler: async (ctx, args) => {
    const order = await ctx.db.get(args.orderId);
    if (!order) return;
    if (order.status !== "picked_up") return;
    const orderType = (order as any).orderType
      ?? (order.deliveryAddress === "À emporter" ? "pickup" : "delivery");
    if (orderType !== "pickup") return;

    const now = Date.now();
    await ctx.db.patch(args.orderId, {
      status: "delivered",
      updatedAt: now,
    });

    // Incrémenter orderCount de chaque plat
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

    // Enregistrer la transition
    await ctx.scheduler.runAfter(0, internal.orderStateMachine.recordTransition, {
      orderId: args.orderId,
      fromStatus: "picked_up",
      toStatus: "delivered",
      triggeredByRole: "system",
      reason: "Auto-completed pickup order",
    });
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
