import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum SuperAdminStatus { underReview, approved, rejected }

class ProfileUnderReviewScreen extends StatefulWidget {
  const ProfileUnderReviewScreen({super.key});

  @override
  State<ProfileUnderReviewScreen> createState() => _ProfileUnderReviewScreenState();
}

class _ProfileUnderReviewScreenState extends State<ProfileUnderReviewScreen> {
  SuperAdminStatus _adminStatus = SuperAdminStatus.underReview;
  late final String _generatedUserId;
  late final String _generatedPassword;

  @override
  void initState() {
    super.initState();
    final randomNum = 1000 + Random().nextInt(9000);
    _generatedUserId = 'VSM-2026-$randomNum';
    _generatedPassword = 'vankar@${Random().nextInt(900) + 100}';
  }

  void _showCredentialsReceiptDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF07182E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.badge_rounded, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'તમારું યુનિક એકાઉન્ટ ID & પાસવર્ડ',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ફોર્મ ફી સફળતાપૂર્વક ચૂકવાઈ ગઈ છે! તમારી પાસે આ યુનિક લોગિન આઈડી અને પાસવર્ડ છે:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2246),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Unique User ID:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(_generatedUserId, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Password:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(_generatedPassword, style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'નોંધ: તમે ભવિષ્યમાં લોગિન વિભાગમાં આ યુનિક આઈડી અને પાસવર્ડથી કોઈપણ સમયે લોગિન કરી શકશો.',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('કન્ફર્મ & સેવ કરો', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleAutoLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1F0505),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: Colors.redAccent, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'એકાઉન્ટ રદ / રિજેક્ટ કરવામાં આવ્યું છે',
                style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'સુપર એડમિન દ્વારા તમારી પ્રોફાઇલ ચકાસણી દરમિયાન રદ (Reject) કરવામાં આવી છે.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 10),
            Text(
              'તમે આપમેળે લોગ આઉટ થાઓ છો અને આ એકાઉન્ટથી ભવિષ્યમાં ક્યારેય લોગિન કરી શકશો નહીં.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('ઓકે (Auto Logout)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07182E),
        title: const Text(
          'પ્રોફાઇલ ચકાસણી & ફી સ્ટેટસ',
          style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Status Header Icon
              Icon(
                _adminStatus == SuperAdminStatus.approved
                    ? Icons.verified_user_rounded
                    : (_adminStatus == SuperAdminStatus.rejected ? Icons.cancel_rounded : Icons.hourglass_top_rounded),
                size: 80,
                color: _adminStatus == SuperAdminStatus.approved
                    ? Colors.green
                    : (_adminStatus == SuperAdminStatus.rejected ? Colors.redAccent : const Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 14),

              // Status Title
              Text(
                _adminStatus == SuperAdminStatus.approved
                    ? 'તમારી પ્રોફાઈલ સુપર એડમિન દ્વારા મંજૂર (Approved) થઈ ગઈ છે!'
                    : (_adminStatus == SuperAdminStatus.rejected
                        ? 'તમારી પ્રોફાઇલ સુપર એડમિન દ્વારા રદ (Rejected) કરવામાં આવી છે'
                        : 'તમારી પ્રોફાઇલ ચકાસણી હેઠળ છે (Profile Under Review)'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _adminStatus == SuperAdminStatus.approved
                      ? Colors.green
                      : (_adminStatus == SuperAdminStatus.rejected ? Colors.redAccent : const Color(0xFFD4AF37)),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Description Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF07182E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _adminStatus == SuperAdminStatus.approved
                        ? Colors.green
                        : (_adminStatus == SuperAdminStatus.rejected ? Colors.redAccent : const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                  ),
                ),
                child: Text(
                  _adminStatus == SuperAdminStatus.approved
                      ? 'તમારું એકાઉન્ટ સંપૂર્ણ રીતે અનલોક થઈ ગયું છે. તમે કોઈપણ સમયે તમારા યુનિક આઈડી અને પાસવર્ડ વડે લોગિન કરી શકો છો.'
                      : (_adminStatus == SuperAdminStatus.rejected
                          ? 'સુપર એડમિન દ્વારા તમારું એકાઉન્ટ રદ કરવામાં આવ્યું છે. તમે એપ્લિકેશનનો ઉપયોગ કરી શકશો નહીં અને આપમેળે લોગઆઉટ થશો.'
                          : 'તમારી પ્રોફાઈલ અને ફોર્મ ફી (₹ 500) સુપર એડમિન દ્વારા ચકાસણી હેઠળ છે. એડમિન દ્વારા મંજૂરી મળ્યા બાદ એપ્લિકેશન અનલોક થશે.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ),

              const SizedBox(height: 20),

              // Unique Credentials Card
              Card(
                color: const Color(0xFF0A2246),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Unique User ID:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(_generatedUserId, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Form Registration Fee:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const Text('₹ 500.00 (Submitted)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _showCredentialsReceiptDialog,
                        icon: const Icon(Icons.vpn_key_rounded, color: Colors.black, size: 18),
                        label: const Text('View User ID & Password / આઈડી-પાસવર્ડ જુઓ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          minimumSize: const Size(double.infinity, 42),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Super Admin Status Selector Simulation
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purpleAccent, width: 1),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.purpleAccent),
                        SizedBox(width: 8),
                        Text(
                          'Super Admin Decision Control (Demo)',
                          style: TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<SuperAdminStatus>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: const Color(0xFFD4AF37),
                        selectedForegroundColor: Colors.black,
                      ),
                      segments: const [
                        ButtonSegment(value: SuperAdminStatus.underReview, label: Text('Review', style: TextStyle(fontSize: 11))),
                        ButtonSegment(value: SuperAdminStatus.approved, label: Text('Approve', style: TextStyle(fontSize: 11))),
                        ButtonSegment(value: SuperAdminStatus.rejected, label: Text('Reject', style: TextStyle(fontSize: 11))),
                      ],
                      selected: {_adminStatus},
                      onSelectionChanged: (Set<SuperAdminStatus> newSelection) {
                        setState(() {
                          _adminStatus = newSelection.first;
                        });
                        if (_adminStatus == SuperAdminStatus.rejected) {
                          _handleAutoLogout();
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Final Action Button
              ElevatedButton.icon(
                onPressed: () {
                  if (_adminStatus == SuperAdminStatus.approved) {
                    context.go('/home');
                  } else if (_adminStatus == SuperAdminStatus.rejected) {
                    _handleAutoLogout();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('તમારી પ્રોફાઇલ ચકાસણી હેઠળ છે. સુપર એડમિન એપ્રુવલ બાદ અનલોક થશે.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: Icon(
                  _adminStatus == SuperAdminStatus.approved ? Icons.check_circle : Icons.lock,
                  color: Colors.black,
                ),
                label: Text(
                  _adminStatus == SuperAdminStatus.approved
                      ? 'ઓપન એપ્લિકેશન (Go to App)'
                      : (_adminStatus == SuperAdminStatus.rejected ? 'Account Rejected (Blocked)' : 'પ્રોફાઇલ ચકાસણી હેઠળ છે (Locked)'),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _adminStatus == SuperAdminStatus.approved
                      ? Colors.green
                      : (_adminStatus == SuperAdminStatus.rejected ? Colors.redAccent : const Color(0xFFD4AF37)),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
