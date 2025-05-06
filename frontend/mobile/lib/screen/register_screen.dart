import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/screen/landing_screen.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/widget/language_toggle.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MAIZE_BOTTOM_OVERLAY,
        foregroundColor: MAIZE_ACCENT,
        actionsPadding: EdgeInsets.only(right: 30.w),
        actions: [LanguageToggleLocale(color_toggle: MAIZE_ACCENT)],
      ),
      body: Container(
        decoration: BoxDecoration(color: MAIZE_BOTTOM_OVERLAY),
        child: Padding(
          padding: EdgeInsets.all(30.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => currentPage = index),
                  children: [
                    Form(key: _formKeys[0], child: _buildPageOne()),
                    Form(key: _formKeys[1], child: _buildPageTwo())
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (currentPage > 0)
              ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MAIZE_PRIMARY_LIGHT,
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                ),
                child: CustomFont(
                    text: AppLocalizations.of(context)!.back,
                    color: Color(0xFF72AB50)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF72AB50),
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
              ),
              onPressed: isLoading ? null : _nextOrSubmit,
              child: isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.0),
                    )
                  : CustomFont(
                      text: currentPage < 1
                          ? AppLocalizations.of(context)!.next
                          : AppLocalizations.of(context)!.register,
                      color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageOne() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomFont(
            text: AppLocalizations.of(context)!.register_page1_title,
            fontSize: 35.sp,
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.bold,
            height: 1,
            letterSpacing: 0,
          ),
          SizedBox(height: 10.h),
          CustomFont(
            text: AppLocalizations.of(context)!.register_page1_description,
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.w300,
          ),
          SizedBox(height: 30.h),
          _buildInputField(AppLocalizations.of(context)!.first_name, 'Juan',
              firstnameController, validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.first_name_required;
            }
            return null;
          }),
          SizedBox(height: 20.h),
          _buildInputField(AppLocalizations.of(context)!.last_name, 'Dela Cruz',
              lastnameController, validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.last_name_required;
            }
            return null;
          }),
          SizedBox(height: 20.h),
          _buildInputField(AppLocalizations.of(context)!.contact_number, '+63',
              contactController, validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.contact_number_required;
            }
            final regex = RegExp(r'^(09\d{9}|\+639\d{9})$');
            if (!regex.hasMatch(value)) {
              return AppLocalizations.of(context)!.valid_ph_number_required;
            }
            return null;
          }),
          SizedBox(height: 20.h),
          _buildInputField(AppLocalizations.of(context)!.address,
              'St. Name, House No., Brgy., Province', addressController,
              isMultiline: true, validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.address_required;
            }
            return null;
          }),
        ],
      ),
    );
  }

  Widget _buildPageTwo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomFont(
            text: AppLocalizations.of(context)!.register_page2_title +
                firstnameController.text,
            fontSize: 35.sp,
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.bold,
            height: 1,
            letterSpacing: 0,
          ),
          SizedBox(height: 10.h),
          CustomFont(
            text: AppLocalizations.of(context)!.register_page2_description,
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.w300,
          ),
          SizedBox(height: 20.h),
          _buildInputField('Username', '@', usernameController,
              validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.username_required;
            }
            if (value.length < 3) {
              return AppLocalizations.of(context)!.username_too_short;
            }
            return null;
          }),
          SizedBox(height: 20.h),
          _buildPasswordField('Password', passwordController, true),
          SizedBox(height: 20.h),
          _buildPasswordField(
              'Confirm Password', confirmPasswordController, false),
        ],
      ),
    );
  }

  Future<void> _nextOrSubmit() async {
    final isValid = _formKeys[currentPage].currentState?.validate() ?? false;
    if (!isValid) return;

    if (currentPage == 0) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _handleRegistration();
    }
  }

  Future<void> _handleRegistration() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    setState(() => isLoading = true);

    try {
      final userData = {
        'fullName': '${firstnameController.text} ${lastnameController.text}',
        'contactNumber': contactController.text,
        'address': addressController.text,
        'username': usernameController.text,
        'password': passwordController.text,
      };

      final response = await _apiService.register(userData);

      if (response.success) {
        // Immediately attempt to login with the new credentials
        await _loginAfterRegistration(
          usernameController.text, 
          passwordController.text
        );
      } else {
        // Handle different error cases
        _handleRegistrationError(response.message);
      }
    } catch (e) {
      _showSnackBar(
        message: AppLocalizations.of(context)!.connection_error,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  
  Future<void> _loginAfterRegistration(String username, String password) async {
    try {
      // Call the login API
      final loginResponse = await _apiService.login(username, password);
      
      if (loginResponse.success) {
        // Navigate to main screen
        if (mounted) {
          // Import your main screen and navigate to it
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main', // Replace with your main screen route
            (route) => false, // Remove all previous routes
          );
          
          // Show success message after navigation (in the main screen)
          // We need to delay slightly to ensure the new screen is built
          Future.delayed(Duration(milliseconds: 300), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.registration_successful,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Color(0xFF72AB50),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        }
      } else {
        // If login fails after registration (should be rare)
        _showSnackBar(
          message: "${AppLocalizations.of(context)!.registration_successful} ${AppLocalizations.of(context)!.login_failed}",
          isError: true,
        );
        
        // Navigate back to landing page with login dialog
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => LandingScreen(showLoginOnLoad: true)),
          );
        }
      }
    } catch (e) {
      // Handle login error
      _showSnackBar(
        message: "${AppLocalizations.of(context)!.registration_successful} ${AppLocalizations.of(context)!.login_failed}",
        isError: true,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => LandingScreen(showLoginOnLoad: true)),
        );
      }
    }
  }

  void _handleRegistrationError(String? errorMessage) {
    String displayMessage;
    
    // Check for common error cases
    if (errorMessage?.contains('username already exists') ?? false) {
      displayMessage = AppLocalizations.of(context)!.username_already_exists;
    } 
    else if (errorMessage?.contains('timeout') ?? false) {
      displayMessage = AppLocalizations.of(context)!.registration_timeout;
    }
    else {
      // Generic error if no specific case matched
      displayMessage = errorMessage ?? AppLocalizations.of(context)!.registration_failed;
    }
    
    _showSnackBar(message: displayMessage, isError: true);
  }

  void _showSnackBar({required String message, required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Color(0xFF72AB50),
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller,
      {bool isMultiline = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFont(
          text: label,
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: MAIZE_ACCENT,
        ),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          maxLines: isMultiline ? 3 : 1,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: MAIZE_PRIMARY_LIGHT,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            errorStyle: TextStyle(color: Colors.red.shade700),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller, bool isPasswordField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFont(
          text: label,
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: MAIZE_ACCENT,
        ),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          obscureText:
              isPasswordField ? !isPasswordVisible : !isConfirmPasswordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFDDFFD7),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            errorStyle: TextStyle(color: Colors.red.shade700),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordField
                    ? (isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off)
                    : (isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                color: Color(0xFF72AB50),
              ),
              onPressed: () {
                setState(() {
                  if (isPasswordField) {
                    isPasswordVisible = !isPasswordVisible;
                  } else {
                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                  }
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.password_required;
            }
            if (value.length < 6) {
              return AppLocalizations.of(context)!.password_too_short;
            }
            if (!isPasswordField && value != passwordController.text) {
              return AppLocalizations.of(context)!.passwords_dont_match;
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    contactController.dispose();
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}