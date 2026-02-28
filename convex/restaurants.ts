import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import {
  requireUser,
  requireRole,
  requireRoleWithToken,
  NotFoundError,
} from "./helpers/errors";
import { sanitizeString } from "./helpers/validators";

// ============ QUERIES ============

/** Lister les restaurants d'une ville (public) */
export const listByCity = query({
  args: { city: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("restaurants")
      .withIndex("by_city", (q) => q.eq("city", args.city))
      .collect();
  },
});

/** Récupérer un restaurant par ID (public) */
export const getById = query({
  args: { restaurantId: v.id("restaurants") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.restaurantId);
  },
});

/** Mes restaurants (propriétaire) */
export const myRestaurants = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    return await ctx.db
      .query("restaurants")
      .withIndex("by_owner", (q) => q.eq("ownerId", user._id))
      .collect();
  },
});

/** Tous les restaurants (admin/ops) */
export const listAll = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops");
    return await ctx.db.query("restaurants").collect();
  },
});

/** Restaurants non vérifiés (admin/ops) */
export const pendingVerification = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops");
    return await ctx.db
      .query("restaurants")
      .filter((q) => q.eq(q.field("isVerified"), false))
      .collect();
  },
});

// ============ MUTATIONS ============

/** Créer un restaurant (role restaurant ou admin) */
export const create = mutation({
  args: {
    name: v.string(),
    description: v.string(),
    phone: v.optional(v.string()),
    imageUrl: v.optional(v.string()),
    coverImageUrl: v.optional(v.string()),
    address: v.string(),
    city: v.string(),
    country: v.string(),
    latitude: v.number(),
    longitude: v.number(),
    cuisineType: v.array(v.string()),
    openingHours: v.object({
      monday: v.optional(v.object({ open: v.string(), close: v.string() })),
      tuesday: v.optional(v.object({ open: v.string(), close: v.string() })),
      wednesday: v.optional(v.object({ open: v.string(), close: v.string() })),
      thursday: v.optional(v.object({ open: v.string(), close: v.string() })),
      friday: v.optional(v.object({ open: v.string(), close: v.string() })),
      saturday: v.optional(v.object({ open: v.string(), close: v.string() })),
      sunday: v.optional(v.object({ open: v.string(), close: v.string() })),
    }),
    deliveryFee: v.number(),
    minOrderAmount: v.number(),
    estimatedDeliveryTime: v.number(),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "restaurant", "admin");

    const { token: _token, ...restaurantArgs } = args;
    return await ctx.db.insert("restaurants", {
      ...restaurantArgs,
      name: sanitizeString(args.name, 100),
      description: sanitizeString(args.description, 500),
      ownerId: user._id,
      rating: undefined,
      totalRatings: 0,
      isOpen: false,
      isVerified: false,
      createdAt: Date.now(),
    });
  },
});

/** Mettre à jour le statut ouvert/fermé (propriétaire) */
export const toggleOpen = mutation({
  args: {
    restaurantId: v.id("restaurants"),
    isOpen: v.boolean(),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "restaurant", "admin");
    const restaurant = await ctx.db.get(args.restaurantId);
    if (!restaurant) throw new NotFoundError("Restaurant");

    // Vérifier la propriété (sauf admin)
    if (user.role !== "admin" && restaurant.ownerId !== user._id) {
      throw new Error("Vous n'êtes pas propriétaire de ce restaurant");
    }

    await ctx.db.patch(args.restaurantId, { isOpen: args.isOpen });
  },
});

/** Vérifier un restaurant (admin/ops ou via token admin) */
export const verify = mutation({
  args: { restaurantId: v.id("restaurants"), token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    if (args.token) {
      await requireRoleWithToken(ctx, args.token, "admin", "ops");
    } else {
      await requireRole(ctx, "admin", "ops");
    }
    const restaurant = await ctx.db.get(args.restaurantId);
    if (!restaurant) throw new NotFoundError("Restaurant");
    await ctx.db.patch(args.restaurantId, { isVerified: true });
  },
});

/** Vérification directe (dev uniquement — à supprimer en prod) */
export const verifyDirect = mutation({
  args: { restaurantId: v.id("restaurants") },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.restaurantId, { isVerified: true });
  },
});

/** Mettre à jour un restaurant (propriétaire) */
export const update = mutation({
  args: {
    restaurantId: v.id("restaurants"),
    name: v.optional(v.string()),
    description: v.optional(v.string()),
    phone: v.optional(v.string()),
    imageUrl: v.optional(v.string()),
    coverImageUrl: v.optional(v.string()),
    address: v.optional(v.string()),
    city: v.optional(v.string()),
    country: v.optional(v.string()),
    cuisineType: v.optional(v.array(v.string())),
    deliveryFee: v.optional(v.number()),
    minOrderAmount: v.optional(v.number()),
    estimatedDeliveryTime: v.optional(v.number()),
    openingHours: v.optional(
      v.object({
        monday: v.optional(v.object({ open: v.string(), close: v.string() })),
        tuesday: v.optional(v.object({ open: v.string(), close: v.string() })),
        wednesday: v.optional(
          v.object({ open: v.string(), close: v.string() })
        ),
        thursday: v.optional(
          v.object({ open: v.string(), close: v.string() })
        ),
        friday: v.optional(v.object({ open: v.string(), close: v.string() })),
        saturday: v.optional(
          v.object({ open: v.string(), close: v.string() })
        ),
        sunday: v.optional(v.object({ open: v.string(), close: v.string() })),
      })
    ),
    serviceModes: v.optional(v.array(v.string())),
    paymentMethods: v.optional(v.array(v.string())),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "restaurant", "admin");
    const restaurant = await ctx.db.get(args.restaurantId);
    if (!restaurant) throw new NotFoundError("Restaurant");

    if (user.role !== "admin" && restaurant.ownerId !== user._id) {
      throw new Error("Vous n'êtes pas propriétaire de ce restaurant");
    }

    const { restaurantId, token: _token, ...updates } = args;
    const filtered = Object.fromEntries(
      Object.entries(updates).filter(([, val]) => val !== undefined)
    );
    await ctx.db.patch(restaurantId, filtered);
  },
});
