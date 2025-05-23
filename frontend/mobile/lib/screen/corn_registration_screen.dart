import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/screen/home_screen.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/widget/language_toggle.dart';

class CornRegistrationScreen extends StatefulWidget {
  // Get user data from previous registration
  final Map<String, dynamic> userData;

  const CornRegistrationScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  _CornRegistrationScreenState createState() => _CornRegistrationScreenState();
}

class _CornRegistrationScreenState extends State<CornRegistrationScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();

  // Current step index (1-based for UI display)
  int _currentStep = 1;

  // Form field values
  String fieldName = '';
  String location = 'Amadeo, Cavite';
  DateTime? plantingDate;
  String growthStage = '';
  String soilType = '';
  String cornVariety = '';

  // Loading state
  bool isLoading = false;

  // Growth stage options

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> growthStages = [
      {
        'id': 'VE',
        'name': AppLocalizations.of(context)!.growth_stage_ve,
        'icon': '🌱',
        'description': AppLocalizations.of(context)!.growth_stage_ve_desc,
      },
      {
        'id': 'V3',
        'name': AppLocalizations.of(context)!.growth_stage_v3,
        'icon': '🌿',
        'description': AppLocalizations.of(context)!.growth_stage_v3_desc,
      },
      {
        'id': 'V8',
        'name': AppLocalizations.of(context)!.growth_stage_v8,
        'icon': '🌱🌿',
        'description': AppLocalizations.of(context)!.growth_stage_v8_desc,
      },
      {
        'id': 'VT',
        'name': AppLocalizations.of(context)!.growth_stage_vt,
        'icon': '🌾',
        'description': AppLocalizations.of(context)!.growth_stage_vt_desc,
      },
      {
        'id': 'R1',
        'name': AppLocalizations.of(context)!.growth_stage_r1,
        'icon': '🌽',
        'description': AppLocalizations.of(context)!.growth_stage_r1_desc,
      },
      {
        'id': 'R6',
        'name': AppLocalizations.of(context)!.growth_stage_r6,
        'icon': '🌽',
        'description': AppLocalizations.of(context)!.growth_stage_r6_desc,
      },
    ];

    final List<Map<String, dynamic>> soilTypes = [
      {
        'id': 'loamy',
        'name': AppLocalizations.of(context)!.soil_loamy,
        'icon': '🟤',
        'description': AppLocalizations.of(context)!.soil_loamy_desc,
      },
      {
        'id': 'sandy',
        'name': AppLocalizations.of(context)!.soil_sandy,
        'icon': '🟡',
        'description': AppLocalizations.of(context)!.soil_sandy_desc,
      },
      {
        'id': 'clay',
        'name': AppLocalizations.of(context)!.soil_clay,
        'icon': '🟠',
        'description': AppLocalizations.of(context)!.soil_clay_desc,
      },
      {
        'id': 'silty',
        'name': AppLocalizations.of(context)!.soil_silty,
        'icon': '🟣',
        'description': AppLocalizations.of(context)!.soil_silty_desc,
      },
    ];

    final List<Map<String, dynamic>> cornVarieties = [
      {
        'id': 'sweetCorn',
        'name': AppLocalizations.of(context)!.variety_sweet_corn,
        'icon': '🌽',
        'description': AppLocalizations.of(context)!.variety_sweet_corn_desc,
      },
      {
        'id': 'fieldCorn',
        'name': AppLocalizations.of(context)!.variety_field_corn,
        'icon': '🌾',
        'description': AppLocalizations.of(context)!.variety_field_corn_desc,
      },
      {
        'id': 'popcorn',
        'name': AppLocalizations.of(context)!.variety_popcorn,
        'icon': '🍿',
        'description': AppLocalizations.of(context)!.variety_popcorn_desc,
      },
      {
        'id': 'flintCorn',
        'name': AppLocalizations.of(context)!.variety_flint_corn,
        'icon': '🌈',
        'description': AppLocalizations.of(context)!.variety_flint_corn_desc,
      },
    ];

    return Scaffold(
      // appBar: AppBar(
      //   leading: _currentStep > 1
      //       ? IconButton(
      //           icon: const Icon(Icons.arrow_back),
      //           onPressed: () {
      //             if (_currentStep > 1) {
      //               setState(() {
      //                 _currentStep--;
      //               });
      //               _pageController.animateToPage(
      //                 _currentStep - 1,
      //                 duration: const Duration(milliseconds: 300),
      //                 curve: Curves.ease,
      //               );
      //             }
      //           },
      //         )
      //       : null,
      // ),
      body: Container(
        decoration: BoxDecoration(color: MAIZE_BOTTOM_OVERLAY),
        child: Column(
          children: [
            _buildProgressIndicator(),
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
                  _buildFieldInfoStep(),
                  _buildSoilTypeStep(soilTypes),
                  _buildCornVarietyStep(cornVarieties),
                  _buildPlantingDateStep(),
                  _buildGrowthStageStep(growthStages),
                  _buildCompletionStep(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: const LanguageToggleLocale(color_toggle: MAIZE_ACCENT),
            ),
          ],
        ),
      ),
    );
  }

  // Submit corn field data to API
  Future<void> _submitCornFieldData() async {
    if (fieldName.isEmpty ||
        soilType.isEmpty ||
        cornVariety.isEmpty ||
        plantingDate == null ||
        growthStage.isEmpty) {
      _showSnackBar(
        message: AppLocalizations.of(context)!.all_fields_required,
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get user ID from userData
      final String userId = widget.userData['userId'] ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID not found');
      }

      // Prepare corn field data
      final Map<String, dynamic> cornFieldData = {
        'fieldName': fieldName,
        'location': location,
        'soilType': soilType,
        'cornVariety': cornVariety,
        'plantingDate': plantingDate!.toIso8601String(),
        'growthStage': growthStage,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Submit data to API
      final response =
          await _apiService.registerCornField(userId, cornFieldData);

      if (response.success) {
        // Move to completion step
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _showSnackBar(
          message: response.message ??
              AppLocalizations.of(context)!.registration_failed,
          isError: true,
        );
      }
    } catch (e) {
      print('Error submitting corn field data: $e');
      _showSnackBar(
        message: AppLocalizations.of(context)!.connection_error,
        isError: true,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding:
          EdgeInsets.only(right: 20.w, left: 20.w, top: 70.h, bottom: 20.h),
      child: Column(
        children: [
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var label in [
                AppLocalizations.of(context)!.step1_title,
                AppLocalizations.of(context)!.step2_title,
                AppLocalizations.of(context)!.step3_title,
                AppLocalizations.of(context)!.step4_title,
                AppLocalizations.of(context)!.step5_title
              ])
                Container(
                  width: 60.w,
                  child: CustomFont(
                    text: label,
                    fontSize: 12.sp,
                    color: MAIZE_ACCENT,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          SizedBox(height: 5.h),
          // Progress bar
          Container(
            height: 20.h,
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: MAIZE_PRIMARY_LIGHT,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  margin: EdgeInsets.only(top: 8.h),
                ),
                // Filled progress
                Container(
                  height: 4.h,
                  width: MediaQuery.of(context).size.width *
                      ((_currentStep - 1) / 5) *
                      0.99,
                  decoration: BoxDecoration(
                    color: MAIZE_ACCENT,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  margin: EdgeInsets.only(top: 8.h, left: 19.w),
                ),
                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final stepNum = index + 1;
                    return Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: _currentStep >= stepNum
                            ? MAIZE_ACCENT
                            : MAIZE_PRIMARY_LIGHT,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$stepNum',
                          style: TextStyle(
                            color: _currentStep >= stepNum
                                ? MAIZE_PRIMARY_LIGHT
                                : MAIZE_ACCENT,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: Field Info
  Widget _buildFieldInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: CustomFont(
                  text: AppLocalizations.of(context)?.field_information ??
                      'Field Information',
                  fontSize: 35.sp,
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Field name input
          _buildInputField(
            label: AppLocalizations.of(context)?.field_name ?? 'Field Name',
            icon: '🌱',
            hintText: 'e.g. North Field',
            value: fieldName,
            onChanged: (value) {
              setState(() {
                fieldName = value;
              });
            },
          ),
          SizedBox(height: 15.h),

          // Location input
          _buildInputField(
            label: AppLocalizations.of(context)?.location ?? 'Location',
            icon: '📍',
            hintText: 'Amadeo, Cavite',
            value: location,
            onChanged: (value) {
              setState(() {
                location = value;
              });
            },
          ),
          CustomFont(
            text: 'Default: Amadeo, Cavite',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: MAIZE_ACCENT,
          ),
          SizedBox(height: 30.h),

          // Next button
          ElevatedButton(
            onPressed: () {
              if (fieldName.trim().isEmpty) {
                _showSnackBar(
                  message: AppLocalizations.of(context)!.field_name_required,
                  isError: true,
                );
                return;
              }
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF72AB50),
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: CustomFont(
              text: AppLocalizations.of(context)?.next ?? 'Next',
              color: MAIZE_PRIMARY_LIGHT,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Soil Type
  Widget _buildSoilTypeStep(dynamic soilTypes) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: CustomFont(
                  text: AppLocalizations.of(context)!.soil_type,
                  fontSize: 35.sp,
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          CustomFont(
            text: AppLocalizations.of(context)!.soil_type_title,
            color: MAIZE_ACCENT,
          ),

          // Soil type grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.3,
            ),
            itemCount: soilTypes.length,
            itemBuilder: (context, index) {
              final soil = soilTypes[index];
              final isSelected = soilType == soil['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    soilType = soil['id'];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? MAIZE_PRIMARY : MAIZE_PRIMARY_LIGHT,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    color: isSelected ? MAIZE_PRIMARY_LIGHT : Colors.white,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color.fromARGB(255, 81, 81, 81)
                                  .withOpacity(0.8),
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        soil['icon'],
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(height: 5.h),
                      CustomFont(
                          text: soil['name'],
                          fontWeight: FontWeight.w600,
                          color: MAIZE_ACCENT),
                      SizedBox(height: 3.h),
                      CustomFont(
                        text: soil['description'],
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w300,
                        color: MAIZE_ACCENT,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY_LIGHT,
                    foregroundColor: Colors.grey.shade700,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: CustomFont(
                    text: AppLocalizations.of(context)?.back ?? 'Back',
                    fontWeight: FontWeight.w600,
                    color: MAIZE_PRIMARY,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (soilType.isEmpty) {
                      _showSnackBar(
                        message:
                            AppLocalizations.of(context)!.corn_variety_required,
                        isError: true,
                      );
                      return;
                    }
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF72AB50),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: CustomFont(
                    text: AppLocalizations.of(context)?.next ?? 'Next',
                    color: MAIZE_PRIMARY_LIGHT,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 3: Corn Variety
  Widget _buildCornVarietyStep(dynamic cornVarieties) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: CustomFont(
                  text: AppLocalizations.of(context)!.corn_variety,
                  fontSize: 35.sp,
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          CustomFont(
            text: AppLocalizations.of(context)!.corn_variety_title,
            color: MAIZE_ACCENT,
          ),

          // Corn variety grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.3,
            ),
            itemCount: cornVarieties.length,
            itemBuilder: (context, index) {
              final variety = cornVarieties[index];
              final isSelected = cornVariety == variety['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    cornVariety = variety['id'];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? MAIZE_PRIMARY : MAIZE_PRIMARY_LIGHT,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    color: isSelected ? MAIZE_PRIMARY_LIGHT : Colors.white,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color.fromARGB(255, 81, 81, 81)
                                  .withOpacity(0.8),
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        variety['icon'],
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(height: 5.h),
                      CustomFont(
                        text: variety['name'],
                        color: MAIZE_ACCENT,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      CustomFont(
                        text: variety['description'],
                        fontSize: 13.sp,
                        color: MAIZE_ACCENT,
                        fontWeight: FontWeight.w300,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY_LIGHT,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: CustomFont(
                    text: AppLocalizations.of(context)?.back ?? 'Back',
                    fontWeight: FontWeight.w600,
                    color: MAIZE_PRIMARY,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (cornVariety.isEmpty) {
                      _showSnackBar(
                        message:
                            AppLocalizations.of(context)!.corn_variety_required,
                        isError: true,
                      );
                      return;
                    }
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF72AB50),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: CustomFont(
                    text: AppLocalizations.of(context)?.next ?? 'Next',
                    color: MAIZE_PRIMARY_LIGHT,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 4: Planting Date
  Widget _buildPlantingDateStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: CustomFont(
                  text: AppLocalizations.of(context)!.planting_season_title,
                  fontSize: 35.sp,
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          CustomFont(
            text: AppLocalizations.of(context)!.planting_season_description,
            color: MAIZE_ACCENT,
          ),
          SizedBox(height: 30.h),

          // Planting icon
          Center(
            child: Stack(alignment: Alignment(0.0, 0.0), children: [
              Container(
                padding: EdgeInsets.all(10),
                width: 100.w,
                height: 80.h,
                decoration: BoxDecoration(
                    color: MAIZE_PRIMARY,
                    borderRadius: BorderRadius.circular(100)),
              ),
              Text(
                '🌱',
                style: TextStyle(fontSize: 70.sp),
              ),
            ]),
          ),
          SizedBox(height: 30.h),

          // Date picker field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFont(
                text: AppLocalizations.of(context)?.planting_date ??
                    'Planting Date',
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: MAIZE_ACCENT,
              ),
              SizedBox(height: 5.h),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: plantingDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: MAIZE_ACCENT,
                            onPrimary: MAIZE_PRIMARY_LIGHT,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    setState(() {
                      plantingDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: MAIZE_PRIMARY_LIGHT,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: MAIZE_PRIMARY_LIGHT,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.r),
                            bottomLeft: Radius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          '📅',
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            plantingDate != null
                                ? '${plantingDate!.day}/${plantingDate!.month}/${plantingDate!.year}'
                                : AppLocalizations.of(context)?.select_date ??
                                    'Select date',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: plantingDate != null
                                  ? MAIZE_ACCENT
                                  : MAIZE_ACCENT,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY_LIGHT,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: CustomFont(
                    text: AppLocalizations.of(context)?.back ?? 'Back',
                    fontWeight: FontWeight.w600,
                    color: MAIZE_PRIMARY,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (plantingDate == null) {
                      _showSnackBar(
                        message: AppLocalizations.of(context)!
                            .planting_date_required,
                        isError: true,
                      );
                      return;
                    }
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF72AB50),
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: CustomFont(
                    text: AppLocalizations.of(context)?.next ?? 'Next',
                    color: MAIZE_PRIMARY_LIGHT,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Step 5: Growth Stage
  Widget _buildGrowthStageStep(dynamic growthStages) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomFont(
                  text: AppLocalizations.of(context)?.growth_stage ??
                      'Growth Stage',
                  fontSize: 35.sp,
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CustomFont(
            text: AppLocalizations.of(context)!.corn_age_title,
            color: MAIZE_ACCENT,
          ),

          // Growth stage grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.3,
            ),
            itemCount: growthStages.length,
            itemBuilder: (context, index) {
              final stage = growthStages[index];
              final isSelected = growthStage == stage['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    growthStage = stage['id'];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? MAIZE_PRIMARY : MAIZE_PRIMARY_LIGHT,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    color: isSelected ? MAIZE_PRIMARY_LIGHT : Colors.white,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color.fromARGB(255, 81, 81, 81)
                                  .withOpacity(0.8),
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stage['icon'],
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(height: 5.h),
                      CustomFont(
                        text: stage['name'],
                        fontWeight: FontWeight.w600,
                        color: MAIZE_ACCENT,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.h),
                      CustomFont(
                        text: stage['description'],
                        fontWeight: FontWeight.w300,
                        fontSize: 13.sp,
                        color: MAIZE_ACCENT,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY_LIGHT,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: CustomFont(
                    text: AppLocalizations.of(context)?.back ?? 'Back',
                    fontWeight: FontWeight.w600,
                    color: MAIZE_PRIMARY,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (growthStage.isEmpty) {
                      _showSnackBar(
                        message:
                            AppLocalizations.of(context)!.growth_stage_required,
                        isError: true,
                      );
                      return;
                    }

                    // Submit corn field data to API
                    _submitCornFieldData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
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
                          text:
                              AppLocalizations.of(context)?.submit ?? 'Submit',
                          color: MAIZE_PRIMARY_LIGHT,
                          fontWeight: FontWeight.w600,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Step 6: Completion Step
  Widget _buildCompletionStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80.w,
            color: MAIZE_ACCENT,
          ),
          SizedBox(height: 20.h),
          CustomFont(
            text: AppLocalizations.of(context)!.registration_successful,
            fontSize: 24.sp,
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          CustomFont(
            text: AppLocalizations.of(context)!.corn_registration,
            color: MAIZE_ACCENT,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          // Registration summary
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: MAIZE_PRIMARY_LIGHT, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem(
                  AppLocalizations.of(context)!.field_name,
                  fieldName,
                ),
                _buildSummaryItem(
                  AppLocalizations.of(context)!.location,
                  location,
                ),
                _buildSummaryItem(
                  AppLocalizations.of(context)!.soil_type,
                  soilType,
                ),
                _buildSummaryItem(
                  AppLocalizations.of(context)!.corn_variety,
                  cornVariety,
                ),
                _buildSummaryItem(
                  AppLocalizations.of(context)!.planting_date,
                  plantingDate != null
                      ? '${plantingDate!.day}/${plantingDate!.month}/${plantingDate!.year}'
                      : 'Not selected',
                ),
                _buildSummaryItem(
                  AppLocalizations.of(context)!.growth_stage,
                  growthStage,
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to the appropriate screen after completion
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF72AB50),
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: CustomFont(
              text: AppLocalizations.of(context)!.done,
              color: MAIZE_PRIMARY_LIGHT,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CustomFont(
              text: '$label:',
              fontWeight: FontWeight.w500,
              color: MAIZE_ACCENT,
            ),
          ),
          Expanded(
            flex: 3,
            child: CustomFont(
              text: value,
              color: MAIZE_ACCENT,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar({required String message, required bool isError}) {
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

  Widget _buildInputField({
    required String label,
    required String icon,
    required String hintText,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFont(
          text: '$icon $label',
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: MAIZE_ACCENT,
        ),
        SizedBox(height: 5.h),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: MAIZE_PRIMARY_LIGHT,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            errorStyle: TextStyle(color: Colors.red.shade700),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
