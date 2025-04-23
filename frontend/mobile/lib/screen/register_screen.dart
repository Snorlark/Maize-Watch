import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/api_service.dart'; // Import API service
import '../model/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService(); // Create API service instance

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/GRADIENT.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.all(30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: CustomFont(
                          text: 'Create an account',
                          fontWeight: FontWeight.bold,
                          fontSize: 22.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Scrollable Form
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputField('Name', 'Full Name', nameController, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          }),
                          SizedBox(height: 20.h),
                          _buildInputField('Contact Number', '+63', contactController, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Contact number is required';
                            }
                            final regex = RegExp(r'^(09\d{9}|\+639\d{9})$');
                            if (!regex.hasMatch(value)) {
                              return 'Enter a valid PH mobile number (e.g., +639123456789 or 09123456789)';
                            }
                            return null;
                          }),
                          SizedBox(height: 20.h),
                          _buildInputField('Address', 'St. Name, House No., Brgy., Province', addressController, isMultiline: true, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          }),
                          SizedBox(height: 20.h),
                          _buildInputField('Username', '@', usernameController, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          }),
                          SizedBox(height: 20.h),
                          _buildPasswordField('Password', passwordController, true),
                          SizedBox(height: 20.h),
                          _buildPasswordField('Confirm Password', confirmPasswordController, false),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed Register Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF72AB50),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                  onPressed: isLoading ? null : _handleRegistration,
                  child: isLoading 
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : CustomFont(
                          text: 'Register',
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Create user object with all details
        final userData = {
          'fullName': nameController.text,
          'contactNumber': contactController.text,
          'address': addressController.text,
          'username': usernameController.text,
          'password': passwordController.text,
        };
        
        // Call register API
        final response = await _apiService.register(userData);
        
        setState(() {
          isLoading = false;
        });
        
        if (response.success) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful! You can now log in.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to login screen after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        } else {
          // Registration failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Registration failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error. Please check your internet connection and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isMultiline = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFont(
          text: label,
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: Colors.black,
        ),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          maxLines: isMultiline ? 3 : 1,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFDDFFD7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isPasswordField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFont(
          text: label,
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: Colors.black,
        ),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          obscureText: isPasswordField ? !isPasswordVisible : !isConfirmPasswordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFDDFFD7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordField
                    ? (isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                    : (isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                color: const Color(0xFF72AB50),
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
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (!isPasswordField && value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    nameController.dispose();
    contactController.dispose();
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}