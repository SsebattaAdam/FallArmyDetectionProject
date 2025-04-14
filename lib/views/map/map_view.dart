import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'map_controller.dart';
import 'detection_model.dart';
import 'detection_detail_widget.dart';
import 'map_legend_widget.dart';
import 'map_filter_widget.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  Detection? _selectedDetection;
  bool _showLegend = false;
  bool _showFilters = false;
  List<String> _selectedDetectionTypes = [
    'fall-armyworm-egg',
    'fall-armyworm-larval-damage',
    'fall-armyworm-frass',
    'healthy-maize',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapController()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fall Armyworm Map'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                  _showLegend = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                setState(() {
                  _showLegend = !_showLegend;
                  _showFilters = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<MapController>().refreshData();
              },
            ),
          ],
        ),
        body: Consumer<MapController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading map data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(controller.error),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.refreshData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Filter markers based on selected detection types
            final filteredMarkers = controller.markers.where((marker) {
              // Extract detection type from marker ID if possible
              final markerId = marker.markerId.value;
              if (markerId.startsWith('detection_')) {
                final detectionId = int.parse(markerId.split('_')[1]);
                final detection = controller.detections.firstWhere(
                  (d) => d.id == detectionId,
                  orElse: () => Detection(
                    id: -1,
                    districtName: '',
                    latitude: 0,
                    longitude: 0,
                    detectionType: '',
                    confidence: 0,
                    detectionDate: DateTime.now(),
                  ),
                );
                return detection.id != -1 && _selectedDetectionTypes.contains(detection.detectionType);
              }
              return true; // Keep district markers
            }).toSet();

            return Stack(
              children: [
                // Google Map
                                // Google Map
                GoogleMap(
                  initialCameraPosition: controller.initialCameraPosition,
                  markers: filteredMarkers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                ),
                
                // Selected detection detail card
                if (_selectedDetection != null)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: DetectionDetailWidget(
                      detection: _selectedDetection!,
                      onClose: () {
                        setState(() {
                          _selectedDetection = null;
                        });
                      },
                    ),
                  ),
                
                // Legend
                if (_showLegend)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: MapLegendWidget(),
                  ),
                
                // Filters
                if (_showFilters)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: MapFilterWidget(
                      detectionTypes: const [
                        'fall-armyworm-egg',
                        'fall-armyworm-larval-damage',
                        'fall-armyworm-frass',
                        'healthy-maize',
                      ],
                      selectedTypes: _selectedDetectionTypes,
                      onFilterChanged: (types) {
                        setState(() {
                          _selectedDetectionTypes = types;
                        });
                      },
                    ),
                  ),
                
                // Loading indicator for refreshing data
                if (controller.isLoading)
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                
                // Stats panel
                Positioned(
                  bottom: _selectedDetection != null ? 200 : 16,
                  left: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detections: ${controller.detections.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Districts: ${controller.districts.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to detection screen or show detection dialog
            // This will be implemented in your detection functionality
          },
          child: const Icon(Icons.add_a_photo),
          tooltip: 'Add Detection',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

