import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { requireRoleWithToken } from "./helpers/errors";
import { internal } from "./_generated/api";

/** Toutes les règles métier (admin) */
export const listAll = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "finance");
    return await ctx.db.query("businessRules").collect();
  },
});

/** Modifier une règle métier (admin only) */
export const updateRule = mutation({
  args: {
    token: v.string(),
    key: v.string(),
    value: v.string(),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin");

    const rule = await ctx.db
      .query("businessRules")
      .withIndex("by_key", (q) => q.eq("key", args.key))
      .unique();

    if (!rule) {
      throw new Error(`Règle '${args.key}' introuvable`);
    }

    await ctx.db.patch(rule._id, {
      value: args.value,
      updatedAt: Date.now(),
      updatedBy: admin._id,
    });

    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "update_business_rule",
      resource: "businessRules",
      resourceId: rule._id,
    });
  },
});
