import 'package:flutter/foundation.dart';

enum SuggestedActionType {
  breathing,
  directions,
  audio,
  save,
  timer,
  checklist,
  note,
  call,
  menu;

  static SuggestedActionType? fromWire(String? value) {
    for (final type in values) {
      if (type.name == value) return type;
    }
    return null;
  }
}

/// A contextual call-to-action attached to a place ("Start a 12-minute walk").
@immutable
final class SuggestedAction {
  const SuggestedAction({
    required this.type,
    required this.label,
    this.description,
  });

  /// Returns `null` for malformed entries so callers can filter them out,
  /// mirroring `readSuggestedActions` on the server.
  static SuggestedAction? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final type = SuggestedActionType.fromWire(raw['type'] as String?);
    final label = _trimmed(raw['label']);
    if (type == null || label == null) return null;

    return SuggestedAction(
      type: type,
      label: label,
      description: _trimmed(raw['description']),
    );
  }

  final SuggestedActionType type;
  final String label;
  final String? description;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'label': label,
    if (description != null) 'description': description,
  };

  static String? _trimmed(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestedAction &&
          type == other.type &&
          label == other.label &&
          description == other.description;

  @override
  int get hashCode => Object.hash(type, label, description);
}
