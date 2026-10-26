import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _fullNameController.text.trim();
    final phone = _mobileController.text.trim();
    final email = _emailController.text.trim();

    final res = await ref.read(authNotifierProvider.notifier).sendRegistrationOtp(
          name: name,
          phone: phone,
          email: email,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        _showDualVerificationDialog(res);
      } else {
        final errorMsg = res['message'] ?? 'ચકાસણી કોડ મોકલવામાં નિષ્ફળતા';
        final isLocked = res['isLocked'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLocked
                  ? '⚠️ સુરક્ષા લૉકઆઉટ: વધુ પડતા પ્રયાસોને લીધે એકાઉન્ટ 10 મિનિટ માટે લૉક છે. થોડા સમય પછી ફરી પ્રયાસ કરો.'
                  : errorMsg,
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showDualVerificationDialog(Map<String, dynamic> initialData) {
    final phoneOtpCtrl = TextEditingController();
    final emailOtpCtrl = TextEditingController();
    final maskedPhone = initialData['maskedPhone'] ?? _mobileController.text.trim();
    final maskedEmail = initialData['maskedEmail'] ?? _emailController.text.trim();

    bool isVerifying = false;
    bool isResending = false;
    String statusMsg = '';
    bool isLocked = false;
    Timer? resendTimer;
    int cooldown = initialData['resendCooldownSeconds'] ?? 60;

    void cleanup() {
      resendTimer?.cancel();
      phoneOtpCtrl.dispose();
      emailOtpCtrl.dispose();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (_, setDialogState) {
          void startCooldownTimer([int seconds = 60]) {
            resendTimer?.cancel();
            cooldown = seconds;
            resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (cooldown <= 1) {
                t.cancel();
                setDialogState(() => cooldown = 0);
              } else {
                setDialogState(() => cooldown--);
              }
            });
          }

          if (resendTimer == null && cooldown > 0) {
            startCooldownTimer(cooldown);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF041126),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
            ),
            title: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFFD4AF37), size: 26),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ચકાસણી (Dual Verification)',
                    style: TextStyle(
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
                  const Text(
                    'નોંધણી પૂર્ણ કરવા માટે તમારા મોબાઇલ અને ઈમેલ બંને પર મોકલેલા 6-અંકના OTP દાખલ કરો:\n(Enter 6-digit OTP codes sent to your mobile & email)',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  // Phone OTP Field
                  TextField(
                    controller: phoneOtpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      prefixIcon: const Icon(Icons.sms_outlined, color: Color(0xFFD4AF37), size: 20),
                      labelText: 'Mobile SMS OTP ($maskedPhone) *',
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12.5, letterSpacing: 0),
                      hintText: '123456',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13, letterSpacing: 4),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Email OTP Field
                  TextField(
                    controller: emailOtpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      prefixIcon: const Icon(Icons.mark_email_read_outlined, color: Color(0xFFD4AF37), size: 20),
                      labelText: 'Email OTP ($maskedEmail) *',
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12.5, letterSpacing: 0),
                      hintText: '123456',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13, letterSpacing: 4),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Resend Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: (cooldown > 0 || isResending)
                            ? null
                            : () async {
                                setDialogState(() {
                                  isResending = true;
                                  statusMsg = '';
                                });
                                final res = await ref.read(authNotifierProvider.notifier).sendRegistrationOtp(
                                      name: _fullNameController.text.trim(),
                                      phone: _mobileController.text.trim(),
                                      email: _emailController.text.trim(),
                                    );
                                setDialogState(() {
                                  isResending = false;
                                  if (res['success'] == true) {
                                    statusMsg = 'નવા ચકાસણી કોડ સફળતાપૂર્વક મોકલવામાં આવ્યા છે.';
                                    startCooldownTimer(res['resendCooldownSeconds'] ?? 60);
                                  } else {
                                    isLocked = res['isLocked'] == true;
                                    statusMsg = res['message'] ?? 'કોડ ફરી મોકલવામાં નિષ્ફળતા';
                                  }
                                });
                              },
                        icon: isResending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)),
                              )
                            : const Icon(Icons.refresh, size: 16, color: Color(0xFFD4AF37)),
                        label: Text(
                          cooldown > 0
                              ? 'Resend in ${cooldown}s (ફરી ${cooldown}s)'
                              : 'Resend Codes (નવા કોડ મોકલો)',
                          style: TextStyle(
                            color: (cooldown > 0 || isResending) ? Colors.white38 : const Color(0xFFD4AF37),
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const Text(
                        'મહત્તમ 4 પ્રયાસો',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),

                  // Error / Status container
                  if (statusMsg.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.red.withOpacity(0.18) : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLocked ? Colors.redAccent : Colors.orangeAccent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isLocked ? Icons.lock_clock : Icons.info_outline,
                            color: isLocked ? Colors.redAccent : Colors.orangeAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusMsg,
                              style: TextStyle(
                                color: isLocked ? Colors.redAccent : Colors.orangeAccent,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isVerifying
                    ? null
                    : () {
                        cleanup();
                        Navigator.pop(dialogCtx);
                      },
                child: const Text('Cancel (રદ કરો)', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: (isVerifying || isLocked)
                    ? null
                    : () async {
                        final pOtp = phoneOtpCtrl.text.trim();
                        final eOtp = emailOtpCtrl.text.trim();

                        if (pOtp.length != 6 || eOtp.length != 6) {
                          setDialogState(() {
                            statusMsg = 'કૃપા કરીને બંને 6-અંકના OTP કોડ દાખલ કરો (Please enter both 6-digit OTP codes)';
                          });
                          return;
                        }

                        setDialogState(() {
                          isVerifying = true;
                          statusMsg = '';
                          isLocked = false;
                        });

                        final phone = _mobileController.text.trim();
                        final email = _emailController.text.trim();

                        final verifyRes = await ref.read(authNotifierProvider.notifier).verifyRegistrationOtp(
                              phone: phone,
                              email: email,
                              phoneOtp: pOtp,
                              emailOtp: eOtp,
                            );

                        if (verifyRes['success'] == true && verifyRes['registrationToken'] != null) {
                          final regToken = verifyRes['registrationToken'] as String;
                          cleanup();
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }

                          // Finalize account creation with registrationToken
                          setState(() => _isLoading = true);
                          final regSuccess = await ref.read(authNotifierProvider.notifier).register(
                                email,
                                _passwordController.text,
                                phone: phone,
                                name: _fullNameController.text.trim(),
                                registrationToken: regToken,
                              );

                          if (mounted) {
                            setState(() => _isLoading = false);
                            if (regSuccess) {
                              _showMandatoryProfileDialog();
                            } else {
                              final err = ref.read(authNotifierProvider).errorMessage ?? 'નોંધણી નિષ્ફળ થઈ';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(err),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } else {
                          setDialogState(() {
                            isVerifying = false;
                            isLocked = verifyRes['isLocked'] == true;
                            statusMsg = verifyRes['message'] ?? 'OTP ચકાસણી નિષ્ફળ થઈ';
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isVerifying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text(
                        'Verify & Register (ચકાસો)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMandatoryProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF07182E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.person_add_rounded, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'નોંધણી સફળ! પ્રોફાઇલ બનાવો',
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'તમારું એકાઉન્ટ સફળતાપૂર્વક બની ગયું છે!\n\nહવે તમારી વૈવાહિક પ્રોફાઇલ વિગતો (Biodata) ભરો જેથી સમાજના અન્ય સભ્યો તમારી યોગ્યતા જોઈ શકે. પ્રોફાઇલ સબમિટ કર્યા પછી એડમિન દ્વારા મંજૂર કરવામાં આવશે.',
              style:
                  TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 10),
            Text(
              'Account created successfully! Please proceed to fill your matrimonial candidate profile.',
              style:
                  TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.go('/profile/create');
              },
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black),
              label: const Text(
                'પ્રોફાઇલ બનાવો (Create Profile Now)',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFFD4AF37), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF0A1F3A),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF1E3A5F), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFD4AF37), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
      errorStyle:
          const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.paddingOf(context);
      final availableHeight = size.height - padding.top - padding.bottom;

      if (size.width >= 960) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildWebSplitRegisterView(size, availableHeight),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _buildWebMobileRegisterView(size, availableHeight),
          ),
        );
      }
    }

    return _buildMobileRegisterView(context);
  }

  Widget _buildMobileRegisterView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041126),
        elevation: 0,
        title: const Text(
          'New Registration (નવી નોંધણી)',
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFD4AF37).withOpacity(0.3),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A1F3A), Color(0xFF041126)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.6),
                                width: 1.2),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFFD4AF37),
                                      width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.how_to_reg_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'All Gujarat Vankar Samaj',
                                style: TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Matrimony Portal · નોંધણી',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Form Fields
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF041126),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border(
                              left: BorderSide(
                                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                                  width: 1.2),
                              right: BorderSide(
                                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                                  width: 1.2),
                              bottom: BorderSide(
                                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                                  width: 1.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _sectionLabel('વ્યક્તિગત માહિતી', 'Personal Info'),
                              const SizedBox(height: 10),

                              // Full Name
                              TextFormField(
                                controller: _fullNameController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: _inputDecoration(
                                  label: 'Full Name (પૂરું નામ) *',
                                  hint: 'Enter your full name',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  if (val.trim().length < 3) {
                                    return 'Name must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Mobile Number
                              TextFormField(
                                controller: _mobileController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: _inputDecoration(
                                  label: 'Mobile Number (મોબાઇલ નંબર - 10 અંક) *',
                                  hint: '10-digit mobile number',
                                  prefixIcon: Icons.phone_android_rounded,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'કૃપા કરીને મોબાઇલ નંબર દાખલ કરો (Please enter mobile number)';
                                  }
                                  if (val.trim().length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(val.trim())) {
                                    return 'માન્ય 10 અંકનો મોબાઇલ નંબર દાખલ કરો (6-9 થી શરૂ)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              _sectionLabel('એકાઉન્ટ માહિતી', 'Account Details'),
                              const SizedBox(height: 10),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                decoration: _inputDecoration(
                                  label: 'Email Address (ઈ-મેઇલ) *',
                                  hint: 'example@email.com',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'કૃપા કરીને ઈમેઈલ સરનામું દાખલ કરો (Please enter email address)';
                                  }
                                  final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                  if (!emailRegex.hasMatch(val.trim())) {
                                    return 'માન્ય ઈમેઈલ સરનામું દાખલ કરો (Enter a valid email address)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: _inputDecoration(
                                  label: 'Password (પાસવર્ડ) *',
                                  hint: 'At least 6 characters',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _passwordVisible = !_passwordVisible),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  if (val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_confirmPasswordVisible,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: _inputDecoration(
                                  label: 'Confirm Password (પાસવર્ડ ફરીથી) *',
                                  hint: 'Re-enter your password',
                                  prefixIcon: Icons.lock_reset_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (val != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Register Button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFD4AF37),
                                    disabledBackgroundColor:
                                        const Color(0xFFD4AF37)
                                            .withOpacity(0.5),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.how_to_reg_rounded,
                                                color: Colors.black, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Register (નોંધણી કરો)',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Already have account
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: const Text(
                                      'Login (લૉગિન)',
                                      style: TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String gujarati, String english) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$gujarati · $english',
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ==================== WEB THEMED REGISTRATION ====================

  InputDecoration _webInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Color(0xFF74819B), fontSize: 13.5),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(prefixIcon, color: const Color(0xFF74819B), size: 21),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD5DCE7), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFA4143D), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }

  Widget _webSectionLabel(String gujarati, String english) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFA4143D),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$gujarati · $english',
          style: const TextStyle(
            color: Color(0xFFA4143D),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildRightRegisterPanel(BuildContext context, {bool isScrollable = true}) {
    final formContent = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top-Right: Already have an account? Login Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Color(0xFF74819B),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFA4143D), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFFA4143D),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Heading
            const Text(
              'New Registration',
              style: TextStyle(
                color: Color(0xFF101B36),
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Join our Vankar Samaj matrimony community · નવી નોંધણી',
              style: TextStyle(
                color: Color(0xFF74819B),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: Personal Info
            _webSectionLabel('વ્યક્તિગત માહિતી', 'Personal Info'),
            const SizedBox(height: 12),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14.5),
              textCapitalization: TextCapitalization.words,
              decoration: _webInputDecoration(
                label: 'Full Name (પૂરું નામ) *',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (val.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // Mobile Number
            TextFormField(
              controller: _mobileController,
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14.5),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: _webInputDecoration(
                label: 'Mobile Number (મોબાઇલ નંબર - 10 અંક) *',
                hint: '10-digit mobile number',
                prefixIcon: Icons.phone_android_rounded,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'કૃપા કરીને મોબાઇલ નંબર દાખલ કરો (Please enter mobile number)';
                }
                if (val.trim().length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(val.trim())) {
                  return 'માન્ય 10 અંકનો મોબાઇલ નંબર દાખલ કરો (6-9 થી શરૂ)';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Section 2: Account Details
            _webSectionLabel('એકાઉન્ટ માહિતી', 'Account Details'),
            const SizedBox(height: 12),

            // Email Address
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14.5),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: _webInputDecoration(
                label: 'Email Address (ઈ-મેઇલ) *',
                hint: 'example@email.com',
                prefixIcon: Icons.email_outlined,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'કૃપા કરીને ઈમેઈલ સરનામું દાખલ કરો (Please enter email address)';
                }
                final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(val.trim())) {
                  return 'માન્ય ઈમેઈલ સરનામું દાખલ કરો (Enter a valid email address)';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14.5),
              decoration: _webInputDecoration(
                label: 'Password (પાસવર્ડ) *',
                hint: 'At least 6 characters',
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF74819B),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter password';
                }
                if (val.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_confirmPasswordVisible,
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14.5),
              decoration: _webInputDecoration(
                label: 'Confirm Password (પાસવર્ડ ફરીથી) *',
                hint: 'Re-enter your password',
                prefixIcon: Icons.lock_reset_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF74819B),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please confirm your password';
                }
                if (val != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 22),

            // Register Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA4143D),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0x99A4143D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          'Register (નોંધણી કરો)',
                          style: TextStyle(
                            fontSize: 15.5,
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
    );

    if (!isScrollable) {
      return Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            width: 140,
            height: 140,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/images/mandala_watermark_top.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                ),
              ),
            ),
          ),
          formContent,
        ],
      );
    }

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Top-right corner mandala watermark
          Positioned(
            top: 0,
            right: 0,
            width: 240,
            height: 240,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/images/mandala_watermark_top.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                ),
              ),
            ),
          ),
          // Bottom-right corner mandala watermark
          Positioned(
            bottom: 0,
            right: 0,
            width: 260,
            height: 260,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/images/mandala_watermark_bottom.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Centered Form Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                      child: formContent,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebSplitRegisterView(Size size, double availableHeight) {
    const double posterRatio = 975.0 / 865.0; // 1.12716763 exact image ratio

    // Ensure the right panel gets at least 480px of breathing room
    final double maxLeftWidth = size.width - 480.0;
    final double exactHeightWidth = availableHeight * posterRatio;

    final double leftWidth = exactHeightWidth > maxLeftWidth ? maxLeftWidth : exactHeightWidth;
    final double leftHeight = leftWidth / posterRatio;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Promotional Panel: Full sacred Buddha poster, zero cropping!
          Container(
            width: leftWidth,
            height: availableHeight,
            color: const Color(0xFFFAF8F5),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/buddha_sacred_login_poster.png',
              width: leftWidth,
              height: leftHeight,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, _) => Image.asset(
                'assets/images/heritage_login_poster.png',
                width: leftWidth,
                height: leftHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Right Registration Panel: Clean White, centered registration form with mandalas
          Expanded(
            child: _buildRightRegisterPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWebMobileRegisterView(Size size, double availableHeight) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Top Compact Heritage Banner
            AspectRatio(
              aspectRatio: 975.0 / 520.0,
              child: Image.asset(
                'assets/images/heritage_login_poster.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            // Registration Form Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: _buildRightRegisterPanel(context, isScrollable: false),
            ),
          ],
        ),
      ),
    );
  }
}
