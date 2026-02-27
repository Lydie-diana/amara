import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

/**
 * Génère une URL signée pour uploader un fichier vers Convex Storage.
 * Le client Flutter envoie ensuite le fichier directement à cette URL via HTTP POST.
 */
export const generateUploadUrl = mutation({
  args: {},
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

/**
 * Récupère l'URL publique d'un fichier stocké dans Convex Storage.
 */
export const getUrl = query({
  args: { storageId: v.id("_storage") },
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});
