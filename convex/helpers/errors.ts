import { QueryCtx, MutationCtx } from "../_generated/server";
import { Doc, Id } from "../_generated/dataModel";

// ============ CLASSES D'ERREURS TYPÉES ============

export class OryxError extends Error {
  constructor(
    message: string,
    public code: string,
    public httpStatus: number = 400
  ) {
    super(message);
    this.name = "OryxError";
  }
}

export class AuthenticationError extends OryxError {
  constructor(message: string = "Non authentifié") {
    super(message, "AUTH_REQUIRED", 401);
  }
}

export class AuthorizationError extends OryxError {
  constructor(message: string = "Accès non autorisé") {
    super(message, "FORBIDDEN", 403);
  }
}

export class NotFoundError extends OryxError {
  constructor(resource: string) {
    super(`${resource} non trouvé(e)`, "NOT_FOUND", 404);
  }
}

export class ValidationError extends OryxError {
  constructor(field: string, message: string) {
    super(`Validation: ${field} - ${message}`, "VALIDATION_ERROR", 400);
  }
}

export class RateLimitError extends OryxError {
  constructor() {
    super(
      "Trop de requêtes, veuillez réessayer plus tard",
      "RATE_LIMITED",
      429
    );
  }
}

export class InvalidStateTransitionError extends OryxError {
  constructor(from: string, to: string) {
    super(
      `Transition invalide: ${from} → ${to}`,
      "INVALID_STATE_TRANSITION",
      400
    );
  }
}

export class AccountSuspendedError extends OryxError {
  constructor() {
    super(
      "Votre compte a été suspendu. Contactez le support.",
      "ACCOUNT_SUSPENDED",
      403
    );
  }
}

// ============ HELPERS D'AUTHENTIFICATION ============

/**
 * Vérifie que l'utilisateur est authentifié.
 * Essaie d'abord Clerk (web), puis le token de session (mobile).
 */
export async function requireAuth(
  ctx: QueryCtx | MutationCtx,
  token?: string
): Promise<{ subject: string; tokenIdentifier: string }> {
  // 1. Essayer Clerk (web)
  const identity = await ctx.auth.getUserIdentity();
  if (identity) return identity as { subject: string; tokenIdentifier: string };

  // 2. Fallback: token de session (mobile)
  if (token) {
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", token))
      .unique();
    if (session && session.expiresAt >= Date.now()) {
      const user = await ctx.db.get(session.userId);
      if (user) {
        return {
          subject: user._id,
          tokenIdentifier: `custom:${user._id}`,
        };
      }
    }
  }

  throw new AuthenticationError();
}

/**
 * Récupère l'utilisateur Convex.
 * Supporte Clerk (web) et token de session (mobile).
 */
export async function requireUser(
  ctx: QueryCtx | MutationCtx,
  token?: string
): Promise<Doc<"users">> {
  const identity = await requireAuth(ctx, token);

  // Si c'est un token mobile, le subject est directement le userId
  if (identity.tokenIdentifier.startsWith("custom:")) {
    const user = await ctx.db.get(identity.subject as Id<"users">);
    if (!user) throw new NotFoundError("Utilisateur");
    if (!user.isActive) throw new AccountSuspendedError();
    return user;
  }

  // Sinon, c'est Clerk — chercher par externalId
  const user = await ctx.db
    .query("users")
    .withIndex("by_externalId", (q) => q.eq("externalId", identity.subject))
    .unique();
  if (!user) throw new NotFoundError("Utilisateur");
  if (!user.isActive) throw new AccountSuspendedError();
  return user;
}

/**
 * Vérifie que l'utilisateur a l'un des rôles autorisés.
 * Retourne l'utilisateur si OK, throw AuthorizationError sinon.
 */
export async function requireRole(
  ctx: QueryCtx | MutationCtx,
  ...allowedRoles: Doc<"users">["role"][]
): Promise<Doc<"users">> {
  const user = await requireUser(ctx);
  if (!allowedRoles.includes(user.role)) {
    throw new AuthorizationError(
      `Rôle requis: ${allowedRoles.join(" ou ")}. Votre rôle: ${user.role}`
    );
  }
  return user;
}

/**
 * Variante de requireRole qui accepte un token optionnel (pour le mobile).
 */
export async function requireRoleWithToken(
  ctx: QueryCtx | MutationCtx,
  token: string | undefined,
  ...allowedRoles: Doc<"users">["role"][]
): Promise<Doc<"users">> {
  const user = await requireUser(ctx, token);
  if (!allowedRoles.includes(user.role)) {
    throw new AuthorizationError(
      `Rôle requis: ${allowedRoles.join(" ou ")}. Votre rôle: ${user.role}`
    );
  }
  return user;
}

/**
 * Optionnellement récupère l'utilisateur (pour les queries publiques).
 * Retourne null si non authentifié, l'utilisateur sinon.
 */
export async function optionalUser(
  ctx: QueryCtx | MutationCtx,
  token?: string
): Promise<Doc<"users"> | null> {
  const identity = await ctx.auth.getUserIdentity();
  if (identity) {
    const user = await ctx.db
      .query("users")
      .withIndex("by_externalId", (q) =>
        q.eq("externalId", identity.subject)
      )
      .unique();
    return user;
  }

  // Fallback: token mobile
  if (token) {
    try {
      return await requireUserByToken(ctx, token);
    } catch {
      return null;
    }
  }

  return null;
}

// ============ AUTH PAR TOKEN (mobile) ============

/**
 * Récupère l'utilisateur via un token de session (auth mobile).
 * Vérifie que la session est valide et non expirée.
 */
export async function requireUserByToken(
  ctx: QueryCtx | MutationCtx,
  token: string
): Promise<Doc<"users">> {
  const session = await ctx.db
    .query("auth_sessions")
    .withIndex("by_token", (q) => q.eq("token", token))
    .unique();

  if (!session) throw new AuthenticationError();
  if (session.expiresAt < Date.now()) throw new AuthenticationError("Session expirée");

  const user = await ctx.db.get(session.userId);
  if (!user) throw new NotFoundError("Utilisateur");
  if (!user.isActive) throw new AccountSuspendedError();
  return user;
}

/**
 * Vérifie rôle via token de session.
 */
export async function requireRoleByToken(
  ctx: QueryCtx | MutationCtx,
  token: string,
  ...allowedRoles: Doc<"users">["role"][]
): Promise<Doc<"users">> {
  const user = await requireUserByToken(ctx, token);
  if (!allowedRoles.includes(user.role)) {
    throw new AuthorizationError(
      `Rôle requis: ${allowedRoles.join(" ou ")}. Votre rôle: ${user.role}`
    );
  }
  return user;
}
