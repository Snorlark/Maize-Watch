import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/custom_dialog.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/features/settings/presentation/screens/profile_screen.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/settings/presentation/screens/sensor_status_screen.dart';
import 'package:mobile/features/settings/presentation/screens/about_screen.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/features/settings/presentation/widgets/language_settings_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/notification_settings_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
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
                      title: 'Sensor Status',
                      subtitle: 'Monitor the condition of your sensors',
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


                    _buildOptionItem(
                      title: 'Language',
                      currentValue: 'English',
                      icon: Icons.language,
                      onTap: () {
                        _showOptionDialog('Language Settings', LanguageSettingsWidget(
                          currentLanguage: 'English',
                          onLanguageChanged: (language) {
                            // Handle language change
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Language changed to $language'),
                                backgroundColor: MAIZE_ACCENT,
                              ),
                            );
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Notifications ${enabled ? 'enabled' : 'disabled'}'),
                                backgroundColor: MAIZE_ACCENT,
                              ),
                            );
                          },
                          onVibrationOnlyToggled: (vibrationOnly) {
                            // Handle vibration only toggle
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vibration only ${vibrationOnly ? 'enabled' : 'disabled'}'),
                                backgroundColor: MAIZE_ACCENT,
                              ),
                            );
                          },
                        ));
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
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
                size: 22.sp,
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
