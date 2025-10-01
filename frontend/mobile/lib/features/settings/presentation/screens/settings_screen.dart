import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_event.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_state.dart';
import 'package:mobile/features/settings/presentation/widgets/language_settings_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/notification_settings_widget.dart';
import 'package:mobile/features/settings/presentation/screens/sensor_status_screen.dart';

import '../../../../generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettings());
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
                  color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Status bar spacing
          SizedBox(height: 40.h),
          
          // Back button and title
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: kAppSmallGap),
                  Text(
                    'Manage your app preferences',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),                  
                ],
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Expanded(
      child: SingleChildScrollView(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: MAIZE_ACCENT,
                ),
              );
            }

            if (state is SettingsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SettingsBloc>().add(const RefreshSettings());
                      },
                      child: Text(S.current.retry),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Settings Section
                _buildSectionCard(
                  title: S.current.device_settings,
                  children: [
                    _buildMenuItem(
                      title: S.current.sensor_status,
                      subtitle: S.current.monitor_sensor_condition,
                      icon: Icons.sensors,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SensorStatusScreen()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: kAppMediumPadding),

                // App Settings Section
                _buildSectionCard(
                  title: 'App Settings',
                  children: [
                    _buildOptionItem(
                      title: 'Language',
                      currentValue: 'English',
                      icon: Icons.language,
                      onTap: () {
                        _showOptionDialog('Language Settings', LanguageSettingsWidget(
                          currentLanguage: 'English',
                          onLanguageChanged: (language) {
                            // Handle language change
                          },
                        ));
                      },
                    ),

                    SizedBox(height: kAppMediumPadding),
                    Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                    SizedBox(height: kAppMediumPadding),

                    _buildOptionItem(
                      title: 'Notifications',
                      currentValue: 'On',
                      icon: Icons.notifications,
                      onTap: () {
                        _showOptionDialog('Notification Settings', NotificationSettingsWidget(
                          isNotificationsEnabled: true,
                          isVibrationOnly: false,
                          onNotificationToggled: (enabled) {
                            // Handle notification toggle
                          },
                          onVibrationOnlyToggled: (vibrationOnly) {
                            // Handle vibration only toggle
                          },
                        ));
                      },
                    ),
                  ],
                ),
                SizedBox(height: kAppMediumPadding),

                // Support Section
                _buildSectionCard(
                  title: 'Support',
                  children: [
                    _buildMenuItem(
                      title: 'Help & FAQ',
                      subtitle: 'Get help and find answers to common questions',
                      icon: Icons.help_outline,
                      onTap: () {
                        _showHelpDialog();
                      },
                    ),

                    SizedBox(height: kAppMediumPadding),
                    Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                    SizedBox(height: kAppMediumPadding),

                    _buildMenuItem(
                      title: 'Contact Support',
                      subtitle: 'Get in touch with our support team',
                      icon: Icons.support_agent,
                      onTap: () {
                        _showContactDialog();
                      },
                    ),
                  ],
                ),
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey, width: 1),
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
                size: 24.sp,
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(kAppMediumPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Help & FAQ',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: kAppMediumPadding),
              Text(S.current.help_content_coming_soon),
              SizedBox(height: kAppMediumPadding),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.current.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(kAppMediumPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact Support',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: kAppMediumPadding),
              Text(S.current.contact_information_coming_soon),
              SizedBox(height: kAppMediumPadding),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.current.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}