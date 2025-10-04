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

  static String m0(category) => "Kategorya: ${category}";

  static String m1(fieldName, farmName) =>
      "Congratulations! Ang inyong field na \"${fieldName}\" sa farm na \"${farmName}\" ay matagumpay na narehistro.";

  static String m2(count) => "${count} araw";

  static String m3(count) => "${count}d na ang nakalipas";

  static String m4(days) => "${days}d na lang";

  static String m5(count) => "${count} araw na natitira";

  static String m6(days, rate) =>
      "${days} araw hanggang sa susunod na yugto (${rate}/araw)";

  static String m7(deadline) => "Deadline: ${deadline}";

  static String m8(index) => "Device ${index}";

  static String m9(count) =>
      "${Intl.plural(count, zero: 'Walang nakarehistrong device', one: '1 Nakarehistrong Device', other: '${count} Nakarehistrong Device')}";

  static String m10(parameter) =>
      "Sigurado ba kayo na gusto ninyong tanggalin ang ${parameter} na reseta na ito?";

  static String m11(days) => "V8 - Yugto ng Ikawalong Dahon (${days} araw)";

  static String m12(days) => "VE - Yugto ng Pagsibol (${days} araw)";

  static String m13(filter) =>
      "Walang nahanap na mga reseta para sa \"${filter}\"";

  static String m14(error) => "Error sa pag-load ng mga prototype: ${error}";

  static String m15(error) => "Error sa pag-unsync ng prototype: ${error}";

  static String m16(error) => "Nabigo sa pag-update ng profile: ${error}";

  static String m17(filters) => "Na-filter ng: ${filters}";

  static String m18(feature) => "Paparating na ang gabay para sa ${feature}!";

  static String m19(count) => "${count}h na ang nakalipas";

  static String m20(hours) => "${hours}h na lang";

  static String m21(platform) =>
      "Malapit na ang pagsasama para sa ${platform}!";

  static String m22(language) => "Ang wika ay napalitan sa ${language}";

  static String m23(days) => "R6 - Yugto ng Pagiging Hinog (${days} araw)";

  static String m24(count) => "${count}m na ang nakalipas";

  static String m25(count) =>
      "Mayroon kayong ${count} na bagong farm tasks na kailangang kumpletuhin";

  static String m26(error) =>
      "Nabigo sa pag-update ng notification settings: ${error}";

  static String m27(enabled) => "Notifications enabled: ${enabled}";

  static String m28(status) => "Notifications ${status}";

  static String m29(seconds) => "Ipadala ulit sa ${seconds} segundo";

  static String m30(sensorName) =>
      "Ang ${sensorName} sensor ay offline na ng mahigit sa 30 minuto.";

  static String m31(sensorName) =>
      "Ang ${sensorName} sensor ay offline na ng mahigit sa 30 minuto.";

  static String m32(days) => "R1 - Yugto ng Pagkakaroon ng Silk (${days} araw)";

  static String m33(days) =>
      "VT - Yugto ng Pagkakaroon ng Tassel (${days} araw)";

  static String m34(days) => "V3 - Yugto ng Ikatlong Dahon (${days} araw)";

  static String m35(timeline) => "Timeline: ${timeline}";

  static String m36(urgency) => "Kadalian: ${urgency}";

  static String m37(phoneNumber) =>
      "Nagpadala kami ng 6-digit verification code sa ${phoneNumber}. Pakilagay ito sa ibaba para magpatuloy.";

  static String m38(status) => "Vibration only ${status}";

  static String m39(count) =>
      "Mayroon kayong ${count} na bagong farm tasks na kailangang kumpletuhin";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Tungkol"),
    "aboutApp": MessageLookupByLibrary.simpleMessage(
      "Ang Maize Watch ay isang application para sa pagmomonitor ng ani na idinisenyo para matulungan ang mga magsasaka na subaybayan ang paglaki ng mais at mabilis na makilala ang mga problema.",
    ),
    "about_app": MessageLookupByLibrary.simpleMessage(
      "Ang maize-watch mobile app ay nagmumungkahi ng isang makabagong, IoT-driven na sistema ng pagmomonitor ng mais na pinalakas ng prescriptive analytics. Ang sistemang ito ay hindi lamang nagbibigay ng real-time data sa kalusugan ng ani at mga kondisyon ng kapaligiran kundi ginagamit din ang mga datong ito para magbigay ng praktikal na payo, na lalong nag-o-optimize sa kalidad at ani ng mais.",
    ),
    "about_user": MessageLookupByLibrary.simpleMessage("Tungkol sa User"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action_check_all": MessageLookupByLibrary.simpleMessage("I-check Lahat"),
    "action_delete": MessageLookupByLibrary.simpleMessage("Tanggalin"),
    "action_delete_all": MessageLookupByLibrary.simpleMessage(
      "Tanggalin Lahat",
    ),
    "action_delete_completed": MessageLookupByLibrary.simpleMessage(
      "Tanggalin ang Tapos na",
    ),
    "action_uncheck_all": MessageLookupByLibrary.simpleMessage(
      "I-uncheck Lahat",
    ),
    "active": MessageLookupByLibrary.simpleMessage("Aktibo"),
    "active_sensor_is_sending_data_to_thingspeak":
        MessageLookupByLibrary.simpleMessage(
          "Aktibo: Ang sensor ay nagpapadala ng data sa ThingSpeak",
        ),
    "add": MessageLookupByLibrary.simpleMessage("Magdagdag"),
    "add_another_device": MessageLookupByLibrary.simpleMessage(
      "Magdagdag ng Isa Pang Device",
    ),
    "add_device": MessageLookupByLibrary.simpleMessage("Magdagdag ng Device"),
    "add_field": MessageLookupByLibrary.simpleMessage("Magdagdag ng Field"),
    "add_field_information": MessageLookupByLibrary.simpleMessage(
      "Magdagdag ng field information",
    ),
    "add_your_first_monitoring_device_to_get_started":
        MessageLookupByLibrary.simpleMessage(
          "Ilagay ang iyong unang monitoring device para magsimula",
        ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "address_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang address ay naglalaman ng hindi wastong mga character",
    ),
    "address_needs_alphanumeric": MessageLookupByLibrary.simpleMessage(
      "Ang address ay dapat maglaman ng hindi bababa sa isang titik o numero",
    ),
    "address_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang address",
    ),
    "address_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang address ay hindi dapat lumampas sa 200 na character",
    ),
    "address_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang address ay dapat hindi bababa sa 10 na character",
    ),
    "agreement_prefix": MessageLookupByLibrary.simpleMessage(
      "Sa pag-login, sumasang-ayon kayo sa aming ",
    ),
    "agreement_suffix": MessageLookupByLibrary.simpleMessage("."),
    "ai_powered_insights_and_recommendations":
        MessageLookupByLibrary.simpleMessage(
          "Mga rekomendasyon at pananaw mula sa AI",
        ),
    "all": MessageLookupByLibrary.simpleMessage("Lahat"),
    "all_clear": MessageLookupByLibrary.simpleMessage("Lahat Malinaw"),
    "all_farm_operations_up_to_date": MessageLookupByLibrary.simpleMessage(
      "Lahat ng farm operations ay updated na.",
    ),
    "all_fields": MessageLookupByLibrary.simpleMessage("Lahat ng Field"),
    "all_fields_required": MessageLookupByLibrary.simpleMessage(
      "Lahat ng field ay kailangan.",
    ),
    "analytics": MessageLookupByLibrary.simpleMessage("Analytics"),
    "analytics_guide": MessageLookupByLibrary.simpleMessage(
      "Gabay sa Analitika",
    ),
    "analytics_reports": MessageLookupByLibrary.simpleMessage(
      "Analitika at Ulat",
    ),
    "and": MessageLookupByLibrary.simpleMessage(" at "),
    "appName": MessageLookupByLibrary.simpleMessage("Maize Watch"),
    "app_information": MessageLookupByLibrary.simpleMessage(
      "Impormasyon ng App",
    ),
    "app_performance": MessageLookupByLibrary.simpleMessage(
      "Performance ng App",
    ),
    "app_settings": MessageLookupByLibrary.simpleMessage("Mga Setting ng App"),
    "apply": MessageLookupByLibrary.simpleMessage("Ilapat"),
    "apr": MessageLookupByLibrary.simpleMessage("Abr"),
    "april": MessageLookupByLibrary.simpleMessage("Abr"),
    "are_you_sure_you_want_to_delete_this_device_this_action_cannot_be_undone":
        MessageLookupByLibrary.simpleMessage(
          "Sigurado ba kayo na gusto ninyong i-delete ang device na ito? Hindi na ito maibabalik.",
        ),
    "are_you_sure_you_want_to_log_out": MessageLookupByLibrary.simpleMessage(
      "Sigurado ba kayo na gusto ninyong log out?",
    ),
    "asap": MessageLookupByLibrary.simpleMessage("KAAGAD"),
    "attention": MessageLookupByLibrary.simpleMessage("ATENSYON"),
    "aug": MessageLookupByLibrary.simpleMessage("Ago"),
    "august": MessageLookupByLibrary.simpleMessage("Ago"),
    "authentication_failed": MessageLookupByLibrary.simpleMessage(
      "Nabigo ang authentication. Pakisubukan ulit.",
    ),
    "authentication_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang authentication",
    ),
    "available": MessageLookupByLibrary.simpleMessage("Available"),
    "available_in_english_and_filipino": MessageLookupByLibrary.simpleMessage(
      "Available sa Ingles at Filipino",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Bumalik"),
    "back_button": MessageLookupByLibrary.simpleMessage("Bumalik"),
    "back_online": MessageLookupByLibrary.simpleMessage("Bumalik Online"),
    "back_to_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Bumalik sa mga Reseta",
    ),
    "barangay": MessageLookupByLibrary.simpleMessage("Barangay"),
    "barangay_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang barangay",
    ),
    "bright": MessageLookupByLibrary.simpleMessage("Maliwanag"),
    "button_retry": MessageLookupByLibrary.simpleMessage("Subukan Ulit"),
    "can_i_use_the_app_without_internet": MessageLookupByLibrary.simpleMessage(
      "Maaari ko bang gamitin ang app nang walang internet?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Kanselahin"),
    "category": MessageLookupByLibrary.simpleMessage("Kategorya"),
    "category_filter": m0,
    "category_humidity_management": MessageLookupByLibrary.simpleMessage(
      "Pamamahala ng Halumigmig",
    ),
    "category_irrigation": MessageLookupByLibrary.simpleMessage("Irigasyon"),
    "category_light_management": MessageLookupByLibrary.simpleMessage(
      "Pamamahala ng Liwanag",
    ),
    "category_soil_treatment": MessageLookupByLibrary.simpleMessage(
      "Paggagamot ng Lupa",
    ),
    "category_temperature_management": MessageLookupByLibrary.simpleMessage(
      "Pamamahala ng Temperatura",
    ),
    "channel_id": MessageLookupByLibrary.simpleMessage("ID ng Channel"),
    "check_farm": MessageLookupByLibrary.simpleMessage("Suriin ang Sakahan"),
    "check_notification_status": MessageLookupByLibrary.simpleMessage(
      "Suriin ang Status ng Notification",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("SINUSURI..."),
    "checking_authentication": MessageLookupByLibrary.simpleMessage(
      "Sinusuri ang authentication...",
    ),
    "checking_if_sensors_are_actively_sending_data_to_thingspeak":
        MessageLookupByLibrary.simpleMessage(
          "Sinusuri kung ang mga sensor ay aktibong nagpapadala ng data sa ThingSpeak",
        ),
    "clay_soil": MessageLookupByLibrary.simpleMessage("Luwad na lupa"),
    "clear_all": MessageLookupByLibrary.simpleMessage("I-clear Lahat"),
    "close": MessageLookupByLibrary.simpleMessage("Isara"),
    "cloudy": MessageLookupByLibrary.simpleMessage("Maulap"),
    "common_problems_and_solutions_for_sensor_connectivity":
        MessageLookupByLibrary.simpleMessage(
          "Mga karaniwang problema at solusyon sa koneksyon ng sensor",
        ),
    "complete": MessageLookupByLibrary.simpleMessage("Kumpleto"),
    "complete_farm_registration_to_start_monitoring":
        MessageLookupByLibrary.simpleMessage(
          "Kumpletuhin ang farm registration para magsimula ng pagmomonitor",
        ),
    "complete_walkthrough_for_new_users": MessageLookupByLibrary.simpleMessage(
      "Kumpletong gabay para sa mga bagong gumagamit",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Tapos na"),
    "configure_sensor_settings": MessageLookupByLibrary.simpleMessage(
      "I-configure ang sensor settings",
    ),
    "confirm_password": MessageLookupByLibrary.simpleMessage(
      "Kumpirmahin ang Password",
    ),
    "confirm_password_required": MessageLookupByLibrary.simpleMessage(
      "Pakikumpirmahin ang inyong password",
    ),
    "confirm_unsync": MessageLookupByLibrary.simpleMessage(
      "Kumpirmahin ang unsync",
    ),
    "confirm_your_farm_data": MessageLookupByLibrary.simpleMessage(
      "Kumpirmahin ang Inyong Farm Data",
    ),
    "congratulations_field_registered": m1,
    "connect_to_monitoring_system": MessageLookupByLibrary.simpleMessage(
      "I-connect sa monitoring system",
    ),
    "connecting_sensors": MessageLookupByLibrary.simpleMessage(
      "Pag-connect ng Sensors",
    ),
    "connection_error": MessageLookupByLibrary.simpleMessage(
      "May error sa koneksyon. Pakisuri ang inyong internet at subukan ulit.",
    ),
    "connection_timeout": MessageLookupByLibrary.simpleMessage(
      "Nag-timeout ang koneksyon. Pakisuri ang inyong internet connection.",
    ),
    "contactUs": MessageLookupByLibrary.simpleMessage(
      "Makipag-ugnayan sa amin sa:",
    ),
    "contact_information_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Darating na ang contact information!",
    ),
    "contact_number": MessageLookupByLibrary.simpleMessage(
      "Numero ng Telepono",
    ),
    "contact_number_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang contact number ay dapat nasa format na 09xxxxxxxxx (hal., 09194022808)",
    ),
    "contact_number_invalid_length": MessageLookupByLibrary.simpleMessage(
      "Ang numero ng telepono ay dapat eksaktong 10 na digit (walang +63)",
    ),
    "contact_number_invalid_prefix": MessageLookupByLibrary.simpleMessage(
      "Hindi wastong prefix ng Philippine mobile number",
    ),
    "contact_number_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang numero ng telepono",
    ),
    "contact_support": MessageLookupByLibrary.simpleMessage(
      "Makipag-ugnayan at Suporta",
    ),
    "continue_to_dashboard": MessageLookupByLibrary.simpleMessage(
      "Magpatuloy sa Dashboard",
    ),
    "continue_to_field_registration": MessageLookupByLibrary.simpleMessage(
      "Magpatuloy sa Pagrehistro ng Field",
    ),
    "continue_to_registration": MessageLookupByLibrary.simpleMessage(
      "Magpatuloy sa Registration",
    ),
    "corn": MessageLookupByLibrary.simpleMessage("Mais"),
    "corn_age_title": MessageLookupByLibrary.simpleMessage(
      "Ilang araw na ang inyong mais?",
    ),
    "corn_condition": MessageLookupByLibrary.simpleMessage("Kalagayan ng Mais"),
    "corn_growth": MessageLookupByLibrary.simpleMessage("Paglaki ng Mais"),
    "corn_registration": MessageLookupByLibrary.simpleMessage(
      "Pagrehistro ng Mais",
    ),
    "corn_variety": MessageLookupByLibrary.simpleMessage("Uri ng Mais"),
    "corn_variety_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang uri ng mais",
    ),
    "corn_variety_title": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong gustong uri ng mais",
    ),
    "critical": MessageLookupByLibrary.simpleMessage("Kritikal"),
    "critical_stress": MessageLookupByLibrary.simpleMessage(
      "Kritikal na stress",
    ),
    "crop_condition_critical_stress": MessageLookupByLibrary.simpleMessage(
      "Kritikal na stress",
    ),
    "crop_condition_healthy": MessageLookupByLibrary.simpleMessage("Malusog"),
    "crop_condition_high_stress": MessageLookupByLibrary.simpleMessage(
      "Mataas na stress",
    ),
    "crop_condition_moderate_stress": MessageLookupByLibrary.simpleMessage(
      "Katamtamang stress",
    ),
    "crop_condition_subtitle": MessageLookupByLibrary.simpleMessage(
      "Suriin ang kasalukuyang kalagayan ng inyong mais at makakuha ng personalized na mga rekomendasyon.",
    ),
    "crop_condition_title": MessageLookupByLibrary.simpleMessage(
      "Kalagayan ng Ani",
    ),
    "crop_excellent": MessageLookupByLibrary.simpleMessage(
      "Ang inyong mga ani ay nasa napakagaling na kalagayan.",
    ),
    "crop_health": MessageLookupByLibrary.simpleMessage("Kalusugan ng Ani"),
    "crop_health_status": MessageLookupByLibrary.simpleMessage(
      "Kalagayan ng Kalusugan ng Tanim",
    ),
    "crop_is_growing_well_with_minimal_stress":
        MessageLookupByLibrary.simpleMessage(
          "Ang ani ay nag-grow na well na may minimal na stress",
        ),
    "crop_is_growing_with_some_stress_factors":
        MessageLookupByLibrary.simpleMessage(
          "Ang ani ay nag-grow na may ilang stress factors",
        ),
    "crop_needs_attention_several_high_stress_factors_detected":
        MessageLookupByLibrary.simpleMessage(
          "Ang ani ay nangangailangan ng atensyon - maraming mataas na stress factors na nakita",
        ),
    "crop_okay": MessageLookupByLibrary.simpleMessage(
      "Ang inyong mga ani ay maayos naman. Subaybayan nang mabuti.",
    ),
    "crop_requires_immediate_attention_multiple_high_stress_factors_detected":
        MessageLookupByLibrary.simpleMessage(
          "Ang ani ay nangangailangan ng immeditang atensyon - maraming mataas na stress factors na nakita",
        ),
    "crop_risk": MessageLookupByLibrary.simpleMessage(
      "Ang mga ani ay nasa panganib! Kailangan ng agarang aksyon.",
    ),
    "current_growth_stage": MessageLookupByLibrary.simpleMessage(
      "Kasalukuyang Growth Stage",
    ),
    "current_stage": MessageLookupByLibrary.simpleMessage("Kasalukuyang Yugto"),
    "dashboard_title": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "data_collected_over_past_7_days": MessageLookupByLibrary.simpleMessage(
      "Data na nakolekta sa nakaraang 7 araw",
    ),
    "data_not_updating": MessageLookupByLibrary.simpleMessage(
      "Hindi Nag-a-update ang Datos",
    ),
    "data_update_issues": MessageLookupByLibrary.simpleMessage(
      "Mga Isyu sa Pag-update ng Datos",
    ),
    "days": m2,
    "days_ago": m3,
    "days_left": m4,
    "days_remaining": m5,
    "days_since_planting": MessageLookupByLibrary.simpleMessage(
      "Araw Mula sa Pagtatanim",
    ),
    "days_to_next_stage": m6,
    "deadline": MessageLookupByLibrary.simpleMessage("Takdang Oras"),
    "deadline_colon": m7,
    "debug_data_view": MessageLookupByLibrary.simpleMessage(
      "Pagtingin ng Debug Data",
    ),
    "debug_section": MessageLookupByLibrary.simpleMessage("Debug Section"),
    "dec": MessageLookupByLibrary.simpleMessage("Dis"),
    "december": MessageLookupByLibrary.simpleMessage("Dis"),
    "declining": MessageLookupByLibrary.simpleMessage("Bumababa ang paglaki"),
    "default_farm": MessageLookupByLibrary.simpleMessage("Default Farm"),
    "default_user": MessageLookupByLibrary.simpleMessage("magsasaka"),
    "delete": MessageLookupByLibrary.simpleMessage("Tanggalin"),
    "delete_device": MessageLookupByLibrary.simpleMessage(
      "I-delete ang Device",
    ),
    "delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Tanggalin ang Reseta",
    ),
    "delete_prescription_confirmation": MessageLookupByLibrary.simpleMessage(
      "Sigurado ba kayo na gusto ninyong tanggalin ang tapos na reseta na ito? Ang aksyong ito ay hindi na mababawi.",
    ),
    "description": MessageLookupByLibrary.simpleMessage(
      "I-maximize ang inyong ani, i-minimize ang inyong mga alalahanin.",
    ),
    "description_prescription": MessageLookupByLibrary.simpleMessage(
      "Paglalarawan",
    ),
    "device": m8,
    "device_id_hint": MessageLookupByLibrary.simpleMessage("ID ng Device *"),
    "device_id_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang ID ng Device",
    ),
    "device_name_hint": MessageLookupByLibrary.simpleMessage(
      "Pangalan ng Device *",
    ),
    "device_name_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang pangalan ng device",
    ),
    "device_registration": MessageLookupByLibrary.simpleMessage(
      "Pagrehistro ng Device",
    ),
    "device_settings": MessageLookupByLibrary.simpleMessage(
      "Mga Setting ng Device",
    ),
    "device_status": MessageLookupByLibrary.simpleMessage("Status ng Device"),
    "devices_registered": m9,
    "dialog_delete_all_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Tanggalin Lahat ng Reseta",
    ),
    "dialog_delete_all_prescriptions_confirm": MessageLookupByLibrary.simpleMessage(
      "Sigurado ba kayo na gusto ninyong tanggalin ang LAHAT ng reseta? Ang aksyong ito ay hindi na mababawi.",
    ),
    "dialog_delete_completed_prescriptions":
        MessageLookupByLibrary.simpleMessage("Tanggalin ang Tapos na Reseta"),
    "dialog_delete_completed_prescriptions_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Sigurado ba kayo na gusto ninyong tanggalin ang lahat ng tapos na reseta?",
        ),
    "dialog_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Tanggalin ang Reseta",
    ),
    "dialog_delete_prescription_confirm": m10,
    "dim": MessageLookupByLibrary.simpleMessage("Madilim"),
    "dismiss": MessageLookupByLibrary.simpleMessage("Tanggalin"),
    "done": MessageLookupByLibrary.simpleMessage("TAPOS"),
    "dry": MessageLookupByLibrary.simpleMessage("Tuyo"),
    "e_g_field_sensor_1": MessageLookupByLibrary.simpleMessage(
      "hal. Field Sensor 1",
    ),
    "early_vegetative": MessageLookupByLibrary.simpleMessage(
      "Maagang Vegetatibo",
    ),
    "early_vegetative_growth_rapid_leaf_development":
        MessageLookupByLibrary.simpleMessage(
          "Maagang paglaking vegetatibo - mabilis na pag-unlad ng dahon",
        ),
    "early_vegetative_stage": MessageLookupByLibrary.simpleMessage(
      "Maagang Yugto ng Vegetatibo",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("I-edit"),
    "edit_details": MessageLookupByLibrary.simpleMessage("I-edit ang Detalye"),
    "edit_device": MessageLookupByLibrary.simpleMessage("I-edit ang Device"),
    "edit_settings": MessageLookupByLibrary.simpleMessage(
      "I-edit ang mga Setting",
    ),
    "eighth_leaf_stage": m11,
    "email_support": MessageLookupByLibrary.simpleMessage("Suporta sa Email"),
    "emergence": MessageLookupByLibrary.simpleMessage("Pagsibol"),
    "emergence_stage": m12,
    "empty_no_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Walang nahanap na mga reseta",
    ),
    "empty_no_prescriptions_filter": m13,
    "enable": MessageLookupByLibrary.simpleMessage("I-enable"),
    "enableNotifications": MessageLookupByLibrary.simpleMessage(
      "Paganahin ang Notifications",
    ),
    "enable_notifications": MessageLookupByLibrary.simpleMessage(
      "Paganahin ang Notifications",
    ),
    "english": MessageLookupByLibrary.simpleMessage("Ingles"),
    "enter_6_digit_code": MessageLookupByLibrary.simpleMessage(
      "Ilagay ang 6-digit code",
    ),
    "enter_barangay": MessageLookupByLibrary.simpleMessage(
      "Ilagay ang Barangay",
    ),
    "enter_unique_device_id": MessageLookupByLibrary.simpleMessage(
      "Ilagay ang unique device ID",
    ),
    "enter_username": MessageLookupByLibrary.simpleMessage(
      "Ilagay ang inyong username",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "error_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Error sa pagtanggal ng reseta",
    ),
    "error_delete_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Error sa pagtanggal ng mga reseta",
    ),
    "error_deleting_prescription": MessageLookupByLibrary.simpleMessage(
      "Error sa pagtanggal ng reseta",
    ),
    "error_invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Mali ang username o password. Pakisuri ang inyong credentials at subukan ulit.",
    ),
    "error_load_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Nabigo sa pag-load ng mga reseta",
    ),
    "error_loading_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Error sa pag-load ng mga reseta",
    ),
    "error_loading_prototypes": m14,
    "error_marking_complete": MessageLookupByLibrary.simpleMessage(
      "Error sa pagmarka ng reseta bilang tapos na",
    ),
    "error_marking_incomplete": MessageLookupByLibrary.simpleMessage(
      "Error sa pagmarka ng reseta bilang hindi pa tapos",
    ),
    "error_no_internet": MessageLookupByLibrary.simpleMessage(
      "Walang internet connection. Pakisuri ang inyong koneksyon at subukan ulit.",
    ),
    "error_server": MessageLookupByLibrary.simpleMessage(
      "May problema sa server. Pakisubukan ulit mamaya.",
    ),
    "error_timeout": MessageLookupByLibrary.simpleMessage(
      "Ang server ay tumatagal sa pagtugon. Pakisubukan ulit mamaya.",
    ),
    "error_unknown": MessageLookupByLibrary.simpleMessage(
      "May hindi inaasahang error na naganap. Pakisubukan ulit.",
    ),
    "error_unsyncing_prototype": m15,
    "error_update_prescription": MessageLookupByLibrary.simpleMessage(
      "Error sa pag-update ng reseta",
    ),
    "estimated_duration": MessageLookupByLibrary.simpleMessage(
      "Tinatayang Tagal",
    ),
    "estimated_growth_stage": MessageLookupByLibrary.simpleMessage(
      "Tinatayang Yugto ng Paglaki",
    ),
    "excellent": MessageLookupByLibrary.simpleMessage("Napakagaling"),
    "exit_app_message": MessageLookupByLibrary.simpleMessage(
      "Sigurado ba kayo na gusto ninyong lumabas sa application?",
    ),
    "exit_app_title": MessageLookupByLibrary.simpleMessage(
      "Lumabas sa Application",
    ),
    "expected_harvest": MessageLookupByLibrary.simpleMessage("Inaasahang Ani"),
    "failed_to_load_crop_condition": MessageLookupByLibrary.simpleMessage(
      "Nabigo sa pag-load ng crop condition",
    ),
    "failed_to_load_prototypes": MessageLookupByLibrary.simpleMessage(
      "Hindi ma-load ang mga prototype",
    ),
    "failed_to_load_sensor_status": MessageLookupByLibrary.simpleMessage(
      "Hindi ma-load ang sensor status",
    ),
    "failed_to_unsync_prototype": MessageLookupByLibrary.simpleMessage(
      "Nabigo sa pag-unsync ng prototype",
    ),
    "failed_to_update_profile": m16,
    "fair": MessageLookupByLibrary.simpleMessage("Katamtaman"),
    "faqA1": MessageLookupByLibrary.simpleMessage(
      "Pumunta sa settings at i-toggle ang switch.",
    ),
    "faqA2": MessageLookupByLibrary.simpleMessage(
      "I-click ang \'Forgot Password\' sa login screen.",
    ),
    "faqQ1": MessageLookupByLibrary.simpleMessage(
      "Paano ko paganahin ang notifications?",
    ),
    "faqQ2": MessageLookupByLibrary.simpleMessage(
      "Paano i-reset ang aking password?",
    ),
    "faqTitle": MessageLookupByLibrary.simpleMessage("Mga Madalas na Tanong"),
    "faq_a1": MessageLookupByLibrary.simpleMessage(
      "Ang berde ay nangangahulugang gumagana nang maayos ang sensor, habang ang pula ay maaaring may problema.",
    ),
    "faq_a2": MessageLookupByLibrary.simpleMessage(
      "Ang sensor data ay na-update tuwing 5 segundo nang awtomatiko.",
    ),
    "faq_add_sensor_answer": MessageLookupByLibrary.simpleMessage(
      "Pumunta sa Farm Management section at i-tap ang \'Magdagdag ng Sensor\'. Sundin ang mga tagubilin sa pag-setup para ma-connect ang sensor sa app.",
    ),
    "faq_add_sensor_question": MessageLookupByLibrary.simpleMessage(
      "Paano magdagdag ng bagong sensor?",
    ),
    "faq_change_farm_settings_answer": MessageLookupByLibrary.simpleMessage(
      "Pumunta sa Settings > Farm Management para i-update ang farm information, field details, at sensor configurations.",
    ),
    "faq_change_farm_settings_question": MessageLookupByLibrary.simpleMessage(
      "Paano baguhin ang farm settings?",
    ),
    "faq_check_farm_data_answer": MessageLookupByLibrary.simpleMessage(
      "Inirerekomenda naming i-check ang farm data kahit isang beses sa isang araw. Magse-send ang app ng notifications para sa urgent issues.",
    ),
    "faq_check_farm_data_question": MessageLookupByLibrary.simpleMessage(
      "Gaano kadalas dapat i-check ang farm data?",
    ),
    "faq_offline_usage_answer": MessageLookupByLibrary.simpleMessage(
      "Oo, pwede gamitin ang app offline para sa pagtingin ng cached data. Pero ang real-time updates ay nangangailangan ng internet connection.",
    ),
    "faq_offline_usage_question": MessageLookupByLibrary.simpleMessage(
      "Pwede bang gamitin ang app offline?",
    ),
    "faq_q1": MessageLookupByLibrary.simpleMessage(
      "Ano ang ibig sabihin ng mga sensor indicators?",
    ),
    "faq_q2": MessageLookupByLibrary.simpleMessage(
      "Gaano kadalas na-update ng app ang sensor data?",
    ),
    "faq_sensor_disconnected_answer": MessageLookupByLibrary.simpleMessage(
      "I-check ang internet connection at siguraduhing naka-power on ang sensor. Subukan i-restart ang sensor at i-refresh ang app.",
    ),
    "faq_sensor_disconnected_question": MessageLookupByLibrary.simpleMessage(
      "Bakit naka-disconnect ang sensor ko?",
    ),
    "faq_title": MessageLookupByLibrary.simpleMessage("Mga Madalas na Tanong"),
    "farm": MessageLookupByLibrary.simpleMessage("Sakahan"),
    "farm_alert": MessageLookupByLibrary.simpleMessage("Alert ng Sakahan"),
    "farm_alerts": MessageLookupByLibrary.simpleMessage("Mga Alert ng Sakahan"),
    "farm_alerts_description": MessageLookupByLibrary.simpleMessage(
      "Mga babala sa panahon, irrigation alerts, at crop health updates",
    ),
    "farm_details": MessageLookupByLibrary.simpleMessage("Detalye ng Farm"),
    "farm_prescription": MessageLookupByLibrary.simpleMessage(
      "Mga Reseta sa Sakahan",
    ),
    "farm_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Mga Reseta ng Sakahan",
    ),
    "farm_registered_successfully": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na Na-register ang Farm!",
    ),
    "farm_registration_successful": MessageLookupByLibrary.simpleMessage(
      "Matagumpay ang Farm Registration!",
    ),
    "farm_registration_summary": MessageLookupByLibrary.simpleMessage(
      "Buod ng Farm Registration",
    ),
    "farm_setup_guide": MessageLookupByLibrary.simpleMessage(
      "Farm Setup Guide",
    ),
    "farm_summary": MessageLookupByLibrary.simpleMessage("Buod ng Farm"),
    "farm_task": MessageLookupByLibrary.simpleMessage("Gawain sa Bukid"),
    "farm_task_requires_attention": MessageLookupByLibrary.simpleMessage(
      "Ang farm task ay nangangailangan ng atensyon",
    ),
    "fast_draining_soil": MessageLookupByLibrary.simpleMessage(
      "Mabilis na nag-drain na lupa na may magandang aeration",
    ),
    "features_guide": MessageLookupByLibrary.simpleMessage(
      "Gabay sa mga Tampok",
    ),
    "feb": MessageLookupByLibrary.simpleMessage("Peb"),
    "february": MessageLookupByLibrary.simpleMessage("Peb"),
    "fertilization": MessageLookupByLibrary.simpleMessage(
      "Pagtatanim ng Pataba",
    ),
    "field": MessageLookupByLibrary.simpleMessage("Field"),
    "field_colon": MessageLookupByLibrary.simpleMessage("Field:"),
    "field_information": MessageLookupByLibrary.simpleMessage(
      "Impormasyon ng Field",
    ),
    "field_name": MessageLookupByLibrary.simpleMessage("Pangalan ng Field"),
    "field_name_hint": MessageLookupByLibrary.simpleMessage(
      "Field A, Hilagang Field, Pangunahing Plot",
    ),
    "field_name_label": MessageLookupByLibrary.simpleMessage(
      "Pangalan ng Field",
    ),
    "field_name_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang pangalan ng field",
    ),
    "fields_registered": MessageLookupByLibrary.simpleMessage(
      "mga field na narehistro",
    ),
    "filter_done": MessageLookupByLibrary.simpleMessage("Tapos na"),
    "filter_newest": MessageLookupByLibrary.simpleMessage("Pinakabago Muna"),
    "filter_not_done": MessageLookupByLibrary.simpleMessage("Hindi pa Tapos"),
    "filter_oldest": MessageLookupByLibrary.simpleMessage("Pinakaluma Muna"),
    "filter_prescriptions": MessageLookupByLibrary.simpleMessage(
      "I-filter ang mga Reseta",
    ),
    "filter_view_all": MessageLookupByLibrary.simpleMessage("Tingnan Lahat"),
    "filtered_by": m17,
    "first_name": MessageLookupByLibrary.simpleMessage("Pangalan"),
    "first_name_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Ang pangalan ay hindi maaaring magkaroon ng magkakasunod na special character",
    ),
    "first_name_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang pangalan ay maaari lamang maglaman ng mga titik, espasyo, gitling, apostrophe, at tuldok",
    ),
    "first_name_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang pangalan ay hindi maaaring magsimula o magtapos sa mga special character",
    ),
    "first_name_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang pangalan",
    ),
    "first_name_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang pangalan ay hindi dapat lumampas sa 50 na character",
    ),
    "first_name_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang pangalan ay dapat hindi bababa sa 2 na character",
    ),
    "first_time_setup": MessageLookupByLibrary.simpleMessage("Unang Setup"),
    "follow_recommended_actions": MessageLookupByLibrary.simpleMessage(
      "Sundin ang mga rekomendadong aksyon",
    ),
    "follow_us": MessageLookupByLibrary.simpleMessage("Sundan Kami"),
    "for_today": MessageLookupByLibrary.simpleMessage("para sa Araw na Ito"),
    "forgot_password": MessageLookupByLibrary.simpleMessage(
      "Nakalimutan ang Password?",
    ),
    "frequently_asked_questions": MessageLookupByLibrary.simpleMessage(
      "Mga Madalas Itanong",
    ),
    "friday": MessageLookupByLibrary.simpleMessage("Biyernes"),
    "from": MessageLookupByLibrary.simpleMessage("mula sa"),
    "fully_developed_corn": MessageLookupByLibrary.simpleMessage(
      "Ganap na hinog na mais",
    ),
    "general": MessageLookupByLibrary.simpleMessage("Pangkalahatan"),
    "get_help_and_find_answers": MessageLookupByLibrary.simpleMessage(
      "Kumuha ng tulong at makahanap ng mga sagot sa mga karaniwang tanong",
    ),
    "get_in_touch_with_support_team": MessageLookupByLibrary.simpleMessage(
      "Makipag-ugnayan sa aming support team",
    ),
    "get_real_time_analytics": MessageLookupByLibrary.simpleMessage(
      "Makakuha ng real-time analytics at insights",
    ),
    "get_weather_forecasts_and_alerts_for_your_farm":
        MessageLookupByLibrary.simpleMessage(
          "Kumuha ng mga taya ng panahon at alerto para sa inyong sakahan",
        ),
    "getting_started": MessageLookupByLibrary.simpleMessage("Simula"),
    "github": MessageLookupByLibrary.simpleMessage("GitHub"),
    "give_field_unique_name": MessageLookupByLibrary.simpleMessage(
      "Bigyan ng natatanging pangalan ang inyong field para matulungan kayong kilalanin ito sa inyong sakahan",
    ),
    "go_to_settings": MessageLookupByLibrary.simpleMessage(
      "Pumunta sa Settings",
    ),
    "go_to_settings_language_and_select_your_preferred_language":
        MessageLookupByLibrary.simpleMessage(
          "Pumunta sa Settings > Wika at piliin ang inyong gustong wika.",
        ),
    "good": MessageLookupByLibrary.simpleMessage("MABUTI"),
    "greeting_afternoon": MessageLookupByLibrary.simpleMessage(
      "Magandang Hapon",
    ),
    "greeting_evening": MessageLookupByLibrary.simpleMessage("Magandang Gabi"),
    "greeting_morning": MessageLookupByLibrary.simpleMessage("Magandang Umaga"),
    "growth_stage": MessageLookupByLibrary.simpleMessage("Yugto ng Paglaki"),
    "growth_stage_calculated": MessageLookupByLibrary.simpleMessage(
      "Ang yugto ng paglaki ay awtomatikong kinakalkula batay sa inyong petsa ng pagtatanim para magbigay ng tumpak na pagmomonitor.",
    ),
    "growth_stage_early_vegetative": MessageLookupByLibrary.simpleMessage(
      "Maagang Vegetatibo",
    ),
    "growth_stage_emergence": MessageLookupByLibrary.simpleMessage("Pagsibol"),
    "growth_stage_maturing": MessageLookupByLibrary.simpleMessage("Paghihinog"),
    "growth_stage_maturity_harvest": MessageLookupByLibrary.simpleMessage(
      "Hinog/Ani",
    ),
    "growth_stage_mid_vegetative": MessageLookupByLibrary.simpleMessage(
      "Gitnang Vegetatibo",
    ),
    "growth_stage_progress": MessageLookupByLibrary.simpleMessage(
      "Pag-unlad ng Yugto ng Paglaki",
    ),
    "growth_stage_r1": MessageLookupByLibrary.simpleMessage(
      "Pagkakaroon ng Silk",
    ),
    "growth_stage_r1_desc": MessageLookupByLibrary.simpleMessage(
      "May silk na sa mga uhay",
    ),
    "growth_stage_r6": MessageLookupByLibrary.simpleMessage("Hinog"),
    "growth_stage_r6_desc": MessageLookupByLibrary.simpleMessage(
      "Ganap na hinog na mais",
    ),
    "growth_stage_reproductive": MessageLookupByLibrary.simpleMessage(
      "Reproduktibo",
    ),
    "growth_stage_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang yugto ng paglaki",
    ),
    "growth_stage_unknown": MessageLookupByLibrary.simpleMessage(
      "Hindi kilalang yugto ng paglaki",
    ),
    "growth_stage_v3": MessageLookupByLibrary.simpleMessage("Maagang Paglaki"),
    "growth_stage_v3_desc": MessageLookupByLibrary.simpleMessage(
      "3-5 dahon na ang nabuo",
    ),
    "growth_stage_v8": MessageLookupByLibrary.simpleMessage("Gitnang Paglaki"),
    "growth_stage_v8_desc": MessageLookupByLibrary.simpleMessage(
      "8-10 dahon, tumataas na",
    ),
    "growth_stage_ve": MessageLookupByLibrary.simpleMessage("Pagsibol"),
    "growth_stage_ve_desc": MessageLookupByLibrary.simpleMessage(
      "Kakasimula pa lang tumubo mula sa lupa",
    ),
    "growth_stage_vt": MessageLookupByLibrary.simpleMessage(
      "Pagkakaroon ng Tassel",
    ),
    "growth_stage_vt_desc": MessageLookupByLibrary.simpleMessage(
      "May tassel na sa taas",
    ),
    "growth_timeline": MessageLookupByLibrary.simpleMessage(
      "Timeline ng Paglaki",
    ),
    "guide_coming_soon": m18,
    "harvest": MessageLookupByLibrary.simpleMessage("Ani"),
    "harvest_time": MessageLookupByLibrary.simpleMessage("Oras na ng ani!"),
    "healthy": MessageLookupByLibrary.simpleMessage("Malusog"),
    "healthy_growth": MessageLookupByLibrary.simpleMessage(
      "Malusog na paglaki",
    ),
    "help": MessageLookupByLibrary.simpleMessage("Tulong"),
    "helpDescription": MessageLookupByLibrary.simpleMessage(
      "Narito ang ilang kapaki-pakinabang na impormasyon.",
    ),
    "helpTitle": MessageLookupByLibrary.simpleMessage("Tulong"),
    "help_content_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Darating na ang help content!",
    ),
    "help_description": MessageLookupByLibrary.simpleMessage(
      "Ang seksyon na ito ay nagbibigay ng impormasyon para matulungan ang mga user na maintindihan ang mga feature at paggamit ng app. Matuto kung paano i-monitor ang inyong mga halaman, i-configure ang mga setting, at i-interpret ang sensor data.",
    ),
    "help_faq": MessageLookupByLibrary.simpleMessage("Tulong at FAQ"),
    "help_title": MessageLookupByLibrary.simpleMessage("Tulong"),
    "high": MessageLookupByLibrary.simpleMessage("Mataas"),
    "high_priority": MessageLookupByLibrary.simpleMessage(
      "Mataas na Prioridad",
    ),
    "high_stress": MessageLookupByLibrary.simpleMessage("Mataas na stress"),
    "historical": MessageLookupByLibrary.simpleMessage("Makasaysayan"),
    "hours_ago": m19,
    "hours_left": m20,
    "how_do_i_change_the_language": MessageLookupByLibrary.simpleMessage(
      "Paano ko babaguhin ang wika?",
    ),
    "how_often_does_the_app_update_sensor_data":
        MessageLookupByLibrary.simpleMessage(
          "Gaano kadalas ina-update ng app ang datos mula sa sensor?",
        ),
    "how_to_read_and_interpret_sensor_data":
        MessageLookupByLibrary.simpleMessage(
          "Kung paano basahin at intindihin ang datos mula sa sensor",
        ),
    "how_to_update_your_profile_and_settings":
        MessageLookupByLibrary.simpleMessage(
          "Kung paano i-update ang inyong profile at mga setting",
        ),
    "humidity": MessageLookupByLibrary.simpleMessage("Halumigmig"),
    "humidity_moderate": MessageLookupByLibrary.simpleMessage(
      "Ang hangin ay may katamtamang halumigmig, komportable para sa transpiration ng halaman.",
    ),
    "humidity_quite_humid": MessageLookupByLibrary.simpleMessage(
      "Ang hangin ay medyo mahalumigmig, madalas na nauugnay sa mga basa na kapaligiran.",
    ),
    "humidity_sensor": MessageLookupByLibrary.simpleMessage(
      "Sensor ng Halumigmig",
    ),
    "humidity_title": MessageLookupByLibrary.simpleMessage("Halumigmig"),
    "humidity_very_dry": MessageLookupByLibrary.simpleMessage(
      "Ang hangin ay napakatuyo, tipikal ng mga tuyong kapaligiran.",
    ),
    "humidity_very_humid": MessageLookupByLibrary.simpleMessage(
      "Ang hangin ay napakahalumigmig, karaniwan bago ang ulan o sa mga tropikal na klima.",
    ),
    "id": MessageLookupByLibrary.simpleMessage("ID"),
    "immediate": MessageLookupByLibrary.simpleMessage("Agarang"),
    "in_progress": MessageLookupByLibrary.simpleMessage("Ginagawa"),
    "inactive": MessageLookupByLibrary.simpleMessage("Hindi aktibo"),
    "inactive_sensor_is_offline_or_not_sending_data":
        MessageLookupByLibrary.simpleMessage(
          "Hindi Aktibo: Ang sensor ay offline o hindi nagpapadala ng data",
        ),
    "initializing": MessageLookupByLibrary.simpleMessage("Sinisimula..."),
    "instagram": MessageLookupByLibrary.simpleMessage("Instagram"),
    "install_sensors_to_enable_real_time_monitoring":
        MessageLookupByLibrary.simpleMessage(
          "Mag-install ng sensors para ma-enable ang real-time monitoring",
        ),
    "install_soil_moisture_sensors": MessageLookupByLibrary.simpleMessage(
      "Mag-install ng soil moisture sensors",
    ),
    "instructions": MessageLookupByLibrary.simpleMessage("Mga Tagubilin"),
    "integration_coming_soon": m21,
    "invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Hindi wasto ang username o password",
    ),
    "invalid_prototype_id": MessageLookupByLibrary.simpleMessage(
      "Hindi katanggap-tanggap ang prototype ID",
    ),
    "invalid_verification_code_format": MessageLookupByLibrary.simpleMessage(
      "Hindi wastong format ng verification code",
    ),
    "irrigation": MessageLookupByLibrary.simpleMessage("Irigasyon"),
    "jan": MessageLookupByLibrary.simpleMessage("Ene"),
    "january": MessageLookupByLibrary.simpleMessage("Ene"),
    "jul": MessageLookupByLibrary.simpleMessage("Hul"),
    "july": MessageLookupByLibrary.simpleMessage("Hul"),
    "jun": MessageLookupByLibrary.simpleMessage("Hun"),
    "june": MessageLookupByLibrary.simpleMessage("Hun"),
    "just_now": MessageLookupByLibrary.simpleMessage("Kakalabas lang"),
    "just_sprouting_from_soil": MessageLookupByLibrary.simpleMessage(
      "Kakasimula pa lang tumubo mula sa lupa",
    ),
    "key_features": MessageLookupByLibrary.simpleMessage(
      "Mga Pangunahing Tampok",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Wika"),
    "language_changed_to": m22,
    "language_settings": MessageLookupByLibrary.simpleMessage(
      "Mga Setting ng Wika",
    ),
    "last_month": MessageLookupByLibrary.simpleMessage("Nakaraang buwan"),
    "last_name": MessageLookupByLibrary.simpleMessage("Apelyido"),
    "last_name_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay hindi maaaring magkaroon ng magkakasunod na special character",
    ),
    "last_name_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay maaari lamang maglaman ng mga titik, espasyo, gitling, apostrophe, at tuldok",
    ),
    "last_name_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay hindi maaaring magsimula o magtapos sa mga special character",
    ),
    "last_name_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang apelyido",
    ),
    "last_name_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay hindi dapat lumampas sa 50 na character",
    ),
    "last_name_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang apelyido ay dapat hindi bababa sa 2 na character",
    ),
    "last_updated": MessageLookupByLibrary.simpleMessage("Huling na-update"),
    "last_week": MessageLookupByLibrary.simpleMessage("Nakaraang linggo"),
    "ldrSensor": MessageLookupByLibrary.simpleMessage("LDR Sensor"),
    "ldr_sensor": MessageLookupByLibrary.simpleMessage(
      "Light Dependent Resistor",
    ),
    "learn_how_to_add_and_configure_your_farm_details":
        MessageLookupByLibrary.simpleMessage(
          "Matuto kung paano mag-add at mag-configure ng inyong farm details",
        ),
    "learn_how_to_use_maize_watch": MessageLookupByLibrary.simpleMessage(
      "Matuto kung paano gamitin ang Maize Watch app",
    ),
    "learn_more_about_maize_watch": MessageLookupByLibrary.simpleMessage(
      "Matuto pa tungkol sa Maize Watch",
    ),
    "leaves_3_5_developed": MessageLookupByLibrary.simpleMessage(
      "3-5 dahon na ang nabuo",
    ),
    "leaves_8_10_developed": MessageLookupByLibrary.simpleMessage(
      "8-10 dahon, tumataas na",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Liwanag"),
    "light_intensity": MessageLookupByLibrary.simpleMessage(
      "Intensidad ng Liwanag",
    ),
    "light_intensity_bright": MessageLookupByLibrary.simpleMessage(
      "Ang intensidad ng liwanag ay maliwanag, malapit sa malinaw na kondisyon ng araw.",
    ),
    "light_intensity_moderate": MessageLookupByLibrary.simpleMessage(
      "Ang intensidad ng liwanag ay katamtaman, katulad ng maulap na araw.",
    ),
    "light_intensity_sensor": MessageLookupByLibrary.simpleMessage(
      "Sensor ng Intensidad ng Liwanag",
    ),
    "light_intensity_title": MessageLookupByLibrary.simpleMessage(
      "Intensidad ng Liwanag",
    ),
    "light_intensity_very_low": MessageLookupByLibrary.simpleMessage(
      "Ang intensidad ng liwanag ay napakababa, katulad ng gabi o makapal na lilim.",
    ),
    "light_intensity_very_strong": MessageLookupByLibrary.simpleMessage(
      "Ang intensidad ng liwanag ay napakalakas, katulad ng direktang sikat ng araw sa tanghali.",
    ),
    "linkedin": MessageLookupByLibrary.simpleMessage("LinkedIn"),
    "live": MessageLookupByLibrary.simpleMessage("ONLINE"),
    "live_monitoring": MessageLookupByLibrary.simpleMessage(
      "Live na Pagsubaybay",
    ),
    "live_monitoring_guide": MessageLookupByLibrary.simpleMessage(
      "Gabay sa Live na Pagsubaybay",
    ),
    "loading": MessageLookupByLibrary.simpleMessage("Naglo-load"),
    "loading_analytics_data": MessageLookupByLibrary.simpleMessage(
      "Naglo-load ng analytics data...",
    ),
    "loading_farm_tasks": MessageLookupByLibrary.simpleMessage(
      "Naglo-load ng farm tasks...",
    ),
    "loading_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Naglo-load ng mga reseta...",
    ),
    "loading_your_farm": MessageLookupByLibrary.simpleMessage(
      "Naglo-load ng inyong sakahan...",
    ),
    "loading_your_farms": MessageLookupByLibrary.simpleMessage(
      "Naglo-load ng inyong mga sakahan...",
    ),
    "loamy_soil": MessageLookupByLibrary.simpleMessage("Ma-loamy na lupa"),
    "location": MessageLookupByLibrary.simpleMessage("Lokasyon"),
    "location_default": MessageLookupByLibrary.simpleMessage(
      "Default: Amadeo, Cavite",
    ),
    "location_label": MessageLookupByLibrary.simpleMessage("Lokasyon"),
    "location_not_specified": MessageLookupByLibrary.simpleMessage(
      "Hindi tinukoy ang lokasyon",
    ),
    "log_out": MessageLookupByLibrary.simpleMessage("Log out sa Account"),
    "login": MessageLookupByLibrary.simpleMessage("Mag-login"),
    "login_error": MessageLookupByLibrary.simpleMessage("Error sa Login"),
    "login_failed": MessageLookupByLibrary.simpleMessage(
      "Nabigo ang pag-login. Pakisubukan ang manual na pag-login.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Mag-logout"),
    "logout_error": MessageLookupByLibrary.simpleMessage(
      "May problema sa pag-logout. Pakisubukan ulit.",
    ),
    "logout_message": MessageLookupByLibrary.simpleMessage(
      "Sigurado ba kayo na gusto ninyong mag-logout sa inyong account?",
    ),
    "logout_title": MessageLookupByLibrary.simpleMessage(
      "Kumpirmasyon ng Logout",
    ),
    "low": MessageLookupByLibrary.simpleMessage("Mababa"),
    "low_light": MessageLookupByLibrary.simpleMessage("Mababang Liwanag"),
    "low_priority": MessageLookupByLibrary.simpleMessage("Mababang Prioridad"),
    "maize_watch": MessageLookupByLibrary.simpleMessage("Maize Watch"),
    "maize_watch_description": MessageLookupByLibrary.simpleMessage(
      "Ang Maize Watch ay isang komprehensibong aplikasyon para sa pagsubaybay ng pananim na partikular na dinisenyo para sa mga magsasakang Pilipino upang masubaybayan ang pagtubo ng mais, mabantayan ang mga kondisyon sa kapaligiran, at matukoy nang maaga ang mga posibleng problema.",
    ),
    "maize_watch_notifications": MessageLookupByLibrary.simpleMessage(
      "Mga Notification ng Maize Watch",
    ),
    "manage_and_unsync_prototypes": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan at i-unsync ang mga prototype sa mga field",
    ),
    "manage_and_unsync_prototypes_from_fields":
        MessageLookupByLibrary.simpleMessage(
          "Pamahalaan at i-unsync ang mga prototype sa mga field",
        ),
    "manage_your_account_settings": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan ang iyong account settings",
    ),
    "manage_your_app_preferences": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan ang mga kagustuhan ng app",
    ),
    "manage_your_personal_informations": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan ang iyong personal informations",
    ),
    "manage_your_registered_prototypes": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan ang inyong mga narehistrong prototype",
    ),
    "mar": MessageLookupByLibrary.simpleMessage("Mar"),
    "march": MessageLookupByLibrary.simpleMessage("Mar"),
    "mark_as_complete": MessageLookupByLibrary.simpleMessage(
      "Markahan bilang Tapos",
    ),
    "mark_complete": MessageLookupByLibrary.simpleMessage(
      "Markahan bilang Tapos",
    ),
    "marked_as_completed": MessageLookupByLibrary.simpleMessage(
      "Minarkahan bilang nakumpleto!",
    ),
    "marked_as_pending": MessageLookupByLibrary.simpleMessage(
      "Minarkahan bilang pending",
    ),
    "materials_needed": MessageLookupByLibrary.simpleMessage(
      "Mga Materyales na Kailangan",
    ),
    "maturing": MessageLookupByLibrary.simpleMessage("Paghihinog"),
    "maturing_phase_grain_filling": MessageLookupByLibrary.simpleMessage(
      "Yugto ng paghihinog - pagpuno ng butil",
    ),
    "maturing_stage": MessageLookupByLibrary.simpleMessage(
      "Yugto ng Paghihinog",
    ),
    "maturity_harvest": MessageLookupByLibrary.simpleMessage("Hinog/Ani"),
    "maturity_ready_for_harvest": MessageLookupByLibrary.simpleMessage(
      "Hinog - handa na para sa ani",
    ),
    "maturity_stage": m23,
    "may": MessageLookupByLibrary.simpleMessage("May"),
    "medium": MessageLookupByLibrary.simpleMessage("Katamtaman"),
    "medium_priority": MessageLookupByLibrary.simpleMessage(
      "Katamtamang Prioridad",
    ),
    "menu": MessageLookupByLibrary.simpleMessage("Menu"),
    "mid_vegetative": MessageLookupByLibrary.simpleMessage(
      "Gitnang Vegetatibo",
    ),
    "mid_vegetative_growth_stem_elongation":
        MessageLookupByLibrary.simpleMessage(
          "Gitnang paglaking vegetatibo - paghaba ng tangkay",
        ),
    "mid_vegetative_stage": MessageLookupByLibrary.simpleMessage(
      "Gitnang Yugto ng Vegetatibo",
    ),
    "minutes_ago": m24,
    "moderate": MessageLookupByLibrary.simpleMessage("Katamtaman"),
    "moderate_stress": MessageLookupByLibrary.simpleMessage(
      "Katamtamang stress",
    ),
    "moist": MessageLookupByLibrary.simpleMessage("Basa"),
    "moisture_fairly_moist": MessageLookupByLibrary.simpleMessage(
      "Ang lupa ay medyo basa. Subaybayan para sa posibleng sobrang pagdidilig.",
    ),
    "moisture_low": MessageLookupByLibrary.simpleMessage(
      "Ang kahalumigmigan ng lupa ay mababa. Isaalang-alang ang pagdidilig sa lalong madaling panahon para mapanatili ang malusog na paglaki.",
    ),
    "moisture_optimal": MessageLookupByLibrary.simpleMessage(
      "Ang kahalumigmigan ng lupa ay nasa optimal na antas. Ang mga halaman ay nasa mabuting kalagayan.",
    ),
    "moisture_too_dry": MessageLookupByLibrary.simpleMessage(
      "Ang lupa ay masyadong tuyo. Lubhang inirerekomenda ang irigasyon para maiwasan ang stress ng halaman.",
    ),
    "moisture_too_wet": MessageLookupByLibrary.simpleMessage(
      "Ang lupa ay masyadong basa. Mataas ang panganib ng root rot at fungal diseases.",
    ),
    "monday": MessageLookupByLibrary.simpleMessage("Lunes"),
    "monitor_crop_health": MessageLookupByLibrary.simpleMessage(
      "Subaybayan ang kalusugan ng inyong ani gamit ang IoT sensors",
    ),
    "monitor_sensor_condition": MessageLookupByLibrary.simpleMessage(
      "Subaybayan ang kalagayan ng iyong mga sensor",
    ),
    "multi_language_support": MessageLookupByLibrary.simpleMessage(
      "Suporta sa Maraming Wika",
    ),
    "multiple_fields_info": MessageLookupByLibrary.simpleMessage(
      "Maaari kayong magkaroon ng maraming field sa inyong sakahan. Bawat field ay maaaring magkaiba ang uri ng lupa, petsa ng pagtatanim, at mga sensor.",
    ),
    "municipality": MessageLookupByLibrary.simpleMessage("Bayan"),
    "municipality_amadeo": MessageLookupByLibrary.simpleMessage("Amadeo"),
    "municipality_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang bayan",
    ),
    "my_farm": MessageLookupByLibrary.simpleMessage("Aking Sakahan"),
    "name": MessageLookupByLibrary.simpleMessage("Pangalan"),
    "name_your_field": MessageLookupByLibrary.simpleMessage(
      "Pangalanan ang Inyong Field",
    ),
    "network_error": MessageLookupByLibrary.simpleMessage(
      "May error sa network",
    ),
    "new_farm": MessageLookupByLibrary.simpleMessage("Bagong Sakahan"),
    "new_farm_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Mga Bagong Reseta sa Sakahan",
    ),
    "new_farm_tasks_message": m25,
    "new_password": MessageLookupByLibrary.simpleMessage("Bagong Password"),
    "new_password_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang bagong password",
    ),
    "new_prescription_available": MessageLookupByLibrary.simpleMessage(
      "May bagong reseta na available",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Susunod"),
    "next_button": MessageLookupByLibrary.simpleMessage("Susunod"),
    "no": MessageLookupByLibrary.simpleMessage("Hindi"),
    "no_analytics_data_available": MessageLookupByLibrary.simpleMessage(
      "Walang available na analytics data",
    ),
    "no_corn_fields": MessageLookupByLibrary.simpleMessage(
      "Walang nahanap na corn fields",
    ),
    "no_data": MessageLookupByLibrary.simpleMessage("Walang Data"),
    "no_details_available": MessageLookupByLibrary.simpleMessage(
      "Walang detalye na available",
    ),
    "no_devices_registered": MessageLookupByLibrary.simpleMessage(
      "Walang devices na naka-register",
    ),
    "no_devices_registered_yet": MessageLookupByLibrary.simpleMessage(
      "Walang devices na naka-register",
    ),
    "no_farm_tasks_available": MessageLookupByLibrary.simpleMessage(
      "Walang available na farm tasks",
    ),
    "no_field": MessageLookupByLibrary.simpleMessage("Walang field"),
    "no_pending_tasks_found": MessageLookupByLibrary.simpleMessage(
      "Walang nahanap na pending tasks",
    ),
    "no_prescriptions_found": MessageLookupByLibrary.simpleMessage(
      "Walang nahanap na mga reseta",
    ),
    "no_prototypes_found": MessageLookupByLibrary.simpleMessage(
      "Walang nahanap na mga prototype",
    ),
    "no_prototypes_registered": MessageLookupByLibrary.simpleMessage(
      "Wala pa kayong narehistro na mga prototype.",
    ),
    "no_sensor_data_available": MessageLookupByLibrary.simpleMessage(
      "Walang available na sensor data",
    ),
    "no_tasks": MessageLookupByLibrary.simpleMessage("Walang Gawain"),
    "no_urgent_tasks_found": MessageLookupByLibrary.simpleMessage(
      "Walang nahanap na urgent tasks",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Wala"),
    "normal": MessageLookupByLibrary.simpleMessage("Normal"),
    "not_connected": MessageLookupByLibrary.simpleMessage("Hindi naka-connect"),
    "not_now": MessageLookupByLibrary.simpleMessage("Hindi Ngayon"),
    "not_set": MessageLookupByLibrary.simpleMessage("Hindi naka-set"),
    "not_specified": MessageLookupByLibrary.simpleMessage("Hindi specified"),
    "not_started": MessageLookupByLibrary.simpleMessage("Hindi pa Nagsimula"),
    "notification_badge": MessageLookupByLibrary.simpleMessage(
      "Badge ng Notification",
    ),
    "notification_description": MessageLookupByLibrary.simpleMessage(
      "Makakuha ng mga alert para sa farm updates, weather warnings, at sensor issues",
    ),
    "notification_permission_message": MessageLookupByLibrary.simpleMessage(
      "Maize Watch ay gustong magpadala ng mga notification sa inyo tungkol sa:\n\n• Bagong farm prescriptions\n• Mga alert ng sensor\n• Mga impormasyon na mahalaga\n\nIto ay makakatulong sa inyo na mapanig sa kalusugan ng inyong sakahan.",
    ),
    "notification_permission_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang pahintulot sa notification para makatanggap ng mga alert",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Mga Setting ng Notification",
    ),
    "notification_settings_failed": m26,
    "notification_settings_updated": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na na-update ang notification settings!",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Tunog ng Notification",
    ),
    "notification_test_failed": MessageLookupByLibrary.simpleMessage(
      "Nabigo ang test na notification",
    ),
    "notification_test_successful": MessageLookupByLibrary.simpleMessage(
      "Matagumpay ang test na notification!",
    ),
    "notification_types": MessageLookupByLibrary.simpleMessage(
      "Mga Uri ng Notification",
    ),
    "notification_vibration": MessageLookupByLibrary.simpleMessage(
      "Vibration ng Notification",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Mga Notipikasyon"),
    "notifications_channel_description": MessageLookupByLibrary.simpleMessage(
      "Mga notification para sa pagmomonitor ng sakahan at mga alert",
    ),
    "notifications_disabled_message": MessageLookupByLibrary.simpleMessage(
      "Disabled na ang notifications. Maaari ninyong i-enable ang mga ito sa settings.",
    ),
    "notifications_enabled": m27,
    "notifications_enabled_disabled": m28,
    "notifications_enabled_message": MessageLookupByLibrary.simpleMessage(
      "Inabled na ang notifications! Maaari kang makatanggap ng mga update sa inyong sakahan.",
    ),
    "notifications_for_farm_monitoring": MessageLookupByLibrary.simpleMessage(
      "Mga notification para sa pagmomonitor ng sakahan at mga alert",
    ),
    "notifications_guide": MessageLookupByLibrary.simpleMessage(
      "Gabay sa Notipikasyon",
    ),
    "nov": MessageLookupByLibrary.simpleMessage("Nob"),
    "november": MessageLookupByLibrary.simpleMessage("Nob"),
    "now": MessageLookupByLibrary.simpleMessage("Ngayon"),
    "null_value": MessageLookupByLibrary.simpleMessage("NULL"),
    "oct": MessageLookupByLibrary.simpleMessage("Okt"),
    "october": MessageLookupByLibrary.simpleMessage("Okt"),
    "off": MessageLookupByLibrary.simpleMessage("Naka-off"),
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "offline_mode_cached_data": MessageLookupByLibrary.simpleMessage(
      "Naka-offline Mode - Cached Data",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "okay": MessageLookupByLibrary.simpleMessage("Sige"),
    "on": MessageLookupByLibrary.simpleMessage("Naka-on"),
    "overcast": MessageLookupByLibrary.simpleMessage("Overcast"),
    "overdue": MessageLookupByLibrary.simpleMessage("Overdue"),
    "overview": MessageLookupByLibrary.simpleMessage("Pangkalahatang Tingin"),
    "parameter_humidity": MessageLookupByLibrary.simpleMessage("Halumigmig"),
    "parameter_light_intensity": MessageLookupByLibrary.simpleMessage(
      "Intensidad ng Liwanag",
    ),
    "parameter_soil_moisture": MessageLookupByLibrary.simpleMessage(
      "Soil Moisture",
    ),
    "parameter_soil_ph": MessageLookupByLibrary.simpleMessage("Soil pH"),
    "parameter_temperature": MessageLookupByLibrary.simpleMessage(
      "Temperatura",
    ),
    "partly_cloudy": MessageLookupByLibrary.simpleMessage("Medyo Maulap"),
    "partly_cloudy_description": MessageLookupByLibrary.simpleMessage(
      "Medyo maulap",
    ),
    "partly_cloudy_weather": MessageLookupByLibrary.simpleMessage(
      "Medyo Maulap",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "password_min_length": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat hindi bababa sa 6 na character",
    ),
    "password_needs_lowercase": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat maglaman ng hindi bababa sa isang maliit na titik",
    ),
    "password_needs_number": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat maglaman ng hindi bababa sa isang numero",
    ),
    "password_needs_special": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat maglaman ng hindi bababa sa isang special character (!@#\$%^&*)",
    ),
    "password_needs_uppercase": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat maglaman ng hindi bababa sa isang malaking titik",
    ),
    "password_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang password",
    ),
    "password_reset_successful": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na na-reset ang password!",
    ),
    "password_too_common": MessageLookupByLibrary.simpleMessage(
      "Ang password na ito ay masyadong karaniwan. Pakipili ng mas malakas na password",
    ),
    "password_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang password ay hindi dapat lumampas sa 128 na character",
    ),
    "password_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang password ay dapat hindi bababa sa 6 na character",
    ),
    "passwords_do_not_match": MessageLookupByLibrary.simpleMessage(
      "Hindi magkatugma ang mga password",
    ),
    "passwords_dont_match": MessageLookupByLibrary.simpleMessage(
      "Hindi magkatugma ang mga password",
    ),
    "pending": MessageLookupByLibrary.simpleMessage("Naghihintay"),
    "performance_tips": MessageLookupByLibrary.simpleMessage(
      "Mga Tip sa Performance",
    ),
    "permission_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang Pahintulot",
    ),
    "pest_control": MessageLookupByLibrary.simpleMessage("Kontrol sa Peste"),
    "phSensor": MessageLookupByLibrary.simpleMessage("pH Level Sensor"),
    "ph_sensor": MessageLookupByLibrary.simpleMessage("PH Level ng Lupa"),
    "phone_number": MessageLookupByLibrary.simpleMessage("Numero ng Telepono"),
    "phone_number_invalid": MessageLookupByLibrary.simpleMessage(
      "Pakilagay ang wastong numero ng telepono",
    ),
    "phone_number_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang numero ng telepono",
    ),
    "phone_support": MessageLookupByLibrary.simpleMessage(
      "Suporta sa Telepono",
    ),
    "phone_verification_description": MessageLookupByLibrary.simpleMessage(
      "Pakiverify ang inyong phone number para makumpleto ang inyong registration.",
    ),
    "phone_verification_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang Phone Verification",
    ),
    "planting_date": MessageLookupByLibrary.simpleMessage(
      "Petsa ng Pagtatanim",
    ),
    "planting_date_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang petsa ng pagtatanim",
    ),
    "planting_season_description": MessageLookupByLibrary.simpleMessage(
      "Piliin ang petsa na kayo nagtanim ng mais",
    ),
    "planting_season_title": MessageLookupByLibrary.simpleMessage(
      "Kailan kayo nagtanim?",
    ),
    "please_complete_device_info": MessageLookupByLibrary.simpleMessage(
      "Pakikumpletuhin ang lahat ng impormasyon ng device",
    ),
    "please_enter_field_name": MessageLookupByLibrary.simpleMessage(
      "Pakilagay ang pangalan ng field",
    ),
    "please_log_in_continue": MessageLookupByLibrary.simpleMessage(
      "Pakiusap mag-login para magpatuloy.",
    ),
    "please_register_device": MessageLookupByLibrary.simpleMessage(
      "Pakirehistro ng hindi bababa sa isang device para magpatuloy",
    ),
    "please_review_your_farm_information_before_submitting":
        MessageLookupByLibrary.simpleMessage(
          "Pakitingnan ang inyong farm information bago i-submit",
        ),
    "please_select_planting_date": MessageLookupByLibrary.simpleMessage(
      "Pakipili ang petsa ng pagtatanim",
    ),
    "please_try_again": MessageLookupByLibrary.simpleMessage(
      "Pakiusap subukan ulit",
    ),
    "please_validate_prototype_id": MessageLookupByLibrary.simpleMessage(
      "Pakitingnan ang prototype ID bago i-submit",
    ),
    "poor": MessageLookupByLibrary.simpleMessage("Mahina"),
    "prescription_alert": MessageLookupByLibrary.simpleMessage(
      "Alert ng Reseta",
    ),
    "prescription_deleted_successfully": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na natanggal ang reseta",
    ),
    "prescription_details": MessageLookupByLibrary.simpleMessage(
      "Mga Detalye ng Reseta",
    ),
    "prescription_marked_complete": MessageLookupByLibrary.simpleMessage(
      "Ang reseta ay minarkahan bilang tapos na",
    ),
    "prescription_marked_incomplete": MessageLookupByLibrary.simpleMessage(
      "Ang reseta ay minarkahan bilang hindi pa tapos",
    ),
    "prescription_updates": MessageLookupByLibrary.simpleMessage(
      "Mga Update ng Reseta",
    ),
    "prescription_updates_description": MessageLookupByLibrary.simpleMessage(
      "Mga bagong rekomendasyon sa sakahan at mga mungkahi sa paggamot",
    ),
    "prescriptions_subtitle": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan ang inyong mga reseta",
    ),
    "prescriptions_title": MessageLookupByLibrary.simpleMessage("Mga Reseta"),
    "priority": MessageLookupByLibrary.simpleMessage("Prioridad"),
    "privacy_info_intro": MessageLookupByLibrary.simpleMessage(
      "Sa Maize Watch, kami ay nakatuon sa pagprotekta sa privacy ng aming mga user, lalo na ang mga magsasaka ng mais na nagtitiwala sa amin ng kanilang mahalagang agricultural data. Ang Privacy Information na ito ay naglalarawan kung paano namin kinokolekta, ginagamit, at pinoprotektahan ang inyong impormasyon kapag ginagamit ninyo ang aming platform.",
    ),
    "privacy_info_section1_content": MessageLookupByLibrary.simpleMessage(
      "Para mabigyan kayo ng data-driven insights at i-optimize ang inyong ani ng mais, ang Maize Watch ay kinokolekta ang mga sumusunod na uri ng impormasyon:\n\nFarm-Specific Data: Lokasyon (GPS coordinates ng mga field), laki at hangganan ng field, uri ng ani, petsa ng pagtatanim/pag-aani, at yield data.\nSensor Data: Antas ng kahalumigmigan/nutrient ng lupa, temperatura (lupa/ambient), halumigmig, intensidad ng liwanag, at iba pang nauugnay na environmental data.\nAccount Information: Inyong pangalan, contact info, pangalan/ID ng sakahan, at login credentials (encrypted).\nUsage Data: Mga feature na na-access, oras na ginugol, mga report na nabuo, at anonymized device info.",
    ),
    "privacy_info_section1_title": MessageLookupByLibrary.simpleMessage(
      "1. Impormasyon na Aming Kinokolekta:",
    ),
    "privacy_info_section2_content": MessageLookupByLibrary.simpleMessage(
      "Para Magbigay ng Core Services: I-visualize ang performance ng sakahan, i-analyze ang mga kondisyon, magbigay ng mga rekomendasyon, at i-track ang progress.\nPara I-improve ang Maize Watch: I-enhance ang mga feature, gumawa ng mga bagong tool, at i-improve ang mga model (madalas na gumagamit ng anonymized data).\nPara sa Communication: Magpadala ng updates, alerts, at tumugon sa mga inquiry.\nPara sa Security: Siguraduhin ang integridad ng platform, pigilan ang fraud, at sumunod sa legal duties.",
    ),
    "privacy_info_section2_title": MessageLookupByLibrary.simpleMessage(
      "2. Paano Namin Ginagamit ang Inyong Impormasyon:",
    ),
    "privacy_info_section3_content": MessageLookupByLibrary.simpleMessage(
      "Sa Inyong Pahintulot: Ang data ay ibinabahagi lamang sa mga partido na inyong inaprubahan (hal., mga consultant).\nService Providers: Mga pinagkakatiwalaang provider lamang sa ilalim ng mahigpit na kasunduan.\nAggregated/Anonymized Data: Ginagamit para sa research o benchmarking nang hindi inilalantad ang mga pagkakakilanlan.\nLegal Requirements: Inilalantad lamang kapag legal na kinakailangan.",
    ),
    "privacy_info_section3_title": MessageLookupByLibrary.simpleMessage(
      "3. Pagbabahagi at Paglalantad ng Data:",
    ),
    "privacy_info_section4_content": MessageLookupByLibrary.simpleMessage(
      "Encryption (sa transit & at rest)\nMahigpit na access controls\nRegular na security audits\nSecure na data backups",
    ),
    "privacy_info_section4_title": MessageLookupByLibrary.simpleMessage(
      "4. Seguridad ng Data:",
    ),
    "privacy_info_section5_content": MessageLookupByLibrary.simpleMessage(
      "I-access, i-update, o i-correct ang inyong data anumang oras\nHumiling ng kopya ng inyong data (data portability)\nHumiling ng pagtanggal ng data (subject to legal retention)\nOpt-out sa non-essential communications",
    ),
    "privacy_info_section5_title": MessageLookupByLibrary.simpleMessage(
      "5. Inyong mga Pagpipilian at Karapatan:",
    ),
    "privacy_info_section6_content": MessageLookupByLibrary.simpleMessage(
      "Ang inyong data ay pinapanatili habang ang inyong account ay aktibo at para sa isang makatuwirang panahon pagkatapos para sumunod sa mga obligasyon at siguraduhin ang continuity.",
    ),
    "privacy_info_section6_title": MessageLookupByLibrary.simpleMessage(
      "6. Pagpapanatili ng Data:",
    ),
    "privacy_info_section7_content": MessageLookupByLibrary.simpleMessage(
      "Ang mga update sa Privacy Information na ito ay ipopost sa aming website o ikokomunika nang naaangkop. Pakisuri ito nang pana-panahon.",
    ),
    "privacy_info_section7_title": MessageLookupByLibrary.simpleMessage(
      "7. Mga Pagbabago sa Privacy Information na Ito:",
    ),
    "privacy_info_title": MessageLookupByLibrary.simpleMessage(
      "Maize Watch Privacy Information",
    ),
    "privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Patakaran sa Privacy",
    ),
    "processing": MessageLookupByLibrary.simpleMessage("Pinoproseso"),
    "processing_farm_analytics_data": MessageLookupByLibrary.simpleMessage(
      "Pinoproseso ang farm analytics data...",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profile_guide": MessageLookupByLibrary.simpleMessage("Gabay sa Profile"),
    "profile_management": MessageLookupByLibrary.simpleMessage(
      "Pamamahala ng Profile",
    ),
    "profile_update_in_progress": MessageLookupByLibrary.simpleMessage(
      "Ang pag-update ng profile ay kasalukuyang ginagawa. Pakihintay.",
    ),
    "profile_updated_successfully": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na na-update ang profile!",
    ),
    "prototype_id": MessageLookupByLibrary.simpleMessage("ID ng Prototype"),
    "prototype_id_hint": MessageLookupByLibrary.simpleMessage("Prototype ID *"),
    "prototype_id_not_found": MessageLookupByLibrary.simpleMessage(
      "Hindi makita ang prototype ID",
    ),
    "prototype_id_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang Prototype ID",
    ),
    "prototype_id_valid_and_available": MessageLookupByLibrary.simpleMessage(
      "Ang Prototype ID ay valid at available",
    ),
    "prototype_management": MessageLookupByLibrary.simpleMessage(
      "Pamamahala ng Prototype",
    ),
    "prototype_unsynced": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na na-unsync ang prototype",
    ),
    "province": MessageLookupByLibrary.simpleMessage("Lalawigan"),
    "province_cavite": MessageLookupByLibrary.simpleMessage("Cavite"),
    "province_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang lalawigan",
    ),
    "quiet_hours": MessageLookupByLibrary.simpleMessage("Mga Tahimik na Oras"),
    "r1_silking": MessageLookupByLibrary.simpleMessage(
      "Pagkakaroon ng Silk (R1)",
    ),
    "r6_mature": MessageLookupByLibrary.simpleMessage("Hinog (R6)"),
    "rainfall": MessageLookupByLibrary.simpleMessage("Ulan"),
    "rainy": MessageLookupByLibrary.simpleMessage("Maulan"),
    "rapid_growth": MessageLookupByLibrary.simpleMessage(
      "Mabilis na paglaki na nakita!",
    ),
    "real_time_sensor_monitoring": MessageLookupByLibrary.simpleMessage(
      "Real-time na Pagsubaybay ng Sensor",
    ),
    "receive_alerts_recommendations": MessageLookupByLibrary.simpleMessage(
      "Makatanggap ng mga alert at rekomendasyon",
    ),
    "recommendation_apply_fertilizer": MessageLookupByLibrary.simpleMessage(
      "Maglagay ng pataba ayon sa rekomendasyon para sa optimal na paglaki",
    ),
    "recommendation_light": MessageLookupByLibrary.simpleMessage(
      "Siguraduhin ang tamang exposure sa liwanag para sa malusog na paglaki",
    ),
    "recommendation_soil_ph": MessageLookupByLibrary.simpleMessage(
      "I-adjust ang soil pH sa mga rekomendadong antas",
    ),
    "recommendation_temperature": MessageLookupByLibrary.simpleMessage(
      "Subaybayan at panatilihin ang optimal na kondisyon ng temperatura",
    ),
    "recommendation_title": MessageLookupByLibrary.simpleMessage(
      "Mga Rekomendasyon",
    ),
    "recommendation_water": MessageLookupByLibrary.simpleMessage(
      "I-adjust ang irrigation schedule batay sa antas ng kahalumigmigan ng lupa",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("I-refresh"),
    "refresh_auth": MessageLookupByLibrary.simpleMessage("I-refresh ang Auth"),
    "refresh_farm_data": MessageLookupByLibrary.simpleMessage(
      "I-refresh ang Farm Data",
    ),
    "refresh_status": MessageLookupByLibrary.simpleMessage(
      "I-refresh ang Status",
    ),
    "region": MessageLookupByLibrary.simpleMessage("Rehiyon"),
    "region_calabarzon": MessageLookupByLibrary.simpleMessage(
      "CALABARZON (Region IV-A)",
    ),
    "region_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang rehiyon",
    ),
    "register": MessageLookupByLibrary.simpleMessage("Magparehistro"),
    "register_corn_button": MessageLookupByLibrary.simpleMessage(
      "Irehistro ang Mais",
    ),
    "register_corn_field_prompt": MessageLookupByLibrary.simpleMessage(
      "Pakirehistro ang isang corn field para makapagsimula ng pag-track ng progress.",
    ),
    "register_corn_next": MessageLookupByLibrary.simpleMessage(
      "Irehistro ang inyong mais sa susunod",
    ),
    "register_farm_details": MessageLookupByLibrary.simpleMessage(
      "Irehistro ang inyong farm details",
    ),
    "register_monitoring_devices": MessageLookupByLibrary.simpleMessage(
      "Irehistro ang mga monitoring device para sa inyong field (Kailangan ng hindi bababa sa isang device)",
    ),
    "register_page1_description": MessageLookupByLibrary.simpleMessage(
      "Gumawa ng inyong account sa pamamagitan ng pagbibigay ng inyong personal na impormasyon sa ibaba.",
    ),
    "register_page1_title": MessageLookupByLibrary.simpleMessage(
      "Simulan natin ang inyong pagrehistro",
    ),
    "register_page2_description": MessageLookupByLibrary.simpleMessage(
      "Ngayon ay mag-setup tayo ng inyong login credentials para sa seguridad ng inyong account.",
    ),
    "register_page2_title": MessageLookupByLibrary.simpleMessage("Kumusta, "),
    "registered": MessageLookupByLibrary.simpleMessage("Narehistrong"),
    "registered_devices": MessageLookupByLibrary.simpleMessage(
      "Naka-register na Devices",
    ),
    "registered_prototypes": MessageLookupByLibrary.simpleMessage(
      "Mga Nakarehistrong Prototype",
    ),
    "registration_failed": MessageLookupByLibrary.simpleMessage(
      "Nabigo ang pagrehistro. Pakisubukan ulit.",
    ),
    "registration_successful": MessageLookupByLibrary.simpleMessage(
      "Matagumpay ang pagrehistro! Pakilagay ang inyong impormasyon ng mais.",
    ),
    "registration_timeout": MessageLookupByLibrary.simpleMessage(
      "Ang server ay tumatagal sa pagtugon. Maaaring nagawa na ang inyong account. Pakisubukan ang pag-login.",
    ),
    "reproductive": MessageLookupByLibrary.simpleMessage("Reproduktibo"),
    "reproductive_phase_grain_development":
        MessageLookupByLibrary.simpleMessage(
          "Reproduktibong yugto - pag-unlad ng butil",
        ),
    "reproductive_stage": MessageLookupByLibrary.simpleMessage(
      "Reproduktibong Yugto",
    ),
    "request_timed_out": MessageLookupByLibrary.simpleMessage(
      "Nag-timeout ang request. Pakisuri ang inyong koneksyon at subukan ulit.",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Kailangan"),
    "resend_code": MessageLookupByLibrary.simpleMessage(
      "Ipadala ulit ang Code",
    ),
    "resend_in_seconds": m29,
    "resending": MessageLookupByLibrary.simpleMessage("Muling ipinapadala..."),
    "reset_password": MessageLookupByLibrary.simpleMessage(
      "I-reset ang Password",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Subukan Ulit"),
    "review_and_submit": MessageLookupByLibrary.simpleMessage(
      "Suriin at Ipadala",
    ),
    "sandy_soil": MessageLookupByLibrary.simpleMessage("Mabuhangin na lupa"),
    "saturday": MessageLookupByLibrary.simpleMessage("Sabado"),
    "save": MessageLookupByLibrary.simpleMessage("I-save"),
    "saving": MessageLookupByLibrary.simpleMessage("Nagse-save..."),
    "season_both": MessageLookupByLibrary.simpleMessage("Parehong Panahon"),
    "season_dry": MessageLookupByLibrary.simpleMessage(
      "Tag-araw (Disyembre hanggang Mayo)",
    ),
    "season_wet": MessageLookupByLibrary.simpleMessage(
      "Tag-ulan (Hunyo hanggang Nobyembre)",
    ),
    "seconds_ago": MessageLookupByLibrary.simpleMessage(
      "segundo na ang nakalipas",
    ),
    "see_more": MessageLookupByLibrary.simpleMessage("Tingnan pa"),
    "seedling_emergence_roots_developing": MessageLookupByLibrary.simpleMessage(
      "Pagsibol ng binhi - pag-unlad ng ugat",
    ),
    "select_barangay": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong barangay",
    ),
    "select_date": MessageLookupByLibrary.simpleMessage("Piliin ang Petsa"),
    "select_language": MessageLookupByLibrary.simpleMessage("Piliin ang Wika"),
    "select_municipality": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong bayan",
    ),
    "select_planting_date": MessageLookupByLibrary.simpleMessage(
      "Piliin ang petsa ng pagtatanim",
    ),
    "select_province": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong lalawigan",
    ),
    "select_region": MessageLookupByLibrary.simpleMessage(
      "Piliin ang inyong rehiyon",
    ),
    "send_verification_code": MessageLookupByLibrary.simpleMessage(
      "Ipadala ang Verification Code",
    ),
    "sending": MessageLookupByLibrary.simpleMessage("Nagse-send..."),
    "sensor_alert": MessageLookupByLibrary.simpleMessage("Alert ng Sensor"),
    "sensor_connection_issues": MessageLookupByLibrary.simpleMessage(
      "Mga Isyu sa Koneksyon ng Sensor",
    ),
    "sensor_data_is_updated_every_30_minutes_automatically":
        MessageLookupByLibrary.simpleMessage(
          "Ang datos mula sa sensor ay awtomatikong ina-update kada 30 minuto.",
        ),
    "sensor_is_actively_sending_data_to_thingspeak":
        MessageLookupByLibrary.simpleMessage(
          "Ang sensor ay aktibong nagpapadala ng data sa ThingSpeak",
        ),
    "sensor_is_not_sending_data_or_offline":
        MessageLookupByLibrary.simpleMessage(
          "Ang sensor ay hindi nagpapadala ng data o offline",
        ),
    "sensor_offline": MessageLookupByLibrary.simpleMessage("Sensor Offline"),
    "sensor_offline_alert": MessageLookupByLibrary.simpleMessage(
      "Alert ng sensor offline",
    ),
    "sensor_offline_description": m30,
    "sensor_offline_message": m31,
    "sensor_setup_guide": MessageLookupByLibrary.simpleMessage(
      "Gabay sa Setup ng Sensor",
    ),
    "sensor_sleep_description": MessageLookupByLibrary.simpleMessage(
      "Ang inyong mga sensor ay natutulog na mula 8pm hanggang 3am PH time. Gising sila sa 3am.",
    ),
    "sensor_sleep_mode": MessageLookupByLibrary.simpleMessage(
      "Mga Sensor sa Sleep Mode",
    ),
    "sensor_sleep_mode_alert": MessageLookupByLibrary.simpleMessage(
      "Mga sensor sa sleep mode",
    ),
    "sensor_status": MessageLookupByLibrary.simpleMessage("Status ng Sensor"),
    "sensor_status_description": MessageLookupByLibrary.simpleMessage(
      "Mga alert kapag ang mga sensor ay nag-offline o kailangan ng maintenance",
    ),
    "sensor_troubleshooting": MessageLookupByLibrary.simpleMessage(
      "Pag-aayos ng Problema sa Sensor",
    ),
    "sensors": MessageLookupByLibrary.simpleMessage("Mga Sensor"),
    "sensors_are_sleeping_from_8pm_to_3am_ph_time":
        MessageLookupByLibrary.simpleMessage(
          "Ang mga sensor ay natutulog mula 8pm hanggang 3am PH time",
        ),
    "sensors_in_sleep_mode": MessageLookupByLibrary.simpleMessage(
      "Mga Sensor sa Sleep Mode",
    ),
    "sensors_sleep_mode": MessageLookupByLibrary.simpleMessage(
      "Ang mga sensor ay nasa sleep mode (8pm-3am PH time)",
    ),
    "sensors_sleep_mode_message": MessageLookupByLibrary.simpleMessage(
      "Ang inyong mga sensor ay natutulog na mula 8pm hanggang 3am PH time. Gising sila sa 3am.",
    ),
    "sent": MessageLookupByLibrary.simpleMessage("Naipadala"),
    "sep": MessageLookupByLibrary.simpleMessage("Set"),
    "september": MessageLookupByLibrary.simpleMessage("Set"),
    "session_expired": MessageLookupByLibrary.simpleMessage(
      "Ang inyong session ay nag-expire na. Pakisubukan ang pag-login ulit.",
    ),
    "set_up_weather_station": MessageLookupByLibrary.simpleMessage(
      "Mag-setup ng weather station",
    ),
    "setting_up_and_managing_app_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Pag-setup at pamamahala ng mga notipikasyon ng app",
        ),
    "setting_up_your_farm": MessageLookupByLibrary.simpleMessage(
      "Pag-setup ng Inyong Farm",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "setup": MessageLookupByLibrary.simpleMessage("I-setup"),
    "setup_farm_data_message": MessageLookupByLibrary.simpleMessage(
      "Ngayon ay mag-setup tayo ng inyong farm data para magsimula ng pagmomonitor ng inyong mga tanim na mais.",
    ),
    "silking_stage": m32,
    "silks_emerging": MessageLookupByLibrary.simpleMessage(
      "May silk na sa mga uhay",
    ),
    "silty_soil": MessageLookupByLibrary.simpleMessage("Maalikabok na lupa"),
    "sleep_mode_active": MessageLookupByLibrary.simpleMessage(
      "Aktibo ang Sleep Mode",
    ),
    "smart_analytics": MessageLookupByLibrary.simpleMessage(
      "Matalinong Analitika",
    ),
    "smooth_textured_soil": MessageLookupByLibrary.simpleMessage(
      "Makinis na lupa na may magandang moisture retention",
    ),
    "soilMoistureSensor": MessageLookupByLibrary.simpleMessage(
      "Soil Moisture Sensor",
    ),
    "soil_clay": MessageLookupByLibrary.simpleMessage("Clay"),
    "soil_clay_desc": MessageLookupByLibrary.simpleMessage(
      "Mabigat, nagtataglay ng tubig",
    ),
    "soil_loam": MessageLookupByLibrary.simpleMessage("Loam"),
    "soil_loamy": MessageLookupByLibrary.simpleMessage("Loamy"),
    "soil_loamy_desc": MessageLookupByLibrary.simpleMessage(
      "Halo ng buhangin, silt, clay",
    ),
    "soil_moisture": MessageLookupByLibrary.simpleMessage(
      "Kahalumigmigan ng Lupa",
    ),
    "soil_moisture_sensor": MessageLookupByLibrary.simpleMessage(
      "Soil Moisture Sensor",
    ),
    "soil_peaty": MessageLookupByLibrary.simpleMessage("Peaty"),
    "soil_ph": MessageLookupByLibrary.simpleMessage("pH ng Lupa"),
    "soil_ph_sensor": MessageLookupByLibrary.simpleMessage(
      "Sensor ng pH ng Lupa",
    ),
    "soil_saline": MessageLookupByLibrary.simpleMessage("Saline"),
    "soil_sandy": MessageLookupByLibrary.simpleMessage("Sandy"),
    "soil_sandy_desc": MessageLookupByLibrary.simpleMessage(
      "Magaan, mabilis matuyo",
    ),
    "soil_silt": MessageLookupByLibrary.simpleMessage("Silt"),
    "soil_silty": MessageLookupByLibrary.simpleMessage("Silty"),
    "soil_silty_desc": MessageLookupByLibrary.simpleMessage(
      "Makinis, nagtataglay ng kahalumigmigan",
    ),
    "soil_type": MessageLookupByLibrary.simpleMessage("Uri ng Lupa"),
    "soil_type_hint": MessageLookupByLibrary.simpleMessage("Uri ng Lupa *"),
    "soil_type_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang uri ng lupa",
    ),
    "soil_type_title": MessageLookupByLibrary.simpleMessage(
      "Piliin ang uri ng lupa ng inyong field",
    ),
    "soon": MessageLookupByLibrary.simpleMessage("Malapit na"),
    "soundAndVibrate": MessageLookupByLibrary.simpleMessage("Tunog & Vibrate"),
    "sound_and_vibrate": MessageLookupByLibrary.simpleMessage(
      "Tunog & Vibrate",
    ),
    "stable": MessageLookupByLibrary.simpleMessage("Matatag ang paglaki"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "status_all_completed_deleted": MessageLookupByLibrary.simpleMessage(
      "Lahat ng tapos na reseta ay natanggal",
    ),
    "status_all_deleted": MessageLookupByLibrary.simpleMessage(
      "Lahat ng reseta ay natanggal",
    ),
    "status_check": MessageLookupByLibrary.simpleMessage("Pagsuri ng Status"),
    "status_completed": MessageLookupByLibrary.simpleMessage("NAKUMPLETO"),
    "status_legend": MessageLookupByLibrary.simpleMessage(
      "Palatandaan ng Status",
    ),
    "status_prescription_completed": MessageLookupByLibrary.simpleMessage(
      "Ang reseta ay minarkahan bilang tapos na",
    ),
    "status_prescription_deleted": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na natanggal ang reseta",
    ),
    "status_prescription_pending": MessageLookupByLibrary.simpleMessage(
      "Ang reseta ay minarkahan bilang pending",
    ),
    "stay_updated": MessageLookupByLibrary.simpleMessage(
      "Manatiling updated sa inyong sakahan!",
    ),
    "step1_title": MessageLookupByLibrary.simpleMessage("Field"),
    "step2_title": MessageLookupByLibrary.simpleMessage("Lupa"),
    "step3_title": MessageLookupByLibrary.simpleMessage("Mais"),
    "step4_title": MessageLookupByLibrary.simpleMessage("Panahon"),
    "step5_title": MessageLookupByLibrary.simpleMessage("Edad"),
    "step_by_step_guide_to_connect_your_monitoring_sensors":
        MessageLookupByLibrary.simpleMessage(
          "Step-by-step na guide para sa pag-connect ng inyong monitoring sensors",
        ),
    "step_by_step_instructions": MessageLookupByLibrary.simpleMessage(
      "Mga Hakbang na Gabay",
    ),
    "steps": MessageLookupByLibrary.simpleMessage("mga hakbang"),
    "submit": MessageLookupByLibrary.simpleMessage("Ipadala"),
    "submit_button": MessageLookupByLibrary.simpleMessage("Ipadala"),
    "submit_farm_data": MessageLookupByLibrary.simpleMessage(
      "I-submit ang Farm Data",
    ),
    "sunday": MessageLookupByLibrary.simpleMessage("Linggo"),
    "sunny": MessageLookupByLibrary.simpleMessage("Maaraw"),
    "support": MessageLookupByLibrary.simpleMessage("Suporta"),
    "system": MessageLookupByLibrary.simpleMessage("Sistema"),
    "tap_to_view": MessageLookupByLibrary.simpleMessage("I-tap para tingnan"),
    "tasseling": MessageLookupByLibrary.simpleMessage("Pagkakaroon ng Tassel"),
    "tasseling_reproductive_phase_begins": MessageLookupByLibrary.simpleMessage(
      "Pagkakaroon ng tassel - nagsisimula ang reproduktibong yugto",
    ),
    "tasseling_stage": m33,
    "tassels_appearing": MessageLookupByLibrary.simpleMessage(
      "May tassel na sa taas",
    ),
    "tempHumidSensor": MessageLookupByLibrary.simpleMessage(
      "Temperature & Humidity Sensor",
    ),
    "temp_humid_sensor": MessageLookupByLibrary.simpleMessage(
      "Temperatura at Halumigmig",
    ),
    "temperature": MessageLookupByLibrary.simpleMessage("Temperatura"),
    "temperature_sensor": MessageLookupByLibrary.simpleMessage(
      "Sensor ng Temperatura",
    ),
    "terms_intro": MessageLookupByLibrary.simpleMessage(
      "Maligayang pagdating sa Maize Watch. Sa pag-access o paggamit ng aming platform, serbisyo, at mga kaugnay na tool, sumasang-ayon kayo na sumunod at maging nakatali sa mga Terms of Use na ito. Kung hindi kayo sumasang-ayon sa anumang bahagi ng mga tuntuning ito, pakihuwag gamitin ang Maize Watch.",
    ),
    "terms_of_service": MessageLookupByLibrary.simpleMessage(
      "Mga Tuntunin ng Serbisyo",
    ),
    "terms_of_use": MessageLookupByLibrary.simpleMessage(
      "Mga Tuntunin ng Paggamit",
    ),
    "terms_section1_content": MessageLookupByLibrary.simpleMessage(
      "Maaari ninyong gamitin ang Maize Watch para sa mga legal na layunin lamang at alinsunod sa mga tuntuning ito.\nKayo ay responsable sa pagpapanatili ng confidentiality ng inyong account credentials at lahat ng mga aktibidad sa ilalim ng inyong account.\nSumasang-ayon kayo na huwag abusuhin ang platform, makialam sa seguridad o functionality nito, o subukang mag-access nang walang pahintulot sa anumang bahagi ng sistema.",
    ),
    "terms_section1_title": MessageLookupByLibrary.simpleMessage(
      "1. Paggamit ng Platform:",
    ),
    "terms_section2_content": MessageLookupByLibrary.simpleMessage(
      "Kayo ay nananatiling may buong pagmamay-ari ng inyong farm data at sensor information.\nSa paggamit ng Maize Watch, binibigyan ninyo kami ng pahintulot na i-analyze ang inyong data para magbigay ng personalized insights at i-improve ang performance ng platform.\nHindi namin ibabahagi ang inyong identifiable data nang walang inyong tahasang pahintulot, tulad ng nakabalangkas sa aming Privacy Policy.",
    ),
    "terms_section2_title": MessageLookupByLibrary.simpleMessage(
      "2. Pagmamay-ari at Paggamit ng Data:",
    ),
    "terms_section3_content": MessageLookupByLibrary.simpleMessage(
      "Lahat ng content sa Maize Watch, kasama ang mga visualization, software, text, graphics, at logos, ay pagmamay-ari ng Maize Watch o ng mga licensor nito.\nHindi ninyo maaaring i-reproduce, i-distribute, i-modify, o gumawa ng derivative works nang walang aming nakasulat na pahintulot.",
    ),
    "terms_section3_title": MessageLookupByLibrary.simpleMessage(
      "3. Intellectual Property:",
    ),
    "terms_section4_content": MessageLookupByLibrary.simpleMessage(
      "Reserbado namin ang karapatan na i-suspend o i-terminate ang inyong access sa Maize Watch anumang oras kung lalabagin ninyo ang mga tuntuning ito, aabusuhin ang platform, o makikisali sa anumang pag-uugali na makakagambala sa serbisyo para sa ibang mga user.",
    ),
    "terms_section4_title": MessageLookupByLibrary.simpleMessage(
      "4. Pagwawakas ng Account:",
    ),
    "terms_section5_content": MessageLookupByLibrary.simpleMessage(
      "Ang Maize Watch ay nagbibigay ng data-based insights para suportahan ang mga desisyon sa agrikultura. Ang mga huling desisyon tungkol sa mga gawi sa pagsasaka ay nananatiling inyong responsibilidad.\nHindi namin ginagarantiyahan ang mga tiyak na resulta ng ani o kakayahang kumita dahil ang tagumpay sa agrikultura ay nakadepende sa maraming hindi makokontrol na mga salik.\nAng platform ay ibinibigay \"as-is\" at \"as available\" nang walang mga warranty ng anumang uri.",
    ),
    "terms_section5_title": MessageLookupByLibrary.simpleMessage(
      "5. Mga Disclaimer:",
    ),
    "terms_section6_content": MessageLookupByLibrary.simpleMessage(
      "Sa lawak na pinahihintulutan ng batas, ang Maize Watch ay hindi mananagot para sa anumang hindi direktang, incidental, o consequential na pinsala na nagmumula sa inyong paggamit ng platform, kasama ang pagkawala ng data, pagkawala ng ani, o mga desisyon na may kaugnayan sa sakahan na ginawa batay sa aming analytics.",
    ),
    "terms_section6_title": MessageLookupByLibrary.simpleMessage(
      "6. Limitasyon ng Pananagutan:",
    ),
    "terms_section7_content": MessageLookupByLibrary.simpleMessage(
      "Maaari naming i-update ang mga Terms of Use na ito paminsan-minsan. Ang mga mahahalagang pagbabago ay ikokomunika sa pamamagitan ng aming platform o sa pamamagitan ng email. Ang patuloy na paggamit ng Maize Watch ay nangangahulugang tinatanggap ninyo ang mga na-update na tuntunin.",
    ),
    "terms_section7_title": MessageLookupByLibrary.simpleMessage(
      "7. Mga Update sa mga Tuntunin:",
    ),
    "test_notification": MessageLookupByLibrary.simpleMessage(
      "Test na Notification",
    ),
    "textSizeLabel": MessageLookupByLibrary.simpleMessage("Laki ng Teksto"),
    "the_app_requires_internet_connection_to_sync_data_and_receive_updates":
        MessageLookupByLibrary.simpleMessage(
          "Kailangan ng internet connection ang app para makapag-sync ng datos at makatanggap ng mga update.",
        ),
    "the_app_will_show_offline_status_and_send_notifications_when_sensors_reconnect":
        MessageLookupByLibrary.simpleMessage(
          "Ipakikita ng app ang offline status at magpapadala ng notipikasyon kapag muling nakakonekta ang mga sensor.",
        ),
    "third_leaf_stage": m34,
    "this_month": MessageLookupByLibrary.simpleMessage("Ngayong buwan"),
    "this_prescription_is_completed": MessageLookupByLibrary.simpleMessage(
      "Ang prescription na ito ay tapos na",
    ),
    "this_week": MessageLookupByLibrary.simpleMessage("Sa linggong ito"),
    "thursday": MessageLookupByLibrary.simpleMessage("Huwebes"),
    "timeline": MessageLookupByLibrary.simpleMessage("Timeline"),
    "timeline_filter": m35,
    "timeline_next_week": MessageLookupByLibrary.simpleMessage(
      "Susunod na Linggo",
    ),
    "timeline_this_week": MessageLookupByLibrary.simpleMessage(
      "Ngayong Linggo",
    ),
    "timeline_today": MessageLookupByLibrary.simpleMessage("Ngayon"),
    "tips_to_improve_app_performance_and_speed":
        MessageLookupByLibrary.simpleMessage(
          "Mga tip para mapahusay ang performance at bilis ng app",
        ),
    "to": MessageLookupByLibrary.simpleMessage("Hanggang"),
    "today": MessageLookupByLibrary.simpleMessage("Ngayon"),
    "tooltip_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Tanggalin ang reseta",
    ),
    "tooltip_refresh_prescriptions": MessageLookupByLibrary.simpleMessage(
      "I-refresh ang mga reseta",
    ),
    "track_temperature_humidity_soil_moisture_and_light_levels":
        MessageLookupByLibrary.simpleMessage(
          "Subaybayan ang temperatura, halumigmig, kahalumigmigan ng lupa, at antas ng liwanag",
        ),
    "translate": MessageLookupByLibrary.simpleMessage("Isalin"),
    "troubleshooting": MessageLookupByLibrary.simpleMessage(
      "Pag-aayos ng Problema",
    ),
    "try_again": MessageLookupByLibrary.simpleMessage("Subukan Ulit"),
    "tuesday": MessageLookupByLibrary.simpleMessage("Martes"),
    "twitter": MessageLookupByLibrary.simpleMessage("Twitter"),
    "type": MessageLookupByLibrary.simpleMessage("Uri"),
    "unable_to_update_prescription_status":
        MessageLookupByLibrary.simpleMessage(
          "Hindi ma-update ang status ng reseta",
        ),
    "understanding_your_farm_analytics_and_reports":
        MessageLookupByLibrary.simpleMessage(
          "Pag-unawa sa analitika at mga ulat ng inyong sakahan",
        ),
    "undo_complete": MessageLookupByLibrary.simpleMessage("I-undo ang Tapos"),
    "unexpected_error": MessageLookupByLibrary.simpleMessage(
      "Hindi kilalang error",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("HINDI KILALA"),
    "unknown_action": MessageLookupByLibrary.simpleMessage(
      "Hindi Kilalang Aksyon",
    ),
    "unknown_field": MessageLookupByLibrary.simpleMessage(
      "Hindi Kilalang Field",
    ),
    "unknown_sensor": MessageLookupByLibrary.simpleMessage(
      "Hindi Kilalang Sensor",
    ),
    "unnamed_device": MessageLookupByLibrary.simpleMessage(
      "Walang pangalan na Device",
    ),
    "unsync_prototype": MessageLookupByLibrary.simpleMessage(
      "I-unsync ang Prototype",
    ),
    "unsync_prototype_confirmation": MessageLookupByLibrary.simpleMessage(
      "Sigurado ba kayo na gusto ninyong i-unsync ang prototype na ito mula sa field? Ang aksyong ito ay hindi na mababawi.",
    ),
    "update_device": MessageLookupByLibrary.simpleMessage(
      "I-update ang Device",
    ),
    "urgency": MessageLookupByLibrary.simpleMessage("Kadalian"),
    "urgency_filter": m36,
    "urgency_high": MessageLookupByLibrary.simpleMessage("MATAAS"),
    "urgency_low": MessageLookupByLibrary.simpleMessage("MABABA"),
    "urgency_medium": MessageLookupByLibrary.simpleMessage("KATAMTAMAN"),
    "urgency_urgent": MessageLookupByLibrary.simpleMessage("URGENT"),
    "urgent": MessageLookupByLibrary.simpleMessage("Kailangan agad"),
    "user_id_not_found": MessageLookupByLibrary.simpleMessage(
      "Hindi nahanap ang User ID",
    ),
    "user_not_authenticated": MessageLookupByLibrary.simpleMessage(
      "Ang user ay hindi naka-authenticate",
    ),
    "user_registration_successful": MessageLookupByLibrary.simpleMessage(
      "Matagumpay ang Pagrehistro ng User!",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "username_already_exists": MessageLookupByLibrary.simpleMessage(
      "Mayroon nang ganitong username. Pakisubukan ang iba.",
    ),
    "username_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Ang username ay hindi maaaring magkaroon ng magkakasunod na tuldok o underscore",
    ),
    "username_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Ang username ay maaari lamang maglaman ng mga titik, numero, underscore, at tuldok",
    ),
    "username_invalid_end": MessageLookupByLibrary.simpleMessage(
      "Ang username ay dapat magtapos sa isang titik o numero",
    ),
    "username_invalid_start": MessageLookupByLibrary.simpleMessage(
      "Ang username ay dapat magsimula sa isang titik o numero",
    ),
    "username_must_be_at_least_3_characters":
        MessageLookupByLibrary.simpleMessage(
          "Ang username ay dapat hindi bababa sa 3 na character",
        ),
    "username_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang username",
    ),
    "username_too_long": MessageLookupByLibrary.simpleMessage(
      "Ang username ay hindi dapat lumampas sa 20 na character",
    ),
    "username_too_short": MessageLookupByLibrary.simpleMessage(
      "Ang username ay dapat hindi bababa sa 3 na character",
    ),
    "v3_early_growth": MessageLookupByLibrary.simpleMessage(
      "Maagang Paglaki (V3)",
    ),
    "v8_mid_growth": MessageLookupByLibrary.simpleMessage(
      "Gitnang Paglaki (V8)",
    ),
    "valid_ph_number_required": MessageLookupByLibrary.simpleMessage(
      "Ilagay ang wastong Philippine mobile number",
    ),
    "validate": MessageLookupByLibrary.simpleMessage("I-validate"),
    "validated": MessageLookupByLibrary.simpleMessage("Na-validate"),
    "variety_field_corn": MessageLookupByLibrary.simpleMessage("Field Corn"),
    "variety_field_corn_desc": MessageLookupByLibrary.simpleMessage(
      "Para sa pagkain ng hayop, ethanol",
    ),
    "variety_flint": MessageLookupByLibrary.simpleMessage("Flint"),
    "variety_flint_corn": MessageLookupByLibrary.simpleMessage("Flint Corn"),
    "variety_flint_corn_desc": MessageLookupByLibrary.simpleMessage(
      "Makulay, pandekorasyon",
    ),
    "variety_glutinous": MessageLookupByLibrary.simpleMessage(
      "Glutinous (Malagkit)",
    ),
    "variety_popcorn": MessageLookupByLibrary.simpleMessage("Popcorn"),
    "variety_popcorn_desc": MessageLookupByLibrary.simpleMessage(
      "Para sa pagpo-pop",
    ),
    "variety_purple": MessageLookupByLibrary.simpleMessage("Purple"),
    "variety_sweet": MessageLookupByLibrary.simpleMessage("Sweet"),
    "variety_sweet_corn": MessageLookupByLibrary.simpleMessage("Sweet Corn"),
    "variety_sweet_corn_desc": MessageLookupByLibrary.simpleMessage(
      "Para sa pagkain ng tao",
    ),
    "variety_white_fodder": MessageLookupByLibrary.simpleMessage(
      "White Fodder",
    ),
    "variety_yellow_dent": MessageLookupByLibrary.simpleMessage("Yellow Dent"),
    "ve_emergence": MessageLookupByLibrary.simpleMessage("Pagsibol (VE)"),
    "ve_stage": MessageLookupByLibrary.simpleMessage("VE"),
    "verification_code": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "verification_code_description": m37,
    "verification_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Pakilagay ang wastong 6-digit code",
    ),
    "verification_code_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang verification code ay dapat maglaman lamang ng mga numero",
    ),
    "verification_code_invalid_length": MessageLookupByLibrary.simpleMessage(
      "Ang verification code ay dapat 6 na digit",
    ),
    "verification_code_required": MessageLookupByLibrary.simpleMessage(
      "Kailangan ang verification code",
    ),
    "verification_code_resent": MessageLookupByLibrary.simpleMessage(
      "Matagumpay na na-resend ang verification code",
    ),
    "verification_code_sent": MessageLookupByLibrary.simpleMessage(
      "Naipadala ang Verification Code",
    ),
    "verification_failed": MessageLookupByLibrary.simpleMessage(
      "Nabigo ang Verification",
    ),
    "verification_help_text": MessageLookupByLibrary.simpleMessage(
      "Hindi nakatanggap ng code? Tingnan ang inyong SMS messages o subukan ulit.",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("I-verify"),
    "verify_phone_number": MessageLookupByLibrary.simpleMessage(
      "I-verify ang Phone Number",
    ),
    "verifying": MessageLookupByLibrary.simpleMessage("Nag-ve-verify..."),
    "version": MessageLookupByLibrary.simpleMessage("bersyon 1.0.0"),
    "versionInfo": MessageLookupByLibrary.simpleMessage("bersyon 1.0.0"),
    "very_bright": MessageLookupByLibrary.simpleMessage("Napakaliwanag"),
    "very_dry": MessageLookupByLibrary.simpleMessage("Napakatuyo"),
    "very_high": MessageLookupByLibrary.simpleMessage("Napakataas"),
    "vibrate": MessageLookupByLibrary.simpleMessage("Vibrate"),
    "vibrationOnly": MessageLookupByLibrary.simpleMessage("Vibration Lang"),
    "vibration_only": MessageLookupByLibrary.simpleMessage("Vibration Lang"),
    "vibration_only_description": MessageLookupByLibrary.simpleMessage(
      "Tahimik na notifications na may vibration lang",
    ),
    "vibration_only_enabled_disabled": m38,
    "view_all": MessageLookupByLibrary.simpleMessage("Tingnan Lahat"),
    "view_complete_prescriptions": MessageLookupByLibrary.simpleMessage(
      "kumpletuhin ang inyong mga reseta",
    ),
    "view_details": MessageLookupByLibrary.simpleMessage("Tingnan ang Detalye"),
    "view_more_details": MessageLookupByLibrary.simpleMessage(
      "Tingnan ang mas maraming detalye",
    ),
    "vt_tasseling": MessageLookupByLibrary.simpleMessage(
      "Pagkakaroon ng Tassel (VT)",
    ),
    "warning": MessageLookupByLibrary.simpleMessage("BABALA"),
    "water_retaining_soil": MessageLookupByLibrary.simpleMessage(
      "Lupa na nag-iimbak ng tubig na may mataas na fertility",
    ),
    "weather_integration": MessageLookupByLibrary.simpleMessage(
      "Pagsasama ng Impormasyon sa Panahon",
    ),
    "website": MessageLookupByLibrary.simpleMessage("Website"),
    "wednesday": MessageLookupByLibrary.simpleMessage("Miyerkules"),
    "weekly_overview": MessageLookupByLibrary.simpleMessage("Buod ng Linggo"),
    "weekly_summary": MessageLookupByLibrary.simpleMessage("Buod ng Linggo"),
    "welcome": MessageLookupByLibrary.simpleMessage(
      "Maligayang pagdating sa Maize Watch",
    ),
    "welcome_back": MessageLookupByLibrary.simpleMessage(
      "Maligayang pagbabalik!",
    ),
    "well_balanced_soil": MessageLookupByLibrary.simpleMessage(
      "Mabuting balansadong lupa",
    ),
    "wet": MessageLookupByLibrary.simpleMessage("Mabasa"),
    "what_if_my_sensors_go_offline": MessageLookupByLibrary.simpleMessage(
      "Paano kung mag-offline ang aking mga sensor?",
    ),
    "when_did_you_plant": MessageLookupByLibrary.simpleMessage(
      "Kailan kayo nagtanim ng inyong mais? Tumutulong ito sa amin na matukoy ang kasalukuyang yugto ng paglaki.",
    ),
    "why_your_data_might_not_be_refreshing":
        MessageLookupByLibrary.simpleMessage(
          "Mga dahilan kung bakit hindi nagre-refresh ang inyong datos",
        ),
    "yes": MessageLookupByLibrary.simpleMessage("Oo"),
    "yesterday": MessageLookupByLibrary.simpleMessage("Kahapon"),
    "you_have_new_farm_tasks": m39,
    "your_farm_has_been_successfully_registered_and_is_ready_for_monitoring":
        MessageLookupByLibrary.simpleMessage(
          "Ang inyong farm ay matagumpay na na-register at handa na para sa monitoring.",
        ),
    "your_personal_information": MessageLookupByLibrary.simpleMessage(
      "Inyong Personal na Impormasyon",
    ),
    "zip_code": MessageLookupByLibrary.simpleMessage("Zip Code"),
    "zip_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Pakilagay ang wastong zip code",
    ),
    "zip_code_optional": MessageLookupByLibrary.simpleMessage(
      "Zip Code (Opsiyonal)",
    ),
  };
}
