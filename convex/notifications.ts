import { v } from "convex/values";
import { mutation, query, internalMutation } from "./_generated/server";
import { requireUser } from "./helpers/errors";

// ============ QUERIES ============

/** Liste des notifications de l'utilisateur (desc) */
export const list = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    return await ctx.db
      .query("notifications")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .order("desc")
      .collect();
  },
});

/** Nombre de notifications non lues */
export const unreadCount = query({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    const unread = await ctx.db
      .query("notifications")
      .withIndex("by_user_unread", (q) =>
        q.eq("userId", user._id).eq("isRead", false)
      )
      .collect();
    return unread.length;
  },
});

// ============ MUTATIONS ============

/** Marquer une notification comme lue */
export const markAsRead = mutation({
  args: {
    notificationId: v.id("notifications"),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    const notif = await ctx.db.get(args.notificationId);
    if (!notif || notif.userId !== user._id) {
      throw new Error("Notification non trouvee");
    }
    await ctx.db.patch(args.notificationId, { isRead: true });
  },
});

/** Marquer toutes les notifications comme lues */
export const markAllAsRead = mutation({
  args: { token: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    const unread = await ctx.db
      .query("notifications")
      .withIndex("by_user_unread", (q) =>
        q.eq("userId", user._id).eq("isRead", false)
      )
      .collect();
    for (const notif of unread) {
      await ctx.db.patch(notif._id, { isRead: true });
    }
    return { updated: unread.length };
  },
});

/** Supprimer une notification */
export const deleteOne = mutation({
  args: {
    notificationId: v.id("notifications"),
    token: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx, args.token);
    const notif = await ctx.db.get(args.notificationId);
    if (!notif || notif.userId !== user._id) {
      throw new Error("Notification non trouvee");
    }
    await ctx.db.delete(args.notificationId);
  },
});

// ============ INTERNAL (appele par le flow commandes) ============

/** Creer une notification (usage interne uniquement) */
export const createInternal = internalMutation({
  args: {
    userId: v.id("users"),
    title: v.string(),
    message: v.string(),
    type: v.union(
      v.literal("order_update"),
      v.literal("promotion"),
      v.literal("system")
    ),
  },
  handler: async (ctx, args) => {
    await ctx.db.insert("notifications", {
      userId: args.userId,
      title: args.title,
      message: args.message,
      type: args.type,
      isRead: false,
      createdAt: Date.now(),
    });
  },
});
