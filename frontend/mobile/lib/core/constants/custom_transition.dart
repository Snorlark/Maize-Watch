import 'package:flutter/material.dart';

class CustomTransition<T> extends PageRouteBuilder<T> {
  CustomTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 600),
    Duration reverseDuration = const Duration(milliseconds: 300),
  }) : super(
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeInOutCubic,
           );

           return FadeTransition(
             opacity: curvedAnimation,
             child: ScaleTransition(
               scale: Tween<double>(
                 begin: 0.95,
                 end: 1.0,
               ).animate(curvedAnimation),
               child: child,
             ),
           );
         },
       );
}
