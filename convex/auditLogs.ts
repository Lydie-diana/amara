import { v } from "convex/values";
import { query, internalMutation } from "./_generated/server";
import { requireRoleWithToken } from "./helpers/errors";

// ============ INTERNAL (appelé par d'autres mutations) ============

/** Écrire une entrée d'audit (usage interne uniquement) */
export const log = internalMutation({
  args: {
    userId: v.optional(v.id("users")),
    action: v.string(),
    resource: v.string(),
    resourceId: v.optional(v.string()),
    details: v.optional(v.string()),
    ipAddress: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await ctx.db.insert("auditLogs", {
      ...args,
      createdAt: Date.now(),
    });
  },
});

// ============ QUERIES (admin/support/finance/ops) ============

/** Logs récents */
export const recent = query({
  args: {
    token: v.optional(v.string()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "support", "finance", "ops");
    return await ctx.db
      .query("auditLogs")
      .order("desc")
      .take(args.limit ?? 100);
  },
});

/** Logs par type de ressource */
export const byResource = query({
  args: {
    token: v.optional(v.string()),
    resource: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "support", "finance", "ops");
    return await ctx.db
      .query("auditLogs")
      .withIndex("by_resource", (q) => q.eq("resource", args.resource))
      .order("desc")
      .take(args.limit ?? 50);
  },
});

/** Logs par action */
export const byAction = query({
  args: {
    token: v.optional(v.string()),
    action: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin");
    return await ctx.db
      .query("auditLogs")
      .withIndex("by_action", (q) => q.eq("action", args.action))
      .order("desc")
      .take(args.limit ?? 50);
  },
});

/** Logs d'un utilisateur spécifique */
export const byUser = query({
  args: {
    token: v.optional(v.string()),
    userId: v.id("users"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "support");
    return await ctx.db
      .query("auditLogs")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .order("desc")
      .take(args.limit ?? 50);
  },
});
