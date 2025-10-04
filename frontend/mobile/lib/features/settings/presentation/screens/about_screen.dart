import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../generated/l10n.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }


  Widget _buildAboutSection() {
    return Expanded(
      child: Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [                 
              Text(S.of(context).about, style: Theme.of(context).textTheme.headlineMedium,),
              verticalSpace(5.h),
              Text(S.of(context).learn_more_about_maize_watch, style: Theme.of(context).textTheme.bodySmall,),   
              verticalSpace(kAppLargeGap),
              
              // App Info Section
              _buildSectionCard(
                title: S.of(context).app_information,
                children: [
                  _buildAppInfoItem(),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Features Section
              _buildSectionCard(
                title: S.of(context).key_features,
                children: [
                  _buildFeatureItem(
                    S.of(context).real_time_sensor_monitoring,
                    S.of(context).track_temperature_humidity_soil_moisture_and_light_levels,
                    Icons.sensors,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildFeatureItem(
                    S.of(context).weather_integration,
                    S.of(context).get_weather_forecasts_and_alerts_for_your_farm,
                    Icons.wb_sunny,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildFeatureItem(
                    S.of(context).smart_analytics,
                    S.of(context).ai_powered_insights_and_recommendations,
                    Icons.analytics,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildFeatureItem(
                    S.of(context).multi_language_support,
                    S.of(context).available_in_english_and_filipino,
                    Icons.language,
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Contact Section
              _buildSectionCard(
                title: S.of(context).contact_support,
        children: [
                  _buildContactItem(
                    S.of(context).email_support,
                    'maizewatch@gmail.com',
                    Icons.email,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildContactItem(
                    S.of(context).phone_support,
                    '+63 912 345 6789',
                    Icons.phone,
                    () => _launchWebsite(),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildContactItem(
                    S.of(context).website,
                    'www.maizewatch.com',
                    Icons.web,
                    () => _launchWebsite(),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Social Media Section
              _buildSectionCard(
                title: S.of(context).follow_us,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialIcon(
                        icon: Icons.camera_alt,
                        label: S.of(context).instagram,
                        onTap: () => _launchWebsite(),
                      ),
                      _buildSocialIcon(
                        icon: Icons.code,
                        label: S.of(context).github,
                        onTap: () => _launchWebsite(),
                      ),
                      _buildSocialIcon(
                        icon: Icons.business,
                        label: S.of(context).linkedin,
                        onTap: () => _launchWebsite(),
                      ),
                      _buildSocialIcon(
                        icon: Icons.alternate_email,
                        label: S.of(context).twitter,
                        onTap: () => _launchWebsite(),
                      ),
                    ],
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

  Widget _buildAppInfoItem() {
    return Row(
              children: [
                Container(
                  width: 60.w,
          height: 60.w,
                  decoration: BoxDecoration(
            color: MAIZE_ACCENT.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.agriculture,
            color: MAIZE_ACCENT,
            size: 30.sp,
                  ),
                ),
                SizedBox(width: kAppMediumPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).maize_watch,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                  color: Colors.black87,
                        ),
                      ),
                      Text(
                        S.of(context).version,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              SizedBox(height: kAppSmallPadding),
                Text(
                  S.of(context).maize_watch_description,
                  style: TextStyle(
                  fontSize: 14.sp,
                    color: Colors.black87,
                  height: 1.4,
                ),
                ),
              ],
            ),
          ),
        ],
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Row(
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
        ],
    );
  }

  Widget _buildContactItem(String title, String value, IconData icon, VoidCallback onTap) {
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
                    value,
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

  Widget _buildSocialIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
        borderRadius: BorderRadius.circular(25.r),
        splashColor: MAIZE_ACCENT.withOpacity(0.1),
        highlightColor: MAIZE_ACCENT.withOpacity(0.05),
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
                color: MAIZE_ACCENT.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: MAIZE_ACCENT,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        ),
      ),
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
