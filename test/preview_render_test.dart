// 그림 미리보기 PNG 생성 (눈으로 확인용). 실행: flutter test test/preview_render_test.dart
// 결과: build/previews/sheet.png (16장 모음, 칠한 상태/안 칠한 상태)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_coloring/art/palette.dart';
import 'package:kids_coloring/art/pictures.dart';
import 'package:kids_coloring/widgets/picture_painter.dart';

void main() {
  test('render preview sheet', () async {
    const cell = 250.0;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final cols = 8, rows = (pictures.length * 2 / cols).ceil();
    for (var i = 0; i < pictures.length; i++) {
      final p = pictures[i];
      for (var v = 0; v < 2; v++) {
        final fills = v == 0
            ? List.filled(p.regions.length, 0)
            : [for (var r = 0; r < p.regions.length; r++) palette[(r * 5 + i) % 17].toARGB32()];
        final k = i * 2 + v;
        canvas.save();
        canvas.translate((k % cols) * cell, (k ~/ cols) * cell);
        PicturePainter(p, fills).paint(canvas, const Size(cell - 6, cell - 6));
        canvas.restore();
      }
    }
    final img = await rec.endRecording().toImage((cols * cell).toInt(), (rows * cell).toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/previews').createSync(recursive: true);
    File('build/previews/sheet.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
