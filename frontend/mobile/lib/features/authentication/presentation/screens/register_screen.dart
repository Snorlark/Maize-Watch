// register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/widgets/custom_snackbar.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/features/authentication/presentation/widgets/register_app_bar.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../generated/l10n.dart';
import '../widgets/register_form_fields.dart';
import 'registration_success_screen.dart';
import 'phone_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  final _pageController = PageController();
  final _controllers = RegisterControllers();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        print("🔍 RegisterScreen: Authentication state changed to: ${state.status}");
        print("🔍 RegisterScreen: User data available: ${state.user != null}");
        
        if (state.status == AuthenticationStatus.registrationSuccess) {
          print("🎉 Registration successful! Showing success screen...");

          // Navigate to success screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RegistrationSuccessScreen(
                    userName: _controllers.firstNameController.text,
                    onContinue: () {
                      print("🚀 Continue button pressed!");

                      // Get current authentication state when button is pressed
                      final currentState =
                          context.read<AuthenticationBloc>().state;
                      print("🔍 Current state: ${currentState.status}");
                      print(
                        "🔍 User data available: ${currentState.user != null}",
                      );

                      if (currentState.user != null) {
                        print(
                          "🔍 Context is mounted, attempting navigation...",
                        );
                        try {
                          Navigator.pushReplacementNamed(
                            context,
                            '/farm-registration',
                            arguments: {
                              'id': currentState.user!.id,
                              'username': currentState.user!.username,
                              'fullName': currentState.user!.fullName,
                              'contactNumber': currentState.user!.contactNumber,
                              'address': currentState.user!.address,
                              'role': currentState.user!.role,
                            },
                          );
                          print("✅ Navigation initiated successfully");
                        } catch (e) {
                          print("❌ Navigation error: $e");
                        }
                      } else {
                        print("❌ No user data available");
                      }
                    },
                  ),
            ),
          );
        } else if (state.status == AuthenticationStatus.authenticated) {
          print(
            "🔐 User authenticated after registration, navigating to farm registration",
          );

          // Check if widget is still mounted before navigation
          if (mounted && context.mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/farm-registration',
              arguments: {
                'id': state.user!.id,
                'username': state.user!.username,
                'fullName': state.user!.fullName,
                'contactNumber': state.user!.contactNumber,
                'address': state.user!.address,
                'role': state.user!.role,
              },
            );
          }
        } else if (state.status == AuthenticationStatus.failure) {
          CustomSnackbar.showError(
            context,
            state.message ?? S.of(context).registration_failed,
          );
        }
      },
      child: Scaffold(
        appBar: RegisterAppBar(
          onBackPressed:
              currentPage > 1
                  ? _goToPreviousPage
                  : () => Navigator.of(context).pop(),
        ),
        body: Container(
          decoration: const BoxDecoration(color: MAIZE_BOTTOM_OVERLAY),
          padding: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  children: [
                    RegisterFormPage(
                      formKey: _formKeys[0],
                      controllers: _controllers,
                      pageIndex: 0,
                    ),
                    RegisterFormPage(
                      formKey: _formKeys[1],
                      controllers: _controllers,
                      pageIndex: 1,
                    ),
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
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isLoading = state.status == AuthenticationStatus.loading;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: kAppMediumPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (currentPage > 0)
                _buildNavigationButton(
                  onPressed: isLoading ? null : _goToPreviousPage,
                  text: S.of(context).back,
                  isBack: true,
                ),
              _buildNavigationButton(
                onPressed: isLoading ? null : _handleNextOrSubmit,
                text:
                    currentPage < 1
                        ? S.of(context).next
                        : S.of(context).register,
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButton({
    required VoidCallback? onPressed,
    required String text,
    bool isBack = false,
    bool isLoading = false,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: isBack ? Colors.white : MAIZE_PRIMARY,
            foregroundColor: isBack ? MAIZE_PRIMARY : Colors.white,
            elevation: isBack ? 0 : 2,
            shadowColor:
                isBack ? Colors.transparent : MAIZE_PRIMARY.withOpacity(0.3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
        ),
        child:
              isLoading && !isBack
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
      ),
    );
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextOrSubmit() {
    print("🔍 RegisterScreen: _handleNextOrSubmit called, currentPage: $currentPage");
    
    if (!_formKeys[currentPage].currentState!.validate()) {
      print("🔍 RegisterScreen: Form validation failed");
      return;
    }

    if (currentPage < 1) {
      print("🔍 RegisterScreen: Going to next page");
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      print("🔍 RegisterScreen: Submitting registration");
      _submitRegistration();
    }
  }

  void _submitRegistration() async {
    print("🔍 RegisterScreen: _submitRegistration called");
    
    if (!_formKeys[currentPage].currentState!.validate()) {
      print("🔍 RegisterScreen: Form validation failed in submit");
      return;
    }

    final addressObject = _controllers.getAddressObject();
    print("🔍 RegisterScreen: Address object: $addressObject");

    // First, verify phone number with 2FA
    final verificationResult = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PhoneVerificationScreen(
          contactNumber: _controllers.contactController.text,
        ),
      ),
    );

    if (verificationResult == true) {
      // Phone verification successful, proceed with registration
      print("🔍 RegisterScreen: Phone verification successful, proceeding with registration");
      context.read<AuthenticationBloc>().add(
        RegisterEvent(
          username: _controllers.usernameController.text,
          password: _controllers.passwordController.text,
          fullName:
              '${_controllers.firstNameController.text} ${_controllers.lastNameController.text}',
          contactNumber: _controllers.contactController.text,
          address: addressObject,
          role: 'user',
        ),
      );
      print("🔍 RegisterScreen: RegisterEvent dispatched");
    } else {
      print("🔍 RegisterScreen: Phone verification failed or cancelled");
    }
  }

  @override
  void dispose() {
    _controllers.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
