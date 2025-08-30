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
        if (state.status == AuthenticationStatus.registrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).registration_successful),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state.status == AuthenticationStatus.failure) {
          CustomSnackbar.showError(
            context,
            state.message ?? S.of(context).registration_failed,
          );
        }
      },
      child: Scaffold(
        appBar: RegisterAppBar(
          onBackPressed: currentPage > 0 ? _goToPreviousPage : () => Navigator.of(context).pop(),
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
    return SizedBox(
      width: isBack ? 120.w : 180.w,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isBack ? Colors.white : MAIZE_ACCENT,
          foregroundColor: isBack ? Colors.black87 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: isBack ? 1 : 3,
          shadowColor: Colors.black26,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 22.h,
                  width: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
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
    // Validate current form
    if (!_formKeys[currentPage].currentState!.validate()) return;

    if (currentPage == 0) {
      // Go to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit registration
      _submitRegistration();
    }
  }

  void _submitRegistration() {
    // Final validation including password confirmation
    if (_controllers.passwordController.text !=
        _controllers.confirmPasswordController.text) {
      CustomSnackbar.showError(context, S.of(context).passwords_dont_match);
      return;
    }

    // Combine first name and last name into fullName
    final fullName =
        '${_controllers.firstNameController.text.trim()} ${_controllers.lastNameController.text.trim()}'
            .trim();

    // Dispatch registration event
    context.read<AuthenticationBloc>().add(
      RegisterEvent(
        username: _controllers.usernameController.text.trim(),
        password: _controllers.passwordController.text,
        fullName: fullName,
        contactNumber: _controllers.contactController.text.trim(),
        address: _controllers.getAddressObject(),
        role: 'user', // Use the role as needed, e.g., 'user'
      ),
    );
  }

  @override
  void dispose() {
    _controllers.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
