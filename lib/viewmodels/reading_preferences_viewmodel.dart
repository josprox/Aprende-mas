import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingPreferences {
  final double textScale;

  const ReadingPreferences({
    this.textScale = 1.0,
  });

  ReadingPreferences copyWith({
    double? textScale,
  }) {
    return ReadingPreferences(
      textScale: textScale ?? this.textScale,
    );
  }
}

class ReadingPreferencesNotifier extends StateNotifier<ReadingPreferences> {
  static const String _keyTextScale = 'reading_text_scale';

  ReadingPreferencesNotifier() : super(const ReadingPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final scale = prefs.getDouble(_keyTextScale) ?? 1.0;
    state = state.copyWith(textScale: scale);
  }

  Future<void> setTextScale(double scale) async {
    // Clamp between 0.85 and 1.6
    final clamped = scale.clamp(0.85, 1.6);
    state = state.copyWith(textScale: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextScale, clamped);
  }

  Future<void> resetTextScale() async {
    await setTextScale(1.0);
  }
}

final readingPreferencesProvider =
    StateNotifierProvider<ReadingPreferencesNotifier, ReadingPreferences>((ref) {
  return ReadingPreferencesNotifier();
});
