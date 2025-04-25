import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/detectionmapmodel.dart';

class MarkerUtil {
  // No need to initialize custom marker icons anymore
  static Future<void> initialize() async {
    // This method is kept for backward compatibility
    // but doesn't need to do anything now
  }

  // Get marker color based on detection class
  static BitmapDescriptor getMarkerIcon(String detectionClass) {
    switch (detectionClass) {
      case 'healthy-maize':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'fall-armyworm-larval-damage':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'fall-armyworm-egg':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'fall-armyworm-frass':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      default:
      // For any other class, return violet (though we'll filter these out)
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  // Create markers from detections, filtering out unknown class
  static Set<Marker> createMarkers(
      List<Detection> detections,
      Function(Detection) onMarkerTap,
      ) {
    // Filter out detections with 'unknown' class
    final filteredDetections = detections.where((detection) =>
    detection.detectionClass != 'unknown'
    ).toList();

    return filteredDetections.map((detection) {
      return Marker(
        markerId: MarkerId('detection_${detection.id}'),
        position: detection.position,
        icon: getMarkerIcon(detection.detectionClass),
        infoWindow: InfoWindow(
          title: detection.result,
          snippet: 'Confidence: ${detection.confidence.toStringAsFixed(1)}%',
        ),
        onTap: () => onMarkerTap(detection),
      );
    }).toSet();
  }
}
