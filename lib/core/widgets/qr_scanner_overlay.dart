import 'package:flutter/material.dart';

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength = borderLength > min(cutOutSize / 2, borderWidthSize) ? borderWidthSize / 2 : borderLength;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    // Draw overlay background
    canvas.saveLayer(
      rect,
      backgroundPaint,
    );
    canvas.drawRect(rect, backgroundPaint);
    // Draw the cut out area
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cutOutRect,
        Radius.circular(borderRadius),
      ),
      boxPaint,
    );
    canvas.restore();

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cutOutRect,
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );

    // Draw corner lines
    final lineLength = _borderLength;
    final lineWidth = borderWidth;
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // Top left corner
    canvas.drawLine(
      Offset(cutOutRect.left - lineWidth / 2, cutOutRect.top + lineLength),
      Offset(cutOutRect.left - lineWidth / 2, cutOutRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top - lineWidth / 2),
      Offset(cutOutRect.left + lineLength, cutOutRect.top - lineWidth / 2),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(cutOutRect.right + lineWidth / 2, cutOutRect.top + lineLength),
      Offset(cutOutRect.right + lineWidth / 2, cutOutRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top - lineWidth / 2),
      Offset(cutOutRect.right - lineLength, cutOutRect.top - lineWidth / 2),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(cutOutRect.left - lineWidth / 2, cutOutRect.bottom - lineLength),
      Offset(cutOutRect.left - lineWidth / 2, cutOutRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom + lineWidth / 2),
      Offset(cutOutRect.left + lineLength, cutOutRect.bottom + lineWidth / 2),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(cutOutRect.right + lineWidth / 2, cutOutRect.bottom - lineLength),
      Offset(cutOutRect.right + lineWidth / 2, cutOutRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom + lineWidth / 2),
      Offset(cutOutRect.right - lineLength, cutOutRect.bottom + lineWidth / 2),
      cornerPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }

  double min(double a, double b) {
    return a < b ? a : b;
  }
}