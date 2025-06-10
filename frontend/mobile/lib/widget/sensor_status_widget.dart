import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/sensor_sleep_service.dart';

class SensorStatusWidget extends StatefulWidget {
  final bool ldrSensor;
  final bool phLevelSensor;
  final bool tempAndHumidSensor;
  final bool soilLevelSensor;
  final AppLocalizations localization;

  const SensorStatusWidget({
    super.key,
    required this.ldrSensor,
    required this.phLevelSensor,
    required this.tempAndHumidSensor,
    required this.soilLevelSensor,
    required this.localization,
  });

  @override
  State<SensorStatusWidget> createState() => _SensorStatusWidgetState();
}

class _SensorStatusWidgetState extends State<SensorStatusWidget> {
  final SensorSleepService _sensorSleepService = SensorSleepService();
  Map<String, bool> _sensorStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeSensorStatus();
  }

  void _initializeSensorStatus() {
    // Initialize with widget values
    _sensorStatus = {
      'ldr': widget.ldrSensor,
      'ph': widget.phLevelSensor,
      'dht': widget.tempAndHumidSensor,
      'soil': widget.soilLevelSensor,
    };
    
    // Initialize the sensor sleep service
    _sensorSleepService.initialize();
    
    // Update status from service
    _updateStatusFromService();
  }

  void _updateStatusFromService() {
    final serviceStatus = _sensorSleepService.currentSensorStatus;
    if (serviceStatus.isNotEmpty) {
      setState(() {
        _sensorStatus = serviceStatus;
      });
    }
  }

  Widget sensorRow(String label, bool isActive, {bool showSleepMode = true}) {
    final isSleeping = !isActive && showSleepMode;
    
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(8)),
      padding: EdgeInsets.all(ScreenUtil().setHeight(8)),
      decoration: BoxDecoration(
        color: isSleeping ? Colors.orange.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSleeping 
            ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSleeping 
                        ? Colors.orange 
                        : (isActive ? Colors.green : Colors.red),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: label,
                        color: MAIZE_ACCENT,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      if (isSleeping)
                        CustomFont(
                          text: 'Sleep Mode',
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (isSleeping)
                Icon(
                  Icons.bedtime,
                  color: Colors.orange,
                  size: 16,
                ),
              SizedBox(width: ScreenUtil().setWidth(5)),
              CustomFont(
                text: isSleeping 
                    ? 'Sleeping'
                    : (isActive ? widget.localization.on : widget.localization.off),
                color: isSleeping 
                    ? Colors.orange 
                    : (isActive ? Colors.green : Colors.red),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(10),
          horizontal: ScreenUtil().setHeight(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomFont(
                  text: widget.localization.sensors,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                IconButton(
                  onPressed: () {
                    _sensorSleepService.refreshSensorStatus();
                    _updateStatusFromService();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: MAIZE_ACCENT,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(15)),
            sensorRow(widget.localization.ldrSensor, _sensorStatus['ldr'] ?? widget.ldrSensor),
            sensorRow(widget.localization.phSensor, _sensorStatus['ph'] ?? widget.phLevelSensor),
            sensorRow(widget.localization.tempHumidSensor, _sensorStatus['dht'] ?? widget.tempAndHumidSensor),
            sensorRow(widget.localization.soilMoistureSensor, _sensorStatus['soil'] ?? widget.soilLevelSensor),
            
            // Add sleep mode summary if any sensors are sleeping
            if (_sensorStatus.values.any((status) => !status))
              Container(
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                padding: EdgeInsets.all(ScreenUtil().setHeight(8)),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Expanded(
                      child: CustomFont(
                        text: 'Some sensors are in sleep mode to conserve power',
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sensorSleepService.dispose();
    super.dispose();
  }
}
