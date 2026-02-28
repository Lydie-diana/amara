import { mutation } from "./_generated/server";

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

/**
 * Crée ou met à jour un compte admin avec un mot de passe.
 * Usage: npx convex run createAdmin:run
 */
export const run = mutation({
  handler: async (ctx) => {
    const email = "admin@amara.ci";
    const password = "Admin2024!";

    const salt = generateSalt();
    const passwordHash = await hashPassword(password, salt);

    // Check if admin already exists
    const existing = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", email))
      .unique();

    if (existing) {
      // Update with password
      await ctx.db.patch(existing._id, {
        passwordHash,
        role: "admin",
        isActive: true,
      });
      return { action: "updated", email, password };
    }

    // Create new admin
    await ctx.db.insert("users", {
      name: "Admin Amara",
      email,
      phone: "+2250700000000",
      passwordHash,
      role: "admin",
      isActive: true,
      onboardingCompleted: true,
      preferredLanguage: "fr",
      createdAt: Date.now(),
    });

    return { action: "created", email, password };
  },
});
