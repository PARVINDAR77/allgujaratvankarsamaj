import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const parganaSeedData = [
  {
    name: 'સુરત પરજીયા માયાવંશી સમાજ',
    gujaratiName: 'સુરત પરજીયા માયાવંશી સમાજ',
    districtRegion: 'વલસાડ/સુરત',
    description: 'સુરત શહેર, નવસારી, વલસાડ'
  },
  {
    name: 'મયાવંશી સમાજ',
    gujaratiName: 'મયાવંશી સમાજ',
    districtRegion: 'વલસાડ/સુરત',
    description: 'સુરત શહેર અને સુરત જીલ્લાના ગામો'
  },
  {
    name: '૧૮ ગામ માયાવંશી સમાજ',
    gujaratiName: '૧૮ ગામ માયાવંશી સમાજ',
    districtRegion: 'વલસાડ/સુરત',
    description: 'સુરત જીલ્લાના કેટલાક ગામો'
  },
  {
    name: 'મોગ્રસીયા માયાવંશી સમાજ',
    gujaratiName: 'મોગ્રસીયા માયાવંશી સમાજ',
    districtRegion: 'વલસાડ/સુરત',
    description: 'સુરત જીલ્લાના કેટલાક ગામો'
  },
  {
    name: 'એક્સો પંચોતેર ગામ (૧૭૫) દેશી વણકર સમાજ',
    gujaratiName: 'એક્સો પંચોતેર ગામ (૧૭૫) દેશી વણકર સમાજ',
    districtRegion: 'ભરૂચ',
    description: 'ભરૂચ જીલ્લાના નાંદોદ, ભરૂચ, ડેડીયાપાડા, વાગરા, ઝઘડિયા, આમોદ તાલુકાના ગામો'
  },
  {
    name: 'બાણું (૯૨) ગામ વણકર સમાજ',
    gujaratiName: 'બાણું (૯૨) ગામ વણકર સમાજ',
    districtRegion: 'વડોદરા',
    description: 'જંબુસર અને પાદરા તાલુકાના કેટલાક ગામો'
  },
  {
    name: 'વાકળ પરગણુ',
    gujaratiName: 'વાકળ પરગણુ',
    districtRegion: 'વડોદરા',
    description: 'પાદરા તાલુકો'
  },
  {
    name: 'કાનમ પરગણુ',
    gujaratiName: 'કાનમ પરગણુ',
    districtRegion: 'વડોદરા',
    description: 'કરજણ તાલુકો'
  },
  {
    name: 'મેવાસ પરગણુ',
    gujaratiName: 'મેવાસ પરગણુ',
    districtRegion: 'વડોદરા',
    description: 'તિલકવાડા, સંખેડા, બાધરપુર તાલુકાના ગામો (નર્મદા જીલ્લો)'
  },
  {
    name: 'છોતેર પરગણુ',
    gujaratiName: 'છોતેર પરગણુ',
    districtRegion: 'વડોદરા',
    description: 'વાઘોડિયા તાલુકાના ગામો'
  },
  {
    name: 'બાણું (૯૨) ગામ પરગણું',
    gujaratiName: 'બાણું (૯૨) ગામ પરગણું',
    districtRegion: 'વડોદરા',
    description: 'જંબુસર તાલુકો'
  },
  {
    name: 'બાવન (૫૨) પરગણુ',
    gujaratiName: 'બાવન (૫૨) પરગણુ',
    districtRegion: 'વડોદરા',
    description: 'સાવલી તાલુકો'
  },
  {
    name: 'પાલ પરગણા વણકર સમાજ',
    gujaratiName: 'પાલ પરગણા વણકર સમાજ',
    districtRegion: 'વડોદરા',
    description: 'જબુગામ, જેતપુર અને પાવી તાલુકાના ગામો'
  },
  {
    name: 'રાજ પરગણું',
    gujaratiName: 'રાજ પરગણું',
    districtRegion: 'વડોદરા',
    description: 'રાજપીપળા (હવે નર્મદા જીલ્લો)'
  },
  {
    name: 'પીસ્તાલીસ ગામ વણકર સમાજ',
    gujaratiName: 'પીસ્તાલીસ ગામ વણકર સમાજ',
    districtRegion: 'વડોદરા',
    description: 'સાવલી અને વડોદરા તાલુકો'
  },
  {
    name: 'એકવીસ (૨૧) પરગણા વણકર સમાજ',
    gujaratiName: 'એકવીસ (૨૧) પરગણા વણકર સમાજ',
    districtRegion: 'વડોદરા',
    description: 'સંખેડા તલુકો'
  },
  {
    name: 'શિનોર પરગણા',
    gujaratiName: 'શિનોર પરગણા',
    districtRegion: 'વડોદરા',
    description: 'શિનોર, કરજણ'
  },
  {
    name: 'છયાસી (૮૬) ગામ વણકર પરગણું',
    gujaratiName: 'છયાસી (૮૬) ગામ વણકર પરગણું',
    districtRegion: 'આણંદ/ખેડા અને મહીસાગર',
    description: 'આંકલાવ, બોરસદ, પાદરા, ખંભાત, આણંદ અને વડોદરા તાલુકાના કેટલાક ગામો'
  },
  {
    name: 'ભાલ પરગણું',
    gujaratiName: 'ભાલ પરગણું',
    districtRegion: 'આણંદ/ખેડા અને મહીસાગર',
    description: 'ખંભાત તાલુકો'
  },
  {
    name: 'છાસઠ ગામ (દંઢયા) પરગણું',
    gujaratiName: 'છાસઠ ગામ (દંઢયા) પરગણું',
    districtRegion: 'આણંદ/ખેડા અને મહીસાગર',
    description: 'બોરસદ, આણંદ, પેટલાદ, સોજીત્રા અને તારાપુર તાલુકાના ગામો'
  },
  {
    name: 'સારસા વણકર સમાજ પરગણું',
    gujaratiName: 'સારસા વણકર સમાજ પરગણું',
    districtRegion: 'આણંદ/ખેડા અને મહીસાગર',
    description: 'આણંદ જીલ્લાના ગામો'
  },
  {
    name: 'ચરોતર વણકર સમાજ',
    gujaratiName: 'ચરોતર વણકર સમાજ',
    districtRegion: 'આણંદ/ખેડા અને મહીસાગર',
    description: 'ઓડ, ઉમરેઠ, નડીયાદ, આણંદ તાલુકાના કેટલાક ગામો'
  },
  {
    name: 'ચોયાસી વણકર સમાજ',
    gujaratiName: 'ચોયાસી વણકર સમાજ',
    districtRegion: 'આણંદ',
    description: 'નડિયાદ, ખેડાના ગામો'
  },
  {
    name: 'છાસઠ પરગણું (ડંઢયા) ૮૫ ગામ',
    gujaratiName: 'છાસઠ પરગણું (ડંઢયા) ૮૫ ગામ',
    districtRegion: 'આણંદ',
    description: 'ખંભાત તાલુકો, બોરસદ, આણંદ, માતર, સોજીત્રા'
  },
  {
    name: 'સપ્તકટ પરગણું',
    gujaratiName: 'સપ્તકટ પરગણું',
    districtRegion: 'આણંદ',
    description: 'ખંભાત તાલુકાના ગામો'
  },
  {
    name: 'છપ્પન ગામ પરગણું',
    gujaratiName: 'છપ્પન ગામ પરગણું',
    districtRegion: 'આણંદ',
    description: 'ડાકોર અને ઠાસરા તાલુકાના ગામો'
  },
  {
    name: 'નવ (૦૯) ગામ પરગણું',
    gujaratiName: 'નવ (૦૯) ગામ પરગણું',
    districtRegion: 'આણંદ',
    description: 'ઉમરેઠ વિસ્તારના ગામો'
  },
  {
    name: 'પંદર (૧૫) ગામ પરગણું',
    gujaratiName: 'પંદર (૧૫) ગામ પરગણું',
    districtRegion: 'આણંદ',
    description: 'મહુધા, કઠલાલ તાલુકો'
  },
  {
    name: 'પાલ પરગણા સમાજ',
    gujaratiName: 'પાલ પરગણા સમાજ',
    districtRegion: 'આણંદ',
    description: 'નડિયાદ – મહેમદાવાદ વચ્ચેના ગામો'
  },
  {
    name: '૪૨ (૨૫૨) ગામ વણકર સમાજ',
    gujaratiName: '૪૨ (૨૫૨) ગામ વણકર સમાજ',
    districtRegion: 'આણંદ',
    description: 'મહેમદાવાદ તાલુકોનાં ગામો'
  },
  {
    name: 'ખેડા (૦૯) ગામ વણકર સમાજ',
    gujaratiName: 'ખેડા (૦૯) ગામ વણકર સમાજ',
    districtRegion: 'આણંદ',
    description: 'મહેમદાવાદ, તા. બારેજડી'
  },
  {
    name: 'આઠ (૦૮) ગામ પરગણું',
    gujaratiName: 'આઠ (૦૮) ગામ પરગણું',
    districtRegion: 'આણંદ',
    description: 'મોડાસા તાલુકો'
  },
  {
    name: 'પંદર ગામ પરગણું',
    gujaratiName: 'પંદર ગામ પરગણું',
    districtRegion: 'આણંદ',
    description: 'મહુધા અને કઠલાલ તાલુકો.'
  },
  {
    name: 'બાર (૧૨) ગામ પરગણુ',
    gujaratiName: 'બાર (૧૨) ગામ પરગણુ',
    districtRegion: 'આણંદ',
    description: 'સેવાલિયા અને બાલાસિનોર'
  },
  {
    name: 'બાવીસો પરગણું',
    gujaratiName: 'બાવીસો પરગણું',
    districtRegion: 'આણંદ',
    description: 'કપડવંજ તાલુકાના કેટલાક ગામો'
  },
  {
    name: 'ચોયાસી (૩૦ ગામ) પરગણું',
    gujaratiName: 'ચોયાસી (૩૦ ગામ) પરગણું',
    districtRegion: 'આણંદ',
    description: 'કપડવંજ તાલુકાના ગામો'
  },
  {
    name: 'આંબલીયા બારનું પરગણું',
    gujaratiName: 'આંબલીયા બારનું પરગણું',
    districtRegion: 'આણંદ',
    description: 'બાયડ તાલુકાના ગામો (અરવલ્લી જીલ્લો)'
  },
  {
    name: '૪૭ ગામ વણકર સમાજ',
    gujaratiName: '૪૭ ગામ વણકર સમાજ',
    districtRegion: 'આણંદ',
    description: 'અરવલ્લી જીલ્લો'
  },
  {
    name: 'બાવન (૫૨) ગામ તોરણ પરગણું',
    gujaratiName: 'બાવન (૫૨) ગામ તોરણ પરગણું',
    districtRegion: 'આણંદ',
    description: 'કપડવંજ તાલુકાના ગામો'
  },
  {
    name: 'બાવીસ ગામ પરગણા સમાજ',
    gujaratiName: 'બાવીસ ગામ પરગણા સમાજ',
    districtRegion: 'કપડવંજ અને બાયડ તાલુકો',
    description: 'મોડાસા પ્રાંતિજ (હવે અરવલ્લી જીલ્લો)'
  },
  {
    name: 'અડઠ ભારીશ પ્રણામી પરગણું (૬૦ ગામો)',
    gujaratiName: 'અડઠ ભારીશ પ્રણામી પરગણું (૬૦ ગામો)',
    districtRegion: 'કપડવંજ અને બાયડ તાલુકો',
    description: 'મોડાસા, હિંમતનગર, ભિલોડા તાલુકો'
  },
  {
    name: 'ચોવીસી ગામ વણકર સમાજ',
    gujaratiName: 'ચોવીસી ગામ વણકર સમાજ',
    districtRegion: 'કપડવંજ અને બાયડ તાલુકો',
    description: 'વીરપુર તાલુકો – મહીસાગર જીલ્લો'
  },
  {
    name: 'નવ (૦૯) પંચ વણકર સમાજ',
    gujaratiName: 'નવ (૦૯) પંચ વણકર સમાજ',
    districtRegion: 'કપડવંજ અને બાયડ તાલુકો',
    description: 'બાલાશિનોર તાલુકો – મહીસાગર જીલ્લો'
  },
  {
    name: 'પાંચ (૦૫) પરગણા',
    gujaratiName: 'પાંચ (૦૫) પરગણા',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'લુણાવાડા તાલુકો – મહીસાગર જીલ્લો'
  },
  {
    name: 'કપડવંજ (૧૨૫) સવાસો ગામ',
    gujaratiName: 'કપડવંજ (૧૨૫) સવાસો ગામ',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'કપડવંજ તલુકો – મહીસાગર જીલ્લો'
  },
  {
    name: 'પ્રણામી વણકર સમાજ',
    gujaratiName: 'પ્રણામી વણકર સમાજ',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'મોડાસા, માલપુર તાલુકો, દાહોદ જીલ્લો'
  },
  {
    name: 'પાંચ (૦૫) ગામ પરગણું',
    gujaratiName: 'પાંચ (૦૫) ગામ પરગણું',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'દાહોદ તાલુકો'
  },
  {
    name: 'પંદર (૧૫) ગામ પરગણું',
    gujaratiName: 'પંદર (૧૫) ગામ પરગણું',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'લીમખેડા તાલુકો'
  },
  {
    name: 'સત્તર (૧૭) ગામ પરગણું',
    gujaratiName: 'સત્તર (૧૭) ગામ પરગણું',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'દેવગઢબારીયા તાલુકો'
  },
  {
    name: 'નવ (૦૯) ગામ પરગણું',
    gujaratiName: 'નવ (૦૯) ગામ પરગણું',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'ધાનપુર તાલુકો'
  },
  {
    name: 'પાંચ (૦૫) ગામ પરગણું',
    gujaratiName: 'પાંચ (૦૫) ગામ પરગણું',
    districtRegion: 'બાલાશિનોર તાલુકાના ગામો',
    description: 'શંઘોડ તાલુકો'
  },
  {
    name: 'પીસ્તાલીસ (૪૫) ગામ પરગણું',
    gujaratiName: 'પીસ્તાલીસ (૪૫) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'ગોધરા અને શહેરા તાલુકો'
  },
  {
    name: 'સોળ (૧૬) ગામ પરગણું',
    gujaratiName: 'સોળ (૧૬) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'શહેરા તાલુકો'
  },
  {
    name: 'સાવલી (૧૬) સોળ ગામ પરગણું',
    gujaratiName: 'સાવલી (૧૬) સોળ ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'લુણાવાડા તાલુકો (હવે મહીસાગર જીલ્લો)'
  },
  {
    name: 'તોંતેર (૭૩) ગામ પરગણું',
    gujaratiName: 'તોંતેર (૭૩) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'લુણાવાડા (હવે મહીસાગર જીલ્લો)'
  },
  {
    name: 'સુડતાલીસ (૪૭) ગામ પરગણું',
    gujaratiName: 'સુડતાલીસ (૪૭) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'બાલાશિનોર (હવે મહીસાગર જીલ્લો)'
  },
  {
    name: 'સાત (૦૭) ગામ પરગણું',
    gujaratiName: 'સાત (૦૭) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'વિરપુર, લુણાવાડા, બાલાશિનોર (મહીસાગર જીલ્લો)'
  },
  {
    name: 'સોળ (૧૬) ગામ પરગણું',
    gujaratiName: 'સોળ (૧૬) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'સંતરામપુર'
  },
  {
    name: 'છત્રીસ (૩૬) ગામ પરગણું',
    gujaratiName: 'છત્રીસ (૩૬) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'હાલોલ'
  },
  {
    name: 'પાંચસો (૫૦૦) ગામ પરગણું',
    gujaratiName: 'પાંચસો (૫૦૦) ગામ પરગણું',
    districtRegion: 'પંચમહાલ (ગોધરા) / મહીસાગર તલુકો',
    description: 'મોરવા હડફ, ગોધરા અને બારિયા તાલુકાનો વિસ્તાર'
  },
  {
    name: 'બાયડ બેતાલીસ પરગણું',
    gujaratiName: 'બાયડ બેતાલીસ પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'સાબરકાંઠાના ગામો'
  },
  {
    name: 'માલપરીયા વણકર પરગણું',
    gujaratiName: 'માલપરીયા વણકર પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'સાબરકાંઠા જીલ્લાના ગામો'
  },
  {
    name: 'પાંત્રિસનું (૩૫) પરગણું',
    gujaratiName: 'પાંત્રિસનું (૩૫) પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'ઇડરનો વિસ્તાર'
  },
  {
    name: 'સોળનું (૧૬) પરગણું',
    gujaratiName: 'સોળનું (૧૬) પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'ઇડરનો વિસ્તાર'
  },
  {
    name: 'ચૌદનું (૧૪) પરગણું',
    gujaratiName: 'ચૌદનું (૧૪) પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'ઇડરનો વિસ્તાર'
  },
  {
    name: 'સત્તાવીસ (૨૭)નું પરગણું',
    gujaratiName: 'સત્તાવીસ (૨૭)નું પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'ખેડબ્રહ્માનો વિસ્તાર'
  },
  {
    name: 'બાવન (૫૨) શ્રી વણકર સમાજ',
    gujaratiName: 'બાવન (૫૨) શ્રી વણકર સમાજ',
    districtRegion: 'સાબરકાંઠા',
    description: 'પ્રાંતિજનો વિસ્તાર'
  },
  {
    name: 'સત્તાવીસ (૨૭) પરગણું',
    gujaratiName: 'સત્તાવીસ (૨૭) પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'હિંમતનગરનો વિસ્તાર'
  },
  {
    name: 'સોબેસી પરગણા વણકર સમાજ',
    gujaratiName: 'સોબેસી પરગણા વણકર સમાજ',
    districtRegion: 'સાબરકાંઠા',
    description: 'વિજયનગરમહાલ (૧૬ ગામનો વિસ્તાર)'
  },
  {
    name: 'સવાસો (૧૨૫) ગામનું પરગણું',
    gujaratiName: 'સવાસો (૧૨૫) ગામનું પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'બાયડ તાલુકો અને કપડવંજના કેટલાક ગામો'
  },
  {
    name: 'પ્રણામીધર્મી પરગણું (અડા આઠમનું પરગણું)',
    gujaratiName: 'પ્રણામીધર્મી પરગણું (અડા આઠમનું પરગણું)',
    districtRegion: 'સાબરકાંઠા',
    description: 'મોડાસાનો વિસ્તાર અને હિંમતનગરના કેટલાક ગામો'
  },
  {
    name: 'આઠ (૦૮) ગામ પરગણું',
    gujaratiName: 'આઠ (૦૮) ગામ પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'ભિલોડા'
  },
  {
    name: 'બારીશ પરગણું',
    gujaratiName: 'બારીશ પરગણું',
    districtRegion: 'સાબરકાંઠા',
    description: 'ભિલોડા'
  },
  {
    name: 'ધાંધાર વણકર જીલ્લો',
    gujaratiName: 'ધાંધાર વણકર જીલ્લો',
    districtRegion: 'બનાસકાંઠા',
    description: 'પાલનપુર અને વડગામનો વિસ્તાર'
  },
  {
    name: 'મારવાડી વણકર સમાજ',
    gujaratiName: 'મારવાડી વણકર સમાજ',
    districtRegion: 'બનાસકાંઠા',
    description: 'વાવ, થરાદ, ભાંભર અને ડીસાનો વિસ્તાર'
  },
  {
    name: 'પાંચ પાદર વણકર સમાજ',
    gujaratiName: 'પાંચ પાદર વણકર સમાજ',
    districtRegion: 'બનાસકાંઠા',
    description: 'પાલનપુરનો વિસ્તાર'
  },
  {
    name: 'નિયડ વણકર સમાજ (૩૨ ગામ)',
    gujaratiName: 'નિયડ વણકર સમાજ (૩૨ ગામ)',
    districtRegion: 'બનાસકાંઠા',
    description: 'રાધનપુરનો વિસ્તાર'
  },
  {
    name: 'વઢિયાર વણકર સમાજ',
    gujaratiName: 'વઢિયાર વણકર સમાજ',
    districtRegion: 'બનાસકાંઠા',
    description: 'સમીનો વિસ્તાર'
  },
  {
    name: 'જતોડો વણકર સમાજ',
    gujaratiName: 'જતોડો વણકર સમાજ',
    districtRegion: 'બનાસકાંઠા',
    description: 'સાંતલપુર અને હારીજના ગામો'
  },
  {
    name: 'લખતર વણકર સમાજ (ગામ – ૧૨)',
    gujaratiName: 'લખતર વણકર સમાજ (ગામ – ૧૨)',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'લખતર'
  },
  {
    name: 'ચોવીસી વણકર સમાજ (ગામ',
    gujaratiName: 'ચોવીસી વણકર સમાજ (ગામ',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: '૨૪) - મૂળી'
  },
  {
    name: 'વઢવાણ મેરડી વણકર સમાજ (ગામ',
    gujaratiName: 'વઢવાણ મેરડી વણકર સમાજ (ગામ',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: '૨૨) - વઢવાણ'
  },
  {
    name: 'રણછોડ ભાયાથ વણકર સમાજ (ગામ – ૧૮)',
    gujaratiName: 'રણછોડ ભાયાથ વણકર સમાજ (ગામ – ૧૮)',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'વઢવાણ'
  },
  {
    name: 'ચુડા પરગણા વણકર સમાજ (ગામ – ૧૨)',
    gujaratiName: 'ચુડા પરગણા વણકર સમાજ (ગામ – ૧૨)',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ચુડા'
  },
  {
    name: 'ઝાલાવાડ વણકર સમાજ (ગામ – ૮૪)',
    gujaratiName: 'ઝાલાવાડ વણકર સમાજ (ગામ – ૮૪)',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ધાંગધ્રા'
  },
  {
    name: 'થાન ચોવીસી વણકર સમાજ (ગામ – ૨૪)',
    gujaratiName: 'થાન ચોવીસી વણકર સમાજ (ગામ – ૨૪)',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ચોટીલા'
  },
  {
    name: 'સાયલા વણકર સમાજ (ગામ – ૧૨)',
    gujaratiName: 'સાયલા વણકર સમાજ (ગામ – ૧૨)',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'સાયલા'
  },
  {
    name: 'ચોવીસ ગામ પરગણું',
    gujaratiName: 'ચોવીસ ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ધાંગધ્રા તાલુકાના રાજસીતાપુરનો વિસ્તાર'
  },
  {
    name: 'જતવાડ ૧૨ ગામ પરગણું',
    gujaratiName: 'જતવાડ ૧૨ ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ચોટીલા તાલુકો'
  },
  {
    name: 'સાયલા પાંચ ગામ પરગણું',
    gujaratiName: 'સાયલા પાંચ ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'સાયલા તાલુકો'
  },
  {
    name: 'થાન ત્રણ ગામ પરગણું',
    gujaratiName: 'થાન ત્રણ ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ચોટીલા તાલુકો'
  },
  {
    name: 'પાટડી',
    gujaratiName: 'પાટડી',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'દશાડા (૬૨) બાાસઠ ગામ પરગણું - પાટડી, દશાડાનાં ગામો'
  },
  {
    name: 'ભાદર કાંઠો',
    gujaratiName: 'ભાદર કાંઠો',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'લીમડી તાલુકાના ગામો'
  },
  {
    name: 'ચોર્માસી (૮૪) ગામ પરગણું',
    gujaratiName: 'ચોર્માસી (૮૪) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'લીમડી તાલુકાના ગામો'
  },
  {
    name: 'બેંતાલીસ (૪૨) ગામ પરગણું',
    gujaratiName: 'બેંતાલીસ (૪૨) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ધાંગધ્રા અને હળવદ તાલુકાના ગામો'
  },
  {
    name: 'અઢાર (૧૮) ગામ પરગણું',
    gujaratiName: 'અઢાર (૧૮) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'સુરેન્દ્રનગર'
  },
  {
    name: 'ચૌદ (૧૪) ગામ પરગણું',
    gujaratiName: 'ચૌદ (૧૪) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'લખતર'
  },
  {
    name: 'ચોવીસી (૨૪) ગામ પરગણું',
    gujaratiName: 'ચોવીસી (૨૪) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'જતવડ'
  },
  {
    name: 'બાર (૧૨) ગામ પરગણું',
    gujaratiName: 'બાર (૧૨) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'છત્રિયાણા નો વિસ્તાર'
  },
  {
    name: 'એક (૦૧) ગામ પરગણું',
    gujaratiName: 'એક (૦૧) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ચુડાનો વિસ્તાર'
  },
  {
    name: 'પાંચ (૦૫) ગામ પરગણું',
    gujaratiName: 'પાંચ (૦૫) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'સાયલાનો વિસ્તાર'
  },
  {
    name: 'ત્રણ (૦૩) ગામ પરગણું',
    gujaratiName: 'ત્રણ (૦૩) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'થાનનો વિસ્તાર'
  },
  {
    name: 'બાણું (૯૨) ગામ પરગણું',
    gujaratiName: 'બાણું (૯૨) ગામ પરગણું',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'પાટડી – દસાડ, ખારોપાટ વિસ્તાર'
  },
  {
    name: 'અઢાર (૧૮)બાસઠ પરગણા વણકર સમાજ',
    gujaratiName: 'અઢાર (૧૮)બાસઠ પરગણા વણકર સમાજ',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ગઢડા તાલુકાનો વિસ્તાર'
  },
  {
    name: 'ખારાપાટ વણકર સમાજ',
    gujaratiName: 'ખારાપાટ વણકર સમાજ',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ગારિયાધાર અને સાવરકુંડલા તાલુકાનો વિસ્તાર'
  },
  {
    name: 'નાગેર વણકર સમાજ',
    gujaratiName: 'નાગેર વણકર સમાજ',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'અમરેલી'
  },
  {
    name: 'સોરઠ વણકર સમાજ',
    gujaratiName: 'સોરઠ વણકર સમાજ',
    districtRegion: 'સુરેન્દ્રનગર અને આસપાસનો વિસ્તાર',
    description: 'ધોરાજી'
  },
  {
    name: 'બાર (૧૨) ગામ પરગણું (ગરપંથી)',
    gujaratiName: 'બાર (૧૨) ગામ પરગણું (ગરપંથી)',
    districtRegion: 'ભાવનગર',
    description: 'શિહોર તાલુકાના ગામો'
  },
  {
    name: 'કાંધાજી પરગણું (ગામ',
    gujaratiName: 'કાંધાજી પરગણું (ગામ',
    districtRegion: 'ભાવનગર',
    description: '૮૫) - પાલિયાણા અને ગારિયાધરનો વિસ્તાર'
  },
  {
    name: 'વાંછાંક પરગણું',
    gujaratiName: 'વાંછાંક પરગણું',
    districtRegion: 'ભાવનગર',
    description: 'મહુધા, સાવરકુંડલા, તળાજા અને અમરેલી ના ગામો'
  },
  {
    name: 'અઢાર અને બાસઠ પરગણું',
    gujaratiName: 'અઢાર અને બાસઠ પરગણું',
    districtRegion: 'ભાવનગર',
    description: 'રાંધોડા, બોટાદ, ગારિયાધાર અને ઠસા તાલુકાના ગામો'
  },
  {
    name: 'ઘોઘાબારા પરગણું',
    gujaratiName: 'ઘોઘાબારા પરગણું',
    districtRegion: 'ભાવનગર',
    description: 'શિહોર અને ઘોઘા તાલુકાનો વિસ્તાર'
  },
  {
    name: 'સત્તાવીશ ભાદરકાંઠા વણકર સમાજ (૨૭ ગામ)',
    gujaratiName: 'સત્તાવીશ ભાદરકાંઠા વણકર સમાજ (૨૭ ગામ)',
    districtRegion: 'ભાવનગર',
    description: 'બોટાદનો વિસ્તાર'
  },
  {
    name: 'શ્રી લાઠિયા પરગણા ગુર્જર વણકર સમાજ (ગઢાળી ગોળ)',
    gujaratiName: 'શ્રી લાઠિયા પરગણા ગુર્જર વણકર સમાજ (ગઢાળી ગોળ)',
    districtRegion: 'ભાવનગર',
    description: 'ગઢડા, ગારિયાધર, ગઢાળી, વનાળી તેમજ અન્ય ગામો'
  },
  {
    name: 'ગોહિલવાડ વણકર સમાજ',
    gujaratiName: 'ગોહિલવાડ વણકર સમાજ',
    districtRegion: 'ભાવનગર',
    description: 'ભાવનગર શહેર'
  },
  {
    name: 'મેઘવાળ વણકર સમાજ',
    gujaratiName: 'મેઘવાળ વણકર સમાજ',
    districtRegion: 'જામનગર',
    description: 'જામનગર જીલ્લાનાં ગામો'
  },
  {
    name: 'ગુર્જરા મેઘવાળ પરગણું/સમાજ',
    gujaratiName: 'ગુર્જરા મેઘવાળ પરગણું/સમાજ',
    districtRegion: 'જામનગર',
    description: 'જામનગર જીલ્લાનાં ગામો'
  },
  {
    name: 'સોરઠીયા મેઘવાળ પરગણું/સમાજ',
    gujaratiName: 'સોરઠીયા મેઘવાળ પરગણું/સમાજ',
    districtRegion: 'જામનગર',
    description: 'જામનગર જીલ્લાનાં ગામો'
  },
  {
    name: 'ચારણીયા મેઘવાળ પરગણું/સમાજ',
    gujaratiName: 'ચારણીયા મેઘવાળ પરગણું/સમાજ',
    districtRegion: 'જામનગર',
    description: 'જામનગર (લાલપુરા રોડ વિસ્તાર)'
  },
  {
    name: 'મહેશ્વરી મેઘવાળ પરગણું/સમાજ',
    gujaratiName: 'મહેશ્વરી મેઘવાળ પરગણું/સમાજ',
    districtRegion: 'જામનગર',
    description: 'કાલાવાડ, જોડીયા, ધ્રોલ, જામજોધપુરનો વિસ્તાર'
  },
  {
    name: 'મારુ મેઘવાળ સમાજ',
    gujaratiName: 'મારુ મેઘવાળ સમાજ',
    districtRegion: 'જામનગર',
    description: 'હાલાર વિસ્તારના બાવન (૫૨) ગામો'
  },
  {
    name: 'છત્રીસ ગામ વણકર સમાજ',
    gujaratiName: 'છત્રીસ ગામ વણકર સમાજ',
    districtRegion: 'જામનગર',
    description: 'જામનગર જીલ્લો'
  },
  {
    name: 'કાંઠા ચોવીસી ગુર્જર સમાજ (ગામ : ૩૬)',
    gujaratiName: 'કાંઠા ચોવીસી ગુર્જર સમાજ (ગામ : ૩૬)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'ભચાઉ અને અંજારનો વિસ્તાર'
  },
  {
    name: 'ચોવીસી વણકર સમાજ (ગામ : ૧૨)',
    gujaratiName: 'ચોવીસી વણકર સમાજ (ગામ : ૧૨)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'રાપર તાલુકો'
  },
  {
    name: 'કંઠી ચોવીસી વણકર સમાજ (ગામ : ૨૪)',
    gujaratiName: 'કંઠી ચોવીસી વણકર સમાજ (ગામ : ૨૪)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'અંજારનો વિસ્તાર'
  },
  {
    name: 'પાવર બત્રીસી વણકર સમાજ (ગામ : ૩૨)',
    gujaratiName: 'પાવર બત્રીસી વણકર સમાજ (ગામ : ૩૨)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'ભૂજ તાલુકો'
  },
  {
    name: 'મેઘવંશી વણકર સમાજ (ગામ : ૨૫)',
    gujaratiName: 'મેઘવંશી વણકર સમાજ (ગામ : ૨૫)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'મુન્દ્રા તાલુકાનો વિસ્તાર'
  },
  {
    name: 'ભીમરાવ ગુર્જર વણકર સમાજ',
    gujaratiName: 'ભીમરાવ ગુર્જર વણકર સમાજ',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'અંજાર તાલુકાનો વિસ્તાર'
  },
  {
    name: 'દુધઈ ચોવીસી વણકર સમાજ (ગામ : ૧૨)',
    gujaratiName: 'દુધઈ ચોવીસી વણકર સમાજ (ગામ : ૧૨)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'અંજાર તાલુકાનો વિસ્તાર'
  },
  {
    name: 'રાપર ચોવીસી ગુર્જર વણકર સમાજ (ગામ : ૨૦)',
    gujaratiName: 'રાપર ચોવીસી ગુર્જર વણકર સમાજ (ગામ : ૨૦)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'રાપર તાલુકાનો વિસ્તાર'
  },
  {
    name: 'વાગડ ચોવીસી વણકર સમાજ (ગામ – ૧૨)',
    gujaratiName: 'વાગડ ચોવીસી વણકર સમાજ (ગામ – ૧૨)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'રાપર તાલુકાનો વિસ્તાર'
  },
  {
    name: 'પરાથર ચોવીસી વણકર સમાજ (ગામ : ૨૦)',
    gujaratiName: 'પરાથર ચોવીસી વણકર સમાજ (ગામ : ૨૦)',
    districtRegion: 'કચ્છ – ભુજ તાલુકો',
    description: 'ભચાઉ તાલુકાનો વિસ્તાર'
  },
  {
    name: 'મોરબી',
    gujaratiName: 'મોરબી',
    districtRegion: 'રાજકોટ/મોરબી',
    description: 'માળિયા-ટંકારા તાલુકા વણકર સમાજ - મોરબી, માળિયા, ટંકારા તાલુકાનો વિસ્તાર'
  },
  {
    name: 'વાંકાનેર તાલુકા વણકર સમાજ નાત',
    gujaratiName: 'વાંકાનેર તાલુકા વણકર સમાજ નાત',
    districtRegion: 'રાજકોટ/મોરબી',
    description: 'વાંકાનેર તાલુકાનો વિસ્તાર'
  },
  {
    name: 'કાઠિયાવાડ વણકર સમાજ',
    gujaratiName: 'કાઠિયાવાડ વણકર સમાજ',
    districtRegion: 'રાજકોટ/મોરબી',
    description: 'રાજકોટ, જામનગર, જૂનાગઢ'
  },
];


async function main() {
  console.log('Seeding ' + parganaSeedData.length + ' Parganas...');
  for (const p of parganaSeedData) {
    await prisma.pargana.upsert({
      where: { code: p.name },
      update: {},
      create: {
        name: p.name,
        gujaratiName: p.gujaratiName,
        districtRegion: p.districtRegion,
        description: p.description,
        code: p.name,
      }
    });
  }
  console.log('Parganas seeded successfully!');
}

main().catch(e => {
  console.error(e);
  process.exit(1);
}).finally(async () => {
  await prisma.$disconnect();
});
