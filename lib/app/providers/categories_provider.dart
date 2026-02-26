import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/convex_client.dart';

class FoodCategory {
  final String emoji;
  final String label;

  const FoodCategory({required this.emoji, required this.label});

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      emoji: json['emoji'] as String,
      label: json['label'] as String,
    );
  }
}

final categoriesProvider =
    FutureProvider<List<FoodCategory>>((ref) async {
  try {
    final client = ref.read(convexClientProvider);
    final data = await client.getCategories();
    return data
        .map((e) => FoodCategory.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } catch (e) {
    debugPrint('[Categories] Erreur: $e');
    return [];
  }
});
