import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

// ─── Clés SharedPreferences ───────────────────────────────────────────────────
const _kLat = 'location_lat';
const _kLng = 'location_lng';
const _kCity = 'location_city';
const _kDistrict = 'location_district';
const _kDisplay = 'location_display';

// ─── Seuil de déplacement : 500 mètres ───────────────────────────────────────
const _kMovementThresholdMeters = 500.0;

// ─── État ─────────────────────────────────────────────────────────────────────

class LocationState {
  final double? latitude;
  final double? longitude;
  final String city;
  final String district;
  final String displayAddress;
  final bool isLoading;
  final bool permissionDenied;
  final bool hasMovedSignificantly;
  final LocationResult? newPosition; // position proposée si déplacement détecté

  const LocationState({
    this.latitude,
    this.longitude,
    this.city = 'Abidjan',
    this.district = '',
    this.displayAddress = 'Abidjan',
    this.isLoading = false,
    this.permissionDenied = false,
    this.hasMovedSignificantly = false,
    this.newPosition,
  });

  bool get hasLocation => latitude != null && longitude != null;

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? district,
    String? displayAddress,
    bool? isLoading,
    bool? permissionDenied,
    bool? hasMovedSignificantly,
    LocationResult? newPosition,
    bool clearNewPosition = false,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      district: district ?? this.district,
      displayAddress: displayAddress ?? this.displayAddress,
      isLoading: isLoading ?? this.isLoading,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      hasMovedSignificantly: hasMovedSignificantly ?? this.hasMovedSignificantly,
      newPosition: clearNewPosition ? null : (newPosition ?? this.newPosition),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() => const LocationState(isLoading: false);

  /// Appelé au démarrage : charge la position stockée puis tente le GPS.
  Future<void> initLocation() async {
    state = state.copyWith(isLoading: true);

    // 1. Charger la position précédente depuis SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final storedLat = prefs.getDouble(_kLat);
    final storedLng = prefs.getDouble(_kLng);
    final storedCity = prefs.getString(_kCity) ?? 'Abidjan';
    final storedDistrict = prefs.getString(_kDistrict) ?? '';
    final storedDisplay = prefs.getString(_kDisplay) ?? storedCity;

    if (storedLat != null && storedLng != null) {
      state = state.copyWith(
        latitude: storedLat,
        longitude: storedLng,
        city: storedCity,
        district: storedDistrict,
        displayAddress: storedDisplay,
        isLoading: false,
      );
    }

    // 2. Tenter d'obtenir la position GPS actuelle
    final result = await LocationService.getCurrentLocation();

    if (result == null) {
      // Permission refusée ou GPS indisponible
      state = state.copyWith(
        isLoading: false,
        permissionDenied: storedLat == null, // refusé seulement si pas de position stockée
      );
      return;
    }

    // 3. Comparer avec la position stockée
    if (storedLat != null && storedLng != null) {
      final distance = LocationService.distanceInMeters(
        storedLat, storedLng, result.latitude, result.longitude,
      );
      debugPrint('[LocationProvider] Distance depuis dernière position: ${distance.toStringAsFixed(0)}m');

      if (distance > _kMovementThresholdMeters) {
        // Déplacement significatif détecté → proposer le changement
        state = state.copyWith(
          isLoading: false,
          hasMovedSignificantly: true,
          newPosition: result,
        );
        return;
      }
    }

    // 4. Pas de déplacement ou première utilisation → appliquer directement
    await _applyLocation(result);
  }

  /// Confirme le déplacement détecté → change de secteur.
  Future<void> confirmNewLocation() async {
    final newPos = state.newPosition;
    if (newPos == null) return;
    state = state.copyWith(hasMovedSignificantly: false, clearNewPosition: true);
    await _applyLocation(newPos);
  }

  /// Ignore le déplacement → garde le secteur actuel.
  void dismissMovement() {
    state = state.copyWith(
      hasMovedSignificantly: false,
      clearNewPosition: true,
    );
  }

  /// Définit une adresse manuellement (depuis le picker).
  Future<void> setManualLocation(LocationResult result) async {
    state = state.copyWith(hasMovedSignificantly: false, clearNewPosition: true);
    await _applyLocation(result);
  }

  /// Relance la détection GPS (bouton "Ma position").
  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true, permissionDenied: false);
    final result = await LocationService.getCurrentLocation();
    if (result == null) {
      final deniedForever = await LocationService.isPermissionDeniedForever();
      state = state.copyWith(isLoading: false, permissionDenied: true);
      if (deniedForever) await LocationService.openAppSettings();
      return;
    }
    await _applyLocation(result);
  }

  Future<void> _applyLocation(LocationResult result) async {
    state = state.copyWith(
      latitude: result.latitude,
      longitude: result.longitude,
      city: result.city,
      district: result.district,
      displayAddress: result.displayAddress,
      isLoading: false,
      permissionDenied: false,
      hasMovedSignificantly: false,
      clearNewPosition: true,
    );
    // Persister
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLat, result.latitude);
    await prefs.setDouble(_kLng, result.longitude);
    await prefs.setString(_kCity, result.city);
    await prefs.setString(_kDistrict, result.district);
    await prefs.setString(_kDisplay, result.displayAddress);
    debugPrint('[LocationProvider] Location applied: ${result.displayAddress}');
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final locationProvider =
    NotifierProvider<LocationNotifier, LocationState>(LocationNotifier.new);
