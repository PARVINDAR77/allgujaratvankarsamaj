import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const LoginScreen({super.key, this.initialPage = 0});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final PageController _pageController;
  final _emailController = TextEditingController(text: 'panjabiparvindar77@gmail.com');
  final _passwordController = TextEditingController(text: 'Parvindar@123');
  bool _isLoading = false;
  int _currentPage = 0;

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

  Future<void> _performLogin([String? email, String? password]) async {
    if (_isLoading) return;

    final inputEmail = _emailController.text.trim().toLowerCase();
    final inputPassword = _passwordController.text;

    if (inputEmail.contains('reject') || inputPassword.contains('reject')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('તમારું એકાઉન્ટ સુપર એડમિન દ્વારા રદ (Reject) કરવામાં આવ્યું છે. તમે લોગિન કરી શકશો નહીં.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).login(
            email ?? _emailController.text.trim(),
            password ?? _passwordController.text,
          );

      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/main-poster');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/main-poster');
      }
    }
  }

  void _showCustomLoginDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Text(
          'Account Login (લોગિન)',
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
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _performLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showCategoryInfo(String title, String details, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF041126),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              details,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (title.contains('Matrimony')) {
                  _performLogin();
                } else if (title.contains('Services')) {
                  context.push('/samaj-services');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                title.contains('Matrimony') ? 'Explore Matrimony  >' : 'View Section  >',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 685 / 1000,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // 1. Poster Image Carousel (Page 0: Login Poster -> Page 1: Buddha Layout)
                          Positioned.fill(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (page) {
                                setState(() => _currentPage = page);
                              },
                              children: [
                                Image.asset(
                                  'assets/images/login_poster_2.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/1 (2).jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/buddha_home_poster.jpeg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/1 (1).jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Loading indicator overlay if processing login
                          if (_isLoading)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.6),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                                ),
                              ),
                            ),

                          if (_currentPage == 0) ...[
                            // Page 0 Hotspots
                            Positioned(
                              left: w * 0.02,
                              top: h * 0.56,
                              width: w * 0.18,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => context.push('/government-employees'),
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.21,
                              top: h * 0.56,
                              width: w * 0.18,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: _showCustomLoginDialog,
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.40,
                              top: h * 0.56,
                              width: w * 0.18,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () => _showCategoryInfo(
                                    'Private Job',
                                    'Business | Professional | Self Employed | Career Opportunities',
                                    Icons.business_center,
                                    const Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.60,
                              top: h * 0.56,
                              width: w * 0.18,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () => context.push('/samaj-services'),
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.79,
                              top: h * 0.56,
                              width: w * 0.18,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () => _showCategoryInfo(
                                    'Students (12+)',
                                    'Study Guidance | Career Support | Scholarship Info | Skill Development | Bright Future',
                                    Icons.school,
                                    const Color(0xFF3D1A6B),
                                  ),
                                ),
                              ),
                            ),
                            // Blue Login Button
                            Positioned(
                              left: w * 0.15,
                              top: h * 0.82,
                              width: w * 0.33,
                              height: h * 0.08,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: _showCustomLoginDialog,
                                ),
                              ),
                            ),
                            // Green Register Button
                            Positioned(
                              left: w * 0.52,
                              top: h * 0.82,
                              width: w * 0.33,
                              height: h * 0.08,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () => context.push('/register'),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Page 1 Hotspots (Buddha layout)
                            Positioned(
                              left: w * 0.02,
                              top: h * 0.49,
                              width: w * 0.22,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => context.push('/government-employees'),
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.26,
                              top: h * 0.49,
                              width: w * 0.22,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => context.push('/search'),
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.50,
                              top: h * 0.49,
                              width: w * 0.22,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => _showCategoryInfo(
                                    'Private Job (ખાનગી નોકરી અને વેપાર)',
                                    'Business | Professional | Self Employed | Career Opportunities',
                                    Icons.business_center,
                                    const Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: w * 0.74,
                              top: h * 0.49,
                              width: w * 0.22,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => context.push('/samaj-services'),
                                ),
                              ),
                            ),
                            // Gold Button 1: પાવન પ્રેરણાદાતા
                            Positioned(
                              left: w * 0.08,
                              top: h * 0.77,
                              width: w * 0.42,
                              height: h * 0.15,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => context.push('/pavan-prernadata'),
                                ),
                              ),
                            ),
                            // Gold Button 2: Samaj Super Stars
                            Positioned(
                              left: w * 0.50,
                              top: h * 0.77,
                              width: w * 0.42,
                              height: h * 0.15,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => context.push('/samaj-super-stars'),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
