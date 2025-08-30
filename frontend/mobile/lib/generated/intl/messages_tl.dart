// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'tl';

  static String m0(days, rate) =>
      "${days} araw hanggang susunod na yugto (${rate}/araw)";

  static String m1(parameter) =>
      "Sigurado ka bang gusto mong tanggalin ang reseta sa ${parameter}?";

  static String m2(filter) => "Walang nakitang reseta para sa \"${filter}\"";

  static String m3(count) =>
      "Pamahalaan ang iyong mga reseta (${count} kabuuan)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Tungkol"),
    "aboutApp": MessageLookupByLibrary.simpleMessage(
      "Ang Maize Watch ay isang crop monitoring application na tumutulong sa mga magsasaka na subaybayan ang paglago ng mais at agad na matukoy ang mga problema.",
    ),
    "about_app": MessageLookupByLibrary.simpleMessage(
      "Ang maize-watch app ay isang IoT-driven na sistema na may prescriptive analytics para sa pag-monitor ng mais.",
    ),
    "about_user": MessageLookupByLibrary.simpleMessage("Tungkol sa User"),
    "account": MessageLookupByLibrary.simpleMessage("Akunta"),
    "action_check_all": MessageLookupByLibrary.simpleMessage("I-check Lahat"),
    "action_delete": MessageLookupByLibrary.simpleMessage("Tanggalin"),
    "action_delete_all": MessageLookupByLibrary.simpleMessage(
      "Tanggalin Lahat",
    ),
    "action_delete_completed": MessageLookupByLibrary.simpleMessage(
      "Tanggalin ang Tapos Na",
    ),
    "action_uncheck_all": MessageLookupByLibrary.simpleMessage(
      "I-uncheck Lahat",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Tirahan"),
    "address_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang address ay may hindi wastong karakter",
    ),
    "address_needs_alphanumeric": MessageLookupByLibrary.simpleMessage(
      "Ang address ay dapat may hindi bababa sa isang titik o numero",
    ),
    "address_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang address",
    ),
    "address_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang address ay hindi dapat lumampas sa 200 karakter",
    ),
    "address_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang address ay dapat may hindi bababa sa 10 karakter",
    ),
    "agreement_prefix": MessageLookupByLibrary.simpleMessage(
      "Sa pag-login, sumasang-ayon ka sa aming ",
    ),
    "agreement_suffix": MessageLookupByLibrary.simpleMessage("."),
    "all_fields_required": MessageLookupByLibrary.simpleMessage(
      "Kinakailangang punan ang lahat ng mga patlang.",
    ),
    "and": MessageLookupByLibrary.simpleMessage(" at "),
    "appName": MessageLookupByLibrary.simpleMessage("Maize Watch"),
    "back": MessageLookupByLibrary.simpleMessage("Bumalik"),
    "back_button": MessageLookupByLibrary.simpleMessage("Bumalik"),
    "barangay": MessageLookupByLibrary.simpleMessage("Barangay"),
    "barangay_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang barangay",
    ),
    "bright": MessageLookupByLibrary.simpleMessage("Maliwanag"),
    "button_retry": MessageLookupByLibrary.simpleMessage("Subukang Muli"),
    "confirm_password": MessageLookupByLibrary.simpleMessage(
      "Kumpirmahin ang Password",
    ),
    "confirm_password_required": MessageLookupByLibrary.simpleMessage(
      "Mangyaring i-confirm ang inyong password",
    ),
    "connection_error": MessageLookupByLibrary.simpleMessage(
      "May problema sa koneksyon. Pakisuri ang iyong internet at subukang muli.",
    ),
    "contactUs": MessageLookupByLibrary.simpleMessage(
      "Makipag-ugnayan sa amin sa:",
    ),
    "contact_number": MessageLookupByLibrary.simpleMessage(
      "10-digit Numero ng Telepono",
    ),
    "contact_number_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang numero ng telepono ay dapat magsimula sa 9",
    ),
    "contact_number_invalid_length": MessageLookupByLibrary.simpleMessage(
      "Ang numero ng telepono ay dapat eksaktong 10 digits (walang +63)",
    ),
    "contact_number_invalid_prefix": MessageLookupByLibrary.simpleMessage(
      "Hindi wastong Philippine mobile number prefix",
    ),
    "contact_number_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang numero ng telepono",
    ),
    "corn": MessageLookupByLibrary.simpleMessage("Mais"),
    "corn_age_title": MessageLookupByLibrary.simpleMessage(
      "Ilang taon na ang iyong pananim na mais?",
    ),
    "corn_growth": MessageLookupByLibrary.simpleMessage("Paglago ng Mais"),
    "corn_registration": MessageLookupByLibrary.simpleMessage(
      "Rehistrasyon ng Mais",
    ),
    "corn_variety": MessageLookupByLibrary.simpleMessage("Uri ng Mais"),
    "corn_variety_title": MessageLookupByLibrary.simpleMessage(
      "Piliin ang nais mong uri ng mais",
    ),
    "critical": MessageLookupByLibrary.simpleMessage("Kritikal"),
    "crop_condition_subtitle": MessageLookupByLibrary.simpleMessage(
      "Tingnan ang kasalukuyang kondisyon ng iyong mais at tumanggap ng rekomendasyon.",
    ),
    "crop_condition_title": MessageLookupByLibrary.simpleMessage(
      "Kondisyon ng Pananim",
    ),
    "crop_excellent": MessageLookupByLibrary.simpleMessage(
      "Napakahusay ng kondisyon ng iyong mga pananim.",
    ),
    "crop_health": MessageLookupByLibrary.simpleMessage("Kalusugan ng Pananim"),
    "crop_okay": MessageLookupByLibrary.simpleMessage(
      "Maayos ang pananim. Bantayan pa rin.",
    ),
    "crop_risk": MessageLookupByLibrary.simpleMessage(
      "Nasa panganib ang pananim! Agarang aksyon ang kailangan.",
    ),
    "current_growth_stage": MessageLookupByLibrary.simpleMessage(
      "Kasalukuyang Yugto ng Paglaki",
    ),
    "dashboard_title": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "days": MessageLookupByLibrary.simpleMessage("araw"),
    "days_ago": MessageLookupByLibrary.simpleMessage("araw ang nakalipas"),
    "days_since_planting": MessageLookupByLibrary.simpleMessage(
      "Mga Araw Mula Nang Itanim",
    ),
    "days_to_next_stage": m0,
    "declining": MessageLookupByLibrary.simpleMessage("Humihina ang paglago"),
    "default_user": MessageLookupByLibrary.simpleMessage("magsasaka"),
    "description": MessageLookupByLibrary.simpleMessage(
      "Palaguin ang ani, bawasan ang alalahanin.",
    ),
    "dialog_delete_all_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Tanggalin Lahat ng Reseta",
    ),
    "dialog_delete_all_prescriptions_confirm": MessageLookupByLibrary.simpleMessage(
      "Sigurado ka bang gusto mong tanggalin ang LAHAT ng reseta? Hindi na maibabalik ang aksyong ito.",
    ),
    "dialog_delete_completed_prescriptions":
        MessageLookupByLibrary.simpleMessage(
          "Tanggalin ang Lahat ng Tapos Nang Reseta",
        ),
    "dialog_delete_completed_prescriptions_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Sigurado ka bang gusto mong tanggalin ang lahat ng tapos nang reseta?",
        ),
    "dialog_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Tanggalin ang Reseta",
    ),
    "dialog_delete_prescription_confirm": m1,
    "dim": MessageLookupByLibrary.simpleMessage("Maliwanag"),
    "done": MessageLookupByLibrary.simpleMessage("Tapos na"),
    "dry": MessageLookupByLibrary.simpleMessage("Tuyo"),
    "empty_no_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Walang nakitang reseta",
    ),
    "empty_no_prescriptions_filter": m2,
    "enableNotifications": MessageLookupByLibrary.simpleMessage(
      "Paganahin ang Abiso",
    ),
    "enable_notifications": MessageLookupByLibrary.simpleMessage(
      "Paganahin ang Mga Abiso",
    ),
    "enter_barangay": MessageLookupByLibrary.simpleMessage(
      "Maglagay ng Barangay",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "error_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Error sa pag-delete ng reseta",
    ),
    "error_delete_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Error sa pag-delete ng mga reseta",
    ),
    "error_invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Mali ang username o password. Pakisuri ang iyong credentials at subukang muli.",
    ),
    "error_load_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Hindi ma-load ang mga reseta",
    ),
    "error_no_internet": MessageLookupByLibrary.simpleMessage(
      "Walang internet connection. Pakisuri ang iyong connection at subukang muli.",
    ),
    "error_server": MessageLookupByLibrary.simpleMessage(
      "May problema sa server. Pakisubukan muli mamaya.",
    ),
    "error_timeout": MessageLookupByLibrary.simpleMessage(
      "Mabagal ang server. Pakisubukan muli mamaya.",
    ),
    "error_unknown": MessageLookupByLibrary.simpleMessage(
      "May hindi inaasahang error. Pakisubukan muli.",
    ),
    "error_update_prescription": MessageLookupByLibrary.simpleMessage(
      "Error sa pag-update ng reseta",
    ),
    "excellent": MessageLookupByLibrary.simpleMessage("Napakahusay"),
    "exit_app_message": MessageLookupByLibrary.simpleMessage(
      "Sigurado ka bang gusto mong lumabas ng application?",
    ),
    "exit_app_title": MessageLookupByLibrary.simpleMessage("Lumabas ng App"),
    "fair": MessageLookupByLibrary.simpleMessage("Katamtaman"),
    "faqA1": MessageLookupByLibrary.simpleMessage(
      "Pumunta sa mga setting at i-toggle ang switch.",
    ),
    "faqA2": MessageLookupByLibrary.simpleMessage(
      "I-click ang \'Nakalimutan ang Password\' sa login screen.",
    ),
    "faqQ1": MessageLookupByLibrary.simpleMessage(
      "Paano ko i-on ang mga notipikasyon?",
    ),
    "faqQ2": MessageLookupByLibrary.simpleMessage(
      "Paano i-reset ang aking password?",
    ),
    "faqTitle": MessageLookupByLibrary.simpleMessage("Mga Madalas Itanong"),
    "faq_a1": MessageLookupByLibrary.simpleMessage(
      "Ang berde ay nangangahulugang maayos ang sensor, habang ang pula ay maaaring may problema.",
    ),
    "faq_a2": MessageLookupByLibrary.simpleMessage(
      "Ina-update ang datos bawat 5 segundo.",
    ),
    "faq_q1": MessageLookupByLibrary.simpleMessage(
      "Ano ang ibig sabihin ng mga indicator ng sensor?",
    ),
    "faq_q2": MessageLookupByLibrary.simpleMessage(
      "Gaano kadalas ina-update ang datos ng sensor?",
    ),
    "faq_title": MessageLookupByLibrary.simpleMessage("FAQs"),
    "field_information": MessageLookupByLibrary.simpleMessage(
      "Impormasyon ng Bukid",
    ),
    "field_name": MessageLookupByLibrary.simpleMessage("Pangalan ng Bukid"),
    "field_name_label": MessageLookupByLibrary.simpleMessage(
      "Pangalan ng Bukirin",
    ),
    "field_name_required": MessageLookupByLibrary.simpleMessage(
      "Kinakailangan ang pangalan ng bukid",
    ),
    "filter_done": MessageLookupByLibrary.simpleMessage("Tapos Na"),
    "filter_newest": MessageLookupByLibrary.simpleMessage("Pinakabago Muna"),
    "filter_not_done": MessageLookupByLibrary.simpleMessage("Hindi Pa Tapos"),
    "filter_oldest": MessageLookupByLibrary.simpleMessage("Pinakaluma Muna"),
    "filter_view_all": MessageLookupByLibrary.simpleMessage("Tingnan Lahat"),
    "first_name": MessageLookupByLibrary.simpleMessage("Pangalan"),
    "first_name_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Ang unang pangalan ay hindi dapat may magkakasunod na espesyal na karakter",
    ),
    "first_name_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang unang pangalan ay pwedeng may mga titik, espasyo, gitling, kudlit, at tuldok lamang",
    ),
    "first_name_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang unang pangalan ay hindi dapat magsimula o magtapos sa mga espesyal na karakter",
    ),
    "first_name_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang pangalan",
    ),
    "first_name_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang unang pangalan ay hindi dapat lumampas sa 50 titik",
    ),
    "first_name_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang unang pangalan ay dapat may hindi bababa sa 2 titik",
    ),
    "forgot_password": MessageLookupByLibrary.simpleMessage(
      "Nakalimutan ang Password?",
    ),
    "fully_developed_corn": MessageLookupByLibrary.simpleMessage(
      "Ganap nang mais",
    ),
    "good": MessageLookupByLibrary.simpleMessage("Maganda"),
    "greeting_afternoon": MessageLookupByLibrary.simpleMessage(
      "Magandang Hapon",
    ),
    "greeting_evening": MessageLookupByLibrary.simpleMessage("Magandang Gabi"),
    "greeting_morning": MessageLookupByLibrary.simpleMessage("Magandang Umaga"),
    "growth_stage": MessageLookupByLibrary.simpleMessage("Yugto ng Paglaki"),
    "growth_stage_r1": MessageLookupByLibrary.simpleMessage(
      "Paglabas ng Buhok",
    ),
    "growth_stage_r1_desc": MessageLookupByLibrary.simpleMessage(
      "May buhok na sa tenga",
    ),
    "growth_stage_r6": MessageLookupByLibrary.simpleMessage("Ganap na Hinog"),
    "growth_stage_r6_desc": MessageLookupByLibrary.simpleMessage(
      "Lubos nang hinog ang mais",
    ),
    "growth_stage_v3": MessageLookupByLibrary.simpleMessage("Maagang Paglago"),
    "growth_stage_v3_desc": MessageLookupByLibrary.simpleMessage(
      "May 3-5 dahon na",
    ),
    "growth_stage_v8": MessageLookupByLibrary.simpleMessage("Gitnang Paglago"),
    "growth_stage_v8_desc": MessageLookupByLibrary.simpleMessage(
      "8-10 dahon, tumataas",
    ),
    "growth_stage_ve": MessageLookupByLibrary.simpleMessage("Pag-usbong"),
    "growth_stage_ve_desc": MessageLookupByLibrary.simpleMessage(
      "Kakauusbong mula sa lupa",
    ),
    "growth_stage_vt": MessageLookupByLibrary.simpleMessage(
      "Paglabas ng Bulaklak",
    ),
    "growth_stage_vt_desc": MessageLookupByLibrary.simpleMessage(
      "May bulaklak na sa tuktok",
    ),
    "growth_timeline": MessageLookupByLibrary.simpleMessage("Takbo ng Paglaki"),
    "healthy_growth": MessageLookupByLibrary.simpleMessage(
      "Malusog ang bilis ng paglago",
    ),
    "helpDescription": MessageLookupByLibrary.simpleMessage(
      "Narito ang ilang kapaki-pakinabang na impormasyon.",
    ),
    "helpTitle": MessageLookupByLibrary.simpleMessage("Tulong"),
    "help_description": MessageLookupByLibrary.simpleMessage(
      "Nagbibigay ang seksyong ito ng impormasyon upang matulungan ang mga user na maunawaan ang mga tampok at paggamit ng app.",
    ),
    "help_title": MessageLookupByLibrary.simpleMessage("Tulong"),
    "high": MessageLookupByLibrary.simpleMessage("Mataas"),
    "hours_ago": MessageLookupByLibrary.simpleMessage("oras ang nakalipas"),
    "humidity": MessageLookupByLibrary.simpleMessage("Halumigmig"),
    "humidity_moderate": MessageLookupByLibrary.simpleMessage(
      "Katamtamang halumigmig ng hangin.",
    ),
    "humidity_quite_humid": MessageLookupByLibrary.simpleMessage(
      "Medyo mahalumigmig ang hangin.",
    ),
    "humidity_title": MessageLookupByLibrary.simpleMessage("Halumigmig"),
    "humidity_very_dry": MessageLookupByLibrary.simpleMessage(
      "Sobrang tuyo ng hangin.",
    ),
    "humidity_very_humid": MessageLookupByLibrary.simpleMessage(
      "Sobrang mahalumigmig ng hangin.",
    ),
    "invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Di-wastong username o password",
    ),
    "just_now": MessageLookupByLibrary.simpleMessage("ngayon lang"),
    "just_sprouting_from_soil": MessageLookupByLibrary.simpleMessage(
      "Sumisilang pa lang mula sa lupa",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Wika"),
    "last_name": MessageLookupByLibrary.simpleMessage("Apelyido"),
    "last_name_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay hindi dapat may magkakasunod na espesyal na karakter",
    ),
    "last_name_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay pwedeng may mga titik, espasyo, gitling, kudlit, at tuldok lamang",
    ),
    "last_name_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay hindi dapat magsimula o magtapos sa mga espesyal na karakter",
    ),
    "last_name_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang apelyido",
    ),
    "last_name_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay hindi dapat lumampas sa 50 titik",
    ),
    "last_name_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay dapat may hindi bababa sa 2 titik",
    ),
    "last_updated": MessageLookupByLibrary.simpleMessage("Huling na-update"),
    "ldrSensor": MessageLookupByLibrary.simpleMessage("LDR Sensor"),
    "ldr_sensor": MessageLookupByLibrary.simpleMessage("Sensor ng Liwanag"),
    "leaves_3_5_developed": MessageLookupByLibrary.simpleMessage(
      "May 3-5 dahon na",
    ),
    "leaves_8_10_developed": MessageLookupByLibrary.simpleMessage(
      "May 8-10 dahon, lumalaki na",
    ),
    "light_intensity": MessageLookupByLibrary.simpleMessage("Liwanag"),
    "light_intensity_bright": MessageLookupByLibrary.simpleMessage(
      "Maliwanag ang kapaligiran.",
    ),
    "light_intensity_moderate": MessageLookupByLibrary.simpleMessage(
      "Katamtamang liwanag.",
    ),
    "light_intensity_title": MessageLookupByLibrary.simpleMessage("Liwanag"),
    "light_intensity_very_low": MessageLookupByLibrary.simpleMessage(
      "Sobrang hina ng liwanag.",
    ),
    "light_intensity_very_strong": MessageLookupByLibrary.simpleMessage(
      "Napakaliwanag gaya ng tanghaling tapat.",
    ),
    "live": MessageLookupByLibrary.simpleMessage("ONLINE"),
    "location": MessageLookupByLibrary.simpleMessage("Lokasyon"),
    "location_default": MessageLookupByLibrary.simpleMessage(
      "Default: Amadeo, Cavite",
    ),
    "location_label": MessageLookupByLibrary.simpleMessage("Lokasyon"),
    "login": MessageLookupByLibrary.simpleMessage("Mag-login"),
    "login_error": MessageLookupByLibrary.simpleMessage("Error sa Pag-login"),
    "login_failed": MessageLookupByLibrary.simpleMessage(
      "Hindi matagumpay ang pag-login. Mangyaring mag-login ng manu-mano.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Mag-logout"),
    "logout_error": MessageLookupByLibrary.simpleMessage(
      "Nagkaroon ng problema sa pag-logout. Pakisubukang muli.",
    ),
    "logout_message": MessageLookupByLibrary.simpleMessage(
      "Sigurado ka bang gusto mong mag-logout?",
    ),
    "logout_title": MessageLookupByLibrary.simpleMessage(
      "Kumpirmasyon ng Logout",
    ),
    "low": MessageLookupByLibrary.simpleMessage("Mababa"),
    "low_light": MessageLookupByLibrary.simpleMessage("Mahinang Liwanag"),
    "minutes_ago": MessageLookupByLibrary.simpleMessage("minuto ang nakalipas"),
    "moist": MessageLookupByLibrary.simpleMessage("Basa"),
    "moisture_fairly_moist": MessageLookupByLibrary.simpleMessage(
      "Medyo basa ang lupa. Bantayan laban sa sobrang tubig.",
    ),
    "moisture_low": MessageLookupByLibrary.simpleMessage(
      "Mababa ang halumigmig ng lupa. Magdilig sa lalong madaling panahon.",
    ),
    "moisture_optimal": MessageLookupByLibrary.simpleMessage(
      "Tamang-tama ang halumigmig ng lupa. Maayos ang kondisyon.",
    ),
    "moisture_too_dry": MessageLookupByLibrary.simpleMessage(
      "Sobrang tuyo ng lupa. Kailangan ng irigasyon.",
    ),
    "moisture_too_wet": MessageLookupByLibrary.simpleMessage(
      "Sobrang basa ng lupa. Panganib ng pagkabulok ng ugat.",
    ),
    "municipality": MessageLookupByLibrary.simpleMessage("Bayan"),
    "municipality_amadeo": MessageLookupByLibrary.simpleMessage("Amadeo"),
    "municipality_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang bayan",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Susunod"),
    "next_button": MessageLookupByLibrary.simpleMessage("Susunod"),
    "no": MessageLookupByLibrary.simpleMessage("Hindi"),
    "no_corn_fields": MessageLookupByLibrary.simpleMessage(
      "Walang natagpuang taniman ng mais",
    ),
    "no_data": MessageLookupByLibrary.simpleMessage("Walang Datos"),
    "normal": MessageLookupByLibrary.simpleMessage("Normal"),
    "notifications": MessageLookupByLibrary.simpleMessage("Mga Abiso"),
    "off": MessageLookupByLibrary.simpleMessage("Patay"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "okay": MessageLookupByLibrary.simpleMessage("Okay"),
    "on": MessageLookupByLibrary.simpleMessage("Bukas"),
    "parameter_humidity": MessageLookupByLibrary.simpleMessage("Halumigmig"),
    "parameter_light_intensity": MessageLookupByLibrary.simpleMessage(
      "Lakas ng Liwanag",
    ),
    "parameter_soil_moisture": MessageLookupByLibrary.simpleMessage(
      "Halumigmig ng Lupa",
    ),
    "parameter_soil_ph": MessageLookupByLibrary.simpleMessage(
      "Antas ng pH ng Lupa",
    ),
    "parameter_temperature": MessageLookupByLibrary.simpleMessage(
      "Temperatura",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "password_needs_lowercase": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat may hindi bababa sa isang maliit na titik",
    ),
    "password_needs_number": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat may hindi bababa sa isang numero",
    ),
    "password_needs_special": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat may hindi bababa sa isang espesyal na karakter (!@#\$%^&*)",
    ),
    "password_needs_uppercase": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat may hindi bababa sa isang malaking titik",
    ),
    "password_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang password",
    ),
    "password_too_common": MessageLookupByLibrary.simpleMessage(
      "Ang password na ito ay masyadong common. Mangyaring pumili ng mas malakas na password",
    ),
    "password_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang password ay hindi dapat lumampas sa 128 karakter",
    ),
    "password_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat may hindi bababa sa 6 na karakter",
    ),
    "passwords_dont_match": MessageLookupByLibrary.simpleMessage(
      "Hindi magkatugma ang mga password",
    ),
    "phSensor": MessageLookupByLibrary.simpleMessage("Sensor ng Antas ng pH"),
    "ph_sensor": MessageLookupByLibrary.simpleMessage("PH Antas ng Lupa"),
    "planting_date": MessageLookupByLibrary.simpleMessage(
      "Petsa ng Pagtatanim",
    ),
    "planting_season_description": MessageLookupByLibrary.simpleMessage(
      "Piliin and petsa ng pagtatanim ng mais.",
    ),
    "planting_season_title": MessageLookupByLibrary.simpleMessage(
      "Kailan ka nagtanim?",
    ),
    "poor": MessageLookupByLibrary.simpleMessage("Mahina"),
    "prescriptions_subtitle": m3,
    "prescriptions_title": MessageLookupByLibrary.simpleMessage("Mga Reseta"),
    "privacy_info_intro": MessageLookupByLibrary.simpleMessage(
      "Sa Maize Watch, kami ay nakatuon sa pagprotekta sa pagkapribado ng aming mga gumagamit, lalo na ang mga magsasaka ng mais na nagtitiwala sa amin ng kanilang mahalagang datos sa agrikultura. Ang Impormasyon sa Pagkapribado na ito ay nagbabalangkas kung paano namin kinokolekta, ginagamit, at pinoprotektahan ang iyong impormasyon kapag ginamit mo ang aming platform.",
    ),
    "privacy_info_section1_content": MessageLookupByLibrary.simpleMessage(
      "Upang bigyan ka ng mga insight na batay sa datos at i-optimize ang iyong ani ng mais, kinokolekta ng Maize Watch ang mga sumusunod na uri ng impormasyon:\n\nDatos na Partikular sa Bukid: Lokasyon (mga coordinate ng GPS ng mga bukid), laki at mga hangganan ng bukid, iba\'t ibang pananim, mga petsa ng pagtatanim/pag-aani, at datos ng ani.\nDatos ng Sensor: Antas ng kahalumigmigan/sustansya ng lupa, temperatura (lupa/kapaligiran), humidity, intensity ng liwanag, at iba pang may-katuturang datos sa kapaligiran.\nImpormasyon sa Account: Ang iyong pangalan, impormasyon sa pakikipag-ugnayan, pangalan/ID ng bukid, at mga kredensyal sa pag-login (naka-encrypt).\nDatos ng Paggamit: Mga feature na na-access, oras na ginugol, mga ulat na nabuo, at hindi nagpapakilalang impormasyon ng device.",
    ),
    "privacy_info_section1_title": MessageLookupByLibrary.simpleMessage(
      "1. Impormasyong Kinokolekta Namin:",
    ),
    "privacy_info_section2_content": MessageLookupByLibrary.simpleMessage(
      "Upang Magbigay ng Pangunahing Serbisyo: I-visualize ang pagganap ng bukid, suriin ang mga kondisyon, mag-alok ng mga rekomendasyon, at subaybayan ang pag-unlad.\nUpang Pagbutihin ang Maize Watch: Pagandahin ang mga feature, bumuo ng mga bagong tool, at pagbutihin ang mga modelo (madalas gamit ang hindi nagpapakilala datos).\nPara sa Komunikasyon: Magpadala ng mga update, alerto, at tumugon sa mga katanungan.\nPara sa Seguridad: Tiyakin ang integridad ng platform, pigilan ang pandaraya, at sumunod sa mga legal na tungkulin.",
    ),
    "privacy_info_section2_title": MessageLookupByLibrary.simpleMessage(
      "2. Paano Namin Ginagamit ang Iyong Impormasyon:",
    ),
    "privacy_info_section3_content": MessageLookupByLibrary.simpleMessage(
      "Sa Iyong Pahintulot: Ang datos ay ibinabahagi lamang sa mga partido na iyong inaprubahan (hal., mga consultant).\nMga Tagapagbigay ng Serbisyo: Mga pinagkakatiwalaang tagapagbigay lamang sa ilalim ng mahigpit na kasunduan.\nPinagsama-sama/Hindi Nagpapakilalang Datos: Ginagamit para sa pananaliksik o benchmarking nang hindi ibinubunyag ang mga pagkakakilanlan.\nMga Legal na Kinakailangan: Ibinubunyag lamang kapag legal na kinakailangan.",
    ),
    "privacy_info_section3_title": MessageLookupByLibrary.simpleMessage(
      "3. Pagbabahagi at Pagbubunyag ng Datos:",
    ),
    "privacy_info_section4_content": MessageLookupByLibrary.simpleMessage(
      "Pag-encrypt (sa transit at sa pahinga)\nMahigpit na mga kontrol sa pag-access\nPamamaraan ng mga regular na pag-audit sa seguridad\nMga secure na backup ng datos",
    ),
    "privacy_info_section4_title": MessageLookupByLibrary.simpleMessage(
      "4. Seguridad ng Datos:",
    ),
    "privacy_info_section5_content": MessageLookupByLibrary.simpleMessage(
      "I-access, i-update, o itama ang iyong datos anumang orasHumiling ng kopya ng iyong datos (data portability)\nHumiling ng pagtanggal ng datos (napapailalim sa legal na pagpapanatili)\nMag-opt-out sa mga hindi mahahalagang komunikasyon",
    ),
    "privacy_info_section5_title": MessageLookupByLibrary.simpleMessage(
      "5. Ang Iyong mga Pagpipilian at Karapatan:",
    ),
    "privacy_info_section6_content": MessageLookupByLibrary.simpleMessage(
      "Ang iyong datos ay pinananatili habang aktibo ang iyong account at para sa isang makatwirang panahon pagkatapos upang sumunod sa mga obligasyon at tiyakin ang pagpapatuloy.",
    ),
    "privacy_info_section6_title": MessageLookupByLibrary.simpleMessage(
      "6. Pagpapanatili ng Datos:",
    ),
    "privacy_info_section7_content": MessageLookupByLibrary.simpleMessage(
      "Ang mga update sa Impormasyon sa Pagkapribado na ito ay ipo-post sa aming website o ipapaalam nang naaangkop. Mangyaring suriin ito nang pana-panahon.",
    ),
    "privacy_info_section7_title": MessageLookupByLibrary.simpleMessage(
      "7. Mga Pagbabago sa Impormasyon sa Pagkapribado na Ito:",
    ),
    "privacy_info_title": MessageLookupByLibrary.simpleMessage(
      "Impormasyon sa Pagkapribado ng Maize Watch",
    ),
    "privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Patakaran sa Pagkapribado",
    ),
    "province": MessageLookupByLibrary.simpleMessage("Lalawigan"),
    "province_cavite": MessageLookupByLibrary.simpleMessage("Cavite"),
    "province_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang lalawigan",
    ),
    "r1_silking": MessageLookupByLibrary.simpleMessage("Pagsilk (R1)"),
    "r6_mature": MessageLookupByLibrary.simpleMessage("Ganap na Mais (R6)"),
    "rainfall": MessageLookupByLibrary.simpleMessage("Ulan"),
    "rapid_growth": MessageLookupByLibrary.simpleMessage(
      "Mabilis ang paglago!",
    ),
    "recommendation_apply_fertilizer": MessageLookupByLibrary.simpleMessage(
      "Maglagay ng pataba ayon sa rekomendasyon para sa pinakamainam na paglago",
    ),
    "recommendation_light": MessageLookupByLibrary.simpleMessage(
      "Siguraduhing may tamang liwanag para sa malusog na paglago",
    ),
    "recommendation_soil_ph": MessageLookupByLibrary.simpleMessage(
      "I-adjust ang antas ng pH ng lupa sa rekomendadong antas",
    ),
    "recommendation_temperature": MessageLookupByLibrary.simpleMessage(
      "Subaybayan at panatilihin ang pinakamainam na kondisyon ng temperatura",
    ),
    "recommendation_title": MessageLookupByLibrary.simpleMessage(
      "Mga Rekomendasyon",
    ),
    "recommendation_water": MessageLookupByLibrary.simpleMessage(
      "I-adjust ang iskedyul ng patubig batay sa antas ng halumigmig ng lupa",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("I-refresh"),
    "region": MessageLookupByLibrary.simpleMessage("Rehiyon"),
    "region_calabarzon": MessageLookupByLibrary.simpleMessage(
      "CALABARZON (Rehiyon IV-A)",
    ),
    "region_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang rehiyon",
    ),
    "register": MessageLookupByLibrary.simpleMessage("Magrehistro"),
    "register_corn_button": MessageLookupByLibrary.simpleMessage(
      "Magrehistro ng Mais",
    ),
    "register_corn_field_prompt": MessageLookupByLibrary.simpleMessage(
      "Mangyaring magrehistro ng taniman ng mais upang masimulan ang pagsubaybay.",
    ),
    "register_corn_next": MessageLookupByLibrary.simpleMessage(
      "I-rehistro ang mais",
    ),
    "register_page1_description": MessageLookupByLibrary.simpleMessage(
      "Gumawa ng inyong account sa pamamagitan ng pagbibigay ng inyong personal na impormasyon sa ibaba.",
    ),
    "register_page1_title": MessageLookupByLibrary.simpleMessage(
      "Umpisahan na natin",
    ),
    "register_page2_description": MessageLookupByLibrary.simpleMessage(
      "Ngayon naman ay mag-setup tayo ng inyong login credentials para ma-secure ang inyong account.",
    ),
    "register_page2_title": MessageLookupByLibrary.simpleMessage("Kamusta, "),
    "registration_failed": MessageLookupByLibrary.simpleMessage(
      "Hindi matagumpay ang pagpaparehistro. Pakisubukang muli.",
    ),
    "registration_successful": MessageLookupByLibrary.simpleMessage(
      "Matagumpay ang pagpaparehistro! Mangyaring mag-lagay ng impormasyon tungkol sa mais.",
    ),
    "registration_timeout": MessageLookupByLibrary.simpleMessage(
      "Masyado nang matagal ang paghihintay sa server. Maaaring nalikha na ang iyong account. Subukang mag-login.",
    ),
    "review_and_submit": MessageLookupByLibrary.simpleMessage(
      "Suriin at Isumite",
    ),
    "season_both": MessageLookupByLibrary.simpleMessage("Parehong Panahon"),
    "season_dry": MessageLookupByLibrary.simpleMessage(
      "Panahong Tag-init (Disyembre hanggang Mayo)",
    ),
    "season_wet": MessageLookupByLibrary.simpleMessage(
      "Panahong Tag-ulan (Hunyo hanggang Nobyembre)",
    ),
    "seconds_ago": MessageLookupByLibrary.simpleMessage(
      "segundo ang nakalipas",
    ),
    "see_more": MessageLookupByLibrary.simpleMessage("Tingnan Pa"),
    "select_barangay": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong barangay",
    ),
    "select_date": MessageLookupByLibrary.simpleMessage("Pumili ng Petsa"),
    "select_municipality": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong bayan",
    ),
    "select_province": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong lalawigan",
    ),
    "select_region": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong rehiyon",
    ),
    "sensors": MessageLookupByLibrary.simpleMessage("Mga Sensor"),
    "settings": MessageLookupByLibrary.simpleMessage("Mga Setting"),
    "silks_emerging": MessageLookupByLibrary.simpleMessage(
      "Lumalabas na ang silk mula sa tainga",
    ),
    "soilMoistureSensor": MessageLookupByLibrary.simpleMessage(
      "Sensor ng Halumigmig ng Lupa",
    ),
    "soil_clay": MessageLookupByLibrary.simpleMessage("Luwad"),
    "soil_clay_desc": MessageLookupByLibrary.simpleMessage(
      "Mabigat, humahawak ng tubig",
    ),
    "soil_loam": MessageLookupByLibrary.simpleMessage("Loam"),
    "soil_loamy": MessageLookupByLibrary.simpleMessage("Loam"),
    "soil_loamy_desc": MessageLookupByLibrary.simpleMessage(
      "Halo ng buhangin, lamo, luwad",
    ),
    "soil_moisture": MessageLookupByLibrary.simpleMessage("Halumigmig ng Lupa"),
    "soil_moisture_sensor": MessageLookupByLibrary.simpleMessage(
      "Halumigmig ng Lupa",
    ),
    "soil_peaty": MessageLookupByLibrary.simpleMessage("Pit"),
    "soil_saline": MessageLookupByLibrary.simpleMessage("Alat"),
    "soil_sandy": MessageLookupByLibrary.simpleMessage("Mabuhangin"),
    "soil_sandy_desc": MessageLookupByLibrary.simpleMessage(
      "Magaan, mabilis ang daloy ng tubig",
    ),
    "soil_silt": MessageLookupByLibrary.simpleMessage("Lamo"),
    "soil_silty": MessageLookupByLibrary.simpleMessage("Lamo"),
    "soil_silty_desc": MessageLookupByLibrary.simpleMessage(
      "Makinis, humahawak ng moisture",
    ),
    "soil_type": MessageLookupByLibrary.simpleMessage("Uri ng Lupa"),
    "soil_type_required": MessageLookupByLibrary.simpleMessage(
      "Kinakailangan ang uri ng lupa",
    ),
    "soil_type_title": MessageLookupByLibrary.simpleMessage(
      "Piliin ang uri ng lupa ng iyong bukirin",
    ),
    "soundAndVibrate": MessageLookupByLibrary.simpleMessage("Tunog at Vibrate"),
    "sound_and_vibrate": MessageLookupByLibrary.simpleMessage(
      "Tunog at Panginginig",
    ),
    "stable": MessageLookupByLibrary.simpleMessage("Matatag ang paglago"),
    "status_all_completed_deleted": MessageLookupByLibrary.simpleMessage(
      "Lahat ng tapos nang reseta ay nai-delete na",
    ),
    "status_all_deleted": MessageLookupByLibrary.simpleMessage(
      "Lahat ng reseta ay nai-delete na",
    ),
    "status_prescription_completed": MessageLookupByLibrary.simpleMessage(
      "Minarkahan bilang tapos na ang reseta",
    ),
    "status_prescription_deleted": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na nai-delete ang reseta",
    ),
    "status_prescription_pending": MessageLookupByLibrary.simpleMessage(
      "Minarkahan bilang hindi pa tapos ang reseta",
    ),
    "stay_updated": MessageLookupByLibrary.simpleMessage(
      "Manatiling updated sa iyong sakahan!",
    ),
    "step1_title": MessageLookupByLibrary.simpleMessage("Bukirin"),
    "step2_title": MessageLookupByLibrary.simpleMessage("Lupa"),
    "step3_title": MessageLookupByLibrary.simpleMessage("Mais"),
    "step4_title": MessageLookupByLibrary.simpleMessage("Panahon"),
    "step5_title": MessageLookupByLibrary.simpleMessage("Edad"),
    "submit": MessageLookupByLibrary.simpleMessage("Isumite"),
    "submit_button": MessageLookupByLibrary.simpleMessage("Isumite"),
    "tassels_appearing": MessageLookupByLibrary.simpleMessage(
      "Lumalabas na ang mga bulaklak sa tuktok",
    ),
    "tempHumidSensor": MessageLookupByLibrary.simpleMessage(
      "Sensor ng Temperatura at Humidity",
    ),
    "temp_humid_sensor": MessageLookupByLibrary.simpleMessage(
      "Temperatura at Humidity",
    ),
    "temperature": MessageLookupByLibrary.simpleMessage("Temperatura"),
    "terms_intro": MessageLookupByLibrary.simpleMessage(
      "Maligayang pagdating sa Maize Watch. Sa pamamagitan ng pag-access o paggamit ng aming platform, mga serbisyo, at mga kaugnay na tool, sumasang-ayon kang sumunod at mapailalim sa Mga Tuntunin ng Paggamit na ito. Kung hindi ka sumasang-ayon sa anumang bahagi ng mga tuntuning ito, mangyaring huwag gamitin ang Maize Watch.",
    ),
    "terms_of_service": MessageLookupByLibrary.simpleMessage(
      "Mga Tuntunin ng Serbisyo",
    ),
    "terms_of_use": MessageLookupByLibrary.simpleMessage(
      "Mga Tuntunin ng Paggamit",
    ),
    "terms_section1_content": MessageLookupByLibrary.simpleMessage(
      "Maaari mo lamang gamitin ang Maize Watch para sa mga legal na layunin at alinsunod sa mga tuntuning ito.\nResponsibilidad mong panatilihing kumpidensyal ang iyong mga kredensyal sa account at lahat ng aktibidad sa ilalim ng iyong account.\nSumasang-ayon kang hindi gagamitin nang mali ang platform, makialam sa seguridad o pag-andar nito, o tangkaing hindi awtorisadong pag-access sa anumang bahagi ng system.",
    ),
    "terms_section1_title": MessageLookupByLibrary.simpleMessage(
      "1. Paggamit ng Platform:",
    ),
    "terms_section2_content": MessageLookupByLibrary.simpleMessage(
      "Pinapanatili mo ang ganap na pagmamay-ari ng iyong datos ng bukid at impormasyon ng sensor.\nSa pamamagitan ng paggamit ng Maize Watch, binibigyan mo kami ng pahintulot na suriin ang iyong datos upang magbigay ng mga personalized na insight at pagbutihin ang pagganap ng platform.\nHindi namin ibabahagi ang iyong nakakapagpakilalang datos nang wala ang iyong malinaw na pahintulot, gaya ng nakabalangkas sa aming Patakaran sa Pagkapribado.",
    ),
    "terms_section2_title": MessageLookupByLibrary.simpleMessage(
      "2. Pagmamay-ari at Paggamit ng Datos:",
    ),
    "terms_section3_content": MessageLookupByLibrary.simpleMessage(
      "Ang lahat ng nilalaman sa Maize Watch, kabilang ang mga visualization, software, text, graphics, at logo, ay pag-aari ng Maize Watch o ng mga naglilisensya nito.\nHindi mo maaaring kopyahin, ipamahagi, baguhin, o lumikha ng mga gawaing hango nang wala ang aming nakasulat na pahintulot.",
    ),
    "terms_section3_title": MessageLookupByLibrary.simpleMessage(
      "3. Intelektwal na Ari-arian:",
    ),
    "terms_section4_content": MessageLookupByLibrary.simpleMessage(
      "Taglay namin ang karapatang suspindihin o wakasan ang iyong pag-access sa Maize Watch anumang oras kung lalabag ka sa mga tuntuning ito, aabusuhin ang platform, o makisali sa anumang pag-uugali na nakakaabala sa serbisyo para sa ibang mga gumagamit.",
    ),
    "terms_section4_title": MessageLookupByLibrary.simpleMessage(
      "4. Pagwawakas ng Account:",
    ),
    "terms_section5_content": MessageLookupByLibrary.simpleMessage(
      "Nagbibigay ang Maize Watch ng mga insight na batay sa datos upang suportahan ang mga desisyon sa agrikultura. Ang mga huling desisyon tungkol sa mga kasanayan sa pagsasaka ay nananatiling iyong responsibilidad.\nHindi namin ginagarantiya ang mga partikular na resulta ng ani o kakayahang kumita dahil ang tagumpay sa agrikultura ay nakasalalay sa maraming hindi makontrol na mga kadahilanan.\nAng platform ay ibinibigay nang “as-is” at “as available” nang walang anumang uri ng mga garantiya.",
    ),
    "terms_section5_title": MessageLookupByLibrary.simpleMessage(
      "5. Mga Disclaimer:",
    ),
    "terms_section6_content": MessageLookupByLibrary.simpleMessage(
      "Sa lawak na pinahihintulutan ng batas, ang Maize Watch ay hindi mananagot para sa anumang hindi direkta, incidental, o kinahihinatnang mga pinsala na nagmumula sa iyong paggamit ng platform, kabilang ang pagkawala ng datos, pagkawala ng ani, o mga desisyon na may kaugnayan sa bukid na ginawa batay sa aming analytics.",
    ),
    "terms_section6_title": MessageLookupByLibrary.simpleMessage(
      "6. Limitasyon ng Pananagutan:",
    ),
    "terms_section7_content": MessageLookupByLibrary.simpleMessage(
      "Maaari naming i-update ang Mga Tuntunin ng Paggamit na ito paminsan-minsan. Ang mga materyal na pagbabago ay ipapaalam sa pamamagitan ng aming website o sa pamamagitan ng email. Ang iyong patuloy na paggamit ng Maize Watch pagkatapos ng mga pagbabago ay ituturing na pagtanggap sa mga bagong tuntunin.",
    ),
    "terms_section7_title": MessageLookupByLibrary.simpleMessage(
      "7. Mga Update sa Mga Tuntunin:",
    ),
    "textSizeLabel": MessageLookupByLibrary.simpleMessage("Laki ng Teksto"),
    "tooltip_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Tanggalin ang reseta",
    ),
    "tooltip_refresh_prescriptions": MessageLookupByLibrary.simpleMessage(
      "I-refresh ang mga reseta",
    ),
    "translate": MessageLookupByLibrary.simpleMessage("Isalin"),
    "try_again": MessageLookupByLibrary.simpleMessage("Subukang Muli"),
    "user_id_not_found": MessageLookupByLibrary.simpleMessage(
      "Hindi mahanap ang iyong User ID",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Pangalan ng Gamit"),
    "username_already_exists": MessageLookupByLibrary.simpleMessage(
      "Ginagamit na ang username. Pakisubukang muli gamit ang ibang username.",
    ),
    "username_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Ang username ay hindi dapat may magkakasunod na tuldok o underscore",
    ),
    "username_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang username ay pwedeng may mga titik, numero, underscore, at tuldok lamang",
    ),
    "username_invalid_end": MessageLookupByLibrary.simpleMessage(
      "Ang username ay dapat magtapos sa titik o numero",
    ),
    "username_invalid_start": MessageLookupByLibrary.simpleMessage(
      "Ang username ay dapat magsimula sa titik o numero",
    ),
    "username_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang username",
    ),
    "username_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang username ay hindi dapat lumampas sa 20 karakter",
    ),
    "username_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang username ay dapat may hindi bababa sa 3 karakter",
    ),
    "v3_early_growth": MessageLookupByLibrary.simpleMessage(
      "Unang Paglago (V3)",
    ),
    "v8_mid_growth": MessageLookupByLibrary.simpleMessage(
      "Gitnang Paglago (V8)",
    ),
    "valid_ph_number_required": MessageLookupByLibrary.simpleMessage(
      "Maglagay ng wastong numero ng telepono sa Pilipinas",
    ),
    "variety_field_corn": MessageLookupByLibrary.simpleMessage(
      "Pang-maisang Bukid",
    ),
    "variety_field_corn_desc": MessageLookupByLibrary.simpleMessage(
      "Para sa hayop o ethanol",
    ),
    "variety_flint": MessageLookupByLibrary.simpleMessage("Flint"),
    "variety_flint_corn": MessageLookupByLibrary.simpleMessage(
      "Makintab na Mais",
    ),
    "variety_flint_corn_desc": MessageLookupByLibrary.simpleMessage(
      "Makukulay, palamuti",
    ),
    "variety_glutinous": MessageLookupByLibrary.simpleMessage("Malagkit"),
    "variety_popcorn": MessageLookupByLibrary.simpleMessage("Popcorn"),
    "variety_popcorn_desc": MessageLookupByLibrary.simpleMessage(
      "Para sa popcorn",
    ),
    "variety_purple": MessageLookupByLibrary.simpleMessage("Ube"),
    "variety_sweet": MessageLookupByLibrary.simpleMessage("Matamis"),
    "variety_sweet_corn": MessageLookupByLibrary.simpleMessage(
      "Matamis na Mais",
    ),
    "variety_sweet_corn_desc": MessageLookupByLibrary.simpleMessage(
      "Para sa pagkain ng tao",
    ),
    "variety_white_fodder": MessageLookupByLibrary.simpleMessage(
      "Puting Fodder",
    ),
    "variety_yellow_dent": MessageLookupByLibrary.simpleMessage(
      "Dilaw na Dent",
    ),
    "ve_emergence": MessageLookupByLibrary.simpleMessage("Pagsibol (VE)"),
    "versionInfo": MessageLookupByLibrary.simpleMessage("bersyon 1.0.0"),
    "very_bright": MessageLookupByLibrary.simpleMessage("Napakaliwanag"),
    "very_dry": MessageLookupByLibrary.simpleMessage("Sobrang Tuyo"),
    "very_high": MessageLookupByLibrary.simpleMessage("Napakataas"),
    "vibrate": MessageLookupByLibrary.simpleMessage("Panginginig"),
    "vibrationOnly": MessageLookupByLibrary.simpleMessage("Vibrasyon Lamang"),
    "vibration_only": MessageLookupByLibrary.simpleMessage(
      "Panginginig Lamang",
    ),
    "view_details": MessageLookupByLibrary.simpleMessage("Tingnan ang Detalye"),
    "view_more_details": MessageLookupByLibrary.simpleMessage(
      "Tingnan ang karagdagang detalye",
    ),
    "vt_tasseling": MessageLookupByLibrary.simpleMessage("Pagbubulaklak (VT)"),
    "welcome": MessageLookupByLibrary.simpleMessage(
      "Maligayang pagdating sa Maize Watch",
    ),
    "wet": MessageLookupByLibrary.simpleMessage("Basang-basa"),
    "yes": MessageLookupByLibrary.simpleMessage("Oo"),
    "zip_code": MessageLookupByLibrary.simpleMessage("Zip Code"),
    "zip_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Mangyaring maglagay ng wastong zip code",
    ),
    "zip_code_optional": MessageLookupByLibrary.simpleMessage(
      "Zip Code (Opsyonal)",
    ),
  };
}
