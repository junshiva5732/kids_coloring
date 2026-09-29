import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_coloring/art/pictures.dart';
import 'package:kids_coloring/l10n/strings.dart';
import 'package:kids_coloring/services/coloring_store.dart';

void main() {
  test('pictures: unique ids, every pack has 4+ pictures, background first', () {
    expect(pictures.map((p) => p.id).toSet().length, pictures.length);
    for (var pack = 0; pack < packCount; pack++) {
      expect(pictures.where((p) => p.pack == pack).length, greaterThanOrEqualTo(4));
    }
    for (final p in pictures) {
      expect(p.regions.length, greaterThan(2), reason: p.id);
      expect(p.regions.first.getBounds(), const Rect.fromLTRB(0, 0, 1000, 1000), reason: p.id);
    }
  });

  test('every region is reachable by a tap somewhere', () {
    // 각 영역의 경계 상자 안을 격자로 훑어, 그 영역이 가장 위로 잡히는 점이 하나는 있어야 한다.
    for (final p in pictures) {
      for (var i = 1; i < p.regions.length; i++) {
        final b = p.regions[i].getBounds();
        var hit = false;
        for (var x = b.left; x <= b.right && !hit; x += b.width / 12) {
          for (var y = b.top; y <= b.bottom && !hit; y += b.height / 12) {
            if (p.regionAt(Offset(x, y)) == i) hit = true;
          }
        }
        expect(hit, isTrue, reason: '${p.id} region $i is fully covered');
      }
    }
  });

  test('every picture has a name in every language', () {
    for (final l in S.supported) {
      final s = S(l);
      for (final p in pictures) {
        expect(s.pictureName(p.id), isNot(p.id), reason: '${l.languageCode} ${p.id}');
      }
      expect(s.packNames.length, packCount);
    }
  });

  test('store: paint, undo value, completion, unlock', () {
    final store = ColoringStore.memory();
    final p = pictures.first;
    expect(store.isStarted(p), isFalse);
    expect(store.paint(p, 1, 0xFFFF0000), 0);
    expect(store.paint(p, 1, 0xFF00FF00), 0xFFFF0000);
    expect(store.isStarted(p), isTrue);
    expect(store.isComplete(p), isFalse);
    for (var i = 1; i < p.regions.length; i++) {
      store.paint(p, i, 0xFF0000FF);
    }
    expect(store.isComplete(p), isTrue); // 배경은 안 칠해도 완성
    store.clear(p);
    expect(store.isStarted(p), isFalse);

    expect(store.isUnlocked(0), isTrue);
    expect(store.isUnlocked(1), isFalse);
    store.unlock(1);
    expect(store.isUnlocked(1), isTrue);
  });
}
