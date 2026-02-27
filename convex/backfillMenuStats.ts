import { mutation } from "./_generated/server";

/**
 * Migration one-shot : remplit orderCount, rating, totalRatings
 * sur les menuItems existants en se basant sur les commandes livrées
 * et les avis déjà soumis.
 *
 * À exécuter une seule fois via le dashboard Convex, puis supprimer ce fichier.
 */
export const run = mutation({
  args: {},
  handler: async (ctx) => {
    // 1. Reset tous les menuItems à 0
    const allItems = await ctx.db.query("menuItems").collect();
    for (const item of allItems) {
      await ctx.db.patch(item._id, {
        orderCount: 0,
        rating: 0,
        totalRatings: 0,
      });
    }

    // 2. Parcourir toutes les commandes livrées → incrémenter orderCount
    const deliveredOrders = await ctx.db
      .query("orders")
      .withIndex("by_status", (q) => q.eq("status", "delivered"))
      .collect();

    const orderCountMap = new Map<string, number>();
    for (const order of deliveredOrders) {
      const seen = new Set<string>();
      for (const item of order.items) {
        const mid = (item as any).menuItemId as string;
        if (!mid || seen.has(mid)) continue;
        seen.add(mid);
        orderCountMap.set(mid, (orderCountMap.get(mid) ?? 0) + 1);
      }
    }

    // Appliquer orderCount
    for (const [mid, count] of orderCountMap) {
      try {
        const menuItem = await ctx.db.get(mid as any);
        if (menuItem) {
          await ctx.db.patch(menuItem._id, { orderCount: count });
        }
      } catch {
        // menuItem supprimé, on ignore
      }
    }

    // 3. Parcourir tous les avis → recalculer rating et totalRatings par plat
    const allReviews = await ctx.db.query("reviews").collect();

    // Map: menuItemId → { sum, count }
    const ratingMap = new Map<string, { sum: number; count: number }>();

    for (const review of allReviews) {
      const order = await ctx.db.get(review.orderId);
      if (!order) continue;

      const seenItems = new Set<string>();
      for (const item of order.items) {
        const mid = (item as any).menuItemId as string;
        if (!mid || seenItems.has(mid)) continue;
        seenItems.add(mid);

        const existing = ratingMap.get(mid) ?? { sum: 0, count: 0 };
        existing.sum += review.rating;
        existing.count += 1;
        ratingMap.set(mid, existing);
      }
    }

    // Appliquer rating + totalRatings
    for (const [mid, { sum, count }] of ratingMap) {
      try {
        const menuItem = await ctx.db.get(mid as any);
        if (menuItem) {
          const avg = Math.round((sum / count) * 10) / 10;
          await ctx.db.patch(menuItem._id, {
            rating: avg,
            totalRatings: count,
          });
        }
      } catch {
        // menuItem supprimé, on ignore
      }
    }

    return {
      message: "Backfill terminé",
      deliveredOrders: deliveredOrders.length,
      reviews: allReviews.length,
      itemsWithOrders: orderCountMap.size,
      itemsWithRatings: ratingMap.size,
    };
  },
});
