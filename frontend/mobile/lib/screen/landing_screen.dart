import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/custom/custom_login_overlay.dart';
import 'package:maize_watch/screen/register_screen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/widget/language_toggle.dart';

class LandingScreen extends StatefulWidget {
  final bool showLoginOnLoad;

  const LandingScreen({super.key, this.showLoginOnLoad = false});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
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

    String description_split = AppLocalizations.of(context)!.description;
    List<String> description_list = description_split.split(",");

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background-landing.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setSp(30)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [ 
                    CustomFont(
                      text: 'v.1.0',
                      color: const Color.fromARGB(209, 255, 255, 255),
                    ),
                  ]
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/maize_watch_logo.png',
                          width: 200.w,
                          height: 200.h,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          'MAIZE WATCH',
                          style: GoogleFonts.righteous(
                            color: Color(0xFFe0f6bc),
                            fontSize: ScreenUtil().setSp(32),
                            letterSpacing: 5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.30),
                                offset: Offset(2, 2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            CustomFont(
                              text: "${description_list.first}, ",
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1,
                              color: MAIZE_PRIMARY_LIGHT,
                              fontSize: 15,
                              textAlign: TextAlign.center,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.30),
                                  offset: Offset(2, 2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            CustomFont(
                              text: description_list.last,
                              fontStyle: FontStyle.normal,
                              letterSpacing: 1,
                              color: MAIZE_PRIMARY_LIGHT,
                              fontSize: 15,
                              textAlign: TextAlign.center,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.30),
                                  offset: Offset(2, 2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            showLoginOverlay(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF72AB50),
                            fixedSize: Size.fromWidth(200.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: CustomFont(
                            text: AppLocalizations.of(context)!.login,
                            fontWeight: FontWeight.bold,
                            color: MAIZE_PRIMARY_LIGHT,
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setHeight(20)),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MAIZE_PRIMARY_LIGHT,
                            fixedSize: Size.fromWidth(200.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: CustomFont(
                            text: AppLocalizations.of(context)!.register,
                            color: Color(0xFF72AB50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: const LanguageToggleLocale(color_toggle: MAIZE_PRIMARY_LIGHT),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
