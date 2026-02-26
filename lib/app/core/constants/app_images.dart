/// Catalogue d'images Unsplash pour l'app Amara.
/// Toutes les images sont libres d'utilisation (Unsplash License).
/// Format : photos via le CDN Unsplash (images.unsplash.com) avec taille optimisée.
class AmaraImages {
  AmaraImages._();

  // ─── Restaurants ───────────────────────────────────────────────────────────

  /// Chez Mama Africa — cuisine ivoirienne
  static const String chezMamaAfrica =
      'https://images.unsplash.com/photo-1567364816519-cbc9c4ffe1eb?w=800&q=80';

  /// Saveurs du Sahel — cuisine sénégalaise
  static const String saveursDuSahel =
      'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=800&q=80';

  /// Terroir Camerounais — cuisine camerounaise
  static const String terroirCamerounais =
      'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&q=80';

  /// Lagos Kitchen — cuisine nigériane
  static const String lagosKitchen =
      'https://images.unsplash.com/photo-1574484284002-952d92456975?w=800&q=80';

  /// Marrakech Délices — cuisine marocaine
  static const String marrakechDelices =
      'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800&q=80';

  /// Addis Flavors — cuisine éthiopienne
  static const String addisEthiopian =
      'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800&q=80';

  // ─── Splash & Onboarding ──────────────────────────────────────────────────

  /// Splash — vue aérienne soupe okra nigériane, 2 assiettes (sans humains)
  static const String splashHero =
      'https://images.unsplash.com/photo-1665332561290-cc6757172890?w=1200&q=85';

  /// Onboarding 1 — poisson grillé + kachumbari coloré, vue du dessus (sans humains)
  static const String onboarding1 =
      'https://images.unsplash.com/photo-1666181551815-b9adecb24e46?w=1200&q=85';

  /// Onboarding 2 — eforiro (ragoût d'épinards) & fufu, gros plan (sans humains)
  static const String onboarding2 =
      'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=1200&q=85';

  /// Onboarding 3 — jollof rice élégant avec poulet grillé, style restaurant (sans humains)
  static const String onboarding3 =
      'https://images.unsplash.com/photo-1664993101841-036f189719b6?w=1200&q=85';

  // ─── Plats ─────────────────────────────────────────────────────────────────

  /// Attiéké poisson
  static const String attieke =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=75';

  /// Poulet braisé / grillé
  static const String pouletBraise =
      'https://images.unsplash.com/photo-1598103442097-8b74394b95c2?w=400&q=75';

  /// Riz / Jollof Rice
  static const String jollofRice =
      'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=75';

  /// Thiéboudienne / riz au poisson
  static const String thiebs =
      'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=75';

  /// Soupe / ragoût africain
  static const String ragout =
      'https://images.unsplash.com/photo-1547592180-85f173990554?w=400&q=75';

  /// Couscous
  static const String couscous =
      'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400&q=75';

  /// Brochettes / suya
  static const String brochettes =
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&q=75';

  /// Injera / plat éthiopien
  static const String injera =
      'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=75';

  /// Boisson / jus
  static const String jus =
      'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&q=75';

  /// Dessert / pâtisserie
  static const String dessert =
      'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=400&q=75';

  /// Foutou / fufu
  static const String foutou =
      'https://images.unsplash.com/photo-1567364816519-cbc9c4ffe1eb?w=400&q=75';

  /// Burger / street food
  static const String streetFood =
      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=75';

  // ─── Mapping restaurant name → image URL ──────────────────────────────────

  static String restaurantImage(String name) {
    final n = name.toLowerCase();
    if (n.contains('mama') || n.contains('ivoir')) return chezMamaAfrica;
    if (n.contains('sahel') || n.contains('sénégal') || n.contains('senegal')) return saveursDuSahel;
    if (n.contains('cameroun')) return terroirCamerounais;
    if (n.contains('lagos') || n.contains('nigérian') || n.contains('nigerian')) return lagosKitchen;
    if (n.contains('marrakech') || n.contains('maroc')) return marrakechDelices;
    if (n.contains('addis') || n.contains('éthiop') || n.contains('ethiop')) return addisEthiopian;
    return chezMamaAfrica;
  }

  // ─── Mapping tags plat → image URL ────────────────────────────────────────

  static String menuItemImage(String name, List<String> tags) {
    final n = name.toLowerCase();
    final t = tags.map((e) => e.toLowerCase()).join(' ');

    if (n.contains('attiéké') || n.contains('attieke')) return attieke;
    if (n.contains('jollof') || n.contains('riz')) return jollofRice;
    if (n.contains('thiéb') || n.contains('thieb')) return thiebs;
    if (n.contains('couscous')) return couscous;
    if (n.contains('brochette') || n.contains('suya')) return brochettes;
    if (n.contains('injera') || n.contains('doro') || n.contains('tibs') || n.contains('beyay') || n.contains('kitfo')) return injera;
    if (n.contains('foutou') || n.contains('fufu')) return foutou;
    if (n.contains('ndolé') || n.contains('ndole') || n.contains('eru') || n.contains('maafé') || n.contains('maaffe') || n.contains('yassa')) return ragout;
    if (n.contains('poulet') || n.contains('chicken') || n.contains('dg')) return pouletBraise;
    if (n.contains('puff') || n.contains('koki') || n.contains('harira')) return streetFood;
    if (n.contains('jus') || n.contains('bissap') || n.contains('gingembre') || n.contains('chapman') || n.contains('bunna') || n.contains('thé') || n.contains('the')) return jus;
    if (n.contains('tagine') || n.contains('pastilla')) return couscous;

    if (t.contains('poisson')) return attieke;
    if (t.contains('riz')) return jollofRice;
    if (t.contains('végétarien')) return ragout;
    if (t.contains('boeuf')) return brochettes;
    if (t.contains('boisson')) return jus;
    if (t.contains('grillé')) return pouletBraise;

    return attieke;
  }
}
