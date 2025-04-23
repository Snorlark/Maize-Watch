import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import 'package:maize_watch/widget/crop_condition_widget.dart';
import 'package:maize_watch/widget/humidity_data_widget.dart';
import 'package:maize_watch/widget/light_data_widget.dart';
import 'package:maize_watch/widget/moisture_data_widget.dart';


class CropConditionScreen extends StatelessWidget {
  const CropConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    double moistureData = 80.1;
    double humidityData = 90;
    double lightIntensityData = 82;

    return Stack(
      children: [
        const DecoratedBox(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover)),
        child: Center()
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(ScreenUtil().setSp(30),
              ScreenUtil().setSp(50), ScreenUtil().setSp(30), ScreenUtil().setSp(50)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/maize_watch_logo.png',
                    scale: 5.5,
                  )
                ],
              ),
              CustomFont(
                  text: 'Lot 1',
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(20),
                  fontWeight: FontWeight.bold),
              CustomFont(
                  text: '28°',
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(65),
                  fontWeight: FontWeight.bold),
              const CropConditionWidget(condition: 28),
              SizedBox(height: ScreenUtil().setHeight(10)),
              const Divider(color: Colors.white),
              SizedBox(height: ScreenUtil().setHeight(10)),
              MoistureDataWidget(moistureData: moistureData),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HumidityDataWidget(humidityData: humidityData),
                  LightDataWidget(lightIntensityData: lightIntensityData)
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(5)),
              CustomButton(context: context, title: 'View more details', screen: DetailScreen(), isTransparent: true,)
            ],
          ),
        )
      ],
    );
  }
}

