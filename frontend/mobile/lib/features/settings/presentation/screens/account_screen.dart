import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/custom_dialog.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_event.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_state.dart';
import 'package:mobile/features/settings/presentation/screens/profile_screen.dart';
import 'package:mobile/features/settings/presentation/screens/sensor_status_screen.dart';
import 'package:mobile/features/settings/presentation/screens/about_screen.dart';
import 'package:mobile/features/settings/presentation/screens/help_screen.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/features/settings/presentation/widgets/language_settings_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/notification_settings_widget.dart';

import '../../../../generated/l10n.dart';
import 'prototype_management_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings when screen initializes
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      body: SafeArea(
        child: Column(
          children: [
            // Header section with background
            _buildHeaderSection(),
            
            // Main content area
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: kAppSmallPadding),
                padding: EdgeInsets.only(
                  left: kAppMediumPadding, 
                  right: kAppMediumPadding, 
                  top: kAppMediumPadding, 
                  bottom: kAppLargePadding,
                ),
                decoration: BoxDecoration(
                  color: MAIZE_PRIMARY_LIGHT,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingsSection(),
                  ],
                ),
                
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 180.h,
      padding: EdgeInsets.only(left: kAppMediumPadding, right: kAppMediumPadding, top: kAppMediumPadding, bottom: kAppLargePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/farmer.png'),
          fit: BoxFit.cover,
        ),
      ),
      child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              // Status bar spacing
              SizedBox(height: 40.h),
              
              // Back button and title
              Row(
              children: [Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    'Menu',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: kAppSmallGap),
              Text(
                'Manage your account settings',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),                  
                ],
              ),  Spacer(),]),
              
            

             
            ],
          
        
      ),
    );
  }

  

  Widget _buildSettingsSection() {
    return Expanded(
      child: SingleChildScrollView(
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
            final user = state.user;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildSectionCard(
                  title: 'Profile',
            children: [
                    _buildMenuItem(
                      title: user?.fullName ?? '',
                      subtitle: 'Manage your personal informations',
                      icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },                      
                    ),
                  ],
                ),
                SizedBox(height: kAppMediumPadding),

                _buildSectionCard(
                  title: 'Settings',
                  children: [
                    _buildMenuItem(
                      title: S.of(context).sensor_status,
                      subtitle: S.of(context).monitor_sensor_condition,
                      icon: Icons.sensors,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SensorStatusScreen()),
                        );
                      },
                      
                    ),

                    SizedBox(height: kAppMediumPadding),
                    Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                    SizedBox(height: kAppMediumPadding),

                                        _buildMenuItem(
                      title: 'Prototype Management',
                      subtitle: 'Manage and unsync prototypes from fields',
                      icon: Icons.device_hub,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrototypeManagementScreen()),
                        );
                      },
                      
                    ),

                    SizedBox(height: kAppMediumPadding),
                    Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                    SizedBox(height: kAppMediumPadding),


                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        print('🔧 AccountScreen: Settings state: ${settingsState.runtimeType}');
                        
                        // Get current language from state without setState
                        String displayLanguage = 'English';
                        String languageCode = 'en';
                        
                        if (settingsState is SettingsLoaded) {
                          print('🔧 AccountScreen: Current language: ${settingsState.settings.language}');
                          languageCode = settingsState.settings.language;
                          displayLanguage = settingsState.settings.language == 'tl' ? 'Filipino' : 'English';
                        } else if (settingsState is SettingsUpdated) {
                          print('🔧 AccountScreen: Settings updated, language: ${settingsState.settings.language}');
                          languageCode = settingsState.settings.language;
                          displayLanguage = settingsState.settings.language == 'tl' ? 'Filipino' : 'English';
                        }
                        
                        return _buildOptionItem(
                          title: S.of(context).language,
                          currentValue: displayLanguage,
                          icon: Icons.language,
                          onTap: () {
                            print('🔧 AccountScreen: Language dialog opened, current language: $displayLanguage');
                            _showOptionDialog(S.of(context).language_settings, LanguageSettingsWidget(
                              currentLanguage: languageCode,
                              onLanguageChanged: (language) {
                                print('🔧 AccountScreen: Language change requested: $language');
                                context.read<SettingsBloc>().add(UpdateLanguage(language));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(context).language_changed_to(language == 'tl' ? 'Filipino' : 'English')),
                                    backgroundColor: MAIZE_ACCENT,
                                  ),
                                );
                              },
                            ));
                          },
                        );
                      },
                    ),

                                        SizedBox(height: kAppMediumPadding),
                    Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                    SizedBox(height: kAppMediumPadding),

                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        print('🔧 AccountScreen: Settings state for notifications: ${settingsState.runtimeType}');
                        String currentNotificationStatus = 'On';
                        bool notificationsEnabled = true;
                        bool vibrationOnly = false;
                        
                        if (settingsState is SettingsLoaded) {
                          print('🔧 AccountScreen: Current notification settings: ${settingsState.settings.notificationsEnabled}, ${settingsState.settings.vibrationOnly}');
                          notificationsEnabled = settingsState.settings.notificationsEnabled;
                          vibrationOnly = settingsState.settings.vibrationOnly;
                          currentNotificationStatus = notificationsEnabled ? (vibrationOnly ? 'Vibration Only' : 'On') : 'Off';
                        } else if (settingsState is SettingsUpdated) {
                          print('🔧 AccountScreen: Updated notification settings: ${settingsState.settings.notificationsEnabled}, ${settingsState.settings.vibrationOnly}');
                          notificationsEnabled = settingsState.settings.notificationsEnabled;
                          vibrationOnly = settingsState.settings.vibrationOnly;
                          currentNotificationStatus = notificationsEnabled ? (vibrationOnly ? 'Vibration Only' : 'On') : 'Off';
                        }
                        
                        return _buildOptionItem(
                          title: 'Notifications',
                          currentValue: currentNotificationStatus,
                          icon: Icons.notifications,
                          onTap: () {
                            print('🔧 AccountScreen: Notification dialog opened, current settings: enabled=$notificationsEnabled, vibrationOnly=$vibrationOnly');
                            _showOptionDialog('Notification Settings', NotificationSettingsWidget(
                              isNotificationsEnabled: notificationsEnabled,
                              isVibrationOnly: vibrationOnly,
                              onNotificationToggled: (enabled) {
                                print('🔧 AccountScreen: Notification toggle requested: $enabled');
                                context.read<SettingsBloc>().add(UpdateNotificationSettings(
                                  enabled: enabled,
                                  vibrationOnly: vibrationOnly,
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.current.notifications_enabled_disabled(enabled ? 'enabled' : 'disabled')),
                                    backgroundColor: MAIZE_ACCENT,
                                  ),
                                );
                              },
                              onVibrationOnlyToggled: (vibrationOnly) {
                                print('🔧 AccountScreen: Vibration only toggle requested: $vibrationOnly');
                                context.read<SettingsBloc>().add(UpdateNotificationSettings(
                                  enabled: notificationsEnabled,
                                  vibrationOnly: vibrationOnly,
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.current.vibration_only_enabled_disabled(vibrationOnly ? 'enabled' : 'disabled')),
                                    backgroundColor: MAIZE_ACCENT,
                                  ),
                                );
                              },
                            ));
                          },
                        );
                      },
              ),
            ],
          ),
                SizedBox(height: kAppMediumPadding),
                // SupportSection
                _buildSectionCard(
                  title: 'Support',
                  children: [
                    _buildMenuItem(
                      title: 'About',
                      subtitle: 'Know more about Maize Watch\'s objective and socials',
                      icon: Icons.info_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutScreen()),
                        );
                      },
                      
                    ),

                    SizedBox(height: kAppMediumPadding),
                    Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                    SizedBox(height: kAppMediumPadding),

                    _buildMenuItem(
                      title: 'Help',
                      subtitle: 'Learn how to use the Maize Watch app',
                      icon: Icons.help_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpScreen()),
                        );
                      },
                      
                    ),
                  ],
                ),
                verticalSpace(kAppLargeGap),
                
                // Logout Section
                _buildLogoutSection(),

                
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: kAppSmallPadding),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,    
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: MAIZE_ACCENT.withOpacity(0.1),
        highlightColor: MAIZE_ACCENT.withOpacity(0.05),
        child: Container(
           padding: EdgeInsets.symmetric(vertical: kAppSmallPadding),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: MAIZE_ACCENT.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                  icon,
                      color: MAIZE_ACCENT,
                  size: 24.sp,
                    ),
                  ),
              SizedBox(width: kAppMediumGap),
                  Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MAIZE_ACCENT.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
               Icon(
                Icons.north_east,
                color: MAIZE_ACCENT,
                size: 18.sp,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required String title,
    required String currentValue,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: MAIZE_ACCENT.withOpacity(0.1),
        highlightColor: MAIZE_ACCENT.withOpacity(0.05),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: kAppSmallPadding),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: MAIZE_ACCENT.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                  icon,
                color: MAIZE_ACCENT,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: kAppMediumGap),
            Expanded(
                child: Padding(padding: EdgeInsets.only(right: kAppSmallPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      currentValue,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MAIZE_ACCENT.withOpacity(0.8), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
                Icons.chevron_right,
                color: MAIZE_ACCENT,
                size: 24.sp,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Center(
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
              _showLogoutDialog();
            },
              borderRadius: BorderRadius.circular(30.r),
              splashColor: Colors.red[200],
              highlightColor: Colors.red[200],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: kAppLargePadding*2, vertical: kAppMediumPadding),
                child: Text(
                  'Log out',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    customOptionDialog(context, title: 'Log out', content: 'Are you sure you want to log out?', onYes: () {
      context.read<AuthenticationBloc>().add(LogoutEvent());
    });
  }

  void _showOptionDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 600.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(kAppMediumPadding),
                decoration: BoxDecoration(
                  color: MAIZE_ACCENT,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(child: content),
            ],
          ),
        ),
          ),
    );
  }
}
