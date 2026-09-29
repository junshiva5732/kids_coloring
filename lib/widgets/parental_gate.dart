import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/strings.dart';

/// 부모 확인: 아이가 광고·설정으로 넘어가지 못하게 곱셈 문제를 낸다 (Google Play 가족 정책 권장).
/// 정답을 고르면 true, 틀리거나 닫으면 false.
Future<bool> showParentalGate(BuildContext context, {math.Random? random}) async {
  final r = random ?? math.Random();
  final a = 6 + r.nextInt(4), b = 6 + r.nextInt(4); // 36~81: 어린아이가 풀기 어려운 범위
  final answer = a * b;
  final choices = <int>{answer};
  while (choices.length < 3) {
    final delta = (r.nextInt(5) + 1) * (r.nextBool() ? 1 : -1);
    final c = answer + delta * (r.nextBool() ? 1 : a);
    if (c > 0) choices.add(c);
  }
  final options = choices.toList()..shuffle(r);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final s = S.of(ctx);
      return AlertDialog(
        icon: const Icon(Icons.lock_person_rounded, size: 36),
        title: Text(s.forGrownUps),
        content: Text(s.gateQuestion(a, b), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          for (final o in options)
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, o == answer),
              child: Text('$o', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
        ],
      );
    },
  );
  if (result == false && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).gateWrong), duration: const Duration(seconds: 2)));
  }
  return result == true;
}
