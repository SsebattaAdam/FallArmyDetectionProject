
import 'package:fammaize/analytics2/providers/providersfiles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize analytics data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Armyworm Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Time Trends'),
            Tab(text: 'Distribution'),
            Tab(text: 'Districts'),
          ],
        ),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.fetchAnalyticsData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.analyticsData == null) {
            return const Center(child: Text('No data available'));
          }

          return Column(
            children: [
              // Filter section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildFilterSection(provider),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(provider),
                    _buildTimeSeriesTab(provider),
                    _buildDistributionTab(provider),
                    _buildDistrictsTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(AnalyticsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Time Period',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: provider.selectedDays,
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                      DropdownMenuItem(value: 30, child: Text('Last 30 days')),
                      DropdownMenuItem(value: 90, child: Text('Last 90 days')),
                      DropdownMenuItem(value: 365, child: Text('Last year')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateFilters(days: value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: provider.selectedDistrict,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Districts'),
                      ),
                      ...provider.districts.map((district) =>
                          DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          ),
                      ),
                    ],
                    onChanged: (value) {
                      provider.updateFilters(districtFilter: value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Detection Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: provider.selectedClass,
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Types'),
                ),
                DropdownMenuItem<String>(
                  value: 'fall-armyworm-larval-damage',
                  child: Text('Larval Damage'),
                ),
                DropdownMenuItem<String>(
                  value: 'fall-armyworm-egg',
                  child: Text('Eggs'),
                ),
                DropdownMenuItem<String>(
                  value: 'fall-armyworm-frass',
                  child: Text('Frass'),
                ),
                DropdownMenuItem<String>(
                  value: 'healthy-maize',
                  child: Text('Healthy Maize'),
                ),
              ],
              onChanged: (value) {
                provider.updateFilters(classFilter: value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AnalyticsProvider provider) {
    final data = provider.analyticsData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards - First Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: _buildSummaryCard(
                    title: 'Total Detections',
                    value: data['total_detections'].toString(),
                    icon: Icons.photo_camera,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: _buildSummaryCard(
                    title: 'Districts Affected',
                    value: data['districts_affected'].toString(),
                    icon: Icons.location_on,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary cards - Second Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: _buildSummaryCard(
                    title: 'Infestation Rate',
                    value: '${data['infestation_rate']}%',
                    icon: Icons.bug_report,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: _buildSummaryCard(
                    title: 'Recent Trend',
                    value: '${data['recent_trend'] >= 0 ? '+' : ''}${data['recent_trend']}%',
                    icon: data['recent_trend'] >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: data['recent_trend'] >= 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Detection Type Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Pie chart for class distribution
          SizedBox(
            height: 300,
            child: _buildClassDistributionPieChart(data),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesTab(AnalyticsProvider provider) {
    final data = provider.analyticsData!;
    final timeSeriesData = data['time_series'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detection Trends Over Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This chart shows the number of detections over time by type.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _buildTimeSeriesChart(timeSeriesData),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionTab(AnalyticsProvider provider) {
    final data = provider.analyticsData!;
    final classDistribution = data['class_distribution'] as Map<String, dynamic>;

    // Convert to list for display
    final List<MapEntry<String, dynamic>> distributionList =
    classDistribution.entries.toList();

    // Calculate total with explicit type handling
    final total = classDistribution.values.fold<int>(
      0,
          (int sum, dynamic value) {
        final numValue = value is int
            ? value
            : (value is double
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0);
        return sum + numValue;
      },
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detection Type Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: total == 0
                ? const Center(child: Text('No data available'))
                : ListView.builder(
              itemCount: distributionList.length,
              itemBuilder: (context, index) {
                final entry = distributionList[index];
                final className = _formatClassName(entry.key);
                // Ensure count is treated as int
                final count = entry.value is int
                    ? entry.value
                    : (entry.value is double
                    ? entry.value.toInt()
                    : int.tryParse(entry.value.toString()) ?? 0);
                    final percentage = total > 0
                    ? (count / total * 100).toStringAsFixed(1)
                    : '0.0';

                return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                className,
                style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                ),
                ),
                const SizedBox(height: 8),
                Row(
                children: [
                Expanded(
                child: LinearProgressIndicator(
                value: total > 0 ? count / total : 0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForClass(entry.key),
                ),
                minHeight: 10,
                ),
                ),
                const SizedBox(width: 16),
                Text(
                '$count ($percentage%)',
                style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ],
                ),
                ],
                ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDistrictsTab(AnalyticsProvider provider) {
    final data = provider.analyticsData!;
    final districtCounts = data['district_counts'] as Map<String, dynamic>;

    // Convert to list for display
    final List<MapEntry<String, dynamic>> districtList =
    districtCounts.entries.toList()
      ..sort((a, b) {
        final aValue = a.value is int
            ? a.value
            : (a.value is double
            ? a.value.toInt()
            : int.tryParse(a.value.toString()) ?? 0);
        final bValue = b.value is int
            ? b.value
            : (b.value is double
            ? b.value.toInt()
            : int.tryParse(b.value.toString()) ?? 0);
        return bValue.compareTo(aValue);
      });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detections by District',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: districtList.isEmpty
                ? const Center(child: Text('No district data available'))
                : ListView.builder(
              itemCount: districtList.length,
              itemBuilder: (context, index) {
                final entry = districtList[index];
                final district = entry.key;
                final count = entry.value is int
                    ? entry.value
                    : (entry.value is double
                    ? entry.value.toInt()
                    : int.tryParse(entry.value.toString()) ?? 0);
                    final maxEntry = districtList.first;
                    final maxCount = maxEntry.value is int
                    ? maxEntry.value
                        : (maxEntry.value is double
                    ? maxEntry.value.toInt()
                    : int.tryParse(maxEntry.value.toString()) ?? 0);

                return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                district,
                style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                ),
                ),
                const SizedBox(height: 8),
                Row(
                children: [
                Expanded(
                child: LinearProgressIndicator(
                value: maxCount > 0 ? count / maxCount : 0,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.blue,
                ),
                minHeight: 10,
                ),
                ),
                const SizedBox(width: 16),
                Text(
                count.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ],
                ),
                ],
                ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
        elevation: 2,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Icon(icon, color: color),
    const SizedBox(width: 8),
    Text(
    title,
    style: TextStyle(
    color: Colors.grey[600],
    fontSize: 14,
    ),
    ),
    ],
    ),
      const SizedBox(height: 12),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    ],
    ),
        ),
    );
  }

  Widget _buildClassDistributionPieChart(Map<String, dynamic> data) {
    final classDistribution = data['class_distribution'];

    // Convert to list for chart
    final List<MapEntry<String, dynamic>> distributionList =
    classDistribution.entries.toList();

    // Calculate total with explicit type handling
    final total = classDistribution.values.fold<int>(
      0,
          (int sum, dynamic value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0),
    );

    // Handle case where total is 0 to avoid division by zero
    if (total == 0) {
      return const Center(child: Text('No data available for pie chart'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: distributionList.map((entry) {
          final className = entry.key;
          // Ensure count is treated as int
          final count = entry.value is int
              ? entry.value
              : int.tryParse(entry.value.toString()) ?? 0;
          final percentage = (count / total * 100).toStringAsFixed(1);

          return PieChartSectionData(
            color: _getColorForClass(className),
            value: count.toDouble(),
            title: '$percentage%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 150),
      swapAnimationCurve: Curves.linear,
    );
  }


  Widget _buildTimeSeriesChart(Map<String, dynamic> timeSeriesData) {
    final labels = List<String>.from(timeSeriesData['labels']);
    final data = timeSeriesData['data'];

    // Skip some dates if there are too many to display
    final displayLabels = <String>[];
    final skipFactor = labels.length > 30 ? (labels.length / 10).ceil() : 1;

    for (int i = 0; i < labels.length; i++) {
      if (i % skipFactor == 0 || i == labels.length - 1) {
        displayLabels.add(labels[i]);
      } else {
        displayLabels.add('');
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < displayLabels.length) {
                  final label = displayLabels[value.toInt()];
                  if (label.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(DateTime.parse(label)),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: labels.length.toDouble() - 1,
        minY: 0,
        lineBarsData: _getLineBarsData(data, labels),
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData(Map<String, dynamic> data, List<String> labels) {
    final result = <LineChartBarData>[];

    data.forEach((className, values) {
      // Convert values to a properly typed list
      final typedValues = List<int>.from(
          values.map((v) => v is int ? v : int.parse(v.toString()))
      );

      // Skip if all values are 0
      if (typedValues.every((value) => value == 0)) {
        return;
      }

      final spots = <FlSpot>[];
      for (int i = 0; i < typedValues.length; i++) {
        spots.add(FlSpot(i.toDouble(), typedValues[i].toDouble()));
      }

      result.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _getColorForClass(className),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _getColorForClass(className).withOpacity(0.2),
          ),
        ),
      );
    });

    return result;
  }


  Color _getColorForClass(String className) {
    switch (className) {
      case 'fall-armyworm-larval-damage':
        return Colors.red;
      case 'fall-armyworm-egg':
        return Colors.orange;
      case 'fall-armyworm-frass':
        return Colors.brown;
      case 'healthy-maize':
        return Colors.green;
      case 'unknown':
      default:
        return Colors.grey;
    }
  }

  String _formatClassName(String className) {
    switch (className) {
      case 'fall-armyworm-larval-damage':
        return 'Larval Damage';
      case 'fall-armyworm-egg':
        return 'Eggs';
      case 'fall-armyworm-frass':
        return 'Frass';
      case 'healthy-maize':
        return 'Healthy Maize';
      case 'unknown':
      default:
        return 'Unknown';
    }
  }
}

