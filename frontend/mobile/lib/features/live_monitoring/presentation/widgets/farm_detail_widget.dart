import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../farm/domain/entities/farm.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../../../core/constants/app_spacing.dart';

class FarmDetailWidget extends StatefulWidget {
  final Farm farm;
  final List<SensorReading> sensorReadings;
  final VoidCallback onBack;
  final VoidCallback? onFieldClustering;

  const FarmDetailWidget({
    super.key,
    required this.farm,
    required this.sensorReadings,
    required this.onBack,
    this.onFieldClustering,
  });

  @override
  State<FarmDetailWidget> createState() => _FarmDetailWidgetState();
}

class _FarmDetailWidgetState extends State<FarmDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with back button and title
          _buildHeader(),
          
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Large field image with overlay button
                  _buildFieldImage(),
                  
                  // Field details card
                  _buildFieldDetailsCard(),
                  
                  // Calendar section
                  _buildCalendarSection(),
                  
                  // Activity section
                  _buildActivitySection(),
                  
                  // Bottom padding
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 24.sp,
            ),
          ),
          const Spacer(),
          Text(
            'Detail Field',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.more_horiz,
            color: Colors.black87,
            size: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldImage() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/field_detail_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 20.h,
          right: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map,
                  color: Colors.white,
                  size: 16.sp,
                ),
                horizontalSpace(6),
                Text(
                  'Open map this field',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldDetailsCard() {
    // Get the first field if available
    final firstField = widget.farm.fields.isNotEmpty ? widget.farm.fields.first : null;
    final sensorsCount = firstField?.sensors.length ?? 0;
    
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.farm.farmName.isNotEmpty 
                ? widget.farm.farmName 
                : 'Farm',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (firstField != null) ...[
            verticalSpace(4),
            Text(
              'Field: ${firstField.fieldName}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            verticalSpace(4),
            Text(
              'Growth Stage: ${firstField.growthStage}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
          verticalSpace(8),
          Text(
            'Planting Date: ${firstField != null ? "${firstField.plantingDate.day}/${firstField.plantingDate.month}/${firstField.plantingDate.year}" : "N/A"}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          verticalSpace(16),
          Row(
            children: [
              _buildStatItem(Icons.grass, '${widget.farm.fields.length} Fields'),
              horizontalSpace(24),
              _buildStatItem(Icons.sensors, '$sensorsCount Sensors'),
              horizontalSpace(24),
              _buildStatItem(Icons.calendar_today, firstField?.growthStage ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.grey[600],
        ),
        horizontalSpace(6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF8BC34A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: const Color(0xFF8BC34A),
                size: 20.sp,
              ),
              horizontalSpace(8),
              Text(
                'Want to see calendar details?',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Open Calendar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF8BC34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7 days to harvest',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  verticalSpace(8),
                  Container(
                    width: 200.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: Colors.grey[300],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.77, // 24/31
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          color: const Color(0xFF8BC34A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  horizontalSpace(4),
                  Text(
                    '24/31 Days',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
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

  Widget _buildActivitySection() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Activity this field',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '24/31 Completed',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF8BC34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          verticalSpace(16),
          _buildActivityItem(
            'Watering of fields R89...',
            '7:30 AM',
            'On-Progress',
            true,
          ),
          verticalSpace(12),
          _buildActivityItem(
            'Planting of fields R8978',
            '',
            'Not-Started',
            false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(
    String title,
    String time,
    String status,
    bool isActive,
  ) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF8BC34A).withOpacity(0.1) : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isActive ? Icons.water_drop : Icons.grass,
            color: isActive ? const Color(0xFF8BC34A) : Colors.grey[400],
            size: 20.sp,
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.black87 : Colors.grey[400],
                ),
              ),
              if (time.isNotEmpty) ...[
                verticalSpace(2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.sp,
                      color: Colors.grey[500],
                    ),
                    horizontalSpace(4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF8BC34A) : Colors.grey[300],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

}
