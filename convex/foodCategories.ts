import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { requireRoleWithToken } from "./helpers/errors";
import { internal } from "./_generated/api";

/** Liste des catégories cuisine actives, triées par sortOrder */
export const listActive = query({
  args: {},
  handler: async (ctx) => {
    const categories = await ctx.db
      .query("foodCategories")
      .withIndex("by_active", (q) => q.eq("isActive", true))
      .collect();

    return categories.sort((a, b) => a.sortOrder - b.sortOrder);
  },
});

/** Toutes les catégories (admin) */
export const listAll = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support");
    const all = await ctx.db.query("foodCategories").collect();
    return all.sort((a, b) => a.sortOrder - b.sortOrder);
  },
});

/** Créer une catégorie (admin) */
export const create = mutation({
  args: {
    token: v.string(),
    emoji: v.string(),
    label: v.string(),
    sortOrder: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin", "ops");
    const id = await ctx.db.insert("foodCategories", {
      emoji: args.emoji,
      label: args.label,
      sortOrder: args.sortOrder ?? 0,
      isActive: true,
      createdAt: Date.now(),
    });
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "create_category",
      resource: "foodCategories",
      resourceId: id,
    });
    return id;
  },
});

/** Modifier une catégorie (admin) */
export const updateCat = mutation({
  args: {
    token: v.string(),
    id: v.id("foodCategories"),
    emoji: v.optional(v.string()),
    label: v.optional(v.string()),
    sortOrder: v.optional(v.number()),
    isActive: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin", "ops");
    const { token, id, ...updates } = args;
    const patch: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(updates)) {
      if (value !== undefined) patch[key] = value;
    }
    await ctx.db.patch(id, patch);
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "update_category",
      resource: "foodCategories",
      resourceId: id,
    });
  },
});

/** Supprimer une catégorie (admin) — soft delete */
export const remove = mutation({
  args: {
    token: v.string(),
    id: v.id("foodCategories"),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin", "ops");
    await ctx.db.patch(args.id, { isActive: false });
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "delete_category",
      resource: "foodCategories",
      resourceId: args.id,
    });
  },
});
