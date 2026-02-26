import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Modèle adresse ──────────────────────────────────────────────────────────

class SavedAddress {
  final String id;
  String label;
  final IconData icon;
  String address;
  String complement;
  bool isDefault;
  double? lat;
  double? lng;

  SavedAddress({
    required this.id,
    required this.label,
    this.icon = Icons.location_on_rounded,
    required this.address,
    this.complement = '',
    this.isDefault = false,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'complement': complement,
        'isDefault': isDefault,
        'lat': lat,
        'lng': lng,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json['id'] as String,
        label: json['label'] as String,
        address: json['address'] as String,
        complement: json['complement'] as String? ?? '',
        isDefault: json['isDefault'] as bool? ?? false,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class AddressNotifier extends Notifier<List<SavedAddress>> {
  static const _storageKey = 'amara_saved_addresses';

  @override
  List<SavedAddress> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = state.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  void add(SavedAddress address) {
    if (address.isDefault) {
      for (final a in state) {
        a.isDefault = false;
      }
    }
    if (state.isEmpty) address.isDefault = true;
    state = [...state, address];
    _save();
  }

  void update(String id, {String? label, String? address, String? complement, double? lat, double? lng}) {
    state = [
      for (final a in state)
        if (a.id == id) ...[
          SavedAddress(
            id: a.id,
            label: label ?? a.label,
            address: address ?? a.address,
            complement: complement ?? a.complement,
            isDefault: a.isDefault,
            lat: lat ?? a.lat,
            lng: lng ?? a.lng,
          )
        ] else
          a,
    ];
    _save();
  }

  void remove(String id) {
    final wasDefault = state.any((a) => a.id == id && a.isDefault);
    state = state.where((a) => a.id != id).toList();
    if (wasDefault && state.isNotEmpty) {
      state.first.isDefault = true;
      state = [...state];
    }
    _save();
  }

  void setDefault(String id) {
    for (final a in state) {
      a.isDefault = a.id == id;
    }
    state = [...state];
    _save();
  }

  SavedAddress? get defaultAddress => state.where((a) => a.isDefault).firstOrNull;
}

// ─── Providers ───────────────────────────────────────────────────────────────

final addressProvider =
    NotifierProvider<AddressNotifier, List<SavedAddress>>(AddressNotifier.new);

final defaultAddressProvider = Provider<SavedAddress?>((ref) {
  final addresses = ref.watch(addressProvider);
  return addresses.where((a) => a.isDefault).firstOrNull;
});
