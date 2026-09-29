import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob 광고 단위 ID.
///
/// - 디버그 빌드(`flutter run`, `--debug`): 항상 Google 공식 테스트 ID.
///   개발 중 실제 광고를 클릭하면 무효 트래픽으로 계정이 정지될 수 있으므로.
/// - 릴리즈 빌드(`--release`, 스토어 배포): 실제 ID.
///
/// Android 실제 ID: AdMob 앱 "Coloring Fun" (ca-app-pub-7493209423244427~5057544618), 2026-09-29 등록.
/// 전면 광고는 쓰지 않는다(아동 대상).
class AdIds {
  AdIds._();

  // ── 실제 ID ─────────────────────────────────────────────────────────
  static const _androidReal = _Ids(
    banner: 'ca-app-pub-7493209423244427/4286639998',
    rewarded: 'ca-app-pub-7493209423244427/1613123628',
  );

  // TODO(iOS): AdMob 에서 iOS 앱 등록 후 교체
  static const _iosReal = _iosTest;

  // ── Google 공식 테스트 ID ────────────────────────────────────────────
  static const _androidTest = _Ids(
    banner: 'ca-app-pub-3940256099942544/6300978111',
    rewarded: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const _iosTest = _Ids(
    banner: 'ca-app-pub-3940256099942544/2934735716',
    rewarded: 'ca-app-pub-3940256099942544/1712485313',
  );

  static _Ids get _current {
    if (kReleaseMode) return Platform.isAndroid ? _androidReal : _iosReal;
    return Platform.isAndroid ? _androidTest : _iosTest;
  }

  static String get banner => _current.banner;
  static String get rewarded => _current.rewarded;
}

class _Ids {
  final String banner;
  final String rewarded;
  const _Ids({required this.banner, required this.rewarded});
}
