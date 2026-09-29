import 'package:flutter/material.dart';

import '../art/pictures.dart';

/// 그림 하나를 그린다: 아래 영역부터 채우기(안 칠한 곳은 흰색)와 테두리 → 선 장식.
/// 1000x1000 좌표를 위젯 크기에 맞춰 늘린다. 갤러리 썸네일과 색칠 화면이 함께 쓴다.
class PicturePainter extends CustomPainter {
  final Picture picture;
  final List<int> fills;
  final double strokeWidth;

  PicturePainter(this.picture, this.fills, {this.strokeWidth = 7});

  static const outline = Color(0xFF2B2B2B);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1000, size.height / 1000);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 1000, 1000));

    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = outline;
    // 영역마다 채우기 → 테두리 순서로 그려야 위에 겹친 영역이 아래 영역의 선을 가린다.
    // 배경(0번) 테두리는 캔버스 가장자리라 그리지 않는다.
    for (var i = 0; i < picture.regions.length; i++) {
      final c = i < fills.length ? fills[i] : 0;
      fill.color = c == 0 ? Colors.white : Color(c);
      canvas.drawPath(picture.regions[i], fill);
      if (i > 0) canvas.drawPath(picture.regions[i], stroke);
    }
    for (final d in picture.details) {
      canvas.drawPath(d, stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PicturePainter old) =>
      old.picture != picture || !identical(old.fills, fills) || old.strokeWidth != strokeWidth;
}
