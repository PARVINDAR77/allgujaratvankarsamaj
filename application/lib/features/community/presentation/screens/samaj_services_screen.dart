import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SamajServicesScreen extends StatefulWidget {
  const SamajServicesScreen({super.key});

  @override
  State<SamajServicesScreen> createState() => _SamajServicesScreenState();
}

class _SamajServicesScreenState extends State<SamajServicesScreen> {
  static final List<Map<String, dynamic>> _serviceCategories = [
    {
      'title': '1. ઘર અને દૈનિક જીવનની સેવાઓ',
      'color': Colors.orange,
      'items': [
        '🧱 Mason / Raj Mistri',
        '🎨 Painter',
        '🔧 Plumber',
        '⚡ Electrician',
        '❄️ AC / Fridge Repair',
        '🪚 Carpenter',
        '🪟 Aluminium / Glass Work',
        '🚪 Furniture / Interior',
        '🧹 House Cleaning',
        '🐜 Pest Control',
        '🚚 Packers & Movers',
      ],
    },
    {
      'title': '2. Vehicle & Transport',
      'color': Colors.blue,
      'items': [
        '🚗 Car Rental',
        '🛵 Bike/Scooter Repair',
        '🚘 Car Repair / Garage',
        '🛞 Tyre & Puncture',
        '🔋 Battery Service',
        '🚕 Taxi / Cab',
        '🚌 Bus / Tempo',
        '🚛 Goods Transport',
        '🚗 Driver Service',
        '🅿️ Parking Service',
      ],
    },
    {
      'title': '3. Computer & Digital Services',
      'color': Colors.purple,
      'items': [
        '💻 Computer/Laptop Repair',
        '🖨️ Printer Repair',
        '📱 Mobile Repair',
        '🌐 Website Development',
        '📱 App Development',
        '🎨 Graphic Design',
        '🖨️ Printing / Xerox',
        '📸 Photo Studio',
        '🪪 Online Form Filling',
        '📄 Document Scanning',
        '💳 Digital Payment Assistance',
      ],
    },
    {
      'title': '4. Education Services',
      'color': Colors.green,
      'items': [
        '👨‍🏫 Tuition / Coaching',
        '🏫 School Admission Guidance',
        '🎓 College Admission Guidance',
        '📝 Competitive Exam Coaching',
        '💼 Career Guidance',
        '🌍 Foreign Study Guidance',
        '📖 Books / Stationery',
        '💻 Computer Training',
        '🗣️ English Speaking',
        '🏆 Scholarship Information',
      ],
    },
    {
      'title': '5. Job & Business Services',
      'color': Colors.teal,
      'items': [
        '💼 Job Placement',
        '👷 Skilled Worker Jobs',
        '🏢 Private Job Information',
        '🏛️ Government Job Guidance',
        '📄 Resume / CV Making',
        '💼 Interview Preparation',
        '🏪 Business Directory',
        '🤝 Business Networking',
        '📈 Business Consultant',
        '🧾 GST / Tax Consultant',
      ],
    },
    {
      'title': '6. Legal & Financial Services',
      'color': Colors.indigo,
      'items': [
        '⚖️ Advocate / Legal Advice',
        '📑 Document Writer',
        '🏦 Bank Loan Assistance',
        '💰 Financial Consultant',
        '🧾 Income Tax / GST',
        '🏠 Property Documents',
        '📜 Insurance Agent',
        '💳 Loan / Finance Services',
        '🏦 Banking Assistance',
      ],
    },
    {
      'title': '7. Health & Emergency',
      'color': Colors.red,
      'items': [
        '🏥 Hospital',
        '👨‍⚕️ Doctor',
        '🦷 Dentist',
        '👓 Eye Care',
        '💊 Medical Store',
        '🚑 Ambulance',
        '🩸 Blood Donor Directory',
        '🧪 Laboratory / Diagnostic',
        '🧑‍⚕️ Home Nursing',
        '♿ Elderly Assistance',
      ],
    },
    {
      'title': '8. Business & Local Shops',
      'color': Colors.brown,
      'items': [
        '🛒 Grocery',
        '👗 Clothes / Garments',
        '👟 Footwear',
        '📱 Mobile Shop',
        '💻 Electronics',
        '🪑 Furniture',
        '💎 Jewellery',
        '🍰 Bakery',
        '🍽️ Restaurant / Food',
        '🖨️ Printing Press',
      ],
    },
    {
      'title': '9. Skilled Professionals',
      'color': Colors.blueGrey,
      'items': [
        '👨‍🔧 Electrician',
        '🔧 Plumber',
        '🪚 Carpenter',
        '🔨 Welder',
        '🧱 Mason',
        '🎨 Painter',
        '👨‍💻 Computer Technician',
        '📱 Mobile Technician',
        '🚗 Mechanic',
        '❄️ AC Technician',
        '📺 TV Technician',
      ],
    },
    {
      'title': '10. Event & Wedding Services (A-Z)',
      'color': Colors.pink,
      'items': [
        '❄️ AC Repair & Services',
        '🔈 Audio & Sound System Rental',
        '💄 Beauty Parlor & Bridal Makeup',
        '🏛️ Banquet Hall Booking',
        '🥁 Brass Band & Dhol',
        '📷 Cameraman & Photography',
        '🚗 Car Rental (Luxury & Wedding Cars)',
        '🍽️ Catering Services',
        '🚁 Drone Videography & Aerial Shots',
        '🎛️ DJ Sound & Disco Lighting',
        '🎪 Event Management & Planning',
        '⚡ Electrical Works & Lighting',
        '🌸 Flower Decoration & Stage Setup',
        '🍛 Food Stalls & Live Counters',
        '🔌 Generator Rental',
        '🎨 Graphic Design & Banner Printing',
        '✨ Haldi & Mehendi Decoration',
        '💇‍♀️ Hair Styling & Unisex Salon',
        '💌 Invitation Card Printing & E-Invites',
        '🛋️ Interior Decoration',
        '💍 Jewelry Rental & Bridal Accessories',
        '🤹 Juggler & Mascot Entertainment',
        '✉️ Kankotri & Wedding Card Shop',
        '🧑‍🍳 Kitchen Catering & Halwai Services',
        '🎥 Live YouTube & Facebook Streaming',
        '📺 LED Screen (Video Wall) Setup',
        '🎪 Mandap & Shamiana Decoration',
        '✍️ Mehendi Artist',
        '📱 Mobile & Electronics Shop',
        '🎇 Name Entry Setup & Cold Pyro Effects',
        '🪴 Nursery & Floral Supply',
        '💻 Online Cyber Cafe Services',
        '👮 Officers & Bouncer Security Services',
        '📸 Pre-Wedding Photography & Cinematography',
        '🖨️ Printing & Flex Shop',
        '🧽 Quick Car Wash & Detailing',
        '📦 Quick Courier & Transport',
        '🚌 Rental Cars, Buses & Tempo Travellers',
        '💧 RO Water Filter Service',
        '🔊 Sound System & DJ Setup',
        '⛩️ Stage & Entry Gate Decoration',
        '✂️ Tailoring Shop',
        '⛺ Tent, Chair & Table Rental',
        '✈️ Tours & Travels Booking',
        '🔧 Utility Repair Services',
        '⛱️ Umbrella & Outdoor Canopy Rental',
        '📹 Video Shooting (4K / Cinematic HD)',
        '🚘 Vintage Car Rental for Groom Entry',
        '💍 Wedding Planning & Coordination',
        '🚰 Water Tanker Supply',
        '🙋‍♀️ Welcome Girls & Hostess',
        '🖨️ Xerox, Lamination & Document Printing',
        '▶️ YouTube Live Streaming & Broadcast',
        '🪡 Zari & Embroidery Works',
        '🧥 Groom Wear & Sherwani Rental',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    // Custom Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF041126), Color(0xFF0A2A5E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (context.canPop()) context.pop();
                                  else context.go('/home');
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vankar Samaj Services',
                                      style: TextStyle(color: const Color(0xFFD4AF37), fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      'સમાજ માટે - સમાજ દ્વારા',
                                      style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.handshake, color: const Color(0xFFD4AF37).withValues(alpha: 0.8), size: isDesktop ? 48 : 36),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Services List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _serviceCategories.length,
                        itemBuilder: (context, index) {
                          final category = _serviceCategories[index];
                          final Color color = category['color'];
                          final List<String> items = category['items'];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.category, color: color, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category['title'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: color.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Items Grid
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 280,
                                    mainAxisExtent: 60,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, itemIndex) {
                                    final String fullItem = items[itemIndex];
                                    final int spaceIndex = fullItem.indexOf(' ');
                                    final String emoji = spaceIndex != -1 ? fullItem.substring(0, spaceIndex) : '';
                                    final String text = spaceIndex != -1 ? fullItem.substring(spaceIndex + 1) : fullItem;
                                    
                                    return InkWell(
                                      onTap: () {},
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade200),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            if (emoji.isNotEmpty) ...[
                                              Text(emoji, style: const TextStyle(fontSize: 22)),
                                              const SizedBox(width: 12),
                                            ],
                                            Expanded(
                                              child: Text(
                                                text,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF041126),
                                                  height: 1.2,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
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

