// Borda tracejada (a página usa border: dashed), para estados vazios e atalhos.
//
// Uso: CustomPaint(painter: const BordaTracejada(), child: ...)
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class BordaTracejada extends CustomPainter {
  final double traco;
  final double espaco;

  const BordaTracejada({this.traco = 5, this.espaco = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppCores.bordaForte
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final caminho = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(0.5),
        const Radius.circular(raio),
      ));
    for (final metrica in caminho.computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += traco + espaco) {
        canvas.drawPath(metrica.extractPath(d, d + traco), paint);
      }
    }
  }

  @override
  bool shouldRepaint(BordaTracejada old) => old.traco != traco || old.espaco != espaco;
}
