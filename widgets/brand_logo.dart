import 'package:flutter/material.dart';

import '../theme.dart';

class LabCdLogo extends StatelessWidget {
  const LabCdLogo({
    super.key,
    this.height = 36,
    this.color = LcdColors.gold,
  });

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const aspect = 140.903 / 111.785;
    return Semantics(
      label: 'Logótipo LAB Catarina Domingos',
      image: true,
      child: SizedBox(
        width: height * aspect,
        height: height,
        child: CustomPaint(
          painter: _LabCdLogoPainter(color),
        ),
      ),
    );
  }
}

class LabCdBrandLockup extends StatelessWidget {
  const LabCdBrandLockup({
    super.key,
    this.markHeight = 32,
    this.subtitle,
    this.titleColor = LcdColors.cream,
    this.subtitleColor = LcdColors.muted,
  });

  final double markHeight;
  final String? subtitle;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabCdLogo(height: markHeight),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LAB Catarina Domingos',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabCdLogoPainter extends CustomPainter {
  _LabCdLogoPainter(this.color);
  final Color color;

  static final Path _logoPath = _buildPath();

  static Path _buildPath() {
    final p = Path()..fillType = PathFillType.evenOdd;
    // Exact path from assets/branding/logotipo.svg (viewBox 140.903 x 111.785)
    p.moveTo(104.48, 2.273);
    p.cubicTo(117.226, -0.223, 129.846, 5.194, 136.042, 16.42);
    p.cubicTo(140.937, 25.289, 141.382, 35.44, 139.006, 45.401);
    p.cubicTo(135.194, 61.377, 129.707, 76.585, 122.331, 91.273);
    p.cubicTo(118.8, 98.305, 112.314, 109.533, 106.425, 108.592);
    p.cubicTo(105.127, 108.385, 102.721, 106.636, 102.357, 105.327);
    p.lineTo(99.792, 96.088);
    p.cubicTo(98.871, 97.243, 97.868, 98.348, 96.781, 99.403);
    p.cubicTo(89.688, 106.281, 80.44, 109.72, 69.035, 109.72);
    p.lineTo(32.79, 109.72);
    p.lineTo(32.896, 108.651);
    p.lineTo(34.18, 108.651);
    p.cubicTo(35.961, 108.651, 37.494, 108.063, 38.777, 106.887);
    p.cubicTo(40.06, 105.711, 40.808, 104.267, 41.022, 102.557);
    p.lineTo(41.022, 85.413);
    p.cubicTo(33.703, 85.15, 27.056, 83.451, 21.082, 80.318);
    p.cubicTo(14.56, 76.896, 9.499, 72.227, 5.899, 66.311);
    p.cubicTo(2.3, 60.395, 0.5, 53.784, 0.5, 46.478);
    p.cubicTo(0.5, 39.172, 2.282, 32.56, 5.846, 26.644);
    p.cubicTo(9.41, 20.728, 14.328, 16.077, 20.601, 12.691);
    p.cubicTo(26.873, 9.305, 33.859, 7.613, 41.557, 7.613);
    p.cubicTo(46.404, 7.613, 51.34, 8.272, 56.365, 9.591);
    p.cubicTo(61.39, 10.909, 65.578, 12.673, 68.928, 14.883);
    p.lineTo(71.067, 29.959);
    p.lineTo(70.104, 29.959);
    p.cubicTo(68.607, 23.971, 65.15, 19.285, 59.733, 15.899);
    p.cubicTo(54.316, 12.513, 48.293, 10.82, 41.664, 10.82);
    p.cubicTo(32.184, 10.82, 24.289, 14.188, 17.981, 20.924);
    p.cubicTo(11.673, 27.66, 8.519, 36.124, 8.519, 46.317);
    p.cubicTo(8.519, 56.51, 11.78, 65.046, 18.302, 71.924);
    p.cubicTo(24.218, 78.164, 31.792, 81.574, 41.022, 82.153);
    p.lineTo(41.022, 38.085);
    p.cubicTo(32.112, 38.298, 25.804, 39.688, 22.098, 42.254);
    p.cubicTo(20.173, 43.609, 18.712, 44.91, 17.714, 46.157);
    p.cubicTo(16.716, 47.404, 15.683, 48.99, 14.613, 50.915);
    p.lineTo(13.437, 50.487);
    p.cubicTo(15.504, 44.428, 18.961, 40.259, 23.808, 37.978);
    p.cubicTo(28.655, 35.697, 37.245, 34.556, 49.576, 34.556);
    p.cubicTo(52.142, 34.556, 58.628, 34.663, 69.035, 34.877);
    p.cubicTo(76.591, 35.091, 83.255, 36.73, 89.029, 39.795);
    p.cubicTo(94.803, 42.86, 99.311, 47.19, 102.554, 52.786);
    p.cubicTo(105.797, 58.381, 107.419, 64.886, 107.419, 72.299);
    p.cubicTo(107.419, 77.998, 106.499, 83.137, 104.66, 87.718);
    p.cubicTo(106.626, 95.58, 106.926, 101.866, 108.2, 101.198);
    p.cubicTo(114.802, 97.737, 124.968, 62.355, 127.696, 50.144);
    p.cubicTo(131.141, 34.725, 130.647, 16.784, 115.041, 10.825);
    p.cubicTo(98.334, 4.447, 84.54, 24.423, 69.73, 14.478);
    p.cubicTo(76.149, 13.988, 81.402, 12.563, 86.578, 9.424);
    p.cubicTo(92.13, 6.058, 98.013, 3.54, 104.48, 2.273);
    p.close();

    p.moveTo(47.972, 38.085);
    p.lineTo(47.972, 82.064);
    p.cubicTo(56.69, 81.283, 63.942, 77.92, 69.73, 71.978);
    p.cubicTo(76.395, 65.135, 79.727, 55.762, 79.727, 43.858);
    p.lineTo(80.796, 43.858);
    p.cubicTo(80.867, 44.714, 80.903, 45.569, 80.903, 46.424);
    p.cubicTo(80.903, 58.684, 77.606, 68.254, 71.013, 75.132);
    p.cubicTo(65.347, 81.044, 57.666, 84.415, 47.972, 85.246);
    p.lineTo(47.972, 106.513);
    p.lineTo(69.035, 106.513);
    p.cubicTo(78.088, 106.513, 85.412, 103.376, 91.007, 97.104);
    p.cubicTo(96.602, 90.831, 99.4, 82.563, 99.4, 72.299);
    p.cubicTo(99.4, 65.527, 98.135, 59.557, 95.604, 54.39);
    p.cubicTo(93.074, 49.222, 89.51, 45.212, 84.913, 42.361);
    p.cubicTo(80.315, 39.51, 75.023, 38.085, 69.035, 38.085);
    p.close();

    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 140.903, size.height / 111.785);
    canvas.drawPath(_logoPath, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LabCdLogoPainter oldDelegate) => oldDelegate.color != color;
}
