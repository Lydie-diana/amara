/**
 * Helpers de validation pour les mutations Convex.
 * Utilisés dans les handlers pour valider les entrées utilisateur.
 */

/** Valide un numéro de téléphone camerounais (+237 6XX XXX XXX) */
export function validatePhone(phone: string): boolean {
  const cleaned = phone.replace(/\s/g, "");
  return /^(\+237)?6[0-9]{8}$/.test(cleaned);
}

/** Valide un format email basique */
export function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/** Valide un prix en FCFA (entier positif, max 1 000 000) */
export function validatePrice(price: number): boolean {
  return Number.isFinite(price) && price >= 0 && price <= 1_000_000;
}

/** Valide une latitude (-90 à 90) */
export function validateLatitude(lat: number): boolean {
  return Number.isFinite(lat) && lat >= -90 && lat <= 90;
}

/** Valide une longitude (-180 à 180) */
export function validateLongitude(lng: number): boolean {
  return Number.isFinite(lng) && lng >= -180 && lng <= 180;
}

/** Valide que les coordonnées sont dans la zone métropolitaine de Douala */
export function validateDoualaCoords(lat: number, lng: number): boolean {
  return lat >= 3.9 && lat <= 4.2 && lng >= 9.5 && lng <= 9.9;
}

/** Nettoie une chaîne : trim + limite de longueur */
export function sanitizeString(input: string, maxLength: number = 500): string {
  return input.trim().slice(0, maxLength);
}

/** Valide un rating (1-5, entier ou demi) */
export function validateRating(rating: number): boolean {
  return rating >= 1 && rating <= 5 && rating * 2 === Math.round(rating * 2);
}

/** Valide les heures au format HH:MM */
export function validateTimeFormat(time: string): boolean {
  return /^([01]\d|2[0-3]):([0-5]\d)$/.test(time);
}

/** Calcule la distance entre deux points GPS (formule Haversine, en km) */
export function haversineDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // Rayon de la Terre en km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRad(deg: number): number {
  return deg * (Math.PI / 180);
}

/** Vérifie si un point est dans un polygone (ray casting algorithm) */
export function pointInPolygon(
  point: { latitude: number; longitude: number },
  polygon: { latitude: number; longitude: number }[]
): boolean {
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i].latitude;
    const yi = polygon[i].longitude;
    const xj = polygon[j].latitude;
    const yj = polygon[j].longitude;

    const intersect =
      yi > point.longitude !== yj > point.longitude &&
      point.latitude < ((xj - xi) * (point.longitude - yi)) / (yj - yi) + xi;
    if (intersect) inside = !inside;
  }
  return inside;
}
