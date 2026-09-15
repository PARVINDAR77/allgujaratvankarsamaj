import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Government Employees Screen displaying full poster artwork layout 5.jpeg with functional touch hotspots.
class GovtEmployeesScreen extends ConsumerStatefulWidget {
  const GovtEmployeesScreen({super.key});

  @override
  ConsumerState<GovtEmployeesScreen> createState() => _GovtEmployeesScreenState();
}

class _GovtEmployeesScreenState extends ConsumerState<GovtEmployeesScreen> {
  void _showEmployeeDetails(String name, String dept, String post, String district) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Department:', dept),
            _buildDetailRow('Designation:', post),
            _buildDetailRow('District:', district),
            _buildDetailRow('Status:', 'Verified Government Employee'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Matrimonial Interest sent to $name!')),
              );
            },
            icon: const Icon(Icons.favorite, size: 14, color: Colors.white),
            label: const Text('Send Interest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            // Native aspect ratio for poster artwork 5.jpeg (736 x 1600)
            final posterH = screenW * (1600 / 736);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: screenW,
                height: posterH,
                child: Stack(
                  children: [
                    // 1. Full Image Artwork Poster (5.jpeg)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/5.jpeg',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (1).jpeg',
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF041026),
                          ),
                        ),
                      ),
                    ),

                    // 2. Top-Left Menu Icon (☰) Hotspot
                    Positioned(
                      left: screenW * 0.03,
                      top: posterH * 0.012,
                      width: screenW * 0.14,
                      height: posterH * 0.045,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // 3. Top-Right Notification Bell Icon (🔔) Hotspot
                    Positioned(
                      right: screenW * 0.03,
                      top: posterH * 0.012,
                      width: screenW * 0.14,
                      height: posterH * 0.045,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No new notifications')),
                            );
                          },
                        ),
                      ),
                    ),

                    // 4. Filter Dropdown Buttons Hotspots Bar (Dept, Post, District, Taluka)
                    Positioned(
                      left: screenW * 0.03,
                      top: posterH * 0.365,
                      width: screenW * 0.94,
                      height: posterH * 0.045,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFF007BFF).withValues(alpha: 0.25),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filter selected: All Departments & Districts')),
                            );
                          },
                        ),
                      ),
                    ),

                    // 5. Search Bar & Search/Reset Buttons Row Hotspot
                    Positioned(
                      left: screenW * 0.03,
                      top: posterH * 0.420,
                      width: screenW * 0.94,
                      height: posterH * 0.040,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFF007BFF).withValues(alpha: 0.25),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Searching Government Employee Directory...')),
                            );
                          },
                        ),
                      ),
                    ),

                    // 6. Data Row 1 Hotspot: Dipak R. Vankar (IAS Officer)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.490,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Dipak R. Vankar', 'IAS', 'IAS Officer', 'Gandhinagar'),
                      ),
                    ),

                    // 7. Data Row 2 Hotspot: Riddhi M. Vankar (Teacher)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.516,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Riddhi M. Vankar', 'Education', 'Teacher', 'Ahmedabad'),
                      ),
                    ),

                    // 8. Data Row 3 Hotspot: Hardik P. Vankar (Police Inspector)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.542,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Hardik P. Vankar', 'Police', 'Police Inspector', 'Surat'),
                      ),
                    ),

                    // 9. Data Row 4 Hotspot: Kavita B. Vankar (Staff Nurse)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.568,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Kavita B. Vankar', 'Health', 'Staff Nurse', 'Vadodara'),
                      ),
                    ),

                    // 10. Data Row 5 Hotspot: Jigneshkumar V. Vankar (Talati)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.594,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Jigneshkumar V. Vankar', 'Revenue', 'Talati', 'Rajkot'),
                      ),
                    ),

                    // 11. Data Row 6 Hotspot: Rekhaben V. Vankar (Gram Sevak)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.620,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Rekhaben V. Vankar', 'Panchayat', 'Gram Sevak', 'Jamnagar'),
                      ),
                    ),

                    // 12. Data Row 7 Hotspot: Manish D. Vankar (Forest Guard)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.646,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Manish D. Vankar', 'Forest', 'Forest Guard', 'Junagadh'),
                      ),
                    ),

                    // 13. Data Row 8 Hotspot: Hetal K. Vankar (Court Clerk)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.672,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Hetal K. Vankar', 'Judiciary', 'Court Clerk', 'Bhavnagar'),
                      ),
                    ),

                    // 14. Data Row 9 Hotspot: Sanjay L. Vankar (Junior Engineer)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.698,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Sanjay L. Vankar', 'GEB', 'Junior Engineer', 'Mehsana'),
                      ),
                    ),

                    // 15. Data Row 10 Hotspot: Devangiben S. Vankar (Welfare Officer)
                    Positioned(
                      left: screenW * 0.02,
                      top: posterH * 0.724,
                      width: screenW * 0.96,
                      height: posterH * 0.024,
                      child: InkWell(
                        onTap: () => _showEmployeeDetails('Devangiben S. Vankar', 'Social Justice', 'Welfare Officer', 'Kutch'),
                      ),
                    ),

                    // 16. Bottom Feature Icon 1: Education
                    Positioned(
                      left: screenW * 0.04,
                      top: posterH * 0.775,
                      width: screenW * 0.16,
                      height: posterH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => context.push('/samaj-services'),
                        ),
                      ),
                    ),

                    // 17. Bottom Feature Icon 2: Connect
                    Positioned(
                      left: screenW * 0.23,
                      top: posterH * 0.775,
                      width: screenW * 0.16,
                      height: posterH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 18. Bottom Feature Icon 3: Progress
                    Positioned(
                      left: screenW * 0.42,
                      top: posterH * 0.775,
                      width: screenW * 0.16,
                      height: posterH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => context.push('/verified-profile'),
                        ),
                      ),
                    ),

                    // 19. Bottom Feature Icon 4: Support
                    Positioned(
                      left: screenW * 0.61,
                      top: posterH * 0.775,
                      width: screenW * 0.16,
                      height: posterH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => context.push('/samaj-services'),
                        ),
                      ),
                    ),

                    // 20. Bottom Feature Icon 5: Bright Future
                    Positioned(
                      left: screenW * 0.80,
                      top: posterH * 0.775,
                      width: screenW * 0.16,
                      height: posterH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => context.push('/family-details'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
