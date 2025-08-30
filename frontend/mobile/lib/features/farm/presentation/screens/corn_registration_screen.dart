import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/farm.dart';
import '../bloc/farm_bloc.dart';
import '../widgets/corn_registration_app_bar.dart';
import '../widgets/corn_registration_form_pages.dart';
import '../widgets/corn_registration_progress_indicator.dart';

class FarmRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const FarmRegistrationScreen({
    super.key,
    required this.userData,
  });

  @override
  State<FarmRegistrationScreen> createState() => _FarmRegistrationScreenState();
}

class _FarmRegistrationScreenState extends State<FarmRegistrationScreen> {
  final PageController _pageController = PageController();
  final _formControllers = CornRegistrationControllers();
  
  int _currentStep = 1;
  static const int _totalSteps = 6;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmBloc, FarmState>(
      listener: (context, state) {
        if (state is FarmCreated) {
          // Move to completion step
          _pageController.animateToPage(
            _totalSteps - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (state is FarmError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: CornRegistrationAppBar(
          onBackPressed: _currentStep > 1 ? _goToPreviousPage : () => Navigator.of(context).pop(),
        ),
        body: Container(
          decoration: const BoxDecoration(color: MAIZE_BOTTOM_OVERLAY),
          child: Column(
            children: [
              CornRegistrationProgressIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps - 1, // Exclude completion step
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index + 1;
                    });
                  },
                  children: [
                    FieldInfoFormPage(controllers: _formControllers),
                    SoilTypeFormPage(controllers: _formControllers),
                    CornVarietyFormPage(controllers: _formControllers),
                    PlantingDateFormPage(controllers: _formControllers),
                    GrowthStageFormPage(controllers: _formControllers),
                    CompletionFormPage(controllers: _formControllers),
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
    return BlocBuilder<FarmBloc, FarmState>(
      builder: (context, state) {
        final isLoading = state is FarmLoading;
        final isCompletionStep = _currentStep == _totalSteps;

        if (isCompletionStep) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: kAppMediumPadding,
              vertical: kAppMediumPadding,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MAIZE_ACCENT,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  S.of(context).done,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: kAppMediumPadding,
            vertical: kAppMediumPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_currentStep > 1)
                _buildNavigationButton(
                  onPressed: isLoading ? null : _goToPreviousPage,
                  text: S.of(context).back,
                  isBack: true,
                ),
              _buildNavigationButton(
                onPressed: isLoading ? null : _handleNextOrSubmit,
                text: _currentStep < _totalSteps - 1
                    ? S.of(context).next
                    : S.of(context).submit,
                isLoading: isLoading && _currentStep == _totalSteps - 1,
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
        child: isLoading
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
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextOrSubmit() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitCornFieldData();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        if (_formControllers.fieldName.trim().isEmpty) {
          CustomSnackbar.showError(context, S.of(context).field_name_required);
          return false;
        }
        break;
      case 2:
        if (_formControllers.soilType.isEmpty) {
          CustomSnackbar.showError(context, S.of(context).soil_type_required);
          return false;
        }
        break;
      case 3:
        if (_formControllers.cornVariety.isEmpty) {
          CustomSnackbar.showError(context, S.of(context).corn_variety_required);
          return false;
        }
        break;
      case 4:
        if (_formControllers.plantingDate == null) {
          CustomSnackbar.showError(context, S.of(context).planting_date_required);
          return false;
        }
        break;
      case 5:
        if (_formControllers.growthStage.isEmpty) {
          CustomSnackbar.showError(context, S.of(context).growth_stage_required);
          return false;
        }
        break;
    }
    return true;
  }

  void _submitCornFieldData() {
    final user = widget.userData['user'] ?? widget.userData;
    final String userId = user['id'] ?? user['_id'] ?? user['userId'] ?? '';

    if (userId.isEmpty) {
      CustomSnackbar.showError(context, 'User ID not found');
      return;
    }

    final now = DateTime.now();
    final farm = Farm(
      userId: userId,
      fieldName: _formControllers.fieldName,
      location: _formControllers.location,
      soilType: _formControllers.soilType,
      plantingDate: _formControllers.plantingDate!,
      growthStage: _formControllers.growthStage,
      createdAt: now,
      updatedAt: now,
    );

    context.read<FarmBloc>().add(CreateFarmEvent(farm: farm));
  }

  @override
  void dispose() {
    _formControllers.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class CornRegistrationControllers {
  String fieldName = '';
  String location = 'Amadeo, Cavite';
  DateTime? plantingDate;
  String growthStage = '';
  String soilType = '';
  String cornVariety = '';

  void dispose() {
    // Add any controller disposal if needed
  }
}
