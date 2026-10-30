import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../providers/product_provider.dart';
import 'home_screen.dart';

/// Bounce-drop brand animation, live status pill and progress bar.
/// Preloads the catalog while the animation plays, then fades into Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (!mounted) return;
    // Never block the splash for more than 8s on a slow network.
    final bootstrap = context
        .read<ProductProvider>()
        .bootstrap()
        .timeout(const Duration(seconds: 8), onTimeout: () {});

    await Future.wait<void>([_controller.forward(), bootstrap]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(AppRoutes.fade(const HomeScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              _LogoPlate(animation: _controller),
              const SizedBox(height: 28),
              _BrandTitle(animation: _controller),
              const SizedBox(height: 8),
              Text(
                'Belanja Segar & Cepat Setiap Hari',
                textAlign: TextAlign.center,
                style: AppText.bodyMedium,
              ),
              const Spacer(flex: 3),
              _StatusPill(animation: _controller),
              const SizedBox(height: 16),
              _ProgressBar(animation: _controller),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPlate extends StatelessWidget {
  const _LogoPlate({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.pastelPedestal,
          borderRadius: BorderRadius.circular(40),
          boxShadow: AppShadows.soft,
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          size: 56,
          color: AppColors.primaryInk,
        ),
      ),
      builder: (_, child) {
        final t = const Interval(0, 0.2).transform(animation.value);
        return Transform.scale(
          scale: Curves.easeOutBack.transform(t),
          child: child,
        );
      },
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.animation});

  static const String _brand = 'Ngemart.id';

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final style = AppText.headlineXL.copyWith(fontSize: 38, height: 1.2);

    return Semantics(
      label: _brand,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _brand.length; i++)
                  _buildLetter(_brand[i], i, style),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLetter(String char, int index, TextStyle style) {
    // Letters start staggered; each one drops with a bounce curve.
    final begin = 0.1 + index * 0.035;
    final t = Interval(begin, begin + 0.28).transform(animation.value);
    final dy = -160 * (1 - Curves.bounceOut.transform(t));
    final opacity = (t * 4).clamp(0.0, 1.0).toDouble();

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Text(char, style: style),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.animation});

  static const List<String> _messages = [
    'Menyiapkan etalase…',
    'Memuat katalog produk…',
    'Merapikan tampilan…',
    'Siap berbelanja!',
  ];

  final Animation<double> animation;

  String _messageFor(double progress) {
    if (progress < 0.34) return _messages[0];
    if (progress < 0.68) return _messages[1];
    if (progress < 1) return _messages[2];
    return _messages[3];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final done = animation.value >= 1;
        final message = _messageFor(animation.value);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              done
                  ? const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.success,
                    )
                  : const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  message,
                  key: ValueKey<String>(message),
                  style: AppText.labelMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: Curves.easeInOut.transform(animation.value),
              minHeight: 6,
              backgroundColor: AppColors.surfaceWhite,
              color: AppColors.primaryInk,
            ),
          );
        },
      ),
    );
  }
}
