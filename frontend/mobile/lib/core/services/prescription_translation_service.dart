import 'package:mobile/core/storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrescriptionTranslationService {
  static final Map<String, Map<String, String>> _titleTranslations = {
    // Temperature management
    'Manage high temperature stress': {
      'en': 'Manage high temperature stress',
      'tl': 'Pamahalaan ang stress sa mataas na temperatura',
    },
    'Adjust plant spacing for better light penetration': {
      'en': 'Adjust plant spacing for better light penetration',
      'tl': 'Ayusin ang pagitan ng mga halaman para sa mas mabuting pagpasok ng liwanag',
    },
    'Provide shade during peak heat hours': {
      'en': 'Provide shade during peak heat hours',
      'tl': 'Magbigay ng lilim sa mga oras ng matinding init',
    },
    'Increase ventilation': {
      'en': 'Increase ventilation',
      'tl': 'Dagdagan ang bentilasyon',
    },
    
    // Water management
    'Adjust irrigation schedule': {
      'en': 'Adjust irrigation schedule',
      'tl': 'Ayusin ang iskedyul ng irigasyon',
    },
    'Increase watering frequency': {
      'en': 'Increase watering frequency',
      'tl': 'Dagdagan ang dalas ng pagdidilig',
    },
    'Reduce watering frequency': {
      'en': 'Reduce watering frequency',
      'tl': 'Bawasan ang dalas ng pagdidilig',
    },
    'Check drainage system': {
      'en': 'Check drainage system',
      'tl': 'Suriin ang sistema ng daluyan ng tubig',
    },
    
    // Soil management
    'Apply soil treatment': {
      'en': 'Apply soil treatment',
      'tl': 'Maglagay ng paggamot sa lupa',
    },
    'Apply organic fertilizer': {
      'en': 'Apply organic fertilizer',
      'tl': 'Maglagay ng organikong pataba',
    },
    'Adjust soil pH': {
      'en': 'Adjust soil pH',
      'tl': 'Ayusin ang pH ng lupa',
    },
    'Improve soil drainage': {
      'en': 'Improve soil drainage',
      'tl': 'Pabutihin ang daluyan ng tubig sa lupa',
    },
    
    // Humidity and environment
    'Monitor humidity levels': {
      'en': 'Monitor humidity levels',
      'tl': 'Subaybayan ang antas ng halumigmig',
    },
    'Increase humidity': {
      'en': 'Increase humidity',
      'tl': 'Dagdagan ang halumigmig',
    },
    'Decrease humidity': {
      'en': 'Decrease humidity',
      'tl': 'Bawasan ang halumigmig',
    },
    
    // Light management
    'Adjust light exposure': {
      'en': 'Adjust light exposure',
      'tl': 'Ayusin ang pagkakalantad sa liwanag',
    },
    'Increase light exposure': {
      'en': 'Increase light exposure',
      'tl': 'Dagdagan ang pagkakalantad sa liwanag',
    },
    'Reduce light exposure': {
      'en': 'Reduce light exposure',
      'tl': 'Bawasan ang pagkakalantad sa liwanag',
    },
    
    // Pest and disease management
    'Apply pest control': {
      'en': 'Apply pest control',
      'tl': 'Maglagay ng pestisidyo',
    },
    'Check for diseases': {
      'en': 'Check for diseases',
      'tl': 'Suriin ang mga sakit',
    },
    'Remove infected plants': {
      'en': 'Remove infected plants',
      'tl': 'Alisin ang mga nahawaang halaman',
    },
    
    // General maintenance
    'Prune plants': {
      'en': 'Prune plants',
      'tl': 'Mag-prune ng mga halaman',
    },
    'Harvest crops': {
      'en': 'Harvest crops',
      'tl': 'Mag-ani ng mga pananim',
    },
    'Check plant health': {
      'en': 'Check plant health',
      'tl': 'Suriin ang kalusugan ng mga halaman',
    },
    'Monitor growth progress': {
      'en': 'Monitor growth progress',
      'tl': 'Subaybayan ang paglaki',
    },
    
    // Temperature management prescriptions
    'Protect from cold stress': {
      'en': 'Protect from cold stress',
      'tl': 'Protektahan mula sa stress sa lamig',
    },
    'Increase humidity for optimal plant growth': {
      'en': 'Increase humidity for optimal plant growth',
      'tl': 'Dagdagan ang halumigmig para sa optimal na paglaki ng halaman',
    },
    'Reduce humidity to prevent disease': {
      'en': 'Reduce humidity to prevent disease',
      'tl': 'Bawasan ang halumigmig upang maiwasan ang sakit',
    },
    
    // Water management prescriptions
    'URGENT: Irrigate immediately': {
      'en': 'URGENT: Irrigate immediately',
      'tl': 'KAGIPITAN: Mag-irrigate kaagad',
    },
    'Increase irrigation frequency': {
      'en': 'Increase irrigation frequency',
      'tl': 'Dagdagan ang dalas ng irigasyon',
    },
    'Improve drainage to prevent waterlogging': {
      'en': 'Improve drainage to prevent waterlogging',
      'tl': 'Mapabuti ang daluyan ng tubig upang maiwasan ang pagbabaha',
    },
    
    // Soil management prescriptions
    'Apply lime to increase soil pH': {
      'en': 'Apply lime to increase soil pH',
      'tl': 'Maglagay ng apog upang taasan ang pH ng lupa',
    },
    'Apply sulfur to decrease soil pH': {
      'en': 'Apply sulfur to decrease soil pH',
      'tl': 'Maglagay ng asupre upang babaan ang pH ng lupa',
    },
    
    // Growth stage specific prescriptions
    'Ensure proper emergence and early growth': {
      'en': 'Ensure proper emergence and early growth',
      'tl': 'Siguraduhin ang tamang pagsibol at maagang paglaki',
    },
    'Early vegetative growth management': {
      'en': 'Early vegetative growth management',
      'tl': 'Pamamahala sa maagang paglaking vegetatibo',
    },
    'CRITICAL: Reproductive stage management': {
      'en': 'CRITICAL: Reproductive stage management',
      'tl': 'KAGIPITAN: Pamamahala sa reproduktibong yugto',
    },
    
    // Pest and disease management
    'Pest monitoring and control for {growth_stage} stage': {
      'en': 'Pest monitoring and control for {growth_stage} stage',
      'tl': 'Pagsubaybay at kontrol sa peste para sa yugto ng {growth_stage}',
    },
    'Disease prevention for {growth_stage} stage': {
      'en': 'Disease prevention for {growth_stage} stage',
      'tl': 'Pag-iwas sa sakit para sa yugto ng {growth_stage}',
    },
    
    // Fertilizer management
    'Fertilizer application for {growth_stage} stage': {
      'en': 'Fertilizer application for {growth_stage} stage',
      'tl': 'Paglalagay ng pataba para sa yugto ng {growth_stage}',
    },
    
    // General monitoring
    'Continue regular monitoring and maintenance': {
      'en': 'Continue regular monitoring and maintenance',
      'tl': 'Magpatuloy sa regular na pagsubaybay at pagpapanatili',
    },
    
    // Field names
    'Field Durant': {
      'en': 'Field Durant',
      'tl': 'Field Durant',
    },
    '02 PROTO': {
      'en': '02 PROTO',
      'tl': '02 PROTO',
    },
  };

  // Detailed instruction translations for step-by-step guidance
  static final Map<String, Map<String, List<String>>> _instructionTranslations = {
    // Temperature management instructions
    'Manage high temperature stress': {
      'en': [
        '1. Increase irrigation frequency to 2-3 times daily',
        '2. Apply mulch around plants to reduce soil temperature',
        '3. Consider temporary shade structures if temperature exceeds 35°C',
        '4. Monitor soil moisture closely - high temperatures increase water demand',
        '5. Avoid fertilizer application during peak heat hours (10 AM - 3 PM)',
        '6. Check for heat stress symptoms: wilting, leaf curling, stunted growth'
      ],
      'tl': [
        '1. Dagdagan ang dalas ng irigasyon sa 2-3 beses kada araw',
        '2. Maglagay ng mulch sa paligid ng mga halaman upang mabawasan ang temperatura ng lupa',
        '3. Isaalang-alang ang pansamantalang mga istruktura ng lilim kung ang temperatura ay lumampas sa 35°C',
        '4. Subaybayan nang mabuti ang kahalumigmigan ng lupa - ang mataas na temperatura ay nagpapataas ng pangangailangan sa tubig',
        '5. Iwasan ang paglalagay ng pataba sa mga oras ng matinding init (10 AM - 3 PM)',
        '6. Suriin ang mga sintomas ng stress sa init: paglalanta, pagkulot ng dahon, paghinto ng paglaki'
      ]
    },
    'Adjust plant spacing for better light penetration': {
      'en': [
        '1. Measure current plant spacing between rows and within rows',
        '2. For corn, increase row spacing to 75-90 cm (30-36 inches)',
        '3. Adjust plant spacing within rows to 20-25 cm (8-10 inches)',
        '4. Remove excess plants if overcrowded, keeping the healthiest ones',
        '5. Ensure proper spacing allows for equipment access between rows',
        '6. Monitor light penetration - leaves should not overlap significantly',
        '7. Consider plant height and growth stage when adjusting spacing',
        '8. Document new spacing measurements for future reference'
      ],
      'tl': [
        '1. Sukatin ang kasalukuyang pagitan ng mga halaman sa pagitan ng mga hilera at sa loob ng mga hilera',
        '2. Para sa mais, dagdagan ang pagitan ng mga hilera sa 75-90 cm (30-36 pulgada)',
        '3. Ayusin ang pagitan ng mga halaman sa loob ng mga hilera sa 20-25 cm (8-10 pulgada)',
        '4. Alisin ang mga labis na halaman kung sobrang siksik, panatilihin ang mga pinakamalusog',
        '5. Siguraduhin na ang tamang pagitan ay nagbibigay-daan para sa pag-access ng kagamitan sa pagitan ng mga hilera',
        '6. Subaybayan ang pagpasok ng liwanag - ang mga dahon ay hindi dapat mag-overlap nang malaki',
        '7. Isaalang-alang ang taas ng halaman at yugto ng paglaki kapag inaayos ang pagitan',
        '8. Idokumento ang mga bagong sukat ng pagitan para sa mga hinaharap na sanggunian'
      ]
    },
    'Protect from cold stress': {
      'en': [
        '1. Reduce irrigation frequency to prevent waterlogging',
        '2. Apply organic mulch to insulate soil',
        '3. Consider row covers or plastic tunnels for protection',
        '4. Monitor soil temperature - avoid planting if below 10°C',
        '5. Use black plastic mulch to warm soil',
        '6. Check for cold damage: stunted growth, yellowing leaves'
      ],
      'tl': [
        '1. Bawasan ang dalas ng irigasyon upang maiwasan ang pagbabaha',
        '2. Maglagay ng organikong mulch upang i-insulate ang lupa',
        '3. Isaalang-alang ang mga row cover o plastic tunnel para sa proteksyon',
        '4. Subaybayan ang temperatura ng lupa - iwasan ang pagtatanim kung mas mababa sa 10°C',
        '5. Gumamit ng itim na plastic mulch upang painitin ang lupa',
        '6. Suriin ang pinsala sa lamig: paghinto ng paglaki, pagdilaw ng mga dahon'
      ]
    },
    'Increase humidity for optimal plant growth': {
      'en': [
        '1. Increase irrigation frequency to maintain soil moisture',
        '2. Apply mulch to reduce soil evaporation',
        '3. Consider overhead irrigation during early morning hours',
        '4. Use humidifiers or misting systems if available',
        '5. Group plants together to create microclimate',
        '6. Monitor humidity levels with hygrometer'
      ],
      'tl': [
        '1. Dagdagan ang dalas ng irigasyon upang mapanatili ang kahalumigmigan ng lupa',
        '2. Maglagay ng mulch upang mabawasan ang pagkatuyo ng lupa',
        '3. Isaalang-alang ang overhead irrigation sa mga oras ng umaga',
        '4. Gumamit ng humidifier o misting system kung available',
        '5. Pagsama-samahin ang mga halaman upang lumikha ng microclimate',
        '6. Subaybayan ang antas ng halumigmig gamit ang hygrometer'
      ]
    },
    'Reduce humidity to prevent disease': {
      'en': [
        '1. Improve field drainage to reduce standing water',
        '2. Increase plant spacing for better air circulation',
        '3. Apply fungicide preventively if disease pressure is high',
        '4. Remove excess vegetation that blocks air flow',
        '5. Use fans or ventilation systems if available',
        '6. Monitor for fungal disease symptoms'
      ],
      'tl': [
        '1. Mapabuti ang daluyan ng tubig sa field upang mabawasan ang nakatayong tubig',
        '2. Dagdagan ang pagitan ng mga halaman para sa mas mabuting sirkulasyon ng hangin',
        '3. Maglagay ng fungicide nang preventive kung mataas ang pressure ng sakit',
        '4. Alisin ang labis na vegetation na humahadlang sa daloy ng hangin',
        '5. Gumamit ng fan o ventilation system kung available',
        '6. Subaybayan ang mga sintomas ng fungal disease'
      ]
    },
    
    // Water management instructions
    'URGENT: Irrigate immediately': {
      'en': [
        '1. Apply 20-30mm of water immediately using sprinkler or flood irrigation',
        '2. Water early morning (6-8 AM) to minimize evaporation',
        '3. Check soil moisture after 2 hours - should be moist to 15cm depth',
        '4. Repeat irrigation if soil still dry after 4 hours',
        '5. Monitor plants for recovery signs within 24 hours',
        '6. Adjust irrigation schedule to prevent future stress'
      ],
      'tl': [
        '1. Maglagay ng 20-30mm ng tubig kaagad gamit ang sprinkler o flood irrigation',
        '2. Magdilig sa umaga (6-8 AM) upang mabawasan ang pagkatuyo',
        '3. Suriin ang kahalumigmigan ng lupa pagkatapos ng 2 oras - dapat ay moist hanggang 15cm ang lalim',
        '4. Ulitin ang irigasyon kung tuyo pa rin ang lupa pagkatapos ng 4 oras',
        '5. Subaybayan ang mga halaman para sa mga palatandaan ng paggaling sa loob ng 24 oras',
        '6. Ayusin ang iskedyul ng irigasyon upang maiwasan ang future stress'
      ]
    },
    'Increase irrigation frequency': {
      'en': [
        '1. Water every 2-3 days instead of weekly',
        '2. Apply 15-20mm per irrigation session',
        '3. Water early morning or late afternoon to reduce evaporation',
        '4. Check soil moisture before each irrigation',
        '5. Adjust frequency based on weather conditions',
        '6. Monitor plant response and adjust accordingly'
      ],
      'tl': [
        '1. Magdilig tuwing 2-3 araw sa halip na lingguhan',
        '2. Maglagay ng 15-20mm per irrigation session',
        '3. Magdilig sa umaga o hapon upang mabawasan ang pagkatuyo',
        '4. Suriin ang kahalumigmigan ng lupa bago ang bawat irigasyon',
        '5. Ayusin ang dalas batay sa kondisyon ng panahon',
        '6. Subaybayan ang tugon ng halaman at ayusin nang naaayon'
      ]
    },
    'Improve drainage to prevent waterlogging': {
      'en': [
        '1. Create drainage ditches around field perimeter',
        '2. Install subsurface drainage pipes if needed',
        '3. Raise planting beds to improve water runoff',
        '4. Add organic matter to improve soil structure',
        '5. Avoid over-irrigation during wet periods',
        '6. Monitor soil moisture levels regularly'
      ],
      'tl': [
        '1. Gumawa ng drainage ditches sa paligid ng field',
        '2. Mag-install ng subsurface drainage pipes kung kailangan',
        '3. Taasan ang planting beds upang mapabuti ang water runoff',
        '4. Magdagdag ng organic matter upang mapabuti ang istruktura ng lupa',
        '5. Iwasan ang over-irrigation sa mga panahon ng tag-ulan',
        '6. Subaybayan nang regular ang antas ng kahalumigmigan ng lupa'
      ]
    },
    
    // Soil management instructions
    'Apply lime to increase soil pH': {
      'en': [
        '1. Apply 2-4 metric tons per hectare of agricultural lime',
        '2. Broadcast lime evenly across the field using spreader',
        '3. Incorporate lime into soil to 15-20 cm depth using disc harrow',
        '4. Water field after application to help lime dissolve',
        '5. Wait 2-3 weeks before planting to allow pH adjustment',
        '6. Test soil pH again after 4-6 weeks to verify effectiveness'
      ],
      'tl': [
        '1. Maglagay ng 2-4 metric tons per hectare ng agricultural lime',
        '2. I-broadcast ang lime nang pantay sa buong field gamit ang spreader',
        '3. I-incorporate ang lime sa lupa hanggang 15-20 cm ang lalim gamit ang disc harrow',
        '4. Diligan ang field pagkatapos ng application upang matulungan ang pagkatunaw ng lime',
        '5. Maghintay ng 2-3 linggo bago magtanim upang payagan ang pH adjustment',
        '6. I-test ulit ang soil pH pagkatapos ng 4-6 linggo upang mapatunayan ang effectiveness'
      ]
    },
    'Apply sulfur to decrease soil pH': {
      'en': [
        '1. Apply elemental sulfur at 1-3 tons per hectare based on soil type',
        '2. For sandy soil: Use 1-2 tons/ha sulfur',
        '3. For loam soil: Use 2-3 tons/ha sulfur',
        '4. For clay soil: Use 3-4 tons/ha sulfur',
        '5. Mix sulfur thoroughly into top 15 cm of soil',
        '6. Water field after application and wait 4-6 weeks before planting'
      ],
      'tl': [
        '1. Maglagay ng elemental sulfur sa 1-3 tons per hectare batay sa uri ng lupa',
        '2. Para sa sandy soil: Gumamit ng 1-2 tons/ha sulfur',
        '3. Para sa loam soil: Gumamit ng 2-3 tons/ha sulfur',
        '4. Para sa clay soil: Gumamit ng 3-4 tons/ha sulfur',
        '5. Ihalo nang mabuti ang sulfur sa top 15 cm ng lupa',
        '6. Diligan ang field pagkatapos ng application at maghintay ng 4-6 linggo bago magtanim'
      ]
    },
    
    // Growth stage specific instructions
    'Ensure proper emergence and early growth': {
      'en': [
        '1. Verify seed depth: 2-3 cm for heavy soils, 3-4 cm for light soils',
        '2. Check for soil crusting that may prevent emergence',
        '3. Maintain consistent soil moisture - avoid waterlogging',
        '4. Protect from birds and rodents',
        '5. Apply pre-emergence herbicide if needed',
        '6. Monitor daily for emergence progress'
      ],
      'tl': [
        '1. Patunayan ang lalim ng binhi: 2-3 cm para sa mabibigat na lupa, 3-4 cm para sa magaan na lupa',
        '2. Suriin ang soil crusting na maaaring humadlang sa pagsibol',
        '3. Panatilihin ang consistent na kahalumigmigan ng lupa - iwasan ang pagbabaha',
        '4. Protektahan mula sa mga ibon at daga',
        '5. Maglagay ng pre-emergence herbicide kung kailangan',
        '6. Subaybayan araw-araw ang pag-unlad ng pagsibol'
      ]
    },
    'Early vegetative growth management': {
      'en': [
        '1. Begin side-dressing with nitrogen fertilizer (Urea 46-0-0 at 1-2 bags/ha)',
        '2. Apply fertilizer 10-15 cm from plant base using side-dress applicator',
        '3. Thin plants to recommended spacing (20-25 cm between plants)',
        '4. Control weeds with cultivation or herbicide',
        '5. Monitor for pest damage and apply control measures',
        '6. Maintain soil moisture at 70-80% field capacity'
      ],
      'tl': [
        '1. Simulan ang side-dressing gamit ang nitrogen fertilizer (Urea 46-0-0 sa 1-2 bags/ha)',
        '2. Maglagay ng pataba 10-15 cm mula sa base ng halaman gamit ang side-dress applicator',
        '3. I-thin ang mga halaman sa recommended spacing (20-25 cm sa pagitan ng mga halaman)',
        '4. Kontrolin ang mga damo gamit ang cultivation o herbicide',
        '5. Subaybayan ang pinsala ng peste at maglagay ng control measures',
        '6. Panatilihin ang kahalumigmigan ng lupa sa 70-80% field capacity'
      ]
    },
    'CRITICAL: Reproductive stage management': {
      'en': [
        '1. CRITICAL: Maintain consistent soil moisture (80-90%) - this is the most important factor',
        '2. Increase irrigation frequency to every 2-3 days with 30-40 mm water',
        '3. Monitor pollination success - check for proper silking and pollen shed',
        '4. Apply potassium fertilizer (0-0-60) at 1-2 bags/ha for kernel development',
        '5. Control pests that can damage ears and kernels',
        '6. Avoid stress during this critical 2-3 week period'
      ],
      'tl': [
        '1. KAGIPITAN: Panatilihin ang consistent na kahalumigmigan ng lupa (80-90%) - ito ang pinakamahalagang salik',
        '2. Dagdagan ang dalas ng irigasyon sa tuwing 2-3 araw na may 30-40 mm na tubig',
        '3. Subaybayan ang tagumpay ng pollination - suriin ang tamang silking at pollen shed',
        '4. Maglagay ng potassium fertilizer (0-0-60) sa 1-2 bags/ha para sa pag-unlad ng kernel',
        '5. Kontrolin ang mga peste na maaaring makapinsala sa mga tainga at kernel',
        '6. Iwasan ang stress sa kritikal na 2-3 linggong panahon na ito'
      ]
    }
  };

  static final Map<String, Map<String, String>> _descriptionTranslations = {
    // Temperature management descriptions
    'Implement shading or increase watering frequency during peak heat hours.': {
      'en': 'Implement shading or increase watering frequency during peak heat hours.',
      'tl': 'Maglagay ng lilim o dagdagan ang dalas ng pagdidilig sa mga oras ng matinding init.',
    },
    'Space plants further apart to allow better air circulation and light penetration.': {
      'en': 'Space plants further apart to allow better air circulation and light penetration.',
      'tl': 'Paghiwalayin ang mga halaman para sa mas mabuting sirkulasyon ng hangin at pagpasok ng liwanag.',
    },
    'Provide temporary shade during the hottest part of the day.': {
      'en': 'Provide temporary shade during the hottest part of the day.',
      'tl': 'Magbigay ng pansamantalang lilim sa pinakamainit na bahagi ng araw.',
    },
    'Increase air circulation around plants to reduce heat stress.': {
      'en': 'Increase air circulation around plants to reduce heat stress.',
      'tl': 'Dagdagan ang sirkulasyon ng hangin sa paligid ng mga halaman upang mabawasan ang stress sa init.',
    },
    
    // Water management descriptions
    'Increase watering frequency to prevent drought stress.': {
      'en': 'Increase watering frequency to prevent drought stress.',
      'tl': 'Dagdagan ang dalas ng pagdidilig upang maiwasan ang stress sa tagtuyot.',
    },
    'Reduce watering frequency to prevent overwatering and root rot.': {
      'en': 'Reduce watering frequency to prevent overwatering and root rot.',
      'tl': 'Bawasan ang dalas ng pagdidilig upang maiwasan ang labis na pagdidilig at pagkabulok ng ugat.',
    },
    'Check and improve drainage to prevent waterlogging.': {
      'en': 'Check and improve drainage to prevent waterlogging.',
      'tl': 'Suriin at pabutihin ang daluyan ng tubig upang maiwasan ang pagbaha.',
    },
    'Water plants early in the morning or late in the evening.': {
      'en': 'Water plants early in the morning or late in the evening.',
      'tl': 'Diligin ang mga halaman sa umaga o sa gabi.',
    },
    
    // Soil management descriptions
    'Apply organic fertilizer to improve soil quality.': {
      'en': 'Apply organic fertilizer to improve soil quality.',
      'tl': 'Maglagay ng organikong pataba upang mapabuti ang kalidad ng lupa.',
    },
    'Test soil pH and adjust if necessary for optimal plant growth.': {
      'en': 'Test soil pH and adjust if necessary for optimal plant growth.',
      'tl': 'Suriin ang pH ng lupa at ayusin kung kinakailangan para sa optimal na paglaki ng halaman.',
    },
    'Add compost to improve soil structure and nutrient content.': {
      'en': 'Add compost to improve soil structure and nutrient content.',
      'tl': 'Magdagdag ng compost upang mapabuti ang istruktura ng lupa at nilalaman ng nutrisyon.',
    },
    'Apply soil amendments to correct nutrient deficiencies.': {
      'en': 'Apply soil amendments to correct nutrient deficiencies.',
      'tl': 'Maglagay ng mga pagbabago sa lupa upang maitama ang kakulangan sa nutrisyon.',
    },
    
    // Humidity and environment descriptions
    'Use humidifiers or misting systems to maintain optimal humidity.': {
      'en': 'Use humidifiers or misting systems to maintain optimal humidity.',
      'tl': 'Gumamit ng humidifier o misting system upang mapanatili ang optimal na halumigmig.',
    },
    'Increase humidity levels to prevent plant stress.': {
      'en': 'Increase humidity levels to prevent plant stress.',
      'tl': 'Dagdagan ang antas ng halumigmig upang maiwasan ang stress ng halaman.',
    },
    'Reduce humidity to prevent fungal diseases.': {
      'en': 'Reduce humidity to prevent fungal diseases.',
      'tl': 'Bawasan ang halumigmig upang maiwasan ang mga sakit na fungal.',
    },
    'Monitor environmental conditions regularly.': {
      'en': 'Monitor environmental conditions regularly.',
      'tl': 'Subaybayan ang mga kondisyon ng kapaligiran nang regular.',
    },
    
    // Light management descriptions
    'Adjust artificial lighting or natural light exposure.': {
      'en': 'Adjust artificial lighting or natural light exposure.',
      'tl': 'Ayusin ang artipisyal na ilaw o natural na pagkakalantad sa liwanag.',
    },
    'Increase light exposure to promote healthy growth.': {
      'en': 'Increase light exposure to promote healthy growth.',
      'tl': 'Dagdagan ang pagkakalantad sa liwanag upang mapadali ang malusog na paglaki.',
    },
    'Reduce light exposure to prevent leaf burn.': {
      'en': 'Reduce light exposure to prevent leaf burn.',
      'tl': 'Bawasan ang pagkakalantad sa liwanag upang maiwasan ang pagkasunog ng dahon.',
    },
    'Ensure plants receive adequate light for photosynthesis.': {
      'en': 'Ensure plants receive adequate light for photosynthesis.',
      'tl': 'Siguraduhin na ang mga halaman ay nakakatanggap ng sapat na liwanag para sa potosintesis.',
    },
    
    // Pest and disease management descriptions
    'Apply appropriate pest control measures.': {
      'en': 'Apply appropriate pest control measures.',
      'tl': 'Maglagay ng angkop na mga hakbang sa pagkontrol ng peste.',
    },
    'Inspect plants regularly for signs of disease or pest damage.': {
      'en': 'Inspect plants regularly for signs of disease or pest damage.',
      'tl': 'Suriin ang mga halaman nang regular para sa mga palatandaan ng sakit o pinsala ng peste.',
    },
    'Remove infected or damaged plant material immediately.': {
      'en': 'Remove infected or damaged plant material immediately.',
      'tl': 'Alisin agad ang nahawaang o nasirang materyal ng halaman.',
    },
    'Use organic pest control methods when possible.': {
      'en': 'Use organic pest control methods when possible.',
      'tl': 'Gumamit ng organikong mga paraan ng pagkontrol ng peste kung maaari.',
    },
    
    // General maintenance descriptions
    'Prune plants to promote healthy growth and shape.': {
      'en': 'Prune plants to promote healthy growth and shape.',
      'tl': 'Mag-prune ng mga halaman upang mapadali ang malusog na paglaki at hugis.',
    },
    'Harvest crops at the optimal time for best quality.': {
      'en': 'Harvest crops at the optimal time for best quality.',
      'tl': 'Mag-ani ng mga pananim sa pinakamainam na oras para sa pinakamahusay na kalidad.',
    },
    'Check plant health and address any issues promptly.': {
      'en': 'Check plant health and address any issues promptly.',
      'tl': 'Suriin ang kalusugan ng halaman at harapin agad ang anumang mga problema.',
    },
    'Monitor growth progress and adjust care as needed.': {
      'en': 'Monitor growth progress and adjust care as needed.',
      'tl': 'Subaybayan ang paglaki at ayusin ang pangangalaga kung kinakailangan.',
    },
    // Field-specific translations
    'Field Durant: humidity at': {
      'en': 'Field Durant: humidity at',
      'tl': 'Field Durant: halumigmig sa',
    },
    '02 PROTO: humidity at': {
      'en': '02 PROTO: humidity at',
      'tl': '02 PROTO: halumigmig sa',
    },
    'Field Durant: temperature at': {
      'en': 'Field Durant: temperature at',
      'tl': 'Field Durant: temperatura sa',
    },
    '02 PROTO: temperature at': {
      'en': '02 PROTO: temperature at',
      'tl': '02 PROTO: temperatura sa',
    },
    'Field Durant: soil moisture at': {
      'en': 'Field Durant: soil moisture at',
      'tl': 'Field Durant: kahalumigmigan ng lupa sa',
    },
    '02 PROTO: soil moisture at': {
      'en': '02 PROTO: soil moisture at',
      'tl': '02 PROTO: kahalumigmigan ng lupa sa',
    },
    'Field Durant: light intensity at': {
      'en': 'Field Durant: light intensity at',
      'tl': 'Field Durant: intensity ng liwanag sa',
    },
    '02 PROTO: light intensity at': {
      'en': '02 PROTO: light intensity at',
      'tl': '02 PROTO: intensity ng liwanag sa',
    },
  };

  // Get current language from SecureStorage (same as settings system) with SharedPreferences fallback
  static Future<String> _getCurrentLanguage() async {
    try {
      // First try to get from SecureStorage (settings system)
      final settingsJson = await SecureStorage.read(key: 'settings');
      if (settingsJson != null) {
        final settingsData = Map<String, dynamic>.from(jsonDecode(settingsJson));
        final language = settingsData['language'] ?? 'en';
        // Also store in SharedPreferences for immediate access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_language_code', language);
        return language;
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language_code') ?? 'en';
    } catch (e) {
      // Final fallback
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language_code') ?? 'en';
    }
  }

  // Translate prescription title
  static Future<String> translatePrescriptionTitle(String originalTitle) async {
    final language = await _getCurrentLanguage();
    final lowerTitle = originalTitle.toLowerCase();

    // Try exact match first
    for (final entry in _titleTranslations.entries) {
      if (entry.key.toLowerCase() == lowerTitle) {
        return entry.value[language] ?? originalTitle;
      }
    }

    // Try partial matching for more flexibility
    for (final entry in _titleTranslations.entries) {
      if (lowerTitle.contains(entry.key.toLowerCase()) || 
          entry.key.toLowerCase().contains(lowerTitle)) {
        return entry.value[language] ?? originalTitle;
      }
    }

    // Fallback: Try to translate common words if no exact match
    if (language == 'tl') {
      return _translateCommonWords(originalTitle);
    }

    return originalTitle; // Fallback to original if no translation found
  }

  // Fallback translation for common words
  static String _translateCommonWords(String text) {
    final commonTranslations = {
      'adjust': 'Ayusin',
      'plant': 'halaman',
      'plants': 'mga halaman',
      'spacing': 'pagitan',
      'better': 'mas mabuti',
      'light': 'liwanag',
      'penetration': 'pagpasok',
      'temperature': 'temperatura',
      'high': 'mataas',
      'stress': 'stress',
      'manage': 'Pamahalaan',
      'increase': 'Dagdagan',
      'decrease': 'Bawasan',
      'reduce': 'Bawasan',
      'water': 'tubig',
      'watering': 'pagdidilig',
      'frequency': 'dalas',
      'irrigation': 'irigasyon',
      'schedule': 'iskedyul',
      'soil': 'lupa',
      'apply': 'Maglagay',
      'treatment': 'paggamot',
      'humidity': 'halumigmig',
      'levels': 'antas',
      'monitor': 'Subaybayan',
      'exposure': 'pagkakalantad',
      'pest': 'peste',
      'control': 'kontrol',
      'disease': 'sakit',
      'diseases': 'mga sakit',
      'check': 'Suriin',
      'remove': 'Alisin',
      'infected': 'nahawaang',
      'prune': 'Mag-prune',
      'harvest': 'Mag-ani',
      'crops': 'mga pananim',
      'health': 'kalusugan',
      'growth': 'paglaki',
      'progress': 'pag-unlad',
      'field': 'field',
      'for': 'para sa',
      'and': 'at',
      'or': 'o',
      'the': 'ang',
      'a': 'isang',
      'an': 'isang',
      'to': 'upang',
      'of': 'ng',
      'in': 'sa',
      'on': 'sa',
      'at': 'sa',
      'with': 'kasama',
      'during': 'sa panahon ng',
      'peak': 'matinding',
      'heat': 'init',
      'hours': 'oras',
      'provide': 'Magbigay',
      'shade': 'lilim',
      'ventilation': 'bentilasyon',
      'drainage': 'daluyan ng tubig',
      'system': 'sistema',
      'organic': 'organiko',
      'fertilizer': 'pataba',
      'improve': 'mapabuti',
      'quality': 'kalidad',
      'ph': 'pH',
      'test': 'Suriin',
      'necessary': 'kinakailangan',
      'optimal': 'optimal',
      'compost': 'compost',
      'structure': 'istruktura',
      'nutrient': 'nutrisyon',
      'content': 'nilalaman',
      'amendments': 'mga pagbabago',
      'correct': 'maitama',
      'deficiencies': 'kakulangan',
      'humidifiers': 'humidifier',
      'misting': 'misting',
      'systems': 'mga sistema',
      'maintain': 'mapanatili',
      'prevent': 'maiwasan',
      'fungal': 'fungal',
      'artificial': 'artipisyal',
      'natural': 'natural',
      'promote': 'mapadali',
      'healthy': 'malusog',
      'burn': 'pagkasunog',
      'leaf': 'dahon',
      'ensure': 'Siguraduhin',
      'receive': 'nakakatanggap',
      'adequate': 'sapat',
      'photosynthesis': 'potosintesis',
      'appropriate': 'angkop',
      'measures': 'mga hakbang',
      'inspect': 'Suriin',
      'regularly': 'nang regular',
      'signs': 'mga palatandaan',
      'damage': 'pinsala',
      'immediately': 'agad',
      'material': 'materyal',
      'methods': 'mga paraan',
      'when': 'kung',
      'possible': 'maaari',
      'shape': 'hugis',
      'time': 'oras',
      'best': 'pinakamahusay',
      'address': 'harapin',
      'issues': 'mga problema',
      'promptly': 'agad',
      'care': 'pangangalaga',
      'needed': 'kinakailangan',
    };

    String translated = text;
    for (final entry in commonTranslations.entries) {
      final regex = RegExp(r'\b' + RegExp.escape(entry.key) + r'\b', caseSensitive: false);
      translated = translated.replaceAll(regex, entry.value);
    }
    
    return translated;
  }

  // Translate prescription description
  static Future<String> translatePrescriptionDescription(String originalDescription) async {
    final language = await _getCurrentLanguage();
    final lowerDescription = originalDescription.toLowerCase();

    // Try exact match first
    for (final entry in _descriptionTranslations.entries) {
      if (entry.key.toLowerCase() == lowerDescription) {
        return entry.value[language] ?? originalDescription;
      }
    }

    // Try partial matching for more flexibility
    for (final entry in _descriptionTranslations.entries) {
      if (lowerDescription.contains(entry.key.toLowerCase()) || 
          entry.key.toLowerCase().contains(lowerDescription)) {
        return entry.value[language] ?? originalDescription;
      }
    }

    // Fallback: Try to translate common words if no exact match
    if (language == 'tl') {
      return _translateCommonWords(originalDescription);
    }

    return originalDescription; // Fallback to original if no translation found
  }

  // Translate prescription instructions (step-by-step)
  static Future<List<String>> translatePrescriptionInstructions(String prescriptionTitle, List<String> originalInstructions) async {
    final language = await _getCurrentLanguage();
    
    // Try to find exact match for the prescription title
    if (_instructionTranslations.containsKey(prescriptionTitle)) {
      final translations = _instructionTranslations[prescriptionTitle];
      if (translations != null && translations.containsKey(language)) {
        return translations[language]!;
      }
    }
    
    // If no exact match, try to translate each instruction individually
    if (language == 'tl') {
      return originalInstructions.map((instruction) => _translateCommonWords(instruction)).toList();
    }
    
    return originalInstructions; // Return original if no translation found
  }

  // Get translated instructions for a specific prescription
  static Future<List<String>> getTranslatedInstructions(String prescriptionTitle) async {
    final language = await _getCurrentLanguage();
    
    print('🔍 getTranslatedInstructions called for: "$prescriptionTitle"');
    print('🔍 Current language: $language');
    print('🔍 Available instruction keys: ${_instructionTranslations.keys.toList()}');
    
    if (_instructionTranslations.containsKey(prescriptionTitle)) {
      final translations = _instructionTranslations[prescriptionTitle];
      if (translations != null && translations.containsKey(language)) {
        print('🔍 Found exact match for: $prescriptionTitle');
        print('🔍 Instructions count: ${translations[language]!.length}');
        return translations[language]!;
      }
    }
    
    // Try partial matching
    for (final key in _instructionTranslations.keys) {
      if (prescriptionTitle.toLowerCase().contains(key.toLowerCase()) || 
          key.toLowerCase().contains(prescriptionTitle.toLowerCase())) {
        print('🔍 Found partial match: "$key" for "$prescriptionTitle"');
        final translations = _instructionTranslations[key];
        if (translations != null && translations.containsKey(language)) {
          print('🔍 Instructions count: ${translations[language]!.length}');
          return translations[language]!;
        }
      }
    }
    
    print('🔍 No instructions found for: $prescriptionTitle');
    // Return empty list if no instructions found
    return [];
  }
}