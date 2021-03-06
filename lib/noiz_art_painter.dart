library noiz_art_painter;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void renderNoizArt(NoizArtPainter noizArt) {
  RenderingFlutterBinding(
    root: RenderPositionedBox(
      alignment: Alignment.topLeft,
      child: RenderCustomPaint(
        painter: noizArt,
      ),
    ),
  );
}

class NoizArtPainter extends CustomPainter {
  NoizArtPainter() {
    init();
  }

  Canvas screenCanvas;
  Size screenSize;
  double screenWidth;
  double screenHeight;

  // rng
  Random rng;

  // color palette
  List<Color> _palette;

  // paint options
  Paint backgroundPaint = Paint();
  Paint fillPaint = Paint();
  Paint strokePaint = Paint();
  bool useFill = true;
  bool useStroke = true;

  final List<Alignment> alignmentList = <Alignment>[
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];

  void init() async {}

  Future<void> getSize() async {
    // find full screen canvas width and height
    final Size physicalSize = window.physicalSize;
    final double pixelRatio = window.devicePixelRatio;
    screenWidth = physicalSize.width / pixelRatio;
    screenHeight = physicalSize.height / pixelRatio;
  }

  @override
  void paint(Canvas canvas, Size size) {
    getSize();
    screenCanvas = canvas;
    screenSize = size;
    setRng();
    reset();
    draw();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void reset() {
    // reset to default settings
    fillPaint.style = PaintingStyle.fill;
    fillPaint.filterQuality = FilterQuality.high;
    fill(Colors.white24);

    strokePaint.style = PaintingStyle.stroke;
    strokePaint.filterQuality = FilterQuality.high;
    strokeWeight(3.0);
    stroke(Colors.white);
    strokePaint.strokeCap = StrokeCap.butt;
    strokePaint.strokeJoin = StrokeJoin.bevel;

    emptyColors();
  }

  void setRng([int seed]) {
    rng = Random(seed);
  }

  dynamic random([dynamic arg1, dynamic arg2]) {
    if (arg1 is List<dynamic>) {
      return arg1[rng.nextInt(arg1.length)];
    }

    if (arg1 is num && arg2 == null) {
      return rng.nextInt(arg1.toInt()).toDouble();
    }

    if (arg1 is num && arg2 is num) {
      arg1 = arg1.toInt();
      arg2 = arg2.toInt();
      return (arg2 == 0 ? 0 : arg1) +
          rng.nextInt((arg2 - arg1).abs()).toDouble();
    }

    return rng.nextDouble();
  }

  void addColor(Color newColor) {
    _palette.add(newColor);
  }

  void emptyColors() {
    _palette = <Color>[];
  }

  List<Color> get listColors => _palette;

  void draw() {}

  Color color(num r, num g, num b, [num a = 255]) {
    return Color.fromRGBO(r, g, b, a / 255);
  }

  Color hexColor(String hexColorString) {
    if (hexColorString == null) {
      return null;
    }
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = "FF" + hexColorString;
    }
    final int colorInt = int.parse(hexColorString, radix: 16);
    return Color(colorInt);
  }

  // background
  void background(Color color) {
    backgroundPaint.color = color;
    screenCanvas.drawPaint(backgroundPaint);
  }

  void gradientBackground({
    List<Color> colors,
  }) {
    if (colors == null) {
      final Color color1 = Colors.grey[800];
      final Color color2 = Colors.black;

      colors = <Color>[
        color1,
        color2,
      ];
    }

    final Rect fullRect = Rect.fromLTWH(0.0, 0.0, screenWidth, screenHeight);

    final Gradient gradient = LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final Paint gradientPaint = Paint()
      ..shader = gradient.createShader(fullRect);

    screenCanvas.drawRect(fullRect, gradientPaint);
  }

  void radialGradientBackground({
    Alignment center = Alignment.center,
    double radius = 1.5,
    List<Color> colors,
  }) {
    if (colors == null) {
      final Color color1 = Colors.grey[800];
      final Color color2 = Colors.black;

      colors = <Color>[
        color1,
        color2,
      ];
    }

    final Gradient gradient = RadialGradient(
      center: center ?? random(alignmentList),
      radius: radius,
      colors: colors,
    );

    final Rect rect = Rect.fromLTWH(0.0, 0.0, screenWidth, screenHeight);
    screenCanvas.drawPaint(Paint()..shader = gradient.createShader(rect));
  }

  void stroke(Color color) {
    strokePaint.color = color;
    useStroke = true;
  }

  void strokeWeight(num weight) {
    strokePaint.strokeWidth = weight.toDouble();
  }

  void noStroke() {
    useStroke = false;
  }

  void fill(Color color) {
    fillPaint.color = color;
    useFill = true;
  }

  void noFill() {
    useFill = false;
  }

  void ellipse(double x, double y, double w, [double h]) {
    final num _h = h ?? w;

    final Rect rect = Rect.fromCenter(
      center: Offset(
        x,
        y,
      ),
      width: w,
      height: _h,
    );

    if (useFill) {
      screenCanvas.drawOval(rect, fillPaint);
    }
    if (useStroke) {
      screenCanvas.drawOval(rect, strokePaint);
    }
  }

  void rect(double x, double y, double w, double h) {
    final Rect rect = Rect.fromLTWH(x, y, w, h);

    if (useFill) {
      screenCanvas.drawRect(rect, fillPaint);
    }
    if (useStroke) {
      screenCanvas.drawRect(rect, strokePaint);
    }
  }

  void line(double x1, double y1, double x2, double y2) {
    if (useStroke) {
      screenCanvas.drawLine(Offset(x1, y1), Offset(x2, y2), strokePaint);
    }
  }
}
