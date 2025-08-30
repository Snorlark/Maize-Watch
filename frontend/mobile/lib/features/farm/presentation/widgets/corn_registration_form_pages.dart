import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../generated/l10n.dart';
import '../screens/corn_registration_screen.dart';

// Field Information Page
class FieldInfoFormPage extends StatelessWidget {
  final CornRegistrationControllers controllers;

  const FieldInfoFormPage({
    super.key,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).field_information,
            style: TextStyle(
              fontSize: 32.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          verticalSpace(24),
          _buildInputField(
            context: context,
            label: S.of(context).field_name,
            icon: '🌱',
            hintText: 'e.g. North Field',
            value: controllers.fieldName,
            onChanged: (value) => controllers.fieldName = value,
          ),
          verticalSpace(16),
          _buildInputField(
            context: context,
            label: S.of(context).location,
            icon: '📍',
            hintText: 'Amadeo, Cavite',
            value: controllers.location,
            onChanged: (value) => controllers.location = value,
          ),
          verticalSpace(8),
          Text(
            'Default: Amadeo, Cavite',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: MAIZE_ACCENT.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Soil Type Selection Page
class SoilTypeFormPage extends StatefulWidget {
  final CornRegistrationControllers controllers;

  const SoilTypeFormPage({
    super.key,
    required this.controllers,
  });

  @override
  State<SoilTypeFormPage> createState() => _SoilTypeFormPageState();
}

class _SoilTypeFormPageState extends State<SoilTypeFormPage> {
  @override
  Widget build(BuildContext context) {
    final soilTypes = [
      {
        'id': 'loamy',
        'name': S.of(context).soil_loamy,
        'icon': '🟤',
        'description': S.of(context).soil_loamy_desc,
      },
      {
        'id': 'sandy',
        'name': S.of(context).soil_sandy,
        'icon': '🟡',
        'description': S.of(context).soil_sandy_desc,
      },
      {
        'id': 'clay',
        'name': S.of(context).soil_clay,
        'icon': '🟠',
        'description': S.of(context).soil_clay_desc,
      },
      {
        'id': 'silty',
        'name': S.of(context).soil_silty,
        'icon': '🟣',
        'description': S.of(context).soil_silty_desc,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).soil_type,
            style: TextStyle(
              fontSize: 32.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          verticalSpace(8),
          Text(
            S.of(context).soil_type_title,
            style: TextStyle(
              fontSize: 16.sp,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: kAppMediumGap,
              mainAxisSpacing: kAppMediumGap,
              childAspectRatio: 1.3,
            ),
            itemCount: soilTypes.length,
            itemBuilder: (context, index) {
              final soil = soilTypes[index];
              final isSelected = widget.controllers.soilType == soil['id'];
              
              return _buildSelectionCard(
                isSelected: isSelected,
                icon: soil['icon'] as String,
                title: soil['name'] as String,
                description: soil['description'] as String,
                onTap: () {
                  setState(() {
                    widget.controllers.soilType = soil['id'] as String;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Corn Variety Selection Page
class CornVarietyFormPage extends StatefulWidget {
  final CornRegistrationControllers controllers;

  const CornVarietyFormPage({
    super.key,
    required this.controllers,
  });

  @override
  State<CornVarietyFormPage> createState() => _CornVarietyFormPageState();
}

class _CornVarietyFormPageState extends State<CornVarietyFormPage> {
  @override
  Widget build(BuildContext context) {
    final cornVarieties = [
      {
        'id': 'sweetCorn',
        'name': S.of(context).variety_sweet_corn,
        'icon': '🌽',
        'description': S.of(context).variety_sweet_corn_desc,
      },
      {
        'id': 'fieldCorn',
        'name': S.of(context).variety_field_corn,
        'icon': '🌾',
        'description': S.of(context).variety_field_corn_desc,
      },
      {
        'id': 'popcorn',
        'name': S.of(context).variety_popcorn,
        'icon': '🍿',
        'description': S.of(context).variety_popcorn_desc,
      },
      {
        'id': 'flintCorn',
        'name': S.of(context).variety_flint_corn,
        'icon': '🌈',
        'description': S.of(context).variety_flint_corn_desc,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).corn_variety,
            style: TextStyle(
              fontSize: 32.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          verticalSpace(8),
          Text(
            S.of(context).corn_variety_title,
            style: TextStyle(
              fontSize: 16.sp,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: kAppMediumGap,
              mainAxisSpacing: kAppMediumGap,
              childAspectRatio: 1.3,
            ),
            itemCount: cornVarieties.length,
            itemBuilder: (context, index) {
              final variety = cornVarieties[index];
              final isSelected = widget.controllers.cornVariety == variety['id'];
              
              return _buildSelectionCard(
                isSelected: isSelected,
                icon: variety['icon'] as String,
                title: variety['name'] as String,
                description: variety['description'] as String,
                onTap: () {
                  setState(() {
                    widget.controllers.cornVariety = variety['id'] as String;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Planting Date Selection Page
class PlantingDateFormPage extends StatefulWidget {
  final CornRegistrationControllers controllers;

  const PlantingDateFormPage({
    super.key,
    required this.controllers,
  });

  @override
  State<PlantingDateFormPage> createState() => _PlantingDateFormPageState();
}

class _PlantingDateFormPageState extends State<PlantingDateFormPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).planting_season_title,
            style: TextStyle(
              fontSize: 32.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          verticalSpace(8),
          Text(
            S.of(context).planting_season_description,
            style: TextStyle(
              fontSize: 16.sp,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(40),
          // Planting icon
          Center(
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: MAIZE_PRIMARY,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Center(
                child: Text(
                  '🌱',
                  style: TextStyle(fontSize: 50.sp),
                ),
              ),
            ),
          ),
          verticalSpace(40),
          // Date picker field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).planting_date,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: MAIZE_ACCENT,
                ),
              ),
              verticalSpace(8),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.controllers.plantingDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: MAIZE_ACCENT,
                            onPrimary: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      widget.controllers.plantingDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '📅',
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      horizontalSpace(12),
                      Expanded(
                        child: Text(
                          widget.controllers.plantingDate != null
                              ? '${widget.controllers.plantingDate!.day}/${widget.controllers.plantingDate!.month}/${widget.controllers.plantingDate!.year}'
                              : S.of(context).select_date,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: widget.controllers.plantingDate != null
                                ? MAIZE_ACCENT
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Growth Stage Selection Page
class GrowthStageFormPage extends StatefulWidget {
  final CornRegistrationControllers controllers;

  const GrowthStageFormPage({
    super.key,
    required this.controllers,
  });

  @override
  State<GrowthStageFormPage> createState() => _GrowthStageFormPageState();
}

class _GrowthStageFormPageState extends State<GrowthStageFormPage> {
  @override
  Widget build(BuildContext context) {
    final growthStages = [
      {
        'id': 'VE',
        'name': S.of(context).growth_stage_ve,
        'icon': '🌱',
        'description': S.of(context).growth_stage_ve_desc,
      },
      {
        'id': 'V3',
        'name': S.of(context).growth_stage_v3,
        'icon': '🌿',
        'description': S.of(context).growth_stage_v3_desc,
      },
      {
        'id': 'V8',
        'name': S.of(context).growth_stage_v8,
        'icon': '🌱🌿',
        'description': S.of(context).growth_stage_v8_desc,
      },
      {
        'id': 'VT',
        'name': S.of(context).growth_stage_vt,
        'icon': '🌾',
        'description': S.of(context).growth_stage_vt_desc,
      },
      {
        'id': 'R1',
        'name': S.of(context).growth_stage_r1,
        'icon': '🌽',
        'description': S.of(context).growth_stage_r1_desc,
      },
      {
        'id': 'R6',
        'name': S.of(context).growth_stage_r6,
        'icon': '🌽',
        'description': S.of(context).growth_stage_r6_desc,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).growth_stage,
            style: TextStyle(
              fontSize: 32.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          verticalSpace(8),
          Text(
            S.of(context).corn_age_title,
            style: TextStyle(
              fontSize: 16.sp,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: kAppMediumGap,
              mainAxisSpacing: kAppMediumGap,
              childAspectRatio: 1.3,
            ),
            itemCount: growthStages.length,
            itemBuilder: (context, index) {
              final stage = growthStages[index];
              final isSelected = widget.controllers.growthStage == stage['id'];
              
              return _buildSelectionCard(
                isSelected: isSelected,
                icon: stage['icon'] as String,
                title: stage['name'] as String,
                description: stage['description'] as String,
                onTap: () {
                  setState(() {
                    widget.controllers.growthStage = stage['id'] as String;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Completion Page
class CompletionFormPage extends StatelessWidget {
  final CornRegistrationControllers controllers;

  const CompletionFormPage({
    super.key,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          verticalSpace(40),
          Icon(
            Icons.check_circle_outline,
            size: 80.w,
            color: MAIZE_ACCENT,
          ),
          verticalSpace(24),
          Text(
            S.of(context).registration_successful,
            style: TextStyle(
              fontSize: 24.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace(16),
          Text(
            S.of(context).corn_registration,
            style: TextStyle(
              fontSize: 16.sp,
              color: MAIZE_ACCENT,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace(40),
          // Registration summary
          Container(
            padding: EdgeInsets.all(kAppMediumPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: MAIZE_PRIMARY_LIGHT, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem(
                  S.of(context).field_name,
                  controllers.fieldName,
                ),
                _buildSummaryItem(
                  S.of(context).location,
                  controllers.location,
                ),
                _buildSummaryItem(
                  S.of(context).soil_type,
                  controllers.soilType,
                ),
                _buildSummaryItem(
                  S.of(context).corn_variety,
                  controllers.cornVariety,
                ),
                _buildSummaryItem(
                  S.of(context).planting_date,
                  controllers.plantingDate != null
                      ? '${controllers.plantingDate!.day}/${controllers.plantingDate!.month}/${controllers.plantingDate!.year}'
                      : 'Not selected',
                ),
                _buildSummaryItem(
                  S.of(context).growth_stage,
                  controllers.growthStage,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: MAIZE_ACCENT,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: MAIZE_ACCENT,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
Widget _buildInputField({
  required BuildContext context,
  required String label,
  required String icon,
  required String hintText,
  required String value,
  required ValueChanged<String> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$icon $label',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: MAIZE_ACCENT,
        ),
      ),
      verticalSpace(8),
      TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: MAIZE_ACCENT),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    ],
  );
}

Widget _buildSelectionCard({
  required bool isSelected,
  required String icon,
  required String title,
  required String description,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? MAIZE_ACCENT : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: isSelected ? MAIZE_PRIMARY_LIGHT : Colors.white,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 24.sp),
          ),
          verticalSpace(8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace(4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: MAIZE_ACCENT.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
