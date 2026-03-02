import { v } from "convex/values";
import { internalAction, mutation, query } from "./_generated/server";
import { internal } from "./_generated/api";

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

/** Inscription email/password — retourne pendingUserId + code (interne, jamais exposé au client) */
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

    if (existing && existing.isActive) {
      throw new Error("Un compte avec cet email existe déjà");
    }

    // Si user non vérifié existant → le supprimer pour re-inscription propre
    if (existing && !existing.isActive) {
      await ctx.db.delete(existing._id);
    }

    // Hash password
    const salt = generateSalt();
    const passwordHash = await hashPassword(args.password, salt);

    // Create user (inactive until email verified)
    const userId = await ctx.db.insert("users", {
      name: args.name,
      email: args.email,
      phone: args.phone,
      passwordHash,
      role: args.role ?? "client",
      isActive: false,
      isEmailVerified: false,
      onboardingCompleted: false,
      preferredLanguage: "fr",
      createdAt: Date.now(),
    });

    // Generate 6-digit OTP code
    const code = Math.floor(100000 + Math.random() * 900000).toString();

    // Store verification
    await ctx.db.insert("email_verifications", {
      userId,
      email: args.email,
      code,
      expiresAt: Date.now() + 15 * 60 * 1000, // 15 min
      attempts: 0,
      createdAt: Date.now(),
    });

    // Return internal data (code stays internal, never sent to Flutter client)
    return { pendingUserId: userId, email: args.email, code, name: args.name };
  },
});

/** Vérification du code OTP email — active le compte et crée la session */
export const verifyEmail = mutation({
  args: {
    pendingUserId: v.id("users"),
    code: v.string(),
  },
  handler: async (ctx, args) => {
    const verification = await ctx.db
      .query("email_verifications")
      .withIndex("by_userId", (q) => q.eq("userId", args.pendingUserId))
      .order("desc")
      .first();

    if (!verification || verification.usedAt !== undefined) {
      throw new Error("Code invalide ou déjà utilisé");
    }
    if (verification.expiresAt < Date.now()) {
      throw new Error("Code expiré. Cliquez sur Renvoyer pour obtenir un nouveau code.");
    }
    if (verification.attempts >= 5) {
      throw new Error("Trop de tentatives. Cliquez sur Renvoyer pour obtenir un nouveau code.");
    }
    if (verification.code !== args.code) {
      await ctx.db.patch(verification._id, { attempts: verification.attempts + 1 });
      throw new Error("Code incorrect");
    }

    // Mark verification as used and activate user
    await ctx.db.patch(verification._id, { usedAt: Date.now() });
    await ctx.db.patch(args.pendingUserId, { isActive: true, isEmailVerified: true });

    // Create session
    const token = generateToken();
    await ctx.db.insert("auth_sessions", {
      userId: args.pendingUserId,
      token,
      expiresAt: Date.now() + SESSION_DURATION_MS,
      createdAt: Date.now(),
    });

    return { token, userId: args.pendingUserId };
  },
});

/** Renvoi du code OTP — invalide l'ancien et génère un nouveau */
export const resendVerification = mutation({
  args: {
    pendingUserId: v.id("users"),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db.get(args.pendingUserId);
    if (!user || user.isActive) {
      throw new Error("Utilisateur invalide ou déjà vérifié");
    }

    // Invalidate existing codes
    const existing = await ctx.db
      .query("email_verifications")
      .withIndex("by_userId", (q) => q.eq("userId", args.pendingUserId))
      .order("desc")
      .first();
    if (existing && existing.usedAt === undefined) {
      await ctx.db.patch(existing._id, { usedAt: Date.now() });
    }

    // New code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    await ctx.db.insert("email_verifications", {
      userId: args.pendingUserId,
      email: user.email,
      code,
      expiresAt: Date.now() + 15 * 60 * 1000,
      attempts: 0,
      createdAt: Date.now(),
    });

    return { email: user.email, code, name: user.name };
  },
});

/** Envoi de l'email de vérification via Resend (internalAction — accès fetch) */
export const sendVerificationEmail = internalAction({
  args: {
    email: v.string(),
    name: v.string(),
    code: v.string(),
  },
  handler: async (_ctx, args) => {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: "Bearer re_ao3Jzvg4_AGcwbQaiVzztZRDZk7s1FcH7",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Amara <noreply@elevenjobs.io>",
        to: [args.email],
        subject: "Votre code de vérification Amara",
        html: buildEmailTemplate(args.name, args.code),
      }),
    });
    if (!response.ok) {
      const body = await response.text();
      throw new Error(`Échec envoi email: ${body}`);
    }
  },
});

function buildEmailTemplate(name: string, code: string): string {
  const digits = code.split("").join("</td><td style=\"width:48px;height:56px;background:#1A1228;border:1px solid #2E2245;border-radius:10px;text-align:center;vertical-align:middle;font-size:26px;font-weight:700;color:#FFFFFF;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;\">");
  return `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="color-scheme" content="dark">
</head>
<body style="margin:0;padding:0;background:#F4F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F4F4F6;min-height:100vh;">
    <tr><td align="center" style="padding:48px 20px;">

      <!-- Card -->
      <table role="presentation" width="520" cellpadding="0" cellspacing="0" style="max-width:520px;width:100%;background:#120E1C;border-radius:24px;border:1px solid #1E1730;overflow:hidden;">

        <!-- Top accent line -->
        <tr><td style="height:3px;background:linear-gradient(90deg,#E62050 0%,#FF6B8A 50%,#E62050 100%);"></td></tr>

        <!-- Header -->
        <tr><td style="padding:40px 48px 32px;">
          <table role="presentation" cellpadding="0" cellspacing="0">
            <tr>
              <td style="width:40px;height:40px;background:linear-gradient(135deg,#E62050,#C0003A);border-radius:10px;text-align:center;vertical-align:middle;">
                <span style="color:#FFFFFF;font-size:20px;font-weight:900;line-height:40px;">A</span>
              </td>
              <td style="padding-left:12px;vertical-align:middle;">
                <span style="color:#FFFFFF;font-size:20px;font-weight:700;letter-spacing:-0.3px;">Amara</span>
              </td>
            </tr>
          </table>
        </td></tr>

        <!-- Divider -->
        <tr><td style="padding:0 48px;"><div style="height:1px;background:#1E1730;"></div></td></tr>

        <!-- Body -->
        <tr><td style="padding:36px 48px 40px;">

          <p style="margin:0 0 6px;color:#9B93A8;font-size:13px;font-weight:500;text-transform:uppercase;letter-spacing:1px;">Vérification du compte</p>
          <h1 style="margin:0 0 20px;color:#FFFFFF;font-size:22px;font-weight:700;line-height:1.3;">Bonjour ${name} 👋</h1>

          <p style="margin:0 0 32px;color:#7A7287;font-size:15px;line-height:1.7;">
            Utilisez le code ci-dessous pour activer votre compte. Il est valable <span style="color:#FFFFFF;font-weight:600;">15 minutes</span>.
          </p>

          <!-- Code digits -->
          <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 auto 32px;border-collapse:separate;border-spacing:8px 0;">
            <tr>
              <td style="width:48px;height:56px;background:#1A1228;border:1px solid #2E2245;border-radius:10px;text-align:center;vertical-align:middle;font-size:26px;font-weight:700;color:#FFFFFF;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">${digits}</td>
            </tr>
          </table>

          <!-- Security note -->
          <table role="presentation" cellpadding="0" cellspacing="0" style="background:#1A1228;border-radius:12px;border:1px solid #1E1730;width:100%;">
            <tr>
              <td style="padding:16px 20px;">
                <p style="margin:0;color:#5C5468;font-size:13px;line-height:1.6;">
                  🔒 &nbsp;Si vous n'êtes pas à l'origine de cette demande, ignorez simplement cet email. Ce code expire dans 15 minutes.
                </p>
              </td>
            </tr>
          </table>

        </td></tr>

        <!-- Footer -->
        <tr><td style="padding:20px 48px 28px;border-top:1px solid #1E1730;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
            <tr>
              <td style="color:#3D3549;font-size:12px;">© 2025 Amara</td>
              <td align="right" style="color:#3D3549;font-size:12px;">
                <a href="https://elevenjobs.io" style="color:#5C5468;text-decoration:none;">elevenjobs.io</a>
              </td>
            </tr>
          </table>
        </td></tr>

      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

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
      if (!user.isEmailVerified) {
        throw new Error("Veuillez vérifier votre email avant de vous connecter.");
      }
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

// ============ MOT DE PASSE OUBLIÉ ============

/** Demande de réinitialisation — génère un code OTP 6 chiffres */
export const requestPasswordReset = mutation({
  args: { email: v.string() },
  handler: async (ctx, args) => {
    const email = args.email.toLowerCase().trim();

    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .unique();

    // Anti-enumeration : retourner silencieusement si user inexistant/inactif
    if (!user || !user.isActive || !user.isEmailVerified) {
      return { email, code: null, name: null };
    }

    // Invalider ancien code
    const existing = await ctx.db
      .query("password_resets")
      .withIndex("by_email", (q) => q.eq("email", email))
      .order("desc")
      .first();
    if (existing && existing.usedAt === undefined) {
      await ctx.db.patch(existing._id, { usedAt: Date.now() });
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();

    await ctx.db.insert("password_resets", {
      email,
      code,
      expiresAt: Date.now() + 15 * 60 * 1000,
      attempts: 0,
      createdAt: Date.now(),
    });

    return { email, code, name: user.name };
  },
});

/** Vérification du code de réinitialisation */
export const verifyResetCode = mutation({
  args: { email: v.string(), code: v.string() },
  handler: async (ctx, args) => {
    const email = args.email.toLowerCase().trim();

    const reset = await ctx.db
      .query("password_resets")
      .withIndex("by_email", (q) => q.eq("email", email))
      .order("desc")
      .first();

    if (!reset || reset.usedAt !== undefined) {
      throw new Error("Code invalide ou déjà utilisé");
    }
    if (reset.expiresAt < Date.now()) {
      throw new Error("Code expiré. Demandez un nouveau code.");
    }
    if (reset.attempts >= 5) {
      throw new Error("Trop de tentatives. Demandez un nouveau code.");
    }
    if (reset.code !== args.code) {
      await ctx.db.patch(reset._id, { attempts: reset.attempts + 1 });
      throw new Error("Code incorrect");
    }

    return { valid: true, email };
  },
});

/** Réinitialisation du mot de passe — vérifie le code et change le password */
export const resetPassword = mutation({
  args: { email: v.string(), code: v.string(), newPassword: v.string() },
  handler: async (ctx, args) => {
    const email = args.email.toLowerCase().trim();

    if (args.newPassword.length < 6) {
      throw new Error("Le mot de passe doit comporter au moins 6 caractères");
    }

    // Re-valider le code
    const reset = await ctx.db
      .query("password_resets")
      .withIndex("by_email", (q) => q.eq("email", email))
      .order("desc")
      .first();

    if (!reset || reset.usedAt !== undefined) {
      throw new Error("Code invalide ou déjà utilisé");
    }
    if (reset.expiresAt < Date.now()) {
      throw new Error("Code expiré");
    }
    if (reset.code !== args.code) {
      throw new Error("Code incorrect");
    }

    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .unique();

    if (!user || !user.isActive) {
      throw new Error("Utilisateur non trouvé");
    }

    // Hasher le nouveau mot de passe
    const salt = generateSalt();
    const passwordHash = await hashPassword(args.newPassword, salt);
    await ctx.db.patch(user._id, { passwordHash });

    // Marquer le code comme utilisé
    await ctx.db.patch(reset._id, { usedAt: Date.now() });

    // Invalider TOUTES les sessions (sécurité : forcer re-login partout)
    const sessions = await ctx.db
      .query("auth_sessions")
      .withIndex("by_userId", (q) => q.eq("userId", user._id))
      .collect();
    for (const session of sessions) {
      await ctx.db.delete(session._id);
    }

    return { success: true };
  },
});

/** Envoi email de réinitialisation via Resend */
export const sendPasswordResetEmail = internalAction({
  args: { email: v.string(), name: v.string(), code: v.string() },
  handler: async (_ctx, args) => {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: "Bearer re_ao3Jzvg4_AGcwbQaiVzztZRDZk7s1FcH7",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Amara <noreply@elevenjobs.io>",
        to: [args.email],
        subject: "Réinitialisation de votre mot de passe Amara",
        html: buildPasswordResetEmailTemplate(args.name, args.code),
      }),
    });
    if (!response.ok) {
      const body = await response.text();
      throw new Error(`Échec envoi email: ${body}`);
    }
  },
});

function buildPasswordResetEmailTemplate(name: string, code: string): string {
  const digits = code.split("").join("</td><td style=\"width:48px;height:56px;background:#1A1228;border:1px solid #2E2245;border-radius:10px;text-align:center;vertical-align:middle;font-size:26px;font-weight:700;color:#FFFFFF;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;\">");
  return `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="color-scheme" content="dark">
</head>
<body style="margin:0;padding:0;background:#F4F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F4F4F6;min-height:100vh;">
    <tr><td align="center" style="padding:48px 20px;">
      <table role="presentation" width="520" cellpadding="0" cellspacing="0" style="max-width:520px;width:100%;background:#120E1C;border-radius:24px;border:1px solid #1E1730;overflow:hidden;">
        <tr><td style="height:3px;background:linear-gradient(90deg,#E62050 0%,#FF6B8A 50%,#E62050 100%);"></td></tr>
        <tr><td style="padding:40px 48px 32px;">
          <table role="presentation" cellpadding="0" cellspacing="0">
            <tr>
              <td style="width:40px;height:40px;background:linear-gradient(135deg,#E62050,#C0003A);border-radius:10px;text-align:center;vertical-align:middle;">
                <span style="color:#FFFFFF;font-size:20px;font-weight:900;line-height:40px;">A</span>
              </td>
              <td style="padding-left:12px;vertical-align:middle;">
                <span style="color:#FFFFFF;font-size:20px;font-weight:700;letter-spacing:-0.3px;">Amara</span>
              </td>
            </tr>
          </table>
        </td></tr>
        <tr><td style="padding:0 48px;"><div style="height:1px;background:#1E1730;"></div></td></tr>
        <tr><td style="padding:36px 48px 40px;">
          <p style="margin:0 0 6px;color:#9B93A8;font-size:13px;font-weight:500;text-transform:uppercase;letter-spacing:1px;">Réinitialisation du mot de passe</p>
          <h1 style="margin:0 0 20px;color:#FFFFFF;font-size:22px;font-weight:700;line-height:1.3;">Bonjour ${name} 👋</h1>
          <p style="margin:0 0 32px;color:#7A7287;font-size:15px;line-height:1.7;">
            Utilisez le code ci-dessous pour réinitialiser votre mot de passe. Il est valable <span style="color:#FFFFFF;font-weight:600;">15 minutes</span>.
          </p>
          <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 auto 32px;border-collapse:separate;border-spacing:8px 0;">
            <tr>
              <td style="width:48px;height:56px;background:#1A1228;border:1px solid #2E2245;border-radius:10px;text-align:center;vertical-align:middle;font-size:26px;font-weight:700;color:#FFFFFF;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">${digits}</td>
            </tr>
          </table>
          <table role="presentation" cellpadding="0" cellspacing="0" style="background:#1A1228;border-radius:12px;border:1px solid #1E1730;width:100%;">
            <tr>
              <td style="padding:16px 20px;">
                <p style="margin:0;color:#5C5468;font-size:13px;line-height:1.6;">
                  🔒 &nbsp;Si vous n'avez pas demandé cette réinitialisation, ignorez simplement cet email. Votre mot de passe restera inchangé.
                </p>
              </td>
            </tr>
          </table>
        </td></tr>
        <tr><td style="padding:20px 48px 28px;border-top:1px solid #1E1730;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
            <tr>
              <td style="color:#3D3549;font-size:12px;">© 2025 Amara</td>
              <td align="right" style="color:#3D3549;font-size:12px;">
                <a href="https://elevenjobs.io" style="color:#5C5468;text-decoration:none;">elevenjobs.io</a>
              </td>
            </tr>
          </table>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

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
