import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../home/presentation/providers/views_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const LoginScreen({super.key, this.initialPage = 0});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final PageController _pageController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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

    final inputEmail = (email ?? _emailController.text).trim().toLowerCase();
    final inputPassword = (password ?? _passwordController.text);

    if (inputEmail.isEmpty || inputPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('કૃપા કરીને તમારો ઈમેલ અને પાસવર્ડ દાખલ કરો (Please enter your email and password)'),
          backgroundColor: Colors.orangeAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

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
      final success = await ref.read(authNotifierProvider.notifier).login(
            inputEmail,
            inputPassword,
          );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          final currentUser = ref.read(authNotifierProvider).user;
          if (currentUser != null && !currentUser.hasProfile) {
            context.go('/profile/create');
          } else if (currentUser != null && !currentUser.isVerified) {
            context.go('/profile-under-review');
          } else {
            context.go('/main-poster');
          }
        } else {
          final errorMsg = ref.read(authNotifierProvider).errorMessage ?? 'લોગિન નિષ્ફળ';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('અણધારી ભૂલ: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showCustomLoginDialog() {
    _emailController.clear();
    _passwordController.clear();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF041126),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_person_outlined, color: Color(0xFFD4AF37), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Account Login (લોગિન)',
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'તમારું ઈમેલ અને પાસવર્ડ દાખલ કરો:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFD4AF37), size: 20),
                  labelText: 'Email Address (ઈમેલ)',
                  hintText: 'example@gmail.com',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: obscurePassword,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white60,
                      size: 20,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  labelText: 'Password (પાસવર્ડ)',
                  hintText: '••••••••',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel (રદ કરો)', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                final emailText = _emailController.text.trim();
                final passText = _passwordController.text;

                if (emailText.isEmpty || passText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('કૃપા કરીને ઈમેલ અને પાસવર્ડ દાખલ કરો (Please enter email & password)'),
                      backgroundColor: Colors.orangeAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogCtx);
                _performLogin(emailText, passText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Login (લોગિન)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.paddingOf(context);
    final availableHeight = size.height - padding.top - padding.bottom;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: isMobile ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            child: Container(
              width: isMobile ? size.width : 500,
              height: isMobile ? availableHeight : (500 * (1000 / 685)),
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
                border: isMobile ? null : Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: isMobile
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(14),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // 1. Poster Image Carousel (Page 0: Login Poster -> Page 1: Buddha Layout)
                          Positioned.fill(
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: _pageController,
                              onPageChanged: (page) {
                                setState(() => _currentPage = page);
                              },
                              children: [
                                Image.asset(
                                  'assets/images/login_poster_2.jpg',
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/1 (2).jpeg',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/buddha_home_poster.jpeg',
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/1 (1).jpeg',
                                    fit: BoxFit.fill,
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
                            // --- Row 1: 5 Circular Icons ---
                            // 1. Govt Employees
                            Positioned(
                              left: w * 0.00,
                              top: h * 0.47,
                              width: w * 0.20,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => context.push('/government-employees'),
                                ),
                              ),
                            ),
                            // 2. Matrimony
                            Positioned(
                              left: w * 0.20,
                              top: h * 0.47,
                              width: w * 0.20,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => context.push('/search'),
                                ),
                              ),
                            ),
                            // 3. Private Job
                            Positioned(
                              left: w * 0.40,
                              top: h * 0.47,
                              width: w * 0.20,
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
                            // 4. Samaj Services
                            Positioned(
                              left: w * 0.60,
                              top: h * 0.47,
                              width: w * 0.20,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () => context.push('/samaj-services'),
                                ),
                              ),
                            ),
                            // 5. Samaj Ratna
                            Positioned(
                              left: w * 0.80,
                              top: h * 0.47,
                              width: w * 0.20,
                              height: h * 0.16,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    context.push('/samaj-ratna');
                                  },
                                ),
                              ),
                            ),

                            // --- Row 2: 3 Gold Buttons ---
                            // 1. Pavan Prernadata
                            Positioned(
                              left: w * 0.02,
                              top: h * 0.77,
                              width: w * 0.30,
                              height: h * 0.09,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => context.push('/pavan-prernadata'),
                                ),
                              ),
                            ),
                            // 2. Samaj Super Stars
                            Positioned(
                              left: w * 0.35,
                              top: h * 0.77,
                              width: w * 0.30,
                              height: h * 0.09,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => context.push('/samaj-super-stars'),
                                ),
                              ),
                            ),
                            // 3. Family Directory
                            Positioned(
                              left: w * 0.68,
                              top: h * 0.77,
                              width: w * 0.30,
                              height: h * 0.09,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => context.push('/family-details'),
                                ),
                              ),
                            ),

                            // --- Row 3: 5 Bottom Icons ---
                            // Education
                            Positioned(
                              left: w * 0.0,
                              top: h * 0.88,
                              width: w * 0.20,
                              height: h * 0.12,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref.read(incrementViewProvider)('HOME_EDUCATION');
                                          _showCategoryInfo('Education', 'For Better Tomorrow', Icons.menu_book, const Color(0xFF1565C0));
                                        },
                                      ),
                                    ),
                                  ),
                                  const Align(alignment: Alignment.bottomCenter, child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_EDUCATION'))),
                                ],
                              ),
                            ),
                            // Unity
                            Positioned(
                              left: w * 0.2,
                              top: h * 0.88,
                              width: w * 0.20,
                              height: h * 0.12,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref.read(incrementViewProvider)('HOME_UNITY');
                                          _showCategoryInfo('Unity', 'In Diversity', Icons.groups, const Color(0xFFD84315));
                                        },
                                      ),
                                    ),
                                  ),
                                  const Align(alignment: Alignment.bottomCenter, child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_UNITY'))),
                                ],
                              ),
                            ),
                            // Progress
                            Positioned(
                              left: w * 0.4,
                              top: h * 0.88,
                              width: w * 0.20,
                              height: h * 0.12,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref.read(incrementViewProvider)('HOME_PROGRESS');
                                          _showCategoryInfo('Progress', 'Through Support', Icons.trending_up, const Color(0xFF2E7D32));
                                        },
                                      ),
                                    ),
                                  ),
                                  const Align(alignment: Alignment.bottomCenter, child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_PROGRESS'))),
                                ],
                              ),
                            ),
                            // Service
                            Positioned(
                              left: w * 0.6,
                              top: h * 0.88,
                              width: w * 0.20,
                              height: h * 0.12,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref.read(incrementViewProvider)('HOME_SERVICE');
                                          _showCategoryInfo('Service', 'To Society', Icons.volunteer_activism, const Color(0xFFC62828));
                                        },
                                      ),
                                    ),
                                  ),
                                  const Align(alignment: Alignment.bottomCenter, child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_SERVICE'))),
                                ],
                              ),
                            ),
                            // Strong Roots
                            Positioned(
                              left: w * 0.8,
                              top: h * 0.88,
                              width: w * 0.20,
                              height: h * 0.12,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref.read(incrementViewProvider)('HOME_STRONG_ROOTS');
                                          _showCategoryInfo('Strong Roots', 'Bright Future', Icons.nature, const Color(0xFF1565C0));
                                        },
                                      ),
                                    ),
                                  ),
                                  const Align(alignment: Alignment.bottomCenter, child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_STRONG_ROOTS'))),
                                ],
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
      );
  }
}
