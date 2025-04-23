import 'package:flutter/material.dart';

class CustomFont extends StatelessWidget {
  final String text;
  final double fontSize, letterSpacing;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final String fontFamily;
  final FontStyle fontStyle;
  final TextDecoration textDecoration;
  final TextDecorationStyle textDecorationStyle;
  final List<Shadow> shadows; // Added shadows property

  const CustomFont({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color = Colors.white,
    this.fontFamily = 'Montserrat',
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none, 
    this.textDecorationStyle = TextDecorationStyle.solid, 
    this.shadows = const [
      Shadow() // Blur effect
    ], // Default shadow added
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: color,
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
        decorationStyle: textDecorationStyle,
        shadows: shadows, // Apply shadows here
      ),
    );
  }
}
