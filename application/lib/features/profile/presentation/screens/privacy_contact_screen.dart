import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';

class PrivacyContactScreen extends StatefulWidget {
  const PrivacyContactScreen({super.key});

  @override
  State<PrivacyContactScreen> createState() => _PrivacyContactScreenState();
}

class _PrivacyContactScreenState extends State<PrivacyContactScreen> {
  String _mobilePrivacy = 'માત્ર મને';
  String _emailPrivacy = 'માત્ર મને';
  String _addressPrivacy = 'પરિવારજનો';
  String _guardianPrivacy = 'માત્ર મને';
  bool _shareInGroup = false;

  final List<String> _privacyOptions = ['માત્ર મને', 'પરિવારજનો', 'બધા સભ્યો', 'કોઈ નહીં'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Standard Vankar Header
            VankarHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.of(context).maybePop(),
              subtitle: '“એક સમાજ, એક વિચાર, એક પરિવાર”',
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    // Header: Privacy & Contact / નંબર અને સંપર્કની Privacy
                    const Text(
                      'Privacy & Contact',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 1, color: AppColors.secondary),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'નંબર અને સંપર્કની Privacy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(width: 24, height: 1, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Top Security Shield Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Padlock Shield Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.lock, color: Colors.black87, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'તમારી માહિતી, તમારી સુરક્ષા',
                                  style: TextStyle(
                                    color: AppColors.goldLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'તમારી સંપર્ક માહિતી (મોબાઈલ નંબર, ઈમેઈલ, સરનામું) તમારા માટે સુરક્ષિત છે. યોગ્ય લોકો સિવાય કોઈને દેખાશે નહીં.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section Title: માહિતી કોણ જોઈ શકે?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'માહિતી કોણ જોઈ શકે?',
                          style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.shield_outlined, color: AppColors.secondary, size: 16),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Card with 5 Privacy Controls
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          // 1. Mobile Number
                          _buildPrivacyRow(
                            icon: Icons.call,
                            title: 'મોબાઈલ નંબર',
                            subtitle: 'તમારો મોબાઈલ નંબર કોણ જોઈ શકે તે પસંદ કરો.',
                            value: _mobilePrivacy,
                            onChanged: (val) => setState(() => _mobilePrivacy = val!),
                          ),
                          const Divider(color: Colors.white12, height: 16),

                          // 2. Email Address
                          _buildPrivacyRow(
                            icon: Icons.email,
                            title: 'ઈમેઈલ સરનામું',
                            subtitle: 'તમારું ઈમેઈલ સરનામું કોણ જોઈ શકે તે પસંદ કરો.',
                            value: _emailPrivacy,
                            onChanged: (val) => setState(() => _emailPrivacy = val!),
                          ),
                          const Divider(color: Colors.white12, height: 16),

                          // 3. Home Address
                          _buildPrivacyRow(
                            icon: Icons.home,
                            title: 'ઘરનું સરનામું',
                            subtitle: 'તમારું સરનામું કોણ જોઈ શકે તે પસંદ કરો.',
                            value: _addressPrivacy,
                            onChanged: (val) => setState(() => _addressPrivacy = val!),
                          ),
                          const Divider(color: Colors.white12, height: 16),

                          // 4. Guardian Contact
                          _buildPrivacyRow(
                            icon: Icons.family_restroom,
                            title: 'વાલીનો સંપર્ક',
                            subtitle: 'તમારા સંપર્કની માહિતી અન્ય વાલીઓને દેખાડવી કે નહીં.',
                            value: _guardianPrivacy,
                            onChanged: (val) => setState(() => _guardianPrivacy = val!),
                          ),
                          const Divider(color: Colors.white12, height: 16),

                          // 5. Toggle Switch
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF031633),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                                ),
                                child: const Icon(Icons.share, color: AppColors.secondary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                     Text(
                                       'સમાજ ડાયરેક્ટરીમાં નંબર શેર કરો',
                                       style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                     ),
                                     SizedBox(height: 2),
                                     Text(
                                       'શું તમારો નંબર વણકર સમાજ ડાયરેક્ટરીમાં શેર કરવો છે?',
                                       style: TextStyle(color: Colors.white60, fontSize: 9),
                                     ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _shareInGroup ? 'ચાલુ' : 'બંધ',
                                    style: TextStyle(
                                      color: _shareInGroup ? Colors.greenAccent : Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Switch(
                                    value: _shareInGroup,
                                    activeThumbColor: AppColors.secondary,
                                    activeTrackColor: AppColors.goldDark,
                                    inactiveThumbColor: Colors.white54,
                                    inactiveTrackColor: Colors.white24,
                                    onChanged: (val) => setState(() => _shareInGroup = val),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section: મારી માહિતી કેવી રીતે દેખાશે? (Live preview)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.visibility, color: AppColors.secondary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'મારી માહિતી કેવી રીતે દેખાશે?',
                          style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _buildPreviewItem('મોબાઈલ નંબર', _mobilePrivacy),
                          const Divider(color: Colors.white12, height: 12),
                          _buildPreviewItem('ઈમેઈલ સરનામું', _emailPrivacy),
                          const Divider(color: Colors.white12, height: 12),
                          _buildPreviewItem('ઘરનું સરનામું', _addressPrivacy),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Notice Card: નોંધ
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF021329),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6), width: 1.2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified_user, color: Color(0xFF2EB85C), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'નોંધ',
                                  style: TextStyle(
                                    color: AppColors.goldLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'વણકર સમાજ મેટ્રિમોની અથવા અધિકૃત હોદ્દેદારો જ તમારા સંપર્કની માહિતી જોઈ શકે છે. તમારી પરવાનગી વગર તમારી માહિતી કોઈ સાથે શેર કરવામાં આવશે નહીં.',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF031633),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 9),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF031633),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF061633),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondary, size: 16),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              onChanged: onChanged,
              items: _privacyOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.secondary, size: 12),
                      const SizedBox(width: 4),
                      Text(opt, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewItem(String label, String privacy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Row(
          children: [
            const Icon(Icons.lock, color: AppColors.secondary, size: 12),
            const SizedBox(width: 4),
            Text(
              privacy,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
