import { mutation } from "./_generated/server";
import { v } from "convex/values";

/**
 * Seed complet pour le restaurant Chef Amara.
 * Catégories : Entrées, Plats africains, Grillades, Poissons & Fruits de mer,
 *              Riz & Pâtes, Desserts, Boissons
 * Images : Unsplash (libres de droits)
 * Usage : npx convex run seedChefAmara:run '{"restaurantId":"ks77mgts7ske85zwxv3bkmcv1x81xwyd"}'
 */
export const run = mutation({
  args: { restaurantId: v.string() },
  handler: async (ctx, args) => {
    const restaurantId = args.restaurantId as any;

    // Supprimer les anciens plats
    const existing = await ctx.db
      .query("menuItems")
      .withIndex("by_restaurant", (q) => q.eq("restaurantId", restaurantId))
      .collect();
    for (const item of existing) {
      await ctx.db.delete(item._id);
    }

    const now = Date.now();
    let count = 0;

    const insert = async (item: {
      name: string;
      description: string;
      price: number;
      category: string;
      imageUrl: string;
      tags: string[];
      isAvailable: boolean;
      isPopular?: boolean;
      discountPercent?: number;
    }) => {
      await ctx.db.insert("menuItems", {
        restaurantId,
        name: item.name,
        description: item.description,
        price: item.price,
        category: item.category,
        imageUrl: item.imageUrl,
        tags: item.tags,
        isAvailable: item.isAvailable,
        createdAt: now,
        orderCount: Math.floor(Math.random() * 200),
        rating: parseFloat((3.5 + Math.random() * 1.5).toFixed(1)),
        totalRatings: Math.floor(Math.random() * 80) + 5,
        ...(item.discountPercent ? { discountPercent: item.discountPercent } : {}),
      });
      count++;
    };

    // ── ENTRÉES ───────────────────────────────────────────────────────────────
    await insert({
      name: "Salade de légumes du marché",
      description: "Tomates fraîches, concombre, oignons rouges, avocat, vinaigrette citron-gingembre. Légèreté et fraîcheur garanties.",
      price: 2500,
      category: "Entrées",
      imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80",
      tags: ["végétarien", "léger"],
      isAvailable: true,
    });

    await insert({
      name: "Beignets de crevettes",
      description: "Crevettes enrobées d'une pâte légère croustillante, frites dorées. Servies avec sauce pimentée maison.",
      price: 4500,
      category: "Entrées",
      imageUrl: "https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=800&q=80",
      tags: ["populaire", "fruits de mer"],
      isAvailable: true,
    });

    await insert({
      name: "Soupe légumes et viande",
      description: "Bouillon maison avec légumes frais, morceaux de viande tendre, épices africaines. Réconfortante et nourrissante.",
      price: 3000,
      category: "Entrées",
      imageUrl: "https://images.unsplash.com/photo-1547592180-85f173990554?w=800&q=80",
      tags: ["chaud", "maison"],
      isAvailable: true,
    });

    await insert({
      name: "Brochettes de foie",
      description: "Foie de boeuf mariné aux épices, grillé sur charbon. Servi avec oignons caramélisés et sauce moutarde.",
      price: 3500,
      category: "Entrées",
      imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80",
      tags: ["grillé", "boeuf"],
      isAvailable: true,
    });

    // ── PLATS AFRICAINS ───────────────────────────────────────────────────────
    await insert({
      name: "Attiéké poisson braisé",
      description: "Attiéké de manioc artisanal accompagné d'un gros poisson braisé au feu de bois, oignons et tomates fraîches. Le grand classique ivoirien.",
      price: 5500,
      category: "Plats africains",
      imageUrl: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80",
      tags: ["populaire", "ivoirien", "poisson"],
      isAvailable: true,
    });

    await insert({
      name: "Foutou banane + sauce graine",
      description: "Foutou de banane plantain pilé à la perfection, nappé de sauce graine onctueuse avec poulet ou viande. Une recette ancestrale.",
      price: 6000,
      category: "Plats africains",
      imageUrl: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&q=80",
      tags: ["populaire", "ivoirien", "traditionnel"],
      isAvailable: true,
      discountPercent: 10,
    });

    await insert({
      name: "Kedjenou de poulet",
      description: "Poulet fermier cuit à l'étouffée dans une jarre en argile avec aubergines, piment, gingembre et épices secrètes. Plat roi de Côte d'Ivoire.",
      price: 7500,
      category: "Plats africains",
      imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80",
      tags: ["populaire", "ivoirien", "poulet", "épicé"],
      isAvailable: true,
    });

    await insert({
      name: "Garba thon et attiéké",
      description: "Attiéké cuit en vapeur, thon frit bien doré, garni d'oignons, piment et huile de palme. La street food préférée d'Abidjan.",
      price: 3500,
      category: "Plats africains",
      imageUrl: "https://images.unsplash.com/photo-1519984388953-d2406bc725e1?w=800&q=80",
      tags: ["populaire", "économique", "thon"],
      isAvailable: true,
    });

    await insert({
      name: "Riz sauce arachide",
      description: "Riz long grain cuit à point, sauce arachide crémeuse préparée avec pâte d'arachide fraîche, poulet effiloché et épices maison.",
      price: 5000,
      category: "Plats africains",
      imageUrl: "https://images.unsplash.com/photo-1596797038530-2c107229654b?w=800&q=80",
      tags: ["riz", "poulet", "arachide"],
      isAvailable: true,
    });

    await insert({
      name: "Alloco poulet",
      description: "Bananes plantains bien mûres frites à l'huile, croustillantes en dehors et fondantes en dedans. Servies avec poulet yassa et piment.",
      price: 4500,
      category: "Plats africains",
      imageUrl: "https://images.unsplash.com/photo-1562802378-063ec186a863?w=800&q=80",
      tags: ["ivoirien", "frit", "poulet"],
      isAvailable: true,
    });

    // ── GRILLADES ─────────────────────────────────────────────────────────────
    await insert({
      name: "Poulet braisé entier",
      description: "Poulet fermier mariné 12h dans notre mélange secret d'épices et herbes fraîches, grillé lentement sur charbon de bois. Juteux, fumé, inoubliable.",
      price: 12000,
      category: "Grillades",
      imageUrl: "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&q=80",
      tags: ["populaire", "poulet", "grillé"],
      isAvailable: true,
    });

    await insert({
      name: "Côtes de boeuf grillées",
      description: "Côtes de boeuf tendres marinées à l'ail, romarin et épices africaines, grillées sur braise vive. Servies avec frites maison et salade.",
      price: 14000,
      category: "Grillades",
      imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80",
      tags: ["boeuf", "grillé", "populaire"],
      isAvailable: true,
    });

    await insert({
      name: "Brochettes de poulet",
      description: "Cubes de poulet fermier marinés, enfilés sur brochettes de bois, grillés à la braise. 6 brochettes servies avec sauce arachide et pain.",
      price: 5500,
      category: "Grillades",
      imageUrl: "https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=800&q=80",
      tags: ["poulet", "grillé", "brochette"],
      isAvailable: true,
    });

    await insert({
      name: "Agneau grillé aux herbes",
      description: "Épaule d'agneau rubannée aux herbes fraîches (thym, romarin, coriandre), rôtie lentement. Chair fondante, croûte parfumée. Servi avec couscous.",
      price: 16000,
      category: "Grillades",
      imageUrl: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&q=80",
      tags: ["agneau", "grillé", "épicé"],
      isAvailable: true,
    });

    await insert({
      name: "Saucisses grillées maison",
      description: "Saucisses artisanales préparées avec viandes sélectionnées et épices maison, grillées sur charbon. Servies avec moutarde et alloco.",
      price: 6500,
      category: "Grillades",
      imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80",
      tags: ["grillé", "saucisse"],
      isAvailable: true,
    });

    // ── POISSONS & FRUITS DE MER ──────────────────────────────────────────────
    await insert({
      name: "Thiéboudienne ivoirien",
      description: "Riz au poisson façon ivoirienne — poisson capitaine, légumes colorés, riz cuit dans un bouillon épicé riche. Plat complet et savoureux.",
      price: 7000,
      category: "Poissons & Fruits de mer",
      imageUrl: "https://images.unsplash.com/photo-1519984388953-d2406bc725e1?w=800&q=80",
      tags: ["poisson", "riz", "populaire"],
      isAvailable: true,
    });

    await insert({
      name: "Crevettes sautées à l'ail",
      description: "Grosses crevettes sautées au beurre avec ail haché, persil frais et pointe de citron. Servies sur lit de riz blanc parfumé.",
      price: 9500,
      category: "Poissons & Fruits de mer",
      imageUrl: "https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=800&q=80",
      tags: ["crevettes", "fruits de mer", "populaire"],
      isAvailable: true,
      discountPercent: 15,
    });

    await insert({
      name: "Poisson capitaine frit",
      description: "Capitaine entier nettoyé, assaisonné avec épices locales, frit jusqu'à la perfection. Croustillant dehors, fondant dedans. Servi avec attiéké.",
      price: 8000,
      category: "Poissons & Fruits de mer",
      imageUrl: "https://images.unsplash.com/photo-1580476262798-bddd9f4b7369?w=800&q=80",
      tags: ["poisson", "frit", "attiéké"],
      isAvailable: true,
    });

    await insert({
      name: "Homard grillé sauce citronnée",
      description: "Homard frais grillé à la perfection, badigeonné d'un beurre citronné maison. Accompagné de légumes vapeur et riz au safran. Le luxe de la mer.",
      price: 22000,
      category: "Poissons & Fruits de mer",
      imageUrl: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80",
      tags: ["homard", "luxe", "grillé", "fruits de mer"],
      isAvailable: true,
    });

    // ── RIZ & PÂTES ───────────────────────────────────────────────────────────
    await insert({
      name: "Riz jollof poulet",
      description: "Le célèbre riz rouge jollof d'Afrique de l'Ouest, cuit dans une sauce tomate épicée fumée, accompagné de cuisses de poulet braisé. Fête garantie.",
      price: 6500,
      category: "Riz & Pâtes",
      imageUrl: "https://images.unsplash.com/photo-1596797038530-2c107229654b?w=800&q=80",
      tags: ["riz", "poulet", "populaire", "épicé"],
      isAvailable: true,
    });

    await insert({
      name: "Pâtes bolognaise maison",
      description: "Tagliatelles al dente dans une sauce bolognaise mijotée 3h avec viande hachée premium, tomates fraîches et herbes italiennes. Un classique réconfortant.",
      price: 5500,
      category: "Riz & Pâtes",
      imageUrl: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&q=80",
      tags: ["pâtes", "boeuf", "maison"],
      isAvailable: true,
    });

    await insert({
      name: "Riz cantonais légumes",
      description: "Riz sauté wok avec œufs brouillés, petits pois, carottes, maïs et sauce soja. Léger, coloré et plein de saveurs.",
      price: 4000,
      category: "Riz & Pâtes",
      imageUrl: "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&q=80",
      tags: ["riz", "végétarien", "léger"],
      isAvailable: true,
    });

    // ── DESSERTS ──────────────────────────────────────────────────────────────
    await insert({
      name: "Fondant au chocolat",
      description: "Moelleux au chocolat noir 70%, cœur coulant chaud, servi avec boule de glace vanille et coulis de fruits rouges. Un dessert mythique.",
      price: 3500,
      category: "Desserts",
      imageUrl: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800&q=80",
      tags: ["chocolat", "dessert", "populaire"],
      isAvailable: true,
    });

    await insert({
      name: "Salade de fruits tropicaux",
      description: "Mangue Amélie, ananas Victoria, papaye, banane et fraises des bois, le tout arrosé d'un sirop de citron vert et menthe fraîche.",
      price: 2500,
      category: "Desserts",
      imageUrl: "https://images.unsplash.com/photo-1501746877-14782df58970?w=800&q=80",
      tags: ["fruits", "frais", "végétarien", "léger"],
      isAvailable: true,
    });

    await insert({
      name: "Crème caramel maison",
      description: "Flan crème caramel préparé à la main chaque matin avec œufs frais, lait entier et vanille de Madagascar. Onctueux, tremblant, parfait.",
      price: 2000,
      category: "Desserts",
      imageUrl: "https://images.unsplash.com/photo-1470124182917-cc6e71b22ecc?w=800&q=80",
      tags: ["dessert", "maison", "crème"],
      isAvailable: true,
    });

    await insert({
      name: "Gâteau Forêt Noire",
      description: "Génoise au cacao imbibée, chantilly maison et cerises au kirsch. Décoré avec copeaux de chocolat noir. Taille individuelle.",
      price: 3000,
      category: "Desserts",
      imageUrl: "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&q=80",
      tags: ["gâteau", "chocolat", "dessert"],
      isAvailable: true,
    });

    await insert({
      name: "Bananes flambées au rhum",
      description: "Bananes plantains dorées au beurre, flambées au rhum vieux, servies avec glace coco et sauce caramel. Le dessert signature de Chef Amara.",
      price: 3500,
      category: "Desserts",
      imageUrl: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800&q=80",
      tags: ["dessert", "flambé", "populaire", "banane"],
      isAvailable: true,
    });

    // ── BOISSONS ──────────────────────────────────────────────────────────────
    await insert({
      name: "Jus de bissap frais",
      description: "Infusion de fleurs d'hibiscus séchées, sucrée avec du sucre de canne, refroidie et servie avec quelques feuilles de menthe. La boisson africaine par excellence.",
      price: 1500,
      category: "Boissons",
      imageUrl: "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=800&q=80",
      tags: ["boisson", "frais", "traditionnel"],
      isAvailable: true,
    });

    await insert({
      name: "Jus de gingembre maison",
      description: "Gingembre frais pressé, citron vert, sucre de canne et une pointe de piment. Tonifiant, piquant, irrésistible. Préparé chaque matin.",
      price: 1500,
      category: "Boissons",
      imageUrl: "https://images.unsplash.com/photo-1603569283847-aa295f0d016a?w=800&q=80",
      tags: ["boisson", "frais", "gingembre"],
      isAvailable: true,
    });

    await insert({
      name: "Smoothie mangue passion",
      description: "Mangue Amélie fraîche, fruits de la passion, lait de coco et jus d'ananas mixés avec glace pilée. Un voyage tropical en verre.",
      price: 2500,
      category: "Boissons",
      imageUrl: "https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=800&q=80",
      tags: ["boisson", "smoothie", "mangue", "frais"],
      isAvailable: true,
    });

    await insert({
      name: "Eau minérale",
      description: "Bouteille d'eau minérale plate 50cl. Bien fraîche.",
      price: 500,
      category: "Boissons",
      imageUrl: "https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=800&q=80",
      tags: ["boisson", "eau"],
      isAvailable: true,
    });

    await insert({
      name: "Café ivoirien",
      description: "Café Robusta de Côte d'Ivoire torréfié artisanalement, préparé en percolation lente. Corsé, aromatique, authentique.",
      price: 1000,
      category: "Boissons",
      imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&q=80",
      tags: ["boisson", "café", "chaud"],
      isAvailable: true,
    });

    return { message: `✅ ${count} plats insérés pour Chef Amara.` };
  },
});
