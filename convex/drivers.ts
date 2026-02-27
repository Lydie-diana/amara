import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import {
  requireRoleWithToken,
  requireUserByToken,
  NotFoundError,
} from "./helpers/errors";

// ============ QUERIES ============

/** Récupérer le profil livreur du user connecté */
export const getProfile = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");
    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .unique();
    return profile;
  },
});

/** Récupérer le profil livreur par userId (admin/ops) */
export const getByUserId = query({
  args: { userId: v.id("users"), token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops", "support");
    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", args.userId))
      .unique();
    return profile;
  },
});

/** Lister les livreurs en ligne (admin/ops) */
export const listOnline = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    await requireRoleWithToken(ctx, args.token, "admin", "ops");
    return await ctx.db
      .query("driverProfiles")
      .withIndex("by_online", (q) => q.eq("isOnline", true))
      .collect();
  },
});

// ============ MUTATIONS ============

/** Créer le profil livreur (onboarding) */
export const createProfile = mutation({
  args: {
    token: v.string(),
    vehicleType: v.union(
      v.literal("moto"),
      v.literal("velo"),
      v.literal("voiture")
    ),
    vehiclePlate: v.optional(v.string()),
    licenseNumber: v.optional(v.string()),
    idCardUrl: v.optional(v.string()),
    licenseUrl: v.optional(v.string()),
    vehiclePhotoUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    // Vérifier qu'il n'a pas déjà un profil
    const existing = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .unique();

    if (existing) {
      throw new Error("Un profil livreur existe déjà pour cet utilisateur");
    }

    const profileId = await ctx.db.insert("driverProfiles", {
      userId: user._id,
      vehicleType: args.vehicleType,
      vehiclePlate: args.vehiclePlate,
      licenseNumber: args.licenseNumber,
      idCardUrl: args.idCardUrl,
      licenseUrl: args.licenseUrl,
      vehiclePhotoUrl: args.vehiclePhotoUrl,
      isVerified: false,
      isOnline: false,
      totalDeliveries: 0,
      createdAt: Date.now(),
    });

    // Marquer l'onboarding comme complété
    await ctx.db.patch(user._id, { onboardingCompleted: true });

    return profileId;
  },
});

/** Mettre à jour le profil livreur */
export const updateProfile = mutation({
  args: {
    token: v.string(),
    vehicleType: v.optional(
      v.union(
        v.literal("moto"),
        v.literal("velo"),
        v.literal("voiture")
      )
    ),
    vehiclePlate: v.optional(v.string()),
    licenseNumber: v.optional(v.string()),
    idCardUrl: v.optional(v.string()),
    licenseUrl: v.optional(v.string()),
    vehiclePhotoUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .unique();

    if (!profile) throw new NotFoundError("Profil livreur");

    const updates: Record<string, any> = {};
    if (args.vehicleType !== undefined) updates.vehicleType = args.vehicleType;
    if (args.vehiclePlate !== undefined) updates.vehiclePlate = args.vehiclePlate;
    if (args.licenseNumber !== undefined) updates.licenseNumber = args.licenseNumber;
    if (args.idCardUrl !== undefined) updates.idCardUrl = args.idCardUrl;
    if (args.licenseUrl !== undefined) updates.licenseUrl = args.licenseUrl;
    if (args.vehiclePhotoUrl !== undefined) updates.vehiclePhotoUrl = args.vehiclePhotoUrl;

    if (Object.keys(updates).length > 0) {
      await ctx.db.patch(profile._id, updates);
    }

    return await ctx.db.get(profile._id);
  },
});

/** Passer en ligne / hors ligne */
export const toggleOnline = mutation({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .unique();

    if (!profile) throw new NotFoundError("Profil livreur");

    const newStatus = !profile.isOnline;
    await ctx.db.patch(profile._id, { isOnline: newStatus });

    // Si hors ligne, marquer aussi la localisation comme indisponible
    if (!newStatus) {
      const location = await ctx.db
        .query("livreurLocations")
        .withIndex("by_livreur", (q) => q.eq("livreurId", user._id))
        .unique();
      if (location) {
        await ctx.db.patch(location._id, {
          isAvailable: false,
          updatedAt: Date.now(),
        });
      }
    }

    return { isOnline: newStatus };
  },
});

/** Définir le statut en ligne explicitement */
export const setOnline = mutation({
  args: {
    token: v.string(),
    isOnline: v.boolean(),
  },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .unique();

    if (!profile) throw new NotFoundError("Profil livreur");

    await ctx.db.patch(profile._id, { isOnline: args.isOnline });

    if (!args.isOnline) {
      const location = await ctx.db
        .query("livreurLocations")
        .withIndex("by_livreur", (q) => q.eq("livreurId", user._id))
        .unique();
      if (location) {
        await ctx.db.patch(location._id, {
          isAvailable: false,
          updatedAt: Date.now(),
        });
      }
    }

    return { isOnline: args.isOnline };
  },
});

/** Incrémenter le nombre de livraisons (appelé après delivered) */
export const incrementDeliveries = mutation({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const user = await requireRoleWithToken(ctx, args.token, "livreur");

    const profile = await ctx.db
      .query("driverProfiles")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .unique();

    if (!profile) throw new NotFoundError("Profil livreur");

    await ctx.db.patch(profile._id, {
      totalDeliveries: profile.totalDeliveries + 1,
    });
  },
});
