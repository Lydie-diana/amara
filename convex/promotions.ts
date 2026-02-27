import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { requireRoleWithToken } from "./helpers/errors";
import { internal } from "./_generated/api";

/** Liste des promotions actives (optionnel: filtrées par ville) */
export const listActive = query({
  args: {
    city: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const all = await ctx.db
      .query("promotions")
      .withIndex("by_active", (q) => q.eq("isActive", true))
      .collect();

    const now = Date.now();

    return all
      .filter((p) => {
        // Filtrer par dates si définies
        if (p.startsAt && now < p.startsAt) return false;
        if (p.endsAt && now > p.endsAt) return false;
        // Filtrer par ville (null = toutes les villes)
        if (p.city && args.city && p.city !== args.city) return false;
        return true;
      })
      .sort((a, b) => a.sortOrder - b.sortOrder);
  },
});

/** Toutes les promotions (admin) */
export const listAll = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support");
    const all = await ctx.db.query("promotions").collect();
    return all.sort((a, b) => a.sortOrder - b.sortOrder);
  },
});

/** Créer une promotion (admin) */
export const create = mutation({
  args: {
    token: v.string(),
    title: v.string(),
    subtitle: v.string(),
    tag: v.string(),
    emoji: v.string(),
    bgColor: v.string(),
    city: v.optional(v.string()),
    sortOrder: v.optional(v.number()),
    startsAt: v.optional(v.number()),
    endsAt: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin", "ops");
    const id = await ctx.db.insert("promotions", {
      title: args.title,
      subtitle: args.subtitle,
      tag: args.tag,
      emoji: args.emoji,
      bgColor: args.bgColor,
      city: args.city,
      isActive: true,
      sortOrder: args.sortOrder ?? 0,
      startsAt: args.startsAt,
      endsAt: args.endsAt,
      createdAt: Date.now(),
    });
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "create_promotion",
      resource: "promotions",
      resourceId: id,
    });
    return id;
  },
});

/** Modifier une promotion (admin) */
export const update = mutation({
  args: {
    token: v.string(),
    id: v.id("promotions"),
    title: v.optional(v.string()),
    subtitle: v.optional(v.string()),
    tag: v.optional(v.string()),
    emoji: v.optional(v.string()),
    bgColor: v.optional(v.string()),
    city: v.optional(v.string()),
    isActive: v.optional(v.boolean()),
    sortOrder: v.optional(v.number()),
    startsAt: v.optional(v.number()),
    endsAt: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin", "ops");
    const { token, id, ...updates } = args;
    // Remove undefined values
    const patch: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(updates)) {
      if (value !== undefined) patch[key] = value;
    }
    await ctx.db.patch(id, patch);
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "update_promotion",
      resource: "promotions",
      resourceId: id,
    });
  },
});

/** Supprimer une promotion (admin) — soft delete via isActive */
export const remove = mutation({
  args: {
    token: v.string(),
    id: v.id("promotions"),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin", "ops");
    await ctx.db.patch(args.id, { isActive: false });
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "delete_promotion",
      resource: "promotions",
      resourceId: args.id,
    });
  },
});
