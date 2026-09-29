import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 색칠 상태·열린 팩·언어 설정을 기기에 저장한다.
class Storage {
  static const _kFills = 'fills';
  static const _kUnlocked = 'unlocked_packs';
  static const _kLocale = 'locale';

  final SharedPreferences _prefs;
  Storage(this._prefs);

  static Future<Storage> create() async => Storage(await SharedPreferences.getInstance());

  /// 사용자가 고른 언어 코드 (null = 시스템 언어).
  String? get localeCode => _prefs.getString(_kLocale);
  Future<void> setLocaleCode(String? code) => code == null ? _prefs.remove(_kLocale) : _prefs.setString(_kLocale, code);

  /// 그림 id → 영역별 색(ARGB, 0 = 안 칠함).
  Map<String, List<int>> loadFills() {
    final s = _prefs.getString(_kFills);
    if (s == null) return {};
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, (v as List).map((e) => (e as num).toInt()).toList()));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveFills(Map<String, List<int>> fills) => _prefs.setString(_kFills, jsonEncode(fills));

  Set<int> get unlockedPacks => (_prefs.getStringList(_kUnlocked) ?? []).map(int.parse).toSet();
  Future<void> setUnlockedPacks(Set<int> packs) => _prefs.setStringList(_kUnlocked, packs.map((p) => '$p').toList());
}
