import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isPrimaryButton;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isPrimaryButton = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight =
        55.0 + (bottomPadding > 0 ? bottomPadding : kAppMediumPadding);

    return Container(
      height: navBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: kAppLargePadding,
        vertical: kAppSmallPadding + (bottomPadding > 0 ? bottomPadding : 0),
      ),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.isPrimaryButton ? MAIZE_PRIMARY : MAIZE_PRIMARY_LIGHT,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 14.0,
              ),
              minimumSize: const Size(140, 50),
              maximumSize: const Size.fromWidth(double.infinity),
            ),
            onPressed: widget.onPressed,
            child: Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    widget.isPrimaryButton
                        ? MAIZE_PRIMARY_LIGHT
                        : MAIZE_PRIMARY,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
