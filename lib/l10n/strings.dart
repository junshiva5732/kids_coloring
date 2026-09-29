import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 앱 문자열 (en / ko / ja / zh). 기본은 시스템 언어를 따르고(미지원 언어는 영어),
/// 갤러리 화면의 언어 버튼으로 바꿀 수 있다 ([LocaleController]).
class S {
  final Locale locale;
  const S(this.locale);

  static S of(BuildContext context) => Localizations.of<S>(context, S)!;
  static const LocalizationsDelegate<S> delegate = _SDelegate();
  static const supported = [Locale('en'), Locale('ko'), Locale('ja'), Locale('zh')];

  static Locale resolve(Locale? l) =>
      supported.firstWhere((s) => s.languageCode == l?.languageCode, orElse: () => supported.first);

  static String nativeName(Locale l) => switch (l.languageCode) {
    'ko' => '한국어',
    'ja' => '日本語',
    'zh' => '简体中文',
    _ => 'English',
  };

  String _t(String en, String ko, String ja, String zh) => switch (locale.languageCode) {
    'ko' => ko,
    'ja' => ja,
    'zh' => zh,
    _ => en,
  };

  String get appTitle => _t('Coloring Fun', '색칠 놀이', 'ぬりえあそび', '涂色乐园');

  List<String> get packNames => [
    _t('My First Pictures', '처음 색칠', 'はじめてのぬりえ', '第一本涂色'),
    _t('Adventure', '신나는 모험', 'わくわく冒険', '奇妙冒险'),
    _t('Animals & Treats', '동물 친구와 간식', 'どうぶつとおやつ', '动物和甜点'),
  ];

  String pictureName(String id) => switch (id) {
    'sun' => _t('Sun', '해님', 'おひさま', '太阳'),
    'house' => _t('House', '우리 집', 'おうち', '房子'),
    'fish' => _t('Fish', '물고기', 'さかな', '小鱼'),
    'flower' => _t('Flower', '꽃', 'おはな', '花朵'),
    'car' => _t('Car', '자동차', 'くるま', '汽车'),
    'cat' => _t('Cat', '고양이', 'ねこ', '小猫'),
    'tree' => _t('Tree', '나무', 'き', '大树'),
    'balloons' => _t('Balloons', '풍선', 'ふうせん', '气球'),
    'rocket' => _t('Rocket', '로켓', 'ロケット', '火箭'),
    'boat' => _t('Sailboat', '돛단배', 'ヨット', '帆船'),
    'snowman' => _t('Snowman', '눈사람', 'ゆきだるま', '雪人'),
    'rainbow' => _t('Rainbow', '무지개', 'にじ', '彩虹'),
    'butterfly' => _t('Butterfly', '나비', 'ちょうちょ', '蝴蝶'),
    'turtle' => _t('Turtle', '거북이', 'かめ', '乌龟'),
    'icecream' => _t('Ice Cream', '아이스크림', 'アイスクリーム', '冰淇淋'),
    'hearts' => _t('Hearts & Stars', '하트와 별', 'ハートとほし', '爱心和星星'),
    _ => id,
  };

  // 색칠 화면
  String get undo => _t('Undo', '되돌리기', 'もどす', '撤销');
  String get startOver => _t('Start over', '처음부터', 'さいしょから', '重新开始');
  String get startOverAsk => _t('Erase all the colors?', '색을 모두 지울까요?', 'いろを ぜんぶ けしますか？', '要擦掉所有颜色吗？');
  String get yes => _t('Yes', '네', 'はい', '是');
  String get no => _t('No', '아니요', 'いいえ', '否');
  String get wellDone => _t('Great job!', '참 잘했어요!', 'よくできました！', '真棒！');

  // 잠긴 팩 / 부모 확인
  String get locked => _t('Locked', '잠김', 'ロック中', '已锁定');
  String get forGrownUps => _t('For grown-ups', '어른 확인', 'おとなの かたへ', '家长确认');
  String gateQuestion(int a, int b) => _t(
    'Please ask a grown-up.\nWhat is $a × $b?',
    '어른에게 부탁하세요.\n$a × $b 는 얼마일까요?',
    'おとなの かたに たのんでね。\n$a × $b は？',
    '请让大人来回答。\n$a × $b 等于多少？',
  );
  String get gateWrong => _t('Not quite. Try again!', '틀렸어요. 다시 해 보세요!', 'ちがいます。もういちど！', '不对哦，再试一次！');
  String unlockBody(String pack) => _t(
    'Watch a short ad to unlock "$pack" (4 pictures) forever.',
    '짧은 광고를 보면 "$pack" 그림 4장이 영구히 열려요.',
    'みじかい広告を見ると「$pack」の4まいが ずっと使えます。',
    '观看一段短广告即可永久解锁“$pack”（4 张图）。',
  );
  String get watchAd => _t('Watch ad', '광고 보기', '広告を見る', '观看广告');
  String get cancel => _t('Cancel', '취소', 'キャンセル', '取消');
  String get adNotReady => _t(
    'No ad available right now. Please try again later.',
    '지금은 광고를 불러올 수 없어요. 잠시 후 다시 시도해 주세요.',
    '現在広告を読み込めません。しばらくしてからお試しください。',
    '暂时无法加载广告，请稍后再试。',
  );
  String unlocked(String pack) => _t('"$pack" unlocked!', '"$pack" 열림!', '「$pack」がひらきました！', '“$pack”已解锁！');

  // 설정
  String get language => _t('Language', '언어', '言語', '语言');
  String get systemLanguage => _t('System default', '시스템 기본', 'システムの設定', '跟随系统');
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) => S.supported.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<S> load(Locale locale) => SynchronousFuture(S(locale));

  @override
  bool shouldReload(_SDelegate old) => false;
}

/// 사용자가 고른 언어. null 이면 시스템 언어를 따른다.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController(super.value);

  static LocaleController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LocaleScope>()!.controller;

  static Locale? fromCode(String? code) =>
      code == null ? null : S.supported.cast<Locale?>().firstWhere((l) => l!.languageCode == code, orElse: () => null);
}

class LocaleScope extends StatelessWidget {
  final LocaleController controller;
  final Widget child;
  const LocaleScope({super.key, required this.controller, required this.child});

  @override
  Widget build(BuildContext context) => _LocaleScope(controller: controller, child: child);
}

class _LocaleScope extends InheritedWidget {
  final LocaleController controller;
  const _LocaleScope({required this.controller, required super.child});

  @override
  bool updateShouldNotify(_LocaleScope old) => old.controller != controller;
}
