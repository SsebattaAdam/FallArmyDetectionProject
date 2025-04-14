import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_armyworm_diagnosis/models/faw_detection.dart'; // Adjust path as needed

class FallArmywormDisplayMap extends StatefulWidget {
  const FallArmywormDisplayMap({super.key});

  @override
  State<FallArmywormDisplayMap> createState() => _FallArmywormDisplayMapState();
}

class _FallArmywormDisplayMapState extends State<FallArmywormDisplayMap> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFawDetections();
  }

  // Fetch FAW detection data from Firestore
  Future<void> _fetchFawDetections() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('faw_detections').get();

      final detections = snapshot.docs
          .map((doc) => FawDetection.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _markers.clear();
        for (var detection in detections) {
          _markers.add(
            Marker(
              markerId: MarkerId('${detection.farmerId}_${detection.timestamp}'),
              position: LatLng(detection.latitude, detection.longitude),
              icon: _getMarkerIcon(detection.severity),
              infoWindow: InfoWindow(
                title: 'FAW Detection',
                snippet: 'Severity: ${detection.severity}',
              ),
            ),
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading map data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  // Define marker colors based on severity
  BitmapDescriptor _getMarkerIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'medium':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'low':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case 'healthy':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarker; // Default gray marker
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Center the map on Uganda (adjust coordinates as needed)
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(const LatLng(1.3733, 32.2903), 6.5), // Centered on Uganda
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAW Infestation Map'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(1.3733, 32.2903), // Centered on Uganda
                zoom: 6.5,
              ),
              markers: _markers,
              myLocationEnabled: true, // Optional: Show user's current location
              myLocationButtonEnabled: true,
            ),
    );
  }
}