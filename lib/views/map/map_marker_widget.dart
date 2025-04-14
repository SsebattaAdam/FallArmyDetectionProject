import 'package:flutter/material.dart';
import 'detection_model.dart';

class MapMarkerWidget extends StatelessWidget {
  final Detection detection;
  final VoidCallback? onTap;

  const MapMarkerWidget({
    Key? key,
    required this.detection,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(detection.markerColor),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getIconForDetectionType(detection.detectionType),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  IconData _getIconForDetectionType(String detectionType) {
    switch (detectionType) {
      case 'fall-armyworm-egg':
        return Icons.egg_outlined;
            case 'fall-armyworm-larval-damage':
        return Icons.bug_report;
      case 'fall-armyworm-frass':
        return Icons.grain;
      case 'healthy-maize':
        return Icons.eco;
      default:
        return Icons.location_on;
    }
  }
}

