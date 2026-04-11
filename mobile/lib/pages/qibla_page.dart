import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/image_utils.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  bool _hasPermission = false;
  bool _isLoading = true;
  double? _distance;
  double? _qiblaAngle;
  late String _bgImage;

  @override
  void initState() {
    super.initState();
    _bgImage = ImageUtils.getRandomCamiImage();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bool? hasSensor = await FlutterQiblah.androidDeviceSensorSupport();
      if (hasSensor == false) {
        // Log or handle devices without magnetic sensors
      }
      
      final status = await FlutterQiblah.checkLocationStatus();
      
      if (status.enabled && (status.status == LocationPermission.always || status.status == LocationPermission.whileInUse)) {
        await _calculateDistance();
        setState(() {
          _hasPermission = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _checkPermission();
    }
  }

  Future<void> _calculateDistance() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      
      // Calculate Qibla Angle manually
      double lat = position.latitude;
      double lng = position.longitude;
      double phiK = 21.422487 * math.pi / 180.0;
      double lambdaK = 39.826206 * math.pi / 180.0;
      double phi = lat * math.pi / 180.0;
      double lambda = lng * math.pi / 180.0;

      double y = math.sin(lambdaK - lambda);
      double x = math.cos(phi) * math.tan(phiK) - math.sin(phi) * math.cos(lambdaK - lambda);
      double qibla = math.atan2(y, x);
      
      setState(() {
        _qiblaAngle = (qibla * 180.0 / math.pi + 360.0) % 360.0;
        _distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          21.422487,
          39.826206,
        ) / 1000.0;
      });
    } catch (e) {
      // Error handled silently as fallback values are used
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              elevation: 0,
              title: Text(
                l10n.qiblaFinder,
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'Noto Serif',
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              _bgImage,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.7),
                    colorScheme.surface.withValues(alpha: 0.9),
                    colorScheme.surface,
                  ],
                  stops: const [0.0, 0.4, 0.9],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _buildBody(context, l10n, colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_off, size: 48, color: colorScheme.error),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.qiblaPermissionRequired,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.qiblaGrantPermission,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: Text(l10n.qiblaSettings),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'Sensör verisi bekleniyor...',
              style: TextStyle(fontFamily: 'Manrope'),
            ),
          );
        }

        final qiblaData = snapshot.data!;
        double heading = qiblaData.direction;
        double targetQiblaAngle = _qiblaAngle ?? qiblaData.qiblah;
        double offset = (targetQiblaAngle - heading + 360) % 360;
        bool isAligned = (offset < 5 || offset > 355);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.qiblaDirection,
                      style: textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Noto Serif',
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (_distance != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.qiblaDistance(_distance!.toStringAsFixed(0)),
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Circle Decoration
                  Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface.withValues(alpha: 0.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  // Entire Compass Assembly
                  Transform.rotate(
                    angle: ((-heading) * (math.pi / 180.0)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass Dial
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CustomPaint(
                            painter: CompassPainter(colorScheme: colorScheme),
                          ),
                        ),
                        // Qibla Needle
                        Transform.rotate(
                          angle: (targetQiblaAngle * (math.pi / 180.0)),
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: CustomPaint(
                              painter: QiblaNeedlePainter(
                                colorScheme: colorScheme,
                                isActive: isAligned,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Center Point
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isAligned ? Colors.green : colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: (isAligned ? Colors.green : colorScheme.primary).withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Top Arrow Reference
                  Positioned(
                    top: -5,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: isAligned 
                    ? Colors.green.withValues(alpha: 0.15) 
                    : colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isAligned ? Colors.green : colorScheme.outline.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAligned ? Icons.check_circle : Icons.explore,
                      color: isAligned ? Colors.green : colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isAligned ? 'Kıbleye Yöneldiniz' : '${heading.toStringAsFixed(0)}°',
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        color: isAligned ? Colors.green : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }
}

class CompassPainter extends CustomPainter {
  final ColorScheme colorScheme;

  CompassPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = {
      'N': 0,
      'E': 90,
      'S': 180,
      'W': 270,
    };

    for (var entry in directions.entries) {
      double angle = entry.value * math.pi / 180.0;
      Offset offset = Offset(
        center.dx + (radius - 20) * math.sin(angle),
        center.dy - (radius - 20) * math.cos(angle),
      );

      textPainter.text = TextSpan(
        text: entry.key,
        style: TextStyle(
          fontFamily: 'Manrope',
          color: entry.key == 'N' ? Colors.red : colorScheme.onSurface.withValues(alpha: 0.4),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // Draw degree markings
    for (int i = 0; i < 360; i += 10) {
      double angle = i * math.pi / 180.0;
      double startRadius = radius - (i % 90 == 0 ? 15 : 10);
      Offset start = Offset(
        center.dx + startRadius * math.sin(angle),
        center.dy - startRadius * math.cos(angle),
      );
      Offset end = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QiblaNeedlePainter extends CustomPainter {
  final ColorScheme colorScheme;
  final bool isActive;

  QiblaNeedlePainter({required this.colorScheme, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = isActive ? Colors.green : colorScheme.primary
      ..style = PaintingStyle.fill;

    // Draw needle
    Path path = Path();
    path.moveTo(center.dx, center.dy - radius + 10); // Top
    path.lineTo(center.dx - 12, center.dy); // Side
    path.lineTo(center.dx + 12, center.dy); // Side
    path.close();

    canvas.drawPath(path, paint);

    // Kabe Icon
    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '🕋',
        style: TextStyle(fontSize: 28),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas, 
      Offset(center.dx - iconPainter.width / 2, center.dy - radius - 25)
    );
  }

  @override
  bool shouldRepaint(covariant QiblaNeedlePainter oldDelegate) => 
    oldDelegate.isActive != isActive;
}
