import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';

class CropConditionWidget extends StatefulWidget {
  final int condition;
  const CropConditionWidget({super.key, required this.condition});

  @override
  State<CropConditionWidget> createState() => _CropConditionWidgetState();
}

class _CropConditionWidgetState extends State<CropConditionWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container (
              width: 50, 
              height: 50, 
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ), 
            ),
            const Icon(
              FlutterIcons.smile_circle_ant,
              color: MAIZE_LOGO_ICON,
            )
          ],
        ),
        SizedBox(width: ScreenUtil().setWidth(15)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomFont(
                text: 'Your crops are in good condition.',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              SizedBox(height: ScreenUtil().setHeight(2)),
              const CustomFont(
                text: 'Keep up the good work!',
                fontSize: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}