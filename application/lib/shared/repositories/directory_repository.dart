import 'package:application/shared/models/directory_models.dart';

/// Temporary mock repository for Directory API.
/// This will be replaced by HTTP calls to the NestJS backend.
class DirectoryRepository {
  // All 13 extracted regions
  final List<DirectoryDistrict> _mockDistricts = [
    const DirectoryDistrict(id: 'd1', nameEn: 'Ahmedabad / Gandhinagar', nameGu: 'અમદાવાદ / ગાંધીનગર', sortOrder: 1),
    const DirectoryDistrict(id: 'd2', nameEn: 'Surat / Valsad', nameGu: 'સુરત / વલસાડ', sortOrder: 2),
    const DirectoryDistrict(id: 'd3', nameEn: 'Bharuch', nameGu: 'ભરૂચ', sortOrder: 3),
    const DirectoryDistrict(id: 'd4', nameEn: 'Vadodara', nameGu: 'વડોદરા', sortOrder: 4),
    const DirectoryDistrict(id: 'd5', nameEn: 'Anand / Kheda / Mahisagar', nameGu: 'આણંદ / ખેડા / મહિસાગર', sortOrder: 5),
    const DirectoryDistrict(id: 'd6', nameEn: 'Mehsana / Patan / Visnagar', nameGu: 'મહેસાણા / પાટણ / વિસનગર', sortOrder: 6),
    const DirectoryDistrict(id: 'd7', nameEn: 'Sabarkantha', nameGu: 'સાબરકાંઠા', sortOrder: 7),
    const DirectoryDistrict(id: 'd8', nameEn: 'Surendranagar', nameGu: 'સુરેન્દ્રનગર', sortOrder: 8),
    const DirectoryDistrict(id: 'd9', nameEn: 'Banaskantha', nameGu: 'બનાસકાંઠા', sortOrder: 9),
    const DirectoryDistrict(id: 'd10', nameEn: 'Bhavnagar', nameGu: 'ભાવનગર', sortOrder: 10),
    const DirectoryDistrict(id: 'd11', nameEn: 'Amreli / Saurashtra', nameGu: 'અમરેલી / સૌરાષ્ટ્ર', sortOrder: 11),
    const DirectoryDistrict(id: 'd12', nameEn: 'Jamnagar', nameGu: 'જામનગર', sortOrder: 12),
    const DirectoryDistrict(id: 'd13', nameEn: 'Kutch', nameGu: 'કચ્છ', sortOrder: 13),
  ];

  static final List<DirectoryPargana> _mockParganas = [
    const DirectoryPargana(id: 'p_d101_1', districtId: 'd101', nameEn: '', nameGu: 'સુરત પરજીયા માયાવંશી સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સુરત શહેર, નવસારી, વલસાડ'),
    const DirectoryPargana(id: 'p_d101_2', districtId: 'd101', nameEn: '', nameGu: 'મયાવંશી સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સુરત શહેર અને સુરત જીલ્લાના ગામો'),
    const DirectoryPargana(id: 'p_d101_3', districtId: 'd101', nameEn: '', nameGu: '૧૮ ગામ માયાવંશી સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સુરત જીલ્લાના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d101_4', districtId: 'd101', nameEn: '', nameGu: 'મોગ્રસીયા માયાવંશી સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સુરત જીલ્લાના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d102_5', districtId: 'd102', nameEn: '', nameGu: 'એક્સો પંચોતેર ગામ (૧૭૫) દેશી વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ભરૂચ જીલ્લાના નાંદોદ, ભરૂચ, ડેડીયાપાડા, વાગરા, ઝઘડિયા, આમોદ તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d103_6', districtId: 'd103', nameEn: '', nameGu: 'બાણું (૯૨) ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જંબુસર અને પાદરા તાલુકાના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d103_7', districtId: 'd103', nameEn: '', nameGu: 'વાકળ પરગણુ', type: 'SAMAJ', areaDescriptionGu: 'પાદરા તાલુકો'),
    const DirectoryPargana(id: 'p_d103_8', districtId: 'd103', nameEn: '', nameGu: 'કાનમ પરગણુ', type: 'SAMAJ', areaDescriptionGu: 'કરજણ તાલુકો'),
    const DirectoryPargana(id: 'p_d103_9', districtId: 'd103', nameEn: '', nameGu: 'મેવાસ પરગણુ', type: 'SAMAJ', areaDescriptionGu: 'તિલકવાડા, સંખેડા, બાધરપુર તાલુકાના ગામો (નર્મદા જીલ્લો)'),
    const DirectoryPargana(id: 'p_d103_10', districtId: 'd103', nameEn: '', nameGu: 'છોતેર પરગણુ', type: 'SAMAJ', areaDescriptionGu: 'વાઘોડિયા તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d103_11', districtId: 'd103', nameEn: '', nameGu: 'બાણું (૯૨) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'જંબુસર તાલુકો'),
    const DirectoryPargana(id: 'p_d103_12', districtId: 'd103', nameEn: '', nameGu: 'બાવન (૫૨) પરગણુ', type: 'SAMAJ', areaDescriptionGu: 'સાવલી તાલુકો'),
    const DirectoryPargana(id: 'p_d103_13', districtId: 'd103', nameEn: '', nameGu: 'પાલ પરગણા વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જબુગામ, જેતપુર અને પાવી તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d103_14', districtId: 'd103', nameEn: '', nameGu: 'રાજ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'રાજપીપળા (હવે નર્મદા જીલ્લો)'),
    const DirectoryPargana(id: 'p_d103_15', districtId: 'd103', nameEn: '', nameGu: 'પીસ્તાલીસ ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સાવલી અને વડોદરા તાલુકો'),
    const DirectoryPargana(id: 'p_d103_16', districtId: 'd103', nameEn: '', nameGu: 'એકવીસ (૨૧) પરગણા વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સંખેડા તલુકો'),
    const DirectoryPargana(id: 'p_d103_17', districtId: 'd103', nameEn: '', nameGu: 'શિનોર પરગણા', type: 'SAMAJ', areaDescriptionGu: 'શિનોર, કરજણ'),
    const DirectoryPargana(id: 'p_d104_18', districtId: 'd104', nameEn: '', nameGu: 'છયાસી (૮૬) ગામ વણકર પરગણું', type: 'SAMAJ', areaDescriptionGu: 'આંકલાવ, બોરસદ, પાદરા, ખંભાત, આણંદ અને વડોદરા તાલુકાના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d104_19', districtId: 'd104', nameEn: '', nameGu: 'ભાલ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ખંભાત તાલુકો'),
    const DirectoryPargana(id: 'p_d104_20', districtId: 'd104', nameEn: '', nameGu: 'છાસઠ ગામ (દંઢયા) પરગણું', type: 'SAMAJ', areaDescriptionGu: 'બોરસદ, આણંદ, પેટલાદ, સોજીત્રા અને તારાપુર તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d104_21', districtId: 'd104', nameEn: '', nameGu: 'સારસા વણકર સમાજ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'આણંદ જીલ્લાના ગામો'),
    const DirectoryPargana(id: 'p_d104_22', districtId: 'd104', nameEn: '', nameGu: 'ચરોતર વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ઓડ, ઉમરેઠ, નડીયાદ, આણંદ તાલુકાના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d105_23', districtId: 'd105', nameEn: '', nameGu: 'ચોયાસી વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'નડિયાદ, ખેડાના ગામો'),
    const DirectoryPargana(id: 'p_d105_24', districtId: 'd105', nameEn: '', nameGu: 'છાસઠ પરગણું (ડંઢયા) ૮૫ ગામ', type: 'SAMAJ', areaDescriptionGu: 'ખંભાત તાલુકો, બોરસદ, આણંદ, માતર, સોજીત્રા'),
    const DirectoryPargana(id: 'p_d105_25', districtId: 'd105', nameEn: '', nameGu: 'સપ્તકટ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ખંભાત તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d105_26', districtId: 'd105', nameEn: '', nameGu: 'છપ્પન ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ડાકોર અને ઠાસરા તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d105_27', districtId: 'd105', nameEn: '', nameGu: 'નવ (૦૯) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ઉમરેઠ વિસ્તારના ગામો'),
    const DirectoryPargana(id: 'p_d105_28', districtId: 'd105', nameEn: '', nameGu: 'પંદર (૧૫) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'મહુધા, કઠલાલ તાલુકો'),
    const DirectoryPargana(id: 'p_d105_29', districtId: 'd105', nameEn: '', nameGu: 'પાલ પરગણા સમાજ', type: 'SAMAJ', areaDescriptionGu: 'નડિયાદ – મહેમદાવાદ વચ્ચેના ગામો'),
    const DirectoryPargana(id: 'p_d105_30', districtId: 'd105', nameEn: '', nameGu: '૪૨ (૨૫૨) ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'મહેમદાવાદ તાલુકોનાં ગામો'),
    const DirectoryPargana(id: 'p_d105_31', districtId: 'd105', nameEn: '', nameGu: 'ખેડા (૦૯) ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'મહેમદાવાદ, તા. બારેજડી'),
    const DirectoryPargana(id: 'p_d105_32', districtId: 'd105', nameEn: '', nameGu: 'આઠ (૦૮) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'મોડાસા તાલુકો'),
    const DirectoryPargana(id: 'p_d105_33', districtId: 'd105', nameEn: '', nameGu: 'પંદર ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'મહુધા અને કઠલાલ તાલુકો.'),
    const DirectoryPargana(id: 'p_d105_34', districtId: 'd105', nameEn: '', nameGu: 'બાર (૧૨) ગામ પરગણુ', type: 'SAMAJ', areaDescriptionGu: 'સેવાલિયા અને બાલાસિનોર'),
    const DirectoryPargana(id: 'p_d105_35', districtId: 'd105', nameEn: '', nameGu: 'બાવીસો પરગણું', type: 'SAMAJ', areaDescriptionGu: 'કપડવંજ તાલુકાના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d105_36', districtId: 'd105', nameEn: '', nameGu: 'ચોયાસી (૩૦ ગામ) પરગણું', type: 'SAMAJ', areaDescriptionGu: 'કપડવંજ તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d105_37', districtId: 'd105', nameEn: '', nameGu: 'આંબલીયા બારનું પરગણું', type: 'SAMAJ', areaDescriptionGu: 'બાયડ તાલુકાના ગામો (અરવલ્લી જીલ્લો)'),
    const DirectoryPargana(id: 'p_d105_38', districtId: 'd105', nameEn: '', nameGu: '૪૭ ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'અરવલ્લી જીલ્લો'),
    const DirectoryPargana(id: 'p_d105_39', districtId: 'd105', nameEn: '', nameGu: 'બાવન (૫૨) ગામ તોરણ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'કપડવંજ તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d106_40', districtId: 'd106', nameEn: '', nameGu: 'બાવીસ ગામ પરગણા સમાજ', type: 'SAMAJ', areaDescriptionGu: 'મોડાસા પ્રાંતિજ (હવે અરવલ્લી જીલ્લો)'),
    const DirectoryPargana(id: 'p_d106_41', districtId: 'd106', nameEn: '', nameGu: 'અડઠ ભારીશ પ્રણામી પરગણું (૬૦ ગામો)', type: 'SAMAJ', areaDescriptionGu: 'મોડાસા, હિંમતનગર, ભિલોડા તાલુકો'),
    const DirectoryPargana(id: 'p_d106_42', districtId: 'd106', nameEn: '', nameGu: 'ચોવીસી ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'વીરપુર તાલુકો – મહીસાગર જીલ્લો'),
    const DirectoryPargana(id: 'p_d106_43', districtId: 'd106', nameEn: '', nameGu: 'નવ (૦૯) પંચ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'બાલાશિનોર તાલુકો – મહીસાગર જીલ્લો'),
    const DirectoryPargana(id: 'p_d108_44', districtId: 'd108', nameEn: '', nameGu: 'પાંચ (૦૫) પરગણા', type: 'SAMAJ', areaDescriptionGu: 'લુણાવાડા તાલુકો – મહીસાગર જીલ્લો'),
    const DirectoryPargana(id: 'p_d108_45', districtId: 'd108', nameEn: '', nameGu: 'કપડવંજ (૧૨૫) સવાસો ગામ', type: 'SAMAJ', areaDescriptionGu: 'કપડવંજ તલુકો – મહીસાગર જીલ્લો'),
    const DirectoryPargana(id: 'p_d108_46', districtId: 'd108', nameEn: '', nameGu: 'પ્રણામી વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'મોડાસા, માલપુર તાલુકો, દાહોદ જીલ્લો'),
    const DirectoryPargana(id: 'p_d108_47', districtId: 'd108', nameEn: '', nameGu: 'પાંચ (૦૫) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'દાહોદ તાલુકો'),
    const DirectoryPargana(id: 'p_d108_48', districtId: 'd108', nameEn: '', nameGu: 'પંદર (૧૫) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'લીમખેડા તાલુકો'),
    const DirectoryPargana(id: 'p_d108_49', districtId: 'd108', nameEn: '', nameGu: 'સત્તર (૧૭) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'દેવગઢબારીયા તાલુકો'),
    const DirectoryPargana(id: 'p_d108_50', districtId: 'd108', nameEn: '', nameGu: 'નવ (૦૯) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ધાનપુર તાલુકો'),
    const DirectoryPargana(id: 'p_d108_51', districtId: 'd108', nameEn: '', nameGu: 'પાંચ (૦૫) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'શંઘોડ તાલુકો'),
    const DirectoryPargana(id: 'p_d109_52', districtId: 'd109', nameEn: '', nameGu: 'પીસ્તાલીસ (૪૫) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ગોધરા અને શહેરા તાલુકો'),
    const DirectoryPargana(id: 'p_d109_53', districtId: 'd109', nameEn: '', nameGu: 'સોળ (૧૬) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'શહેરા તાલુકો'),
    const DirectoryPargana(id: 'p_d109_54', districtId: 'd109', nameEn: '', nameGu: 'સાવલી (૧૬) સોળ ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'લુણાવાડા તાલુકો (હવે મહીસાગર જીલ્લો)'),
    const DirectoryPargana(id: 'p_d109_55', districtId: 'd109', nameEn: '', nameGu: 'તોંતેર (૭૩) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'લુણાવાડા (હવે મહીસાગર જીલ્લો)'),
    const DirectoryPargana(id: 'p_d109_56', districtId: 'd109', nameEn: '', nameGu: 'સુડતાલીસ (૪૭) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'બાલાશિનોર (હવે મહીસાગર જીલ્લો)'),
    const DirectoryPargana(id: 'p_d109_57', districtId: 'd109', nameEn: '', nameGu: 'સાત (૦૭) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'વિરપુર, લુણાવાડા, બાલાશિનોર (મહીસાગર જીલ્લો)'),
    const DirectoryPargana(id: 'p_d109_58', districtId: 'd109', nameEn: '', nameGu: 'સોળ (૧૬) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'સંતરામપુર'),
    const DirectoryPargana(id: 'p_d109_59', districtId: 'd109', nameEn: '', nameGu: 'છત્રીસ (૩૬) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'હાલોલ'),
    const DirectoryPargana(id: 'p_d109_60', districtId: 'd109', nameEn: '', nameGu: 'પાંચસો (૫૦૦) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'મોરવા હડફ, ગોધરા અને બારિયા તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d110_61', districtId: 'd110', nameEn: '', nameGu: 'બાયડ બેતાલીસ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'સાબરકાંઠાના ગામો'),
    const DirectoryPargana(id: 'p_d110_62', districtId: 'd110', nameEn: '', nameGu: 'માલપરીયા વણકર પરગણું', type: 'SAMAJ', areaDescriptionGu: 'સાબરકાંઠા જીલ્લાના ગામો'),
    const DirectoryPargana(id: 'p_d110_63', districtId: 'd110', nameEn: '', nameGu: 'પાંત્રિસનું (૩૫) પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ઇડરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d110_64', districtId: 'd110', nameEn: '', nameGu: 'સોળનું (૧૬) પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ઇડરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d110_65', districtId: 'd110', nameEn: '', nameGu: 'ચૌદનું (૧૪) પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ઇડરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d110_66', districtId: 'd110', nameEn: '', nameGu: 'સત્તાવીસ (૨૭)નું પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ખેડબ્રહ્માનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d110_67', districtId: 'd110', nameEn: '', nameGu: 'બાવન (૫૨) શ્રી વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'પ્રાંતિજનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d110_68', districtId: 'd110', nameEn: '', nameGu: 'સત્તાવીસ (૨૭) પરગણું', type: 'SAMAJ', areaDescriptionGu: 'હિંમતનગરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d110_69', districtId: 'd110', nameEn: '', nameGu: 'સોબેસી પરગણા વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'વિજયનગરમહાલ (૧૬ ગામનો વિસ્તાર)'),
    const DirectoryPargana(id: 'p_d110_70', districtId: 'd110', nameEn: '', nameGu: 'સવાસો (૧૨૫) ગામનું પરગણું', type: 'SAMAJ', areaDescriptionGu: 'બાયડ તાલુકો અને કપડવંજના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d110_71', districtId: 'd110', nameEn: '', nameGu: 'પ્રણામીધર્મી પરગણું (અડા આઠમનું પરગણું)', type: 'SAMAJ', areaDescriptionGu: 'મોડાસાનો વિસ્તાર અને હિંમતનગરના કેટલાક ગામો'),
    const DirectoryPargana(id: 'p_d110_72', districtId: 'd110', nameEn: '', nameGu: 'આઠ (૦૮) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ભિલોડા'),
    const DirectoryPargana(id: 'p_d110_73', districtId: 'd110', nameEn: '', nameGu: 'બારીશ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ભિલોડા'),
    const DirectoryPargana(id: 'p_d111_74', districtId: 'd111', nameEn: '', nameGu: 'ધાંધાર વણકર જીલ્લો', type: 'SAMAJ', areaDescriptionGu: 'પાલનપુર અને વડગામનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d111_75', districtId: 'd111', nameEn: '', nameGu: 'મારવાડી વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'વાવ, થરાદ, ભાંભર અને ડીસાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d111_76', districtId: 'd111', nameEn: '', nameGu: 'પાંચ પાદર વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'પાલનપુરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d111_77', districtId: 'd111', nameEn: '', nameGu: 'નિયડ વણકર સમાજ (૩૨ ગામ)', type: 'SAMAJ', areaDescriptionGu: 'રાધનપુરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d111_78', districtId: 'd111', nameEn: '', nameGu: 'વઢિયાર વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સમીનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d111_79', districtId: 'd111', nameEn: '', nameGu: 'જતોડો વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સાંતલપુર અને હારીજના ગામો'),
    const DirectoryPargana(id: 'p_d112_80', districtId: 'd112', nameEn: '', nameGu: 'લખતર વણકર સમાજ (ગામ – ૧૨)', type: 'SAMAJ', areaDescriptionGu: 'લખતર'),
    const DirectoryPargana(id: 'p_d112_81', districtId: 'd112', nameEn: '', nameGu: 'ચોવીસી વણકર સમાજ (ગામ', type: 'SAMAJ', areaDescriptionGu: '૨૪) - મૂળી'),
    const DirectoryPargana(id: 'p_d112_82', districtId: 'd112', nameEn: '', nameGu: 'વઢવાણ મેરડી વણકર સમાજ (ગામ', type: 'SAMAJ', areaDescriptionGu: '૨૨) - વઢવાણ'),
    const DirectoryPargana(id: 'p_d112_83', districtId: 'd112', nameEn: '', nameGu: 'રણછોડ ભાયાથ વણકર સમાજ (ગામ – ૧૮)', type: 'SAMAJ', areaDescriptionGu: 'વઢવાણ'),
    const DirectoryPargana(id: 'p_d112_84', districtId: 'd112', nameEn: '', nameGu: 'ચુડા પરગણા વણકર સમાજ (ગામ – ૧૨)', type: 'SAMAJ', areaDescriptionGu: 'ચુડા'),
    const DirectoryPargana(id: 'p_d112_85', districtId: 'd112', nameEn: '', nameGu: 'ઝાલાવાડ વણકર સમાજ (ગામ – ૮૪)', type: 'SAMAJ', areaDescriptionGu: 'ધાંગધ્રા'),
    const DirectoryPargana(id: 'p_d112_86', districtId: 'd112', nameEn: '', nameGu: 'થાન ચોવીસી વણકર સમાજ (ગામ – ૨૪)', type: 'SAMAJ', areaDescriptionGu: 'ચોટીલા'),
    const DirectoryPargana(id: 'p_d112_87', districtId: 'd112', nameEn: '', nameGu: 'સાયલા વણકર સમાજ (ગામ – ૧૨)', type: 'SAMAJ', areaDescriptionGu: 'સાયલા'),
    const DirectoryPargana(id: 'p_d112_88', districtId: 'd112', nameEn: '', nameGu: 'ચોવીસ ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ધાંગધ્રા તાલુકાના રાજસીતાપુરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_89', districtId: 'd112', nameEn: '', nameGu: 'જતવાડ ૧૨ ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ચોટીલા તાલુકો'),
    const DirectoryPargana(id: 'p_d112_90', districtId: 'd112', nameEn: '', nameGu: 'સાયલા પાંચ ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'સાયલા તાલુકો'),
    const DirectoryPargana(id: 'p_d112_91', districtId: 'd112', nameEn: '', nameGu: 'થાન ત્રણ ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ચોટીલા તાલુકો'),
    const DirectoryPargana(id: 'p_d112_92', districtId: 'd112', nameEn: '', nameGu: 'પાટડી', type: 'SAMAJ', areaDescriptionGu: 'દશાડા (૬૨) બાાસઠ ગામ પરગણું - પાટડી, દશાડાનાં ગામો'),
    const DirectoryPargana(id: 'p_d112_93', districtId: 'd112', nameEn: '', nameGu: 'ભાદર કાંઠો', type: 'SAMAJ', areaDescriptionGu: 'લીમડી તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d112_94', districtId: 'd112', nameEn: '', nameGu: 'ચોર્માસી (૮૪) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'લીમડી તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d112_95', districtId: 'd112', nameEn: '', nameGu: 'બેંતાલીસ (૪૨) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ધાંગધ્રા અને હળવદ તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d112_96', districtId: 'd112', nameEn: '', nameGu: 'અઢાર (૧૮) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'સુરેન્દ્રનગર'),
    const DirectoryPargana(id: 'p_d112_97', districtId: 'd112', nameEn: '', nameGu: 'ચૌદ (૧૪) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'લખતર'),
    const DirectoryPargana(id: 'p_d112_98', districtId: 'd112', nameEn: '', nameGu: 'ચોવીસી (૨૪) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'જતવડ'),
    const DirectoryPargana(id: 'p_d112_99', districtId: 'd112', nameEn: '', nameGu: 'બાર (૧૨) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'છત્રિયાણા નો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_100', districtId: 'd112', nameEn: '', nameGu: 'એક (૦૧) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'ચુડાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_101', districtId: 'd112', nameEn: '', nameGu: 'પાંચ (૦૫) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'સાયલાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_102', districtId: 'd112', nameEn: '', nameGu: 'ત્રણ (૦૩) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'થાનનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_103', districtId: 'd112', nameEn: '', nameGu: 'બાણું (૯૨) ગામ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'પાટડી – દસાડ, ખારોપાટ વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_104', districtId: 'd112', nameEn: '', nameGu: 'અઢાર (૧૮)બાસઠ પરગણા વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ગઢડા તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_105', districtId: 'd112', nameEn: '', nameGu: 'ખારાપાટ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ગારિયાધાર અને સાવરકુંડલા તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d112_106', districtId: 'd112', nameEn: '', nameGu: 'નાગેર વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'અમરેલી'),
    const DirectoryPargana(id: 'p_d112_107', districtId: 'd112', nameEn: '', nameGu: 'સોરઠ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ધોરાજી'),
    const DirectoryPargana(id: 'p_d113_108', districtId: 'd113', nameEn: '', nameGu: 'બાર (૧૨) ગામ પરગણું (ગરપંથી)', type: 'SAMAJ', areaDescriptionGu: 'શિહોર તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d113_109', districtId: 'd113', nameEn: '', nameGu: 'કાંધાજી પરગણું (ગામ', type: 'SAMAJ', areaDescriptionGu: '૮૫) - પાલિયાણા અને ગારિયાધરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d113_110', districtId: 'd113', nameEn: '', nameGu: 'વાંછાંક પરગણું', type: 'SAMAJ', areaDescriptionGu: 'મહુધા, સાવરકુંડલા, તળાજા અને અમરેલી ના ગામો'),
    const DirectoryPargana(id: 'p_d113_111', districtId: 'd113', nameEn: '', nameGu: 'અઢાર અને બાસઠ પરગણું', type: 'SAMAJ', areaDescriptionGu: 'રાંધોડા, બોટાદ, ગારિયાધાર અને ઠસા તાલુકાના ગામો'),
    const DirectoryPargana(id: 'p_d113_112', districtId: 'd113', nameEn: '', nameGu: 'ઘોઘાબારા પરગણું', type: 'SAMAJ', areaDescriptionGu: 'શિહોર અને ઘોઘા તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d113_113', districtId: 'd113', nameEn: '', nameGu: 'સત્તાવીશ ભાદરકાંઠા વણકર સમાજ (૨૭ ગામ)', type: 'SAMAJ', areaDescriptionGu: 'બોટાદનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d113_114', districtId: 'd113', nameEn: '', nameGu: 'શ્રી લાઠિયા પરગણા ગુર્જર વણકર સમાજ (ગઢાળી ગોળ)', type: 'SAMAJ', areaDescriptionGu: 'ગઢડા, ગારિયાધર, ગઢાળી, વનાળી તેમજ અન્ય ગામો'),
    const DirectoryPargana(id: 'p_d113_115', districtId: 'd113', nameEn: '', nameGu: 'ગોહિલવાડ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ભાવનગર શહેર'),
    const DirectoryPargana(id: 'p_d114_116', districtId: 'd114', nameEn: '', nameGu: 'મેઘવાળ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જામનગર જીલ્લાનાં ગામો'),
    const DirectoryPargana(id: 'p_d114_117', districtId: 'd114', nameEn: '', nameGu: 'ગુર્જરા મેઘવાળ પરગણું/સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જામનગર જીલ્લાનાં ગામો'),
    const DirectoryPargana(id: 'p_d114_118', districtId: 'd114', nameEn: '', nameGu: 'સોરઠીયા મેઘવાળ પરગણું/સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જામનગર જીલ્લાનાં ગામો'),
    const DirectoryPargana(id: 'p_d114_119', districtId: 'd114', nameEn: '', nameGu: 'ચારણીયા મેઘવાળ પરગણું/સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જામનગર (લાલપુરા રોડ વિસ્તાર)'),
    const DirectoryPargana(id: 'p_d114_120', districtId: 'd114', nameEn: '', nameGu: 'મહેશ્વરી મેઘવાળ પરગણું/સમાજ', type: 'SAMAJ', areaDescriptionGu: 'કાલાવાડ, જોડીયા, ધ્રોલ, જામજોધપુરનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d114_121', districtId: 'd114', nameEn: '', nameGu: 'મારુ મેઘવાળ સમાજ', type: 'SAMAJ', areaDescriptionGu: 'હાલાર વિસ્તારના બાવન (૫૨) ગામો'),
    const DirectoryPargana(id: 'p_d114_122', districtId: 'd114', nameEn: '', nameGu: 'છત્રીસ ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જામનગર જીલ્લો'),
    const DirectoryPargana(id: 'p_d115_123', districtId: 'd115', nameEn: '', nameGu: 'કાંઠા ચોવીસી ગુર્જર સમાજ (ગામ : ૩૬)', type: 'SAMAJ', areaDescriptionGu: 'ભચાઉ અને અંજારનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d115_124', districtId: 'd115', nameEn: '', nameGu: 'ચોવીસી વણકર સમાજ (ગામ : ૧૨)', type: 'SAMAJ', areaDescriptionGu: 'રાપર તાલુકો'),
    const DirectoryPargana(id: 'p_d115_125', districtId: 'd115', nameEn: '', nameGu: 'કંઠી ચોવીસી વણકર સમાજ (ગામ : ૨૪)', type: 'SAMAJ', areaDescriptionGu: 'અંજારનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d115_126', districtId: 'd115', nameEn: '', nameGu: 'પાવર બત્રીસી વણકર સમાજ (ગામ : ૩૨)', type: 'SAMAJ', areaDescriptionGu: 'ભૂજ તાલુકો'),
    const DirectoryPargana(id: 'p_d115_127', districtId: 'd115', nameEn: '', nameGu: 'મેઘવંશી વણકર સમાજ (ગામ : ૨૫)', type: 'SAMAJ', areaDescriptionGu: 'મુન્દ્રા તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d115_128', districtId: 'd115', nameEn: '', nameGu: 'ભીમરાવ ગુર્જર વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'અંજાર તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d115_129', districtId: 'd115', nameEn: '', nameGu: 'દુધઈ ચોવીસી વણકર સમાજ (ગામ : ૧૨)', type: 'SAMAJ', areaDescriptionGu: 'અંજાર તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d115_130', districtId: 'd115', nameEn: '', nameGu: 'રાપર ચોવીસી ગુર્જર વણકર સમાજ (ગામ : ૨૦)', type: 'SAMAJ', areaDescriptionGu: 'રાપર તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d115_131', districtId: 'd115', nameEn: '', nameGu: 'વાગડ ચોવીસી વણકર સમાજ (ગામ – ૧૨)', type: 'SAMAJ', areaDescriptionGu: 'રાપર તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d115_132', districtId: 'd115', nameEn: '', nameGu: 'પરાથર ચોવીસી વણકર સમાજ (ગામ : ૨૦)', type: 'SAMAJ', areaDescriptionGu: 'ભચાઉ તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d116_133', districtId: 'd116', nameEn: '', nameGu: 'મોરબી', type: 'SAMAJ', areaDescriptionGu: 'માળિયા-ટંકારા તાલુકા વણકર સમાજ - મોરબી, માળિયા, ટંકારા તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d116_134', districtId: 'd116', nameEn: '', nameGu: 'વાંકાનેર તાલુકા વણકર સમાજ નાત', type: 'SAMAJ', areaDescriptionGu: 'વાંકાનેર તાલુકાનો વિસ્તાર'),
    const DirectoryPargana(id: 'p_d116_135', districtId: 'd116', nameEn: '', nameGu: 'કાઠિયાવાડ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'રાજકોટ, જામનગર, જૂનાગઢ'),
  ];

  final List<DirectoryTaluka> _mockTalukas = [
    const DirectoryTaluka(id: 't1', districtId: 'd1', nameEn: 'Ahmedabad City', nameGu: 'અમદાવાદ શહેર', sortOrder: 1),
    const DirectoryTaluka(id: 't2', districtId: 'd1', nameEn: 'Daskroi', nameGu: 'દસક્રોઇ', sortOrder: 2),
  ];

  final List<DirectoryLocation> _mockLocations = [
    const DirectoryLocation(id: 'l1', districtId: 'd1', talukaId: 't1', nameEn: 'Ahmedabad', nameGu: 'અમદાવાદ', type: 'CITY'),
  ];

  /// GET /directory/districts
  Future<List<DirectoryDistrict>> getDistricts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDistricts;
  }

  /// GET /directory/districts/:districtId/parganas
  Future<List<DirectoryPargana>> getParganasByDistrict(String districtId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockParganas.where((p) => p.districtId == districtId).toList();
  }

  /// GET /directory/locations/districts
  Future<List<DirectoryDistrict>> getLocationDistricts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDistricts; // Using same mock data for now
  }

  /// GET /directory/locations/districts/:districtId/talukas
  Future<List<DirectoryTaluka>> getTalukasByDistrict(String districtId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockTalukas.where((t) => t.districtId == districtId).toList();
  }

  /// GET /directory/locations/talukas/:talukaId/villages
  Future<List<DirectoryLocation>> getVillagesByTaluka(String talukaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockLocations.where((l) => l.talukaId == talukaId).toList();
  }
}
