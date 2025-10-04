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

  static String m0(category) => "Category: ${category}";

  static String m1(fieldName, farmName) =>
      "Congratulations! Your field \"${fieldName}\" in farm \"${farmName}\" has been successfully registered.";

  static String m2(days) => "${days}d left";

  static String m3(days, rate) => "${days} days to next stage (${rate}/day)";

  static String m4(deadline) => "Deadline: ${deadline}";

  static String m5(count) =>
      "${Intl.plural(count, zero: 'No devices registered', one: '1 Device Registered', other: '${count} Devices Registered')}";

  static String m6(parameter) =>
      "Are you sure you want to delete this ${parameter} prescription?";

  static String m7(days) => "V8 - Eighth Leaf Stage (${days} days)";

  static String m8(days) => "VE - Emergence Stage (${days} days)";

  static String m9(filter) => "No prescriptions found for \"${filter}\"";

  static String m10(error) => "Error sa pag-load ng mga prototype: ${error}";

  static String m11(error) => "Error sa pag-unsync ng prototype: ${error}";

  static String m12(error) => "Failed to update profile: ${error}";

  static String m13(filters) => "Filtered by: ${filters}";

  static String m14(hours) => "${hours}h left";

  static String m15(language) => "Language changed to ${language}";

  static String m16(days) => "R6 - Maturity Stage (${days} days)";

  static String m17(count) => "You have ${count} new farm tasks to complete";

  static String m18(error) =>
      "Failed to update notification settings: ${error}";

  static String m19(enabled) => "Notifications enabled: ${enabled}";

  static String m20(status) => "Notifications ${status}";

  static String m21(prototypeId) => "Prototype ID: ${prototypeId}";

  static String m22(seconds) => "Resend in ${seconds} seconds";

  static String m23(sensorName) =>
      "${sensorName} sensor has been offline for more than 30 minutes.";

  static String m24(sensorName) =>
      "${sensorName} sensor has been offline for more than 30 minutes.";

  static String m25(days) => "R1 - Silking Stage (${days} days)";

  static String m26(count) => "Step-by-Step Instructions (${count} steps)";

  static String m27(days) => "VT - Tasseling Stage (${days} days)";

  static String m28(days) => "V3 - Third Leaf Stage (${days} days)";

  static String m29(timeline) => "Timeline: ${timeline}";

  static String m30(urgency) => "Urgency: ${urgency}";

  static String m31(phoneNumber) =>
      "We\'ve sent a 6-digit verification code to ${phoneNumber}. Please enter it below to continue.";

  static String m32(status) => "Vibration only ${status}";

  static String m33(count) => "You have ${count} new farm tasks to complete";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "aboutApp": MessageLookupByLibrary.simpleMessage(
      "Maize Watch is a crop monitoring application designed to help farmers keep track of maize growth and identify issues quickly.",
    ),
    "about_app": MessageLookupByLibrary.simpleMessage(
      "The maize-watch mobile app proposes an innovative, IoT-driven corn monitoring system enhanced by prescriptive analytics. This system will not only provide real-time data on crop health and environmental conditions but also use these data to offer practical advice, further optimizing maize quality and yield.",
    ),
    "about_user": MessageLookupByLibrary.simpleMessage("About User"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action_check_all": MessageLookupByLibrary.simpleMessage("Check All"),
    "action_delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "action_delete_all": MessageLookupByLibrary.simpleMessage("Delete All"),
    "action_delete_completed": MessageLookupByLibrary.simpleMessage(
      "Delete Completed",
    ),
    "action_uncheck_all": MessageLookupByLibrary.simpleMessage("Uncheck All"),
    "active": MessageLookupByLibrary.simpleMessage("Aktibo"),
    "active_sensor_is_sending_data_to_thingspeak":
        MessageLookupByLibrary.simpleMessage(
          "Aktibo: Ang sensor ay nagpapadala ng data sa ThingSpeak",
        ),
    "add_field": MessageLookupByLibrary.simpleMessage("Add Field"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "address_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Address contains invalid characters",
    ),
    "address_needs_alphanumeric": MessageLookupByLibrary.simpleMessage(
      "Address must contain at least one letter or number",
    ),
    "address_required": MessageLookupByLibrary.simpleMessage(
      "Address is required",
    ),
    "address_too_long": MessageLookupByLibrary.simpleMessage(
      "Address must not exceed 200 characters",
    ),
    "address_too_short": MessageLookupByLibrary.simpleMessage(
      "Address must be at least 10 characters long",
    ),
    "agreement_prefix": MessageLookupByLibrary.simpleMessage(
      "By logging in, you agree to our ",
    ),
    "agreement_suffix": MessageLookupByLibrary.simpleMessage("."),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "all_fields_required": MessageLookupByLibrary.simpleMessage(
      "All fields are required.",
    ),
    "and": MessageLookupByLibrary.simpleMessage(" and "),
    "appName": MessageLookupByLibrary.simpleMessage("Maize Watch"),
    "app_settings": MessageLookupByLibrary.simpleMessage("App Settings"),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "apr": MessageLookupByLibrary.simpleMessage("Apr"),
    "april": MessageLookupByLibrary.simpleMessage("Apr"),
    "asap": MessageLookupByLibrary.simpleMessage("ASAP"),
    "aug": MessageLookupByLibrary.simpleMessage("Aug"),
    "august": MessageLookupByLibrary.simpleMessage("Aug"),
    "authentication_required": MessageLookupByLibrary.simpleMessage(
      "Authentication required",
    ),
    "available": MessageLookupByLibrary.simpleMessage("Available"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "back_button": MessageLookupByLibrary.simpleMessage("Back"),
    "back_online": MessageLookupByLibrary.simpleMessage("Back Online"),
    "back_to_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Back to Prescriptions",
    ),
    "barangay": MessageLookupByLibrary.simpleMessage("Barangay"),
    "barangay_required": MessageLookupByLibrary.simpleMessage(
      "Barangay is required",
    ),
    "bright": MessageLookupByLibrary.simpleMessage("Bright"),
    "button_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "category": MessageLookupByLibrary.simpleMessage("Category"),
    "category_filter": m0,
    "category_humidity_management": MessageLookupByLibrary.simpleMessage(
      "Humidity Management",
    ),
    "category_irrigation": MessageLookupByLibrary.simpleMessage("Irrigation"),
    "category_light_management": MessageLookupByLibrary.simpleMessage(
      "Light Management",
    ),
    "category_soil_treatment": MessageLookupByLibrary.simpleMessage(
      "Soil Treatment",
    ),
    "category_temperature_management": MessageLookupByLibrary.simpleMessage(
      "Temperature Management",
    ),
    "check_farm": MessageLookupByLibrary.simpleMessage("Check Farm"),
    "check_notification_status": MessageLookupByLibrary.simpleMessage(
      "Check Notification Status",
    ),
    "checking_if_sensors_are_actively_sending_data_to_thingspeak":
        MessageLookupByLibrary.simpleMessage(
          "Sinusuri kung ang mga sensor ay aktibong nagpapadala ng data sa ThingSpeak",
        ),
    "clear_all": MessageLookupByLibrary.simpleMessage("Clear All"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "cloudy": MessageLookupByLibrary.simpleMessage("Cloudy"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "confirm_password_required": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "confirm_unsync": MessageLookupByLibrary.simpleMessage("Confirm Unsync"),
    "congratulations_field_registered": m1,
    "connection_error": MessageLookupByLibrary.simpleMessage(
      "Connection error. Please check your internet and try again.",
    ),
    "contactUs": MessageLookupByLibrary.simpleMessage("Contact us at:"),
    "contact_information_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Contact information coming soon!",
    ),
    "contact_number": MessageLookupByLibrary.simpleMessage("Contact Number"),
    "contact_number_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Ang contact number ay dapat nasa format na 09xxxxxxxxx (hal., 09194022808)",
    ),
    "contact_number_invalid_length": MessageLookupByLibrary.simpleMessage(
      "Contact number must be exactly 10 digits (without +63)",
    ),
    "contact_number_invalid_prefix": MessageLookupByLibrary.simpleMessage(
      "Invalid Philippine mobile number prefix",
    ),
    "contact_number_required": MessageLookupByLibrary.simpleMessage(
      "Contact number is required",
    ),
    "contact_support": MessageLookupByLibrary.simpleMessage(
      "Makipag-ugnayan sa Suporta",
    ),
    "continue_to_dashboard": MessageLookupByLibrary.simpleMessage(
      "Continue to Dashboard",
    ),
    "continue_to_field_registration": MessageLookupByLibrary.simpleMessage(
      "Continue to Field Registration",
    ),
    "continue_to_registration": MessageLookupByLibrary.simpleMessage(
      "Continue to Registration",
    ),
    "corn": MessageLookupByLibrary.simpleMessage("Corn"),
    "corn_age_title": MessageLookupByLibrary.simpleMessage(
      "How old is your corn crop?",
    ),
    "corn_growth": MessageLookupByLibrary.simpleMessage("Corn Growth"),
    "corn_registration": MessageLookupByLibrary.simpleMessage(
      "Corn Registration",
    ),
    "corn_variety": MessageLookupByLibrary.simpleMessage("Corn Variety"),
    "corn_variety_required": MessageLookupByLibrary.simpleMessage(
      "Corn variety is required",
    ),
    "corn_variety_title": MessageLookupByLibrary.simpleMessage(
      "Choose your preferred corn variety",
    ),
    "critical": MessageLookupByLibrary.simpleMessage("Critical"),
    "crop_condition_critical_stress": MessageLookupByLibrary.simpleMessage(
      "Critical stress",
    ),
    "crop_condition_healthy": MessageLookupByLibrary.simpleMessage("Healthy"),
    "crop_condition_high_stress": MessageLookupByLibrary.simpleMessage(
      "High stress",
    ),
    "crop_condition_moderate_stress": MessageLookupByLibrary.simpleMessage(
      "Moderate stress",
    ),
    "crop_condition_subtitle": MessageLookupByLibrary.simpleMessage(
      "Check the current status of your maize crop and get personalized recommendations.",
    ),
    "crop_condition_title": MessageLookupByLibrary.simpleMessage(
      "Crop Condition",
    ),
    "crop_excellent": MessageLookupByLibrary.simpleMessage(
      "Your crops are in excellent condition.",
    ),
    "crop_health": MessageLookupByLibrary.simpleMessage("Crop Health"),
    "crop_health_status": MessageLookupByLibrary.simpleMessage(
      "Kalagayan ng Kalusugan ng Tanim",
    ),
    "crop_okay": MessageLookupByLibrary.simpleMessage(
      "Your crops are doing okay. Monitor closely.",
    ),
    "crop_risk": MessageLookupByLibrary.simpleMessage(
      "Crops are at risk! Immediate action needed.",
    ),
    "current_growth_stage": MessageLookupByLibrary.simpleMessage(
      "Current Growth Stage",
    ),
    "dashboard_title": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "days": MessageLookupByLibrary.simpleMessage("days"),
    "days_ago": MessageLookupByLibrary.simpleMessage("days ago"),
    "days_left": m2,
    "days_since_planting": MessageLookupByLibrary.simpleMessage(
      "Days Since Planting",
    ),
    "days_to_next_stage": m3,
    "deadline": MessageLookupByLibrary.simpleMessage("Deadline"),
    "deadline_colon": m4,
    "debug_data_view": MessageLookupByLibrary.simpleMessage("Debug Data View"),
    "debug_section": MessageLookupByLibrary.simpleMessage("Debug Section"),
    "dec": MessageLookupByLibrary.simpleMessage("Dec"),
    "december": MessageLookupByLibrary.simpleMessage("Dec"),
    "declining": MessageLookupByLibrary.simpleMessage("Growth is declining"),
    "default_farm": MessageLookupByLibrary.simpleMessage("Default Farm"),
    "default_user": MessageLookupByLibrary.simpleMessage("farmer"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Delete Prescription",
    ),
    "delete_prescription_confirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this completed prescription? This action cannot be undone.",
    ),
    "description": MessageLookupByLibrary.simpleMessage(
      "Maximize your yields, minimize your worries.",
    ),
    "device_registration": MessageLookupByLibrary.simpleMessage(
      "Device Registration",
    ),
    "device_settings": MessageLookupByLibrary.simpleMessage("Device Settings"),
    "devices_registered": m5,
    "dialog_delete_all_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Delete All Prescriptions",
    ),
    "dialog_delete_all_prescriptions_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete ALL prescriptions? This action cannot be undone.",
    ),
    "dialog_delete_completed_prescriptions":
        MessageLookupByLibrary.simpleMessage("Delete Completed Prescriptions"),
    "dialog_delete_completed_prescriptions_confirm":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to delete all completed prescriptions?",
        ),
    "dialog_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Delete Prescription",
    ),
    "dialog_delete_prescription_confirm": m6,
    "dim": MessageLookupByLibrary.simpleMessage("Dim"),
    "dismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
    "done": MessageLookupByLibrary.simpleMessage("DONE"),
    "dry": MessageLookupByLibrary.simpleMessage("Dry"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "edit_settings": MessageLookupByLibrary.simpleMessage("Edit Settings"),
    "eighth_leaf_stage": m7,
    "emergence_stage": m8,
    "empty_no_prescriptions": MessageLookupByLibrary.simpleMessage(
      "No prescriptions found",
    ),
    "empty_no_prescriptions_filter": m9,
    "enable": MessageLookupByLibrary.simpleMessage("Enable"),
    "enableNotifications": MessageLookupByLibrary.simpleMessage(
      "Enable Notifications",
    ),
    "enable_notifications": MessageLookupByLibrary.simpleMessage(
      "Enable Notifications",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enter_6_digit_code": MessageLookupByLibrary.simpleMessage(
      "Ilagay ang 6-digit code",
    ),
    "enter_barangay": MessageLookupByLibrary.simpleMessage("Enter Barangay"),
    "enter_username": MessageLookupByLibrary.simpleMessage(
      "Ilagay ang inyong username",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "error_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Error deleting prescription",
    ),
    "error_delete_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Error deleting prescriptions",
    ),
    "error_deleting_prescription": MessageLookupByLibrary.simpleMessage(
      "Error deleting prescription",
    ),
    "error_invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Wrong username or password. Please check your credentials and try again.",
    ),
    "error_load_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Failed to load prescriptions",
    ),
    "error_loading_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Error loading prescriptions",
    ),
    "error_loading_prototypes": m10,
    "error_marking_complete": MessageLookupByLibrary.simpleMessage(
      "Error marking prescription as complete",
    ),
    "error_marking_incomplete": MessageLookupByLibrary.simpleMessage(
      "Error marking prescription as incomplete",
    ),
    "error_no_internet": MessageLookupByLibrary.simpleMessage(
      "No internet connection. Please check your connection and try again.",
    ),
    "error_server": MessageLookupByLibrary.simpleMessage(
      "There was a problem with the server. Please try again later.",
    ),
    "error_timeout": MessageLookupByLibrary.simpleMessage(
      "The server is taking too long to respond. Please try again later.",
    ),
    "error_unknown": MessageLookupByLibrary.simpleMessage(
      "An unexpected error occurred. Please try again.",
    ),
    "error_unsyncing_prototype": m11,
    "error_update_prescription": MessageLookupByLibrary.simpleMessage(
      "Error updating prescription",
    ),
    "estimated_duration": MessageLookupByLibrary.simpleMessage(
      "Estimated Duration",
    ),
    "estimated_growth_stage": MessageLookupByLibrary.simpleMessage(
      "Estimated Growth Stage",
    ),
    "excellent": MessageLookupByLibrary.simpleMessage("Excellent"),
    "exit_app_message": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the application?",
    ),
    "exit_app_title": MessageLookupByLibrary.simpleMessage("Exit Application"),
    "failed_to_load_prototypes": MessageLookupByLibrary.simpleMessage(
      "Hindi ma-load ang mga prototype",
    ),
    "failed_to_load_sensor_status": MessageLookupByLibrary.simpleMessage(
      "Hindi ma-load ang sensor status",
    ),
    "failed_to_unsync_prototype": MessageLookupByLibrary.simpleMessage(
      "Failed to unsync prototype",
    ),
    "failed_to_update_profile": m12,
    "fair": MessageLookupByLibrary.simpleMessage("Fair"),
    "faqA1": MessageLookupByLibrary.simpleMessage(
      "Go to settings and toggle the switch.",
    ),
    "faqA2": MessageLookupByLibrary.simpleMessage(
      "Click \'Forgot Password\' on the login screen.",
    ),
    "faqQ1": MessageLookupByLibrary.simpleMessage(
      "How do I enable notifications?",
    ),
    "faqQ2": MessageLookupByLibrary.simpleMessage("How to reset my password?"),
    "faqTitle": MessageLookupByLibrary.simpleMessage("FAQs"),
    "faq_a1": MessageLookupByLibrary.simpleMessage(
      "Green indicates the sensor is working properly, while red means there may be an issue.",
    ),
    "faq_a2": MessageLookupByLibrary.simpleMessage(
      "Sensor data is updated every 5 seconds automatically.",
    ),
    "faq_add_sensor_answer": MessageLookupByLibrary.simpleMessage(
      "Pumunta sa Farm Management section at i-tap ang \"Add Sensor\". Sundin ang setup instructions para ma-connect ang sensor sa app.",
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
      "What do the sensor indicators mean?",
    ),
    "faq_q2": MessageLookupByLibrary.simpleMessage(
      "How often does the app update sensor data?",
    ),
    "faq_sensor_disconnected_answer": MessageLookupByLibrary.simpleMessage(
      "I-check ang internet connection at siguraduhing naka-power on ang sensor. Subukan i-restart ang sensor at i-refresh ang app.",
    ),
    "faq_sensor_disconnected_question": MessageLookupByLibrary.simpleMessage(
      "Bakit naka-disconnect ang sensor ko?",
    ),
    "faq_title": MessageLookupByLibrary.simpleMessage("FAQs"),
    "farm_alert": MessageLookupByLibrary.simpleMessage("Farm Alert"),
    "farm_alerts": MessageLookupByLibrary.simpleMessage("Farm Alerts"),
    "farm_alerts_description": MessageLookupByLibrary.simpleMessage(
      "Weather warnings, irrigation alerts, and crop health updates",
    ),
    "farm_prescription": MessageLookupByLibrary.simpleMessage(
      "Farm Prescription",
    ),
    "farm_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Farm Prescriptions",
    ),
    "farm_registration_successful": MessageLookupByLibrary.simpleMessage(
      "Farm Registration Successful!",
    ),
    "farm_task": MessageLookupByLibrary.simpleMessage("Farm Task"),
    "farm_task_requires_attention": MessageLookupByLibrary.simpleMessage(
      "Farm task requires attention",
    ),
    "feb": MessageLookupByLibrary.simpleMessage("Feb"),
    "february": MessageLookupByLibrary.simpleMessage("Feb"),
    "fertilization": MessageLookupByLibrary.simpleMessage("Fertilization"),
    "field": MessageLookupByLibrary.simpleMessage("Field"),
    "field_colon": MessageLookupByLibrary.simpleMessage("Field:"),
    "field_information": MessageLookupByLibrary.simpleMessage(
      "Field Information",
    ),
    "field_name": MessageLookupByLibrary.simpleMessage("Field Name"),
    "field_name_hint": MessageLookupByLibrary.simpleMessage(
      "Field A, North Field, Main Plot",
    ),
    "field_name_label": MessageLookupByLibrary.simpleMessage("Field Name"),
    "field_name_required": MessageLookupByLibrary.simpleMessage(
      "Field name is required",
    ),
    "filter_done": MessageLookupByLibrary.simpleMessage("Done"),
    "filter_newest": MessageLookupByLibrary.simpleMessage("Newest First"),
    "filter_not_done": MessageLookupByLibrary.simpleMessage("Not Yet Done"),
    "filter_oldest": MessageLookupByLibrary.simpleMessage("Oldest First"),
    "filter_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Filter Prescriptions",
    ),
    "filter_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "filtered_by": m13,
    "first_name": MessageLookupByLibrary.simpleMessage("First Name"),
    "first_name_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "First name cannot have consecutive special characters",
    ),
    "first_name_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "First name can only contain letters, spaces, hyphens, apostrophes, and periods",
    ),
    "first_name_invalid_format": MessageLookupByLibrary.simpleMessage(
      "First name cannot start or end with special characters",
    ),
    "first_name_required": MessageLookupByLibrary.simpleMessage(
      "First name is required",
    ),
    "first_name_too_long": MessageLookupByLibrary.simpleMessage(
      "First name must not exceed 50 characters",
    ),
    "first_name_too_short": MessageLookupByLibrary.simpleMessage(
      "First name must be at least 2 characters long",
    ),
    "follow_recommended_actions": MessageLookupByLibrary.simpleMessage(
      "Follow recommended actions",
    ),
    "forgot_password": MessageLookupByLibrary.simpleMessage("Forgot Password?"),
    "frequently_asked_questions": MessageLookupByLibrary.simpleMessage(
      "Mga Madalas na Tanong",
    ),
    "friday": MessageLookupByLibrary.simpleMessage("Friday"),
    "from": MessageLookupByLibrary.simpleMessage("From"),
    "fully_developed_corn": MessageLookupByLibrary.simpleMessage(
      "Fully developed corn",
    ),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "get_help_and_find_answers": MessageLookupByLibrary.simpleMessage(
      "Kumuha ng tulong at makahanap ng mga sagot sa mga karaniwang tanong",
    ),
    "get_in_touch_with_support_team": MessageLookupByLibrary.simpleMessage(
      "Makipag-ugnayan sa aming support team",
    ),
    "get_real_time_analytics": MessageLookupByLibrary.simpleMessage(
      "Get real-time analytics and insights",
    ),
    "give_field_unique_name": MessageLookupByLibrary.simpleMessage(
      "Give your field a unique name to help you identify it in your farm",
    ),
    "go_to_settings": MessageLookupByLibrary.simpleMessage("Go to Settings"),
    "good": MessageLookupByLibrary.simpleMessage("Good"),
    "greeting_afternoon": MessageLookupByLibrary.simpleMessage(
      "Good Afternoon",
    ),
    "greeting_evening": MessageLookupByLibrary.simpleMessage("Good Evening"),
    "greeting_morning": MessageLookupByLibrary.simpleMessage("Good Morning"),
    "growth_stage": MessageLookupByLibrary.simpleMessage("Growth Stage"),
    "growth_stage_calculated": MessageLookupByLibrary.simpleMessage(
      "The growth stage is automatically calculated based on your planting date to provide accurate monitoring.",
    ),
    "growth_stage_early_vegetative": MessageLookupByLibrary.simpleMessage(
      "Early Vegetative",
    ),
    "growth_stage_emergence": MessageLookupByLibrary.simpleMessage("Emergence"),
    "growth_stage_maturing": MessageLookupByLibrary.simpleMessage("Maturing"),
    "growth_stage_maturity_harvest": MessageLookupByLibrary.simpleMessage(
      "Maturity/Harvest",
    ),
    "growth_stage_mid_vegetative": MessageLookupByLibrary.simpleMessage(
      "Mid Vegetative",
    ),
    "growth_stage_r1": MessageLookupByLibrary.simpleMessage("Silking"),
    "growth_stage_r1_desc": MessageLookupByLibrary.simpleMessage(
      "Silks emerging from ears",
    ),
    "growth_stage_r6": MessageLookupByLibrary.simpleMessage("Mature"),
    "growth_stage_r6_desc": MessageLookupByLibrary.simpleMessage(
      "Fully developed corn",
    ),
    "growth_stage_reproductive": MessageLookupByLibrary.simpleMessage(
      "Reproductive",
    ),
    "growth_stage_required": MessageLookupByLibrary.simpleMessage(
      "Growth stage is required",
    ),
    "growth_stage_v3": MessageLookupByLibrary.simpleMessage("Early Growth"),
    "growth_stage_v3_desc": MessageLookupByLibrary.simpleMessage(
      "3-5 leaves developed",
    ),
    "growth_stage_v8": MessageLookupByLibrary.simpleMessage("Mid Growth"),
    "growth_stage_v8_desc": MessageLookupByLibrary.simpleMessage(
      "8-10 leaves, growing taller",
    ),
    "growth_stage_ve": MessageLookupByLibrary.simpleMessage("Emergence"),
    "growth_stage_ve_desc": MessageLookupByLibrary.simpleMessage(
      "Just sprouting from soil",
    ),
    "growth_stage_vt": MessageLookupByLibrary.simpleMessage("Tasseling"),
    "growth_stage_vt_desc": MessageLookupByLibrary.simpleMessage(
      "Tassels appearing at top",
    ),
    "growth_timeline": MessageLookupByLibrary.simpleMessage("Growth Timeline"),
    "harvest": MessageLookupByLibrary.simpleMessage("Harvest"),
    "healthy_growth": MessageLookupByLibrary.simpleMessage(
      "Healthy growth rate",
    ),
    "helpDescription": MessageLookupByLibrary.simpleMessage(
      "Here\'s some helpful info.",
    ),
    "helpTitle": MessageLookupByLibrary.simpleMessage("Help"),
    "help_content_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Help content coming soon!",
    ),
    "help_description": MessageLookupByLibrary.simpleMessage(
      "This section provides information to help users understand the app features and usage. Learn how to monitor your plants, configure settings, and interpret sensor data.",
    ),
    "help_faq": MessageLookupByLibrary.simpleMessage("Tulong at FAQ"),
    "help_title": MessageLookupByLibrary.simpleMessage("Help"),
    "high": MessageLookupByLibrary.simpleMessage("High"),
    "high_priority": MessageLookupByLibrary.simpleMessage("High Priority"),
    "hours_ago": MessageLookupByLibrary.simpleMessage("hours ago"),
    "hours_left": m14,
    "humidity": MessageLookupByLibrary.simpleMessage("Halumigmig"),
    "humidity_moderate": MessageLookupByLibrary.simpleMessage(
      "The air has moderate humidity, comfortable for plant transpiration.",
    ),
    "humidity_quite_humid": MessageLookupByLibrary.simpleMessage(
      "The air is quite humid, often associated with moist environments.",
    ),
    "humidity_sensor": MessageLookupByLibrary.simpleMessage("Humidity Sensor"),
    "humidity_title": MessageLookupByLibrary.simpleMessage("Humidity"),
    "humidity_very_dry": MessageLookupByLibrary.simpleMessage(
      "The air is very dry, typical of arid environments.",
    ),
    "humidity_very_humid": MessageLookupByLibrary.simpleMessage(
      "The air is very humid, common before rainfall or in tropical climates.",
    ),
    "immediate": MessageLookupByLibrary.simpleMessage("Immediate"),
    "in_progress": MessageLookupByLibrary.simpleMessage("In Progress"),
    "inactive": MessageLookupByLibrary.simpleMessage("Hindi Aktibo"),
    "inactive_sensor_is_offline_or_not_sending_data":
        MessageLookupByLibrary.simpleMessage(
          "Hindi Aktibo: Ang sensor ay offline o hindi nagpapadala ng data",
        ),
    "instructions": MessageLookupByLibrary.simpleMessage("Instructions"),
    "invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Invalid username or password",
    ),
    "invalid_prototype_id": MessageLookupByLibrary.simpleMessage(
      "Invalid prototype ID",
    ),
    "invalid_verification_code_format": MessageLookupByLibrary.simpleMessage(
      "Hindi wastong format ng verification code",
    ),
    "irrigation": MessageLookupByLibrary.simpleMessage("Irrigation"),
    "jan": MessageLookupByLibrary.simpleMessage("Jan"),
    "january": MessageLookupByLibrary.simpleMessage("Jan"),
    "jul": MessageLookupByLibrary.simpleMessage("Jul"),
    "july": MessageLookupByLibrary.simpleMessage("Jul"),
    "jun": MessageLookupByLibrary.simpleMessage("Jun"),
    "june": MessageLookupByLibrary.simpleMessage("Jun"),
    "just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "just_sprouting_from_soil": MessageLookupByLibrary.simpleMessage(
      "Just sprouting from soil",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "language_changed_to": m15,
    "language_settings": MessageLookupByLibrary.simpleMessage(
      "Language Settings",
    ),
    "last_month": MessageLookupByLibrary.simpleMessage("Last month"),
    "last_name": MessageLookupByLibrary.simpleMessage("Last Name"),
    "last_name_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Last name cannot have consecutive special characters",
    ),
    "last_name_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Last name can only contain letters, spaces, hyphens, apostrophes, and periods",
    ),
    "last_name_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Last name cannot start or end with special characters",
    ),
    "last_name_required": MessageLookupByLibrary.simpleMessage(
      "Last name is required",
    ),
    "last_name_too_long": MessageLookupByLibrary.simpleMessage(
      "Last name must not exceed 50 characters",
    ),
    "last_name_too_short": MessageLookupByLibrary.simpleMessage(
      "Last name must be at least 2 characters long",
    ),
    "last_updated": MessageLookupByLibrary.simpleMessage("Last updated"),
    "last_week": MessageLookupByLibrary.simpleMessage("Last week"),
    "ldrSensor": MessageLookupByLibrary.simpleMessage("LDR Sensor"),
    "ldr_sensor": MessageLookupByLibrary.simpleMessage(
      "Light Dependent Resistor",
    ),
    "learn_how_to_use_maize_watch": MessageLookupByLibrary.simpleMessage(
      "Learn how to use the Maize Watch app",
    ),
    "learn_more_about_maize_watch": MessageLookupByLibrary.simpleMessage(
      "Learn more about Maize Watch",
    ),
    "leaves_3_5_developed": MessageLookupByLibrary.simpleMessage(
      "3-5 leaves developed",
    ),
    "leaves_8_10_developed": MessageLookupByLibrary.simpleMessage(
      "8-10 leaves, growing taller",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Liwanag"),
    "light_intensity": MessageLookupByLibrary.simpleMessage("Light Intensity"),
    "light_intensity_bright": MessageLookupByLibrary.simpleMessage(
      "The light intensity is bright, close to clear daytime conditions.",
    ),
    "light_intensity_moderate": MessageLookupByLibrary.simpleMessage(
      "The light intensity is moderate, similar to cloudy daylight.",
    ),
    "light_intensity_sensor": MessageLookupByLibrary.simpleMessage(
      "Light Intensity Sensor",
    ),
    "light_intensity_title": MessageLookupByLibrary.simpleMessage(
      "Light Intensity",
    ),
    "light_intensity_very_low": MessageLookupByLibrary.simpleMessage(
      "The light intensity is very low, resembling evening or dense shade.",
    ),
    "light_intensity_very_strong": MessageLookupByLibrary.simpleMessage(
      "The light intensity is very strong, similar to direct midday sunlight.",
    ),
    "live": MessageLookupByLibrary.simpleMessage("ONLINE"),
    "loading_farm_tasks": MessageLookupByLibrary.simpleMessage(
      "Loading farm tasks...",
    ),
    "loading_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Loading prescriptions...",
    ),
    "location": MessageLookupByLibrary.simpleMessage("Location"),
    "location_default": MessageLookupByLibrary.simpleMessage(
      "Default: Amadeo, Cavite",
    ),
    "location_label": MessageLookupByLibrary.simpleMessage("Location"),
    "location_not_specified": MessageLookupByLibrary.simpleMessage(
      "Location not specified",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Log In"),
    "login_error": MessageLookupByLibrary.simpleMessage("Login Error"),
    "login_failed": MessageLookupByLibrary.simpleMessage(
      "Login failed. Please log in manually.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "logout_error": MessageLookupByLibrary.simpleMessage(
      "There was a problem logging out. Please try again.",
    ),
    "logout_message": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout from your account?",
    ),
    "logout_title": MessageLookupByLibrary.simpleMessage("Logout Confirmation"),
    "low": MessageLookupByLibrary.simpleMessage("Low"),
    "low_light": MessageLookupByLibrary.simpleMessage("Low Light"),
    "low_priority": MessageLookupByLibrary.simpleMessage("Low Priority"),
    "maize_watch_notifications": MessageLookupByLibrary.simpleMessage(
      "Maize Watch Notifications",
    ),
    "manage_and_unsync_prototypes": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan at i-unsync ang mga prototype sa mga field",
    ),
    "manage_your_app_preferences": MessageLookupByLibrary.simpleMessage(
      "Pamahalaan ang mga kagustuhan ng app",
    ),
    "mar": MessageLookupByLibrary.simpleMessage("Mar"),
    "march": MessageLookupByLibrary.simpleMessage("Mar"),
    "mark_as_complete": MessageLookupByLibrary.simpleMessage(
      "Mark as Complete",
    ),
    "mark_complete": MessageLookupByLibrary.simpleMessage("Mark Complete"),
    "marked_as_completed": MessageLookupByLibrary.simpleMessage(
      "Marked as completed!",
    ),
    "marked_as_pending": MessageLookupByLibrary.simpleMessage(
      "Marked as pending",
    ),
    "materials_needed": MessageLookupByLibrary.simpleMessage(
      "Materials Needed",
    ),
    "maturity_stage": m16,
    "may": MessageLookupByLibrary.simpleMessage("May"),
    "medium": MessageLookupByLibrary.simpleMessage("Medium"),
    "medium_priority": MessageLookupByLibrary.simpleMessage("Medium Priority"),
    "menu": MessageLookupByLibrary.simpleMessage("Menu"),
    "minutes_ago": MessageLookupByLibrary.simpleMessage("minutes ago"),
    "moist": MessageLookupByLibrary.simpleMessage("Moist"),
    "moisture_fairly_moist": MessageLookupByLibrary.simpleMessage(
      "The soil is fairly moist. Monitor for potential overwatering.",
    ),
    "moisture_low": MessageLookupByLibrary.simpleMessage(
      "The soil moisture is low. Consider watering soon to maintain healthy growth.",
    ),
    "moisture_optimal": MessageLookupByLibrary.simpleMessage(
      "The soil moisture is at an optimal level. Plants are in good condition.",
    ),
    "moisture_too_dry": MessageLookupByLibrary.simpleMessage(
      "The soil is too dry. Irrigation is highly recommended to prevent plant stress.",
    ),
    "moisture_too_wet": MessageLookupByLibrary.simpleMessage(
      "The soil is too wet. Risk of root rot and fungal diseases is high.",
    ),
    "monday": MessageLookupByLibrary.simpleMessage("Monday"),
    "monitor_crop_health": MessageLookupByLibrary.simpleMessage(
      "Monitor your crop health with IoT sensors",
    ),
    "monitor_sensor_condition": MessageLookupByLibrary.simpleMessage(
      "Subaybayan ang kalagayan ng inyong mga sensor",
    ),
    "multiple_fields_info": MessageLookupByLibrary.simpleMessage(
      "You can have multiple fields in your farm. Each field can have different soil types, planting dates, and sensors.",
    ),
    "municipality": MessageLookupByLibrary.simpleMessage("Municipality"),
    "municipality_amadeo": MessageLookupByLibrary.simpleMessage("Amadeo"),
    "municipality_required": MessageLookupByLibrary.simpleMessage(
      "Municipality is required",
    ),
    "my_farm": MessageLookupByLibrary.simpleMessage("My Farm"),
    "name_your_field": MessageLookupByLibrary.simpleMessage("Name Your Field"),
    "network_error": MessageLookupByLibrary.simpleMessage(
      "Network error. Please check your connection.",
    ),
    "new_farm_prescriptions": MessageLookupByLibrary.simpleMessage(
      "New Farm Prescriptions",
    ),
    "new_farm_tasks_message": m17,
    "new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "new_password_required": MessageLookupByLibrary.simpleMessage(
      "New password is required",
    ),
    "new_prescription_available": MessageLookupByLibrary.simpleMessage(
      "New prescription available",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "next_button": MessageLookupByLibrary.simpleMessage("Next"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "no_corn_fields": MessageLookupByLibrary.simpleMessage(
      "No corn fields found",
    ),
    "no_data": MessageLookupByLibrary.simpleMessage("No Data"),
    "no_details_available": MessageLookupByLibrary.simpleMessage(
      "No details available",
    ),
    "no_farm_tasks_available": MessageLookupByLibrary.simpleMessage(
      "No farm tasks available",
    ),
    "no_field": MessageLookupByLibrary.simpleMessage("No field"),
    "no_pending_tasks_found": MessageLookupByLibrary.simpleMessage(
      "No pending tasks found",
    ),
    "no_prescriptions_found": MessageLookupByLibrary.simpleMessage(
      "No prescriptions found",
    ),
    "no_prototypes_found": MessageLookupByLibrary.simpleMessage(
      "No prototypes found",
    ),
    "no_prototypes_registered": MessageLookupByLibrary.simpleMessage(
      "You haven\'t registered any prototypes yet.",
    ),
    "no_sensor_data_available": MessageLookupByLibrary.simpleMessage(
      "Walang available na sensor data",
    ),
    "no_urgent_tasks_found": MessageLookupByLibrary.simpleMessage(
      "No urgent tasks found",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "normal": MessageLookupByLibrary.simpleMessage("Normal"),
    "not_now": MessageLookupByLibrary.simpleMessage("Not Now"),
    "not_started": MessageLookupByLibrary.simpleMessage("Not Started"),
    "notification_badge": MessageLookupByLibrary.simpleMessage(
      "Notification Badge",
    ),
    "notification_description": MessageLookupByLibrary.simpleMessage(
      "Get alerts for farm updates, weather warnings, and sensor issues",
    ),
    "notification_permission_message": MessageLookupByLibrary.simpleMessage(
      "Maize Watch would like to send you notifications about:\n\n• New farm prescriptions\n• Sensor alerts\n• Important updates\n\nThis helps you stay informed about your farm\'s health.",
    ),
    "notification_permission_required": MessageLookupByLibrary.simpleMessage(
      "Notification permission is required to receive alerts",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "notification_settings_failed": m18,
    "notification_settings_updated": MessageLookupByLibrary.simpleMessage(
      "Notification settings updated successfully!",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Notification Sound",
    ),
    "notification_test_failed": MessageLookupByLibrary.simpleMessage(
      "Notification test failed",
    ),
    "notification_test_successful": MessageLookupByLibrary.simpleMessage(
      "Notification test successful!",
    ),
    "notification_types": MessageLookupByLibrary.simpleMessage(
      "Notification Types",
    ),
    "notification_vibration": MessageLookupByLibrary.simpleMessage(
      "Notification Vibration",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notifications_channel_description": MessageLookupByLibrary.simpleMessage(
      "Notifications for farm monitoring and alerts",
    ),
    "notifications_disabled_message": MessageLookupByLibrary.simpleMessage(
      "Notifications disabled. You can enable them in settings.",
    ),
    "notifications_enabled": m19,
    "notifications_enabled_disabled": m20,
    "notifications_enabled_message": MessageLookupByLibrary.simpleMessage(
      "Notifications enabled! You\'ll receive farm updates.",
    ),
    "notifications_for_farm_monitoring": MessageLookupByLibrary.simpleMessage(
      "Notifications for farm monitoring and alerts",
    ),
    "nov": MessageLookupByLibrary.simpleMessage("Nov"),
    "november": MessageLookupByLibrary.simpleMessage("Nov"),
    "now": MessageLookupByLibrary.simpleMessage("Now"),
    "null_value": MessageLookupByLibrary.simpleMessage("NULL"),
    "oct": MessageLookupByLibrary.simpleMessage("Oct"),
    "october": MessageLookupByLibrary.simpleMessage("Oct"),
    "off": MessageLookupByLibrary.simpleMessage("Off"),
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "offline_mode_cached_data": MessageLookupByLibrary.simpleMessage(
      "Offline Mode - Cached Data",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "okay": MessageLookupByLibrary.simpleMessage("Okay"),
    "on": MessageLookupByLibrary.simpleMessage("On"),
    "overcast": MessageLookupByLibrary.simpleMessage("Overcast"),
    "overdue": MessageLookupByLibrary.simpleMessage("Overdue"),
    "parameter_humidity": MessageLookupByLibrary.simpleMessage("Humidity"),
    "parameter_light_intensity": MessageLookupByLibrary.simpleMessage(
      "Light Intensity",
    ),
    "parameter_soil_moisture": MessageLookupByLibrary.simpleMessage(
      "Soil Moisture",
    ),
    "parameter_soil_ph": MessageLookupByLibrary.simpleMessage("Soil pH"),
    "parameter_temperature": MessageLookupByLibrary.simpleMessage(
      "Temperature",
    ),
    "partly_cloudy": MessageLookupByLibrary.simpleMessage("Partly Cloudy"),
    "partly_cloudy_description": MessageLookupByLibrary.simpleMessage(
      "Partly cloudy",
    ),
    "partly_cloudy_weather": MessageLookupByLibrary.simpleMessage(
      "Partly Cloudy",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "password_min_length": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "password_needs_lowercase": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one lowercase letter",
    ),
    "password_needs_number": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one number",
    ),
    "password_needs_special": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one special character (!@#\$%^&*)",
    ),
    "password_needs_uppercase": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one uppercase letter",
    ),
    "password_required": MessageLookupByLibrary.simpleMessage(
      "Password is required",
    ),
    "password_reset_successful": MessageLookupByLibrary.simpleMessage(
      "Password reset successfully!",
    ),
    "password_too_common": MessageLookupByLibrary.simpleMessage(
      "This password is too common. Please choose a stronger password",
    ),
    "password_too_long": MessageLookupByLibrary.simpleMessage(
      "Password must not exceed 128 characters",
    ),
    "password_too_short": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwords_do_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "passwords_dont_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "permission_required": MessageLookupByLibrary.simpleMessage(
      "Permission Required",
    ),
    "pest_control": MessageLookupByLibrary.simpleMessage("Pest Control"),
    "phSensor": MessageLookupByLibrary.simpleMessage("pH Level Sensor"),
    "ph_sensor": MessageLookupByLibrary.simpleMessage("PH Level of Soil"),
    "phone_number": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "phone_number_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid phone number",
    ),
    "phone_number_required": MessageLookupByLibrary.simpleMessage(
      "Phone number is required",
    ),
    "phone_verification_description": MessageLookupByLibrary.simpleMessage(
      "Please verify your phone number to complete your registration.",
    ),
    "phone_verification_required": MessageLookupByLibrary.simpleMessage(
      "Phone Verification Required",
    ),
    "planting_date": MessageLookupByLibrary.simpleMessage("Planting Date"),
    "planting_date_required": MessageLookupByLibrary.simpleMessage(
      "Planting date is required",
    ),
    "planting_season_description": MessageLookupByLibrary.simpleMessage(
      "Select the date you planted your corn",
    ),
    "planting_season_title": MessageLookupByLibrary.simpleMessage(
      "When did you plant?",
    ),
    "please_complete_device_info": MessageLookupByLibrary.simpleMessage(
      "Please complete all device information",
    ),
    "please_enter_field_name": MessageLookupByLibrary.simpleMessage(
      "Please enter a field name",
    ),
    "please_log_in_continue": MessageLookupByLibrary.simpleMessage(
      "Please log in to continue.",
    ),
    "please_register_device": MessageLookupByLibrary.simpleMessage(
      "Please register at least one device to continue",
    ),
    "please_select_planting_date": MessageLookupByLibrary.simpleMessage(
      "Please select a planting date",
    ),
    "please_try_again": MessageLookupByLibrary.simpleMessage(
      "Pakiusap subukan ulit",
    ),
    "please_validate_prototype_id": MessageLookupByLibrary.simpleMessage(
      "Please validate the prototype ID before submitting",
    ),
    "poor": MessageLookupByLibrary.simpleMessage("Poor"),
    "prescription_alert": MessageLookupByLibrary.simpleMessage(
      "Prescription Alert",
    ),
    "prescription_deleted_successfully": MessageLookupByLibrary.simpleMessage(
      "Prescription deleted successfully",
    ),
    "prescription_details": MessageLookupByLibrary.simpleMessage(
      "Prescription Details",
    ),
    "prescription_marked_complete": MessageLookupByLibrary.simpleMessage(
      "Prescription marked as complete",
    ),
    "prescription_marked_incomplete": MessageLookupByLibrary.simpleMessage(
      "Prescription marked as incomplete",
    ),
    "prescription_updates": MessageLookupByLibrary.simpleMessage(
      "Prescription Updates",
    ),
    "prescription_updates_description": MessageLookupByLibrary.simpleMessage(
      "New farm recommendations and treatment suggestions",
    ),
    "prescriptions_subtitle": MessageLookupByLibrary.simpleMessage(
      "Manage your prescriptions",
    ),
    "prescriptions_title": MessageLookupByLibrary.simpleMessage(
      "Prescriptions",
    ),
    "priority": MessageLookupByLibrary.simpleMessage("Priority"),
    "privacy_info_intro": MessageLookupByLibrary.simpleMessage(
      "At Maize Watch, we are committed to protecting the privacy of our users, particularly corn farmers who entrust us with their valuable agricultural data. This Privacy Information outlines how we collect, use, and protect your information when you use our platform.",
    ),
    "privacy_info_section1_content": MessageLookupByLibrary.simpleMessage(
      "To provide you with data-driven insights and optimize your corn yields, Maize Watch collects the following types of information:\n\nFarm-Specific Data: Location (GPS coordinates of fields), field size and boundaries, crop variety, planting/harvesting dates, and yield data.\nSensor Data: Soil moisture/nutrient levels, temperature (soil/ambient), humidity, light intensity, and other relevant environmental data.\nAccount Information: Your name, contact info, farm name/ID, and login credentials (encrypted).\nUsage Data: Features accessed, time spent, reports generated, and anonymized device info.",
    ),
    "privacy_info_section1_title": MessageLookupByLibrary.simpleMessage(
      "1. Information We Collect:",
    ),
    "privacy_info_section2_content": MessageLookupByLibrary.simpleMessage(
      "To Provide Core Services: Visualize farm performance, analyze conditions, offer recommendations, and track progress.\nTo Improve Maize Watch: Enhance features, develop new tools, and improve models (often using anonymized data).\nFor Communication: Send updates, alerts, and respond to inquiries.\nFor Security: Ensure platform integrity, prevent fraud, and comply with legal duties.",
    ),
    "privacy_info_section2_title": MessageLookupByLibrary.simpleMessage(
      "2. How We Use Your Information:",
    ),
    "privacy_info_section3_content": MessageLookupByLibrary.simpleMessage(
      "With Your Consent: Data is shared only with parties you approve (e.g., consultants).\nService Providers: Only trusted providers under strict agreements.\nAggregated/Anonymized Data: Used for research or benchmarking without revealing identities.\nLegal Requirements: Disclosed only when legally necessary.",
    ),
    "privacy_info_section3_title": MessageLookupByLibrary.simpleMessage(
      "3. Data Sharing and Disclosure:",
    ),
    "privacy_info_section4_content": MessageLookupByLibrary.simpleMessage(
      "Encryption (in transit & at rest)\nStrict access controls\nRegular security audits\nSecure data backups",
    ),
    "privacy_info_section4_title": MessageLookupByLibrary.simpleMessage(
      "4. Data Security:",
    ),
    "privacy_info_section5_content": MessageLookupByLibrary.simpleMessage(
      "Access, update, or correct your data anytime\nRequest a copy of your data (data portability)\nRequest data deletion (subject to legal retention)\nOpt-out of non-essential communications",
    ),
    "privacy_info_section5_title": MessageLookupByLibrary.simpleMessage(
      "5. Your Choices and Rights:",
    ),
    "privacy_info_section6_content": MessageLookupByLibrary.simpleMessage(
      "Your data is retained while your account is active and for a reasonable period afterward to comply with obligations and ensure continuity.",
    ),
    "privacy_info_section6_title": MessageLookupByLibrary.simpleMessage(
      "6. Data Retention:",
    ),
    "privacy_info_section7_content": MessageLookupByLibrary.simpleMessage(
      "Updates to this Privacy Information will be posted on our website or communicated appropriately. Please review it periodically.",
    ),
    "privacy_info_section7_title": MessageLookupByLibrary.simpleMessage(
      "7. Changes to This Privacy Information:",
    ),
    "privacy_info_title": MessageLookupByLibrary.simpleMessage(
      "Maize Watch Privacy Information",
    ),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "profile_update_in_progress": MessageLookupByLibrary.simpleMessage(
      "Profile update already in progress. Please wait.",
    ),
    "profile_updated_successfully": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully!",
    ),
    "prototype_id": m21,
    "prototype_id_not_found": MessageLookupByLibrary.simpleMessage(
      "Prototype ID not found",
    ),
    "prototype_unsynced": MessageLookupByLibrary.simpleMessage(
      "Prototype unsynced successfully",
    ),
    "province": MessageLookupByLibrary.simpleMessage("Province"),
    "province_cavite": MessageLookupByLibrary.simpleMessage("Cavite"),
    "province_required": MessageLookupByLibrary.simpleMessage(
      "Province is required",
    ),
    "quiet_hours": MessageLookupByLibrary.simpleMessage("Quiet Hours"),
    "r1_silking": MessageLookupByLibrary.simpleMessage("Silking (R1)"),
    "r6_mature": MessageLookupByLibrary.simpleMessage("Mature (R6)"),
    "rainfall": MessageLookupByLibrary.simpleMessage("Rainfall"),
    "rainy": MessageLookupByLibrary.simpleMessage("Rainy"),
    "rapid_growth": MessageLookupByLibrary.simpleMessage(
      "Rapid growth detected!",
    ),
    "receive_alerts_recommendations": MessageLookupByLibrary.simpleMessage(
      "Receive alerts and recommendations",
    ),
    "recommendation_apply_fertilizer": MessageLookupByLibrary.simpleMessage(
      "Apply fertilizer as recommended for optimal growth",
    ),
    "recommendation_light": MessageLookupByLibrary.simpleMessage(
      "Ensure proper light exposure for healthy growth",
    ),
    "recommendation_soil_ph": MessageLookupByLibrary.simpleMessage(
      "Adjust soil pH to recommended levels",
    ),
    "recommendation_temperature": MessageLookupByLibrary.simpleMessage(
      "Monitor and maintain optimal temperature conditions",
    ),
    "recommendation_title": MessageLookupByLibrary.simpleMessage(
      "Recommendations",
    ),
    "recommendation_water": MessageLookupByLibrary.simpleMessage(
      "Adjust irrigation schedule based on soil moisture levels",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "refresh_auth": MessageLookupByLibrary.simpleMessage("I-refresh ang Auth"),
    "refresh_farm_data": MessageLookupByLibrary.simpleMessage(
      "I-refresh ang Farm Data",
    ),
    "refresh_status": MessageLookupByLibrary.simpleMessage(
      "I-refresh ang Status",
    ),
    "region": MessageLookupByLibrary.simpleMessage("Region"),
    "region_calabarzon": MessageLookupByLibrary.simpleMessage(
      "CALABARZON (Region IV-A)",
    ),
    "region_required": MessageLookupByLibrary.simpleMessage(
      "Region is required",
    ),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "register_corn_button": MessageLookupByLibrary.simpleMessage(
      "Register Corn",
    ),
    "register_corn_field_prompt": MessageLookupByLibrary.simpleMessage(
      "Please register a corn field to start tracking progress.",
    ),
    "register_corn_next": MessageLookupByLibrary.simpleMessage(
      "Register your corn next",
    ),
    "register_monitoring_devices": MessageLookupByLibrary.simpleMessage(
      "Register monitoring devices for your field (At least one device required)",
    ),
    "register_page1_description": MessageLookupByLibrary.simpleMessage(
      "Create your account by providing your personal information below.",
    ),
    "register_page1_title": MessageLookupByLibrary.simpleMessage(
      "Let\'s get you started",
    ),
    "register_page2_description": MessageLookupByLibrary.simpleMessage(
      "Now let\'s set up your login credentials to secure your account.",
    ),
    "register_page2_title": MessageLookupByLibrary.simpleMessage("Hi, "),
    "registered_prototypes": MessageLookupByLibrary.simpleMessage(
      "Mga Nakarehistrong Prototype",
    ),
    "registration_failed": MessageLookupByLibrary.simpleMessage(
      "Registration failed. Please try again.",
    ),
    "registration_successful": MessageLookupByLibrary.simpleMessage(
      "Registration successful! Please input your corn information.",
    ),
    "registration_timeout": MessageLookupByLibrary.simpleMessage(
      "The server is taking too long to respond. Your account may have been created. Please try logging in.",
    ),
    "request_timed_out": MessageLookupByLibrary.simpleMessage(
      "Request timed out. Please check your connection and try again.",
    ),
    "resend_code": MessageLookupByLibrary.simpleMessage(
      "Ipadala ulit ang Code",
    ),
    "resend_in_seconds": m22,
    "resending": MessageLookupByLibrary.simpleMessage("Resending..."),
    "reset_password": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "review_and_submit": MessageLookupByLibrary.simpleMessage(
      "Review and Submit",
    ),
    "saturday": MessageLookupByLibrary.simpleMessage("Saturday"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
    "season_both": MessageLookupByLibrary.simpleMessage("Both Seasons"),
    "season_dry": MessageLookupByLibrary.simpleMessage(
      "Dry Season (December to May)",
    ),
    "season_wet": MessageLookupByLibrary.simpleMessage(
      "Wet Season (June to November)",
    ),
    "seconds_ago": MessageLookupByLibrary.simpleMessage("seconds ago"),
    "see_more": MessageLookupByLibrary.simpleMessage("See More"),
    "select_barangay": MessageLookupByLibrary.simpleMessage(
      "Select your barangay",
    ),
    "select_date": MessageLookupByLibrary.simpleMessage("Select Date"),
    "select_language": MessageLookupByLibrary.simpleMessage("Select Language"),
    "select_municipality": MessageLookupByLibrary.simpleMessage(
      "Select your municipality",
    ),
    "select_planting_date": MessageLookupByLibrary.simpleMessage(
      "Select planting date",
    ),
    "select_province": MessageLookupByLibrary.simpleMessage(
      "Select your province",
    ),
    "select_region": MessageLookupByLibrary.simpleMessage("Select your region"),
    "send_verification_code": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "sending": MessageLookupByLibrary.simpleMessage("Sending..."),
    "sensor_alert": MessageLookupByLibrary.simpleMessage("Sensor Alert"),
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
      "Sensor offline alert",
    ),
    "sensor_offline_description": m23,
    "sensor_offline_message": m24,
    "sensor_sleep_description": MessageLookupByLibrary.simpleMessage(
      "Your sensors are now sleeping from 8pm to 3am PH time. They will wake up at 3am.",
    ),
    "sensor_sleep_mode": MessageLookupByLibrary.simpleMessage(
      "Sensors in Sleep Mode",
    ),
    "sensor_sleep_mode_alert": MessageLookupByLibrary.simpleMessage(
      "Sensors in sleep mode",
    ),
    "sensor_status": MessageLookupByLibrary.simpleMessage(
      "Kalagayan ng Sensor",
    ),
    "sensor_status_description": MessageLookupByLibrary.simpleMessage(
      "Alerts when sensors go offline or need maintenance",
    ),
    "sensors": MessageLookupByLibrary.simpleMessage("Sensors"),
    "sensors_are_sleeping_from_8pm_to_3am_ph_time":
        MessageLookupByLibrary.simpleMessage(
          "Ang mga sensor ay natutulog mula 8pm hanggang 3am PH time",
        ),
    "sensors_in_sleep_mode": MessageLookupByLibrary.simpleMessage(
      "Sensors in Sleep Mode",
    ),
    "sensors_sleep_mode": MessageLookupByLibrary.simpleMessage(
      "Ang mga sensor ay nasa sleep mode (8pm-3am PH time)",
    ),
    "sensors_sleep_mode_message": MessageLookupByLibrary.simpleMessage(
      "Your sensors are now sleeping from 8pm to 3am PH time. They will wake up at 3am.",
    ),
    "sent": MessageLookupByLibrary.simpleMessage("Sent"),
    "sep": MessageLookupByLibrary.simpleMessage("Sep"),
    "september": MessageLookupByLibrary.simpleMessage("Sep"),
    "session_expired": MessageLookupByLibrary.simpleMessage(
      "Your session has expired. Please log in again.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Mga Setting"),
    "setup_farm_data_message": MessageLookupByLibrary.simpleMessage(
      "Now let\'s set up your farm data to start monitoring your corn crops.",
    ),
    "silking_stage": m25,
    "silks_emerging": MessageLookupByLibrary.simpleMessage(
      "Silks emerging from ears",
    ),
    "sleep_mode_active": MessageLookupByLibrary.simpleMessage(
      "Sleep Mode Active",
    ),
    "soilMoistureSensor": MessageLookupByLibrary.simpleMessage(
      "Soil Moisture Sensor",
    ),
    "soil_clay": MessageLookupByLibrary.simpleMessage("Clay"),
    "soil_clay_desc": MessageLookupByLibrary.simpleMessage(
      "Heavy, holds water",
    ),
    "soil_loam": MessageLookupByLibrary.simpleMessage("Loam"),
    "soil_loamy": MessageLookupByLibrary.simpleMessage("Loamy"),
    "soil_loamy_desc": MessageLookupByLibrary.simpleMessage(
      "Mix of sand, silt, clay",
    ),
    "soil_moisture": MessageLookupByLibrary.simpleMessage(
      "Kahalumigmigan ng Lupa",
    ),
    "soil_moisture_sensor": MessageLookupByLibrary.simpleMessage(
      "Soil Moisture Sensor",
    ),
    "soil_peaty": MessageLookupByLibrary.simpleMessage("Peaty"),
    "soil_ph_sensor": MessageLookupByLibrary.simpleMessage("Soil pH Sensor"),
    "soil_saline": MessageLookupByLibrary.simpleMessage("Saline"),
    "soil_sandy": MessageLookupByLibrary.simpleMessage("Sandy"),
    "soil_sandy_desc": MessageLookupByLibrary.simpleMessage(
      "Light, drains quickly",
    ),
    "soil_silt": MessageLookupByLibrary.simpleMessage("Silt"),
    "soil_silty": MessageLookupByLibrary.simpleMessage("Silty"),
    "soil_silty_desc": MessageLookupByLibrary.simpleMessage(
      "Smooth, holds moisture",
    ),
    "soil_type": MessageLookupByLibrary.simpleMessage("Soil Type"),
    "soil_type_required": MessageLookupByLibrary.simpleMessage(
      "Soil type is required",
    ),
    "soil_type_title": MessageLookupByLibrary.simpleMessage(
      "Choose your field\'s soil type",
    ),
    "soundAndVibrate": MessageLookupByLibrary.simpleMessage("Sound & Vibrate"),
    "sound_and_vibrate": MessageLookupByLibrary.simpleMessage(
      "Sound & Vibrate",
    ),
    "stable": MessageLookupByLibrary.simpleMessage("Growth is stable"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "status_all_completed_deleted": MessageLookupByLibrary.simpleMessage(
      "All completed prescriptions deleted",
    ),
    "status_all_deleted": MessageLookupByLibrary.simpleMessage(
      "All prescriptions deleted",
    ),
    "status_check": MessageLookupByLibrary.simpleMessage("Status Check"),
    "status_completed": MessageLookupByLibrary.simpleMessage("COMPLETED"),
    "status_legend": MessageLookupByLibrary.simpleMessage("Status Legend"),
    "status_prescription_completed": MessageLookupByLibrary.simpleMessage(
      "Prescription marked as completed",
    ),
    "status_prescription_deleted": MessageLookupByLibrary.simpleMessage(
      "Prescription deleted successfully",
    ),
    "status_prescription_pending": MessageLookupByLibrary.simpleMessage(
      "Prescription marked as pending",
    ),
    "stay_updated": MessageLookupByLibrary.simpleMessage(
      "Stay updated with your farm!",
    ),
    "step1_title": MessageLookupByLibrary.simpleMessage("Field"),
    "step2_title": MessageLookupByLibrary.simpleMessage("Soil"),
    "step3_title": MessageLookupByLibrary.simpleMessage("Corn"),
    "step4_title": MessageLookupByLibrary.simpleMessage("Season"),
    "step5_title": MessageLookupByLibrary.simpleMessage("Age"),
    "step_by_step_instructions": m26,
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "submit_button": MessageLookupByLibrary.simpleMessage("Submit"),
    "sunday": MessageLookupByLibrary.simpleMessage("Sunday"),
    "sunny": MessageLookupByLibrary.simpleMessage("Sunny"),
    "support": MessageLookupByLibrary.simpleMessage("Suporta"),
    "tap_to_view": MessageLookupByLibrary.simpleMessage("Tap to view"),
    "tasseling_stage": m27,
    "tassels_appearing": MessageLookupByLibrary.simpleMessage(
      "Tassels appearing at top",
    ),
    "tempHumidSensor": MessageLookupByLibrary.simpleMessage(
      "Temperature & Humidity Sensor",
    ),
    "temp_humid_sensor": MessageLookupByLibrary.simpleMessage(
      "Temperature and Humidity",
    ),
    "temperature": MessageLookupByLibrary.simpleMessage("Temperatura"),
    "temperature_sensor": MessageLookupByLibrary.simpleMessage(
      "Temperature Sensor",
    ),
    "terms_intro": MessageLookupByLibrary.simpleMessage(
      "Welcome to Maize Watch. By accessing or using our platform, services, and related tools, you agree to comply with and be bound by these Terms of Use. If you do not agree with any part of these terms, please do not use Maize Watch.",
    ),
    "terms_of_service": MessageLookupByLibrary.simpleMessage(
      "Terms of Service",
    ),
    "terms_of_use": MessageLookupByLibrary.simpleMessage("Terms of Use"),
    "terms_section1_content": MessageLookupByLibrary.simpleMessage(
      "You may only use Maize Watch for lawful purposes and in accordance with these terms.\nYou are responsible for maintaining the confidentiality of your account credentials and all activities under your account.\nYou agree not to misuse the platform, interfere with its security or functionality, or attempt unauthorized access to any part of the system.",
    ),
    "terms_section1_title": MessageLookupByLibrary.simpleMessage(
      "1. Use of the Platform:",
    ),
    "terms_section2_content": MessageLookupByLibrary.simpleMessage(
      "You retain full ownership of your farm data and sensor information.\nBy using Maize Watch, you grant us permission to analyze your data to provide personalized insights and improve platform performance.\nWe will not share your identifiable data without your explicit consent, as outlined in our Privacy Policy.",
    ),
    "terms_section2_title": MessageLookupByLibrary.simpleMessage(
      "2. Data Ownership and Usage:",
    ),
    "terms_section3_content": MessageLookupByLibrary.simpleMessage(
      "All content on Maize Watch, including visualizations, software, text, graphics, and logos, is the property of Maize Watch or its licensors.\nYou may not reproduce, distribute, modify, or create derivative works without our written permission.",
    ),
    "terms_section3_title": MessageLookupByLibrary.simpleMessage(
      "3. Intellectual Property:",
    ),
    "terms_section4_content": MessageLookupByLibrary.simpleMessage(
      "We reserve the right to suspend or terminate your access to Maize Watch at any time if you violate these terms, abuse the platform, or engage in any behavior that disrupts service for other users.",
    ),
    "terms_section4_title": MessageLookupByLibrary.simpleMessage(
      "4. Account Termination:",
    ),
    "terms_section5_content": MessageLookupByLibrary.simpleMessage(
      "Maize Watch provides data-based insights to support agricultural decisions. Final decisions regarding farming practices remain your responsibility.\nWe do not guarantee specific yield outcomes or profitability as agricultural success depends on many uncontrollable factors.\nThe platform is provided “as-is” and “as available” without warranties of any kind.",
    ),
    "terms_section5_title": MessageLookupByLibrary.simpleMessage(
      "5. Disclaimers:",
    ),
    "terms_section6_content": MessageLookupByLibrary.simpleMessage(
      "To the extent permitted by law, Maize Watch shall not be liable for any indirect, incidental, or consequential damages arising from your use of the platform, including data loss, yield loss, or farm-related decisions made based on our analytics.",
    ),
    "terms_section6_title": MessageLookupByLibrary.simpleMessage(
      "6. Limitation of Liability:",
    ),
    "terms_section7_content": MessageLookupByLibrary.simpleMessage(
      "We may update these Terms of Use from time to time. Material changes will be communicated through our platform or via email. Continued use of Maize Watch means you accept the updated terms.",
    ),
    "terms_section7_title": MessageLookupByLibrary.simpleMessage(
      "7. Updates to the Terms:",
    ),
    "test_notification": MessageLookupByLibrary.simpleMessage(
      "Test Notification",
    ),
    "textSizeLabel": MessageLookupByLibrary.simpleMessage("Text Size"),
    "third_leaf_stage": m28,
    "this_month": MessageLookupByLibrary.simpleMessage("This month"),
    "this_week": MessageLookupByLibrary.simpleMessage("This week"),
    "thursday": MessageLookupByLibrary.simpleMessage("Thursday"),
    "timeline": MessageLookupByLibrary.simpleMessage("Timeline"),
    "timeline_filter": m29,
    "timeline_next_week": MessageLookupByLibrary.simpleMessage("Next Week"),
    "timeline_this_week": MessageLookupByLibrary.simpleMessage("This Week"),
    "timeline_today": MessageLookupByLibrary.simpleMessage("Today"),
    "to": MessageLookupByLibrary.simpleMessage("To"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "tooltip_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Delete prescription",
    ),
    "tooltip_refresh_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Refresh prescriptions",
    ),
    "translate": MessageLookupByLibrary.simpleMessage("Translate"),
    "try_again": MessageLookupByLibrary.simpleMessage("Try Again"),
    "tuesday": MessageLookupByLibrary.simpleMessage("Tuesday"),
    "unable_to_update_prescription_status":
        MessageLookupByLibrary.simpleMessage(
          "Unable to update prescription status",
        ),
    "undo_complete": MessageLookupByLibrary.simpleMessage("Undo Complete"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknown_field": MessageLookupByLibrary.simpleMessage(
      "Hindi Kilalang Field",
    ),
    "unknown_sensor": MessageLookupByLibrary.simpleMessage("Unknown Sensor"),
    "unsync_prototype": MessageLookupByLibrary.simpleMessage(
      "Unsync Prototype",
    ),
    "unsync_prototype_confirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to unsync this prototype from the field? This action cannot be undone.",
    ),
    "urgency": MessageLookupByLibrary.simpleMessage("Urgency"),
    "urgency_filter": m30,
    "urgency_high": MessageLookupByLibrary.simpleMessage("HIGH"),
    "urgency_low": MessageLookupByLibrary.simpleMessage("LOW"),
    "urgency_medium": MessageLookupByLibrary.simpleMessage("MEDIUM"),
    "urgency_urgent": MessageLookupByLibrary.simpleMessage("URGENT"),
    "urgent": MessageLookupByLibrary.simpleMessage("Urgent"),
    "user_id_not_found": MessageLookupByLibrary.simpleMessage(
      "User ID not found",
    ),
    "user_not_authenticated": MessageLookupByLibrary.simpleMessage(
      "User not authenticated",
    ),
    "user_registration_successful": MessageLookupByLibrary.simpleMessage(
      "User Registration Successful!",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "username_already_exists": MessageLookupByLibrary.simpleMessage(
      "Username already exists. Please try another one.",
    ),
    "username_consecutive_special": MessageLookupByLibrary.simpleMessage(
      "Username cannot have consecutive periods or underscores",
    ),
    "username_invalid_characters": MessageLookupByLibrary.simpleMessage(
      "Username can only contain letters, numbers, underscores, and periods",
    ),
    "username_invalid_end": MessageLookupByLibrary.simpleMessage(
      "Username must end with a letter or number",
    ),
    "username_invalid_start": MessageLookupByLibrary.simpleMessage(
      "Username must start with a letter or number",
    ),
    "username_must_be_at_least_3_characters":
        MessageLookupByLibrary.simpleMessage(
          "Ang username ay dapat hindi bababa sa 3 na character",
        ),
    "username_required": MessageLookupByLibrary.simpleMessage(
      "Username is required",
    ),
    "username_too_long": MessageLookupByLibrary.simpleMessage(
      "Username must not exceed 20 characters",
    ),
    "username_too_short": MessageLookupByLibrary.simpleMessage(
      "Username must be at least 3 characters",
    ),
    "v3_early_growth": MessageLookupByLibrary.simpleMessage(
      "Early Growth (V3)",
    ),
    "v8_mid_growth": MessageLookupByLibrary.simpleMessage("Mid Growth (V8)"),
    "valid_ph_number_required": MessageLookupByLibrary.simpleMessage(
      "Enter a valid Philippine mobile number",
    ),
    "variety_field_corn": MessageLookupByLibrary.simpleMessage("Field Corn"),
    "variety_field_corn_desc": MessageLookupByLibrary.simpleMessage(
      "For animal feed, ethanol",
    ),
    "variety_flint": MessageLookupByLibrary.simpleMessage("Flint"),
    "variety_flint_corn": MessageLookupByLibrary.simpleMessage("Flint Corn"),
    "variety_flint_corn_desc": MessageLookupByLibrary.simpleMessage(
      "Colorful, decorative",
    ),
    "variety_glutinous": MessageLookupByLibrary.simpleMessage(
      "Glutinous (Malagkit)",
    ),
    "variety_popcorn": MessageLookupByLibrary.simpleMessage("Popcorn"),
    "variety_popcorn_desc": MessageLookupByLibrary.simpleMessage("For popping"),
    "variety_purple": MessageLookupByLibrary.simpleMessage("Purple"),
    "variety_sweet": MessageLookupByLibrary.simpleMessage("Sweet"),
    "variety_sweet_corn": MessageLookupByLibrary.simpleMessage("Sweet Corn"),
    "variety_sweet_corn_desc": MessageLookupByLibrary.simpleMessage(
      "For human consumption",
    ),
    "variety_white_fodder": MessageLookupByLibrary.simpleMessage(
      "White Fodder",
    ),
    "variety_yellow_dent": MessageLookupByLibrary.simpleMessage("Yellow Dent"),
    "ve_emergence": MessageLookupByLibrary.simpleMessage("Emergence (VE)"),
    "ve_stage": MessageLookupByLibrary.simpleMessage("VE"),
    "verification_code": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "verification_code_description": m31,
    "verification_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid 6-digit code",
    ),
    "verification_code_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Verification code must contain only numbers",
    ),
    "verification_code_invalid_length": MessageLookupByLibrary.simpleMessage(
      "Verification code must be 6 digits",
    ),
    "verification_code_required": MessageLookupByLibrary.simpleMessage(
      "Verification code is required",
    ),
    "verification_code_resent": MessageLookupByLibrary.simpleMessage(
      "Verification code resent successfully",
    ),
    "verification_code_sent": MessageLookupByLibrary.simpleMessage(
      "Verification Code Sent",
    ),
    "verification_failed": MessageLookupByLibrary.simpleMessage(
      "Verification Failed",
    ),
    "verification_help_text": MessageLookupByLibrary.simpleMessage(
      "Didn\'t receive the code? Check your SMS messages or try resending.",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "verify_phone_number": MessageLookupByLibrary.simpleMessage(
      "Verify Phone Number",
    ),
    "verifying": MessageLookupByLibrary.simpleMessage("Verifying..."),
    "versionInfo": MessageLookupByLibrary.simpleMessage("version 1.0.0"),
    "very_bright": MessageLookupByLibrary.simpleMessage("Very Bright"),
    "very_dry": MessageLookupByLibrary.simpleMessage("Very Dry"),
    "very_high": MessageLookupByLibrary.simpleMessage("Very High"),
    "vibrate": MessageLookupByLibrary.simpleMessage("Vibrate"),
    "vibrationOnly": MessageLookupByLibrary.simpleMessage("Vibration Only"),
    "vibration_only": MessageLookupByLibrary.simpleMessage("Vibration Only"),
    "vibration_only_description": MessageLookupByLibrary.simpleMessage(
      "Silent notifications with vibration only",
    ),
    "vibration_only_enabled_disabled": m32,
    "view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "view_complete_prescriptions": MessageLookupByLibrary.simpleMessage(
      "View and complete your farm prescriptions",
    ),
    "view_details": MessageLookupByLibrary.simpleMessage("View Details"),
    "view_more_details": MessageLookupByLibrary.simpleMessage(
      "View more details",
    ),
    "vt_tasseling": MessageLookupByLibrary.simpleMessage("Tasseling (VT)"),
    "wednesday": MessageLookupByLibrary.simpleMessage("Wednesday"),
    "welcome": MessageLookupByLibrary.simpleMessage("Welcome to Maize Watch"),
    "wet": MessageLookupByLibrary.simpleMessage("Wet"),
    "when_did_you_plant": MessageLookupByLibrary.simpleMessage(
      "When did you plant your corn? This helps us determine the current growth stage.",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "you_have_new_farm_tasks": m33,
    "your_personal_information": MessageLookupByLibrary.simpleMessage(
      "Your Personal Information",
    ),
    "zip_code": MessageLookupByLibrary.simpleMessage("Zip Code"),
    "zip_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid zip code",
    ),
    "zip_code_optional": MessageLookupByLibrary.simpleMessage(
      "Zip Code (Optional)",
    ),
  };
}
