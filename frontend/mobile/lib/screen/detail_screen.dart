import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/widget/lot_humidity_widget.dart';
import 'package:maize_watch/widget/lot_moisture_widget.dart';
import 'package:maize_watch/widget/lot_temperature_widget.dart';
import '../custom/custom_font.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
      children: [
        const DecoratedBox(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover)),
        child: Center()),
        Padding(
          padding: EdgeInsets.fromLTRB(ScreenUtil().setSp(30),
              ScreenUtil().setSp(50), ScreenUtil().setSp(30), ScreenUtil().setSp(50)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomFont(text: 'Lot 1', fontSize: 28, fontWeight: FontWeight.bold,)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomFont(text: 'Weekly Overview', fontWeight: FontWeight.bold, fontSize: 16,),
                      CustomFont(text: 'Feb. 10 - Feb. 16', fontSize: 12,),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LotTemperatureWidget(),
                      const Divider(height: 50),
                      LotMoistureWidget(),
                      const Divider(height: 50),
                      LotHumidityWidget()
                    ],
                  ),
                ),
              ),              
            ]
          ),
        )
      ]
      )
    );
  }
}
