import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';

class SamajServicesScreen extends StatelessWidget {
  const SamajServicesScreen({super.key});

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
              subtitle: '“સમાજ માટે – સમાજ દ્વારા”',
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    // Header: VANKAR Samaj Services
                    const Text(
                      'VANKAR',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'Samaj Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 20, height: 1, color: AppColors.secondary),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'સમાજ માટે – સમાજ દ્વારા',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(width: 20, height: 1, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 6 Event Service Tiles (2 Columns x 3 Rows)
                    _buildServicesGrid(context),
                    const SizedBox(height: 16),

                    // Directory Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 1, color: AppColors.secondary),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'વ્યવસાય મુજબ સંપર્ક માહિતી',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(width: 24, height: 1, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Directory Table
                    _buildDirectoryTable(context),
                    const SizedBox(height: 14),

                    // Bottom CTA: તમારો વ્યવસાય ઉમેરવા માટે અહીં ક્લિક કરો
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.cardNavy,
                            content: Text(
                              'Opening business registration form for Vankar Samaj Directory...',
                              style: TextStyle(color: AppColors.goldLight),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF041026),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.groups, color: AppColors.secondary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'તમારો વ્યવસાય ઉમેરવા માટે અહીં ક્લિક કરો',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 14),
                          ],
                        ),
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

  Widget _buildServicesGrid(BuildContext context) {
    return Column(
      children: [
        // Row 1: Mandap | Photography
        Row(
          children: [
            Expanded(
              child: _buildServiceTile(
                context,
                title: 'મંડપ',
                subtitle: 'મંડપ બુકિંગ / સંપર્ક',
                desc: 'લગ્ન અને અન્ય પ્રસંગો માટે મંડપ બુક કરો.',
                icon: Icons.holiday_village,
                buttonText: 'સંપર્ક કરો',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildServiceTile(
                context,
                title: 'ફોટોગ્રાફી',
                subtitle: 'ફોટો અને વિડિંયો સેવા',
                desc: 'પ્રોફેશનલ ફોટોગ્રાફી અને વિડિયો શુટીંગ સેવા.',
                icon: Icons.camera_alt,
                buttonText: 'સંપર્ક કરો',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 2: YouTube Live | Car Rental
        Row(
          children: [
            Expanded(
              child: _buildServiceTile(
                context,
                title: 'YouTube Live',
                subtitle: 'લગ્ન કાર્યક્રમનું Live Streaming',
                desc: 'તમારા શુભ પ્રસંગને Live YouTube પર પ્રસારિત કરો.',
                icon: Icons.videocam,
                buttonText: 'સંપર્ક કરો',
                isLive: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildServiceTile(
                context,
                title: 'ભાડે કાર 🚗',
                subtitle: 'કાર Rental',
                desc: 'લગ્ન અને પ્રવાસ માટે કાર ભાડે ઉપલબ્ધ.',
                icon: Icons.directions_car,
                buttonText: 'સંપર્ક કરો',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row 3: Eeco Rental | Business Directory Phone Numbers
        Row(
          children: [
            Expanded(
              child: _buildServiceTile(
                context,
                title: 'ભાડે ઈકો 🚐',
                subtitle: 'ઈકો Rental',
                desc: 'સમૂહ પ્રવાસ અને અન્ય કામ માટે ઈકો ભાડે ઉપલબ્ધ.',
                icon: Icons.airport_shuttle,
                buttonText: 'સંપર્ક કરો',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildServiceTile(
                context,
                title: 'સમાજના ધંધો કરતા લોકોના',
                subtitle: 'Phone Number',
                desc: 'સમાજના વિવિધ વ્યવસાય સાથે જોડાયેલા લોકોની સંપર્ક માહિતી મેળવો.',
                icon: Icons.groups,
                buttonText: 'જુઓ સંપર્ક યાદી >',
                isSecondary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String desc,
    required IconData icon,
    required String buttonText,
    bool isLive = false,
    bool isSecondary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: AppColors.secondary, size: 18),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(color: Colors.white60, fontSize: 9, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.cardNavy,
                    content: Text('Contacting $title vendor service...'),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: isSecondary ? null : AppColors.goldGradient,
                  color: isSecondary ? const Color(0xFF0E2A54) : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isSecondary ? Border.all(color: AppColors.secondary, width: 1) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSecondary) ...[
                      const Icon(Icons.call, color: Colors.black87, size: 10),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: isSecondary ? AppColors.goldLight : Colors.black87,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryTable(BuildContext context) {
    final contacts = [
      {'cat': 'રીયલ એસ્ટેટ', 'name': 'જયેશ વણકર', 'phone': '98765 43210', 'place': 'હિંમતનગર', 'icon': Icons.apartment},
      {'cat': 'કિરાણા સ્ટોર', 'name': 'મહેશ વણકર', 'phone': '98765 12345', 'place': 'હિંમતનગર', 'icon': Icons.shopping_cart},
      {'cat': 'ટેઈલરિંગ', 'name': 'રમેશ વણકર', 'phone': '98765 67890', 'place': 'હિંમતનગર', 'icon': Icons.content_cut},
      {'cat': 'મેડિકલ સ્ટોર', 'name': 'હિતેશ વણકર', 'phone': '98765 24680', 'place': 'હિંમતનગર', 'icon': Icons.local_hospital},
      {'cat': 'કેટરીંગ સેવા', 'name': 'વિપુલ વણકર', 'phone': '98765 13579', 'place': 'હિંમતનગર', 'icon': Icons.restaurant},
      {'cat': 'ફોટોગ્રાફી', 'name': 'દીપક વણકર', 'phone': '98765 97531', 'place': 'હિંમતનગર', 'icon': Icons.camera_alt},
      {'cat': 'ટ્રાવેલ્સ', 'name': 'પ્રકાશ વણકર', 'phone': '98765 86420', 'place': 'હિંમતનગર', 'icon': Icons.directions_bus},
      {'cat': 'મેન્યુફેક્ચરિંગ', 'name': 'નિલેશ વણકર', 'phone': '98765 11223', 'place': 'હિંમતનગર', 'icon': Icons.factory},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.secondary.withValues(alpha: 0.25), width: 0.8),
            verticalInside: BorderSide(color: AppColors.secondary.withValues(alpha: 0.25), width: 0.8),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2.6),
            1: FlexColumnWidth(2.6),
            2: FlexColumnWidth(2.6),
            3: FlexColumnWidth(2.2),
            4: FlexColumnWidth(1.2),
          },
          children: [
            // Header Row
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF0A1F3D)),
              children: const [
                _HeaderCol('વ્યવસાય'),
                _HeaderCol('નામ'),
                _HeaderCol('ફોન નંબર'),
                _HeaderCol('સ્થાન'),
                _HeaderCol('કોલ'),
              ],
            ),
            // Data Rows
            ...contacts.map((c) {
              return TableRow(
                decoration: BoxDecoration(
                  color: contacts.indexOf(c).isEven ? const Color(0xFF041026) : const Color(0xFF061633),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(c['icon'] as IconData, color: AppColors.secondary, size: 11),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            c['cat'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _DataCol(c['name'] as String, isGold: true),
                  _DataCol(c['phone'] as String),
                  _DataCol(c['place'] as String),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${c['name']} (${c['phone']})...')),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Icon(Icons.call, color: Color(0xFF2EB85C), size: 14),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderCol extends StatelessWidget {
  final String title;
  const _HeaderCol(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DataCol extends StatelessWidget {
  final String text;
  final bool isGold;
  const _DataCol(this.text, {this.isGold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          color: isGold ? AppColors.goldLight : Colors.white,
          fontSize: 10,
          fontWeight: isGold ? FontWeight.bold : FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
