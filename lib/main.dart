import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ads/ad_manager.dart';
import 'art/pictures.dart';
import 'l10n/strings.dart';
import 'screens/gallery_screen.dart';
import 'services/coloring_store.dart';
import 'services/storage.dart';

/// 스크린샷 촬영용 언어 강제 (디버그 빌드에서만 동작). 예: --dart-define=LOCALE=ko
const _localeOverride = String.fromEnvironment('LOCALE');

/// 스크린샷 촬영용: 몇몇 그림을 미리 칠해 두고 팩 1 을 연다 (디버그 빌드에서만). --dart-define=DEMO=true
const _demo = bool.fromEnvironment('DEMO');

/// 앱 시드색 (크레파스 느낌의 따뜻한 주황).
const seedColor = Color(0xFFFF9F43);

ColorScheme _scheme(Brightness b) => ColorScheme.fromSeed(seedColor: seedColor, brightness: b);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 광고 SDK 초기화는 앱 표시를 막지 않도록 기다리지 않는다.
  AdManager.instance.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final storage = await Storage.create();
  final store = ColoringStore(storage);
  if (kDebugMode && _demo) _seedDemo(store);
  runApp(ColoringApp(storage: storage, store: store));
}

class ColoringApp extends StatefulWidget {
  final Storage storage;
  final ColoringStore store;
  const ColoringApp({super.key, required this.storage, required this.store});

  @override
  State<ColoringApp> createState() => _ColoringAppState();
}

class _ColoringAppState extends State<ColoringApp> {
  late final LocaleController _locale;

  @override
  void initState() {
    super.initState();
    _locale = LocaleController(LocaleController.fromCode(widget.storage.localeCode));
    _locale.addListener(() => widget.storage.setLocaleCode(_locale.value?.languageCode));
  }

  @override
  void dispose() {
    _locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _locale,
      child: ListenableBuilder(
        listenable: _locale,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => S.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          // 아이용: 항상 밝은 테마
          theme: ThemeData(
            colorScheme: _scheme(Brightness.light),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFFFF8EC),
          ),
          localizationsDelegates: const [S.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: S.supported,
          locale: kDebugMode && _localeOverride.isNotEmpty ? Locale(_localeOverride) : _locale.value,
          home: GalleryScreen(store: widget.store),
        ),
      ),
    );
  }
}

/// 스토어 스크린샷용 색칠 예시. 영역 순서는 pictures.dart 정의와 같다. 꽃은 일부러 덜 칠해 둔다.
void _seedDemo(ColoringStore store) {
  const sky = 0xFF4FC3F7, yellow = 0xFFFDD835, orange = 0xFFFB8C00, red = 0xFFE53935, green = 0xFF43A047;
  const brown = 0xFF8D6E63, peach = 0xFFFFE0B2, dark = 0xFF424242, pink = 0xFFEC407A, white = 0xFFFFFFFF;
  const gray = 0xFFBDBDBD, navy = 0xFF3949AB, purple = 0xFF8E24AA, mint = 0xFFA5D6A7;
  const demo = <String, List<int>>{
    'sun': [sky, orange, orange, orange, orange, orange, orange, orange, orange, yellow, dark, dark, pink, pink],
    'house': [sky, yellow, green, brown, peach, red, brown, sky, sky, yellow],
    'fish': [sky, white, white, white, peach, orange, orange, yellow, orange, white, dark],
    'flower': [mint, green, green, green, green, pink, pink, pink, 0, 0, 0, 0],
    'car': [sky, yellow, gray, red, red, sky, sky, dark, dark, gray, gray, yellow],
    'rocket': [navy, yellow, yellow, yellow, purple, orange, red, red, white, sky, red],
  };
  for (final p in pictures) {
    store.clear(p);
    final colors = demo[p.id];
    if (colors == null) continue;
    for (var i = 0; i < colors.length && i < p.regions.length; i++) {
      if (colors[i] != 0) store.paint(p, i, colors[i]);
    }
  }
  store.unlock(1);
}
