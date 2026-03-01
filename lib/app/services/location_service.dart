import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String city;
  final String district;
  final String displayAddress;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.district,
    required this.displayAddress,
  });

  @override
  String toString() => 'LocationResult($displayAddress, $latitude, $longitude)';
}

class LocationService {
  LocationService._();

  /// Demande la permission et retourne la position GPS actuelle + adresse reverse geocodée.
  /// Retourne null si permission refusée ou GPS indisponible.
  static Future<LocationResult?> getCurrentLocation() async {
    try {
      // 1. Vérifier si le service GPS est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] GPS service disabled');
        return null;
      }

      // 2. Vérifier / demander la permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Permission denied');
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Permission denied forever');
        return null;
      }

      // 3. Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint('[LocationService] Position: ${position.latitude}, ${position.longitude}');

      // 4. Reverse geocoding
      return await _buildResult(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('[LocationService] Error: $e');
      return null;
    }
  }

  /// Convertit des coordonnées en LocationResult (reverse geocoding).
  static Future<LocationResult> _buildResult(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? p.administrativeArea ?? 'Inconnue';
        final district = p.subLocality ?? p.thoroughfare ?? city;
        final displayAddress = district != city
            ? '$district, $city'
            : city;
        return LocationResult(
          latitude: lat,
          longitude: lng,
          city: city,
          district: district,
          displayAddress: displayAddress,
        );
      }
    } catch (e) {
      debugPrint('[LocationService] Geocoding error: $e');
    }
    // Fallback si geocoding échoue
    return LocationResult(
      latitude: lat,
      longitude: lng,
      city: 'Inconnu',
      district: 'Inconnu',
      displayAddress: '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
    );
  }

  /// Calcule la distance en mètres entre deux coordonnées (formule haversine).
  static double distanceInMeters(
      double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  /// Vérifie si la permission GPS est refusée définitivement (ouvrir les réglages requis).
  static Future<bool> isPermissionDeniedForever() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  /// Ouvre les réglages de l'app pour que l'utilisateur active la permission.
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
