// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart'; // Use latlong2 for coordinates
//
// import '../../common/custom_container.dart';
// import '../../constants/constants.dart';
//
// class FallArmywormDisplayMap extends StatelessWidget {
//   const FallArmywormDisplayMap({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kPrimary,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(130.h),
//         child: AppBar(
//           title: const Text(
//             "Fall Armyworm Coverage",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: kPrimary,
//           elevation: 0,
//         ),
//       ),
//       body: SafeArea(
//         child: CustomContainer(
//           containerContent: FlutterMap(
//             options: MapOptions(
//               initialCenter: LatLng(1.3733, 32.2903), // Center of Uganda
//               initialZoom: 6.0,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: const ['a', 'b', 'c'],
//               ),
//               PolygonLayer(
//                 polygons: _buildDistrictPolygons(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Hardcoded district data.
//   List<District> _loadUgandaDistricts() {
//     return [
//       District(
//         name: "Kampala",
//         polygon: [
//           LatLng(0.31, 32.58),
//           LatLng(0.31, 32.59),
//           LatLng(0.32, 32.59),
//           LatLng(0.32, 32.58),
//         ],
//       ),
//       District(
//         name: "Wakiso",
//         polygon: [
//           LatLng(0.35, 32.50),
//           LatLng(0.35, 32.60),
//           LatLng(0.45, 32.60),
//           LatLng(0.45, 32.50),
//         ],
//       ),
//       // Add more districts here
//     ];
//   }
//
//   /// Replace these with your actual disease (fall armyworm) coverage data.
//   Map<String, double> _loadDiseaseCoverage() {
//     return {
//       "Kampala": 0.75, // 75% coverage
//       "Wakiso": 0.50,
//       // Add more districts and coverage percentages
//     };
//   }
//
//   /// Build polygons for each district using the coverage data for color coding.
//   List<Polygon> _buildDistrictPolygons() {
//     final districts = _loadUgandaDistricts();
//     final coverageData = _loadDiseaseCoverage();
//
//     return districts.map((district) {
//       final coverage = coverageData[district.name] ?? 0.0;
//       return Polygon(
//         points: district.polygon,
//         color: _getColorForCoverage(coverage),
//         borderColor: Colors.black,
//         borderStrokeWidth: 1.0,
//       );
//     }).toList();
//   }
//
//   /// Return a color based on the provided coverage value.
//   Color _getColorForCoverage(double coverage) {
//     if (coverage > 0.75) {
//       return Colors.red; // High coverage
//     } else if (coverage > 0.5) {
//       return Colors.orange; // Medium coverage
//     } else {
//       return Colors.green; // Low coverage
//     }
//   }
// }
//
// /// A simple model for a district.
// class District {
//   final String name;
//   final List<LatLng> polygon;
//
//   District({
//     required this.name,
//     required this.polygon,
//   });
// }
