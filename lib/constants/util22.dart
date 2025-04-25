import 'package:flutter/material.dart';

class ChartUtils {
  static Color getColorForClass(String className) {
    switch (className) {
      case 'fall-armyworm-larval-damage':
        return Colors.red;
      case 'fall-armyworm-egg':
        return Colors.orange;
      case 'fall-armyworm-frass':
        return Colors.brown;
      case 'healthy-maize':
        return Colors.green;
      case 'unknown':
      default:
        return Colors.grey;
    }
  }

  static String formatClassName(String className) {
    switch (className) {
      case 'fall-armyworm-larval-damage':
        return 'Larval Damage';
      case 'fall-armyworm-egg':
        return 'Eggs';
      case 'fall-armyworm-frass':
        return 'Frass';
      case 'healthy-maize':
        return 'Healthy Maize';
      case 'unknown':
      default:
        return 'Unknown';
    }
  }

  static String formatTrendValue(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}
