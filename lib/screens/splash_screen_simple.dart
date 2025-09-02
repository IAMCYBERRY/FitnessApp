/// Simplified splash screen without Firebase dependencies
import 'package:flutter/material.dart';
import 'package:rivalx/config/theme.dart';

class SplashScreenSimple extends StatefulWidget {
  const SplashScreenSimple({super.key});

  @override
  State<SplashScreenSimple> createState() => _SplashScreenSimpleState();
}

class _SplashScreenSimpleState extends State<SplashScreenSimple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'RivalX',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.accentYellow,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'COMPETE. CONQUER. REPEAT.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slateGrey,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'UI Theme Demo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.slateGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}