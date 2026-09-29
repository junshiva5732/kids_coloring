import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// 그림을 만드는 도형 도우미. 좌표계는 1000 x 1000.
///
/// 각 함수는 닫힌 [Path] 를 돌려준다. 칠할 수 있는 영역(region)과 선 장식(detail) 모두 이것으로 만든다.

Path circle(double cx, double cy, double r) => Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

Path oval(double l, double t, double r, double b) => Path()..addOval(Rect.fromLTRB(l, t, r, b));

Path rect(double l, double t, double r, double b) => Path()..addRect(Rect.fromLTRB(l, t, r, b));

Path rrect(double l, double t, double r, double b, double radius) =>
    Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));

/// 점 목록 [x0, y0, x1, y1, ...] 으로 닫힌 다각형.
Path poly(List<double> xy) {
  assert(xy.length >= 6 && xy.length.isEven);
  final p = Path()..moveTo(xy[0], xy[1]);
  for (var i = 2; i < xy.length; i += 2) {
    p.lineTo(xy[i], xy[i + 1]);
  }
  return p..close();
}

/// (cx, cy) 를 중심으로 [deg] 도 돌린 타원.
Path rotatedOval(double cx, double cy, double rx, double ry, double deg) {
  final p = oval(cx - rx, cy - ry, cx + rx, cy + ry);
  final a = deg * math.pi / 180;
  final c = math.cos(a), s = math.sin(a);
  // 중심 기준 회전: T(c) · R · T(-c)
  final m = Float64List.fromList([
    c, s, 0, 0, //
    -s, c, 0, 0, //
    0, 0, 1, 0, //
    cx - c * cx + s * cy, cy - s * cx - c * cy, 0, 1,
  ]);
  return p.transform(m);
}

/// 부채꼴 띠 (무지개 한 줄): 중심 (cx, cy), 바깥 반지름 [outer], 안쪽 [inner], 위쪽 반원.
Path arcBand(double cx, double cy, double outer, double inner) {
  final p = Path()
    ..moveTo(cx - outer, cy)
    ..arcToPoint(Offset(cx + outer, cy), radius: Radius.circular(outer))
    ..lineTo(cx + inner, cy)
    ..arcToPoint(Offset(cx - inner, cy), radius: Radius.circular(inner), clockwise: false)
    ..close();
  return p;
}

/// 별 (꼭짓점 [points] 개).
Path star(double cx, double cy, double outer, double inner, {int points = 5}) {
  final xy = <double>[];
  for (var i = 0; i < points * 2; i++) {
    final r = i.isEven ? outer : inner;
    final a = -math.pi / 2 + i * math.pi / points;
    xy
      ..add(cx + r * math.cos(a))
      ..add(cy + r * math.sin(a));
  }
  return poly(xy);
}

/// 하트.
Path heart(double cx, double cy, double w) {
  final h = w * 0.9;
  return Path()
    ..moveTo(cx, cy + h * 0.45)
    ..cubicTo(cx - w * 0.9, cy - h * 0.05, cx - w * 0.45, cy - h * 0.75, cx, cy - h * 0.3)
    ..cubicTo(cx + w * 0.45, cy - h * 0.75, cx + w * 0.9, cy - h * 0.05, cx, cy + h * 0.45)
    ..close();
}

Path union(Path a, Path b) => Path.combine(PathOperation.union, a, b);

Path minus(Path a, Path b) => Path.combine(PathOperation.difference, a, b);

/// 열린 선 (장식용: 수염, 입, 더듬이 등). 칠하지 않고 선만 그린다.
Path line(List<double> xy) {
  final p = Path()..moveTo(xy[0], xy[1]);
  for (var i = 2; i < xy.length; i += 2) {
    p.lineTo(xy[i], xy[i + 1]);
  }
  return p;
}

/// 호 (웃는 입 등). 중심, 반지름, 시작/끝 각도(도).
Path arc(double cx, double cy, double r, double fromDeg, double sweepDeg) =>
    Path()
      ..addArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), fromDeg * math.pi / 180, sweepDeg * math.pi / 180);
