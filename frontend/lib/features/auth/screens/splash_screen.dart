import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final navigator = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await ref.read(authControllerProvider.notifier).restoreSession();
    if (!mounted) return;
    final isAuth = ref.read(authControllerProvider).isAuthenticated;
    navigator.pushReplacementNamed(isAuth ? AppRoutes.home : AppRoutes.welcome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NOTO',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  letterSpacing: 4,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reflect your thoughts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
