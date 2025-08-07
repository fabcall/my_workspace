import 'dart:async';
import 'package:flutter/material.dart';

/// Simple splash screen that shows logo and waits for initialization
class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationFinished;
  final Duration minDisplayDuration;
  final String? logoAssetPath;
  final String? appName;
  final String? tagline;

  const SplashScreen({
    super.key,
    required this.onInitializationFinished,
    this.minDisplayDuration = const Duration(seconds: 2),
    this.logoAssetPath,
    this.appName,
    this.tagline,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  bool _initializationComplete = false;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _startMinTimeTimer();
    _checkInitialization();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Curves.easeInOut,
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: Curves.elasticOut,
          ),
        );

    _pulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _startAnimations() {
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _scaleController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _startMinTimeTimer() {
    Future.delayed(widget.minDisplayDuration, () {
      if (mounted) {
        setState(() {
          _minTimeElapsed = true;
        });
        _checkIfCanFinish();
      }
    });
  }

  void _checkInitialization() {
    // Simple timer-based check - in real app, this would check actual initialization status
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Simulate initialization completion after a delay
      // In real app, you would check your app's initialization state here
      if (!_initializationComplete) {
        setState(() {
          _initializationComplete = true;
        });
        timer.cancel();
        _checkIfCanFinish();
      }
    });
  }

  void _checkIfCanFinish() {
    if (_initializationComplete && _minTimeElapsed) {
      _finishSplash();
    }
  }

  void _finishSplash() {
    widget.onInitializationFinished();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _fadeAnimation,
              _scaleAnimation,
              _pulseAnimation,
            ]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value * _pulseAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      _buildLogo(context),

                      const SizedBox(height: 32),

                      // App Name
                      if (widget.appName != null) ...[
                        Text(
                          widget.appName!,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tagline
                      if (widget.tagline != null) ...[
                        Text(
                          widget.tagline!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                      ] else ...[
                        const SizedBox(height: 64),
                      ],

                      // Loading indicator
                      _buildLoadingIndicator(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    if (widget.logoAssetPath != null) {
      return Image.asset(
        widget.logoAssetPath!,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultLogo(context);
        },
      );
    } else {
      return _buildDefaultLogo(context);
    }
  }

  Widget _buildDefaultLogo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.flutter_dash,
        size: 60,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
