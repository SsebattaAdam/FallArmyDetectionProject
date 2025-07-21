import 'package:flutter/material.dart';

class MapFilterWidget extends StatefulWidget {
  final List<String> detectionTypes;
  final List<String> selectedTypes;
  final Function(List<String>) onFilterChanged;

  const MapFilterWidget({
    Key? key,
    required this.detectionTypes,
    required this.selectedTypes,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<MapFilterWidget> createState() => _MapFilterWidgetState();
}

class _MapFilterWidgetState extends State<MapFilterWidget> {
  late List<String> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
  }

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
              'Filter Detections',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.detectionTypes.map((type) {
              final formattedType = type
                  .split('-')
                  .map((word) => word[0].toUpperCase() + word.substring(1))
                  .join(' ');
              
              return CheckboxListTile(
                title: Text(formattedType),
                value: _selectedTypes.contains(type),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (!_selectedTypes.contains(type)) {
                        _selectedTypes.add(type);
                      }
                    } else {
                      _selectedTypes.remove(type);
                    }
                    widget.onFilterChanged(_selectedTypes);
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypes = List.from(widget.detectionTypes);
                      widget.onFilterChanged(_selectedTypes);
                    });
                  },
                  child: const Text('Select All'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypes = [];
                      widget.onFilterChanged(_selectedTypes);
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
