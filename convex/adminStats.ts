import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { requireRoleWithToken } from "./helpers/errors";
import { internal } from "./_generated/api";

/** KPIs agrégés pour le dashboard admin */
export const dashboardStats = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support", "finance");

    const now = Date.now();
    const todayStart = now - (now % 86_400_000); // début de journée UTC
    const weekStart = todayStart - 7 * 86_400_000;
    const monthStart = todayStart - 30 * 86_400_000;

    // Toutes les commandes
    const allOrders = await ctx.db.query("orders").collect();

    const todayOrders = allOrders.filter((o) => o.createdAt >= todayStart);
    const weekOrders = allOrders.filter((o) => o.createdAt >= weekStart);
    const monthOrders = allOrders.filter((o) => o.createdAt >= monthStart);

    // Revenus (commandes livrées uniquement)
    const todayRevenue = todayOrders
      .filter((o) => o.status === "delivered")
      .reduce((sum, o) => sum + o.total, 0);
    const weekRevenue = weekOrders
      .filter((o) => o.status === "delivered")
      .reduce((sum, o) => sum + o.total, 0);
    const monthRevenue = monthOrders
      .filter((o) => o.status === "delivered")
      .reduce((sum, o) => sum + o.total, 0);

    // Compteurs par statut
    const statusCounts: Record<string, number> = {};
    for (const o of allOrders) {
      statusCounts[o.status] = (statusCounts[o.status] ?? 0) + 1;
    }

    // Utilisateurs
    const allUsers = await ctx.db.query("users").collect();
    const totalClients = allUsers.filter((u) => u.role === "client").length;
    const totalRestaurants = allUsers.filter((u) => u.role === "restaurant").length;
    const totalDrivers = allUsers.filter((u) => u.role === "livreur").length;
    const totalStaff = allUsers.filter((u) =>
      ["admin", "support", "finance", "ops"].includes(u.role)
    ).length;

    // Livreurs en ligne
    const onlineDrivers = await ctx.db
      .query("driverProfiles")
      .withIndex("by_online", (q) => q.eq("isOnline", true))
      .collect();

    // Restaurants
    const allRestaurants = await ctx.db.query("restaurants").collect();
    const pendingVerification = allRestaurants.filter((r) => !r.isVerified).length;
    const openRestaurants = allRestaurants.filter((r) => r.isOpen).length;

    return {
      orders: {
        today: todayOrders.length,
        week: weekOrders.length,
        month: monthOrders.length,
        total: allOrders.length,
        statusCounts,
      },
      revenue: {
        today: todayRevenue,
        week: weekRevenue,
        month: monthRevenue,
      },
      users: {
        clients: totalClients,
        restaurants: totalRestaurants,
        drivers: totalDrivers,
        staff: totalStaff,
        total: allUsers.length,
      },
      drivers: {
        online: onlineDrivers.length,
        total: totalDrivers,
      },
      restaurants: {
        total: allRestaurants.length,
        pendingVerification,
        open: openRestaurants,
      },
    };
  },
});

/** 10 dernières commandes enrichies (restaurant + client noms) */
export const recentOrders = query({
  args: {
    token: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support", "finance");

    const orders = await ctx.db
      .query("orders")
      .order("desc")
      .take(args.limit ?? 10);

    const enriched = await Promise.all(
      orders.map(async (order) => {
        const [restaurant, client, livreur] = await Promise.all([
          ctx.db.get(order.restaurantId),
          ctx.db.get(order.clientId),
          order.livreurId ? ctx.db.get(order.livreurId) : null,
        ]);

        return {
          ...order,
          restaurantName: restaurant?.name ?? "Restaurant inconnu",
          clientName: client?.name ?? "Client inconnu",
          clientPhone: client?.phone ?? "",
          livreurName: livreur?.name ?? null,
        };
      })
    );

    return enriched;
  },
});

/** Toutes les commandes avec filtre optionnel par statut (admin) */
export const allOrders = query({
  args: {
    token: v.string(),
    status: v.optional(
      v.union(
        v.literal("pending"),
        v.literal("confirmed"),
        v.literal("preparing"),
        v.literal("ready"),
        v.literal("picked_up"),
        v.literal("delivering"),
        v.literal("delivered"),
        v.literal("cancelled")
      )
    ),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support", "finance");

    let orders;
    if (args.status) {
      orders = await ctx.db
        .query("orders")
        .withIndex("by_status", (q) => q.eq("status", args.status!))
        .order("desc")
        .take(args.limit ?? 100);
    } else {
      orders = await ctx.db
        .query("orders")
        .order("desc")
        .take(args.limit ?? 100);
    }

    const enriched = await Promise.all(
      orders.map(async (order) => {
        const [restaurant, client, livreur] = await Promise.all([
          ctx.db.get(order.restaurantId),
          ctx.db.get(order.clientId),
          order.livreurId ? ctx.db.get(order.livreurId) : null,
        ]);
        return {
          ...order,
          restaurantName: restaurant?.name ?? "Restaurant inconnu",
          clientName: client?.name ?? "Client inconnu",
          livreurName: livreur?.name ?? null,
        };
      })
    );

    return enriched;
  },
});

/** Historique des transitions de statut d'une commande */
export const orderHistory = query({
  args: {
    token: v.string(),
    orderId: v.id("orders"),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support", "finance");

    const history = await ctx.db
      .query("orderStateHistory")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .order("asc")
      .collect();

    // Enrichir avec les noms des utilisateurs
    const enriched = await Promise.all(
      history.map(async (entry) => {
        let triggeredByName: string | null = null;
        if (entry.triggeredBy) {
          const user = await ctx.db.get(entry.triggeredBy);
          triggeredByName = user?.name ?? null;
        }
        return { ...entry, triggeredByName };
      })
    );

    return enriched;
  },
});

/** Tous les profils livreurs enrichis (admin) */
export const allDrivers = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support");

    const profiles = await ctx.db.query("driverProfiles").collect();

    const enriched = await Promise.all(
      profiles.map(async (profile) => {
        const user = await ctx.db.get(profile.userId);
        return {
          ...profile,
          name: user?.name ?? "Livreur inconnu",
          email: user?.email ?? "",
          phone: user?.phone ?? "",
          isActive: user?.isActive ?? false,
        };
      })
    );

    return enriched;
  },
});

/** Un seul livreur par userId (admin) */
export const driverById = query({
  args: { token: v.string(), userId: v.id("users") },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support");

    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .unique();

    if (!profile) return null;

    const user = await ctx.db.get(args.userId);
    return {
      ...profile,
      name: user?.name ?? "Livreur inconnu",
      email: user?.email ?? "",
      phone: user?.phone ?? "",
      isActive: user?.isActive ?? false,
    };
  },
});

/** Vérifier un livreur (admin) */
export const verifyDriver = mutation({
  args: {
    token: v.string(),
    userId: v.id("users"),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin", "ops");

    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .unique();

    if (!profile) throw new Error("Profil livreur non trouvé");

    await ctx.db.patch(profile._id, { isVerified: true });

    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "verify_driver",
      resource: "driverProfiles",
      resourceId: profile._id,
    });
  },
});
