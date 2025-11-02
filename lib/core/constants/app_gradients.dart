import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  static const Gradient neonRoute = LinearGradient(
    colors: [Color(0xFFF72585), Color(0xFFCBF94E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x000F1216), Color(0xCC0F1216)],
    stops: [0.0, 0.55],
  );

  static LinearGradient button(Color primary) => LinearGradient(
        colors: [primary, const Color(0xFFF72585)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
