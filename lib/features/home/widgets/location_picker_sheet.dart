import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/constants/app_text_styles.dart';
import '../../../app/core/l10n/app_localizations.dart';
import '../../../app/providers/location_provider.dart';
import '../../../app/providers/restaurant_provider.dart';
import '../../../app/services/location_service.dart';

class LocationPickerSheet extends ConsumerStatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  ConsumerState<LocationPickerSheet> createState() =>
      _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  bool _locating = false;
  bool _searching = false;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<_AddressSuggestion> _suggestions = [];
  Timer? _debounce;
  String? _errorMessage;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _errorMessage = null;
    });
    await ref.read(locationProvider.notifier).refreshLocation();
    ref.invalidate(restaurantListProvider);
    setState(() => _locating = false);
    if (mounted) Navigator.of(context).pop();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query.trim());
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() {
      _searching = true;
      _errorMessage = null;
    });
    try {
      final locations = await locationFromAddress(query);
      if (!mounted) return;
      final suggestions = <_AddressSuggestion>[];
      for (final loc in locations.take(5)) {
        try {
          final placemarks = await placemarkFromCoordinates(
              loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final city = p.locality ?? p.administrativeArea ?? '';
            final district = p.subLocality ?? p.thoroughfare ?? '';
            final country = p.country ?? '';
            final lines = <String>[
              if (district.isNotEmpty && district != city) district,
              if (city.isNotEmpty) city,
              if (country.isNotEmpty) country,
            ];
            suggestions.add(_AddressSuggestion(
              displayName: lines.join(', '),
              subtitle: lines.length > 1 ? lines.sublist(1).join(', ') : city,
              latitude: loc.latitude,
              longitude: loc.longitude,
              city: city.isNotEmpty ? city : country,
              district: district.isNotEmpty ? district : city,
            ));
          }
        } catch (_) {}
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _suggestions = suggestions;
          _searching = false;
          if (suggestions.isEmpty && query.isNotEmpty) {
            _errorMessage = l10n.locationNoResult(query);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _searching = false;
          _errorMessage = l10n.locationNotFound;
          _suggestions = [];
        });
      }
    }
  }

  Future<void> _selectSuggestion(_AddressSuggestion suggestion) async {
    _focusNode.unfocus();
    final result = LocationResult(
      latitude: suggestion.latitude,
      longitude: suggestion.longitude,
      city: suggestion.city,
      district: suggestion.district,
      displayAddress: suggestion.displayName,
    );
    await ref.read(locationProvider.notifier).setManualLocation(result);
    ref.invalidate(restaurantListProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AmaraColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.locationTitle,
                    style: AmaraTextStyles.h3
                        .copyWith(color: AmaraColors.textPrimary)),
                const SizedBox(height: 4),
                Text(l10n.locationSubtitle,
                    style: AmaraTextStyles.bodySmall),
                const SizedBox(height: 20),

                // ── Champ de recherche ──────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AmaraColors.bgAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AmaraColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.search_rounded,
                            color: AmaraColors.muted, size: 20),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: _onSearchChanged,
                          style: AmaraTextStyles.bodyMedium.copyWith(
                            color: AmaraColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.locationSearchHint,
                            hintStyle: AmaraTextStyles.bodyMedium.copyWith(
                              color: AmaraColors.muted,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (v) {
                            if (v.trim().length >= 3) {
                              _fetchSuggestions(v.trim());
                            }
                          },
                        ),
                      ),
                      if (_searching)
                        const Padding(
                          padding: EdgeInsets.only(right: 14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AmaraColors.primary,
                            ),
                          ),
                        )
                      else if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _suggestions = [];
                              _errorMessage = null;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(Icons.close_rounded,
                                color: AmaraColors.muted, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Suggestions ─────────────────────────────────────────────
                if (_suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AmaraColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: AmaraColors.divider,
                        indent: 52,
                      ),
                      itemBuilder: (_, i) {
                        final s = _suggestions[i];
                        return InkWell(
                          onTap: () => _selectSuggestion(s),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AmaraColors.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: AmaraColors.primary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.displayName,
                                        style:
                                            AmaraTextStyles.bodyMedium.copyWith(
                                          color: AmaraColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (s.subtitle.isNotEmpty)
                                        Text(
                                          s.subtitle,
                                          style:
                                              AmaraTextStyles.bodySmall.copyWith(
                                            color: AmaraColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.north_west_rounded,
                                    color: AmaraColors.muted, size: 14),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // ── Erreur ──────────────────────────────────────────────────
                if (_errorMessage != null && _suggestions.isEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AmaraColors.muted, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AmaraTextStyles.bodySmall
                              .copyWith(color: AmaraColors.muted),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // ── Divider avec "ou" ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: AmaraColors.divider, height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.locationOr,
                          style: AmaraTextStyles.bodySmall
                              .copyWith(color: AmaraColors.muted)),
                    ),
                    Expanded(
                        child: Divider(color: AmaraColors.divider, height: 1)),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Bouton GPS ───────────────────────────────────────────────
                _LocationOption(
                  icon: Icons.my_location_rounded,
                  iconColor: AmaraColors.primary,
                  title: _locating
                      ? l10n.locationLocating
                      : l10n.locationUseGps,
                  subtitle: location.hasLocation && !_locating
                      ? location.displayAddress
                      : l10n.locationGpsAccuracy,
                  trailing: _locating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AmaraColors.primary,
                          ),
                        )
                      : const Icon(Icons.chevron_right_rounded,
                          color: AmaraColors.muted, size: 20),
                  onTap: _locating ? null : _useCurrentLocation,
                ),

                const SizedBox(height: 12),

                // ── Secteur actuel ───────────────────────────────────────────
                if (location.hasLocation) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AmaraColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AmaraColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AmaraColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: AmaraColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.locationCurrentArea,
                                  style: AmaraTextStyles.labelSmall.copyWith(
                                      color: AmaraColors.primary,
                                      fontSize: 11)),
                              Text(location.displayAddress,
                                  style: AmaraTextStyles.bodyMedium.copyWith(
                                      color: AmaraColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded,
                            color: AmaraColors.primary, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Permission refusée ───────────────────────────────────────
                if (location.permissionDenied) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AmaraColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AmaraColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_off_rounded,
                            color: AmaraColors.warning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.locationAccessDenied,
                            style: AmaraTextStyles.bodySmall.copyWith(
                                color: AmaraColors.warning),
                          ),
                        ),
                        TextButton(
                          onPressed: () => LocationService.openAppSettings(),
                          child: Text(l10n.locationSettings,
                              style: AmaraTextStyles.labelSmall.copyWith(
                                  color: AmaraColors.warning)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggestion de recherche ───────────────────────────────────────────────────

class _AddressSuggestion {
  final String displayName;
  final String subtitle;
  final double latitude;
  final double longitude;
  final String city;
  final String district;

  const _AddressSuggestion({
    required this.displayName,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.district,
  });
}

// ─── Widget option GPS ─────────────────────────────────────────────────────────

class _LocationOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _LocationOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AmaraColors.bgAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AmaraColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AmaraTextStyles.bodyMedium.copyWith(
                          color: AmaraColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AmaraTextStyles.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
