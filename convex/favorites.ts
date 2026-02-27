import { v } from "convex/values";
import { mutation, query } from "./_generated/server";

/** Toggle favori : ajoute ou retire un restaurant des favoris */
export const toggle = mutation({
  args: {
    token: v.string(),
    restaurantId: v.id("restaurants"),
  },
  handler: async (ctx, args) => {
    // Valider session
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .unique();
    if (!session || session.expiresAt < Date.now()) {
      throw new Error("Session invalide ou expirée");
    }

    // Vérifier si déjà en favori
    const existing = await ctx.db
      .query("favorites")
      .withIndex("by_user_restaurant", (q) =>
        q.eq("userId", session.userId).eq("restaurantId", args.restaurantId)
      )
      .unique();

    if (existing) {
      await ctx.db.delete(existing._id);
      return { isFavorite: false };
    } else {
      await ctx.db.insert("favorites", {
        userId: session.userId,
        restaurantId: args.restaurantId,
        createdAt: Date.now(),
      });
      return { isFavorite: true };
    }
  },
});

/** Liste des IDs de restaurants favoris de l'utilisateur */
export const list = query({
  args: {
    token: v.string(),
  },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .unique();
    if (!session || session.expiresAt < Date.now()) {
      return [];
    }

    const favorites = await ctx.db
      .query("favorites")
      .withIndex("by_user", (q) => q.eq("userId", session.userId))
      .collect();

    return favorites.map((f) => f.restaurantId);
  },
});
