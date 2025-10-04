import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_event.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_state.dart';
import 'package:mobile/core/widgets/custom_button.dart';
import 'package:mobile/generated/l10n.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  
  // Notification settings
  bool _notificationsEnabled = true;
  bool _vibrationOnly = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load from SharedPreferences first (for immediate effect)
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final vibrationOnly = prefs.getBool('vibration_only') ?? false;
      
      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _vibrationOnly = vibrationOnly;
      });
      
      print('🔧 NotificationSettingsScreen: Loaded settings from SharedPreferences - enabled: $notificationsEnabled, vibration: $vibrationOnly');
    } catch (e) {
      print('🔧 NotificationSettingsScreen: Error loading settings: $e');
      // Fallback to BLoC state
      final state = context.read<SettingsBloc>().state;
      if (state is SettingsLoaded) {
        setState(() {
          _notificationsEnabled = state.settings.notificationsEnabled;
          _vibrationOnly = state.settings.vibrationOnly;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(        
        backgroundColor: MAIZE_PRIMARY_LIGHT,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back, color: MAIZE_ACCENT),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildSettingsSection(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 180.h,
      padding: EdgeInsets.only(
        left: kAppMediumPadding, 
        right: kAppMediumPadding, 
        top: kAppMediumPadding, 
        bottom: kAppLargePadding,
      ),
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
                    S.of(context).notifications,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: kAppSmallGap),
                  Text(
                    S.of(context).manage_your_app_preferences,
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
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Settings Section
                  _buildSectionCard(
                    title: S.of(context).notification_settings,
                    children: [
                      _buildNotificationItem(
                        title: S.of(context).enable_notifications,
                        subtitle: S.of(context).notification_description,
                        icon: Icons.notifications_active,
                        isEnabled: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        color: Colors.green,
                      ),
                      
                      if (_notificationsEnabled) ...[
                        SizedBox(height: kAppMediumPadding),
                        Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                        SizedBox(height: kAppMediumPadding),
                        
                        _buildNotificationItem(
                          title: S.of(context).vibration_only,
                          subtitle: S.of(context).vibration_only_description,
                          icon: Icons.vibration,
                          isEnabled: _vibrationOnly,
                          onChanged: (value) {
                            setState(() {
                              _vibrationOnly = value;
                            });
                          },
                          color: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                  
                  SizedBox(height: kAppMediumPadding),
                  
                  // Notification Types Section
                  _buildSectionCard(
                    title: S.of(context).notification_types,
                    children: [
                      _buildNotificationItem(
                        title: S.of(context).farm_alerts,
                        subtitle: S.of(context).farm_alerts_description,
                        icon: Icons.agriculture,
                        isEnabled: true,
                        onChanged: (value) {
                          // Handle farm alerts toggle
                        },
                        color: Colors.blue,
                      ),
                      
                      SizedBox(height: kAppMediumPadding),
                      Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                      SizedBox(height: kAppMediumPadding),
                      
                      _buildNotificationItem(
                        title: S.of(context).sensor_status,
                        subtitle: S.of(context).sensor_status_description,
                        icon: Icons.sensors,
                        isEnabled: true,
                        onChanged: (value) {
                          // Handle sensor alerts toggle
                        },
                        color: Colors.purple,
                      ),
                      
                      SizedBox(height: kAppMediumPadding),
                      Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                      SizedBox(height: kAppMediumPadding),
                      
                      _buildNotificationItem(
                        title: S.of(context).prescription_updates,
                        subtitle: S.of(context).prescription_updates_description,
                        icon: Icons.medical_services,
                        isEnabled: true,
                        onChanged: (value) {
                          // Handle prescription alerts toggle
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                  
                  verticalSpace(kAppLargeGap),
                  
                  // Debug section
                  Container(
                    padding: EdgeInsets.all(kAppMediumPadding),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          S.of(context).debug_section,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final enabled = prefs.getBool('notifications_enabled') ?? true;
                            final allKeys = prefs.getKeys();
                            print('🔧 DEBUG: Current notifications_enabled: $enabled');
                            print('🔧 DEBUG: All SharedPreferences keys: $allKeys');
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).notifications_enabled(enabled.toString())),
                                backgroundColor: enabled ? Colors.green : Colors.red,
                              ),
                            );
                          },
                          child: Text(S.of(context).check_notification_status),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onChanged(!isEnabled);
        },
        borderRadius: BorderRadius.circular(12.r),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: kAppSmallPadding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  icon,
                  color: isEnabled ? color : Colors.grey,
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
              Switch(
                value: isEnabled,
                onChanged: onChanged,
                activeColor: color,
                activeTrackColor: color.withOpacity(0.3),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[200],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Row(
        children: [
          if (!_isEditing) ...[
            Expanded(
              child: CustomButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                text: S.of(context).edit_settings,
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _isEditing = false;
                    _loadSettings(); // Reset to original values
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: kAppMediumPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: kAppSmallGap),
            Expanded(
              child: _isLoading 
                ? Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).saving,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : CustomButton(
                    onPressed: () => _saveSettings(),
                    text: S.of(context).save,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    print('🔧 NotificationSettingsScreen: Saving settings...');
    setState(() {
      _isLoading = true;
    });

    try {
      // Save to SharedPreferences for immediate effect
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('vibration_only', _vibrationOnly);
      
      print('🔧 NotificationSettingsScreen: Settings saved to SharedPreferences - enabled: $_notificationsEnabled, vibration: $_vibrationOnly');
      
      // Verify the settings were saved
      final savedEnabled = prefs.getBool('notifications_enabled') ?? true;
      final savedVibration = prefs.getBool('vibration_only') ?? false;
      print('🔧 NotificationSettingsScreen: Verification - saved enabled: $savedEnabled, saved vibration: $savedVibration');

      // Update notification settings in BLoC
      context.read<SettingsBloc>().add(
        UpdateNotificationSettings(
          enabled: _notificationsEnabled,
          vibrationOnly: _vibrationOnly,
        ),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).notification_settings_updated),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
    } catch (e) {
      print("🚨 Notification settings update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).notification_settings_failed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }
}
