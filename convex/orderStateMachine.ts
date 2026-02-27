import { v } from "convex/values";
import { internalMutation, internalQuery } from "./_generated/server";
import { InvalidStateTransitionError } from "./helpers/errors";

// ============ MATRICE DE TRANSITIONS VALIDES PAR RÔLE ============

const VALID_TRANSITIONS: Record<string, Record<string, string[]>> = {
  client: {
    pending: ["cancelled"],
  },
  restaurant: {
    pending: ["confirmed", "cancelled"],
    confirmed: ["preparing"],
    preparing: ["ready"],
  },
  livreur: {
    ready: ["picked_up"],
    picked_up: ["delivering"],
    delivering: ["delivered"],
  },
  admin: {
    pending: ["confirmed", "cancelled", "failed"],
    confirmed: ["preparing", "cancelled"],
    preparing: ["ready", "cancelled"],
    ready: ["picked_up", "cancelled"],
    picked_up: ["delivering", "cancelled"],
    delivering: ["delivered", "cancelled"],
  },
  support: {
    pending: ["cancelled"],
    confirmed: ["cancelled"],
  },
  ops: {
    pending: ["cancelled"],
    confirmed: ["cancelled"],
  },
  system: {
    // Transitions automatiques (timeouts, dispatch)
    pending: ["cancelled", "failed"],
    confirmed: ["cancelled"],
    ready: ["cancelled"],
  },
};

// ============ VALIDATION ============

/**
 * Valide qu'une transition d'état est autorisée pour un rôle donné.
 * Throw InvalidStateTransitionError si la transition est interdite.
 */
export function validateTransition(
  currentStatus: string,
  newStatus: string,
  role: string
): void {
  const roleTransitions = VALID_TRANSITIONS[role];
  if (!roleTransitions) {
    throw new InvalidStateTransitionError(currentStatus, newStatus);
  }

  const allowedNext = roleTransitions[currentStatus];
  if (!allowedNext || !allowedNext.includes(newStatus)) {
    throw new InvalidStateTransitionError(currentStatus, newStatus);
  }
}

/**
 * Retourne les transitions possibles pour un état et un rôle donnés.
 */
export function getAvailableTransitions(
  currentStatus: string,
  role: string
): string[] {
  return VALID_TRANSITIONS[role]?.[currentStatus] ?? [];
}

// ============ HISTORIQUE DES TRANSITIONS ============

/** Enregistrer une transition dans l'historique */
export const recordTransition = internalMutation({
  args: {
    orderId: v.id("orders"),
    fromStatus: v.string(),
    toStatus: v.string(),
    triggeredBy: v.optional(v.id("users")),
    triggeredByRole: v.optional(v.string()),
    reason: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await ctx.db.insert("orderStateHistory", {
      ...args,
      createdAt: Date.now(),
    });
  },
});

/** Récupérer l'historique des transitions d'une commande */
export const getHistory = internalQuery({
  args: { orderId: v.id("orders") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("orderStateHistory")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .order("asc")
      .collect();
  },
});

/** Récupérer le nombre de transitions pour une commande (pour détection anomalie) */
export const getTransitionCount = internalQuery({
  args: { orderId: v.id("orders") },
  handler: async (ctx, args) => {
    const history = await ctx.db
      .query("orderStateHistory")
      .withIndex("by_order", (q) => q.eq("orderId", args.orderId))
      .collect();
    return history.length;
  },
});
