import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';

class DetailedPrescriptionScreen extends StatelessWidget {
  const DetailedPrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> taskData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    final String title = taskData['title'] ?? 'Farm Task';
    final String status = taskData['status'] ?? 'Unknown';
    final String details = taskData['details'] ?? 'No details available';
    final String category = taskData['category'] ?? 'general';
    final String time = taskData['time'] ?? 'Now';
    final Color color = taskData['color'] ?? MAIZE_PRIMARY;
    final bool isActive = taskData['isActive'] ?? false;

    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MAIZE_PRIMARY),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Farm Prescription',
          style: TextStyle(
            color: MAIZE_PRIMARY,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(kAppMediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(title, status, time, color, isActive),
            
            SizedBox(height: kAppMediumPadding),
            
            // Category Card
            _buildCategoryCard(category),
            
            SizedBox(height: kAppMediumPadding),
            
            // Details Card
            _buildDetailsCard(details),
            
            SizedBox(height: kAppMediumPadding),
            
            // Action Steps Card
            _buildActionStepsCard(details, category),
            
            SizedBox(height: kAppMediumPadding),
            
            // Tips Card
            _buildTipsCard(category),
            
            SizedBox(height: kAppLargePadding),
            
            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String title, String status, String time, Color color, bool isActive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(''),
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: kAppSmallGap),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.white.withOpacity(0.8),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                color: MAIZE_PRIMARY,
                size: 20.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Category',
                style: TextStyle(
                  color: MAIZE_PRIMARY,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppSmallGap),
          Text(
            _formatCategoryName(category),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(String details) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: MAIZE_PRIMARY,
                size: 20.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'What to Do',
                style: TextStyle(
                  color: MAIZE_PRIMARY,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppSmallGap),
          Text(
            details.isNotEmpty ? details : 'Follow the recommended actions for this task.',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionStepsCard(String details, String category) {
    final List<String> steps = _getActionSteps(details, category);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                color: MAIZE_PRIMARY,
                size: 20.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Step-by-Step Guide',
                style: TextStyle(
                  color: MAIZE_PRIMARY,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumGap),
          ...steps.asMap().entries.map((entry) {
            final int index = entry.key;
            final String step = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: kAppSmallGap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: MAIZE_PRIMARY,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: kAppSmallGap),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTipsCard(String category) {
    final List<String> tips = _getTipsForCategory(category);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber[700],
                size: 20.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Helpful Tips',
                style: TextStyle(
                  color: Colors.amber[700],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppSmallGap),
          ...tips.map((tip) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              // Mark as completed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task marked as completed!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MAIZE_PRIMARY,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              'Mark as Completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: kAppSmallGap),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton(
            onPressed: () {
              // Remind me later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You will be reminded later'),
                  backgroundColor: Colors.blue,
                ),
              );
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: MAIZE_PRIMARY),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              'Remind Me Later',
              style: TextStyle(
                color: MAIZE_PRIMARY,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'temperature_control':
        return Icons.thermostat;
      case 'humidity_control':
        return Icons.water_drop;
      case 'lighting':
        return Icons.wb_sunny;
      case 'water_management':
        return Icons.opacity;
      case 'fertilization':
        return Icons.grass;
      default:
        return Icons.agriculture;
    }
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'temperature_control':
        return 'Temperature Control';
      case 'humidity_control':
        return 'Humidity Management';
      case 'lighting':
        return 'Lighting Adjustment';
      case 'water_management':
        return 'Water Management';
      case 'fertilization':
        return 'Fertilization';
      default:
        return 'General Farm Task';
    }
  }

  List<String> _getActionSteps(String details, String category) {
    switch (category) {
      case 'temperature_control':
        return [
          'Check current temperature readings',
          'Install heating equipment or row covers',
          'Monitor temperature changes every 2 hours',
          'Adjust heating as needed to maintain optimal range',
        ];
      case 'humidity_control':
        return [
          'Assess current humidity levels',
          'Improve ventilation by opening vents or fans',
          'Remove excess moisture sources',
          'Monitor humidity levels regularly',
        ];
      case 'lighting':
        return [
          'Measure current light levels',
          'Install supplemental LED grow lights',
          'Position lights at optimal distance from plants',
          'Set timer for 12-16 hours daily light exposure',
        ];
      case 'water_management':
        return [
          'Check soil moisture levels',
          'Improve drainage if waterlogged',
          'Adjust irrigation schedule',
          'Monitor plant water stress signs',
        ];
      case 'fertilization':
        return [
          'Test soil nutrient levels',
          'Select appropriate fertilizer type',
          'Apply fertilizer according to package instructions',
          'Water thoroughly after application',
        ];
      default:
        return [
          'Assess the current situation',
          'Gather necessary tools and materials',
          'Follow recommended procedures',
          'Monitor results and adjust as needed',
        ];
    }
  }

  List<String> _getTipsForCategory(String category) {
    switch (category) {
      case 'temperature_control':
        return [
          'Optimal temperature for maize is 20-30°C (68-86°F)',
          'Use thermal blankets during cold nights',
          'Avoid sudden temperature changes',
        ];
      case 'humidity_control':
        return [
          'Ideal humidity range is 50-70%',
          'Good air circulation prevents fungal diseases',
          'Avoid watering late in the day',
        ];
      case 'lighting':
        return [
          'Maize needs 6-8 hours of direct sunlight daily',
          'LED lights are energy-efficient for supplemental lighting',
          'Position lights 12-24 inches above plants',
        ];
      case 'water_management':
        return [
          'Water deeply but less frequently',
          'Check soil moisture 2-3 inches deep',
          'Mulch around plants to retain moisture',
        ];
      case 'fertilization':
        return [
          'Use balanced NPK fertilizer (10-10-10 or similar)',
          'Apply fertilizer when soil is moist',
          'Follow package instructions for application rates',
        ];
      default:
        return [
          'Always follow safety guidelines',
          'Keep records of actions taken',
          'Consult experts when in doubt',
        ];
    }
  }
}
