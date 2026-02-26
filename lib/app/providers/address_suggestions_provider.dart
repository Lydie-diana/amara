import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/data/address_suggestions.dart';
import '../services/convex_client.dart';

final addressSuggestionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final client = ref.read(convexClientProvider);
    final data = await client.getAddressSuggestions();
    if (data.isEmpty) return kAddressSuggestions;
    return data
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return {
            'address': m['address'] as String,
            'lat': (m['latitude'] as num).toDouble(),
            'lng': (m['longitude'] as num).toDouble(),
          };
        })
        .toList();
  } catch (e) {
    debugPrint('[AddressSuggestions] Fallback local: $e');
    return kAddressSuggestions;
  }
});
