import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class HelpSectionWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const HelpSectionWidget({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<HelpSectionWidget> createState() => _HelpSectionWidgetState();
}

class _HelpSectionWidgetState extends State<HelpSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              padding: EdgeInsets.all(kAppMediumPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: MAIZE_ACCENT,
                    size: 24.sp,
                  ),
                  SizedBox(width: kAppSmallGap),
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: MAIZE_ACCENT,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: MAIZE_ACCENT,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (widget.isExpanded) ...[
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: EdgeInsets.all(kAppMediumPadding),
              child: Column(
                children: [
                  _buildHelpItem(
                    'Contact Support',
                    'Get help from our support team',
                    Icons.support_agent,
                    () {
                      // TODO: Implement contact support
                    },
                  ),
                  SizedBox(height: kAppSmallPadding),
                  _buildHelpItem(
                    'User Guide',
                    'Learn how to use the app',
                    Icons.book,
                    () {
                      // TODO: Implement user guide
                    },
                  ),
                  SizedBox(height: kAppSmallPadding),
                  _buildHelpItem(
                    'Report Bug',
                    'Report issues or bugs',
                    Icons.bug_report,
                    () {
                      // TODO: Implement bug report
                    },
                  ),
                  SizedBox(height: kAppSmallPadding),
                  _buildHelpItem(
                    'Feature Request',
                    'Suggest new features',
                    Icons.lightbulb_outline,
                    () {
                      // TODO: Implement feature request
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: kAppSmallPadding),
        child: Row(
          children: [
            Icon(
              icon,
              color: MAIZE_ACCENT,
              size: 20.sp,
            ),
            SizedBox(width: kAppSmallGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
