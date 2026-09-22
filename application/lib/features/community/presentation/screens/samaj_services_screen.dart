import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_data.dart';

class SamajServicesScreen extends StatefulWidget {
  const SamajServicesScreen({super.key});

  @override
  State<SamajServicesScreen> createState() => _SamajServicesScreenState();
}

class _SamajServicesScreenState extends State<SamajServicesScreen> {
  String? selectedDistrict;
  String? selectedTaluka;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

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
      'title': '6. Legal & Financial Services (કાનૂની અને નાણાકીય સેવાઓ)',
      'color': Colors.indigo,
      'items': [
        '⚖️ Advocate / Legal Advice (વકીલ / કાનૂની સલાહ)',
        '📑 Document Writer (દસ્તાવેજ લેખક)',
        '🏦 Bank Loan Assistance (બેંક લોન સહાય)',
        '💰 Financial Consultant (નાણાકીય સલાહકાર)',
        '🧾 Income Tax / GST (ઇન્કમ ટેક્સ / જીએસટી)',
        '🏠 Property Documents (મિલકતના દસ્તાવેજો)',
        '📜 Insurance Agent (વીમા એજન્ટ)',
        '💳 Loan / Finance Services (લોન / ફાઇનાન્સ સેવાઓ)',
        '🏦 Banking Assistance (બેંકિંગ સહાય)',
      ],
    },
    {
      'title': '7. Health & Emergency (આરોગ્ય અને ઈમરજન્સી સેવાઓ)',
      'color': Colors.red,
      'items': [
        '🏥 Hospital (હોસ્પિટલ)',
        '👨‍⚕️ Doctor (ડૉક્ટર)',
        '🦷 Dentist (ડેન્ટિસ્ટ)',
        '👓 Eye Care (આંખની સંભાળ)',
        '💊 Medical Store (મેડિકલ સ્ટોર)',
        '🚑 Ambulance (એમ્બ્યુલન્સ)',
        '🩸 Blood Donor Directory (રક્તદાતા નિર્દેશિકા)',
        '🧪 Laboratory / Diagnostic (લેબોરેટરી)',
        '🧑‍⚕️ Home Nursing (હોમ નર્સિંગ)',
        '♿ Elderly Assistance (વૃદ્ધ સહાય)',
      ],
    },
    {
      'title': '8. Business & Local Shops (વેપાર અને સ્થાનિક દુકાનો)',
      'color': Colors.brown,
      'items': [
        '🛒 Grocery (કરિયાણું)',
        '👗 Clothes / Garments (કપડાં / ગારમેન્ટ્સ)',
        '👟 Footwear (ફૂટવેર / ચંપલ-જૂતા)',
        '📱 Mobile Shop (મોબાઈલની દુકાન)',
        '💻 Electronics (ઇલેક્ટ્રોનિક્સ)',
        '🪑 Furniture (ફર્નિચર)',
        '💎 Jewellery (જ્વેલરી / સોની)',
        '🍰 Bakery (બેકરી)',
        '🍽️ Restaurant / Food (રેસ્ટોરન્ટ / જમવાનું)',
        '🖨️ Printing Press (પ્રિન્ટિંગ પ્રેસ)',
      ],
    },
    {
      'title': '9. Skilled Professionals (કુશળ કારીગરો અને વ્યાવસાયિકો)',
      'color': Colors.blueGrey,
      'items': [
        '👨‍🔧 Electrician (ઇલેક્ટ્રિશિયન)',
        '🔧 Plumber (પ્લમ્બર)',
        '🪚 Carpenter (સુથાર)',
        '🔨 Welder (વેલ્ડર)',
        '🧱 Mason (કડિયો)',
        '🎨 Painter (કલર કામ કરનાર)',
        '👨‍💻 Computer Technician (કમ્પ્યુટર ટેકનિશિયન)',
        '📱 Mobile Technician (મોબાઈલ ટેકનિશિયન)',
        '🚗 Mechanic (મિકેનિક)',
        '❄️ AC Technician (એસી ટેકનિશિયન)',
        '📺 TV Technician (ટીવી ટેકનિશિયન)',
      ],
    },
    {
      'title': '10. Event & Wedding Services (પ્રસંગ અને લગ્ન સેવાઓ A-Z)',
      'color': Colors.pink,
      'items': [
        '❄️ AC Repair & Services (એસી રિપેરિંગ)',
        '🔈 Audio & Sound System Rental (સાઉન્ડ સિસ્ટમ ભાડે)',
        '💄 Beauty Parlor & Bridal Makeup (બ્યુટી પાર્લર / મેકઅપ)',
        '🏛️ Banquet Hall Booking (બેન્ક્વેટ હોલ બુકિંગ)',
        '🥁 Brass Band & Dhol (બ્રાસ બેન્ડ / ઢોલ)',
        '📷 Cameraman & Photography (કેમેરામેન / ફોટોગ્રાફી)',
        '🚗 Car Rental (Luxury & Cars) (લક્ઝરી કાર ભાડે)',
        '🍽️ Catering Services (કેટરિંગ સેવાઓ)',
        '🚁 Drone Videography (ડ્રોન શૂટિંગ)',
        '🎛️ DJ Sound & Disco Lighting (ડીજે / લાઇટિંગ)',
        '🎪 Event Management (ઇવેન્ટ મેનેજમેન્ટ)',
        '⚡ Electrical Works & Lighting (ઇલેક્ટ્રિકલ કામ)',
        '🌸 Flower Decoration & Stage Setup (ફૂલોની સજાવટ)',
        '🍛 Food Stalls & Live Counters (ફૂડ સ્ટોલ)',
        '🔌 Generator Rental (જનરેટર ભાડે)',
        '🎨 Graphic Design & Banner Printing (ગ્રાફિક ડિઝાઇન)',
        '✨ Haldi & Mehendi Decoration (હળદર / મહેંદી સજાવટ)',
        '💇‍♀️ Hair Styling & Unisex Salon (હેર સ્ટાઇલ / સલૂન)',
        '💌 Invitation Card Printing (કંકોત્રી છાપકામ)',
        '🛋️ Interior Decoration (ઇન્ટિરિયર ડેકોરેશન)',
        '💍 Jewelry Rental & Accessories (જ્વેલરી ભાડે)',
        '🤹 Juggler & Mascot Entertainment (મનોરંજન)',
        '✉️ Kankotri & Wedding Card Shop (કંકોત્રીની દુકાન)',
        '🧑‍🍳 Kitchen Catering & Halwai (રસોઇયા / હલવાઈ)',
        '🎥 Live YouTube Streaming (લાઇવ સ્ટ્રીમિંગ)',
        '📺 LED Screen (Video Wall) Setup (એલઇડી સ્ક્રીન)',
        '🎪 Mandap & Shamiana Decoration (મંડપ સજાવટ)',
        '✍️ Mehendi Artist (મહેંદી આર્ટિસ્ટ)',
        '📱 Mobile & Electronics Shop (મોબાઈલ દુકાન)',
        '🎇 Name Entry Setup & Pyro (નામ એન્ટ્રી)',
        '🪴 Nursery & Floral Supply (નર્સરી / ફૂલો)',
        '💻 Online Cyber Cafe Services (સાયબર કાફે)',
        '👮 Officers & Bouncer Security (બાઉન્સર / સુરક્ષા)',
        '📸 Pre-Wedding Photography (પ્રી-વેડિંગ ફોટોગ્રાફી)',
        '🖨️ Printing & Flex Shop (પ્રિન્ટિંગ / ફ્લેક્સ)',
        '🧽 Quick Car Wash & Detailing (કાર વૉશ)',
        '📦 Quick Courier & Transport (કુરિયર)',
        '🚌 Rental Cars, Buses & Tempo (બસ / ટેમ્પો ભાડે)',
        '💧 RO Water Filter Service (આરઓ વોટર સર્વિસ)',
        '🔊 Sound System & DJ Setup (સાઉન્ડ સિસ્ટમ)',
        '⛩️ Stage & Entry Gate Decoration (સ્ટેજ સજાવટ)',
        '✂️ Tailoring Shop (ટેલરિંગ / સિલાઈ)',
        '⛺ Tent, Chair & Table Rental (ટેન્ટ ભાડે)',
        '✈️ Tours & Travels Booking (ટૂર બુકિંગ)',
        '🔧 Utility Repair Services (રિપેરિંગ સેવાઓ)',
        '⛱️ Umbrella & Canopy Rental (છત્રી ભાડે)',
        '📹 Video Shooting (Cinematic HD) (વિડીયો શૂટિંગ)',
        '🚘 Vintage Car Rental for Entry (વિન્ટેજ કાર)',
        '💍 Wedding Planning & Coordination (વેડિંગ પ્લાનિંગ)',
        '🚰 Water Tanker Supply (પાણીના ટેન્કર)',
        '🙋‍♀️ Welcome Girls & Hostess (સ્વાગત કરતી છોકરીઓ)',
        '🖨️ Xerox & Document Printing (ઝેરોક્ષ / લેમિનેશન)',
        '▶️ YouTube Live Broadcast (યુટ્યુબ લાઇવ)',
        '🪡 Zari & Embroidery Works (ઝરી / ભરતકામ)',
        '🧥 Groom Wear & Sherwani Rental (શેરવાની ભાડે)',
        '👳 Safa Vala & Paghdi Tying (સાફા / પાઘડી બાંધનાર)',
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _showServiceProviders(BuildContext context, String serviceName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildProvidersBottomSheet(ctx, serviceName),
    );
  }

  Widget _buildProvidersBottomSheet(BuildContext context, String serviceName) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$serviceName Professionals',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF041126)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Dummy providers
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _buildProviderCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, int index) {
    int currentRating = 0;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 36, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Service Provider ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('10+ years experience', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text('4.8 (120 reviews)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message, size: 18),
                        label: const Text('Message'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.white),
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Contact'),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                const Text('Rate this Professional:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            starIndex < currentRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setLocalState(() {
                              currentRating = starIndex + 1;
                            });
                          },
                        );
                      }),
                    ),
                    if (currentRating > 0)
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted successfully!')));
                          setLocalState(() {
                            currentRating = 0;
                          });
                        },
                        child: const Text('Submit', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final districtsList = AppData.gujaratDistricts.keys.where((d) => d != 'Select District').toList();
    final talukasList = selectedDistrict != null && AppData.gujaratDistricts.containsKey(selectedDistrict) 
        ? AppData.gujaratDistricts[selectedDistrict]!.where((t) => t != 'Select Taluka').toList() 
        : <String>[];

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
                    
                    // --- SEARCH & FILTER SECTION ---
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Search services, professions...',
                              hintStyle: const TextStyle(color: Colors.black54),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Location Dropdowns Row
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 8,
                                  menuMaxHeight: 300,
                                  iconEnabledColor: const Color(0xFFD4AF37),
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: 'District',
                                    hintStyle: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  value: selectedDistrict,
                                  items: districtsList.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (val) => setState(() {
                                    selectedDistrict = val;
                                    selectedTaluka = null; // Reset taluka on district change
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 8,
                                  menuMaxHeight: 300,
                                  iconEnabledColor: const Color(0xFFD4AF37),
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: 'Taluka',
                                    hintStyle: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  value: selectedTaluka,
                                  items: talukasList.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (val) => setState(() => selectedTaluka = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _villageController,
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText: 'Village Name',
                                    hintStyle: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Search backend is temporarily disconnected.')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF041126),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    // --- END SEARCH & FILTER SECTION ---

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
                                    mainAxisExtent: 68,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, itemIndex) {
                                    final String fullItem = items[itemIndex];
                                    final match = RegExp(r'^(\S+)\s+(.*)$').firstMatch(fullItem);
                                    final String emoji = match != null ? match.group(1) ?? '' : '';
                                    final String text = match != null ? match.group(2) ?? fullItem : fullItem;
                                    
                                    return InkWell(
                                      onTap: () {
                                        _showServiceProviders(context, text);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                              Text(
                                                emoji,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Roboto',
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Expanded(
                                              child: Text(
                                                text,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF041126),
                                                  height: 1.2,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 14),
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

