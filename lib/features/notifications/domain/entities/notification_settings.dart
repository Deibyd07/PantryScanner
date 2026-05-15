import 'dart:convert';

import 'package:flutter/material.dart';

class NotificationSettings {
  const NotificationSettings({
    required this.enabled,
    required this.globalDaysBefore,
    required this.preferredHour,
    required this.preferredMinute,
    required this.categoryOverrides,
    required this.updatedAt,
  });

  final bool enabled;
  final int globalDaysBefore;
  final int preferredHour;
  final int preferredMinute;
  final Map<String, int> categoryOverrides;
  final DateTime updatedAt;

  TimeOfDay get preferredTime =>
      TimeOfDay(hour: preferredHour, minute: preferredMinute);

  NotificationSettings copyWith({
    bool? enabled,
    int? globalDaysBefore,
    int? preferredHour,
    int? preferredMinute,
    Map<String, int>? categoryOverrides,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      globalDaysBefore: globalDaysBefore ?? this.globalDaysBefore,
      preferredHour: preferredHour ?? this.preferredHour,
      preferredMinute: preferredMinute ?? this.preferredMinute,
      categoryOverrides: categoryOverrides ?? this.categoryOverrides,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static NotificationSettings defaults() {
    final DateTime now = DateTime.now();
    return NotificationSettings(
      enabled: true,
      globalDaysBefore: 3,
      preferredHour: 9,
      preferredMinute: 0,
      categoryOverrides: const <String, int>{},
      updatedAt: now,
    );
  }

  factory NotificationSettings.fromRow(Map<String, dynamic> row) {
    final int rawDays = row['global_days_before'] as int? ?? 3;
    final int rawHour = row['preferred_hour'] as int? ?? 9;
    final int rawMinute = row['preferred_minute'] as int? ?? 0;
    final String rawOverrides = row['category_overrides'] as String? ?? '{}';

    return NotificationSettings(
      enabled: (row['enabled'] as int? ?? 1) == 1,
      globalDaysBefore: _clampDays(rawDays),
      preferredHour: _clampHour(rawHour),
      preferredMinute: _clampMinute(rawMinute),
      categoryOverrides: _decodeOverrides(rawOverrides),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toRow() {
    return <String, dynamic>{
      'id': 1,
      'enabled': enabled ? 1 : 0,
      'global_days_before': _clampDays(globalDaysBefore),
      'preferred_hour': _clampHour(preferredHour),
      'preferred_minute': _clampMinute(preferredMinute),
      'category_overrides': jsonEncode(categoryOverrides),
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  static int _clampDays(int value) {
    if (value == 1 || value == 3 || value == 7) return value;
    return 3;
  }

  static int _clampHour(int value) => value.clamp(0, 23).toInt();

  static int _clampMinute(int value) => value.clamp(0, 59).toInt();

  static Map<String, int> _decodeOverrides(String raw) {
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, int> cleaned = <String, int>{};
      decoded.forEach((String key, dynamic value) {
        if (value is int) {
          cleaned[key] = _clampDays(value);
          return;
        }
        if (value is String) {
          final int? parsed = int.tryParse(value);
          if (parsed != null) {
            cleaned[key] = _clampDays(parsed);
          }
        }
      });
      return cleaned;
    } catch (_) {
      return <String, int>{};
    }
  }
}
