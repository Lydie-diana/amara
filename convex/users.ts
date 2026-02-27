import { v } from "convex/values";
import { mutation, query, internalMutation } from "./_generated/server";
import {
  requireUser,
  requireRole,
  requireRoleWithToken,
  optionalUser,
} from "./helpers/errors";
import { internal } from "./_generated/api";

// ============ QUERIES ============

/** Récupérer l'utilisateur courant */
export const currentUser = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    return await optionalUser(ctx, args.token);
  },
});

/** Récupérer un utilisateur par ID */
export const getById = query({
  args: { userId: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.userId);
  },
});

/** Lister les utilisateurs par rôle (admin/ops/support) */
export const listByRole = query({
  args: {
    token: v.optional(v.string()),
    role: v.union(
      v.literal("client"),
      v.literal("restaurant"),
      v.literal("livreur"),
      v.literal("admin"),
      v.literal("support"),
      v.literal("finance"),
      v.literal("ops")
    ),
  },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support");
    return await ctx.db
      .query("users")
      .withIndex("by_role", (q) => q.eq("role", args.role))
      .collect();
  },
});

// ============ MUTATIONS ============

/** Sync utilisateur depuis le webhook Clerk (usage interne uniquement) */
export const syncFromWebhook = internalMutation({
  args: {
    externalId: v.string(),
    name: v.string(),
    email: v.string(),
    phone: v.string(),
    imageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("users")
      .withIndex("by_externalId", (q) => q.eq("externalId", args.externalId))
      .unique();

    if (existing) {
      await ctx.db.patch(existing._id, {
        name: args.name,
        email: args.email,
        phone: args.phone,
        imageUrl: args.imageUrl,
      });
      return existing._id;
    }

    return await ctx.db.insert("users", {
      ...args,
      role: "client",
      isActive: true,
      onboardingCompleted: false,
      preferredLanguage: "fr",
      createdAt: Date.now(),
    });
  },
});

/** Désactiver un utilisateur par externalId (webhook Clerk user.deleted) */
export const deactivateByExternalId = internalMutation({
  args: { externalId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_externalId", (q) => q.eq("externalId", args.externalId))
      .unique();
    if (user) {
      await ctx.db.patch(user._id, { isActive: false });
    }
  },
});

/** Sync utilisateur (appelé côté client après login, fallback si webhook pas encore configuré) */
export const syncUser = mutation({
  args: {
    name: v.string(),
    email: v.string(),
    phone: v.optional(v.string()),
    imageUrl: v.optional(v.string()),
    externalId: v.string(),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("users")
      .withIndex("by_externalId", (q) => q.eq("externalId", args.externalId))
      .unique();

    if (existing) {
      await ctx.db.patch(existing._id, {
        name: args.name,
        email: args.email,
        imageUrl: args.imageUrl,
        ...(args.phone && { phone: args.phone }),
      });
      return existing._id;
    }

    return await ctx.db.insert("users", {
      name: args.name,
      email: args.email,
      phone: args.phone ?? "",
      imageUrl: args.imageUrl,
      externalId: args.externalId,
      role: "client",
      isActive: true,
      onboardingCompleted: false,
      preferredLanguage: "fr",
      createdAt: Date.now(),
    });
  },
});

/** Choisir un rôle (onboarding, une seule fois) */
export const updateRole = mutation({
  args: {
    role: v.union(
      v.literal("client"),
      v.literal("restaurant"),
      v.literal("livreur")
    ),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    if (user.onboardingCompleted) {
      throw new Error("Le rôle ne peut plus être modifié après l'onboarding");
    }
    await ctx.db.patch(user._id, { role: args.role });
  },
});

/** Compléter l'onboarding client */
export const completeOnboarding = mutation({
  args: {
    defaultAddress: v.optional(v.string()),
    defaultLatitude: v.optional(v.number()),
    defaultLongitude: v.optional(v.number()),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    const { token: _token, ...updateArgs } = args;
    await ctx.db.patch(user._id, {
      ...updateArgs,
      onboardingCompleted: true,
    });
  },
});

/** Tracker un login (appelé depuis le layout auth) */
export const trackLogin = mutation({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    await ctx.db.patch(user._id, { lastLoginAt: Date.now() });
    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: user._id,
      action: "login",
      resource: "users",
      resourceId: user._id,
    });
  },
});

/** Suspendre un utilisateur (admin) */
export const suspendUser = mutation({
  args: {
    token: v.optional(v.string()),
    userId: v.id("users"),
    reason: v.string(),
  },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin");
    const target = await ctx.db.get(args.userId);
    if (!target) throw new Error("Utilisateur non trouvé");

    await ctx.db.patch(args.userId, {
      isActive: false,
      suspendedAt: Date.now(),
      suspendedReason: args.reason,
    });

    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "suspend_user",
      resource: "users",
      resourceId: args.userId,
      details: JSON.stringify({ reason: args.reason, targetRole: target.role }),
    });
  },
});

/** Réactiver un utilisateur (admin) */
export const reactivateUser = mutation({
  args: { token: v.optional(v.string()), userId: v.id("users") },
  handler: async (ctx, args) => {
    const admin = await requireRoleWithToken(ctx, args.token, "admin");

    await ctx.db.patch(args.userId, {
      isActive: true,
      suspendedAt: undefined,
      suspendedReason: undefined,
    });

    await ctx.scheduler.runAfter(0, internal.auditLogs.log, {
      userId: admin._id,
      action: "reactivate_user",
      resource: "users",
      resourceId: args.userId,
    });
  },
});
