import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../generated/l10n.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(        
        backgroundColor: MAIZE_PRIMARY_LIGHT,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back, color: MAIZE_ACCENT,)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(kAppMediumPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [                 
              Text(S.of(context).help_title, style: Theme.of(context).textTheme.headlineMedium,),
              verticalSpace(5.h),
              Text(S.of(context).learn_how_to_use_maize_watch, style: Theme.of(context).textTheme.bodySmall,),   
              verticalSpace(kAppLargeGap),
              
              // Getting Started Section
              _buildSectionCard(
                title: S.of(context).getting_started,
                children: [
                  _buildHelpItem(
                    S.of(context).setting_up_your_farm,
                    S.of(context).learn_how_to_add_and_configure_your_farm_details,
                    Icons.agriculture,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    S.of(context).connecting_sensors,
                    S.of(context).step_by_step_guide_to_connect_your_monitoring_sensors,
                    Icons.sensors,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    S.of(context).first_time_setup,
                    S.of(context).complete_walkthrough_for_new_users,
                    Icons.play_circle_outline,
                    () => _launchWebsite(),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Features Guide Section
              _buildSectionCard(
                title: S.of(context).features_guide,
                children: [
                  _buildHelpItem(
                    S.of(context).live_monitoring,
                    S.of(context).how_to_read_and_interpret_sensor_data,
                    Icons.monitor,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    S.of(context).analytics_reports,
                    S.of(context).understanding_your_farm_analytics_and_reports,
                    Icons.analytics,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    S.of(context).notifications,
                    S.of(context).setting_up_and_managing_app_notifications,
                    Icons.notifications,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    S.of(context).profile_management,
                    S.of(context).how_to_update_your_profile_and_settings,
                    Icons.person,
                    () => _launchWebsite(),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Troubleshooting Section
              _buildSectionCard(
                title: S.of(context).troubleshooting,
                children: [
                  _buildHelpItem(
                    S.of(context).sensor_connection_issues,
                    S.of(context).common_problems_and_solutions_for_sensor_connectivity,
                    Icons.wifi_off,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    S.of(context).data_not_updating,
                    S.of(context).why_your_data_might_not_be_refreshing,
                    Icons.refresh,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    S.of(context).app_performance,
                    S.of(context).tips_to_improve_app_performance_and_speed,
                    Icons.speed,
                    () => _launchWebsite(),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // FAQ Section
              _buildSectionCard(
                title: S.of(context).frequently_asked_questions,
                children: [
                  _buildFAQItem(
                    S.of(context).how_often_does_the_app_update_sensor_data,
                    S.of(context).sensor_data_is_updated_every_30_minutes_automatically,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildFAQItem(
                    S.of(context).can_i_use_the_app_without_internet,
                    S.of(context).the_app_requires_internet_connection_to_sync_data_and_receive_updates,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildFAQItem(
                    S.of(context).how_do_i_change_the_language,
                    S.of(context).go_to_settings_language_and_select_your_preferred_language,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildFAQItem(
                    S.of(context).what_if_my_sensors_go_offline,
                    S.of(context).the_app_will_show_offline_status_and_send_notifications_when_sensors_reconnect,
                  ),
                ],
              ),
              verticalSpace(kAppLargeGap), // Add some bottom padding
            ],
          ),
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

  Widget _buildHelpItem(String title, String description, IconData icon, VoidCallback onTap) {
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
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MAIZE_ACCENT.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.north_east,
                color: MAIZE_ACCENT,
                size: 20.sp,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: MAIZE_ACCENT,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  void _launchWebsite() async {
    final Uri url = Uri.parse('https://maize-watch-rdcy.onrender.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch website'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }
}
