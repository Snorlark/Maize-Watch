// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Welcome to Maize Watch`
  String get welcome {
    return Intl.message(
      'Welcome to Maize Watch',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Maximize your yields, minimize your worries.`
  String get description {
    return Intl.message(
      'Maximize your yields, minimize your worries.',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get login {
    return Intl.message('Log In', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Let's get you started`
  String get register_page1_title {
    return Intl.message(
      'Let\'s get you started',
      name: 'register_page1_title',
      desc: '',
      args: [],
    );
  }

  /// `Create your account by providing your personal information below.`
  String get register_page1_description {
    return Intl.message(
      'Create your account by providing your personal information below.',
      name: 'register_page1_description',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get first_name {
    return Intl.message('First Name', name: 'first_name', desc: '', args: []);
  }

  /// `Last Name`
  String get last_name {
    return Intl.message('Last Name', name: 'last_name', desc: '', args: []);
  }

  /// `10-digit Contact Number`
  String get contact_number {
    return Intl.message(
      '10-digit Contact Number',
      name: 'contact_number',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Hi, `
  String get register_page2_title {
    return Intl.message(
      'Hi, ',
      name: 'register_page2_title',
      desc: '',
      args: [],
    );
  }

  /// `Now let's set up your login credentials to secure your account.`
  String get register_page2_description {
    return Intl.message(
      'Now let\'s set up your login credentials to secure your account.',
      name: 'register_page2_description',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `User ID not found`
  String get user_id_not_found {
    return Intl.message(
      'User ID not found',
      name: 'user_id_not_found',
      desc: '',
      args: [],
    );
  }

  /// `First name is required`
  String get first_name_required {
    return Intl.message(
      'First name is required',
      name: 'first_name_required',
      desc: '',
      args: [],
    );
  }

  /// `Last name is required`
  String get last_name_required {
    return Intl.message(
      'Last name is required',
      name: 'last_name_required',
      desc: '',
      args: [],
    );
  }

  /// `Contact number is required`
  String get contact_number_required {
    return Intl.message(
      'Contact number is required',
      name: 'contact_number_required',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid Philippine mobile number`
  String get valid_ph_number_required {
    return Intl.message(
      'Enter a valid Philippine mobile number',
      name: 'valid_ph_number_required',
      desc: '',
      args: [],
    );
  }

  /// `Address is required`
  String get address_required {
    return Intl.message(
      'Address is required',
      name: 'address_required',
      desc: '',
      args: [],
    );
  }

  /// `Username is required`
  String get username_required {
    return Intl.message(
      'Username is required',
      name: 'username_required',
      desc: '',
      args: [],
    );
  }

  /// `Username must be at least 3 characters`
  String get username_too_short {
    return Intl.message(
      'Username must be at least 3 characters',
      name: 'username_too_short',
      desc: '',
      args: [],
    );
  }

  /// `Registration successful! Please input your corn information.`
  String get registration_successful {
    return Intl.message(
      'Registration successful! Please input your corn information.',
      name: 'registration_successful',
      desc: '',
      args: [],
    );
  }

  /// `Connection error. Please check your internet and try again.`
  String get connection_error {
    return Intl.message(
      'Connection error. Please check your internet and try again.',
      name: 'connection_error',
      desc: '',
      args: [],
    );
  }

  /// `Username already exists. Please try another one.`
  String get username_already_exists {
    return Intl.message(
      'Username already exists. Please try another one.',
      name: 'username_already_exists',
      desc: '',
      args: [],
    );
  }

  /// `The server is taking too long to respond. Your account may have been created. Please try logging in.`
  String get registration_timeout {
    return Intl.message(
      'The server is taking too long to respond. Your account may have been created. Please try logging in.',
      name: 'registration_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed. Please try again.`
  String get registration_failed {
    return Intl.message(
      'Registration failed. Please try again.',
      name: 'registration_failed',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get password_required {
    return Intl.message(
      'Password is required',
      name: 'password_required',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get password_too_short {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'password_too_short',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwords_dont_match {
    return Intl.message(
      'Passwords do not match',
      name: 'passwords_dont_match',
      desc: '',
      args: [],
    );
  }

  /// `Login failed. Please log in manually.`
  String get login_failed {
    return Intl.message(
      'Login failed. Please log in manually.',
      name: 'login_failed',
      desc: '',
      args: [],
    );
  }

  /// `All fields are required.`
  String get all_fields_required {
    return Intl.message(
      'All fields are required.',
      name: 'all_fields_required',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `LDR Sensor`
  String get ldrSensor {
    return Intl.message('LDR Sensor', name: 'ldrSensor', desc: '', args: []);
  }

  /// `pH Level Sensor`
  String get phSensor {
    return Intl.message(
      'pH Level Sensor',
      name: 'phSensor',
      desc: '',
      args: [],
    );
  }

  /// `Temperature & Humidity Sensor`
  String get tempHumidSensor {
    return Intl.message(
      'Temperature & Humidity Sensor',
      name: 'tempHumidSensor',
      desc: '',
      args: [],
    );
  }

  /// `Soil Moisture Sensor`
  String get soilMoistureSensor {
    return Intl.message(
      'Soil Moisture Sensor',
      name: 'soilMoistureSensor',
      desc: '',
      args: [],
    );
  }

  /// `Register your corn next`
  String get register_corn_next {
    return Intl.message(
      'Register your corn next',
      name: 'register_corn_next',
      desc: '',
      args: [],
    );
  }

  /// `Register Corn`
  String get register_corn_button {
    return Intl.message(
      'Register Corn',
      name: 'register_corn_button',
      desc: '',
      args: [],
    );
  }

  /// `Corn Registration`
  String get corn_registration {
    return Intl.message(
      'Corn Registration',
      name: 'corn_registration',
      desc: '',
      args: [],
    );
  }

  /// `Field Information`
  String get field_information {
    return Intl.message(
      'Field Information',
      name: 'field_information',
      desc: '',
      args: [],
    );
  }

  /// `Field Name`
  String get field_name {
    return Intl.message('Field Name', name: 'field_name', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Soil Type`
  String get soil_type {
    return Intl.message('Soil Type', name: 'soil_type', desc: '', args: []);
  }

  /// `Corn`
  String get corn {
    return Intl.message('Corn', name: 'corn', desc: '', args: []);
  }

  /// `Corn Variety`
  String get corn_variety {
    return Intl.message(
      'Corn Variety',
      name: 'corn_variety',
      desc: '',
      args: [],
    );
  }

  /// `Planting Date`
  String get planting_date {
    return Intl.message(
      'Planting Date',
      name: 'planting_date',
      desc: '',
      args: [],
    );
  }

  /// `Growth Stage`
  String get growth_stage {
    return Intl.message(
      'Growth Stage',
      name: 'growth_stage',
      desc: '',
      args: [],
    );
  }

  /// `Review and Submit`
  String get review_and_submit {
    return Intl.message(
      'Review and Submit',
      name: 'review_and_submit',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Select Date`
  String get select_date {
    return Intl.message('Select Date', name: 'select_date', desc: '', args: []);
  }

  /// `Field name is required`
  String get field_name_required {
    return Intl.message(
      'Field name is required',
      name: 'field_name_required',
      desc: '',
      args: [],
    );
  }

  /// `Soil type is required`
  String get soil_type_required {
    return Intl.message(
      'Soil type is required',
      name: 'soil_type_required',
      desc: '',
      args: [],
    );
  }

  /// `Corn Growth`
  String get corn_growth {
    return Intl.message('Corn Growth', name: 'corn_growth', desc: '', args: []);
  }

  /// `{days} days to next stage ({rate}/day)`
  String days_to_next_stage(int days, String rate) {
    return Intl.message(
      '$days days to next stage ($rate/day)',
      name: 'days_to_next_stage',
      desc: '',
      args: [days, rate],
    );
  }

  /// `Emergence (VE)`
  String get ve_emergence {
    return Intl.message(
      'Emergence (VE)',
      name: 've_emergence',
      desc: '',
      args: [],
    );
  }

  /// `Early Growth (V3)`
  String get v3_early_growth {
    return Intl.message(
      'Early Growth (V3)',
      name: 'v3_early_growth',
      desc: '',
      args: [],
    );
  }

  /// `Mid Growth (V8)`
  String get v8_mid_growth {
    return Intl.message(
      'Mid Growth (V8)',
      name: 'v8_mid_growth',
      desc: '',
      args: [],
    );
  }

  /// `Tasseling (VT)`
  String get vt_tasseling {
    return Intl.message(
      'Tasseling (VT)',
      name: 'vt_tasseling',
      desc: '',
      args: [],
    );
  }

  /// `Silking (R1)`
  String get r1_silking {
    return Intl.message('Silking (R1)', name: 'r1_silking', desc: '', args: []);
  }

  /// `Mature (R6)`
  String get r6_mature {
    return Intl.message('Mature (R6)', name: 'r6_mature', desc: '', args: []);
  }

  /// `Just sprouting from soil`
  String get just_sprouting_from_soil {
    return Intl.message(
      'Just sprouting from soil',
      name: 'just_sprouting_from_soil',
      desc: '',
      args: [],
    );
  }

  /// `3-5 leaves developed`
  String get leaves_3_5_developed {
    return Intl.message(
      '3-5 leaves developed',
      name: 'leaves_3_5_developed',
      desc: '',
      args: [],
    );
  }

  /// `8-10 leaves, growing taller`
  String get leaves_8_10_developed {
    return Intl.message(
      '8-10 leaves, growing taller',
      name: 'leaves_8_10_developed',
      desc: '',
      args: [],
    );
  }

  /// `Tassels appearing at top`
  String get tassels_appearing {
    return Intl.message(
      'Tassels appearing at top',
      name: 'tassels_appearing',
      desc: '',
      args: [],
    );
  }

  /// `Silks emerging from ears`
  String get silks_emerging {
    return Intl.message(
      'Silks emerging from ears',
      name: 'silks_emerging',
      desc: '',
      args: [],
    );
  }

  /// `Fully developed corn`
  String get fully_developed_corn {
    return Intl.message(
      'Fully developed corn',
      name: 'fully_developed_corn',
      desc: '',
      args: [],
    );
  }

  /// `Growth is stable`
  String get stable {
    return Intl.message('Growth is stable', name: 'stable', desc: '', args: []);
  }

  /// `Healthy growth rate`
  String get healthy_growth {
    return Intl.message(
      'Healthy growth rate',
      name: 'healthy_growth',
      desc: '',
      args: [],
    );
  }

  /// `Rapid growth detected!`
  String get rapid_growth {
    return Intl.message(
      'Rapid growth detected!',
      name: 'rapid_growth',
      desc: '',
      args: [],
    );
  }

  /// `Growth is declining`
  String get declining {
    return Intl.message(
      'Growth is declining',
      name: 'declining',
      desc: '',
      args: [],
    );
  }

  /// `Enable Notifications`
  String get enableNotifications {
    return Intl.message(
      'Enable Notifications',
      name: 'enableNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Vibration Only`
  String get vibrationOnly {
    return Intl.message(
      'Vibration Only',
      name: 'vibrationOnly',
      desc: '',
      args: [],
    );
  }

  /// `Sound & Vibrate`
  String get soundAndVibrate {
    return Intl.message(
      'Sound & Vibrate',
      name: 'soundAndVibrate',
      desc: '',
      args: [],
    );
  }

  /// `Corn variety is required`
  String get corn_variety_required {
    return Intl.message(
      'Corn variety is required',
      name: 'corn_variety_required',
      desc: '',
      args: [],
    );
  }

  /// `Planting date is required`
  String get planting_date_required {
    return Intl.message(
      'Planting date is required',
      name: 'planting_date_required',
      desc: '',
      args: [],
    );
  }

  /// `Growth stage is required`
  String get growth_stage_required {
    return Intl.message(
      'Growth stage is required',
      name: 'growth_stage_required',
      desc: '',
      args: [],
    );
  }

  /// `Field`
  String get step1_title {
    return Intl.message('Field', name: 'step1_title', desc: '', args: []);
  }

  /// `Soil`
  String get step2_title {
    return Intl.message('Soil', name: 'step2_title', desc: '', args: []);
  }

  /// `Corn`
  String get step3_title {
    return Intl.message('Corn', name: 'step3_title', desc: '', args: []);
  }

  /// `Season`
  String get step4_title {
    return Intl.message('Season', name: 'step4_title', desc: '', args: []);
  }

  /// `Age`
  String get step5_title {
    return Intl.message('Age', name: 'step5_title', desc: '', args: []);
  }

  /// `Field Name`
  String get field_name_label {
    return Intl.message(
      'Field Name',
      name: 'field_name_label',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location_label {
    return Intl.message('Location', name: 'location_label', desc: '', args: []);
  }

  /// `Default: Amadeo, Cavite`
  String get location_default {
    return Intl.message(
      'Default: Amadeo, Cavite',
      name: 'location_default',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back_button {
    return Intl.message('Back', name: 'back_button', desc: '', args: []);
  }

  /// `Next`
  String get next_button {
    return Intl.message('Next', name: 'next_button', desc: '', args: []);
  }

  /// `Submit`
  String get submit_button {
    return Intl.message('Submit', name: 'submit_button', desc: '', args: []);
  }

  /// `Choose your field's soil type`
  String get soil_type_title {
    return Intl.message(
      'Choose your field\'s soil type',
      name: 'soil_type_title',
      desc: '',
      args: [],
    );
  }

  /// `Choose your preferred corn variety`
  String get corn_variety_title {
    return Intl.message(
      'Choose your preferred corn variety',
      name: 'corn_variety_title',
      desc: '',
      args: [],
    );
  }

  /// `When did you plant?`
  String get planting_season_title {
    return Intl.message(
      'When did you plant?',
      name: 'planting_season_title',
      desc: '',
      args: [],
    );
  }

  /// `Select the date you planted your corn`
  String get planting_season_description {
    return Intl.message(
      'Select the date you planted your corn',
      name: 'planting_season_description',
      desc: '',
      args: [],
    );
  }

  /// `How old is your corn crop?`
  String get corn_age_title {
    return Intl.message(
      'How old is your corn crop?',
      name: 'corn_age_title',
      desc: '',
      args: [],
    );
  }

  /// `Clay`
  String get soil_clay {
    return Intl.message('Clay', name: 'soil_clay', desc: '', args: []);
  }

  /// `Silt`
  String get soil_silt {
    return Intl.message('Silt', name: 'soil_silt', desc: '', args: []);
  }

  /// `Sandy`
  String get soil_sandy {
    return Intl.message('Sandy', name: 'soil_sandy', desc: '', args: []);
  }

  /// `Loam`
  String get soil_loam {
    return Intl.message('Loam', name: 'soil_loam', desc: '', args: []);
  }

  /// `Peaty`
  String get soil_peaty {
    return Intl.message('Peaty', name: 'soil_peaty', desc: '', args: []);
  }

  /// `Saline`
  String get soil_saline {
    return Intl.message('Saline', name: 'soil_saline', desc: '', args: []);
  }

  /// `Glutinous (Malagkit)`
  String get variety_glutinous {
    return Intl.message(
      'Glutinous (Malagkit)',
      name: 'variety_glutinous',
      desc: '',
      args: [],
    );
  }

  /// `Yellow Dent`
  String get variety_yellow_dent {
    return Intl.message(
      'Yellow Dent',
      name: 'variety_yellow_dent',
      desc: '',
      args: [],
    );
  }

  /// `White Fodder`
  String get variety_white_fodder {
    return Intl.message(
      'White Fodder',
      name: 'variety_white_fodder',
      desc: '',
      args: [],
    );
  }

  /// `Flint`
  String get variety_flint {
    return Intl.message('Flint', name: 'variety_flint', desc: '', args: []);
  }

  /// `Sweet`
  String get variety_sweet {
    return Intl.message('Sweet', name: 'variety_sweet', desc: '', args: []);
  }

  /// `Purple`
  String get variety_purple {
    return Intl.message('Purple', name: 'variety_purple', desc: '', args: []);
  }

  /// `Wet Season (June to November)`
  String get season_wet {
    return Intl.message(
      'Wet Season (June to November)',
      name: 'season_wet',
      desc: '',
      args: [],
    );
  }

  /// `Dry Season (December to May)`
  String get season_dry {
    return Intl.message(
      'Dry Season (December to May)',
      name: 'season_dry',
      desc: '',
      args: [],
    );
  }

  /// `Both Seasons`
  String get season_both {
    return Intl.message(
      'Both Seasons',
      name: 'season_both',
      desc: '',
      args: [],
    );
  }

  /// `Emergence`
  String get growth_stage_ve {
    return Intl.message(
      'Emergence',
      name: 'growth_stage_ve',
      desc: '',
      args: [],
    );
  }

  /// `Just sprouting from soil`
  String get growth_stage_ve_desc {
    return Intl.message(
      'Just sprouting from soil',
      name: 'growth_stage_ve_desc',
      desc: '',
      args: [],
    );
  }

  /// `Early Growth`
  String get growth_stage_v3 {
    return Intl.message(
      'Early Growth',
      name: 'growth_stage_v3',
      desc: '',
      args: [],
    );
  }

  /// `3-5 leaves developed`
  String get growth_stage_v3_desc {
    return Intl.message(
      '3-5 leaves developed',
      name: 'growth_stage_v3_desc',
      desc: '',
      args: [],
    );
  }

  /// `Mid Growth`
  String get growth_stage_v8 {
    return Intl.message(
      'Mid Growth',
      name: 'growth_stage_v8',
      desc: '',
      args: [],
    );
  }

  /// `8-10 leaves, growing taller`
  String get growth_stage_v8_desc {
    return Intl.message(
      '8-10 leaves, growing taller',
      name: 'growth_stage_v8_desc',
      desc: '',
      args: [],
    );
  }

  /// `Tasseling`
  String get growth_stage_vt {
    return Intl.message(
      'Tasseling',
      name: 'growth_stage_vt',
      desc: '',
      args: [],
    );
  }

  /// `Tassels appearing at top`
  String get growth_stage_vt_desc {
    return Intl.message(
      'Tassels appearing at top',
      name: 'growth_stage_vt_desc',
      desc: '',
      args: [],
    );
  }

  /// `Silking`
  String get growth_stage_r1 {
    return Intl.message('Silking', name: 'growth_stage_r1', desc: '', args: []);
  }

  /// `Silks emerging from ears`
  String get growth_stage_r1_desc {
    return Intl.message(
      'Silks emerging from ears',
      name: 'growth_stage_r1_desc',
      desc: '',
      args: [],
    );
  }

  /// `Mature`
  String get growth_stage_r6 {
    return Intl.message('Mature', name: 'growth_stage_r6', desc: '', args: []);
  }

  /// `Fully developed corn`
  String get growth_stage_r6_desc {
    return Intl.message(
      'Fully developed corn',
      name: 'growth_stage_r6_desc',
      desc: '',
      args: [],
    );
  }

  /// `Loamy`
  String get soil_loamy {
    return Intl.message('Loamy', name: 'soil_loamy', desc: '', args: []);
  }

  /// `Mix of sand, silt, clay`
  String get soil_loamy_desc {
    return Intl.message(
      'Mix of sand, silt, clay',
      name: 'soil_loamy_desc',
      desc: '',
      args: [],
    );
  }

  /// `Light, drains quickly`
  String get soil_sandy_desc {
    return Intl.message(
      'Light, drains quickly',
      name: 'soil_sandy_desc',
      desc: '',
      args: [],
    );
  }

  /// `Heavy, holds water`
  String get soil_clay_desc {
    return Intl.message(
      'Heavy, holds water',
      name: 'soil_clay_desc',
      desc: '',
      args: [],
    );
  }

  /// `Silty`
  String get soil_silty {
    return Intl.message('Silty', name: 'soil_silty', desc: '', args: []);
  }

  /// `Smooth, holds moisture`
  String get soil_silty_desc {
    return Intl.message(
      'Smooth, holds moisture',
      name: 'soil_silty_desc',
      desc: '',
      args: [],
    );
  }

  /// `Sweet Corn`
  String get variety_sweet_corn {
    return Intl.message(
      'Sweet Corn',
      name: 'variety_sweet_corn',
      desc: '',
      args: [],
    );
  }

  /// `For human consumption`
  String get variety_sweet_corn_desc {
    return Intl.message(
      'For human consumption',
      name: 'variety_sweet_corn_desc',
      desc: '',
      args: [],
    );
  }

  /// `Field Corn`
  String get variety_field_corn {
    return Intl.message(
      'Field Corn',
      name: 'variety_field_corn',
      desc: '',
      args: [],
    );
  }

  /// `For animal feed, ethanol`
  String get variety_field_corn_desc {
    return Intl.message(
      'For animal feed, ethanol',
      name: 'variety_field_corn_desc',
      desc: '',
      args: [],
    );
  }

  /// `Popcorn`
  String get variety_popcorn {
    return Intl.message('Popcorn', name: 'variety_popcorn', desc: '', args: []);
  }

  /// `For popping`
  String get variety_popcorn_desc {
    return Intl.message(
      'For popping',
      name: 'variety_popcorn_desc',
      desc: '',
      args: [],
    );
  }

  /// `Flint Corn`
  String get variety_flint_corn {
    return Intl.message(
      'Flint Corn',
      name: 'variety_flint_corn',
      desc: '',
      args: [],
    );
  }

  /// `Colorful, decorative`
  String get variety_flint_corn_desc {
    return Intl.message(
      'Colorful, decorative',
      name: 'variety_flint_corn_desc',
      desc: '',
      args: [],
    );
  }

  /// `By logging in, you agree to our `
  String get agreement_prefix {
    return Intl.message(
      'By logging in, you agree to our ',
      name: 'agreement_prefix',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// ` and `
  String get and {
    return Intl.message(' and ', name: 'and', desc: '', args: []);
  }

  /// `Terms of Service`
  String get terms_of_service {
    return Intl.message(
      'Terms of Service',
      name: 'terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `.`
  String get agreement_suffix {
    return Intl.message('.', name: 'agreement_suffix', desc: '', args: []);
  }

  /// `Invalid username or password`
  String get invalid_credentials {
    return Intl.message(
      'Invalid username or password',
      name: 'invalid_credentials',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Enable Notifications`
  String get enable_notifications {
    return Intl.message(
      'Enable Notifications',
      name: 'enable_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Vibration Only`
  String get vibration_only {
    return Intl.message(
      'Vibration Only',
      name: 'vibration_only',
      desc: '',
      args: [],
    );
  }

  /// `Vibrate`
  String get vibrate {
    return Intl.message('Vibrate', name: 'vibrate', desc: '', args: []);
  }

  /// `Sound & Vibrate`
  String get sound_and_vibrate {
    return Intl.message(
      'Sound & Vibrate',
      name: 'sound_and_vibrate',
      desc: '',
      args: [],
    );
  }

  /// `Sensors`
  String get sensors {
    return Intl.message('Sensors', name: 'sensors', desc: '', args: []);
  }

  /// `Light Dependent Resistor`
  String get ldr_sensor {
    return Intl.message(
      'Light Dependent Resistor',
      name: 'ldr_sensor',
      desc: '',
      args: [],
    );
  }

  /// `PH Level of Soil`
  String get ph_sensor {
    return Intl.message(
      'PH Level of Soil',
      name: 'ph_sensor',
      desc: '',
      args: [],
    );
  }

  /// `Temperature and Humidity`
  String get temp_humid_sensor {
    return Intl.message(
      'Temperature and Humidity',
      name: 'temp_humid_sensor',
      desc: '',
      args: [],
    );
  }

  /// `Soil Moisture`
  String get soil_moisture_sensor {
    return Intl.message(
      'Soil Moisture',
      name: 'soil_moisture_sensor',
      desc: '',
      args: [],
    );
  }

  /// `On`
  String get on {
    return Intl.message('On', name: 'on', desc: '', args: []);
  }

  /// `Off`
  String get off {
    return Intl.message('Off', name: 'off', desc: '', args: []);
  }

  /// `Help`
  String get help_title {
    return Intl.message('Help', name: 'help_title', desc: '', args: []);
  }

  /// `This section provides information to help users understand the app features and usage. Learn how to monitor your plants, configure settings, and interpret sensor data.`
  String get help_description {
    return Intl.message(
      'This section provides information to help users understand the app features and usage. Learn how to monitor your plants, configure settings, and interpret sensor data.',
      name: 'help_description',
      desc: '',
      args: [],
    );
  }

  /// `FAQs`
  String get faq_title {
    return Intl.message('FAQs', name: 'faq_title', desc: '', args: []);
  }

  /// `What do the sensor indicators mean?`
  String get faq_q1 {
    return Intl.message(
      'What do the sensor indicators mean?',
      name: 'faq_q1',
      desc: '',
      args: [],
    );
  }

  /// `Green indicates the sensor is working properly, while red means there may be an issue.`
  String get faq_a1 {
    return Intl.message(
      'Green indicates the sensor is working properly, while red means there may be an issue.',
      name: 'faq_a1',
      desc: '',
      args: [],
    );
  }

  /// `How often does the app update sensor data?`
  String get faq_q2 {
    return Intl.message(
      'How often does the app update sensor data?',
      name: 'faq_q2',
      desc: '',
      args: [],
    );
  }

  /// `Sensor data is updated every 5 seconds automatically.`
  String get faq_a2 {
    return Intl.message(
      'Sensor data is updated every 5 seconds automatically.',
      name: 'faq_a2',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `About User`
  String get about_user {
    return Intl.message('About User', name: 'about_user', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `The maize-watch mobile app proposes an innovative, IoT-driven corn monitoring system enhanced by prescriptive analytics. This system will not only provide real-time data on crop health and environmental conditions but also use these data to offer practical advice, further optimizing maize quality and yield.`
  String get about_app {
    return Intl.message(
      'The maize-watch mobile app proposes an innovative, IoT-driven corn monitoring system enhanced by prescriptive analytics. This system will not only provide real-time data on crop health and environmental conditions but also use these data to offer practical advice, further optimizing maize quality and yield.',
      name: 'about_app',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `Logout Confirmation`
  String get logout_title {
    return Intl.message(
      'Logout Confirmation',
      name: 'logout_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout from your account?`
  String get logout_message {
    return Intl.message(
      'Are you sure you want to logout from your account?',
      name: 'logout_message',
      desc: '',
      args: [],
    );
  }

  /// `Exit Application`
  String get exit_app_title {
    return Intl.message(
      'Exit Application',
      name: 'exit_app_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit the application?`
  String get exit_app_message {
    return Intl.message(
      'Are you sure you want to exit the application?',
      name: 'exit_app_message',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `There was a problem logging out. Please try again.`
  String get logout_error {
    return Intl.message(
      'There was a problem logging out. Please try again.',
      name: 'logout_error',
      desc: '',
      args: [],
    );
  }

  /// `Okay`
  String get okay {
    return Intl.message('Okay', name: 'okay', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Try Again`
  String get try_again {
    return Intl.message('Try Again', name: 'try_again', desc: '', args: []);
  }

  /// `No corn fields found`
  String get no_corn_fields {
    return Intl.message(
      'No corn fields found',
      name: 'no_corn_fields',
      desc: '',
      args: [],
    );
  }

  /// `Please register a corn field to start tracking progress.`
  String get register_corn_field_prompt {
    return Intl.message(
      'Please register a corn field to start tracking progress.',
      name: 'register_corn_field_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Days Since Planting`
  String get days_since_planting {
    return Intl.message(
      'Days Since Planting',
      name: 'days_since_planting',
      desc: '',
      args: [],
    );
  }

  /// `Current Growth Stage`
  String get current_growth_stage {
    return Intl.message(
      'Current Growth Stage',
      name: 'current_growth_stage',
      desc: '',
      args: [],
    );
  }

  /// `Growth Timeline`
  String get growth_timeline {
    return Intl.message(
      'Growth Timeline',
      name: 'growth_timeline',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get days {
    return Intl.message('days', name: 'days', desc: '', args: []);
  }

  /// `Good Morning`
  String get greeting_morning {
    return Intl.message(
      'Good Morning',
      name: 'greeting_morning',
      desc: '',
      args: [],
    );
  }

  /// `Good Afternoon`
  String get greeting_afternoon {
    return Intl.message(
      'Good Afternoon',
      name: 'greeting_afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good Evening`
  String get greeting_evening {
    return Intl.message(
      'Good Evening',
      name: 'greeting_evening',
      desc: '',
      args: [],
    );
  }

  /// `farmer`
  String get default_user {
    return Intl.message('farmer', name: 'default_user', desc: '', args: []);
  }

  /// `Crop Condition`
  String get crop_condition_title {
    return Intl.message(
      'Crop Condition',
      name: 'crop_condition_title',
      desc: '',
      args: [],
    );
  }

  /// `Check the current status of your maize crop and get personalized recommendations.`
  String get crop_condition_subtitle {
    return Intl.message(
      'Check the current status of your maize crop and get personalized recommendations.',
      name: 'crop_condition_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard_title {
    return Intl.message(
      'Dashboard',
      name: 'dashboard_title',
      desc: '',
      args: [],
    );
  }

  /// `Temperature`
  String get temperature {
    return Intl.message('Temperature', name: 'temperature', desc: '', args: []);
  }

  /// `Humidity`
  String get humidity {
    return Intl.message('Humidity', name: 'humidity', desc: '', args: []);
  }

  /// `Soil Moisture`
  String get soil_moisture {
    return Intl.message(
      'Soil Moisture',
      name: 'soil_moisture',
      desc: '',
      args: [],
    );
  }

  /// `Rainfall`
  String get rainfall {
    return Intl.message('Rainfall', name: 'rainfall', desc: '', args: []);
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Last updated`
  String get last_updated {
    return Intl.message(
      'Last updated',
      name: 'last_updated',
      desc: '',
      args: [],
    );
  }

  /// `minutes ago`
  String get minutes_ago {
    return Intl.message('minutes ago', name: 'minutes_ago', desc: '', args: []);
  }

  /// `hours ago`
  String get hours_ago {
    return Intl.message('hours ago', name: 'hours_ago', desc: '', args: []);
  }

  /// `days ago`
  String get days_ago {
    return Intl.message('days ago', name: 'days_ago', desc: '', args: []);
  }

  /// `Just now`
  String get just_now {
    return Intl.message('Just now', name: 'just_now', desc: '', args: []);
  }

  /// `Crop Health`
  String get crop_health {
    return Intl.message('Crop Health', name: 'crop_health', desc: '', args: []);
  }

  /// `Excellent`
  String get excellent {
    return Intl.message('Excellent', name: 'excellent', desc: '', args: []);
  }

  /// `Good`
  String get good {
    return Intl.message('Good', name: 'good', desc: '', args: []);
  }

  /// `Fair`
  String get fair {
    return Intl.message('Fair', name: 'fair', desc: '', args: []);
  }

  /// `Poor`
  String get poor {
    return Intl.message('Poor', name: 'poor', desc: '', args: []);
  }

  /// `Critical`
  String get critical {
    return Intl.message('Critical', name: 'critical', desc: '', args: []);
  }

  /// `Recommendations`
  String get recommendation_title {
    return Intl.message(
      'Recommendations',
      name: 'recommendation_title',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get view_details {
    return Intl.message(
      'View Details',
      name: 'view_details',
      desc: '',
      args: [],
    );
  }

  /// `See More`
  String get see_more {
    return Intl.message('See More', name: 'see_more', desc: '', args: []);
  }

  /// `ONLINE`
  String get live {
    return Intl.message('ONLINE', name: 'live', desc: '', args: []);
  }

  /// `View more details`
  String get view_more_details {
    return Intl.message(
      'View more details',
      name: 'view_more_details',
      desc: '',
      args: [],
    );
  }

  /// `seconds ago`
  String get seconds_ago {
    return Intl.message('seconds ago', name: 'seconds_ago', desc: '', args: []);
  }

  /// `No Data`
  String get no_data {
    return Intl.message('No Data', name: 'no_data', desc: '', args: []);
  }

  /// `Your crops are in excellent condition.`
  String get crop_excellent {
    return Intl.message(
      'Your crops are in excellent condition.',
      name: 'crop_excellent',
      desc: '',
      args: [],
    );
  }

  /// `Your crops are doing okay. Monitor closely.`
  String get crop_okay {
    return Intl.message(
      'Your crops are doing okay. Monitor closely.',
      name: 'crop_okay',
      desc: '',
      args: [],
    );
  }

  /// `Crops are at risk! Immediate action needed.`
  String get crop_risk {
    return Intl.message(
      'Crops are at risk! Immediate action needed.',
      name: 'crop_risk',
      desc: '',
      args: [],
    );
  }

  /// `Stay updated with your farm!`
  String get stay_updated {
    return Intl.message(
      'Stay updated with your farm!',
      name: 'stay_updated',
      desc: '',
      args: [],
    );
  }

  /// `The soil is too dry. Irrigation is highly recommended to prevent plant stress.`
  String get moisture_too_dry {
    return Intl.message(
      'The soil is too dry. Irrigation is highly recommended to prevent plant stress.',
      name: 'moisture_too_dry',
      desc: '',
      args: [],
    );
  }

  /// `The soil moisture is low. Consider watering soon to maintain healthy growth.`
  String get moisture_low {
    return Intl.message(
      'The soil moisture is low. Consider watering soon to maintain healthy growth.',
      name: 'moisture_low',
      desc: '',
      args: [],
    );
  }

  /// `The soil moisture is at an optimal level. Plants are in good condition.`
  String get moisture_optimal {
    return Intl.message(
      'The soil moisture is at an optimal level. Plants are in good condition.',
      name: 'moisture_optimal',
      desc: '',
      args: [],
    );
  }

  /// `The soil is fairly moist. Monitor for potential overwatering.`
  String get moisture_fairly_moist {
    return Intl.message(
      'The soil is fairly moist. Monitor for potential overwatering.',
      name: 'moisture_fairly_moist',
      desc: '',
      args: [],
    );
  }

  /// `The soil is too wet. Risk of root rot and fungal diseases is high.`
  String get moisture_too_wet {
    return Intl.message(
      'The soil is too wet. Risk of root rot and fungal diseases is high.',
      name: 'moisture_too_wet',
      desc: '',
      args: [],
    );
  }

  /// `Light Intensity`
  String get light_intensity {
    return Intl.message(
      'Light Intensity',
      name: 'light_intensity',
      desc: '',
      args: [],
    );
  }

  /// `Very Dry`
  String get very_dry {
    return Intl.message('Very Dry', name: 'very_dry', desc: '', args: []);
  }

  /// `Dry`
  String get dry {
    return Intl.message('Dry', name: 'dry', desc: '', args: []);
  }

  /// `Normal`
  String get normal {
    return Intl.message('Normal', name: 'normal', desc: '', args: []);
  }

  /// `Moist`
  String get moist {
    return Intl.message('Moist', name: 'moist', desc: '', args: []);
  }

  /// `Wet`
  String get wet {
    return Intl.message('Wet', name: 'wet', desc: '', args: []);
  }

  /// `Low`
  String get low {
    return Intl.message('Low', name: 'low', desc: '', args: []);
  }

  /// `High`
  String get high {
    return Intl.message('High', name: 'high', desc: '', args: []);
  }

  /// `Very High`
  String get very_high {
    return Intl.message('Very High', name: 'very_high', desc: '', args: []);
  }

  /// `Dim`
  String get dim {
    return Intl.message('Dim', name: 'dim', desc: '', args: []);
  }

  /// `Low Light`
  String get low_light {
    return Intl.message('Low Light', name: 'low_light', desc: '', args: []);
  }

  /// `Bright`
  String get bright {
    return Intl.message('Bright', name: 'bright', desc: '', args: []);
  }

  /// `Very Bright`
  String get very_bright {
    return Intl.message('Very Bright', name: 'very_bright', desc: '', args: []);
  }

  /// `Humidity`
  String get humidity_title {
    return Intl.message('Humidity', name: 'humidity_title', desc: '', args: []);
  }

  /// `The air is very dry, typical of arid environments.`
  String get humidity_very_dry {
    return Intl.message(
      'The air is very dry, typical of arid environments.',
      name: 'humidity_very_dry',
      desc: '',
      args: [],
    );
  }

  /// `The air has moderate humidity, comfortable for plant transpiration.`
  String get humidity_moderate {
    return Intl.message(
      'The air has moderate humidity, comfortable for plant transpiration.',
      name: 'humidity_moderate',
      desc: '',
      args: [],
    );
  }

  /// `The air is quite humid, often associated with moist environments.`
  String get humidity_quite_humid {
    return Intl.message(
      'The air is quite humid, often associated with moist environments.',
      name: 'humidity_quite_humid',
      desc: '',
      args: [],
    );
  }

  /// `The air is very humid, common before rainfall or in tropical climates.`
  String get humidity_very_humid {
    return Intl.message(
      'The air is very humid, common before rainfall or in tropical climates.',
      name: 'humidity_very_humid',
      desc: '',
      args: [],
    );
  }

  /// `Light Intensity`
  String get light_intensity_title {
    return Intl.message(
      'Light Intensity',
      name: 'light_intensity_title',
      desc: '',
      args: [],
    );
  }

  /// `The light intensity is very low, resembling evening or dense shade.`
  String get light_intensity_very_low {
    return Intl.message(
      'The light intensity is very low, resembling evening or dense shade.',
      name: 'light_intensity_very_low',
      desc: '',
      args: [],
    );
  }

  /// `The light intensity is moderate, similar to cloudy daylight.`
  String get light_intensity_moderate {
    return Intl.message(
      'The light intensity is moderate, similar to cloudy daylight.',
      name: 'light_intensity_moderate',
      desc: '',
      args: [],
    );
  }

  /// `The light intensity is bright, close to clear daytime conditions.`
  String get light_intensity_bright {
    return Intl.message(
      'The light intensity is bright, close to clear daytime conditions.',
      name: 'light_intensity_bright',
      desc: '',
      args: [],
    );
  }

  /// `The light intensity is very strong, similar to direct midday sunlight.`
  String get light_intensity_very_strong {
    return Intl.message(
      'The light intensity is very strong, similar to direct midday sunlight.',
      name: 'light_intensity_very_strong',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get helpTitle {
    return Intl.message('Help', name: 'helpTitle', desc: '', args: []);
  }

  /// `Here's some helpful info.`
  String get helpDescription {
    return Intl.message(
      'Here\'s some helpful info.',
      name: 'helpDescription',
      desc: '',
      args: [],
    );
  }

  /// `FAQs`
  String get faqTitle {
    return Intl.message('FAQs', name: 'faqTitle', desc: '', args: []);
  }

  /// `How do I enable notifications?`
  String get faqQ1 {
    return Intl.message(
      'How do I enable notifications?',
      name: 'faqQ1',
      desc: '',
      args: [],
    );
  }

  /// `Go to settings and toggle the switch.`
  String get faqA1 {
    return Intl.message(
      'Go to settings and toggle the switch.',
      name: 'faqA1',
      desc: '',
      args: [],
    );
  }

  /// `How to reset my password?`
  String get faqQ2 {
    return Intl.message(
      'How to reset my password?',
      name: 'faqQ2',
      desc: '',
      args: [],
    );
  }

  /// `Click 'Forgot Password' on the login screen.`
  String get faqA2 {
    return Intl.message(
      'Click \'Forgot Password\' on the login screen.',
      name: 'faqA2',
      desc: '',
      args: [],
    );
  }

  /// `Maize Watch`
  String get appName {
    return Intl.message('Maize Watch', name: 'appName', desc: '', args: []);
  }

  /// `Maize Watch is a crop monitoring application designed to help farmers keep track of maize growth and identify issues quickly.`
  String get aboutApp {
    return Intl.message(
      'Maize Watch is a crop monitoring application designed to help farmers keep track of maize growth and identify issues quickly.',
      name: 'aboutApp',
      desc: '',
      args: [],
    );
  }

  /// `version 1.0.0`
  String get versionInfo {
    return Intl.message(
      'version 1.0.0',
      name: 'versionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Contact us at:`
  String get contactUs {
    return Intl.message(
      'Contact us at:',
      name: 'contactUs',
      desc: '',
      args: [],
    );
  }

  /// `Translate`
  String get translate {
    return Intl.message('Translate', name: 'translate', desc: '', args: []);
  }

  /// `Forgot Password?`
  String get forgot_password {
    return Intl.message(
      'Forgot Password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Your session has expired. Please log in again.`
  String get session_expired {
    return Intl.message(
      'Your session has expired. Please log in again.',
      name: 'session_expired',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Prescriptions`
  String get prescriptions_title {
    return Intl.message(
      'Prescriptions',
      name: 'prescriptions_title',
      desc: '',
      args: [],
    );
  }

  /// `Manage your prescriptions`
  String get prescriptions_subtitle {
    return Intl.message(
      'Manage your prescriptions',
      name: 'prescriptions_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get filter_view_all {
    return Intl.message(
      'View All',
      name: 'filter_view_all',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get filter_done {
    return Intl.message('Done', name: 'filter_done', desc: '', args: []);
  }

  /// `Not Yet Done`
  String get filter_not_done {
    return Intl.message(
      'Not Yet Done',
      name: 'filter_not_done',
      desc: '',
      args: [],
    );
  }

  /// `Newest First`
  String get filter_newest {
    return Intl.message(
      'Newest First',
      name: 'filter_newest',
      desc: '',
      args: [],
    );
  }

  /// `Oldest First`
  String get filter_oldest {
    return Intl.message(
      'Oldest First',
      name: 'filter_oldest',
      desc: '',
      args: [],
    );
  }

  /// `Check All`
  String get action_check_all {
    return Intl.message(
      'Check All',
      name: 'action_check_all',
      desc: '',
      args: [],
    );
  }

  /// `Uncheck All`
  String get action_uncheck_all {
    return Intl.message(
      'Uncheck All',
      name: 'action_uncheck_all',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get action_delete {
    return Intl.message('Delete', name: 'action_delete', desc: '', args: []);
  }

  /// `Delete All`
  String get action_delete_all {
    return Intl.message(
      'Delete All',
      name: 'action_delete_all',
      desc: '',
      args: [],
    );
  }

  /// `Delete Completed`
  String get action_delete_completed {
    return Intl.message(
      'Delete Completed',
      name: 'action_delete_completed',
      desc: '',
      args: [],
    );
  }

  /// `Delete Prescription`
  String get dialog_delete_prescription {
    return Intl.message(
      'Delete Prescription',
      name: 'dialog_delete_prescription',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this {parameter} prescription?`
  String dialog_delete_prescription_confirm(String parameter) {
    return Intl.message(
      'Are you sure you want to delete this $parameter prescription?',
      name: 'dialog_delete_prescription_confirm',
      desc: '',
      args: [parameter],
    );
  }

  /// `Delete All Prescriptions`
  String get dialog_delete_all_prescriptions {
    return Intl.message(
      'Delete All Prescriptions',
      name: 'dialog_delete_all_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete ALL prescriptions? This action cannot be undone.`
  String get dialog_delete_all_prescriptions_confirm {
    return Intl.message(
      'Are you sure you want to delete ALL prescriptions? This action cannot be undone.',
      name: 'dialog_delete_all_prescriptions_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete Completed Prescriptions`
  String get dialog_delete_completed_prescriptions {
    return Intl.message(
      'Delete Completed Prescriptions',
      name: 'dialog_delete_completed_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete all completed prescriptions?`
  String get dialog_delete_completed_prescriptions_confirm {
    return Intl.message(
      'Are you sure you want to delete all completed prescriptions?',
      name: 'dialog_delete_completed_prescriptions_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Prescription marked as completed`
  String get status_prescription_completed {
    return Intl.message(
      'Prescription marked as completed',
      name: 'status_prescription_completed',
      desc: '',
      args: [],
    );
  }

  /// `Prescription marked as pending`
  String get status_prescription_pending {
    return Intl.message(
      'Prescription marked as pending',
      name: 'status_prescription_pending',
      desc: '',
      args: [],
    );
  }

  /// `Prescription deleted successfully`
  String get status_prescription_deleted {
    return Intl.message(
      'Prescription deleted successfully',
      name: 'status_prescription_deleted',
      desc: '',
      args: [],
    );
  }

  /// `All completed prescriptions deleted`
  String get status_all_completed_deleted {
    return Intl.message(
      'All completed prescriptions deleted',
      name: 'status_all_completed_deleted',
      desc: '',
      args: [],
    );
  }

  /// `All prescriptions deleted`
  String get status_all_deleted {
    return Intl.message(
      'All prescriptions deleted',
      name: 'status_all_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load prescriptions`
  String get error_load_prescriptions {
    return Intl.message(
      'Failed to load prescriptions',
      name: 'error_load_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Error updating prescription`
  String get error_update_prescription {
    return Intl.message(
      'Error updating prescription',
      name: 'error_update_prescription',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting prescription`
  String get error_delete_prescription {
    return Intl.message(
      'Error deleting prescription',
      name: 'error_delete_prescription',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting prescriptions`
  String get error_delete_prescriptions {
    return Intl.message(
      'Error deleting prescriptions',
      name: 'error_delete_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `No prescriptions found`
  String get empty_no_prescriptions {
    return Intl.message(
      'No prescriptions found',
      name: 'empty_no_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `No prescriptions found for "{filter}"`
  String empty_no_prescriptions_filter(String filter) {
    return Intl.message(
      'No prescriptions found for "$filter"',
      name: 'empty_no_prescriptions_filter',
      desc: '',
      args: [filter],
    );
  }

  /// `Soil pH`
  String get parameter_soil_ph {
    return Intl.message(
      'Soil pH',
      name: 'parameter_soil_ph',
      desc: '',
      args: [],
    );
  }

  /// `Soil Moisture`
  String get parameter_soil_moisture {
    return Intl.message(
      'Soil Moisture',
      name: 'parameter_soil_moisture',
      desc: '',
      args: [],
    );
  }

  /// `Temperature`
  String get parameter_temperature {
    return Intl.message(
      'Temperature',
      name: 'parameter_temperature',
      desc: '',
      args: [],
    );
  }

  /// `Humidity`
  String get parameter_humidity {
    return Intl.message(
      'Humidity',
      name: 'parameter_humidity',
      desc: '',
      args: [],
    );
  }

  /// `Light Intensity`
  String get parameter_light_intensity {
    return Intl.message(
      'Light Intensity',
      name: 'parameter_light_intensity',
      desc: '',
      args: [],
    );
  }

  /// `Delete prescription`
  String get tooltip_delete_prescription {
    return Intl.message(
      'Delete prescription',
      name: 'tooltip_delete_prescription',
      desc: '',
      args: [],
    );
  }

  /// `Refresh prescriptions`
  String get tooltip_refresh_prescriptions {
    return Intl.message(
      'Refresh prescriptions',
      name: 'tooltip_refresh_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get button_retry {
    return Intl.message('Retry', name: 'button_retry', desc: '', args: []);
  }

  /// `Apply fertilizer as recommended for optimal growth`
  String get recommendation_apply_fertilizer {
    return Intl.message(
      'Apply fertilizer as recommended for optimal growth',
      name: 'recommendation_apply_fertilizer',
      desc: '',
      args: [],
    );
  }

  /// `Adjust irrigation schedule based on soil moisture levels`
  String get recommendation_water {
    return Intl.message(
      'Adjust irrigation schedule based on soil moisture levels',
      name: 'recommendation_water',
      desc: '',
      args: [],
    );
  }

  /// `Monitor and maintain optimal temperature conditions`
  String get recommendation_temperature {
    return Intl.message(
      'Monitor and maintain optimal temperature conditions',
      name: 'recommendation_temperature',
      desc: '',
      args: [],
    );
  }

  /// `Adjust soil pH to recommended levels`
  String get recommendation_soil_ph {
    return Intl.message(
      'Adjust soil pH to recommended levels',
      name: 'recommendation_soil_ph',
      desc: '',
      args: [],
    );
  }

  /// `Ensure proper light exposure for healthy growth`
  String get recommendation_light {
    return Intl.message(
      'Ensure proper light exposure for healthy growth',
      name: 'recommendation_light',
      desc: '',
      args: [],
    );
  }

  /// `Text Size`
  String get textSizeLabel {
    return Intl.message('Text Size', name: 'textSizeLabel', desc: '', args: []);
  }

  /// `No internet connection. Please check your connection and try again.`
  String get error_no_internet {
    return Intl.message(
      'No internet connection. Please check your connection and try again.',
      name: 'error_no_internet',
      desc: '',
      args: [],
    );
  }

  /// `The server is taking too long to respond. Please try again later.`
  String get error_timeout {
    return Intl.message(
      'The server is taking too long to respond. Please try again later.',
      name: 'error_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Wrong username or password. Please check your credentials and try again.`
  String get error_invalid_credentials {
    return Intl.message(
      'Wrong username or password. Please check your credentials and try again.',
      name: 'error_invalid_credentials',
      desc: '',
      args: [],
    );
  }

  /// `There was a problem with the server. Please try again later.`
  String get error_server {
    return Intl.message(
      'There was a problem with the server. Please try again later.',
      name: 'error_server',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred. Please try again.`
  String get error_unknown {
    return Intl.message(
      'An unexpected error occurred. Please try again.',
      name: 'error_unknown',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Login Error`
  String get login_error {
    return Intl.message('Login Error', name: 'login_error', desc: '', args: []);
  }

  /// `Maize Watch Privacy Information`
  String get privacy_info_title {
    return Intl.message(
      'Maize Watch Privacy Information',
      name: 'privacy_info_title',
      desc: '',
      args: [],
    );
  }

  /// `At Maize Watch, we are committed to protecting the privacy of our users, particularly corn farmers who entrust us with their valuable agricultural data. This Privacy Information outlines how we collect, use, and protect your information when you use our platform.`
  String get privacy_info_intro {
    return Intl.message(
      'At Maize Watch, we are committed to protecting the privacy of our users, particularly corn farmers who entrust us with their valuable agricultural data. This Privacy Information outlines how we collect, use, and protect your information when you use our platform.',
      name: 'privacy_info_intro',
      desc: '',
      args: [],
    );
  }

  /// `1. Information We Collect:`
  String get privacy_info_section1_title {
    return Intl.message(
      '1. Information We Collect:',
      name: 'privacy_info_section1_title',
      desc: '',
      args: [],
    );
  }

  /// `To provide you with data-driven insights and optimize your corn yields, Maize Watch collects the following types of information:\n\nFarm-Specific Data: Location (GPS coordinates of fields), field size and boundaries, crop variety, planting/harvesting dates, and yield data.\nSensor Data: Soil moisture/nutrient levels, temperature (soil/ambient), humidity, light intensity, and other relevant environmental data.\nAccount Information: Your name, contact info, farm name/ID, and login credentials (encrypted).\nUsage Data: Features accessed, time spent, reports generated, and anonymized device info.`
  String get privacy_info_section1_content {
    return Intl.message(
      'To provide you with data-driven insights and optimize your corn yields, Maize Watch collects the following types of information:\n\nFarm-Specific Data: Location (GPS coordinates of fields), field size and boundaries, crop variety, planting/harvesting dates, and yield data.\nSensor Data: Soil moisture/nutrient levels, temperature (soil/ambient), humidity, light intensity, and other relevant environmental data.\nAccount Information: Your name, contact info, farm name/ID, and login credentials (encrypted).\nUsage Data: Features accessed, time spent, reports generated, and anonymized device info.',
      name: 'privacy_info_section1_content',
      desc: '',
      args: [],
    );
  }

  /// `2. How We Use Your Information:`
  String get privacy_info_section2_title {
    return Intl.message(
      '2. How We Use Your Information:',
      name: 'privacy_info_section2_title',
      desc: '',
      args: [],
    );
  }

  /// `To Provide Core Services: Visualize farm performance, analyze conditions, offer recommendations, and track progress.\nTo Improve Maize Watch: Enhance features, develop new tools, and improve models (often using anonymized data).\nFor Communication: Send updates, alerts, and respond to inquiries.\nFor Security: Ensure platform integrity, prevent fraud, and comply with legal duties.`
  String get privacy_info_section2_content {
    return Intl.message(
      'To Provide Core Services: Visualize farm performance, analyze conditions, offer recommendations, and track progress.\nTo Improve Maize Watch: Enhance features, develop new tools, and improve models (often using anonymized data).\nFor Communication: Send updates, alerts, and respond to inquiries.\nFor Security: Ensure platform integrity, prevent fraud, and comply with legal duties.',
      name: 'privacy_info_section2_content',
      desc: '',
      args: [],
    );
  }

  /// `3. Data Sharing and Disclosure:`
  String get privacy_info_section3_title {
    return Intl.message(
      '3. Data Sharing and Disclosure:',
      name: 'privacy_info_section3_title',
      desc: '',
      args: [],
    );
  }

  /// `With Your Consent: Data is shared only with parties you approve (e.g., consultants).\nService Providers: Only trusted providers under strict agreements.\nAggregated/Anonymized Data: Used for research or benchmarking without revealing identities.\nLegal Requirements: Disclosed only when legally necessary.`
  String get privacy_info_section3_content {
    return Intl.message(
      'With Your Consent: Data is shared only with parties you approve (e.g., consultants).\nService Providers: Only trusted providers under strict agreements.\nAggregated/Anonymized Data: Used for research or benchmarking without revealing identities.\nLegal Requirements: Disclosed only when legally necessary.',
      name: 'privacy_info_section3_content',
      desc: '',
      args: [],
    );
  }

  /// `4. Data Security:`
  String get privacy_info_section4_title {
    return Intl.message(
      '4. Data Security:',
      name: 'privacy_info_section4_title',
      desc: '',
      args: [],
    );
  }

  /// `Encryption (in transit & at rest)\nStrict access controls\nRegular security audits\nSecure data backups`
  String get privacy_info_section4_content {
    return Intl.message(
      'Encryption (in transit & at rest)\nStrict access controls\nRegular security audits\nSecure data backups',
      name: 'privacy_info_section4_content',
      desc: '',
      args: [],
    );
  }

  /// `5. Your Choices and Rights:`
  String get privacy_info_section5_title {
    return Intl.message(
      '5. Your Choices and Rights:',
      name: 'privacy_info_section5_title',
      desc: '',
      args: [],
    );
  }

  /// `Access, update, or correct your data anytime\nRequest a copy of your data (data portability)\nRequest data deletion (subject to legal retention)\nOpt-out of non-essential communications`
  String get privacy_info_section5_content {
    return Intl.message(
      'Access, update, or correct your data anytime\nRequest a copy of your data (data portability)\nRequest data deletion (subject to legal retention)\nOpt-out of non-essential communications',
      name: 'privacy_info_section5_content',
      desc: '',
      args: [],
    );
  }

  /// `6. Data Retention:`
  String get privacy_info_section6_title {
    return Intl.message(
      '6. Data Retention:',
      name: 'privacy_info_section6_title',
      desc: '',
      args: [],
    );
  }

  /// `Your data is retained while your account is active and for a reasonable period afterward to comply with obligations and ensure continuity.`
  String get privacy_info_section6_content {
    return Intl.message(
      'Your data is retained while your account is active and for a reasonable period afterward to comply with obligations and ensure continuity.',
      name: 'privacy_info_section6_content',
      desc: '',
      args: [],
    );
  }

  /// `7. Changes to This Privacy Information:`
  String get privacy_info_section7_title {
    return Intl.message(
      '7. Changes to This Privacy Information:',
      name: 'privacy_info_section7_title',
      desc: '',
      args: [],
    );
  }

  /// `Updates to this Privacy Information will be posted on our website or communicated appropriately. Please review it periodically.`
  String get privacy_info_section7_content {
    return Intl.message(
      'Updates to this Privacy Information will be posted on our website or communicated appropriately. Please review it periodically.',
      name: 'privacy_info_section7_content',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get terms_of_use {
    return Intl.message(
      'Terms of Use',
      name: 'terms_of_use',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Maize Watch. By accessing or using our platform, services, and related tools, you agree to comply with and be bound by these Terms of Use. If you do not agree with any part of these terms, please do not use Maize Watch.`
  String get terms_intro {
    return Intl.message(
      'Welcome to Maize Watch. By accessing or using our platform, services, and related tools, you agree to comply with and be bound by these Terms of Use. If you do not agree with any part of these terms, please do not use Maize Watch.',
      name: 'terms_intro',
      desc: '',
      args: [],
    );
  }

  /// `1. Use of the Platform:`
  String get terms_section1_title {
    return Intl.message(
      '1. Use of the Platform:',
      name: 'terms_section1_title',
      desc: '',
      args: [],
    );
  }

  /// `You may only use Maize Watch for lawful purposes and in accordance with these terms.\nYou are responsible for maintaining the confidentiality of your account credentials and all activities under your account.\nYou agree not to misuse the platform, interfere with its security or functionality, or attempt unauthorized access to any part of the system.`
  String get terms_section1_content {
    return Intl.message(
      'You may only use Maize Watch for lawful purposes and in accordance with these terms.\nYou are responsible for maintaining the confidentiality of your account credentials and all activities under your account.\nYou agree not to misuse the platform, interfere with its security or functionality, or attempt unauthorized access to any part of the system.',
      name: 'terms_section1_content',
      desc: '',
      args: [],
    );
  }

  /// `2. Data Ownership and Usage:`
  String get terms_section2_title {
    return Intl.message(
      '2. Data Ownership and Usage:',
      name: 'terms_section2_title',
      desc: '',
      args: [],
    );
  }

  /// `You retain full ownership of your farm data and sensor information.\nBy using Maize Watch, you grant us permission to analyze your data to provide personalized insights and improve platform performance.\nWe will not share your identifiable data without your explicit consent, as outlined in our Privacy Policy.`
  String get terms_section2_content {
    return Intl.message(
      'You retain full ownership of your farm data and sensor information.\nBy using Maize Watch, you grant us permission to analyze your data to provide personalized insights and improve platform performance.\nWe will not share your identifiable data without your explicit consent, as outlined in our Privacy Policy.',
      name: 'terms_section2_content',
      desc: '',
      args: [],
    );
  }

  /// `3. Intellectual Property:`
  String get terms_section3_title {
    return Intl.message(
      '3. Intellectual Property:',
      name: 'terms_section3_title',
      desc: '',
      args: [],
    );
  }

  /// `All content on Maize Watch, including visualizations, software, text, graphics, and logos, is the property of Maize Watch or its licensors.\nYou may not reproduce, distribute, modify, or create derivative works without our written permission.`
  String get terms_section3_content {
    return Intl.message(
      'All content on Maize Watch, including visualizations, software, text, graphics, and logos, is the property of Maize Watch or its licensors.\nYou may not reproduce, distribute, modify, or create derivative works without our written permission.',
      name: 'terms_section3_content',
      desc: '',
      args: [],
    );
  }

  /// `4. Account Termination:`
  String get terms_section4_title {
    return Intl.message(
      '4. Account Termination:',
      name: 'terms_section4_title',
      desc: '',
      args: [],
    );
  }

  /// `We reserve the right to suspend or terminate your access to Maize Watch at any time if you violate these terms, abuse the platform, or engage in any behavior that disrupts service for other users.`
  String get terms_section4_content {
    return Intl.message(
      'We reserve the right to suspend or terminate your access to Maize Watch at any time if you violate these terms, abuse the platform, or engage in any behavior that disrupts service for other users.',
      name: 'terms_section4_content',
      desc: '',
      args: [],
    );
  }

  /// `5. Disclaimers:`
  String get terms_section5_title {
    return Intl.message(
      '5. Disclaimers:',
      name: 'terms_section5_title',
      desc: '',
      args: [],
    );
  }

  /// `Maize Watch provides data-based insights to support agricultural decisions. Final decisions regarding farming practices remain your responsibility.\nWe do not guarantee specific yield outcomes or profitability as agricultural success depends on many uncontrollable factors.\nThe platform is provided “as-is” and “as available” without warranties of any kind.`
  String get terms_section5_content {
    return Intl.message(
      'Maize Watch provides data-based insights to support agricultural decisions. Final decisions regarding farming practices remain your responsibility.\nWe do not guarantee specific yield outcomes or profitability as agricultural success depends on many uncontrollable factors.\nThe platform is provided “as-is” and “as available” without warranties of any kind.',
      name: 'terms_section5_content',
      desc: '',
      args: [],
    );
  }

  /// `6. Limitation of Liability:`
  String get terms_section6_title {
    return Intl.message(
      '6. Limitation of Liability:',
      name: 'terms_section6_title',
      desc: '',
      args: [],
    );
  }

  /// `To the extent permitted by law, Maize Watch shall not be liable for any indirect, incidental, or consequential damages arising from your use of the platform, including data loss, yield loss, or farm-related decisions made based on our analytics.`
  String get terms_section6_content {
    return Intl.message(
      'To the extent permitted by law, Maize Watch shall not be liable for any indirect, incidental, or consequential damages arising from your use of the platform, including data loss, yield loss, or farm-related decisions made based on our analytics.',
      name: 'terms_section6_content',
      desc: '',
      args: [],
    );
  }

  /// `7. Updates to the Terms:`
  String get terms_section7_title {
    return Intl.message(
      '7. Updates to the Terms:',
      name: 'terms_section7_title',
      desc: '',
      args: [],
    );
  }

  /// `We may update these Terms of Use from time to time. Material changes will be communicated through our platform or via email. Continued use of Maize Watch means you accept the updated terms.`
  String get terms_section7_content {
    return Intl.message(
      'We may update these Terms of Use from time to time. Material changes will be communicated through our platform or via email. Continued use of Maize Watch means you accept the updated terms.',
      name: 'terms_section7_content',
      desc: '',
      args: [],
    );
  }

  /// `First name must be at least 2 characters long`
  String get first_name_too_short {
    return Intl.message(
      'First name must be at least 2 characters long',
      name: 'first_name_too_short',
      desc: '',
      args: [],
    );
  }

  /// `First name must not exceed 50 characters`
  String get first_name_too_long {
    return Intl.message(
      'First name must not exceed 50 characters',
      name: 'first_name_too_long',
      desc: '',
      args: [],
    );
  }

  /// `First name can only contain letters, spaces, hyphens, apostrophes, and periods`
  String get first_name_invalid_characters {
    return Intl.message(
      'First name can only contain letters, spaces, hyphens, apostrophes, and periods',
      name: 'first_name_invalid_characters',
      desc: '',
      args: [],
    );
  }

  /// `First name cannot start or end with special characters`
  String get first_name_invalid_format {
    return Intl.message(
      'First name cannot start or end with special characters',
      name: 'first_name_invalid_format',
      desc: '',
      args: [],
    );
  }

  /// `First name cannot have consecutive special characters`
  String get first_name_consecutive_special {
    return Intl.message(
      'First name cannot have consecutive special characters',
      name: 'first_name_consecutive_special',
      desc: '',
      args: [],
    );
  }

  /// `Last name must be at least 2 characters long`
  String get last_name_too_short {
    return Intl.message(
      'Last name must be at least 2 characters long',
      name: 'last_name_too_short',
      desc: '',
      args: [],
    );
  }

  /// `Last name must not exceed 50 characters`
  String get last_name_too_long {
    return Intl.message(
      'Last name must not exceed 50 characters',
      name: 'last_name_too_long',
      desc: '',
      args: [],
    );
  }

  /// `Last name can only contain letters, spaces, hyphens, apostrophes, and periods`
  String get last_name_invalid_characters {
    return Intl.message(
      'Last name can only contain letters, spaces, hyphens, apostrophes, and periods',
      name: 'last_name_invalid_characters',
      desc: '',
      args: [],
    );
  }

  /// `Last name cannot start or end with special characters`
  String get last_name_invalid_format {
    return Intl.message(
      'Last name cannot start or end with special characters',
      name: 'last_name_invalid_format',
      desc: '',
      args: [],
    );
  }

  /// `Last name cannot have consecutive special characters`
  String get last_name_consecutive_special {
    return Intl.message(
      'Last name cannot have consecutive special characters',
      name: 'last_name_consecutive_special',
      desc: '',
      args: [],
    );
  }

  /// `Contact number must be exactly 10 digits (without +63)`
  String get contact_number_invalid_length {
    return Intl.message(
      'Contact number must be exactly 10 digits (without +63)',
      name: 'contact_number_invalid_length',
      desc: '',
      args: [],
    );
  }

  /// `Contact number must start with 9`
  String get contact_number_invalid_format {
    return Intl.message(
      'Contact number must start with 9',
      name: 'contact_number_invalid_format',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Philippine mobile number prefix`
  String get contact_number_invalid_prefix {
    return Intl.message(
      'Invalid Philippine mobile number prefix',
      name: 'contact_number_invalid_prefix',
      desc: '',
      args: [],
    );
  }

  /// `Address must be at least 10 characters long`
  String get address_too_short {
    return Intl.message(
      'Address must be at least 10 characters long',
      name: 'address_too_short',
      desc: '',
      args: [],
    );
  }

  /// `Address must not exceed 200 characters`
  String get address_too_long {
    return Intl.message(
      'Address must not exceed 200 characters',
      name: 'address_too_long',
      desc: '',
      args: [],
    );
  }

  /// `Address contains invalid characters`
  String get address_invalid_characters {
    return Intl.message(
      'Address contains invalid characters',
      name: 'address_invalid_characters',
      desc: '',
      args: [],
    );
  }

  /// `Address must contain at least one letter or number`
  String get address_needs_alphanumeric {
    return Intl.message(
      'Address must contain at least one letter or number',
      name: 'address_needs_alphanumeric',
      desc: '',
      args: [],
    );
  }

  /// `Username must not exceed 20 characters`
  String get username_too_long {
    return Intl.message(
      'Username must not exceed 20 characters',
      name: 'username_too_long',
      desc: '',
      args: [],
    );
  }

  /// `Username can only contain letters, numbers, underscores, and periods`
  String get username_invalid_characters {
    return Intl.message(
      'Username can only contain letters, numbers, underscores, and periods',
      name: 'username_invalid_characters',
      desc: '',
      args: [],
    );
  }

  /// `Username must start with a letter or number`
  String get username_invalid_start {
    return Intl.message(
      'Username must start with a letter or number',
      name: 'username_invalid_start',
      desc: '',
      args: [],
    );
  }

  /// `Username must end with a letter or number`
  String get username_invalid_end {
    return Intl.message(
      'Username must end with a letter or number',
      name: 'username_invalid_end',
      desc: '',
      args: [],
    );
  }

  /// `Username cannot have consecutive periods or underscores`
  String get username_consecutive_special {
    return Intl.message(
      'Username cannot have consecutive periods or underscores',
      name: 'username_consecutive_special',
      desc: '',
      args: [],
    );
  }

  /// `Password must not exceed 128 characters`
  String get password_too_long {
    return Intl.message(
      'Password must not exceed 128 characters',
      name: 'password_too_long',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one uppercase letter`
  String get password_needs_uppercase {
    return Intl.message(
      'Password must contain at least one uppercase letter',
      name: 'password_needs_uppercase',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one lowercase letter`
  String get password_needs_lowercase {
    return Intl.message(
      'Password must contain at least one lowercase letter',
      name: 'password_needs_lowercase',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one number`
  String get password_needs_number {
    return Intl.message(
      'Password must contain at least one number',
      name: 'password_needs_number',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one special character (!@#$%^&*)`
  String get password_needs_special {
    return Intl.message(
      'Password must contain at least one special character (!@#\$%^&*)',
      name: 'password_needs_special',
      desc: '',
      args: [],
    );
  }

  /// `This password is too common. Please choose a stronger password`
  String get password_too_common {
    return Intl.message(
      'This password is too common. Please choose a stronger password',
      name: 'password_too_common',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get confirm_password_required {
    return Intl.message(
      'Please confirm your password',
      name: 'confirm_password_required',
      desc: '',
      args: [],
    );
  }

  /// `Region`
  String get region {
    return Intl.message('Region', name: 'region', desc: '', args: []);
  }

  /// `Select your region`
  String get select_region {
    return Intl.message(
      'Select your region',
      name: 'select_region',
      desc: '',
      args: [],
    );
  }

  /// `Province`
  String get province {
    return Intl.message('Province', name: 'province', desc: '', args: []);
  }

  /// `Select your province`
  String get select_province {
    return Intl.message(
      'Select your province',
      name: 'select_province',
      desc: '',
      args: [],
    );
  }

  /// `Municipality`
  String get municipality {
    return Intl.message(
      'Municipality',
      name: 'municipality',
      desc: '',
      args: [],
    );
  }

  /// `Select your municipality`
  String get select_municipality {
    return Intl.message(
      'Select your municipality',
      name: 'select_municipality',
      desc: '',
      args: [],
    );
  }

  /// `Barangay`
  String get barangay {
    return Intl.message('Barangay', name: 'barangay', desc: '', args: []);
  }

  /// `Select your barangay`
  String get select_barangay {
    return Intl.message(
      'Select your barangay',
      name: 'select_barangay',
      desc: '',
      args: [],
    );
  }

  /// `Zip Code`
  String get zip_code {
    return Intl.message('Zip Code', name: 'zip_code', desc: '', args: []);
  }

  /// `Zip Code (Optional)`
  String get zip_code_optional {
    return Intl.message(
      'Zip Code (Optional)',
      name: 'zip_code_optional',
      desc: '',
      args: [],
    );
  }

  /// `Region is required`
  String get region_required {
    return Intl.message(
      'Region is required',
      name: 'region_required',
      desc: '',
      args: [],
    );
  }

  /// `Province is required`
  String get province_required {
    return Intl.message(
      'Province is required',
      name: 'province_required',
      desc: '',
      args: [],
    );
  }

  /// `Municipality is required`
  String get municipality_required {
    return Intl.message(
      'Municipality is required',
      name: 'municipality_required',
      desc: '',
      args: [],
    );
  }

  /// `Barangay is required`
  String get barangay_required {
    return Intl.message(
      'Barangay is required',
      name: 'barangay_required',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid zip code`
  String get zip_code_invalid {
    return Intl.message(
      'Please enter a valid zip code',
      name: 'zip_code_invalid',
      desc: '',
      args: [],
    );
  }

  /// `CALABARZON (Region IV-A)`
  String get region_calabarzon {
    return Intl.message(
      'CALABARZON (Region IV-A)',
      name: 'region_calabarzon',
      desc: '',
      args: [],
    );
  }

  /// `Cavite`
  String get province_cavite {
    return Intl.message('Cavite', name: 'province_cavite', desc: '', args: []);
  }

  /// `Amadeo`
  String get municipality_amadeo {
    return Intl.message(
      'Amadeo',
      name: 'municipality_amadeo',
      desc: '',
      args: [],
    );
  }

  /// `Enter Barangay`
  String get enter_barangay {
    return Intl.message(
      'Enter Barangay',
      name: 'enter_barangay',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get reset_password {
    return Intl.message(
      'Reset Password',
      name: 'reset_password',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phone_number {
    return Intl.message(
      'Phone Number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Verification Code`
  String get verification_code {
    return Intl.message(
      'Verification Code',
      name: 'verification_code',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Send Verification Code`
  String get send_verification_code {
    return Intl.message(
      'Send Verification Code',
      name: 'send_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Password reset successfully!`
  String get password_reset_successful {
    return Intl.message(
      'Password reset successfully!',
      name: 'password_reset_successful',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent to your phone number`
  String get verification_code_sent {
    return Intl.message(
      'Verification code sent to your phone number',
      name: 'verification_code_sent',
      desc: '',
      args: [],
    );
  }

  /// `Phone number is required`
  String get phone_number_required {
    return Intl.message(
      'Phone number is required',
      name: 'phone_number_required',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number`
  String get phone_number_invalid {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'phone_number_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Verification code is required`
  String get verification_code_required {
    return Intl.message(
      'Verification code is required',
      name: 'verification_code_required',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid 6-digit code`
  String get verification_code_invalid {
    return Intl.message(
      'Please enter a valid 6-digit code',
      name: 'verification_code_invalid',
      desc: '',
      args: [],
    );
  }

  /// `New password is required`
  String get new_password_required {
    return Intl.message(
      'New password is required',
      name: 'new_password_required',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get password_min_length {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'password_min_length',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwords_do_not_match {
    return Intl.message(
      'Passwords do not match',
      name: 'passwords_do_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Please check your connection.`
  String get network_error {
    return Intl.message(
      'Network error. Please check your connection.',
      name: 'network_error',
      desc: '',
      args: [],
    );
  }

  /// `Notification Settings`
  String get notification_settings {
    return Intl.message(
      'Notification Settings',
      name: 'notification_settings',
      desc: '',
      args: [],
    );
  }

  /// `Get alerts for farm updates, weather warnings, and sensor issues`
  String get notification_description {
    return Intl.message(
      'Get alerts for farm updates, weather warnings, and sensor issues',
      name: 'notification_description',
      desc: '',
      args: [],
    );
  }

  /// `Silent notifications with vibration only`
  String get vibration_only_description {
    return Intl.message(
      'Silent notifications with vibration only',
      name: 'vibration_only_description',
      desc: '',
      args: [],
    );
  }

  /// `Notification Types`
  String get notification_types {
    return Intl.message(
      'Notification Types',
      name: 'notification_types',
      desc: '',
      args: [],
    );
  }

  /// `Farm Alerts`
  String get farm_alerts {
    return Intl.message('Farm Alerts', name: 'farm_alerts', desc: '', args: []);
  }

  /// `Weather warnings, irrigation alerts, and crop health updates`
  String get farm_alerts_description {
    return Intl.message(
      'Weather warnings, irrigation alerts, and crop health updates',
      name: 'farm_alerts_description',
      desc: '',
      args: [],
    );
  }

  /// `Sensor Status`
  String get sensor_status {
    return Intl.message(
      'Sensor Status',
      name: 'sensor_status',
      desc: '',
      args: [],
    );
  }

  /// `Alerts when sensors go offline or need maintenance`
  String get sensor_status_description {
    return Intl.message(
      'Alerts when sensors go offline or need maintenance',
      name: 'sensor_status_description',
      desc: '',
      args: [],
    );
  }

  /// `Prescription Updates`
  String get prescription_updates {
    return Intl.message(
      'Prescription Updates',
      name: 'prescription_updates',
      desc: '',
      args: [],
    );
  }

  /// `New farm recommendations and treatment suggestions`
  String get prescription_updates_description {
    return Intl.message(
      'New farm recommendations and treatment suggestions',
      name: 'prescription_updates_description',
      desc: '',
      args: [],
    );
  }

  /// `Edit Settings`
  String get edit_settings {
    return Intl.message(
      'Edit Settings',
      name: 'edit_settings',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Saving...`
  String get saving {
    return Intl.message('Saving...', name: 'saving', desc: '', args: []);
  }

  /// `Notification settings updated successfully!`
  String get notification_settings_updated {
    return Intl.message(
      'Notification settings updated successfully!',
      name: 'notification_settings_updated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update notification settings: {error}`
  String notification_settings_failed(Object error) {
    return Intl.message(
      'Failed to update notification settings: $error',
      name: 'notification_settings_failed',
      desc: '',
      args: [error],
    );
  }

  /// `Check Notification Status`
  String get check_notification_status {
    return Intl.message(
      'Check Notification Status',
      name: 'check_notification_status',
      desc: '',
      args: [],
    );
  }

  /// `Debug Section`
  String get debug_section {
    return Intl.message(
      'Debug Section',
      name: 'debug_section',
      desc: '',
      args: [],
    );
  }

  /// `Notifications enabled: {enabled}`
  String notifications_enabled(Object enabled) {
    return Intl.message(
      'Notifications enabled: $enabled',
      name: 'notifications_enabled',
      desc: '',
      args: [enabled],
    );
  }

  /// `Urgent`
  String get urgent {
    return Intl.message('Urgent', name: 'urgent', desc: '', args: []);
  }

  /// `Medium`
  String get medium {
    return Intl.message('Medium', name: 'medium', desc: '', args: []);
  }

  /// `Prescription Alert`
  String get prescription_alert {
    return Intl.message(
      'Prescription Alert',
      name: 'prescription_alert',
      desc: '',
      args: [],
    );
  }

  /// `Sensor Offline`
  String get sensor_offline {
    return Intl.message(
      'Sensor Offline',
      name: 'sensor_offline',
      desc: '',
      args: [],
    );
  }

  /// `Sensors in Sleep Mode`
  String get sensor_sleep_mode {
    return Intl.message(
      'Sensors in Sleep Mode',
      name: 'sensor_sleep_mode',
      desc: '',
      args: [],
    );
  }

  /// `Your sensors are now sleeping from 8pm to 3am PH time. They will wake up at 3am.`
  String get sensor_sleep_description {
    return Intl.message(
      'Your sensors are now sleeping from 8pm to 3am PH time. They will wake up at 3am.',
      name: 'sensor_sleep_description',
      desc: '',
      args: [],
    );
  }

  /// `{sensorName} sensor has been offline for more than 30 minutes.`
  String sensor_offline_description(Object sensorName) {
    return Intl.message(
      '$sensorName sensor has been offline for more than 30 minutes.',
      name: 'sensor_offline_description',
      desc: '',
      args: [sensorName],
    );
  }

  /// `Farm Task`
  String get farm_task {
    return Intl.message('Farm Task', name: 'farm_task', desc: '', args: []);
  }

  /// `Check Farm`
  String get check_farm {
    return Intl.message('Check Farm', name: 'check_farm', desc: '', args: []);
  }

  /// `Irrigation`
  String get irrigation {
    return Intl.message('Irrigation', name: 'irrigation', desc: '', args: []);
  }

  /// `Fertilization`
  String get fertilization {
    return Intl.message(
      'Fertilization',
      name: 'fertilization',
      desc: '',
      args: [],
    );
  }

  /// `Pest Control`
  String get pest_control {
    return Intl.message(
      'Pest Control',
      name: 'pest_control',
      desc: '',
      args: [],
    );
  }

  /// `Harvest`
  String get harvest {
    return Intl.message('Harvest', name: 'harvest', desc: '', args: []);
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Farm Prescriptions`
  String get farm_prescriptions {
    return Intl.message(
      'Farm Prescriptions',
      name: 'farm_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `View and complete your farm prescriptions`
  String get view_complete_prescriptions {
    return Intl.message(
      'View and complete your farm prescriptions',
      name: 'view_complete_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Overdue`
  String get overdue {
    return Intl.message('Overdue', name: 'overdue', desc: '', args: []);
  }

  /// `{hours}h left`
  String hours_left(Object hours) {
    return Intl.message(
      '${hours}h left',
      name: 'hours_left',
      desc: '',
      args: [hours],
    );
  }

  /// `{days}d left`
  String days_left(Object days) {
    return Intl.message(
      '${days}d left',
      name: 'days_left',
      desc: '',
      args: [days],
    );
  }

  /// `Sent`
  String get sent {
    return Intl.message('Sent', name: 'sent', desc: '', args: []);
  }

  /// `Deadline`
  String get deadline {
    return Intl.message('Deadline', name: 'deadline', desc: '', args: []);
  }

  /// `Field`
  String get field {
    return Intl.message('Field', name: 'field', desc: '', args: []);
  }

  /// `Instructions`
  String get instructions {
    return Intl.message(
      'Instructions',
      name: 'instructions',
      desc: '',
      args: [],
    );
  }

  /// `Materials Needed`
  String get materials_needed {
    return Intl.message(
      'Materials Needed',
      name: 'materials_needed',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Duration`
  String get estimated_duration {
    return Intl.message(
      'Estimated Duration',
      name: 'estimated_duration',
      desc: '',
      args: [],
    );
  }

  /// `Priority`
  String get priority {
    return Intl.message('Priority', name: 'priority', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `In Progress`
  String get in_progress {
    return Intl.message('In Progress', name: 'in_progress', desc: '', args: []);
  }

  /// `Not Started`
  String get not_started {
    return Intl.message('Not Started', name: 'not_started', desc: '', args: []);
  }

  /// `Mark as Complete`
  String get mark_as_complete {
    return Intl.message(
      'Mark as Complete',
      name: 'mark_as_complete',
      desc: '',
      args: [],
    );
  }

  /// `No prescriptions found`
  String get no_prescriptions_found {
    return Intl.message(
      'No prescriptions found',
      name: 'no_prescriptions_found',
      desc: '',
      args: [],
    );
  }

  /// `Loading prescriptions...`
  String get loading_prescriptions {
    return Intl.message(
      'Loading prescriptions...',
      name: 'loading_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Error loading prescriptions`
  String get error_loading_prescriptions {
    return Intl.message(
      'Error loading prescriptions',
      name: 'error_loading_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Prescription Details`
  String get prescription_details {
    return Intl.message(
      'Prescription Details',
      name: 'prescription_details',
      desc: '',
      args: [],
    );
  }

  /// `Back to Prescriptions`
  String get back_to_prescriptions {
    return Intl.message(
      'Back to Prescriptions',
      name: 'back_to_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Maize Watch Notifications`
  String get maize_watch_notifications {
    return Intl.message(
      'Maize Watch Notifications',
      name: 'maize_watch_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Notifications for farm monitoring and alerts`
  String get notifications_for_farm_monitoring {
    return Intl.message(
      'Notifications for farm monitoring and alerts',
      name: 'notifications_for_farm_monitoring',
      desc: '',
      args: [],
    );
  }

  /// `Immediate`
  String get immediate {
    return Intl.message('Immediate', name: 'immediate', desc: '', args: []);
  }

  /// `High Priority`
  String get high_priority {
    return Intl.message(
      'High Priority',
      name: 'high_priority',
      desc: '',
      args: [],
    );
  }

  /// `Medium Priority`
  String get medium_priority {
    return Intl.message(
      'Medium Priority',
      name: 'medium_priority',
      desc: '',
      args: [],
    );
  }

  /// `Low Priority`
  String get low_priority {
    return Intl.message(
      'Low Priority',
      name: 'low_priority',
      desc: '',
      args: [],
    );
  }

  /// `New prescription available`
  String get new_prescription_available {
    return Intl.message(
      'New prescription available',
      name: 'new_prescription_available',
      desc: '',
      args: [],
    );
  }

  /// `Sensor offline alert`
  String get sensor_offline_alert {
    return Intl.message(
      'Sensor offline alert',
      name: 'sensor_offline_alert',
      desc: '',
      args: [],
    );
  }

  /// `Sensors in sleep mode`
  String get sensor_sleep_mode_alert {
    return Intl.message(
      'Sensors in sleep mode',
      name: 'sensor_sleep_mode_alert',
      desc: '',
      args: [],
    );
  }

  /// `Farm Alert`
  String get farm_alert {
    return Intl.message('Farm Alert', name: 'farm_alert', desc: '', args: []);
  }

  /// `Sensor Alert`
  String get sensor_alert {
    return Intl.message(
      'Sensor Alert',
      name: 'sensor_alert',
      desc: '',
      args: [],
    );
  }

  /// `Tap to view`
  String get tap_to_view {
    return Intl.message('Tap to view', name: 'tap_to_view', desc: '', args: []);
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message('Dismiss', name: 'dismiss', desc: '', args: []);
  }

  /// `View All`
  String get view_all {
    return Intl.message('View All', name: 'view_all', desc: '', args: []);
  }

  /// `Notification Sound`
  String get notification_sound {
    return Intl.message(
      'Notification Sound',
      name: 'notification_sound',
      desc: '',
      args: [],
    );
  }

  /// `Notification Vibration`
  String get notification_vibration {
    return Intl.message(
      'Notification Vibration',
      name: 'notification_vibration',
      desc: '',
      args: [],
    );
  }

  /// `Notification Badge`
  String get notification_badge {
    return Intl.message(
      'Notification Badge',
      name: 'notification_badge',
      desc: '',
      args: [],
    );
  }

  /// `Quiet Hours`
  String get quiet_hours {
    return Intl.message('Quiet Hours', name: 'quiet_hours', desc: '', args: []);
  }

  /// `From`
  String get from {
    return Intl.message('From', name: 'from', desc: '', args: []);
  }

  /// `To`
  String get to {
    return Intl.message('To', name: 'to', desc: '', args: []);
  }

  /// `Test Notification`
  String get test_notification {
    return Intl.message(
      'Test Notification',
      name: 'test_notification',
      desc: '',
      args: [],
    );
  }

  /// `Notification test successful!`
  String get notification_test_successful {
    return Intl.message(
      'Notification test successful!',
      name: 'notification_test_successful',
      desc: '',
      args: [],
    );
  }

  /// `Notification test failed`
  String get notification_test_failed {
    return Intl.message(
      'Notification test failed',
      name: 'notification_test_failed',
      desc: '',
      args: [],
    );
  }

  /// `Permission Required`
  String get permission_required {
    return Intl.message(
      'Permission Required',
      name: 'permission_required',
      desc: '',
      args: [],
    );
  }

  /// `Notification permission is required to receive alerts`
  String get notification_permission_required {
    return Intl.message(
      'Notification permission is required to receive alerts',
      name: 'notification_permission_required',
      desc: '',
      args: [],
    );
  }

  /// `Go to Settings`
  String get go_to_settings {
    return Intl.message(
      'Go to Settings',
      name: 'go_to_settings',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `This week`
  String get this_week {
    return Intl.message('This week', name: 'this_week', desc: '', args: []);
  }

  /// `Last week`
  String get last_week {
    return Intl.message('Last week', name: 'last_week', desc: '', args: []);
  }

  /// `This month`
  String get this_month {
    return Intl.message('This month', name: 'this_month', desc: '', args: []);
  }

  /// `Last month`
  String get last_month {
    return Intl.message('Last month', name: 'last_month', desc: '', args: []);
  }

  /// `Jan`
  String get jan {
    return Intl.message('Jan', name: 'jan', desc: '', args: []);
  }

  /// `Feb`
  String get feb {
    return Intl.message('Feb', name: 'feb', desc: '', args: []);
  }

  /// `Mar`
  String get mar {
    return Intl.message('Mar', name: 'mar', desc: '', args: []);
  }

  /// `Apr`
  String get apr {
    return Intl.message('Apr', name: 'apr', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `Jun`
  String get jun {
    return Intl.message('Jun', name: 'jun', desc: '', args: []);
  }

  /// `Jul`
  String get jul {
    return Intl.message('Jul', name: 'jul', desc: '', args: []);
  }

  /// `Aug`
  String get aug {
    return Intl.message('Aug', name: 'aug', desc: '', args: []);
  }

  /// `Sep`
  String get sep {
    return Intl.message('Sep', name: 'sep', desc: '', args: []);
  }

  /// `Oct`
  String get oct {
    return Intl.message('Oct', name: 'oct', desc: '', args: []);
  }

  /// `Nov`
  String get nov {
    return Intl.message('Nov', name: 'nov', desc: '', args: []);
  }

  /// `Dec`
  String get dec {
    return Intl.message('Dec', name: 'dec', desc: '', args: []);
  }

  /// `Monday`
  String get monday {
    return Intl.message('Monday', name: 'monday', desc: '', args: []);
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message('Tuesday', name: 'tuesday', desc: '', args: []);
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message('Wednesday', name: 'wednesday', desc: '', args: []);
  }

  /// `Thursday`
  String get thursday {
    return Intl.message('Thursday', name: 'thursday', desc: '', args: []);
  }

  /// `Friday`
  String get friday {
    return Intl.message('Friday', name: 'friday', desc: '', args: []);
  }

  /// `Saturday`
  String get saturday {
    return Intl.message('Saturday', name: 'saturday', desc: '', args: []);
  }

  /// `Sunday`
  String get sunday {
    return Intl.message('Sunday', name: 'sunday', desc: '', args: []);
  }

  /// `No pending tasks found`
  String get no_pending_tasks_found {
    return Intl.message(
      'No pending tasks found',
      name: 'no_pending_tasks_found',
      desc: '',
      args: [],
    );
  }

  /// `No urgent tasks found`
  String get no_urgent_tasks_found {
    return Intl.message(
      'No urgent tasks found',
      name: 'no_urgent_tasks_found',
      desc: '',
      args: [],
    );
  }

  /// `No farm tasks available`
  String get no_farm_tasks_available {
    return Intl.message(
      'No farm tasks available',
      name: 'no_farm_tasks_available',
      desc: '',
      args: [],
    );
  }

  /// `Follow recommended actions`
  String get follow_recommended_actions {
    return Intl.message(
      'Follow recommended actions',
      name: 'follow_recommended_actions',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Field`
  String get unknown_field {
    return Intl.message(
      'Unknown Field',
      name: 'unknown_field',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Now`
  String get now {
    return Intl.message('Now', name: 'now', desc: '', args: []);
  }

  /// `Filter Prescriptions`
  String get filter_prescriptions {
    return Intl.message(
      'Filter Prescriptions',
      name: 'filter_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Urgency`
  String get urgency {
    return Intl.message('Urgency', name: 'urgency', desc: '', args: []);
  }

  /// `Urgent`
  String get urgency_urgent {
    return Intl.message('Urgent', name: 'urgency_urgent', desc: '', args: []);
  }

  /// `High`
  String get urgency_high {
    return Intl.message('High', name: 'urgency_high', desc: '', args: []);
  }

  /// `Medium`
  String get urgency_medium {
    return Intl.message('Medium', name: 'urgency_medium', desc: '', args: []);
  }

  /// `Low`
  String get urgency_low {
    return Intl.message('Low', name: 'urgency_low', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Irrigation`
  String get category_irrigation {
    return Intl.message(
      'Irrigation',
      name: 'category_irrigation',
      desc: '',
      args: [],
    );
  }

  /// `Humidity Management`
  String get category_humidity_management {
    return Intl.message(
      'Humidity Management',
      name: 'category_humidity_management',
      desc: '',
      args: [],
    );
  }

  /// `Soil Treatment`
  String get category_soil_treatment {
    return Intl.message(
      'Soil Treatment',
      name: 'category_soil_treatment',
      desc: '',
      args: [],
    );
  }

  /// `Temperature Management`
  String get category_temperature_management {
    return Intl.message(
      'Temperature Management',
      name: 'category_temperature_management',
      desc: '',
      args: [],
    );
  }

  /// `Light Management`
  String get category_light_management {
    return Intl.message(
      'Light Management',
      name: 'category_light_management',
      desc: '',
      args: [],
    );
  }

  /// `Timeline`
  String get timeline {
    return Intl.message('Timeline', name: 'timeline', desc: '', args: []);
  }

  /// `Today`
  String get timeline_today {
    return Intl.message('Today', name: 'timeline_today', desc: '', args: []);
  }

  /// `This Week`
  String get timeline_this_week {
    return Intl.message(
      'This Week',
      name: 'timeline_this_week',
      desc: '',
      args: [],
    );
  }

  /// `Next Week`
  String get timeline_next_week {
    return Intl.message(
      'Next Week',
      name: 'timeline_next_week',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clear_all {
    return Intl.message('Clear All', name: 'clear_all', desc: '', args: []);
  }

  /// `New Farm Prescriptions`
  String get new_farm_prescriptions {
    return Intl.message(
      'New Farm Prescriptions',
      name: 'new_farm_prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `You have {count} new farm tasks to complete`
  String you_have_new_farm_tasks(int count) {
    return Intl.message(
      'You have $count new farm tasks to complete',
      name: 'you_have_new_farm_tasks',
      desc: '',
      args: [count],
    );
  }

  /// `Unknown Sensor`
  String get unknown_sensor {
    return Intl.message(
      'Unknown Sensor',
      name: 'unknown_sensor',
      desc: '',
      args: [],
    );
  }

  /// `Partly Cloudy`
  String get partly_cloudy {
    return Intl.message(
      'Partly Cloudy',
      name: 'partly_cloudy',
      desc: '',
      args: [],
    );
  }

  /// `Partly cloudy`
  String get partly_cloudy_description {
    return Intl.message(
      'Partly cloudy',
      name: 'partly_cloudy_description',
      desc: '',
      args: [],
    );
  }

  /// `My Farm`
  String get my_farm {
    return Intl.message('My Farm', name: 'my_farm', desc: '', args: []);
  }

  /// `ASAP`
  String get asap {
    return Intl.message('ASAP', name: 'asap', desc: '', args: []);
  }

  /// `Loading farm tasks...`
  String get loading_farm_tasks {
    return Intl.message(
      'Loading farm tasks...',
      name: 'loading_farm_tasks',
      desc: '',
      args: [],
    );
  }

  /// `Filtered by: {filters}`
  String filtered_by(Object filters) {
    return Intl.message(
      'Filtered by: $filters',
      name: 'filtered_by',
      desc: '',
      args: [filters],
    );
  }

  /// `Urgency: {urgency}`
  String urgency_filter(Object urgency) {
    return Intl.message(
      'Urgency: $urgency',
      name: 'urgency_filter',
      desc: '',
      args: [urgency],
    );
  }

  /// `Category: {category}`
  String category_filter(Object category) {
    return Intl.message(
      'Category: $category',
      name: 'category_filter',
      desc: '',
      args: [category],
    );
  }

  /// `Timeline: {timeline}`
  String timeline_filter(Object timeline) {
    return Intl.message(
      'Timeline: $timeline',
      name: 'timeline_filter',
      desc: '',
      args: [timeline],
    );
  }

  /// `Step-by-Step Instructions ({count} steps)`
  String step_by_step_instructions(Object count) {
    return Intl.message(
      'Step-by-Step Instructions ($count steps)',
      name: 'step_by_step_instructions',
      desc: '',
      args: [count],
    );
  }

  /// `Farm Prescription`
  String get farm_prescription {
    return Intl.message(
      'Farm Prescription',
      name: 'farm_prescription',
      desc: '',
      args: [],
    );
  }

  /// `No details available`
  String get no_details_available {
    return Intl.message(
      'No details available',
      name: 'no_details_available',
      desc: '',
      args: [],
    );
  }

  /// `Back Online`
  String get back_online {
    return Intl.message('Back Online', name: 'back_online', desc: '', args: []);
  }

  /// `Offline Mode - Cached Data`
  String get offline_mode_cached_data {
    return Intl.message(
      'Offline Mode - Cached Data',
      name: 'offline_mode_cached_data',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message('Offline', name: 'offline', desc: '', args: []);
  }

  /// `Maize Watch would like to send you notifications about:\n\n• New farm prescriptions\n• Sensor alerts\n• Important updates\n\nThis helps you stay informed about your farm's health.`
  String get notification_permission_message {
    return Intl.message(
      'Maize Watch would like to send you notifications about:\n\n• New farm prescriptions\n• Sensor alerts\n• Important updates\n\nThis helps you stay informed about your farm\'s health.',
      name: 'notification_permission_message',
      desc: '',
      args: [],
    );
  }

  /// `Not Now`
  String get not_now {
    return Intl.message('Not Now', name: 'not_now', desc: '', args: []);
  }

  /// `Notifications enabled! You'll receive farm updates.`
  String get notifications_enabled_message {
    return Intl.message(
      'Notifications enabled! You\'ll receive farm updates.',
      name: 'notifications_enabled_message',
      desc: '',
      args: [],
    );
  }

  /// `Notifications disabled. You can enable them in settings.`
  String get notifications_disabled_message {
    return Intl.message(
      'Notifications disabled. You can enable them in settings.',
      name: 'notifications_disabled_message',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get enable {
    return Intl.message('Enable', name: 'enable', desc: '', args: []);
  }

  /// `Add Field`
  String get add_field {
    return Intl.message('Add Field', name: 'add_field', desc: '', args: []);
  }

  /// `No field`
  String get no_field {
    return Intl.message('No field', name: 'no_field', desc: '', args: []);
  }

  /// `Default Farm`
  String get default_farm {
    return Intl.message(
      'Default Farm',
      name: 'default_farm',
      desc: '',
      args: [],
    );
  }

  /// `Sunny`
  String get sunny {
    return Intl.message('Sunny', name: 'sunny', desc: '', args: []);
  }

  /// `Partly Cloudy`
  String get partly_cloudy_weather {
    return Intl.message(
      'Partly Cloudy',
      name: 'partly_cloudy_weather',
      desc: '',
      args: [],
    );
  }

  /// `Cloudy`
  String get cloudy {
    return Intl.message('Cloudy', name: 'cloudy', desc: '', args: []);
  }

  /// `Rainy`
  String get rainy {
    return Intl.message('Rainy', name: 'rainy', desc: '', args: []);
  }

  /// `Overcast`
  String get overcast {
    return Intl.message('Overcast', name: 'overcast', desc: '', args: []);
  }

  /// `Jan`
  String get january {
    return Intl.message('Jan', name: 'january', desc: '', args: []);
  }

  /// `Feb`
  String get february {
    return Intl.message('Feb', name: 'february', desc: '', args: []);
  }

  /// `Mar`
  String get march {
    return Intl.message('Mar', name: 'march', desc: '', args: []);
  }

  /// `Apr`
  String get april {
    return Intl.message('Apr', name: 'april', desc: '', args: []);
  }

  /// `Jun`
  String get june {
    return Intl.message('Jun', name: 'june', desc: '', args: []);
  }

  /// `Jul`
  String get july {
    return Intl.message('Jul', name: 'july', desc: '', args: []);
  }

  /// `Aug`
  String get august {
    return Intl.message('Aug', name: 'august', desc: '', args: []);
  }

  /// `Sep`
  String get september {
    return Intl.message('Sep', name: 'september', desc: '', args: []);
  }

  /// `Oct`
  String get october {
    return Intl.message('Oct', name: 'october', desc: '', args: []);
  }

  /// `Nov`
  String get november {
    return Intl.message('Nov', name: 'november', desc: '', args: []);
  }

  /// `Dec`
  String get december {
    return Intl.message('Dec', name: 'december', desc: '', args: []);
  }

  /// `You have {count} new farm tasks to complete`
  String new_farm_tasks_message(int count) {
    return Intl.message(
      'You have $count new farm tasks to complete',
      name: 'new_farm_tasks_message',
      desc: '',
      args: [count],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Delete Prescription`
  String get delete_prescription {
    return Intl.message(
      'Delete Prescription',
      name: 'delete_prescription',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this completed prescription? This action cannot be undone.`
  String get delete_prescription_confirmation {
    return Intl.message(
      'Are you sure you want to delete this completed prescription? This action cannot be undone.',
      name: 'delete_prescription_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Prescription deleted successfully`
  String get prescription_deleted_successfully {
    return Intl.message(
      'Prescription deleted successfully',
      name: 'prescription_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting prescription`
  String get error_deleting_prescription {
    return Intl.message(
      'Error deleting prescription',
      name: 'error_deleting_prescription',
      desc: '',
      args: [],
    );
  }

  /// `Prescription marked as complete`
  String get prescription_marked_complete {
    return Intl.message(
      'Prescription marked as complete',
      name: 'prescription_marked_complete',
      desc: '',
      args: [],
    );
  }

  /// `Error marking prescription as complete`
  String get error_marking_complete {
    return Intl.message(
      'Error marking prescription as complete',
      name: 'error_marking_complete',
      desc: '',
      args: [],
    );
  }

  /// `Prescription marked as incomplete`
  String get prescription_marked_incomplete {
    return Intl.message(
      'Prescription marked as incomplete',
      name: 'prescription_marked_incomplete',
      desc: '',
      args: [],
    );
  }

  /// `Error marking prescription as incomplete`
  String get error_marking_incomplete {
    return Intl.message(
      'Error marking prescription as incomplete',
      name: 'error_marking_incomplete',
      desc: '',
      args: [],
    );
  }

  /// `Sensors in Sleep Mode`
  String get sensors_in_sleep_mode {
    return Intl.message(
      'Sensors in Sleep Mode',
      name: 'sensors_in_sleep_mode',
      desc: '',
      args: [],
    );
  }

  /// `Your sensors are now sleeping from 8pm to 3am PH time. They will wake up at 3am.`
  String get sensors_sleep_mode_message {
    return Intl.message(
      'Your sensors are now sleeping from 8pm to 3am PH time. They will wake up at 3am.',
      name: 'sensors_sleep_mode_message',
      desc: '',
      args: [],
    );
  }

  /// `{sensorName} sensor has been offline for more than 30 minutes.`
  String sensor_offline_message(String sensorName) {
    return Intl.message(
      '$sensorName sensor has been offline for more than 30 minutes.',
      name: 'sensor_offline_message',
      desc: '',
      args: [sensorName],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Unable to update prescription status`
  String get unable_to_update_prescription_status {
    return Intl.message(
      'Unable to update prescription status',
      name: 'unable_to_update_prescription_status',
      desc: '',
      args: [],
    );
  }

  /// `Deadline: {deadline}`
  String deadline_colon(Object deadline) {
    return Intl.message(
      'Deadline: $deadline',
      name: 'deadline_colon',
      desc: '',
      args: [deadline],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Please validate the prototype ID before submitting`
  String get please_validate_prototype_id {
    return Intl.message(
      'Please validate the prototype ID before submitting',
      name: 'please_validate_prototype_id',
      desc: '',
      args: [],
    );
  }

  /// `Help content coming soon!`
  String get help_content_coming_soon {
    return Intl.message(
      'Help content coming soon!',
      name: 'help_content_coming_soon',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Contact information coming soon!`
  String get contact_information_coming_soon {
    return Intl.message(
      'Contact information coming soon!',
      name: 'contact_information_coming_soon',
      desc: '',
      args: [],
    );
  }

  /// `Language changed to {language}`
  String language_changed_to(Object language) {
    return Intl.message(
      'Language changed to $language',
      name: 'language_changed_to',
      desc: '',
      args: [language],
    );
  }

  /// `Notifications {status}`
  String notifications_enabled_disabled(Object status) {
    return Intl.message(
      'Notifications $status',
      name: 'notifications_enabled_disabled',
      desc: '',
      args: [status],
    );
  }

  /// `Vibration only {status}`
  String vibration_only_enabled_disabled(Object status) {
    return Intl.message(
      'Vibration only $status',
      name: 'vibration_only_enabled_disabled',
      desc: '',
      args: [status],
    );
  }

  /// `Farm task requires attention`
  String get farm_task_requires_attention {
    return Intl.message(
      'Farm task requires attention',
      name: 'farm_task_requires_attention',
      desc: '',
      args: [],
    );
  }

  /// `Device Settings`
  String get device_settings {
    return Intl.message(
      'Device Settings',
      name: 'device_settings',
      desc: '',
      args: [],
    );
  }

  /// `Monitor the condition of your sensors`
  String get monitor_sensor_condition {
    return Intl.message(
      'Monitor the condition of your sensors',
      name: 'monitor_sensor_condition',
      desc: '',
      args: [],
    );
  }

  /// `Mark Complete`
  String get mark_complete {
    return Intl.message(
      'Mark Complete',
      name: 'mark_complete',
      desc: '',
      args: [],
    );
  }

  /// `Undo Complete`
  String get undo_complete {
    return Intl.message(
      'Undo Complete',
      name: 'undo_complete',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'tl'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
