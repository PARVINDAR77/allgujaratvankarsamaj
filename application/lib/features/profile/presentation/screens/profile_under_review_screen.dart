import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/network/api_client.dart';

class ProfileUnderReviewScreen extends ConsumerStatefulWidget {
  const ProfileUnderReviewScreen({super.key});

  @override
  ConsumerState<ProfileUnderReviewScreen> createState() =>
      _ProfileUnderReviewScreenState();
}

class _ProfileUnderReviewScreenState
    extends ConsumerState<ProfileUnderReviewScreen> {
  bool _isChecking = false;
  Map<String, dynamic>? _statusData;
  bool _isLoadingStatus = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _isLoadingStatus = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(apiClientProvider);
      final res = await dio.get('/verifications/my-status');
      if (mounted) {
        setState(() {
          _statusData = res.data as Map<String, dynamic>?;
          _isLoadingStatus = false;
        });

        // If backend already marked profile as verified, update auth and go home!
        if (_statusData?['isVerified'] == true) {
          await ref
              .read(authNotifierProvider.notifier)
              .checkVerificationStatus();
          if (mounted) {
            context.go('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isChecking = true);
    final isVerified =
        await ref.read(authNotifierProvider.notifier).checkVerificationStatus();

    await _fetchStatus();

    if (mounted) {
      setState(() => _isChecking = false);
      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'અભિનંદન! તમારી પ્રોફાઇલ મંજૂર થઈ ગઈ છે. (Profile Approved!)'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'તમારી પ્રોફાઇલ હજી ચકાસણી હેઠળ છે. કૃપા કરીને થોડીવાર પછી ફરી તપાસો.'),
            backgroundColor: Color(0xFFD4AF37),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestReq = _statusData?['latestRequest'] as Map<String, dynamic>?;
    final isRejected = latestReq?['status'] == 'REJECTED';
    final rejectionReason = latestReq?['rejectionReason'] as String?;
    final docType = latestReq?['documentType'] as String? ?? 'ઓળખ કાર્ડ (ID Proof)';
    final submittedAt = latestReq?['createdAt'] != null
        ? DateTime.tryParse(latestReq!['createdAt'].toString())
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF041026),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07182E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ચકાસણી સ્થિતિ (Verification)',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFD4AF37)),
            tooltip: 'લૉગઆઉટ (Sign Out)',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header Icon Badge ─────────────────────────────────────
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRejected
                      ? Colors.red.withValues(alpha: 0.15)
                      : const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  border: Border.all(
                    color: isRejected
                        ? Colors.red
                        : const Color(0xFFD4AF37),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isRejected
                          ? Colors.red.withValues(alpha: 0.2)
                          : const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isRejected
                        ? Icons.cancel_outlined
                        : Icons.hourglass_top_rounded,
                    size: 46,
                    color: isRejected
                        ? Colors.red
                        : const Color(0xFFD4AF37),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Main Title ─────────────────────────────────────────────
              Text(
                isRejected
                    ? 'દસ્તાવેજ અસ્વીકાર થયેલ છે\n(Verification Rejected)'
                    : 'પ્રોફાઇલ ચકાસણી હેઠળ છે\n(Under Admin Review)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isRejected ? Colors.redAccent : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),

              // ── Description ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF07182E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isRejected
                        ? Colors.red.withValues(alpha: 0.3)
                        : const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isRejected
                          ? 'એડમિન દ્વારા તમારા દસ્તાવેજનો અસ્વીકાર કરવામાં આવ્યો છે. કૃપા કરીને યોગ્ય દસ્તાવેજ ફરી અપલોડ કરો.'
                          : 'સમાજની સુરક્ષા અને યોગ્યતા માટે, એડમિન ટીમ તમારા અપલોડ કરેલ ઓળખ કાર્ડની ચકાસણી કરી રહી છે. સામાન્ય રીતે 1 થી 2 કલાકમાં મંજૂરી મળી જાય છે.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    if (isRejected && rejectionReason != null && rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'અસ્વીકારનું કારણ: $rejectionReason',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'સૂચના: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Request Details Card ──────────────────────────────────
              if (!_isLoadingStatus && latestReq != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1F3A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'સબમિશન વિગતો (Submission Info):',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _detailRow(Icons.description_outlined, 'દસ્તાવેજનો પ્રકાર', docType),
                      const SizedBox(height: 8),
                      _detailRow(
                        Icons.check_circle_outline,
                        'સ્થિતિ',
                        isRejected ? 'REJECTED (અસ્વીકાર)' : 'PENDING (ચકાસણી હેઠળ)',
                        valueColor: isRejected ? Colors.redAccent : const Color(0xFFD4AF37),
                      ),
                      if (submittedAt != null) ...[
                        const SizedBox(height: 8),
                        _detailRow(
                          Icons.calendar_today_outlined,
                          'તારીખ',
                          '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Action Buttons ────────────────────────────────────────
              // Button 1: Check Status
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _handleRefresh,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, color: Colors.black),
                  label: Text(
                    _isChecking
                        ? 'તપાસી રહ્યું છે... (Checking...)'
                        : 'ચકાસણી સ્થિતિ તપાસો (Refresh Status)',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Button 2: Re-upload or Update Document
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.go('/verified-profile');
                  },
                  icon: const Icon(Icons.upload_file_rounded, color: Color(0xFFD4AF37)),
                  label: Text(
                    isRejected
                        ? 'ફરીથી દસ્તાવેજ અપલોડ કરો (Re-upload Document)'
                        : 'દસ્તાવેજ બદલો / ફરી અપલોડ કરો (Update Document)',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Button 3: Need Help / Contact
              TextButton.icon(
                onPressed: () {
                  context.push('/privacy-contact');
                },
                icon: const Icon(Icons.support_agent_rounded, color: Colors.white60, size: 18),
                label: const Text(
                  'સહાયતા માટે એડમિનનો સંપર્ક કરો (Need Help?)',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),

              // Button 4: Sign Out
              TextButton(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                },
                child: const Text(
                  'લૉગઆઉટ (Sign Out)',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
