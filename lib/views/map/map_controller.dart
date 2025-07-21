import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'detection_model.dart';
import 'district_model.dart';
import 'map_service.dart';

import 'dart:async';

import 'map_marker_factory.dart';


class MapController extends ChangeNotifier {
  final MapService _mapService = MapService();
  
  List<District> _districts = [];
  List<Detection> _detections = [];
  Map<String, int> _detectionCounts = {};
  Set<Marker> _markers = {};
  bool _isLoading = false;
  String _error = '';
  
  // Initial camera position (Uganda)
  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(1.3733, 32.2903), // Uganda center
    zoom: 7.0,
  );

  // Getters
  List<District> get districts => _districts;
  List<Detection> get detections => _detections;
  Map<String, int> get detectionCounts => _detectionCounts;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Initialize the controller
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadDistricts(),
        _loadDetections(),
        _loadDetectionCounts(),
      ]);
      await _createMarkers();
      _error = '';
    } catch (e) {
      _error = 'Failed to initialize map: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Load districts from API
  Future<void> _loadDistricts() async {
    try {
      _districts = await _mapService.fetchDistricts();
    } catch (e) {
      _error = 'Failed to load districts: $e';
      print(_error);
    }
  }

  // Load detections from API
  Future<void> _loadDetections() async {
    try {
      _detections = await _mapService.fetchDetections();
    } catch (e) {
      _error = 'Failed to load detections: $e';
      print(_error);
    }
  }

  // Load detection counts from API
  Future<void> _loadDetectionCounts() async {
    try {
      _detectionCounts = await _mapService.fetchDetectionCounts();
    } catch (e) {
      _error = 'Failed to load detection counts: $e';
      print(_error);
    }
  }

  // Create markers for the map
 Future<void> _createMarkers() async {
  Set<Marker> markers = {};
  
  // Create markers for districts with detections
  for (var district in _districts) {
    final count = _detectionCounts[district.name] ?? 0;
    if (count > 0) {
      final marker = await MapMarkerFactory.createDistrictMarker(
        id: district.id,
        name: district.name,
        latitude: district.latitude,
        longitude: district.longitude,
        detectionCount: count,
        onTap: () {
          // Handle marker tap
          _loadDetectionsForDistrict(district.name);
        },
      );
      markers.add(marker);
    }
  }
  
  // Create markers for individual detections
  for (var detection in _detections) {
    final marker = await MapMarkerFactory.createDetectionMarker(
      detection: detection,
      onTap: (detection) {
        // This will be handled in the UI
      },
    );
    markers.add(marker);
  }
  
  _markers = markers;
  notifyListeners();
}

  // Create a custom marker icon with count
  // Future<BitmapDescriptor> _createMarkerIcon(int count) async {
  //   // Define marker color based on count
  //   Color markerColor;
  //   if (count > 10) {
  //     markerColor = Colors.red;
  //   } else if (count > 5) {
  //     markerColor = Colors.orange;
  //   } else {
  //     markerColor = Colors.green;
  //   }
    
  //   // Create a simple circle with count text
  //   final PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..color = markerColor;
  //   final TextPainter textPainter = TextPainter(
  //     text: TextSpan(
  //       text: count.toString(),
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 30,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     textDirection: TextDirection.ltr,
  //   );
    
  //   textPainter.layout();
    
  //   // Draw circle
  //   canvas.drawCircle(const Offset(40, 40), 40, paint);
    
  //   // Draw text
  //   textPainter.paint(
  //     canvas,
  //     Offset(
  //       40 - textPainter.width / 2,
  //       40 - textPainter.height / 2,
  //     ),
  //   );
    
  //   // Convert to image
  //   final img = await pictureRecorder.endRecording().toImage(80, 80);
  //   final data = await img.toByteData(format: ui.ImageByteFormat.png);
    
  //   return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  // }

  // Load detections for a specific district
  Future<void> _loadDetectionsForDistrict(String districtName) async {
    _setLoading(true);
    try {
      final districtDetections = await _mapService.fetchDetectionsByDistrict(districtName);
      _detections = districtDetections;
    } catch (e) {
      _error = 'Failed to load detections for district: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshData() async {
    await initialize();
  }
}
