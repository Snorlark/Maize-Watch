import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';

class CustomButton extends StatelessWidget {
  final BuildContext context;
  final String title;
  final Widget screen;
  final bool isTransparent;

  const CustomButton(
      {super.key,
      required this.context,
      required this.title,
      required this.screen,
      this.isTransparent = false});

  @override
  Widget build(BuildContext context) {
    return buildMenuButton(context, title, screen);
  }

  Widget buildMenuButton(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: (isTransparent) ? Colors.white54 : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: CustomFont(
              text: title,
              fontWeight: FontWeight.bold,
              color: (isTransparent) ? Colors.black : MAIZE_ACCENT),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 18, color: (isTransparent) ? Colors.black : MAIZE_ACCENT),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
        ),
      ),
    );
  }
}
