import 'package:flutter/foundation.dart';

import '../art/pictures.dart';
import 'storage.dart';

/// 모든 그림의 색칠 상태와 열린 팩. 바뀌면 바로 저장한다.
class ColoringStore extends ChangeNotifier {
  final Storage? _storage;
  final Map<String, List<int>> _fills;
  final Set<int> _unlocked;

  ColoringStore(Storage storage) : _storage = storage, _fills = storage.loadFills(), _unlocked = storage.unlockedPacks;

  @visibleForTesting
  ColoringStore.memory() : _storage = null, _fills = {}, _unlocked = {};

  /// [p] 의 영역별 색 (0 = 안 칠함). 그림이 바뀌어 영역 수가 달라져도 길이를 맞춘다.
  List<int> fillsOf(Picture p) {
    final f = _fills[p.id];
    if (f != null && f.length == p.regions.length) return f;
    return List.filled(p.regions.length, 0);
  }

  /// 영역 [region] 을 [argb] 로 칠한다. 이전 색을 돌려준다(되돌리기용).
  int paint(Picture p, int region, int argb) {
    final f = List<int>.of(fillsOf(p));
    final prev = f[region];
    f[region] = argb;
    _fills[p.id] = f;
    _changed();
    return prev;
  }

  void clear(Picture p) {
    _fills.remove(p.id);
    _changed();
  }

  /// 배경을 뺀 모든 영역이 칠해졌는지.
  bool isComplete(Picture p) => fillsOf(p).skip(1).every((c) => c != 0);

  /// 하나라도 칠했는지 (갤러리 표시용).
  bool isStarted(Picture p) => fillsOf(p).any((c) => c != 0);

  bool isUnlocked(int pack) => pack == 0 || _unlocked.contains(pack);

  void unlock(int pack) {
    _unlocked.add(pack);
    _storage?.setUnlockedPacks(_unlocked);
    notifyListeners();
  }

  void _changed() {
    _storage?.saveFills(_fills);
    notifyListeners();
  }
}
