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
    setState(() {
      _showMainScreen = true;
    });
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
  late final AnimationController _fillController;
  late final AnimationController _fadeController;
  late final Animation<double> _fillAnimation;
  late final Animation<double> _fadeAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _fadeController.forward().then((_) {
            widget.onLoadingComplete();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _fillController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startLoading() {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    _fillController.forward(from: 0.0);
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
              _AppleProgressWidget(fillAnimation: _fillAnimation),
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

// ─── Apple Widget ─────────────────────────────────────────────────────────────

class _AppleProgressWidget extends StatelessWidget {
  final Animation<double> fillAnimation;

  const _AppleProgressWidget({required this.fillAnimation});

  @override
  Widget build(BuildContext context) {
    const double size = 260;

    return AnimatedBuilder(
      animation: fillAnimation,
      builder: (context, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Black & white apple (always visible underneath)
              Image.asset(
                'assets/apple_bw.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
              // Color apple revealed from bottom to top
              ClipRect(
                clipper: _BottomUpClipper(fillAnimation.value),
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

class _BottomUpClipper extends CustomClipper<Rect> {
  final double progress;

  _BottomUpClipper(this.progress);

  @override
  Rect getClip(Size size) {
    final double revealedHeight = size.height * progress;
    return Rect.fromLTRB(
      0,
      size.height - revealedHeight,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(_BottomUpClipper old) => old.progress != progress;
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
