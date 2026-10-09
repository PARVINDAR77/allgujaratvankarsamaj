import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';

class PrivacyContactScreen extends ConsumerStatefulWidget {
  const PrivacyContactScreen({super.key});

  @override
  ConsumerState<PrivacyContactScreen> createState() => _PrivacyContactScreenState();
}

class _PrivacyContactScreenState extends ConsumerState<PrivacyContactScreen> {
  // Privacy Options
  final List<String> _privacyOptions = ['માત્ર મને', 'પરિવારજનો', 'બધા માટે'];

  // State Variables
  String _mobilePrivacy = 'માત્ર મને';
  String _emailPrivacy = 'માત્ર મને';
  String _addressPrivacy = 'પરિવારજનો';
  String _guardianPrivacy = 'બધા માટે';
  bool _shareClassGroup = false;

  bool _isInitialized = false;
  bool _isSaving = false;

  void _syncFromProfile(ProfileModel profile) {
    if (_isInitialized) return;
    _mobilePrivacy = profile.effectiveMobilePrivacy;
    _emailPrivacy = profile.effectiveEmailPrivacy;
    _addressPrivacy = profile.effectiveAddressPrivacy;
    _guardianPrivacy = profile.effectiveGuardianPrivacy;
    _shareClassGroup = profile.shareClassGroup;
    _isInitialized = true;
  }

  Future<void> _updatePrivacySetting({
    String? mobile,
    String? email,
    String? address,
    String? guardian,
    bool? shareClass,
  }) async {
    setState(() {
      if (mobile != null) _mobilePrivacy = mobile;
      if (email != null) _emailPrivacy = email;
      if (address != null) _addressPrivacy = address;
      if (guardian != null) _guardianPrivacy = guardian;
      if (shareClass != null) _shareClassGroup = shareClass;
      _isSaving = true;
    });

    try {
      final privacyData = {
        'mobilePrivacy': _mobilePrivacy,
        'emailPrivacy': _emailPrivacy,
        'addressPrivacy': _addressPrivacy,
        'guardianPrivacy': _guardianPrivacy,
        'shareClassGroup': _shareClassGroup,
        'privacySettings': {
          'mobile': _mobilePrivacy,
          'email': _emailPrivacy,
          'address': _addressPrivacy,
          'guardian': _guardianPrivacy,
          'shareClassGroup': _shareClassGroup,
        },
      };

      await ref.read(profileRepositoryProvider).updateMyProfile(privacyData);
      ref.invalidate(myProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ગોપનીયતા સેટિંગ્સ સફળતાપૂર્વક સાચવવામાં આવી (Privacy settings updated)',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF041126),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('સેટિંગ્સ સાચવવામાં ભૂલ આવી: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    final profileAsync = ref.watch(myProfileProvider);
    profileAsync.whenData((profile) => _syncFromProfile(profile));

    final isFemale = profileAsync.valueOrNull?.isFemale ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2), // Light cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F2),
        title: const Text(
          'Privacy & Contact (સંપર્ક)',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: isMobile ? size.width : 600,
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(16),
              child: Column(
                children: [
                  // MAIN PRIVACY SETTINGS CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.1), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Top Security Note inside the card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD4AF37)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.security, color: Color(0xFFD4AF37), size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isFemale
                                      ? 'દીકરીઓની સુરક્ષા માટે તમારો મોબાઈલ નંબર અને ઈમેઈલ આપમેળે ગુપ્ત (🔒 માત્ર મને) રહે છે.\nલગ્ન સંબંધ માટે પિતા/વાલીનો નંબર ખુલ્લો રહેશે. તમે અહીંથી ગમે ત્યારે બદલી શકો છો.'
                                      : 'તમારો સંપર્ક નંબર અન્ય વ્યક્તિઓથી ગુપ્ત રાખી શકો છો.\nમાહિતી માત્ર ઓથોરાઇઝ સભ્યોને જ દેખાશે.',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Divider: માહિતી કોણ જોઈ શકે?
                        _buildSectionTitle('માહિતી કોણ જોઈ શકે?'),

                        const SizedBox(height: 8),

                        // Dropdown Rows
                        _buildPrivacyDropdownRow(
                          icon: Icons.phone_in_talk,
                          title: 'મોબાઈલ નંબર',
                          subtitle: 'તમારો મોબાઈલ નંબર કોણ જોઈ શકે તે પસંદ કરો.',
                          value: _mobilePrivacy,
                          onChanged: (val) {
                            if (val != null) _updatePrivacySetting(mobile: val);
                          },
                        ),
                        _buildDivider(),
                        _buildPrivacyDropdownRow(
                          icon: Icons.email_outlined,
                          title: 'ઈમેઈલ સરનામું',
                          subtitle: 'તમારું ઈમેઈલ સરનામું કોણ જોઈ શકે તે પસંદ કરો.',
                          value: _emailPrivacy,
                          onChanged: (val) {
                            if (val != null) _updatePrivacySetting(email: val);
                          },
                        ),
                        _buildDivider(),
                        _buildPrivacyDropdownRow(
                          icon: Icons.home_outlined,
                          title: 'ઘરનું સરનામું',
                          subtitle: 'તમારું સરનામું કોણ જોઈ શકે તે પસંદ કરો.',
                          value: _addressPrivacy,
                          onChanged: (val) {
                            if (val != null) _updatePrivacySetting(address: val);
                          },
                        ),
                        _buildDivider(),
                        _buildPrivacyDropdownRow(
                          icon: Icons.groups_outlined,
                          title: 'વાલીનો સંપર્ક',
                          subtitle: 'તમારા સંપર્કની માહિતી અન્ય વાલીઓને દેખાડવી કે નહી.',
                          value: _guardianPrivacy,
                          onChanged: (val) {
                            if (val != null) _updatePrivacySetting(guardian: val);
                          },
                        ),
                        _buildDivider(),
                        
                        // Switch Row for Class Group
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1565C0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.contacts, color: Color(0xFFD4AF37), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ક્લાસ ગ્રુપમાં નંબર શેર કરો', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 2),
                                    Text('શું તમારો નંબર તમારા ક્લાસ ગ્રુપમાં શેર કરવો છે?', style: TextStyle(color: Colors.black54, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  CupertinoSwitch(
                                    value: _shareClassGroup,
                                    activeTrackColor: const Color(0xFF1565C0),
                                    onChanged: (val) => _updatePrivacySetting(shareClass: val),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_shareClassGroup ? 'ચાલુ' : 'બંધ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // HOW IT WILL APPEAR SUMMARY
                  const SizedBox(height: 16),
                  _buildSectionTitle('મારી માહિતી કેવી રીતે દેખાશે?', icon: Icons.visibility),
                  const SizedBox(height: 12),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('મોબાઈલ નંબર', _mobilePrivacy),
                        _buildDivider(),
                        _buildSummaryRow('ઈમેઈલ સરનામું', _emailPrivacy),
                        _buildDivider(),
                        _buildSummaryRow('ઘરનું સરનામું', _addressPrivacy),
                        _buildDivider(),
                        _buildSummaryRow('વાલીનો સંપર્ક', _guardianPrivacy),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // NOTE CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user, color: Color(0xFF1565C0), size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('સુરક્ષા નોંધ (Security Note)', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(
                                isFemale
                                    ? 'સમાજની દીકરીઓની અંગત સુરક્ષા માટે મોબાઇલ અને ઇમેઇલ માત્ર તમને જ દેખાશે. લગ્ન વિષયક પૂછપરછ માટે પિતા અને વાલીનો નંબર ઉપલબ્ધ રહેશે.'
                                    : 'અધિકૃત સભ્યો જ તમારી પરવાનગી મુજબ સંપર્ક વિગતો જોઈ શકશે. તમારી પરવાનગી વગર તમારી માહિતી કોઈ સાથે શેર કરવામાં આવશે નહિ.',
                                style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contact Support Footer
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Gujarat Vankar Samaj Contact Support',
                          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        _buildContactRow(Icons.email_outlined, 'Email Address', 'support@vankarsamaj.com'),
                        const SizedBox(height: 20),
                        _buildContactRow(Icons.phone_outlined, 'Phone Number', '+91 98765 43210'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyDropdownRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF041126),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF041126),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _privacyOptions.contains(value) ? value : _privacyOptions.first,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4AF37), size: 16),
                dropdownColor: const Color(0xFF041126),
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold),
                items: _privacyOptions.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Row(
                      children: [
                        Icon(
                          val == 'માત્ર મને' ? Icons.lock : (val == 'પરિવારજનો' ? Icons.groups : Icons.public),
                          color: const Color(0xFFD4AF37),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(val),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    IconData iconData = Icons.lock;
    Color iconColor = const Color(0xFFC2185B);
    if (value == 'પરિવારજનો') {
      iconData = Icons.groups;
      iconColor = const Color(0xFF1565C0);
    } else if (value == 'બધા માટે') {
      iconData = Icons.public;
      iconColor = const Color(0xFF2E7D32);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(iconData, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(color: iconColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildContactRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
