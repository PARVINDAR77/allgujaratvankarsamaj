import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'panjabiparvindar77@gmail.com');
  final _passwordController = TextEditingController(text: 'Parvindar@123');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin([String? email, String? password]) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final useEmail = email ?? _emailController.text.trim();
    final usePassword = password ?? _passwordController.text;

    final success = await ref.read(authNotifierProvider.notifier).login(
          useEmail,
          usePassword,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/home');
      } else {
        final authState = ref.read(authNotifierProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
                          // 1. Poster Image
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/buddha_welcome_poster.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/images/buddha_pargana_poster.jpg',
                                fit: BoxFit.cover,
                              ),
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

                          // 2. Circle 1: Government Employees (Red)
                          Positioned(
                            left: w * 0.02,
                            top: h * 0.56,
                            width: w * 0.18,
                            height: h * 0.16,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(40),
                                onTap: () => _showCategoryInfo(
                                  'Government Employees',
                                  'IAS | IPS | IFS | Officer | Teacher | Police | Army | Defence | Health | Other Govt Jobs',
                                  Icons.account_balance,
                                  const Color(0xFF7B1F2E),
                                ),
                              ),
                            ),
                          ),

                          // 3. Circle 2: Matrimony (Maroon) -> Performs Direct Login & Entry
                          Positioned(
                            left: w * 0.21,
                            top: h * 0.56,
                            width: w * 0.18,
                            height: h * 0.16,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(40),
                                onTap: () => _performLogin(),
                              ),
                            ),
                          ),

                          // 4. Circle 3: Private Job (Blue)
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
                                  const Color(0xFF0D3B6E),
                                ),
                              ),
                            ),
                          ),

                          // 5. Circle 4: VANKAR SAMAJ Services (Green) -> Goes to /samaj-services
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

                          // 6. Circle 5: Students 12+ (Purple)
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

                          // 7. Blue Button on Image: [👤 Login >]
                          Positioned(
                            left: w * 0.15,
                            top: h * 0.82,
                            width: w * 0.33,
                            height: h * 0.08,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () => _performLogin(),
                                onLongPress: _showCustomLoginDialog,
                              ),
                            ),
                          ),

                          // 8. Green Button on Image: [👤+ Registration >]
                          Positioned(
                            left: w * 0.52,
                            top: h * 0.82,
                            width: w * 0.33,
                            height: h * 0.08,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () => context.go('/register'),
                              ),
                            ),
                          ),
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
