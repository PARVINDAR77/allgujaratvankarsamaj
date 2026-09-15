import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

/// 2-Page Interactive Poster Screen with fully functional hotspots on both images,
/// including the Blue Login Button and Green Registration Button.
class LoginScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const LoginScreen({super.key, this.initialPage = 0});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final PageController _pageController;
  late int _currentPage;

  final _emailController = TextEditingController(text: 'panjabiparvindar77@gmail.com');
  final _passwordController = TextEditingController(text: 'Parvindar@123');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) {
      if (_currentPage < 1) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        context.go('/home');
      }
    } else {
      _showLoginDialog();
    }
  }

  void _navigateToRegister() {
    context.push('/register');
  }

  Future<void> _performLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      final updatedAuth = ref.read(authNotifierProvider);
      if (updatedAuth.isAuthenticated) {
        if (_currentPage < 1) {
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        } else {
          context.go('/home');
        }
      } else if (updatedAuth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedAuth.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Text(
          'વંકર સમાજ લોગિન (Sign In)',
          style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('રદ કરો (Cancel)', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _performLogin();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('લોગિન કરો', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPosterImageDialog() {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (dialogCtx) => Scaffold(
        backgroundColor: const Color(0xFF020B18),
        body: SafeArea(
          child: Stack(
            children: [
              // Full poster image (1.jpeg / pavan_prernadata_full.jpg)
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Image.asset(
                    'assets/images/pavan_prernadata.jpg',
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/pavan_prernadata_full.jpg',
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/WhatsApp Image 2026-09-08 at 10.08.45 PM.jpeg',
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),

              // Top-Left Back Button to return to Page 2
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(dialogCtx),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF041126), Color(0xFF0A2246)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded, color: Color(0xFFD4AF37), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'પાછા જાઓ (Back)',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuperStarsDialog() {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (dialogCtx) => Scaffold(
        backgroundColor: const Color(0xFF020B18),
        body: SafeArea(
          child: Stack(
            children: [
              // Full poster image (super stars.jpeg)
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Image.asset(
                    'assets/images/super_stars.jpeg',
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                  ),
                ),
              ),

              // Top-Left Back Button to return to Page 2
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(dialogCtx),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF041126), Color(0xFF0A2246)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded, color: Color(0xFFD4AF37), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'પાછા જાઓ (Back)',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: SafeArea(
        child: Stack(
          children: [
            // PageView with NeverScrollableScrollPhysics to prevent swiping between pages
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (pageIndex) {
                setState(() => _currentPage = pageIndex);
              },
              children: [
                // =============================================================
                // PAGE 1: Image 1 (1 (2).jpeg / login_poster_1.jpg)
                // =============================================================
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenW = constraints.maxWidth;
                    final screenH = constraints.maxHeight;
                    final posterH = screenH > 0
                        ? (screenH > screenW * (1000 / 685) ? screenH : screenW * (1000 / 685))
                        : 600.0;

                    return SingleChildScrollView(
                      child: SizedBox(
                        width: screenW,
                        height: posterH,
                        child: Stack(
                          children: [
                            // 1. Background Image 1
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/login_poster_1.jpg',
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF041026),
                                ),
                              ),
                            ),

                            // Hotspot 1: Government Employees (Red Circle)
                            Positioned(
                              left: screenW * 0.02,
                              top: posterH * 0.40,
                              width: screenW * 0.22,
                              height: posterH * 0.18,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  context.push('/government-employees');
                                },
                              ),
                            ),

                            // Hotspot 2: Matrimony (Pink Circle) -> Advances to Page 2
                            Positioned(
                              left: screenW * 0.26,
                              top: posterH * 0.40,
                              width: screenW * 0.22,
                              height: posterH * 0.18,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: _nextPage,
                              ),
                            ),

                            // Hotspot 3: Private Job (Blue Circle)
                            Positioned(
                              left: screenW * 0.50,
                              top: posterH * 0.40,
                              width: screenW * 0.22,
                              height: posterH * 0.18,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.go('/search'),
                              ),
                            ),

                            // Hotspot 4: VANKAR SAMAJ Services (Green Circle)
                            Positioned(
                              left: screenW * 0.74,
                              top: posterH * 0.40,
                              width: screenW * 0.22,
                              height: posterH * 0.18,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.push('/samaj-services'),
                              ),
                            ),

                            // Hotspot 5: Lion (Developed Gujarat)
                            Positioned(
                              left: screenW * 0.02,
                              top: posterH * 0.64,
                              width: screenW * 0.25,
                              height: posterH * 0.13,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.push('/pargana-overview'),
                              ),
                            ),

                            // Hotspot 6: Train (Empowered Vankar Samaj)
                            Positioned(
                              left: screenW * 0.72,
                              top: posterH * 0.64,
                              width: screenW * 0.26,
                              height: posterH * 0.13,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.push('/verified-profile'),
                              ),
                            ),

                            // Hotspot 7: Blue "Login" Button
                            Positioned(
                              left: screenW * 0.08,
                              top: posterH * 0.78,
                              width: screenW * 0.40,
                              height: posterH * 0.08,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.blue.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: _showLoginDialog,
                                ),
                              ),
                            ),

                            // Hotspot 8: Green "Registration" Button -> Registration screen
                            Positioned(
                              left: screenW * 0.52,
                              top: posterH * 0.78,
                              width: screenW * 0.40,
                              height: posterH * 0.08,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.green.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: _navigateToRegister,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // =============================================================
                // PAGE 2: Image 2 (1 (1).jpeg / login_poster_2.jpg)
                // =============================================================
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenW = constraints.maxWidth;
                    final screenH = constraints.maxHeight;
                    final posterH = screenH > 0
                        ? (screenH > screenW * (1000 / 685) ? screenH : screenW * (1000 / 685))
                        : 600.0;

                    return SingleChildScrollView(
                      child: SizedBox(
                        width: screenW,
                        height: posterH,
                        child: Stack(
                          children: [
                            // 1. Background Image 2
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/login_poster_2.jpg',
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF041026),
                                ),
                              ),
                            ),

                            // 2. Base Tap-anywhere to enter Home (/home)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () => context.go('/home'),
                              ),
                            ),

                            // Hotspot 1: 1. પાવન પ્રેરણાદાતા
                            Positioned(
                              left: screenW * 0.10,
                              top: posterH * 0.86,
                              width: screenW * 0.38,
                              height: posterH * 0.09,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _showPosterImageDialog,
                                ),
                              ),
                            ),

                            // Hotspot 2: 2. Samaj Super Stars
                            Positioned(
                              left: screenW * 0.52,
                              top: posterH * 0.86,
                              width: screenW * 0.38,
                              height: posterH * 0.09,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _showSuperStarsDialog,
                                ),
                              ),
                            ),

                            // Hotspot 3: Blue "Login" Button on Page 2
                            Positioned(
                              left: screenW * 0.08,
                              top: posterH * 0.77,
                              width: screenW * 0.40,
                              height: posterH * 0.08,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.blue.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: _showLoginDialog,
                                ),
                              ),
                            ),

                            // Hotspot 4: Green "Registration" Button on Page 2
                            Positioned(
                              left: screenW * 0.52,
                              top: posterH * 0.77,
                              width: screenW * 0.40,
                              height: posterH * 0.08,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.green.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => context.push('/register'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Loading Indicator Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
