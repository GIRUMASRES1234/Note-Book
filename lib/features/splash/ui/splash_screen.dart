import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../notes/ui/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Navigate to HomeScreen after splash screen duration
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    // Simple navigation without complex dependencies
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
        settings: const RouteSettings(name: '/home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff070d1a),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Mesh gradient background ──────────────────────────
          CustomPaint(painter: _MeshBackgroundPainter()),

          // ── Floating particles ────────────────────────────────
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleController.value),
            ),
          ),

          // ── Main content ──────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Outer glow ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) {
                    final glow = Tween(begin: 0.3, end: 1.0).evaluate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    );
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xff4f7fff,
                            ).withOpacity(0.18 * glow),
                            blurRadius: 48,
                            spreadRadius: 16,
                          ),
                          BoxShadow(
                            color: const Color(
                              0xff9b5cff,
                            ).withOpacity(0.10 * glow),
                            blurRadius: 80,
                            spreadRadius: 24,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: _LogoContainer(rotateController: _rotateController),
                ),

                const SizedBox(height: 36),

                // App name
                const Text(
                      'Student Notebook',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xfff0f4ff),
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    )
                    .animate()
                    .fade(delay: 500.ms, duration: 700.ms)
                    .slideY(begin: 0.25, curve: Curves.easeOut),

                const SizedBox(height: 10),

                // Tagline with accent chip
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff4f7fff).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xff4f7fff).withOpacity(0.25),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'Smart Notes for Smart Students 📚',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff8aabff),
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .animate()
                    .fade(delay: 750.ms, duration: 700.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOut),

                const SizedBox(height: 64),

                // Loading dots
                _LoadingDots().animate().fade(delay: 1100.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo container with rotating arc ─────────────────────────────────────────

class _LogoContainer extends StatelessWidget {
  final AnimationController rotateController;
  const _LogoContainer({required this.rotateController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating dashed arc behind logo
        AnimatedBuilder(
          animation: rotateController,
          builder: (_, __) => Transform.rotate(
            angle: rotateController.value * 2 * pi,
            child: CustomPaint(
              size: const Size(180, 180),
              painter: _ArcPainter(),
            ),
          ),
        ),

        // Logo card
        Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xff111827),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff4f7fff).withOpacity(0.35),
                  width: 1.2,
                ),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if logo doesn't exist
                      return const Icon(
                        Icons.note_alt,
                        size: 50,
                        color: Color(0xff4f7fff),
                      );
                    },
                  ),
                ),
              ),
            )
            .animate()
            .fade(duration: 800.ms)
            .scale(
              begin: const Offset(0.55, 0.55),
              curve: Curves.elasticOut,
              duration: 1100.ms,
            ),
      ],
    );
  }
}

// ── Loading dots ──────────────────────────────────────────────────────────────

class _LoadingDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xff4f7fff),
                shape: BoxShape.circle,
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(delay: Duration(milliseconds: 200 * i))
            .then()
            .fadeOut(duration: 600.ms)
            .then()
            .fadeIn(duration: 600.ms);
      }),
    );
  }
}

// ── Custom painters ───────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Outer dotted arc
    paint.color = const Color(0xff4f7fff).withOpacity(0.5);
    _drawDashedCircle(canvas, center, radius, paint, dashCount: 28);

    // Inner faint arc
    paint.color = const Color(0xff9b5cff).withOpacity(0.25);
    paint.strokeWidth = 0.8;
    _drawDashedCircle(canvas, center, radius - 16, paint, dashCount: 20);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    required int dashCount,
  }) {
    const dashRatio = 0.45;
    final angleStep = (2 * pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * angleStep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        angleStep * dashRatio,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}

class _MeshBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top-left blue blob
    paint.shader =
        RadialGradient(
          colors: [
            const Color(0xff1a3a7a).withOpacity(0.55),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.15, size.height * 0.18),
            radius: size.width * 0.55,
          ),
        );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.18),
      size.width * 0.55,
      paint,
    );

    // Bottom-right purple blob
    paint.shader =
        RadialGradient(
          colors: [
            const Color(0xff3b1f7a).withOpacity(0.45),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.88, size.height * 0.82),
            radius: size.width * 0.55,
          ),
        );
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.82),
      size.width * 0.55,
      paint,
    );
  }

  @override
  bool shouldRepaint(_MeshBackgroundPainter old) => false;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Random _rng = Random(42);

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 28; i++) {
      final x = _rng.nextDouble() * size.width;
      final baseY = _rng.nextDouble() * size.height;
      // Particles drift upward slowly
      final y =
          (baseY - progress * 80 * (0.3 + _rng.nextDouble() * 0.7)) %
          size.height;
      final r = 1.0 + _rng.nextDouble() * 2.0;
      final opacity =
          (0.08 + _rng.nextDouble() * 0.22) * (1.0 - (y / size.height) * 0.5);

      paint.color =
          (i % 3 == 0
                  ? const Color(0xff4f7fff)
                  : i % 3 == 1
                  ? const Color(0xff9b5cff)
                  : const Color(0xff5cf0c0))
              .withOpacity(opacity.clamp(0, 1));

      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
