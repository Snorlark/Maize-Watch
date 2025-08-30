// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(days, rate) => "${days} days to next stage (${rate}/day)";

  static String m1(parameter) =>
      "Are you sure you want to delete this ${parameter} prescription?";

  static String m2(filter) => "No prescriptions found for \"${filter}\"";

  static String m3(count) => "Manage your prescriptions (${count} total)";

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
    "all_fields_required": MessageLookupByLibrary.simpleMessage(
      "All fields are required.",
    ),
    "and": MessageLookupByLibrary.simpleMessage(" and "),
    "appName": MessageLookupByLibrary.simpleMessage("Maize Watch"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "back_button": MessageLookupByLibrary.simpleMessage("Back"),
    "barangay": MessageLookupByLibrary.simpleMessage("Barangay"),
    "barangay_required": MessageLookupByLibrary.simpleMessage(
      "Barangay is required",
    ),
    "bright": MessageLookupByLibrary.simpleMessage("Bright"),
    "button_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "confirm_password_required": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "connection_error": MessageLookupByLibrary.simpleMessage(
      "Connection error. Please check your internet and try again.",
    ),
    "contactUs": MessageLookupByLibrary.simpleMessage("Contact us at:"),
    "contact_number": MessageLookupByLibrary.simpleMessage(
      "10-digit Contact Number",
    ),
    "contact_number_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Contact number must start with 9",
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
    "days_since_planting": MessageLookupByLibrary.simpleMessage(
      "Days Since Planting",
    ),
    "days_to_next_stage": m0,
    "declining": MessageLookupByLibrary.simpleMessage("Growth is declining"),
    "default_user": MessageLookupByLibrary.simpleMessage("farmer"),
    "description": MessageLookupByLibrary.simpleMessage(
      "Maximize your yields, minimize your worries.",
    ),
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
    "dialog_delete_prescription_confirm": m1,
    "dim": MessageLookupByLibrary.simpleMessage("Dim"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "dry": MessageLookupByLibrary.simpleMessage("Dry"),
    "empty_no_prescriptions": MessageLookupByLibrary.simpleMessage(
      "No prescriptions found",
    ),
    "empty_no_prescriptions_filter": m2,
    "enableNotifications": MessageLookupByLibrary.simpleMessage(
      "Enable Notifications",
    ),
    "enable_notifications": MessageLookupByLibrary.simpleMessage(
      "Enable Notifications",
    ),
    "enter_barangay": MessageLookupByLibrary.simpleMessage("Enter Barangay"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "error_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Error deleting prescription",
    ),
    "error_delete_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Error deleting prescriptions",
    ),
    "error_invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Wrong username or password. Please check your credentials and try again.",
    ),
    "error_load_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Failed to load prescriptions",
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
    "error_update_prescription": MessageLookupByLibrary.simpleMessage(
      "Error updating prescription",
    ),
    "excellent": MessageLookupByLibrary.simpleMessage("Excellent"),
    "exit_app_message": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the application?",
    ),
    "exit_app_title": MessageLookupByLibrary.simpleMessage("Exit Application"),
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
    "faq_q1": MessageLookupByLibrary.simpleMessage(
      "What do the sensor indicators mean?",
    ),
    "faq_q2": MessageLookupByLibrary.simpleMessage(
      "How often does the app update sensor data?",
    ),
    "faq_title": MessageLookupByLibrary.simpleMessage("FAQs"),
    "field_information": MessageLookupByLibrary.simpleMessage(
      "Field Information",
    ),
    "field_name": MessageLookupByLibrary.simpleMessage("Field Name"),
    "field_name_label": MessageLookupByLibrary.simpleMessage("Field Name"),
    "field_name_required": MessageLookupByLibrary.simpleMessage(
      "Field name is required",
    ),
    "filter_done": MessageLookupByLibrary.simpleMessage("Done"),
    "filter_newest": MessageLookupByLibrary.simpleMessage("Newest First"),
    "filter_not_done": MessageLookupByLibrary.simpleMessage("Not Yet Done"),
    "filter_oldest": MessageLookupByLibrary.simpleMessage("Oldest First"),
    "filter_view_all": MessageLookupByLibrary.simpleMessage("View All"),
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
    "forgot_password": MessageLookupByLibrary.simpleMessage("Forgot Password?"),
    "fully_developed_corn": MessageLookupByLibrary.simpleMessage(
      "Fully developed corn",
    ),
    "good": MessageLookupByLibrary.simpleMessage("Good"),
    "greeting_afternoon": MessageLookupByLibrary.simpleMessage(
      "Good Afternoon",
    ),
    "greeting_evening": MessageLookupByLibrary.simpleMessage("Good Evening"),
    "greeting_morning": MessageLookupByLibrary.simpleMessage("Good Morning"),
    "growth_stage": MessageLookupByLibrary.simpleMessage("Growth Stage"),
    "growth_stage_r1": MessageLookupByLibrary.simpleMessage("Silking"),
    "growth_stage_r1_desc": MessageLookupByLibrary.simpleMessage(
      "Silks emerging from ears",
    ),
    "growth_stage_r6": MessageLookupByLibrary.simpleMessage("Mature"),
    "growth_stage_r6_desc": MessageLookupByLibrary.simpleMessage(
      "Fully developed corn",
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
    "healthy_growth": MessageLookupByLibrary.simpleMessage(
      "Healthy growth rate",
    ),
    "helpDescription": MessageLookupByLibrary.simpleMessage(
      "Here\'s some helpful info.",
    ),
    "helpTitle": MessageLookupByLibrary.simpleMessage("Help"),
    "help_description": MessageLookupByLibrary.simpleMessage(
      "This section provides information to help users understand the app features and usage. Learn how to monitor your plants, configure settings, and interpret sensor data.",
    ),
    "help_title": MessageLookupByLibrary.simpleMessage("Help"),
    "high": MessageLookupByLibrary.simpleMessage("High"),
    "hours_ago": MessageLookupByLibrary.simpleMessage("hours ago"),
    "humidity": MessageLookupByLibrary.simpleMessage("Humidity"),
    "humidity_moderate": MessageLookupByLibrary.simpleMessage(
      "The air has moderate humidity, comfortable for plant transpiration.",
    ),
    "humidity_quite_humid": MessageLookupByLibrary.simpleMessage(
      "The air is quite humid, often associated with moist environments.",
    ),
    "humidity_title": MessageLookupByLibrary.simpleMessage("Humidity"),
    "humidity_very_dry": MessageLookupByLibrary.simpleMessage(
      "The air is very dry, typical of arid environments.",
    ),
    "humidity_very_humid": MessageLookupByLibrary.simpleMessage(
      "The air is very humid, common before rainfall or in tropical climates.",
    ),
    "invalid_credentials": MessageLookupByLibrary.simpleMessage(
      "Invalid username or password",
    ),
    "just_now": MessageLookupByLibrary.simpleMessage("just now"),
    "just_sprouting_from_soil": MessageLookupByLibrary.simpleMessage(
      "Just sprouting from soil",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
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
    "ldrSensor": MessageLookupByLibrary.simpleMessage("LDR Sensor"),
    "ldr_sensor": MessageLookupByLibrary.simpleMessage(
      "Light Dependent Resistor",
    ),
    "leaves_3_5_developed": MessageLookupByLibrary.simpleMessage(
      "3-5 leaves developed",
    ),
    "leaves_8_10_developed": MessageLookupByLibrary.simpleMessage(
      "8-10 leaves, growing taller",
    ),
    "light_intensity": MessageLookupByLibrary.simpleMessage("Light Intensity"),
    "light_intensity_bright": MessageLookupByLibrary.simpleMessage(
      "The light intensity is bright, close to clear daytime conditions.",
    ),
    "light_intensity_moderate": MessageLookupByLibrary.simpleMessage(
      "The light intensity is moderate, similar to cloudy daylight.",
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
    "location": MessageLookupByLibrary.simpleMessage("Location"),
    "location_default": MessageLookupByLibrary.simpleMessage(
      "Default: Amadeo, Cavite",
    ),
    "location_label": MessageLookupByLibrary.simpleMessage("Location"),
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
    "municipality": MessageLookupByLibrary.simpleMessage("Municipality"),
    "municipality_amadeo": MessageLookupByLibrary.simpleMessage("Amadeo"),
    "municipality_required": MessageLookupByLibrary.simpleMessage(
      "Municipality is required",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "next_button": MessageLookupByLibrary.simpleMessage("Next"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "no_corn_fields": MessageLookupByLibrary.simpleMessage(
      "No corn fields found",
    ),
    "no_data": MessageLookupByLibrary.simpleMessage("No Data"),
    "normal": MessageLookupByLibrary.simpleMessage("Normal"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "off": MessageLookupByLibrary.simpleMessage("Off"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "okay": MessageLookupByLibrary.simpleMessage("Okay"),
    "on": MessageLookupByLibrary.simpleMessage("On"),
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
    "password": MessageLookupByLibrary.simpleMessage("Password"),
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
    "password_too_common": MessageLookupByLibrary.simpleMessage(
      "This password is too common. Please choose a stronger password",
    ),
    "password_too_long": MessageLookupByLibrary.simpleMessage(
      "Password must not exceed 128 characters",
    ),
    "password_too_short": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwords_dont_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "phSensor": MessageLookupByLibrary.simpleMessage("pH Level Sensor"),
    "ph_sensor": MessageLookupByLibrary.simpleMessage("PH Level of Soil"),
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
    "poor": MessageLookupByLibrary.simpleMessage("Poor"),
    "prescriptions_subtitle": m3,
    "prescriptions_title": MessageLookupByLibrary.simpleMessage(
      "Prescriptions",
    ),
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
    "province": MessageLookupByLibrary.simpleMessage("Province"),
    "province_cavite": MessageLookupByLibrary.simpleMessage("Cavite"),
    "province_required": MessageLookupByLibrary.simpleMessage(
      "Province is required",
    ),
    "r1_silking": MessageLookupByLibrary.simpleMessage("Silking (R1)"),
    "r6_mature": MessageLookupByLibrary.simpleMessage("Mature (R6)"),
    "rainfall": MessageLookupByLibrary.simpleMessage("Rainfall"),
    "rapid_growth": MessageLookupByLibrary.simpleMessage(
      "Rapid growth detected!",
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
    "registration_failed": MessageLookupByLibrary.simpleMessage(
      "Registration failed. Please try again.",
    ),
    "registration_successful": MessageLookupByLibrary.simpleMessage(
      "Registration successful! Please input your corn information.",
    ),
    "registration_timeout": MessageLookupByLibrary.simpleMessage(
      "The server is taking too long to respond. Your account may have been created. Please try logging in.",
    ),
    "review_and_submit": MessageLookupByLibrary.simpleMessage(
      "Review and Submit",
    ),
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
    "select_municipality": MessageLookupByLibrary.simpleMessage(
      "Select your municipality",
    ),
    "select_province": MessageLookupByLibrary.simpleMessage(
      "Select your province",
    ),
    "select_region": MessageLookupByLibrary.simpleMessage("Select your region"),
    "sensors": MessageLookupByLibrary.simpleMessage("Sensors"),
    "session_expired": MessageLookupByLibrary.simpleMessage(
      "Your session has expired. Please log in again.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "silks_emerging": MessageLookupByLibrary.simpleMessage(
      "Silks emerging from ears",
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
    "soil_moisture": MessageLookupByLibrary.simpleMessage("Soil Moisture"),
    "soil_moisture_sensor": MessageLookupByLibrary.simpleMessage(
      "Soil Moisture",
    ),
    "soil_peaty": MessageLookupByLibrary.simpleMessage("Peaty"),
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
    "status_all_completed_deleted": MessageLookupByLibrary.simpleMessage(
      "All completed prescriptions deleted",
    ),
    "status_all_deleted": MessageLookupByLibrary.simpleMessage(
      "All prescriptions deleted",
    ),
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
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "submit_button": MessageLookupByLibrary.simpleMessage("Submit"),
    "tassels_appearing": MessageLookupByLibrary.simpleMessage(
      "Tassels appearing at top",
    ),
    "tempHumidSensor": MessageLookupByLibrary.simpleMessage(
      "Temperature & Humidity Sensor",
    ),
    "temp_humid_sensor": MessageLookupByLibrary.simpleMessage(
      "Temperature and Humidity",
    ),
    "temperature": MessageLookupByLibrary.simpleMessage("Temperature"),
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
    "textSizeLabel": MessageLookupByLibrary.simpleMessage("Text Size"),
    "tooltip_delete_prescription": MessageLookupByLibrary.simpleMessage(
      "Delete prescription",
    ),
    "tooltip_refresh_prescriptions": MessageLookupByLibrary.simpleMessage(
      "Refresh prescriptions",
    ),
    "translate": MessageLookupByLibrary.simpleMessage("Translate"),
    "try_again": MessageLookupByLibrary.simpleMessage("Try Again"),
    "user_id_not_found": MessageLookupByLibrary.simpleMessage(
      "User ID not found",
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
    "versionInfo": MessageLookupByLibrary.simpleMessage("version 1.0.0"),
    "very_bright": MessageLookupByLibrary.simpleMessage("Very Bright"),
    "very_dry": MessageLookupByLibrary.simpleMessage("Very Dry"),
    "very_high": MessageLookupByLibrary.simpleMessage("Very High"),
    "vibrate": MessageLookupByLibrary.simpleMessage("Vibrate"),
    "vibrationOnly": MessageLookupByLibrary.simpleMessage("Vibration Only"),
    "vibration_only": MessageLookupByLibrary.simpleMessage("Vibration Only"),
    "view_details": MessageLookupByLibrary.simpleMessage("View Details"),
    "view_more_details": MessageLookupByLibrary.simpleMessage(
      "View more details",
    ),
    "vt_tasseling": MessageLookupByLibrary.simpleMessage("Tasseling (VT)"),
    "welcome": MessageLookupByLibrary.simpleMessage("Welcome to Maize Watch"),
    "wet": MessageLookupByLibrary.simpleMessage("Wet"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "zip_code": MessageLookupByLibrary.simpleMessage("Zip Code"),
    "zip_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid zip code",
    ),
    "zip_code_optional": MessageLookupByLibrary.simpleMessage(
      "Zip Code (Optional)",
    ),
  };
}
