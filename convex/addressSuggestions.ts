import { v } from "convex/values";
import { query } from "./_generated/server";

/** Suggestions d'adresses actives, optionnellement filtrées par ville */
export const list = query({
  args: {
    city: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    if (args.city) {
      const results = await ctx.db
        .query("addressSuggestions")
        .withIndex("by_city", (q) => q.eq("city", args.city!))
        .collect();
      return results
        .filter((a) => a.isActive)
        .sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));
    }

    const results = await ctx.db
      .query("addressSuggestions")
      .withIndex("by_active", (q) => q.eq("isActive", true))
      .collect();

    return results.sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));
  },
});
