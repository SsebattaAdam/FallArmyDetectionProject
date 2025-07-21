import 'package:flutter/material.dart';

class MapLegendWidget extends StatelessWidget {
  const MapLegendWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Legend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(
              color: const Color(0xFFFF5252),
              icon: Icons.egg_outlined,
              label: 'Fall Armyworm Eggs',
            ),
            const SizedBox(height: 4),
            _buildLegendItem(
              color: const Color(0xFFFF9800),
              icon: Icons.bug_report,
              label: 'Larval Damage',
            ),
            const SizedBox(height: 4),
            _buildLegendItem(
              color: const Color(0xFFFFEB3B),
              icon: Icons.grain,
              label: 'Frass',
            ),
            const SizedBox(height: 4),
            _buildLegendItem(
              color: const Color(0xFF4CAF50),
              icon: Icons.eco,
              label: 'Healthy Maize',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
