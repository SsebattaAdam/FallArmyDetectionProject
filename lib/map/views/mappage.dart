import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../model/detectionmapmodel.dart';
import '../providerformap/providerformap.dart';
import '../servicemap/newutils.dart';
import '../widgetsmap/detectionmapwidget.dart';
import '../widgetsmap/filterpanelwidget.dart';
import '../widgetsmap/legendwidgetformap.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Detection? _selectedDetection;
  bool _showFilters = false;
  // Uganda's center coordinates
  static const LatLng _ugandaCenter = LatLng(1.3733, 32.2903);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // No need to initialize marker icons anymore, but keeping for compatibility
    await MarkerUtil.initialize();
    // Load initial data
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = Provider.of<MapDataProvider>(context, listen: false);
          provider.initialize();
        }
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapStyle(controller);
  }

  Future<void> _updateMapStyle(GoogleMapController controller) async {
    // You can customize the map style if needed
    // String mapStyle = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
    // controller.setMapStyle(mapStyle);
  }

  void _onMarkerTap(Detection detection) {
    setState(() {
      _selectedDetection = detection;
    });
    // Center the map on the selected detection
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(detection.position, 12),
    );
  }

  void _closeInfoWindow() {
    setState(() {
      _selectedDetection = null;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _closeAllOverlays() {
    setState(() {
      _showFilters = false;
      _selectedDetection = null;
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Fall Armyworm Map',

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: _toggleFilters,
            tooltip: 'Toggle Filters',
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              if (mounted) {
                final provider = Provider.of<MapDataProvider>(context, listen: false);
                provider.fetchDetections();
              }
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Consumer<MapDataProvider>(
        builder: (context, provider, child) {
          // Update markers when detections change
          _markers = MarkerUtil.createMarkers(
            provider.detections,
            _onMarkerTap,
          );

          return GestureDetector(
            onTap: _closeAllOverlays,
            child: Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: _ugandaCenter,
                    zoom: 7,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  onTap: (_) => _closeAllOverlays(),
                ),

                // Loading indicator
                if (provider.isLoading)
                  const Center(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),

                // Error message
                if (provider.error != null)
                  Center(
                    child: Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.fetchDetections(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Detection count indicator
                Positioned(
                  top: 16,
                  left: 16,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${provider.detections.length} Detections',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Map Legend
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: const MapLegend(),
                ),

                // Filter panel
                if (_showFilters)
                  Positioned(
                    top: 16,
                    right: 16,
                    width: 300,
                    child: GestureDetector(
                      onTap: () {}, // Empty callback to prevent tap propagation
                      child: const FilterPanel(),
                    ),
                  ),

                // Detection info window
                if (_selectedDetection != null)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {}, // Empty callback to prevent tap propagation
                        child: DetectionInfoWindow(
                          detection: _selectedDetection!,
                          onClose: _closeInfoWindow,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset map view to Uganda
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_ugandaCenter, 7),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.home, color: Colors.white),
        tooltip: 'Reset View',
      ),
    );
  }
}
