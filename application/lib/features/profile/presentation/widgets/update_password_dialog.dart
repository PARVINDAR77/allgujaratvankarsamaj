import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';

/// High-end dialog for Changing Password across web & mobile with OTP verification.
/// First verifies user's registered Mobile Number or Email via 6-digit OTP,
/// then allows setting a new password securely without needing the old password.
void showUpdatePasswordDialog(BuildContext context, WidgetRef ref) {
  final user = ref.read(authNotifierProvider).user;
  final defaultPhone = user?.phone ?? '';
  final defaultEmail = user?.email ?? '';

  // Controllers
  final identifierController = TextEditingController(
    text: defaultPhone.isNotEmpty ? defaultPhone : defaultEmail,
  );
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State variables
  int step = 1; // 1: Send OTP, 2: Verify OTP, 3: Set New Password
  bool isSubmitting = false;
  bool isResending = false;
  String? errorMessage;
  String? successInfo;
  String maskedContact = '';
  String resetToken = '';
  String verifiedIdentifier = '';

  bool obscureNew = true;
  bool obscureConfirm = true;

  Timer? cooldownTimer;
  int resendCooldown = 0;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          void startCooldown([int seconds = 60]) {
            cooldownTimer?.cancel();
            resendCooldown = seconds;
            cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (resendCooldown <= 1) {
                t.cancel();
                setDialogState(() {
                  resendCooldown = 0;
                });
              } else {
                setDialogState(() {
                  resendCooldown--;
                });
              }
            });
          }

          void disposeDialog() {
            cooldownTimer?.cancel();
            identifierController.dispose();
            otpController.dispose();
            newPasswordController.dispose();
            confirmPasswordController.dispose();
          }

          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFD4AF37),
                secondary: Color(0xFFD4AF37),
              ),
            ),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFB45309), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Change Password\n(પાસવર્ડ બદલો)',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Indicator Pills
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStepPill(1, 'સંપર્ક ચકાસો', 'Verify', step >= 1, step == 1),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
                            _buildStepPill(2, 'ઓટીપી', 'OTP', step >= 2, step == 2),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
                            _buildStepPill(3, 'નવો પાસવર્ડ', 'New Password', step >= 3, step == 3),
                          ],
                        ),
                      ),

                      // Error message banner
                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Success message banner
                      if (successInfo != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  successInfo!,
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ==================== STEP 1: Verify Mobile or Email ====================
                      if (step == 1) ...[
                        const Text(
                          'તમારો નોંધાયેલ મોબાઈલ નંબર અથવા ઈમેઈલ સરનામું દાખલ કરો:\n(Enter your registered Mobile Number or Email address)',
                          style: TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.35),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Mobile Number / Email (મોબાઈલ અથવા ઈમેઈલ) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: identifierController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: '10-અંકનો મોબાઈલ અથવા ઈમેઈલ',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.contact_phone_outlined, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                          ),
                        ),
                        if (defaultPhone.isNotEmpty && defaultEmail.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              ActionChip(
                                label: Text(defaultPhone, style: const TextStyle(fontSize: 12)),
                                avatar: const Icon(Icons.phone_android, size: 14),
                                backgroundColor: const Color(0xFFFEF3C7),
                                onPressed: () {
                                  setDialogState(() {
                                    identifierController.text = defaultPhone;
                                  });
                                },
                              ),
                              ActionChip(
                                label: Text(defaultEmail, style: const TextStyle(fontSize: 12)),
                                avatar: const Icon(Icons.email, size: 14),
                                backgroundColor: const Color(0xFFFEF3C7),
                                onPressed: () {
                                  setDialogState(() {
                                    identifierController.text = defaultEmail;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ],

                      // ==================== STEP 2: 6-Digit OTP ====================
                      if (step == 2) ...[
                        Text(
                          'સુરક્ષા ચકાસણી માટે $maskedContact પર 6-અંકનો OTP મોકલવામાં આવ્યો છે:\n(Enter 6-digit OTP code sent to $maskedContact)',
                          style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.35),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Enter 6-Digit OTP (૬-અંકનો ઓટીપી) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            letterSpacing: 6,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: '123456',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 18,
                              letterSpacing: 6,
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: const Icon(Icons.password_rounded, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: (resendCooldown > 0 || isResending)
                                  ? null
                                  : () async {
                                      setDialogState(() {
                                        isResending = true;
                                        errorMessage = null;
                                        successInfo = null;
                                      });
                                      final res = await ref.read(authNotifierProvider.notifier).requestPasswordReset(verifiedIdentifier);
                                      setDialogState(() {
                                        isResending = false;
                                        if (res['success'] == true) {
                                          successInfo = 'નવો ઓટીપી કોડ મોકલવામાં આવ્યો છે';
                                          startCooldown(res['resendCooldownSeconds'] ?? 60);
                                        } else {
                                          errorMessage = res['message'] ?? 'ઓટીપી મોકલવામાં નિષ્ફળ';
                                        }
                                      });
                                    },
                              icon: isResending
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB45309)),
                                    )
                                  : const Icon(Icons.refresh, size: 16, color: Color(0xFFB45309)),
                              label: Text(
                                resendCooldown > 0
                                    ? 'Resend OTP in ${resendCooldown}s'
                                    : 'Resend OTP (ફરી ઓટીપી મોકલો)',
                                style: TextStyle(
                                  color: resendCooldown > 0 ? Colors.grey : const Color(0xFFB45309),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  step = 1;
                                  errorMessage = null;
                                  successInfo = null;
                                  otpController.clear();
                                });
                              },
                              child: const Text('Change number/email', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ),
                          ],
                        ),
                      ],

                      // ==================== STEP 3: Set New Password ====================
                      if (step == 3) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '✓ સંપર્ક સફળતાપૂર્વક ચકાસાયેલ છે. હવે નવો પાસવર્ડ સેટ કરો.',
                                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'New Password (નવો પાસવર્ડ) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNew,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Minimum 6 characters',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.key_outlined, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNew ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Confirm New Password (નવો પાસવર્ડ ફરીથી લખો) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirm,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Re-enter new password',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.check_circle_outline, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          disposeDialog();
                          Navigator.of(dialogContext).pop();
                        },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Cancel (રદ કરો)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                ),

                // Dynamic Action Button based on Step
                if (step == 1)
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final target = identifierController.text.trim();
                            if (target.isEmpty) {
                              setDialogState(() => errorMessage = 'કૃપા કરીને મોબાઈલ નંબર અથવા ઈમેઈલ દાખલ કરો');
                              return;
                            }

                            setDialogState(() {
                              isSubmitting = true;
                              errorMessage = null;
                              successInfo = null;
                            });

                            final res = await ref.read(authNotifierProvider.notifier).requestPasswordReset(target);

                            setDialogState(() {
                              isSubmitting = false;
                              if (res['success'] == true) {
                                step = 2;
                                verifiedIdentifier = target;
                                maskedContact = res['maskedContact'] ?? target;
                                successInfo = res['message'] ?? 'ઓટીપી કોડ સફળતાપૂર્વક મોકલવામાં આવ્યો છે';
                                startCooldown(res['resendCooldownSeconds'] ?? 60);
                              } else {
                                errorMessage = res['message'] ?? 'ઓટીપી મોકલવામાં નિષ્ફળતા';
                              }
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                          )
                        : const Text('Send OTP (ઓટીપી મોકલો)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  ),

                if (step == 2)
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final code = otpController.text.trim();
                            if (code.length != 6) {
                              setDialogState(() => errorMessage = 'કૃપા કરીને 6-અંકનો ઓટીપી કોડ દાખલ કરો');
                              return;
                            }

                            setDialogState(() {
                              isSubmitting = true;
                              errorMessage = null;
                              successInfo = null;
                            });

                            final res = await ref.read(authNotifierProvider.notifier).verifyResetCode(
                                  identifier: verifiedIdentifier,
                                  code: code,
                                );

                            setDialogState(() {
                              isSubmitting = false;
                              if (res['success'] == true) {
                                step = 3;
                                resetToken = res['resetToken'] ?? code;
                                successInfo = 'ઓટીપી ચકાસણી સફળ થઈ';
                              } else {
                                errorMessage = res['message'] ?? 'અમાન્ય અથવા સમાપ્ત થયેલ ઓટીપી કોડ';
                              }
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                          )
                        : const Text('Verify OTP (ચકાસો)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  ),

                if (step == 3)
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final nP = newPasswordController.text.trim();
                            final cP = confirmPasswordController.text.trim();

                            if (nP.length < 6) {
                              setDialogState(() => errorMessage = 'નવો પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ');
                              return;
                            }
                            if (nP != cP) {
                              setDialogState(() => errorMessage = 'નવો પાસવર્ડ અને કન્ફર્મ પાસવર્ડ સરખા નથી');
                              return;
                            }

                            setDialogState(() {
                              isSubmitting = true;
                              errorMessage = null;
                              successInfo = null;
                            });

                            final res = await ref.read(authNotifierProvider.notifier).resetPassword(
                                  identifier: verifiedIdentifier,
                                  code: resetToken.isNotEmpty ? resetToken : otpController.text.trim(),
                                  newPassword: nP,
                                );

                            if (res['success'] == true) {
                              disposeDialog();
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે! (Password changed successfully!)'),
                                    backgroundColor: Colors.green.shade700,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            } else {
                              setDialogState(() {
                                isSubmitting = false;
                                errorMessage = res['message'] ?? 'પાસવર્ડ બદલવામાં નિષ્ફળ';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                          )
                        : const Text('Save (સેવ કરો)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildStepPill(int num, String guj, String eng, bool isDoneOrActive, bool isActive) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFD4AF37)
              : (isDoneOrActive ? Colors.green.shade600 : Colors.grey.shade300),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$num',
          style: TextStyle(
            color: (isActive || isDoneOrActive) ? Colors.white : Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        guj,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.black87 : Colors.black54,
        ),
      ),
    ],
  );
}
