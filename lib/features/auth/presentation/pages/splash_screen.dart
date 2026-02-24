import 'package:flutter/material.dart';
import 'package:kempa/core/di/injection_container.dart';

class SplashController extends ChangeNotifier {
  bool _animationDone = false;

  bool get animationDone => _animationDone;

  void markAnimationDone() {
    _animationDone = true;
    notifyListeners();
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loaderController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _oneSlide;
  late Animation<Offset> _emguSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _loaderOpacity;

  bool _disposed = false;

  late final SplashController splashController;

  @override
  void initState() {
    super.initState();
    splashController = sl.get<SplashController>();
    _initAnimations();
    _startAnimation();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loaderController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _oneSlide = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );

    _emguSlide = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loaderController,
        curve: Curves.easeIn,
      ),
    );
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_disposed) return;

    await _logoController.forward();
    if (_disposed) return;

    await _textController.forward();
    if (_disposed) return;

    await _loaderController.forward();
    if (_disposed) return;

    splashController.markAnimationDone();
  }

  @override
  void dispose() {
    _disposed = true;
    _logoController.dispose();
    _textController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _oneSlide,
                  child: Transform.translate(
                    offset: const Offset(12, 0),
                    child: const Text(
                      "1",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 72,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    "{",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 72,
                      height: 1.2,
                    ),
                  ),
                ),
                SlideTransition(
                  position: _emguSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: const Text(
                      "емГУ",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 56,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 48),
            FadeTransition(
              opacity: _loaderOpacity,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}