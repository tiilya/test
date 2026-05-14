import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Loading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showMainScreen = false;

  void _onLoadingComplete() {
    setState(() => _showMainScreen = true);
  }

  @override
  Widget build(BuildContext context) {
    return _showMainScreen
        ? const MainScreen()
        : LoadingScreen(onLoadingComplete: _onLoadingComplete);
  }
}

// ─── Loading Screen ───────────────────────────────────────────────────────────

class LoadingScreen extends StatefulWidget {
  final VoidCallback onLoadingComplete;

  const LoadingScreen({super.key, required this.onLoadingComplete});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Looping shimmer — sweeps continuously while loading
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startLoading() {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    // Simulate network request — replace with real Future
    Future.delayed(const Duration(seconds: 4), () {
      _fadeController.forward().then((_) => widget.onLoadingComplete());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AppleShimmerWidget(shimmerController: _shimmerController),
              const SizedBox(height: 48),
              AnimatedOpacity(
                opacity: _isLoading ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: _startLoading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD94F3D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Загрузить данные',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Apple Shimmer Widget ─────────────────────────────────────────────────────

class _AppleShimmerWidget extends StatelessWidget {
  final AnimationController shimmerController;

  const _AppleShimmerWidget({required this.shimmerController});

  @override
  Widget build(BuildContext context) {
    const double size = 260;

    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, _) {
        // t goes -0.5 → 1.5 so the stripe fully enters and exits the image
        final double t = shimmerController.value * 2 - 0.5;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // BW apple — always visible underneath
              Image.asset(
                'assets/apple_bw.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
              // Color apple masked to a diagonal shimmer stripe
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    transform: _DiagonalGradientTransform(t),
                    colors: const [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ).createShader(bounds);
                },
                child: Image.asset(
                  'assets/apple_color.png',
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Shifts the gradient horizontally so the stripe sweeps across the image
class _DiagonalGradientTransform extends GradientTransform {
  final double t; // -0.5 … 1.5

  const _DiagonalGradientTransform(this.t);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double dx = (t - 0.5) * bounds.width * 2;
    return Matrix4.translationValues(dx, 0, 0);
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD94F3D),
        foregroundColor: Colors.white,
        title: const Text('Главный экран'),
      ),
      body: const Center(
        child: Text(
          'Данные загружены!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
