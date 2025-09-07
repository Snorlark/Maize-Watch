import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/widgets/custom_button.dart';
import 'package:mobile/features/authentication/presentation/widgets/login_overlay.dart';

import '../../../../core/constants/app_spacing.dart';
import 'package:mobile/generated/l10n.dart';

import '../../../../core/constants/custom_transition.dart';
import '../../../../core/widgets/language_toggle.dart';
import 'register_screen.dart';

class LandingScreen extends StatefulWidget {
  final bool showLoginOnLoad;
  const LandingScreen({super.key, this.showLoginOnLoad = false});

  @override
  State<LandingScreen> createState() => LandingScreenState();
}

class LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.showLoginOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showLoginOverlay(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    String descriptionSplit = S.of(context).description;
    List<String> descriptionList = descriptionSplit.split(",");

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/background-landing.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          // Version number (positioned absolutely)
          Positioned(
            top: kAppLargePadding,
            right: kAppMediumPadding,
            child: const LanguageToggle(color_toggle: MAIZE_PRIMARY_LIGHT),
          ),

          // Main content (centered)
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Important: only take needed space
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Image.asset(
                        'assets/images/maize-watch-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setHeight(14)),

                    Text(
                      "MAIZE WATCH",
                      style: textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: ScreenUtil().setHeight(5)),

                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "${descriptionList.first}, ",
                          style: textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1,
                            fontSize: 12.sp,
                            color: MAIZE_PRIMARY_LIGHT,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.30),
                                offset: Offset(2, 2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          descriptionList.last,
                          style: textTheme.bodyMedium?.copyWith(
                            letterSpacing: 1,
                            fontSize: 12.sp,
                            color: MAIZE_PRIMARY_LIGHT,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.30),
                                offset: Offset(2, 2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(height: ScreenUtil().setHeight(14)),

                    CustomButton(
                      onPressed: () {
                        showLoginOverlay(context);
                      },
                      text: S.of(context).login,
                      isPrimaryButton: true,
                    ),

                    CustomButton(
                      onPressed:
                          () => Navigator.of(
                            context,
                          ).push(CustomTransition(page: RegisterScreen())),
                      text: S.of(context).register,
                      isPrimaryButton: false,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Language toggle (positioned at the bottom)
          Positioned(
            bottom: kAppLargePadding,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v.2.0',
                style: textTheme.bodyMedium?.copyWith(
                  color: MAIZE_PRIMARY_LIGHT.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
