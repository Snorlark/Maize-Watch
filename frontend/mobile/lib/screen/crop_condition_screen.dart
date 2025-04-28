import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import 'package:maize_watch/widget/crop_condition_widget.dart';
import 'package:maize_watch/widget/humidity_data_widget.dart';
import 'package:maize_watch/widget/light_data_widget.dart';
import 'package:maize_watch/widget/moisture_data_widget.dart';
import 'package:maize_watch/services/api_service.dart'; // Make sure this import path is correct

class CropConditionScreen extends StatefulWidget {
  const CropConditionScreen({super.key});

  @override
  State<CropConditionScreen> createState() => _CropConditionScreenState();
}

class _CropConditionScreenState extends State<CropConditionScreen> {
  String _greeting = 'Good Morning';
  String _userName = 'farmer';
  final ApiService _apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    _loadUserGreeting();
  }
  
  Future<void> _loadUserGreeting() async {
    final userData = await _apiService.getUserData();
    if (userData != null) {
      // Get the user's name - adjust field name as needed
      final name = userData['fullName'] ?? userData['name'] ?? userData['username'] ?? 'farmer';
      // Extract first name if possible
      final firstName = name.contains(' ') ? name.split(' ')[0] : name;
      
      setState(() {
        _greeting = _apiService.getGreeting(firstName).split(',')[0]; // Just the greeting part
        _userName = firstName;
      });
    }
  }

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
              fit: BoxFit.cover
            )
          ),
          child: Center()
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(ScreenUtil().setSp(30),
            ScreenUtil().setSp(50), ScreenUtil().setSp(30), ScreenUtil().setSp(50)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                child: Row(
                  children: [
                    CustomFont(
                      text: '$_greeting, ',
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(23),
                      fontWeight: FontWeight.bold
                    ),
                    CustomFont(
                      text: _userName,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(23),
                      fontWeight: FontWeight.bold
                    ),
                  ],
                ),
              ),

              CustomFont(
                text: '28°',
                color: Colors.white,
                fontSize: ScreenUtil().setSp(65),
                fontWeight: FontWeight.bold
              ),
             
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