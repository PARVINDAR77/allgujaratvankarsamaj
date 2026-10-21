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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
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

  Widget _buildWebQuickChip(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0C2448),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x77FFD700), width: 1.2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFDF73),
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopWebLoginView(Size size, double availableHeight) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF041024),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.75),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  blurRadius: 24,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Left Column: Sacred Heritage & Poster Showcase (50%) ---
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF071936), Color(0xFF020914)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main Poster Graphic with Golden Border Frame
                            Container(
                              constraints: const BoxConstraints(maxHeight: 520),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.65), width: 1.6),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black87, blurRadius: 18, offset: Offset(0, 6)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/images/login_poster_2.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/1 (2).jpeg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Quick Section Pills under Poster
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildWebQuickChip('💍 મેટ્રિમોની', () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('મેટ્રિમોની સેવા માટે કૃપા કરીને બાજુના ફોર્મમાં લોગિન કરો (Please sign in to access Matrimony)'),
                                      backgroundColor: Color(0xFFD4AF37),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }),
                                _buildWebQuickChip('🏛️ સરકારી કર્મચારી', () => context.push('/government-employees')),
                                _buildWebQuickChip('⭐ સુપર સ્ટાર્સ', () => context.push('/samaj-super-stars')),
                                _buildWebQuickChip('🤝 સેવાઓ', () => context.push('/samaj-services')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Vertical Divider with Gold Gradient
                    Container(
                      width: 1.4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xFFFFD700), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // --- Right Column: Direct Web Login Card (50%) ---
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Monogram Icon Header
                                Center(
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFD4AF37), Color(0xFFAA820A)],
                                      ),
                                      border: Border.all(color: const Color(0xFFFFF2C2), width: 2),
                                      boxShadow: const [
                                        BoxShadow(color: Color(0x66FFD700), blurRadius: 18),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.lock_person, color: Colors.black, size: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                const Text(
                                  'સભ્ય લોગિન (Member Login)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFFDF73),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'All Gujarat Vankar Samaj • સત્તાવાર વેબ પોર્ટલ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Email Input Field
                                const Text(
                                  'ઈમેલ સરનામું (Email Address) *',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFFD700), size: 20),
                                    hintText: 'તમારો ઈમેલ દાખલ કરો (e.g. name@gmail.com)',
                                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFF030D1E),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.8),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Password Input Field
                                const Text(
                                  'પાસવર્ડ (Password) *',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscureDesktopPassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _performLogin(),
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFD700), size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureDesktopPassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.white60,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureDesktopPassword = !_obscureDesktopPassword;
                                        });
                                      },
                                    ),
                                    hintText: '••••••••',
                                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                                    filled: true,
                                    fillColor: const Color(0xFF030D1E),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.8),
                                    ),
                                  ),
                                ),

                                // Forgot Password Link
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _showForgotPasswordDialog,
                                    child: const Text(
                                      'પાસવર્ડ ભૂલી ગયા છો? (Forgot Password?)',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Submit Login Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : () => _performLogin(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: const Color(0x88D4AF37),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 6,
                                    shadowColor: const Color(0x66FFD700),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                                        )
                                      : const Text(
                                          'પ્રવેશ કરો (Sign In)',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 18),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Container(height: 1, color: Colors.white12)),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('અથવા (OR)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                                    ),
                                    Expanded(child: Container(height: 1, color: Colors.white12)),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // New Registration Button
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/register'),
                                  icon: const Icon(Icons.person_add_alt_1, color: Color(0xFFFFD700), size: 18),
                                  label: const Text(
                                    'નવી નોંધણી કરો (New Member Registration)',
                                    style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Admin Portal Shortcut
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () => context.push('/admin/login'),
                                    icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white54, size: 16),
                                    label: const Text(
                                      'કમિટી / એડમિન લોગિન (Admin Portal)',
                                      style: TextStyle(color: Colors.white60, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.paddingOf(context);
    final availableHeight = size.height - padding.top - padding.bottom;
    final isDesktop = size.width >= 850;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFF020B18),
        body: SafeArea(
          child: _buildDesktopWebLoginView(size, availableHeight),
        ),
      );
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
