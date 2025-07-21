import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detection_model.dart';

class DetectionDetailWidget extends StatelessWidget {
  final Detection detection;
  final VoidCallback? onClose;

  const DetectionDetailWidget({
    Key? key,
    required this.detection,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(detection.markerColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForDetectionType(detection.detectionType),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detection.formattedDetectionType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Detection details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.location_on,
                  'District',
                  detection.districtName,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  DateFormat('MMM d, yyyy').format(detection.detectionDate),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.verified,
                  'Confidence',
                  detection.formattedConfidence,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.my_location,
                  'Coordinates',
                  '${detection.latitude.toStringAsFixed(4)}, ${detection.longitude.toStringAsFixed(4)}',
                ),
                
                // Image if available
                if (detection.imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      detection.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
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
