import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

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
              Text('About', style: Theme.of(context).textTheme.headlineMedium,),
              verticalSpace(5.h),
              Text('Learn more about Maize Watch', style: Theme.of(context).textTheme.bodySmall,),   
              verticalSpace(kAppLargeGap),
              
              // App Info Section
              _buildSectionCard(
                title: 'App Information',
                children: [
                  _buildAppInfoItem(),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Features Section
              _buildSectionCard(
                title: 'Key Features',
                children: [
                  _buildFeatureItem(
                    'Real-time Sensor Monitoring',
                    'Track temperature, humidity, soil moisture, and light levels',
                    Icons.sensors,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildFeatureItem(
                    'Weather Integration',
                    'Get weather forecasts and alerts for your farm',
                    Icons.wb_sunny,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildFeatureItem(
                    'Smart Analytics',
                    'AI-powered insights and recommendations',
                    Icons.analytics,
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1, indent: 10, endIndent: 10),
                  SizedBox(height: kAppMediumPadding),
                  _buildFeatureItem(
                    'Multi-language Support',
                    'Available in English and Filipino',
                    Icons.language,
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Contact Section
              _buildSectionCard(
                title: 'Contact & Support',
        children: [
                  _buildContactItem(
                    'Email Support',
                    'maizewatch@gmail.com',
                    Icons.email,
                    () => _showComingSoon('Email'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildContactItem(
                    'Phone Support',
                    '+63 912 345 6789',
                    Icons.phone,
                    () => _showComingSoon('Phone'),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Divider(color: MAIZE_ACCENT.withOpacity(0.1), height: 1),
                  SizedBox(height: kAppMediumPadding),
                  _buildContactItem(
                    'Website',
                    'www.maizewatch.com',
                    Icons.web,
                    () => _showComingSoon('Website'),
                  ),
                ],
              ),
              verticalSpace(kAppMediumPadding),

              // Social Media Section
              _buildSectionCard(
                title: 'Follow Us',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialIcon(
                        icon: Icons.camera_alt,
                        label: 'Instagram',
                        onTap: () => _showComingSoon('Instagram'),
                      ),
                      _buildSocialIcon(
                        icon: Icons.code,
                        label: 'GitHub',
                        onTap: () => _showComingSoon('GitHub'),
                      ),
                      _buildSocialIcon(
                        icon: Icons.business,
                        label: 'LinkedIn',
                        onTap: () => _showComingSoon('LinkedIn'),
                      ),
                      _buildSocialIcon(
                        icon: Icons.alternate_email,
                        label: 'Twitter',
                        onTap: () => _showComingSoon('Twitter'),
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
                        'Maize Watch',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                  color: Colors.black87,
                        ),
                      ),
                      Text(
                        'version 1.0.0',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              SizedBox(height: kAppSmallPadding),
                Text(
                  'Maize Watch is a comprehensive crop monitoring application designed specifically for Filipino farmers to track maize growth, monitor environmental conditions, and identify potential issues early.',
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
                  size: 24.sp,
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

  void _showComingSoon(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform integration coming soon!'),
        backgroundColor: MAIZE_ACCENT,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
