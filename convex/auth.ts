import { v } from "convex/values";
import { mutation, query } from "./_generated/server";

// ============ HELPERS ============

function generateSalt(): string {
  const array = new Uint8Array(16);
  crypto.getRandomValues(array);
  return Array.from(array, (b) => b.toString(16).padStart(2, "0")).join("");
}

async function hashPassword(password: string, salt: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(salt + password);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
  return `${salt}:${hashHex}`;
}

async function verifyPassword(
  password: string,
  storedHash: string
): Promise<boolean> {
  const [salt, _hash] = storedHash.split(":");
  if (!salt || !_hash) return false;
  const computed = await hashPassword(password, salt);
  return computed === storedHash;
}

function generateToken(): string {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return Array.from(array, (b) => b.toString(16).padStart(2, "0")).join("");
}

// Session duration: 30 days
const SESSION_DURATION_MS = 30 * 24 * 60 * 60 * 1000;

// ============ MUTATIONS ============

/** Inscription email/password */
export const signup = mutation({
  args: {
    name: v.string(),
    email: v.string(),
    phone: v.string(),
    password: v.string(),
    role: v.optional(
      v.union(v.literal("client"), v.literal("restaurant"), v.literal("livreur"))
    ),
  },
  handler: async (ctx, args) => {
    // Check if email already exists
    const existing = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .unique();

    if (existing) {
      throw new Error("Un compte avec cet email existe déjà");
    }

    // Hash password
    const salt = generateSalt();
    const passwordHash = await hashPassword(args.password, salt);

    // Create user
    const userId = await ctx.db.insert("users", {
      name: args.name,
      email: args.email,
      phone: args.phone,
      passwordHash,
      role: args.role ?? "client",
      isActive: true,
      onboardingCompleted: false,
      preferredLanguage: "fr",
      createdAt: Date.now(),
    });

    // Create session
    const token = generateToken();
    await ctx.db.insert("auth_sessions", {
      userId,
      token,
      expiresAt: Date.now() + SESSION_DURATION_MS,
      createdAt: Date.now(),
    });

    return { token, userId };
  },
});

/** Connexion email/password */
export const login = mutation({
  args: {
    email: v.string(),
    password: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .unique();

    if (!user) {
      throw new Error("Email ou mot de passe incorrect");
    }

    if (!user.isActive) {
      throw new Error("Votre compte a été suspendu. Contactez le support.");
    }

    if (!user.passwordHash) {
      throw new Error("Ce compte n'a pas de mot de passe. Veuillez vous inscrire.");
    }

    const valid = await verifyPassword(args.password, user.passwordHash);
    if (!valid) {
      throw new Error("Email ou mot de passe incorrect");
    }

    // Create session
    const token = generateToken();
    await ctx.db.insert("auth_sessions", {
      userId: user._id,
      token,
      expiresAt: Date.now() + SESSION_DURATION_MS,
      createdAt: Date.now(),
    });

    // Track login
    await ctx.db.patch(user._id, { lastLoginAt: Date.now() });

    return { token, userId: user._id };
  },
});

/** Déconnexion */
export const logout = mutation({
  args: {
    token: v.string(),
  },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .unique();

    if (session) {
      await ctx.db.delete(session._id);
    }
  },
});

/** Mise à jour du profil utilisateur */
export const updateProfile = mutation({
  args: {
    token: v.string(),
    name: v.optional(v.string()),
    phone: v.optional(v.string()),
    imageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .unique();

    if (!session || session.expiresAt < Date.now()) {
      throw new Error("Session invalide ou expirée");
    }

    const user = await ctx.db.get(session.userId);
    if (!user || !user.isActive) {
      throw new Error("Utilisateur non trouvé");
    }

    const updates: Record<string, any> = {};
    if (args.name !== undefined) updates.name = args.name;
    if (args.phone !== undefined) updates.phone = args.phone;
    if (args.imageUrl !== undefined) updates.imageUrl = args.imageUrl;

    if (Object.keys(updates).length > 0) {
      await ctx.db.patch(session.userId, updates);
    }

    const updated = await ctx.db.get(session.userId);
    if (!updated) throw new Error("Erreur interne");
    const { passwordHash: _, ...safeUser } = updated;
    return safeUser;
  },
});

/** Changement de mot de passe */
export const changePassword = mutation({
  args: {
    token: v.string(),
    currentPassword: v.string(),
    newPassword: v.string(),
  },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .unique();

    if (!session || session.expiresAt < Date.now()) {
      throw new Error("Session invalide ou expirée");
    }

    const user = await ctx.db.get(session.userId);
    if (!user || !user.isActive) {
      throw new Error("Utilisateur non trouvé");
    }

    if (!user.passwordHash) {
      throw new Error("Ce compte n'a pas de mot de passe défini");
    }

    const valid = await verifyPassword(args.currentPassword, user.passwordHash);
    if (!valid) {
      throw new Error("Mot de passe actuel incorrect");
    }

    if (args.newPassword.length < 6) {
      throw new Error("Le nouveau mot de passe doit comporter au moins 6 caractères");
    }

    const salt = generateSalt();
    const passwordHash = await hashPassword(args.newPassword, salt);
    await ctx.db.patch(session.userId, { passwordHash });

    return { success: true };
  },
});

/** Valider une session et retourner l'utilisateur */
export const validateSession = query({
  args: {
    token: v.string(),
  },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .unique();

    if (!session) return null;

    // Check expiration
    if (session.expiresAt < Date.now()) {
      return null;
    }

    const user = await ctx.db.get(session.userId);
    if (!user || !user.isActive) return null;

    return user;
  },
});

/** Récupérer l'utilisateur courant par token */
export const currentUserByToken = query({
  args: {
    token: v.string(),
  },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("auth_sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .unique();

    if (!session || session.expiresAt < Date.now()) return null;

    const user = await ctx.db.get(session.userId);
    if (!user || !user.isActive) return null;

    // Don't return passwordHash to client
    const { passwordHash: _, ...safeUser } = user;
    return safeUser;
  },
});

/** Récupérer un utilisateur par ID (infos publiques uniquement) */
export const getUserById = query({
  args: { userId: v.id("users") },
  handler: async (ctx, args) => {
    const user = await ctx.db.get(args.userId);
    if (!user) return null;
    return { _id: user._id, name: user.name, imageUrl: user.imageUrl };
  },
});
