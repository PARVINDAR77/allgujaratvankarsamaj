import 'package:flutter/foundation.dart' show kIsWeb;
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
  bool _obscureDesktopPassword = true;
  bool _rememberMe = true;

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
          content: Text('કૃપા કરીને તમારો મોબાઈલ / ઈમેલ અને પાસવર્ડ દાખલ કરો (Please enter your mobile or email and password)'),
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
              const SizedBox(height: 8),
              Align(
                alignment: const Alignment(0.35, 0.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    _showForgotPasswordDialog();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot Password? (પાસવર્ડ ભૂલી ગયા છો?)',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
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

  void _showForgotPasswordDialog() {
    final identifierCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    int step = 1;
    bool isSubmitting = false;
    String statusInfo = '';
    String maskedTarget = '';
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (resetCtx) => StatefulBuilder(
        builder: (context, setResetState) => AlertDialog(
          backgroundColor: const Color(0xFF041126),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.lock_reset, color: Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step == 1
                      ? 'Forgot Password (પાસવર્ડ રીસેટ)'
                      : 'Set New Password (નવો પાસવર્ડ)',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step == 1) ...[
                  const Text(
                    'તમારો રજિસ્ટર્ડ ઈમેલ અથવા 10 અંકનો મોબાઈલ નંબર દાખલ કરો:\n(Enter your registered Email or Mobile number)',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: identifierCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_search_outlined, color: Color(0xFFD4AF37), size: 20),
                      labelText: 'Email or Mobile (ઈમેલ અથવા મોબાઈલ)',
                      hintText: 'user@email.com / 9876543210',
                      labelStyle: TextStyle(color: Colors.white70, fontSize: 13),
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                      ),
                    ),
                  ),
                  if (statusInfo.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      statusInfo,
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                    ),
                  ],
                ] else ...[
                  Text(
                    'ચકાસણી કોડ $maskedTarget પર મોકલવામાં આવ્યો છે:\n(Enter 6-digit OTP code & new password)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.pin, color: Color(0xFFD4AF37), size: 20),
                      labelText: 'Verification Code (OTP કોડ)',
                      labelStyle: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 0),
                      hintText: '123456',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 13, letterSpacing: 3),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white60,
                          size: 18,
                        ),
                        onPressed: () => setResetState(() => obscureNew = !obscureNew),
                      ),
                      labelText: 'New Password (નવો પાસવર્ડ)',
                      hintText: 'ન્યૂનતમ 6 અક્ષરો (Min 6 chars)',
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureConfirm,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white60,
                          size: 18,
                        ),
                        onPressed: () => setResetState(() => obscureConfirm = !obscureConfirm),
                      ),
                      labelText: 'Confirm Password (ખાતરી કરો)',
                      hintText: 'ફરીથી પાસવર્ડ લખો',
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                      ),
                    ),
                  ),
                  if (statusInfo.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      statusInfo,
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (step == 2) {
                        setResetState(() {
                          step = 1;
                          statusInfo = '';
                        });
                      } else {
                        Navigator.pop(resetCtx);
                      }
                    },
              child: Text(
                step == 2 ? 'Back (પાછા)' : 'Cancel (રદ કરો)',
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (step == 1) {
                        final idText = identifierCtrl.text.trim();
                        if (idText.isEmpty) {
                          setResetState(() => statusInfo = 'કૃપા કરીને ઈમેલ અથવા ફોન નંબર દાખલ કરો');
                          return;
                        }
                        setResetState(() {
                          isSubmitting = true;
                          statusInfo = '';
                        });

                        final res = await ref.read(authNotifierProvider.notifier).requestPasswordReset(idText);
                        if (res['success'] == true) {
                          setResetState(() {
                            isSubmitting = false;
                            step = 2;
                            maskedTarget = res['maskedContact'] ?? idText;
                            if (res['code'] != null) {
                              otpCtrl.text = res['code'].toString();
                            }
                            statusInfo = '';
                          });
                        } else {
                          setResetState(() {
                            isSubmitting = false;
                            statusInfo = res['message'] ?? 'એકાઉન્ટ મળ્યું નથી';
                          });
                        }
                      } else {
                        final otp = otpCtrl.text.trim();
                        final newPass = newPassCtrl.text;
                        final confirmPass = confirmPassCtrl.text;

                        if (otp.length != 6) {
                          setResetState(() => statusInfo = 'કૃપા કરીને 6 અંકનો કોડ દાખલ કરો');
                          return;
                        }
                        if (newPass.length < 6) {
                          setResetState(() => statusInfo = 'પાસવર્ડ ઓછામાં ઓછો 6 અક્ષરનો હોવો જોઈએ');
                          return;
                        }
                        if (newPass != confirmPass) {
                          setResetState(() => statusInfo = 'બંને પાસવર્ડ સરખા હોવા જોઈએ');
                          return;
                        }

                        setResetState(() {
                          isSubmitting = true;
                          statusInfo = '';
                        });

                        final idText = identifierCtrl.text.trim();
                        final res = await ref.read(authNotifierProvider.notifier).resetPassword(
                              identifier: idText,
                              code: otp,
                              newPassword: newPass,
                            );

                        if (res['success'] == true) {
                          Navigator.pop(resetCtx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે! હવે લોગિન થઈ રહ્યું છે...'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            _performLogin(idText, newPass);
                          }
                        } else {
                          setResetState(() {
                            isSubmitting = false;
                            statusInfo = res['message'] ?? 'કોડ ખોટો છે અથવા સમય પૂરો થઈ ગયો છે';
                          });
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      step == 1 ? 'Get Code (કોડ મેળવો)' : 'Reset & Login (સેવ કરો)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                } else if (title.contains('Unity')) {
                  context.push('/advertisement?section=HOME_UNITY');
                } else if (title.contains('Service')) {
                  context.push('/birthdays');
                } else if (title.contains('Strong Roots')) {
                  context.push('/advertisement?section=HOME_STRONG_ROOTS');
                } else if (title.contains('Education')) {
                  context.push('/education');
                } else if (title.contains('Progress')) {
                  context.push('/statistics');
                } else if (title.contains('Private Job')) {
                  context.push('/private-employees');
                } else if (title.contains('Students')) {
                  context.push('/education');
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

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  Widget _buildLeftPromotionalPanel(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        'assets/images/buddha_login_poster.png',
        width: width,
        height: height,
        fit: BoxFit.fill,
        errorBuilder: (ctx, err, _) => Container(color: const Color(0xFFFAF6F0)),
      ),
    );
  }

  Widget _buildRightLoginPanel(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(44, 20, 40, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top-Right: Don't have an account? Register Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Color(0xFF74819B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/register'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFA4143D), width: 1.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFFA4143D),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 38),

                // Welcome Back Heading
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Color(0xFF101B36),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to your account to continue',
                  style: TextStyle(
                    color: Color(0xFF74819B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 28),

                // Mobile Number or Email Input Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_iphone, color: Color(0xFF74819B), size: 20),
                    hintText: 'Mobile Number or Email',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: Color(0xFFA4143D), width: 1.8),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Password Input Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureDesktopPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) _performLogin();
                  },
                  style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF74819B), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureDesktopPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF74819B),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureDesktopPassword = !_obscureDesktopPassword;
                        });
                      },
                    ),
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: Color(0xFFA4143D), width: 1.8),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Remember me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: const Color(0xFFA4143D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _rememberMe = val ?? true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFFA4143D),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Full-width Deep Maroon Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _performLogin(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4143D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0x88A4143D),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),

                const SizedBox(height: 20),

                // OR Divider
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: const Color(0xFFE5E7EB))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: const Color(0xFFE5E7EB))),
                  ],
                ),

                const SizedBox(height: 18),

                // Continue with Google Button
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ગૂગલ લોગિન આગામી અપડેટમાં ઉપલબ્ધ થશે (Google Login will be available soon)'),
                        backgroundColor: Color(0xFFA4143D),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: _buildGoogleIcon(),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),

                const SizedBox(height: 10),

                // Continue with Facebook Button
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ફેસબુક લોગિન આગામી અપડેટમાં ઉપલબ્ધ થશે (Facebook Login will be available soon)'),
                        backgroundColor: Color(0xFFA4143D),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
                  label: const Text(
                    'Continue with Facebook',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),

                const SizedBox(height: 26),

                // Terms & Privacy Legal Footer
                Column(
                  children: [
                    const Text(
                      'By continuing, you agree to our',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => context.push('/privacy-policy'),
                          child: const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Color(0xFFA4143D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('|', style: TextStyle(color: Color(0xFFD1D5DB))),
                        ),
                        InkWell(
                          onTap: () => context.push('/privacy-policy'),
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Color(0xFFA4143D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildBuddhaWebSplitLoginView(Size size, double availableHeight) {
    // Exact aspect ratio of the left poster in the reference image (601 / 678)
    const posterRatio = 601.0 / 678.0;
    final idealLeftWidth = availableHeight * posterRatio;
    final maxLeftWidth = size.width - 400.0;
    final leftWidth = idealLeftWidth > maxLeftWidth ? maxLeftWidth : idealLeftWidth;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Panel: Full-height Buddha & Heritage Poster (No White Gaps, No Clipping)
          _buildLeftPromotionalPanel(leftWidth, availableHeight),

          // Right Panel: Clean White Login Form
          Expanded(
            child: _buildRightLoginPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddhaWebMobileLoginView(Size size, double availableHeight) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Top Compact Buddha Banner
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.asset(
                'assets/images/buddha_login_poster.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            // Login Card Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildRightLoginPanel(context),
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

    if (kIsWeb) {
      if (size.width >= 850) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildBuddhaWebSplitLoginView(size, availableHeight),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _buildBuddhaWebMobileLoginView(size, availableHeight),
          ),
        );
      }
    }

    return _buildMobileLoginView(size, availableHeight);
  }

  Widget _buildMobileLoginView(Size size, double availableHeight) {
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


class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = 2.8;
    final redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = 2.8;
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = 2.8;
    final greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = 2.8;
    final rect = Rect.fromCircle(center: center, radius: radius - 2);
    canvas.drawArc(rect, -2.4, 1.2, false, redPaint);
    canvas.drawArc(rect, -1.2, 1.2, false, yellowPaint);
    canvas.drawArc(rect, 0.0, 1.3, false, greenPaint);
    canvas.drawArc(rect, 1.3, 1.0, false, bluePaint);
    canvas.drawLine(Offset(center.dx - 1, center.dy), Offset(w - 2, center.dy), Paint()..color = const Color(0xFF4285F4)..strokeWidth = 2.8);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
