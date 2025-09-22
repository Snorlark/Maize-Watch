import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/generated/l10n.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            SizedBox(height: kAppLargePadding),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // App Info Card
                    _buildAppInfoCard(),
                    SizedBox(height: kAppLargePadding),
                    
                    // Contact Section
                    _buildContactSection(),
                    SizedBox(height: kAppLargePadding),
                    
                    // Social Media Links
                    _buildSocialMediaLinks(),
                    SizedBox(height: kAppLargePadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: MAIZE_ACCENT,
              size: 24.sp,
            ),
          ),
          SizedBox(width: kAppSmallGap),
          Text(
            S.of(context).about,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: MAIZE_ACCENT,
            ),
          ),
          const Spacer(),
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
           
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/corn-logo.png',
              width: 40.w,
              height: 40.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
      padding: EdgeInsets.all(kAppLargePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Title
          Text(
            'Maize Watch',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: MAIZE_ACCENT,
            ),
          ),
          SizedBox(height: kAppMediumPadding),
          
          // App Description
          Text(
            'Maize Watch is a crop monitoring application designed to help farmers keep track of maize growth and identify issues quickly.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: kAppLargePadding),
          
          // Version
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'version 1.0.0',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        Text(
          'Contact us at:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: MAIZE_ACCENT,
          ),
        ),
        SizedBox(height: kAppMediumPadding),
      ],
    );
  }

  Widget _buildSocialMediaLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
          icon: Icons.camera_alt,
          onTap: () {
            // TODO: Implement Instagram link
            _showComingSoon();
          },
        ),
        SizedBox(width: kAppMediumPadding),
        _buildSocialIcon(
          icon: Icons.code,
          onTap: () {
            // TODO: Implement GitHub link
            _showComingSoon();
          },
        ),
        SizedBox(width: kAppMediumPadding),
        _buildSocialIcon(
          icon: Icons.business,
          onTap: () {
            // TODO: Implement LinkedIn link
            _showComingSoon();
          },
        ),
        SizedBox(width: kAppMediumPadding),
        _buildSocialIcon(
          icon: Icons.alternate_email,
          onTap: () {
            // TODO: Implement X (Twitter) link
            _showComingSoon();
          },
        ),
      ],
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: MAIZE_ACCENT,
          size: 24.sp,
        ),
      ),
    );
  }

  void _showComingSoon() {
    // This would be called from the social media icons
    // For now, we'll just show a snackbar
  }
}
