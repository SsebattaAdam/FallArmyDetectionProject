import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:intl/intl.dart';

import '../model/detectionmapmodel.dart';


class DetectionInfoWindow extends StatelessWidget {
  final Detection detection;
  final VoidCallback onClose;

  const DetectionInfoWindow({
    Key? key,
    required this.detection,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
    final imageUrl = '$baseUrl/${detection.imagePath.replaceFirst('static/upload/', '')}';
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');
    DateTime? detectionDate;

    try {
      detectionDate = DateTime.parse(detection.timestamp);
    } catch (e) {
      // Handle parsing error
    }

    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detection.result,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Class', _formatClass(detection.detectionClass)),
          _buildInfoRow('Confidence', '${detection.confidence.toStringAsFixed(1)}%'),
          if (detection.district.isNotEmpty)
            _buildInfoRow('District', detection.district),
          if (detectionDate != null)
            _buildInfoRow('Date', dateFormat.format(detectionDate)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatClass(String detectionClass) {
    switch (detectionClass) {
      case 'healthy-maize':
        return 'Healthy Maize';
      case 'fall-armyworm-larval-damage':
        return 'Larval Damage';
      case 'fall-armyworm-egg':
        return 'Eggs';
      case 'fall-armyworm-frass':
        return 'Frass';
      default:
        return 'Unknown';
    }
  }
}
