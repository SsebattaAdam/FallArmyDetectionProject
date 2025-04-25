import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providerformap/providerformap.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({Key? key}) : super(key: key);

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  int _selectedDays = 30;
  String? _selectedClass;
  String? _selectedDistrict;
  final List<int> _dayOptions = [7, 14, 30, 90, 365];
  final List<Map<String, String>> _classOptions = [
    {'value': 'fall-armyworm-larval-damage', 'label': 'Larval Damage'},
    {'value': 'fall-armyworm-egg', 'label': 'Eggs'},
    {'value': 'fall-armyworm-frass', 'label': 'Frass'},
    {'value': 'healthy-maize', 'label': 'Healthy Maize'},
    // Removed the 'unknown' option
  ];

  @override
  void initState() {
    super.initState();
    // Initialize filter values from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<MapDataProvider>(context, listen: false);
        setState(() {
          _selectedDays = provider.days;
          _selectedClass = provider.selectedClass;
          _selectedDistrict = provider.selectedDistrict;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapDataProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Detections',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          // Time period filter
          const Text(
            'Time Period:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _dayOptions.map((days) {
              return ChoiceChip(
                label: Text('$days days'),
                selected: _selectedDays == days,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDays = days;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Detection class filter
          const Text(
            'Detection Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('All Types'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Types'),
              ),
              ..._classOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedClass = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // District filter
          const Text(
            'District:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDistrict,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('All Districts'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Districts'),
              ),
              ...provider.districts.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
              });
            },
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    provider.updateFilters(
                      days: _selectedDays,
                      detectionClass: _selectedClass,
                      district: _selectedDistrict,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedDays = 30;
                    _selectedClass = null;
                    _selectedDistrict = null;
                  });
                  provider.clearFilters();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
