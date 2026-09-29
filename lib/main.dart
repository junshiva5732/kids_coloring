import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ads/ad_manager.dart';
import 'l10n/strings.dart';
import 'screens/gallery_screen.dart';
import 'services/coloring_store.dart';
import 'services/storage.dart';

/// 스크린샷 촬영용 언어 강제 (디버그 빌드에서만 동작). 예: --dart-define=LOCALE=ko
const _localeOverride = String.fromEnvironment('LOCALE');

/// 앱 시드색 (크레파스 느낌의 따뜻한 주황).
const seedColor = Color(0xFFFF9F43);

ColorScheme _scheme(Brightness b) => ColorScheme.fromSeed(seedColor: seedColor, brightness: b);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 광고 SDK 초기화는 앱 표시를 막지 않도록 기다리지 않는다.
  AdManager.instance.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final storage = await Storage.create();
  runApp(ColoringApp(storage: storage, store: ColoringStore(storage)));
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
