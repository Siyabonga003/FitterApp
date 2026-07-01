import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_app/models/badge_model.dart';
import 'package:frontend_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

class BadgeNotifier extends Notifier<List<Badges>> {
  final List<Badges> _newBadges = [];

  @override
  List<Badges> build() => [];

  Future<void> loadBadges() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.127:9085/api/badges'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = data.map((j) => Badges.fromJson(j)).toList();
      }
    } catch (e) {
      print('Failed to load badges: $e');
    }
  }

  void onBadgeAwarded(Map<String, dynamic> json) {
    final badge = Badges(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      awardedAt: DateTime.now(),
      isNew: true,
    );


    if (!state.any((b) => b.code == badge.code)) {
      state = [...state, badge];
    }

    _newBadges.add(badge);
  }

  Badges? popNewBadge() {
    if (_newBadges.isEmpty) return null;
    return _newBadges.removeAt(0);
  }

  bool get hasNewBadge => _newBadges.isNotEmpty;
}

final badgeProvider = NotifierProvider<BadgeNotifier, List<Badges>>(
  BadgeNotifier.new,
);