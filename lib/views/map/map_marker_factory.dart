import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'detection_model.dart';

class MapMarkerFactory {
  // Cache for marker icons to avoid recreating them
  static final Map<String, BitmapDescriptor> _markerIconCache = {};

  // Create a marker for a detection
  static Future<Marker> createDetectionMarker({
    required Detection detection,
    required Function(Detection) onTap,
  }) async {
    final BitmapDescriptor icon = await _getMarkerIcon(detection);
    
    return Marker(
      markerId: MarkerId('detection_${detection.id}'),
      position: LatLng(detection.latitude, detection.longitude),
      icon: icon,
      infoWindow: InfoWindow(
        title: detection.formattedDetectionType,
        snippet: '${detection.formattedConfidence} confidence',
      ),
      onTap: () => onTap(detection),
    );
  }

  // Create a marker for a district with detection count
  static Future<Marker> createDistrictMarker({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    required int detectionCount,
    required Function() onTap,
  }) async {
    final BitmapDescriptor icon = await _getCountMarkerIcon(detectionCount);
    
    return Marker(
      markerId: MarkerId('district_$id'),
      position: LatLng(latitude, longitude),
      icon: icon,
      infoWindow: InfoWindow(
        title: name,
        snippet: '$detectionCount detections',
      ),
      onTap: onTap,
    );
  }

  // Get or create a marker icon for a detection type
  static Future<BitmapDescriptor> _getMarkerIcon(Detection detection) async {
    final String cacheKey = detection.detectionType;
    
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }
    
    // Create custom marker icon
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Color(detection.markerColor);
    
    // Draw circle
    canvas.drawCircle(const Offset(24, 24), 24, paint);
    
    // Draw border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(24, 24), 22, borderPaint);
    
    // Draw icon
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _getIconCharForDetectionType(detection.detectionType),
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontFamily: 'MaterialIcons',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        24 - textPainter.width / 2,
        24 - textPainter.height / 2,
      ),
    );
    
    // Convert to image
    final ui.Image image = await pictureRecorder.endRecording().toImage(48, 48);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    final BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    _markerIconCache[cacheKey] = icon;
    
    return icon;
  }

  // Get or create a marker icon with a count
  static Future<BitmapDescriptor> _getCountMarkerIcon(int count) async {
    final String cacheKey = 'count_$count';
    
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }
    
    // Define color based on count
    Color markerColor;
    if (count > 10) {
      markerColor = Colors.red;
    } else if (count > 5) {
      markerColor = Colors.orange;
    } else {
      markerColor = Colors.green;
    }
    
    // Create custom marker icon
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = markerColor;
    
    // Draw circle
    canvas.drawCircle(const Offset(24, 24), 24, paint);
    
    // Draw border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(24, 24), 22, borderPaint);
    
    // Draw count text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        24 - textPainter.width / 2,
        24 - textPainter.height / 2,
      ),
    );
    
    // Convert to image
    final ui.Image image = await pictureRecorder.endRecording().toImage(48, 48);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    final BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    _markerIconCache[cacheKey] = icon;
    
    return icon;
  }

  // Get icon character for detection type
  static String _getIconCharForDetectionType(String detectionType) {
    switch (detectionType) {
      case 'fall-armyworm-egg':
        return '\uE043'; // egg_outlined
      case 'fall-armyworm-larval-damage':
        return '\uE868'; // bug_report
      case 'fall-armyworm-frass':
        return '\uE3E7'; // grain
      case 'healthy-maize':
        return '\uE3B2'; // eco
      default:
        return '\uE55F'; // location_on
    }
  }
}
