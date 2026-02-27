import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import {
  requireRoleWithToken,
  NotFoundError,
} from "./helpers/errors";

// ============ MUTATIONS ============

/** Mettre à jour la position GPS du livreur (upsert) */
export const updateLocation = mutation({
  args: {
    token: v.string(),
    latitude: v.number(),
    longitude: v.number(),
    isAvailable: v.boolean(),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const existing = await ctx.db
      .query("livreurLocations")
      .withIndex("by_livreur", (q) => q.eq("livreurId", user._id))
      .unique();

    if (existing) {
      await ctx.db.patch(existing._id, {
        latitude: args.latitude,
        longitude: args.longitude,
        isAvailable: args.isAvailable,
        updatedAt: Date.now(),
      });
    } else {
      await ctx.db.insert("livreurLocations", {
        livreurId: user._id,
        latitude: args.latitude,
        longitude: args.longitude,
        isAvailable: args.isAvailable,
        updatedAt: Date.now(),
      });
    }

    return { success: true };
  },
});

// ============ QUERIES ============

/** Récupérer la position du livreur connecté */
export const myLocation = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");
    return await ctx.db
      .query("livreurLocations")
      .withIndex("by_livreur", (q) => q.eq("livreurId", user._id))
      .unique();
  },
});

/** Récupérer la position d'un livreur par ID (pour le client/admin) */
export const getByLivreurId = query({
  args: { livreurId: v.id("users"), token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("livreurLocations")
      .withIndex("by_livreur", (q) => q.eq("livreurId", args.livreurId))
      .unique();
  },
});
