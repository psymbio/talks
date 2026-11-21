import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../theme.dart';

// ---------------------------------------------------------------------------
// The mouse glyph, drawn to read like the animals in the paper: a dark leaf
// with the nose at the narrow end, a thin hooked tail, and ears only as soft
// bumps in the silhouette. One subtle gradient and a low shadow keep it from
// looking flat; no faces, no colour — the shape carries it.
//
// Geometry is in body-length units with the nose along +x, so the same paths
// can be reused by the thermal painter.
// ---------------------------------------------------------------------------

/// SLEAP-style landmarks in mouse-local units.
const mouseNodes = <String, Offset>{
  'nose': Offset(0.56, 0),
  'left ear': Offset(0.06, -0.31),
  'right ear': Offset(0.06, 0.31),
  'body centre': Offset(0, 0),
  'tail base': Offset(-0.52, 0),
};

const _earCentres = [Offset(0.06, -0.27), Offset(0.06, 0.27)];
const _earR = 0.115;

/// The body outline, in pixels, for a mouse of body length [s].
Path mouseBody(double s) => Path()
  ..moveTo(0.62 * s, 0)
  ..cubicTo(0.40 * s, 0.22 * s, 0.08 * s, 0.31 * s, -0.22 * s, 0.30 * s)
  ..cubicTo(-0.50 * s, 0.29 * s, -0.60 * s, 0.16 * s, -0.60 * s, 0)
  ..cubicTo(-0.60 * s, -0.16 * s, -0.50 * s, -0.29 * s, -0.22 * s, -0.30 * s)
  ..cubicTo(0.08 * s, -0.31 * s, 0.40 * s, -0.22 * s, 0.62 * s, 0)
  ..close();

/// Body plus ear bumps, unioned into one closed shape.
Path mouseSilhouette(double s) {
  var path = mouseBody(s);
  for (final ear in _earCentres) {
    path = Path.combine(
      PathOperation.union,
      path,
      Path()..addOval(Rect.fromCircle(center: ear * s, radius: _earR * s)),
    );
  }
  return path;
}

/// The tail: a thin hook leaving the rear of the body.
Path mouseTail(double s) => Path()
  ..moveTo(-0.56 * s, 0.06 * s)
  ..cubicTo(-0.84 * s, 0.20 * s, -0.92 * s, 0.46 * s, -0.68 * s, 0.52 * s);

/// Paints a mouse centred on [center], nose along [angle] (radians).
void paintMouse(
  Canvas canvas,
  Offset center,
  double angle,
  double length, {
  Color body = fur,
  double opacity = 1,
  Color? halo,
  bool ghost = false,
  bool subject = false,
  bool shadow = true,
  bool skeleton = false,
}) {
  final s = length;
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(angle);

  final shape = mouseSilhouette(s);
  final tail = mouseTail(s);
  final fillColor = ghost ? ghostFur : body;
  final lineColor = ghost ? ghostLine : Color.lerp(body, Colors.black, 0.45)!;

  if (shadow && !ghost) {
    canvas.save();
    canvas.translate(0.015 * s, 0.045 * s);
    canvas.drawPath(
      shape,
      Paint()
        ..color = fade(ink, 0.16 * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.05 * s),
    );
    canvas.restore();
  }

  if (halo != null) {
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.14 * s
        ..strokeJoin = StrokeJoin.round
        ..color = fade(halo, opacity * 0.9),
    );
  }

  canvas.drawPath(
    tail,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.032 * s
      ..strokeCap = StrokeCap.round
      ..color = fade(ghost ? ghostLine : fillColor, opacity),
  );

  final bounds = shape.getBounds();
  canvas.drawPath(
    shape,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fade(Color.lerp(fillColor, Colors.white, ghost ? 0.4 : 0.14)!,
              opacity),
          fade(fillColor, opacity),
        ],
      ).createShader(bounds),
  );
  canvas.drawPath(
    shape,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (ghost ? 0.022 : 0.028) * s
      ..strokeJoin = StrokeJoin.round
      ..color = fade(lineColor, opacity * (ghost ? 0.8 : 1)),
  );

  // Fig. 3a marks the scored animal with a magenta dot.
  if (subject) {
    canvas.drawCircle(
      Offset.zero,
      0.085 * s,
      Paint()..color = fade(subjectPink, opacity),
    );
  }

  if (skeleton) _paintSkeleton(canvas, s, opacity);

  canvas.restore();
}

void _paintSkeleton(Canvas canvas, double s, double opacity) {
  const edges = ['nose', 'left ear', 'right ear', 'tail base'];
  const edgeColors = [
    Color(0xFF3DA5F5),
    Color(0xFFFFA23A),
    Color(0xFFFFA23A),
    Color(0xFFB079F0),
  ];
  final centre = mouseNodes['body centre']! * s;
  for (final (i, name) in edges.indexed) {
    canvas.drawLine(
      centre,
      mouseNodes[name]! * s,
      Paint()
        ..strokeWidth = 0.026 * s
        ..strokeCap = StrokeCap.round
        ..color = fade(edgeColors[i], opacity),
    );
  }
  for (final node in mouseNodes.values) {
    canvas.drawCircle(
      node * s,
      0.042 * s,
      Paint()..color = fade(Colors.white, opacity),
    );
    canvas.drawCircle(
      node * s,
      0.042 * s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.013 * s
        ..color = fade(ink, opacity),
    );
  }
}

/// A thin arrow, used for the movement cues in Fig. 3a.
void paintArrow(
  Canvas canvas,
  Offset from,
  Offset to, {
  Color color = ink,
  double width = 4,
  double opacity = 1,
  bool dashed = false,
}) {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..color = fade(color, opacity);
  final delta = to - from;
  final len = delta.distance;
  if (len < 1) return;
  final dir = delta / len;

  if (dashed) {
    const dash = 14.0, gap = 10.0;
    var travelled = 0.0;
    while (travelled < len) {
      final end = math.min(travelled + dash, len);
      canvas.drawLine(from + dir * travelled, from + dir * end, paint);
      travelled = end + gap;
    }
  } else {
    canvas.drawLine(from, to, paint);
  }

  final head = width * 3.2;
  final left = Offset(-dir.dy, dir.dx);
  canvas.drawPath(
    Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - dir.dx * head + left.dx * head * 0.55,
          to.dy - dir.dy * head + left.dy * head * 0.55)
      ..lineTo(to.dx - dir.dx * head - left.dx * head * 0.55,
          to.dy - dir.dy * head - left.dy * head * 0.55)
      ..close(),
    Paint()..color = fade(color, opacity),
  );
}

// ---------------------------------------------------------------------------
// Groups of mice
// ---------------------------------------------------------------------------

/// Where a mouse is and how it looks. [pos] is in arena units (0 ... 1).
class MouseSpec {
  const MouseSpec(
    this.pos,
    this.angle, {
    this.body = fur,
    this.halo,
    this.opacity = 1,
    this.skeleton = false,
    this.ghost = false,
    this.subject = false,
  });

  final Offset pos;
  final double angle;
  final Color body;
  final Color? halo;
  final double opacity;
  final bool skeleton;
  final bool ghost;
  final bool subject;

  MouseSpec copyWith({
    Color? halo,
    bool? skeleton,
    Color? body,
    bool? ghost,
    bool? subject,
    double? opacity,
  }) =>
      MouseSpec(
        pos,
        angle,
        body: body ?? this.body,
        halo: halo ?? this.halo,
        opacity: opacity ?? this.opacity,
        skeleton: skeleton ?? this.skeleton,
        ghost: ghost ?? this.ghost,
        subject: subject ?? this.subject,
      );

  static MouseSpec lerp(MouseSpec a, MouseSpec b, double t) => MouseSpec(
        Offset.lerp(a.pos, b.pos, t)!,
        lerpAngle(a.angle, b.angle, t),
        body: Color.lerp(a.body, b.body, t)!,
        halo: Color.lerp(a.halo, b.halo, t),
        opacity: lerpDouble(a.opacity, b.opacity, t)!,
        skeleton: t < 0.5 ? a.skeleton : b.skeleton,
        ghost: t < 0.5 ? a.ghost : b.ghost,
        subject: t < 0.5 ? a.subject : b.subject,
      );
}

/// Interpolates between two angles the short way round.
double lerpAngle(double a, double b, double t) {
  var delta = (b - a) % (2 * math.pi);
  if (delta > math.pi) delta -= 2 * math.pi;
  return a + delta * t;
}

/// Interpolates a group of mice along a list of configurations;
/// [stage] runs from 0 to `states.length - 1`.
List<MouseSpec> lerpStates(List<List<MouseSpec>> states, double stage) {
  final i = math.min(math.max(stage.floor(), 0), states.length - 2);
  final t = _ease((stage - i).clamp(0.0, 1.0));
  return [
    for (var k = 0; k < states[i].length; k++)
      MouseSpec.lerp(states[i][k], states[i + 1][k], t),
  ];
}

double _ease(double t) => t * t * (3 - 2 * t);

/// A behaviour box seen from above, with mice in it.
class ArenaPainter extends CustomPainter {
  ArenaPainter({
    required this.mice,
    this.fill = Colors.white,
    this.border = ink,
    this.borderWidth = 6,
    this.mouseLength = 0.21,
    this.snowflake = false,
  });

  final List<MouseSpec> mice;
  final Color fill;
  final Color border;
  final double borderWidth;

  /// Mouse body length as a fraction of the arena width.
  final double mouseLength;

  /// Draws the cold marker the paper puts in the corner of chilled boxes.
  final bool snowflake;

  @override
  void paint(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(borderWidth / 2),
      Radius.circular(size.shortestSide * 0.035),
    );
    canvas.drawRRect(box, Paint()..color = fill);
    canvas.save();
    canvas.clipRRect(box);
    if (snowflake) {
      _paintSnowflake(
        canvas,
        Offset(size.width * 0.1, size.height * 0.1),
        size.shortestSide * 0.045,
      );
    }
    final ordered = [...mice]..sort((a, b) => (a.ghost ? 0 : 1) - (b.ghost ? 0 : 1));
    for (final m in ordered) {
      if (m.opacity <= 0.01) continue;
      paintMouse(
        canvas,
        Offset(m.pos.dx * size.width, m.pos.dy * size.height),
        m.angle,
        mouseLength * size.width,
        body: m.body,
        halo: m.halo,
        opacity: m.opacity,
        skeleton: m.skeleton,
        ghost: m.ghost,
        subject: m.subject,
      );
    }
    canvas.restore();
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(ArenaPainter oldDelegate) => true;
}

void _paintSnowflake(Canvas canvas, Offset at, double r) {
  final paint = Paint()
    ..strokeWidth = r * 0.16
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF8FE3FF);
  for (var i = 0; i < 3; i++) {
    final a = i * math.pi / 3;
    final d = Offset(math.cos(a), math.sin(a)) * r;
    canvas.drawLine(at - d, at + d, paint);
  }
}
