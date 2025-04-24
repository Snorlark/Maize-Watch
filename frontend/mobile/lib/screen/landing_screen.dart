import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/custom/custom_login_overlay.dart';
import 'package:maize_watch/screen/register_screen.dart';

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
    
    // Show login overlay after the widget is built if showLoginOnLoad is true
    if (widget.showLoginOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showLoginOverlay(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/GRADIENT.png', // Ensure bg.png is in assets/images folder
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setSp(30)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/maize_watch_logo.png', // Ensure bg.png is in assets/images folder
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'MAIZE WATCH',
                    style: GoogleFonts.righteous(
                      color: Color(0xFFDDFFD7),
                      fontSize: ScreenUtil().setSp(32),
                      letterSpacing: 5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.30), // Adjust opacity for subtle effect
                          offset: Offset(2, 2), // Horizontal and vertical displacement
                          blurRadius: 10, // Increases softness of the shadowr
                        ),
                      ],
                    )
                  ),
                  const SizedBox(height: 10),
                  // Slogan Text
                  CustomFont(
                    text: 'Maximize your yields, minimize your worries.',
                    color: Colors.white,
                    fontSize: 15, 
                    textAlign: TextAlign.center,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.30), // Adjust opacity for subtle effect
                          offset: Offset(2, 2), // Horizontal and vertical displacement
                          blurRadius: 10, // Increases softness of the shadowr
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
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: CustomFont(
                      text: 'Log In',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(20)),
                  // Register Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF72AB50),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: CustomFont(
                      text: 'Register',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )    
        ],
      ),
    );
  }
}