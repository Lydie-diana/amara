import { mutation } from "./_generated/server";

/**
 * Seed des catégories cuisine pour Amara
 * Appel : npx convex run --prod seedCategories:run
 */
export const run = mutation({
  handler: async (ctx) => {
    // Vérifier si déjà seedé
    const existing = await ctx.db
      .query("foodCategories")
      .filter((q) => q.eq(q.field("isActive"), true))
      .first();
    if (existing) {
      return { message: "Catégories déjà peuplées" };
    }

    const now = Date.now();

    const categories = [
      { emoji: "🍗", label: "Poulet", sortOrder: 1 },
      { emoji: "🐟", label: "Poisson", sortOrder: 2 },
      { emoji: "🥩", label: "Grillades", sortOrder: 3 },
      { emoji: "🍚", label: "Riz", sortOrder: 4 },
      { emoji: "🥗", label: "Végétarien", sortOrder: 5 },
      { emoji: "🍝", label: "Pâtes", sortOrder: 6 },
      { emoji: "🍔", label: "Burgers", sortOrder: 7 },
      { emoji: "🌶️", label: "Épicé", sortOrder: 8 },
      { emoji: "🥘", label: "Plats locaux", sortOrder: 9 },
      { emoji: "🍰", label: "Desserts", sortOrder: 10 },
      { emoji: "🥤", label: "Boissons", sortOrder: 11 },
      { emoji: "🌍", label: "Africain", sortOrder: 12 },
    ];

    for (const cat of categories) {
      await ctx.db.insert("foodCategories", {
        ...cat,
        isActive: true,
        createdAt: now,
      });
    }

    return { message: `${categories.length} catégories créées` };
  },
});
