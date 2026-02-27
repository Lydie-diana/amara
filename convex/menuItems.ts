import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { requireRole, requireRoleWithToken, NotFoundError } from "./helpers/errors";
import { sanitizeString, validatePrice } from "./helpers/validators";

// ============ QUERIES (publiques) ============

/** Lister les plats d'un restaurant */
export const byRestaurant = query({
  args: { restaurantId: v.id("restaurants") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("menuItems")
      .withIndex("by_restaurant", (q) =>
        q.eq("restaurantId", args.restaurantId)
      )
      .collect();
  },
});

/** Lister par catégorie */
export const byCategory = query({
  args: {
    restaurantId: v.id("restaurants"),
    category: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("menuItems")
      .withIndex("by_category", (q) =>
        q.eq("restaurantId", args.restaurantId).eq("category", args.category)
      )
      .collect();
  },
});

// ============ HELPERS ============

/** Vérifier que l'utilisateur est propriétaire du restaurant */
async function requireRestaurantOwner(
  ctx: any,
  restaurantId: any,
  token?: string
) {
  const user = await requireRoleWithToken(ctx, token, "restaurant", "admin");
  if (user.role !== "admin") {
    const restaurant = await ctx.db.get(restaurantId);
    if (!restaurant || restaurant.ownerId !== user._id) {
      throw new Error("Vous n'êtes pas propriétaire de ce restaurant");
    }
  }
  return user;
}

// ============ MUTATIONS ============

/** Ajouter un plat au menu */
export const create = mutation({
  args: {
    restaurantId: v.id("restaurants"),
    name: v.string(),
    description: v.string(),
    price: v.number(),
    imageUrl: v.optional(v.string()),
    category: v.string(),
    isAvailable: v.boolean(),
    preparationTime: v.optional(v.number()),
    tags: v.optional(v.array(v.string())),
    optionGroups: v.optional(v.array(v.object({
      id: v.string(),
      title: v.string(),
      required: v.boolean(),
      maxSelections: v.number(),
      options: v.array(v.object({
        id: v.string(),
        name: v.string(),
        extraPrice: v.number(),
      })),
    }))),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requireRestaurantOwner(ctx, args.restaurantId, args.token);

    if (!validatePrice(args.price)) {
      throw new Error("Prix invalide (0 - 1 000 000 FCFA)");
    }

    const { token: _token, ...menuItemArgs } = args;
    return await ctx.db.insert("menuItems", {
      ...menuItemArgs,
      name: sanitizeString(args.name, 100),
      description: sanitizeString(args.description, 300),
      createdAt: Date.now(),
    });
  },
});

/** Mettre à jour la disponibilité */
export const toggleAvailability = mutation({
  args: {
    menuItemId: v.id("menuItems"),
    isAvailable: v.boolean(),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const item = await ctx.db.get(args.menuItemId);
    if (!item) throw new NotFoundError("Plat");
    await requireRestaurantOwner(ctx, item.restaurantId, args.token);

    await ctx.db.patch(args.menuItemId, { isAvailable: args.isAvailable });
  },
});

/** Mettre à jour un plat */
export const update = mutation({
  args: {
    menuItemId: v.id("menuItems"),
    name: v.optional(v.string()),
    description: v.optional(v.string()),
    price: v.optional(v.number()),
    imageUrl: v.optional(v.string()),
    category: v.optional(v.string()),
    preparationTime: v.optional(v.number()),
    tags: v.optional(v.array(v.string())),
    optionGroups: v.optional(v.array(v.object({
      id: v.string(),
      title: v.string(),
      required: v.boolean(),
      maxSelections: v.number(),
      options: v.array(v.object({
        id: v.string(),
        name: v.string(),
        extraPrice: v.number(),
      })),
    }))),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const item = await ctx.db.get(args.menuItemId);
    if (!item) throw new NotFoundError("Plat");
    await requireRestaurantOwner(ctx, item.restaurantId, args.token);

    if (args.price !== undefined && !validatePrice(args.price)) {
      throw new Error("Prix invalide (0 - 1 000 000 FCFA)");
    }

    const { menuItemId, token: _token, ...updates } = args;
    const filtered = Object.fromEntries(
      Object.entries(updates).filter(([, val]) => val !== undefined)
    );
    await ctx.db.patch(menuItemId, filtered);
  },
});

/** Supprimer un plat */
export const remove = mutation({
  args: { menuItemId: v.id("menuItems"), token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const item = await ctx.db.get(args.menuItemId);
    if (!item) throw new NotFoundError("Plat");
    await requireRestaurantOwner(ctx, item.restaurantId, args.token);

    await ctx.db.delete(args.menuItemId);
  },
});
