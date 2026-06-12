import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../theme/colors.dart';
import '../../generated/l10n.dart';

class PolicyDialogs {
  static void showPrivacyPolicy(BuildContext context) {
    final l10n = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: MAIZE_LOGO_ICON,
                size: 28,
              ),
              SizedBox(width: kAppSmallPadding),
              Expanded(
                child: Text(
                  l10n.privacy_policy,
                  style: textTheme.headlineMedium?.copyWith(
                    color: MAIZE_LOGO_ICON,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(kAppMediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.privacy_info_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_intro,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.privacy_info_section1_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_section1_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.privacy_info_section2_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_section2_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.privacy_info_section3_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_section3_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.privacy_info_section4_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_section4_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.privacy_info_section5_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_section5_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.privacy_info_section6_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_section6_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.privacy_info_section7_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.privacy_info_section7_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: MAIZE_PRIMARY,
                padding: EdgeInsets.symmetric(
                  horizontal: kAppMediumPadding,
                  vertical: kAppSmallPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.ok,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.all(kAppMediumPadding),
        );
      },
    );
  }

  static void showTermsOfService(BuildContext context) {
    final l10n = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.assignment_outlined, color: MAIZE_LOGO_ICON, size: 28),
              SizedBox(width: kAppSmallPadding),
              Expanded(
                child: Text(
                  l10n.privacy_policy,
                  style: textTheme.headlineMedium?.copyWith(
                    color: MAIZE_LOGO_ICON,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(kAppMediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.terms_intro,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.terms_section1_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.terms_section1_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.terms_section2_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.terms_section2_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.terms_section3_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.terms_section3_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.terms_section4_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.terms_section4_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.terms_section5_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.terms_section5_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.terms_section6_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.terms_section6_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                  SizedBox(height: kAppMediumPadding),
                  Text(
                    l10n.terms_section7_title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    l10n.terms_section7_content,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: MAIZE_PRIMARY,
                padding: EdgeInsets.symmetric(
                  horizontal: kAppMediumPadding,
                  vertical: kAppSmallPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.ok,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.all(kAppMediumPadding),
        );
      },
    );
  }
}
