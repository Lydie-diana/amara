import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/convex_client.dart';

class Promotion {
  final String title;
  final String subtitle;
  final String tag;
  final String emoji;
  final Color bgColor;

  const Promotion({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.emoji,
    required this.bgColor,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      tag: json['tag'] as String,
      emoji: json['emoji'] as String,
      bgColor: _parseColor(json['bgColor'] as String),
    );
  }

  static Color _parseColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return const Color(0xFFE62050);
  }
}

final promotionsProvider =
    FutureProvider.family<List<Promotion>, String?>((ref, city) async {
  try {
    final client = ref.read(convexClientProvider);
    final data = await client.getPromotions(city: city);
    return data
        .map((e) => Promotion.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } catch (e) {
    debugPrint('[Promotions] Erreur: $e');
    return [];
  }
});
