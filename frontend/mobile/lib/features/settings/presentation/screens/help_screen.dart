import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

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
              Text('Help', style: Theme.of(context).textTheme.headlineMedium,),
              verticalSpace(5.h),
              Text('Learn how to use the Maize Watch app', style: Theme.of(context).textTheme.bodySmall,),   
              verticalSpace(kAppLargeGap),
              
              // Getting Started Section
              _buildSectionCard(
                title: 'Getting Started',
                children: [
                  _buildHelpItem(
                    'Setting Up Your Farm',
                    'Learn how to add and configure your farm details',
                    Icons.agriculture,
                    () => _showComingSoon('Farm Setup Guide'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    'Connecting Sensors',
                    'Step-by-step guide to connect your monitoring sensors',
                    Icons.sensors,
                    () => _showComingSoon('Sensor Setup Guide'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    'First Time Setup',
                    'Complete walkthrough for new users',
                    Icons.play_circle_outline,
                    () => _showComingSoon('First Time Setup'),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Features Guide Section
              _buildSectionCard(
                title: 'Features Guide',
                children: [
                  _buildHelpItem(
                    'Live Monitoring',
                    'How to read and interpret sensor data',
                    Icons.monitor,
                    () => _showComingSoon('Live Monitoring Guide'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    'Analytics & Reports',
                    'Understanding your farm analytics and reports',
                    Icons.analytics,
                    () => _showComingSoon('Analytics Guide'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    'Notifications',
                    'Setting up and managing app notifications',
                    Icons.notifications,
                    () => _showComingSoon('Notifications Guide'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    'Profile Management',
                    'How to update your profile and settings',
                    Icons.person,
                    () => _showComingSoon('Profile Guide'),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Troubleshooting Section
              _buildSectionCard(
                title: 'Troubleshooting',
                children: [
                  _buildHelpItem(
                    'Sensor Connection Issues',
                    'Common problems and solutions for sensor connectivity',
                    Icons.wifi_off,
                    () => _showComingSoon('Sensor Troubleshooting'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    'Data Not Updating',
                    'Why your data might not be refreshing',
                    Icons.refresh,
                    () => _showComingSoon('Data Update Issues'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildHelpItem(
                    'App Performance',
                    'Tips to improve app performance and speed',
                    Icons.speed,
                    () => _showComingSoon('Performance Tips'),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // FAQ Section
              _buildSectionCard(
                title: 'Frequently Asked Questions',
                children: [
                  _buildFAQItem(
                    'How often does the app update sensor data?',
                    'Sensor data is updated every 30 minutes automatically.',
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildFAQItem(
                    'Can I use the app without internet?',
                    'The app requires internet connection to sync data and receive updates.',
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildFAQItem(
                    'How do I change the language?',
                    'Go to Settings > Language and select your preferred language.',
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildFAQItem(
                    'What if my sensors go offline?',
                    'The app will show offline status and send notifications when sensors reconnect.',
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
                size: 24.sp,
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature guide coming soon!'),
        backgroundColor: MAIZE_ACCENT,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
