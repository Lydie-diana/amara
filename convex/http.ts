import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { internal, api } from "./_generated/api";

const http = httpRouter();

// ============ CORS HELPER ============

function cors(response: Response): Response {
  const headers = new Headers(response.headers);
  headers.set("Access-Control-Allow-Origin", "*");
  headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  return new Response(response.body, { status: response.status, headers });
}

function json(data: unknown, status = 200): Response {
  return cors(
    new Response(JSON.stringify(data), {
      status,
      headers: { "Content-Type": "application/json" },
    })
  );
}

function error(message: string, status = 400): Response {
  return json({ error: message }, status);
}

// ============ PREFLIGHT OPTIONS ============

const preflight = httpAction(async () => {
  return cors(new Response(null, { status: 204 }));
});

// ============ AUTH ============

/** POST /api/auth/signup — Inscription email/password avec vérification email */
http.route({
  path: "/api/auth/signup",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { name, email, phone, password } = body;
      if (!name || !email || !phone || !password) {
        return error("Champs requis: name, email, phone, password");
      }
      const role = body.role; // "client" | "restaurant" | "livreur" (optionnel)

      // 1. Créer user inactif + code OTP (mutation)
      const result = await ctx.runMutation(api.auth.signup, {
        name, email, phone, password,
        ...(role ? { role } : {}),
      });

      // 2. Envoyer email de vérification via Resend (non-bloquant si domaine non vérifié)
      let emailSent = true;
      try {
        await ctx.runAction(internal.auth.sendVerificationEmail, {
          email: result.email,
          name: result.name,
          code: result.code,
        });
      } catch (emailErr: any) {
        console.error("[signup] Échec envoi email:", emailErr.message);
        emailSent = false;
      }

      // 3. Retourner au client Flutter (sans le code !)
      return json({ pendingUserId: result.pendingUserId, email: result.email, emailSent });
    } catch (e: any) {
      return error(e.message ?? "Erreur signup", 400);
    }
  }),
});

http.route({ path: "/api/auth/signup", method: "OPTIONS", handler: preflight });

/** POST /api/auth/verify-email — Vérification du code OTP */
http.route({
  path: "/api/auth/verify-email",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { pendingUserId, code } = body;
      if (!pendingUserId || !code) {
        return error("Champs requis: pendingUserId, code");
      }
      const result = await ctx.runMutation(api.auth.verifyEmail, {
        pendingUserId,
        code,
      });
      return json(result); // { token, userId }
    } catch (e: any) {
      return error(e.message ?? "Code invalide", 400);
    }
  }),
});

http.route({ path: "/api/auth/verify-email", method: "OPTIONS", handler: preflight });

/** POST /api/auth/resend-verification — Renvoi du code OTP */
http.route({
  path: "/api/auth/resend-verification",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { pendingUserId } = body;
      if (!pendingUserId) return error("pendingUserId requis");

      const result = await ctx.runMutation(api.auth.resendVerification, { pendingUserId });

      try {
        await ctx.runAction(internal.auth.sendVerificationEmail, {
          email: result.email,
          name: result.name,
          code: result.code,
        });
      } catch (emailErr: any) {
        console.error("[resend] Échec envoi email:", emailErr.message);
      }

      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur renvoi", 400);
    }
  }),
});

http.route({ path: "/api/auth/resend-verification", method: "OPTIONS", handler: preflight });

/** POST /api/auth/login — Connexion email/password */
http.route({
  path: "/api/auth/login",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { email, password } = body;
      if (!email || !password) {
        return error("Champs requis: email, password");
      }
      const result = await ctx.runMutation(api.auth.login, { email, password });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur login", 401);
    }
  }),
});

http.route({ path: "/api/auth/login", method: "OPTIONS", handler: preflight });

/** POST /api/auth/logout — Déconnexion */
http.route({
  path: "/api/auth/logout",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { token } = body;
      if (!token) return error("Token requis");
      await ctx.runMutation(api.auth.logout, { token });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur logout");
    }
  }),
});

http.route({ path: "/api/auth/logout", method: "OPTIONS", handler: preflight });

/** GET /api/auth/me — Utilisateur courant (token en header Authorization: Bearer <token>) */
http.route({
  path: "/api/auth/me",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const user = await ctx.runQuery(api.auth.currentUserByToken, { token });
      if (!user) return error("Session invalide ou expirée", 401);
      return json(user);
    } catch (e: any) {
      return error(e.message ?? "Erreur session", 401);
    }
  }),
});

http.route({ path: "/api/auth/me", method: "OPTIONS", handler: preflight });

/** POST /api/auth/update-profile — Mise à jour du profil */
http.route({
  path: "/api/auth/update-profile",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { name, phone, imageUrl } = body;
      const result = await ctx.runMutation(api.auth.updateProfile, {
        token,
        name,
        phone,
        imageUrl,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur mise à jour profil", 400);
    }
  }),
});

http.route({ path: "/api/auth/update-profile", method: "OPTIONS", handler: preflight });

// ============ MOT DE PASSE OUBLIÉ ============

/** POST /api/auth/forgot-password — Demande de réinitialisation */
http.route({
  path: "/api/auth/forgot-password",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { email } = body;
      if (!email) return error("Email requis");

      const result = await ctx.runMutation(api.auth.requestPasswordReset, { email });

      // Envoyer email si user trouvé (code + name non null)
      if (result.code && result.name) {
        try {
          await ctx.runAction(internal.auth.sendPasswordResetEmail, {
            email: result.email,
            name: result.name,
            code: result.code,
          });
        } catch (emailErr: any) {
          console.error("[forgot-password] Échec envoi email:", emailErr.message);
        }
      }

      // Toujours retourner succès (anti-enumeration)
      return json({ success: true, email: result.email });
    } catch (e: any) {
      return error(e.message ?? "Erreur", 400);
    }
  }),
});

http.route({ path: "/api/auth/forgot-password", method: "OPTIONS", handler: preflight });

/** POST /api/auth/verify-reset-code — Vérification du code OTP de réinitialisation */
http.route({
  path: "/api/auth/verify-reset-code",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { email, code } = body;
      if (!email || !code) return error("Champs requis: email, code");

      const result = await ctx.runMutation(api.auth.verifyResetCode, { email, code });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Code invalide", 400);
    }
  }),
});

http.route({ path: "/api/auth/verify-reset-code", method: "OPTIONS", handler: preflight });

/** POST /api/auth/reset-password — Réinitialisation du mot de passe */
http.route({
  path: "/api/auth/reset-password",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const body = await request.json();
      const { email, code, newPassword } = body;
      if (!email || !code || !newPassword) {
        return error("Champs requis: email, code, newPassword");
      }

      const result = await ctx.runMutation(api.auth.resetPassword, {
        email, code, newPassword,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur réinitialisation", 400);
    }
  }),
});

http.route({ path: "/api/auth/reset-password", method: "OPTIONS", handler: preflight });

// ============ FAVORIS ============

/** GET /api/favorites — Liste des restaurant IDs favoris */
http.route({
  path: "/api/favorites",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const ids = await ctx.runQuery(api.favorites.list, { token });
      return json(ids);
    } catch (e: any) {
      return error(e.message ?? "Erreur favoris");
    }
  }),
});

http.route({ path: "/api/favorites", method: "OPTIONS", handler: preflight });

/** POST /api/favorites/toggle — Toggle favori */
http.route({
  path: "/api/favorites/toggle",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { restaurantId } = body;
      if (!restaurantId) return error("restaurantId requis");
      const result = await ctx.runMutation(api.favorites.toggle, {
        token,
        restaurantId: restaurantId as any,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur toggle favori");
    }
  }),
});

http.route({ path: "/api/favorites/toggle", method: "OPTIONS", handler: preflight });

// ============ PROMOTIONS ============

/** GET /api/promotions?city=Abidjan — Banners promotionnels actifs */
http.route({
  path: "/api/promotions",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const city = url.searchParams.get("city") ?? undefined;
      const promos = await ctx.runQuery(api.promotions.listActive, { city });
      return json(promos);
    } catch (e: any) {
      return error(e.message ?? "Erreur promotions");
    }
  }),
});

http.route({ path: "/api/promotions", method: "OPTIONS", handler: preflight });

// ============ CATÉGORIES CUISINE ============

/** GET /api/categories — Catégories cuisine actives */
http.route({
  path: "/api/categories",
  method: "GET",
  handler: httpAction(async (ctx) => {
    try {
      const categories = await ctx.runQuery(api.foodCategories.listActive, {});
      return json(categories);
    } catch (e: any) {
      return error(e.message ?? "Erreur catégories");
    }
  }),
});

http.route({ path: "/api/categories", method: "OPTIONS", handler: preflight });

// ============ SUGGESTIONS D'ADRESSES ============

/** GET /api/addresses?city=Abidjan — Suggestions d'adresses */
http.route({
  path: "/api/addresses",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const city = url.searchParams.get("city") ?? undefined;
      const addresses = await ctx.runQuery(api.addressSuggestions.list, { city });
      return json(addresses);
    } catch (e: any) {
      return error(e.message ?? "Erreur suggestions adresses");
    }
  }),
});

http.route({ path: "/api/addresses", method: "OPTIONS", handler: preflight });

// ============ RESTAURANTS ============

/** GET /api/restaurants?city=Abidjan — Liste des restaurants d'une ville */
http.route({
  path: "/api/restaurants",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const city = url.searchParams.get("city") ?? "Abidjan";
      const restaurants = await ctx.runQuery(api.restaurants.listByCity, { city });
      return json(restaurants);
    } catch (e: any) {
      return error(e.message ?? "Erreur restaurants");
    }
  }),
});

http.route({ path: "/api/restaurants", method: "OPTIONS", handler: preflight });

/** GET /api/restaurants/nearby?lat=5.35&lng=-4.00&radius=15 — Restaurants à proximité GPS */
http.route({
  path: "/api/restaurants/nearby",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const lat = parseFloat(url.searchParams.get("lat") ?? "");
      const lng = parseFloat(url.searchParams.get("lng") ?? "");
      const radius = parseFloat(url.searchParams.get("radius") ?? "15");
      if (isNaN(lat) || isNaN(lng)) return error("Paramètres lat et lng requis");
      const restaurants = await ctx.runQuery(api.restaurants.listNearby, {
        latitude: lat,
        longitude: lng,
        radiusKm: isNaN(radius) ? 15 : radius,
      });
      return json(restaurants);
    } catch (e: any) {
      return error(e.message ?? "Erreur restaurants nearby");
    }
  }),
});

http.route({ path: "/api/restaurants/nearby", method: "OPTIONS", handler: preflight });

/** GET /api/restaurants/:id — Détail d'un restaurant */
http.route({
  path: "/api/restaurant",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const restaurantId = url.searchParams.get("id");
      if (!restaurantId) return error("id requis");
      const restaurant = await ctx.runQuery(api.restaurants.getById, {
        restaurantId: restaurantId as any,
      });
      if (!restaurant) return error("Restaurant non trouvé", 404);
      return json(restaurant);
    } catch (e: any) {
      return error(e.message ?? "Erreur restaurant", 404);
    }
  }),
});

http.route({ path: "/api/restaurant", method: "OPTIONS", handler: preflight });

/** GET /api/restaurant/stats?id=xxx — Stats restaurant (clients uniques, total commandes) */
http.route({
  path: "/api/restaurant/stats",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const restaurantId = url.searchParams.get("id");
      if (!restaurantId) return error("id requis");
      const stats = await ctx.runQuery(api.restaurants.stats, {
        restaurantId: restaurantId as any,
      });
      return json(stats);
    } catch (e: any) {
      return error(e.message ?? "Erreur stats restaurant");
    }
  }),
});

http.route({ path: "/api/restaurant/stats", method: "OPTIONS", handler: preflight });

// ============ MENU ============

/** GET /api/menu?restaurantId=xxx — Menu complet d'un restaurant */
http.route({
  path: "/api/menu",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const restaurantId = url.searchParams.get("restaurantId");
      if (!restaurantId) return error("restaurantId requis");
      const items = await ctx.runQuery(api.menuItems.byRestaurant, {
        restaurantId: restaurantId as any,
      });
      return json(items);
    } catch (e: any) {
      return error(e.message ?? "Erreur menu");
    }
  }),
});

http.route({ path: "/api/menu", method: "OPTIONS", handler: preflight });

/** GET /api/search?q=eru — Recherche de plats par nom, retourne les restaurantIds */
http.route({
  path: "/api/search",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const query = url.searchParams.get("q") ?? "";
      if (query.length < 2) return json([]);
      const results = await ctx.runQuery(api.menuItems.searchByName, { query });
      return json(results);
    } catch (e: any) {
      return error(e.message ?? "Erreur recherche");
    }
  }),
});

http.route({ path: "/api/search", method: "OPTIONS", handler: preflight });

/** GET /api/restaurants/promos — IDs des restaurants ayant des plats en promo */
http.route({
  path: "/api/restaurants/promos",
  method: "GET",
  handler: httpAction(async (ctx, _request) => {
    try {
      const ids = await ctx.runQuery(api.menuItems.restaurantsWithPromos, {});
      return json(ids);
    } catch (e: any) {
      return error(e.message ?? "Erreur promos");
    }
  }),
});

http.route({ path: "/api/restaurants/promos", method: "OPTIONS", handler: preflight });

// ============ COMMANDES ============

/** GET /api/orders — Mes commandes (client connecté) */
http.route({
  path: "/api/orders",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const orders = await ctx.runQuery(api.orders.myOrders, { token });
      return json(orders);
    } catch (e: any) {
      return error(e.message ?? "Erreur commandes", 401);
    }
  }),
});

http.route({ path: "/api/orders", method: "OPTIONS", handler: preflight });

/** POST /api/orders — Créer une commande */
http.route({
  path: "/api/orders",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const {
        restaurantId,
        items,
        deliveryAddress,
        deliveryLatitude,
        deliveryLongitude,
        paymentMethod,
        clientNote,
        orderType,
      } = body;
      const isPickup = orderType === "pickup";
      if (!restaurantId || !items || !paymentMethod) {
        return error("Champs requis manquants");
      }
      if (!isPickup && !deliveryAddress) {
        return error("Adresse de livraison requise pour une commande en livraison");
      }
      const orderId = await ctx.runMutation(api.orders.create, {
        restaurantId,
        items,
        deliveryAddress: deliveryAddress ?? undefined,
        deliveryLatitude: deliveryLatitude ?? undefined,
        deliveryLongitude: deliveryLongitude ?? undefined,
        paymentMethod,
        clientNote,
        orderType: isPickup ? "pickup" : "delivery",
        token,
      });
      return json({ orderId });
    } catch (e: any) {
      return error(e.message ?? "Erreur création commande");
    }
  }),
});

/** GET /api/orders/:id — Détail d'une commande */
http.route({
  path: "/api/order",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const orderId = url.searchParams.get("id");
      if (!orderId) return error("id requis");
      const order = await ctx.runQuery(api.orders.getById, {
        orderId: orderId as any,
        token,
      });
      // Enrichir avec les coordonnées du restaurant pour le tracking
      let enriched = order as any;
      if (order && (order as any).restaurantId) {
        try {
          const restaurant = await ctx.runQuery(api.restaurants.getById, {
            restaurantId: (order as any).restaurantId,
          });
          if (restaurant) {
            enriched = {
              ...order,
              restaurantLatitude: (restaurant as any).latitude,
              restaurantLongitude: (restaurant as any).longitude,
              restaurantName: (restaurant as any).name,
              restaurantImageUrl: (restaurant as any).imageUrl ?? null,
            };
          }
        } catch (_) {}
      }
      // Enrichir avec le nom du livreur
      if (enriched.livreurId) {
        try {
          const livreur = await ctx.runQuery(api.auth.getUserById, {
            userId: enriched.livreurId,
          });
          if (livreur) {
            enriched = { ...enriched, livreurName: (livreur as any).name ?? "Livreur" };
          }
        } catch (_) {}
      }
      return json(enriched);
    } catch (e: any) {
      return error(e.message ?? "Erreur commande", 404);
    }
  }),
});

http.route({ path: "/api/order", method: "OPTIONS", handler: preflight });

/** PATCH /api/order/status — Mettre à jour le statut d'une commande */
http.route({
  path: "/api/order/status",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { orderId, status, reason } = body;
      if (!orderId || !status) return error("orderId et status requis");
      await ctx.runMutation(api.orders.updateStatus, {
        orderId: orderId as any,
        status,
        reason,
        token,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur mise à jour statut");
    }
  }),
});

http.route({ path: "/api/order/status", method: "OPTIONS", handler: preflight });

// ============ LIVREUR — PROFIL ============

/** GET /api/driver/profile — Profil livreur connecté */
http.route({
  path: "/api/driver/profile",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const profile = await ctx.runQuery(api.drivers.getProfile, { token });
      return json(profile);
    } catch (e: any) {
      return error(e.message ?? "Erreur profil livreur", 400);
    }
  }),
});

http.route({ path: "/api/driver/profile", method: "OPTIONS", handler: preflight });

/** POST /api/driver/profile — Créer profil livreur (onboarding) */
http.route({
  path: "/api/driver/profile",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { vehicleType, vehiclePlate, licenseNumber, idCardUrl, licenseUrl, vehiclePhotoUrl } = body;
      if (!vehicleType) return error("vehicleType requis");
      const profileId = await ctx.runMutation(api.drivers.createProfile, {
        token,
        vehicleType,
        vehiclePlate,
        licenseNumber,
        idCardUrl,
        licenseUrl,
        vehiclePhotoUrl,
      });
      return json({ profileId });
    } catch (e: any) {
      return error(e.message ?? "Erreur création profil", 400);
    }
  }),
});

/** PATCH /api/driver/profile — Mettre à jour profil livreur */
http.route({
  path: "/api/driver/profile/update",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const result = await ctx.runMutation(api.drivers.updateProfile, {
        token,
        vehicleType: body.vehicleType,
        vehiclePlate: body.vehiclePlate,
        licenseNumber: body.licenseNumber,
        idCardUrl: body.idCardUrl,
        licenseUrl: body.licenseUrl,
        vehiclePhotoUrl: body.vehiclePhotoUrl,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur mise à jour profil", 400);
    }
  }),
});

http.route({ path: "/api/driver/profile/update", method: "OPTIONS", handler: preflight });

// ============ LIVREUR — EN LIGNE / HORS LIGNE ============

/** POST /api/driver/toggle-online — Toggle en ligne/hors ligne */
http.route({
  path: "/api/driver/toggle-online",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const result = await ctx.runMutation(api.drivers.toggleOnline, { token });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur toggle online", 400);
    }
  }),
});

http.route({ path: "/api/driver/toggle-online", method: "OPTIONS", handler: preflight });

// ============ LIVREUR — LOCALISATION GPS ============

/** POST /api/driver/location — Mettre à jour la position GPS */
http.route({
  path: "/api/driver/location",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { latitude, longitude, isAvailable } = body;
      if (latitude === undefined || longitude === undefined) {
        return error("latitude et longitude requis");
      }
      const result = await ctx.runMutation(api.locations.updateLocation, {
        token,
        latitude,
        longitude,
        isAvailable: isAvailable ?? true,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur mise à jour position", 400);
    }
  }),
});

http.route({ path: "/api/driver/location", method: "OPTIONS", handler: preflight });

/** GET /api/driver/location/track?livreurId=xxx — Position d'un livreur (pour le client) */
http.route({
  path: "/api/driver/location/track",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const livreurId = url.searchParams.get("livreurId");
      if (!livreurId) return error("livreurId requis");
      const location = await ctx.runQuery(api.locations.getByLivreurId, {
        livreurId: livreurId as any,
      });
      if (!location) return json(null);
      return json(location);
    } catch (e: any) {
      return error(e.message ?? "Erreur position livreur", 400);
    }
  }),
});

http.route({ path: "/api/driver/location/track", method: "OPTIONS", handler: preflight });

// ============ LIVREUR — MES LIVRAISONS ============

/** GET /api/driver/deliveries — Commandes assignées au livreur */
http.route({
  path: "/api/driver/deliveries",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const deliveries = await ctx.runQuery(api.orders.myDeliveries, { token });
      return json(deliveries);
    } catch (e: any) {
      return error(e.message ?? "Erreur livraisons", 400);
    }
  }),
});

http.route({ path: "/api/driver/deliveries", method: "OPTIONS", handler: preflight });

// ============ LIVREUR — DISPATCH ============

/** GET /api/driver/dispatch — Demandes de dispatch en attente */
http.route({
  path: "/api/driver/dispatch",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const dispatches = await ctx.runQuery(api.dispatch.pendingForDriver, { token });
      return json(dispatches);
    } catch (e: any) {
      return error(e.message ?? "Erreur dispatch", 400);
    }
  }),
});

http.route({ path: "/api/driver/dispatch", method: "OPTIONS", handler: preflight });

/** POST /api/driver/dispatch/accept — Accepter un dispatch */
http.route({
  path: "/api/driver/dispatch/accept",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { dispatchId } = body;
      if (!dispatchId) return error("dispatchId requis");
      const result = await ctx.runMutation(api.dispatch.acceptDispatch, {
        dispatchId: dispatchId as any,
        token,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur acceptation dispatch", 400);
    }
  }),
});

http.route({ path: "/api/driver/dispatch/accept", method: "OPTIONS", handler: preflight });

/** POST /api/driver/dispatch/refuse — Refuser un dispatch */
http.route({
  path: "/api/driver/dispatch/refuse",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { dispatchId } = body;
      if (!dispatchId) return error("dispatchId requis");
      const result = await ctx.runMutation(api.dispatch.refuseDispatch, {
        dispatchId: dispatchId as any,
        token,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur refus dispatch", 400);
    }
  }),
});

http.route({ path: "/api/driver/dispatch/refuse", method: "OPTIONS", handler: preflight });

/** POST /api/driver/dispatch/create — Créer un dispatch (admin/ops) */
http.route({
  path: "/api/driver/dispatch/create",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { orderId, driverId, expiresInSeconds } = body;
      if (!orderId || !driverId) return error("orderId et driverId requis");
      const dispatchId = await ctx.runMutation(api.dispatch.createDispatch, {
        orderId: orderId as any,
        driverId: driverId as any,
        expiresInSeconds,
        token,
      });
      return json({ dispatchId });
    } catch (e: any) {
      return error(e.message ?? "Erreur création dispatch", 400);
    }
  }),
});

http.route({ path: "/api/driver/dispatch/create", method: "OPTIONS", handler: preflight });

// ============ AVIS / REVIEWS ============

/** POST /api/review — Soumettre un avis (restaurant + livreur) */
http.route({
  path: "/api/review",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { orderId, rating, driverRating, comment } = body;
      if (!orderId || !rating) return error("orderId et rating requis");
      const result = await ctx.runMutation(api.reviews.submit, {
        orderId: orderId as any,
        rating,
        driverRating,
        comment,
        token,
      });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur soumission avis", 400);
    }
  }),
});

http.route({ path: "/api/review", method: "OPTIONS", handler: preflight });

/** GET /api/review/check?orderId=xxx — Vérifier si un avis existe déjà */
http.route({
  path: "/api/review/check",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const orderId = url.searchParams.get("orderId");
      if (!orderId) return error("orderId requis");
      const hasReview = await ctx.runQuery(api.reviews.hasReview, {
        orderId: orderId as any,
        token,
      });
      return json({ hasReview });
    } catch (e: any) {
      return error(e.message ?? "Erreur vérification avis", 400);
    }
  }),
});

http.route({ path: "/api/review/check", method: "OPTIONS", handler: preflight });

/** GET /api/reviews?restaurantId=xxx — Avis d'un restaurant */
http.route({
  path: "/api/reviews",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const restaurantId = url.searchParams.get("restaurantId");
      if (!restaurantId) return error("restaurantId requis");
      const reviews = await ctx.runQuery(api.reviews.byRestaurant, {
        restaurantId: restaurantId as any,
      });
      return json(reviews);
    } catch (e: any) {
      return error(e.message ?? "Erreur récupération avis", 400);
    }
  }),
});

http.route({ path: "/api/reviews", method: "OPTIONS", handler: preflight });

/** GET /api/reviews/driver — Avis reçus par le livreur connecté */
http.route({
  path: "/api/reviews/driver",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const limit = url.searchParams.get("limit");
      const reviews = await ctx.runQuery(api.reviews.myDriverReviews, {
        token,
        ...(limit ? { limit: parseInt(limit) } : {}),
      });
      return json(reviews);
    } catch (e: any) {
      return error(e.message ?? "Erreur récupération avis livreur", 400);
    }
  }),
});

http.route({ path: "/api/reviews/driver", method: "OPTIONS", handler: preflight });

// ============ WEBHOOK CLERK (existant) ============

http.route({
  path: "/clerk-webhook",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const svixId = request.headers.get("svix-id");
    const svixTimestamp = request.headers.get("svix-timestamp");
    const svixSignature = request.headers.get("svix-signature");

    if (!svixId || !svixTimestamp || !svixSignature) {
      return new Response("Headers Svix manquants", { status: 400 });
    }

    const body = await request.text();

    let payload: any;
    try {
      payload = JSON.parse(body);
    } catch {
      return new Response("JSON invalide", { status: 400 });
    }

    const eventType = payload.type;

    switch (eventType) {
      case "user.created":
      case "user.updated": {
        const { id, email_addresses, phone_numbers, first_name, last_name, image_url } = payload.data;
        const email = email_addresses?.[0]?.email_address ?? "";
        const phone = phone_numbers?.[0]?.phone_number ?? "";
        const name = [first_name, last_name].filter(Boolean).join(" ") || "Utilisateur";
        await ctx.runMutation(internal.users.syncFromWebhook, {
          externalId: id, name, email, phone, imageUrl: image_url ?? undefined,
        });
        break;
      }
      case "user.deleted": {
        if (payload.data?.id) {
          await ctx.runMutation(internal.users.deactivateByExternalId, {
            externalId: payload.data.id,
          });
        }
        break;
      }
    }

    return new Response("OK", { status: 200 });
  }),
});

// ============ ADMIN — DASHBOARD STATS ============

/** GET /api/admin/stats — KPIs agrégés */
http.route({
  path: "/api/admin/stats",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const stats = await ctx.runQuery(api.adminStats.dashboardStats, { token });
      return json(stats);
    } catch (e: any) {
      return error(e.message ?? "Erreur stats", 400);
    }
  }),
});

http.route({ path: "/api/admin/stats", method: "OPTIONS", handler: preflight });

/** GET /api/admin/orders/recent?limit=10 — Dernières commandes */
http.route({
  path: "/api/admin/orders/recent",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const limit = url.searchParams.get("limit");
      const orders = await ctx.runQuery(api.adminStats.recentOrders, {
        token,
        ...(limit ? { limit: parseInt(limit) } : {}),
      });
      return json(orders);
    } catch (e: any) {
      return error(e.message ?? "Erreur commandes récentes", 400);
    }
  }),
});

http.route({ path: "/api/admin/orders/recent", method: "OPTIONS", handler: preflight });

/** GET /api/admin/orders/all?status=pending&limit=100 — Toutes les commandes (filtrées) */
http.route({
  path: "/api/admin/orders/all",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const status = url.searchParams.get("status") ?? undefined;
      const limit = url.searchParams.get("limit");
      const orders = await ctx.runQuery(api.adminStats.allOrders, {
        token,
        ...(status ? { status: status as any } : {}),
        ...(limit ? { limit: parseInt(limit) } : {}),
      });
      return json(orders);
    } catch (e: any) {
      return error(e.message ?? "Erreur commandes admin", 400);
    }
  }),
});

http.route({ path: "/api/admin/orders/all", method: "OPTIONS", handler: preflight });

/** GET /api/admin/order?id=xxx — Détail commande admin (enrichi) */
http.route({
  path: "/api/admin/order",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const orderId = url.searchParams.get("id");
      if (!orderId) return error("id requis");
      const order = await ctx.runQuery(api.orders.getById, {
        orderId: orderId as any,
        token,
      });
      if (!order) return error("Commande non trouvée", 404);
      // Enrichir
      let enriched = order as any;
      const restaurant = await ctx.runQuery(api.restaurants.getById, {
        restaurantId: (order as any).restaurantId,
      });
      const client = await ctx.runQuery(api.auth.getUserById, {
        userId: (order as any).clientId,
      });
      enriched = {
        ...order,
        restaurantName: restaurant?.name ?? "Restaurant",
        restaurantAddress: (restaurant as any)?.address ?? "",
        clientName: (client as any)?.name ?? "Client",
        clientPhone: (client as any)?.phone ?? "",
        clientEmail: (client as any)?.email ?? "",
      };
      if (enriched.livreurId) {
        try {
          const livreur = await ctx.runQuery(api.auth.getUserById, {
            userId: enriched.livreurId,
          });
          enriched.livreurName = (livreur as any)?.name ?? "Livreur";
        } catch (_) {}
      }
      return json(enriched);
    } catch (e: any) {
      return error(e.message ?? "Erreur détail commande", 400);
    }
  }),
});

http.route({ path: "/api/admin/order", method: "OPTIONS", handler: preflight });

/** POST /api/admin/order/assign — Assigner livreur */
http.route({
  path: "/api/admin/order/assign",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { orderId, livreurId } = body;
      if (!orderId || !livreurId) return error("orderId et livreurId requis");
      await ctx.runMutation(api.orders.assignLivreur, {
        token,
        orderId: orderId as any,
        livreurId: livreurId as any,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur assignation", 400);
    }
  }),
});

http.route({ path: "/api/admin/order/assign", method: "OPTIONS", handler: preflight });

/** POST /api/admin/order/retrigger-dispatch — Relancer le dispatch */
http.route({
  path: "/api/admin/order/retrigger-dispatch",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { orderId } = body;
      if (!orderId) return error("orderId requis");
      await ctx.runMutation(api.orders.retriggerDispatch, {
        orderId: orderId as any,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur retrigger dispatch", 400);
    }
  }),
});

http.route({ path: "/api/admin/order/retrigger-dispatch", method: "OPTIONS", handler: preflight });

/** GET /api/admin/order/history?orderId=xxx — Historique transitions */
http.route({
  path: "/api/admin/order/history",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const orderId = url.searchParams.get("orderId");
      if (!orderId) return error("orderId requis");
      const history = await ctx.runQuery(api.adminStats.orderHistory, {
        token,
        orderId: orderId as any,
      });
      return json(history);
    } catch (e: any) {
      return error(e.message ?? "Erreur historique", 400);
    }
  }),
});

http.route({ path: "/api/admin/order/history", method: "OPTIONS", handler: preflight });

// ============ ADMIN — RESTAURANTS ============

/** GET /api/admin/restaurants — Tous les restaurants */
http.route({
  path: "/api/admin/restaurants",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const restaurants = await ctx.runQuery(api.restaurants.listAll, { token });
      return json(restaurants);
    } catch (e: any) {
      return error(e.message ?? "Erreur restaurants admin", 400);
    }
  }),
});

http.route({ path: "/api/admin/restaurants", method: "OPTIONS", handler: preflight });

/** GET /api/admin/restaurants/pending — Restaurants non vérifiés */
http.route({
  path: "/api/admin/restaurants/pending",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const restaurants = await ctx.runQuery(api.restaurants.pendingVerification, { token });
      return json(restaurants);
    } catch (e: any) {
      return error(e.message ?? "Erreur restaurants pending", 400);
    }
  }),
});

http.route({ path: "/api/admin/restaurants/pending", method: "OPTIONS", handler: preflight });

/** POST /api/admin/restaurant/verify — Vérifier un restaurant */
http.route({
  path: "/api/admin/restaurant/verify",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { restaurantId } = body;
      if (!restaurantId) return error("restaurantId requis");
      await ctx.runMutation(api.restaurants.verify, {
        restaurantId: restaurantId as any,
        token,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur vérification restaurant", 400);
    }
  }),
});

http.route({ path: "/api/admin/restaurant/verify", method: "OPTIONS", handler: preflight });

/** POST /api/admin/restaurant/toggle-open — Forcer ouverture/fermeture */
http.route({
  path: "/api/admin/restaurant/toggle-open",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { restaurantId, isOpen } = body;
      if (!restaurantId || isOpen === undefined) return error("restaurantId et isOpen requis");
      await ctx.runMutation(api.restaurants.toggleOpen, {
        restaurantId: restaurantId as any,
        isOpen,
        token,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur toggle restaurant", 400);
    }
  }),
});

http.route({ path: "/api/admin/restaurant/toggle-open", method: "OPTIONS", handler: preflight });

// ============ ADMIN — USERS ============

/** GET /api/admin/users?role=client — Utilisateurs par rôle */
http.route({
  path: "/api/admin/users",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const role = url.searchParams.get("role") ?? "client";
      const users = await ctx.runQuery(api.users.listByRole, {
        token,
        role: role as any,
      });
      return json(users);
    } catch (e: any) {
      return error(e.message ?? "Erreur utilisateurs", 400);
    }
  }),
});

http.route({ path: "/api/admin/users", method: "OPTIONS", handler: preflight });

/** GET /api/admin/user?id=xxx — Détail utilisateur */
http.route({
  path: "/api/admin/user",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const userId = url.searchParams.get("id");
      if (!userId) return error("id requis");
      const user = await ctx.runQuery(api.users.getById, {
        userId: userId as any,
      });
      if (!user) return error("Utilisateur non trouvé", 404);
      // Retirer le hash du mot de passe
      const { passwordHash, ...safeUser } = user as any;
      return json(safeUser);
    } catch (e: any) {
      return error(e.message ?? "Erreur utilisateur", 400);
    }
  }),
});

http.route({ path: "/api/admin/user", method: "OPTIONS", handler: preflight });

/** POST /api/admin/user/suspend — Suspendre un utilisateur */
http.route({
  path: "/api/admin/user/suspend",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { userId, reason } = body;
      if (!userId || !reason) return error("userId et reason requis");
      await ctx.runMutation(api.users.suspendUser, {
        token,
        userId: userId as any,
        reason,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur suspension", 400);
    }
  }),
});

http.route({ path: "/api/admin/user/suspend", method: "OPTIONS", handler: preflight });

/** POST /api/admin/user/reactivate — Réactiver un utilisateur */
http.route({
  path: "/api/admin/user/reactivate",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { userId } = body;
      if (!userId) return error("userId requis");
      await ctx.runMutation(api.users.reactivateUser, {
        token,
        userId: userId as any,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur réactivation", 400);
    }
  }),
});

http.route({ path: "/api/admin/user/reactivate", method: "OPTIONS", handler: preflight });

// ============ ADMIN — DRIVERS ============

/** GET /api/admin/drivers — Tous les profils livreurs */
http.route({
  path: "/api/admin/drivers",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const allProfiles = await ctx.runQuery(api.adminStats.allDrivers, { token });
      return json(allProfiles);
    } catch (e: any) {
      return error(e.message ?? "Erreur livreurs", 400);
    }
  }),
});

http.route({ path: "/api/admin/drivers", method: "OPTIONS", handler: preflight });

/** GET /api/admin/drivers/online — Livreurs en ligne */
http.route({
  path: "/api/admin/drivers/online",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const profiles = await ctx.runQuery(api.drivers.listOnline, { token });
      return json(profiles);
    } catch (e: any) {
      return error(e.message ?? "Erreur livreurs en ligne", 400);
    }
  }),
});

http.route({ path: "/api/admin/drivers/online", method: "OPTIONS", handler: preflight });

/** GET /api/admin/driver — Détail d'un livreur par userId */
http.route({
  path: "/api/admin/driver",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const userId = url.searchParams.get("id");
      if (!userId) return error("id requis");
      const driver = await ctx.runQuery(api.adminStats.driverById, {
        token,
        userId: userId as any,
      });
      if (!driver) return error("Livreur introuvable", 404);
      return json(driver);
    } catch (e: any) {
      return error(e.message ?? "Erreur livreur", 400);
    }
  }),
});

http.route({ path: "/api/admin/driver", method: "OPTIONS", handler: preflight });

/** POST /api/admin/driver/verify — Vérifier un livreur */
http.route({
  path: "/api/admin/driver/verify",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { userId } = body;
      if (!userId) return error("userId requis");
      await ctx.runMutation(api.adminStats.verifyDriver, {
        token,
        userId: userId as any,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur vérification livreur", 400);
    }
  }),
});

http.route({ path: "/api/admin/driver/verify", method: "OPTIONS", handler: preflight });

// ============ ADMIN — AUDIT LOGS ============

/** GET /api/admin/audit-logs?limit=50 — Logs récents */
http.route({
  path: "/api/admin/audit-logs",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const limit = url.searchParams.get("limit");
      const logs = await ctx.runQuery(api.auditLogs.recent, {
        token,
        ...(limit ? { limit: parseInt(limit) } : {}),
      });
      return json(logs);
    } catch (e: any) {
      return error(e.message ?? "Erreur audit logs", 400);
    }
  }),
});

http.route({ path: "/api/admin/audit-logs", method: "OPTIONS", handler: preflight });

/** GET /api/admin/audit-logs/by-user?userId=xxx */
http.route({
  path: "/api/admin/audit-logs/by-user",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const userId = url.searchParams.get("userId");
      if (!userId) return error("userId requis");
      const logs = await ctx.runQuery(api.auditLogs.byUser, {
        token,
        userId: userId as any,
      });
      return json(logs);
    } catch (e: any) {
      return error(e.message ?? "Erreur audit logs par user", 400);
    }
  }),
});

http.route({ path: "/api/admin/audit-logs/by-user", method: "OPTIONS", handler: preflight });

/** GET /api/admin/audit-logs/by-resource?resource=orders */
http.route({
  path: "/api/admin/audit-logs/by-resource",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const url = new URL(request.url);
      const resource = url.searchParams.get("resource");
      if (!resource) return error("resource requis");
      const logs = await ctx.runQuery(api.auditLogs.byResource, {
        token,
        resource,
      });
      return json(logs);
    } catch (e: any) {
      return error(e.message ?? "Erreur audit logs par resource", 400);
    }
  }),
});

http.route({ path: "/api/admin/audit-logs/by-resource", method: "OPTIONS", handler: preflight });

// ============ ADMIN: PROMOTIONS ============

/** GET /api/admin/promotions — Toutes les promotions (admin) */
http.route({
  path: "/api/admin/promotions",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const data = await ctx.runQuery(api.promotions.listAll, { token });
      return json(data);
    } catch (e: any) {
      return error(e.message ?? "Erreur promotions", 400);
    }
  }),
});
http.route({ path: "/api/admin/promotions", method: "OPTIONS", handler: preflight });

/** POST /api/admin/promotions/create — Créer promotion */
http.route({
  path: "/api/admin/promotions/create",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const id = await ctx.runMutation(api.promotions.create, { token, ...body });
      return json({ id });
    } catch (e: any) {
      return error(e.message ?? "Erreur création promotion", 400);
    }
  }),
});
http.route({ path: "/api/admin/promotions/create", method: "OPTIONS", handler: preflight });

/** POST /api/admin/promotions/update — Modifier promotion */
http.route({
  path: "/api/admin/promotions/update",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      await ctx.runMutation(api.promotions.update, { token, ...body });
      return json({ ok: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur modification promotion", 400);
    }
  }),
});
http.route({ path: "/api/admin/promotions/update", method: "OPTIONS", handler: preflight });

/** POST /api/admin/promotions/delete — Supprimer promotion */
http.route({
  path: "/api/admin/promotions/delete",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      await ctx.runMutation(api.promotions.remove, { token, id: body.id });
      return json({ ok: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur suppression promotion", 400);
    }
  }),
});
http.route({ path: "/api/admin/promotions/delete", method: "OPTIONS", handler: preflight });

// ============ ADMIN: CATEGORIES ============

/** GET /api/admin/categories — Toutes les catégories (admin) */
http.route({
  path: "/api/admin/categories",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const data = await ctx.runQuery(api.foodCategories.listAll, { token });
      return json(data);
    } catch (e: any) {
      return error(e.message ?? "Erreur catégories", 400);
    }
  }),
});
http.route({ path: "/api/admin/categories", method: "OPTIONS", handler: preflight });

/** POST /api/admin/categories/create — Créer catégorie */
http.route({
  path: "/api/admin/categories/create",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const id = await ctx.runMutation(api.foodCategories.create, { token, ...body });
      return json({ id });
    } catch (e: any) {
      return error(e.message ?? "Erreur création catégorie", 400);
    }
  }),
});
http.route({ path: "/api/admin/categories/create", method: "OPTIONS", handler: preflight });

/** POST /api/admin/categories/update — Modifier catégorie */
http.route({
  path: "/api/admin/categories/update",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      await ctx.runMutation(api.foodCategories.updateCat, { token, ...body });
      return json({ ok: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur modification catégorie", 400);
    }
  }),
});
http.route({ path: "/api/admin/categories/update", method: "OPTIONS", handler: preflight });

/** POST /api/admin/categories/delete — Supprimer catégorie */
http.route({
  path: "/api/admin/categories/delete",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      await ctx.runMutation(api.foodCategories.remove, { token, id: body.id });
      return json({ ok: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur suppression catégorie", 400);
    }
  }),
});
http.route({ path: "/api/admin/categories/delete", method: "OPTIONS", handler: preflight });

// ============ ADMIN: BUSINESS RULES ============

http.route({
  path: "/api/admin/business-rules",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return cors(new Response("Unauthorized", { status: 401 }));
      const data = await ctx.runQuery(api.businessRules.listAll, { token });
      return cors(new Response(JSON.stringify(data), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }));
    } catch (e: any) {
      return cors(new Response(JSON.stringify({ error: e.message }), { status: 400 }));
    }
  }),
});
http.route({ path: "/api/admin/business-rules", method: "OPTIONS", handler: preflight });

http.route({
  path: "/api/admin/business-rules/update",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return cors(new Response("Unauthorized", { status: 401 }));
      const body = await request.json();
      await ctx.runMutation(api.businessRules.updateRule, {
        token,
        key: body.key,
        value: body.value,
      });
      return cors(new Response(JSON.stringify({ ok: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }));
    } catch (e: any) {
      return cors(new Response(JSON.stringify({ error: e.message }), { status: 400 }));
    }
  }),
});
http.route({ path: "/api/admin/business-rules/update", method: "OPTIONS", handler: preflight });

// ============ NOTIFICATIONS ============

/** GET /api/notifications — Liste des notifications de l'utilisateur */
http.route({
  path: "/api/notifications",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const notifications = await ctx.runQuery(api.notifications.list, { token });
      return json(notifications);
    } catch (e: any) {
      return error(e.message ?? "Erreur notifications", 400);
    }
  }),
});
http.route({ path: "/api/notifications", method: "OPTIONS", handler: preflight });

/** GET /api/notifications/unread-count — Nombre de notifications non lues */
http.route({
  path: "/api/notifications/unread-count",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const count = await ctx.runQuery(api.notifications.unreadCount, { token });
      return json({ count });
    } catch (e: any) {
      return error(e.message ?? "Erreur unread count", 400);
    }
  }),
});
http.route({ path: "/api/notifications/unread-count", method: "OPTIONS", handler: preflight });

/** POST /api/notifications/read — Marquer une notification comme lue */
http.route({
  path: "/api/notifications/read",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { notificationId } = body;
      if (!notificationId) return error("notificationId requis");
      await ctx.runMutation(api.notifications.markAsRead, {
        notificationId: notificationId as any,
        token,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur mark as read", 400);
    }
  }),
});
http.route({ path: "/api/notifications/read", method: "OPTIONS", handler: preflight });

/** POST /api/notifications/read-all — Marquer toutes les notifications comme lues */
http.route({
  path: "/api/notifications/read-all",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const result = await ctx.runMutation(api.notifications.markAllAsRead, { token });
      return json(result);
    } catch (e: any) {
      return error(e.message ?? "Erreur mark all read", 400);
    }
  }),
});
http.route({ path: "/api/notifications/read-all", method: "OPTIONS", handler: preflight });

/** POST /api/notifications/delete — Supprimer une notification */
http.route({
  path: "/api/notifications/delete",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    try {
      const token = extractToken(request);
      if (!token) return error("Token requis", 401);
      const body = await request.json();
      const { notificationId } = body;
      if (!notificationId) return error("notificationId requis");
      await ctx.runMutation(api.notifications.deleteOne, {
        notificationId: notificationId as any,
        token,
      });
      return json({ success: true });
    } catch (e: any) {
      return error(e.message ?? "Erreur suppression notification", 400);
    }
  }),
});
http.route({ path: "/api/notifications/delete", method: "OPTIONS", handler: preflight });

// ============ HELPERS ============

function extractToken(request: Request): string | null {
  const authHeader = request.headers.get("Authorization");
  if (authHeader?.startsWith("Bearer ")) {
    return authHeader.slice(7);
  }
  return null;
}

export default http;
