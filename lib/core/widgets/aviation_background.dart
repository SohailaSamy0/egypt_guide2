import 'dart:math' as math;

import 'package:flutter/material.dart';

class AviationBackground extends StatelessWidget {
  final Widget child;
  final bool includeSafeArea;

  const AviationBackground({
    super.key,
    required this.child,
    this.includeSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final content = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [
                      Color(0xFF07111F),
                      Color(0xFF0B2031),
                      Color(0xFF12394C),
                    ]
                  : const [
                      Color(0xFF6FE0F1),
                      Color(0xFFB5E8F6),
                      Color(0xFF78D8F0),
                    ],
            ),
          ),
        ),
        CustomPaint(
          painter: _AviationPainter(dark: dark),
        ),
        child,
      ],
    );

    return includeSafeArea ? SafeArea(child: content) : content;
  }
}

class AviationBackgroundDecoration extends Decoration {
  final bool dark;

  const AviationBackgroundDecoration({required this.dark});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _AviationBoxPainter(dark: dark);
  }
}

class _AviationBoxPainter extends BoxPainter {
  final bool dark;

  _AviationBoxPainter({required this.dark});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final rect = offset & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? const [
              Color(0xFF07111F),
              Color(0xFF0B2031),
              Color(0xFF12394C),
            ]
          : const [
              Color(0xFF6FE0F1),
              Color(0xFFB5E8F6),
              Color(0xFF78D8F0),
            ],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = gradient);
    _paintPattern(canvas, size, offset, dark);
  }
}

class _AviationPainter extends CustomPainter {
  final bool dark;

  const _AviationPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    _paintPattern(canvas, size, Offset.zero, dark);
  }

  @override
  bool shouldRepaint(covariant _AviationPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

void _paintPattern(Canvas canvas, Size size, Offset origin, bool dark) {
  final planePaint = Paint()
    ..color = (dark ? Colors.white : const Color(0xFF0074B8))
        .withValues(alpha: dark ? 0.07 : 0.08)
    ..style = PaintingStyle.fill;

  final cloudPaint = Paint()
    ..color = Colors.white.withValues(alpha: dark ? 0.035 : 0.11)
    ..style = PaintingStyle.fill;

  final points = <Offset>[
    Offset(size.width * 0.11, size.height * 0.14),
    Offset(size.width * 0.77, size.height * 0.10),
    Offset(size.width * 0.55, size.height * 0.31),
    Offset(size.width * 0.16, size.height * 0.48),
    Offset(size.width * 0.84, size.height * 0.55),
    Offset(size.width * 0.42, size.height * 0.72),
    Offset(size.width * 0.76, size.height * 0.87),
    Offset(size.width * 0.09, size.height * 0.91),
  ];

  for (var i = 0; i < points.length; i++) {
    final p = points[i] + origin;
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate((i.isEven ? -18 : 22) * math.pi / 180);
    final scale = i % 3 == 0 ? 1.2 : 0.85;
    canvas.scale(scale);
    canvas.drawPath(_planePath(), planePaint);
    canvas.restore();
  }

  final clouds = <Offset>[
    Offset(size.width * 0.18, size.height * 0.24),
    Offset(size.width * 0.72, size.height * 0.39),
    Offset(size.width * 0.30, size.height * 0.64),
  ];

  for (final c in clouds) {
    final p = c + origin;
    canvas.drawCircle(p, 34, cloudPaint);
    canvas.drawCircle(p + const Offset(32, 7), 24, cloudPaint);
    canvas.drawCircle(p + const Offset(-27, 10), 20, cloudPaint);
  }
}

Path _planePath() {
  return Path()
    ..moveTo(0, -22)
    ..quadraticBezierTo(4, -17, 4, -8)
    ..lineTo(20, 1)
    ..lineTo(20, 5)
    ..lineTo(4, 2)
    ..lineTo(3, 14)
    ..lineTo(9, 19)
    ..lineTo(9, 22)
    ..lineTo(0, 19)
    ..lineTo(-9, 22)
    ..lineTo(-9, 19)
    ..lineTo(-3, 14)
    ..lineTo(-4, 2)
    ..lineTo(-20, 5)
    ..lineTo(-20, 1)
    ..lineTo(-4, -8)
    ..quadraticBezierTo(-4, -17, 0, -22)
    ..close();
}
