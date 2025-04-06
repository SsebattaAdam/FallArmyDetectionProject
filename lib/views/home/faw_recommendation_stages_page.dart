import 'package:flutter/material.dart';
import 'package:fammaize/detectionCode/PesticideDetailsScreen.dart';

void main() {
  runApp(MaterialApp(
    home: FAWRecommendationStagesPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class FAWRecommendationStagesPage extends StatelessWidget {
  final List<Map<String, String>> stages = [
    {
      'stage': 'FAW Egg Stage',
      'symptoms': 'Tiny eggs in clusters on the underside of leaves.',
      'recommendation': 'Use neem-based sprays to prevent hatching.',
    },
    {
      'stage': 'Larval Damage',
      'symptoms': 'Leaf holes, windowpane damage, and frass (insect waste).',
      'recommendation': 'Introduce biological controls like parasitoids.',
    },
    {
      'stage': 'Healthy',
      'symptoms': 'No visible signs of pest damage.',
      'recommendation': 'Monitor weekly and maintain proper plant spacing.',
    },
    {
      'stage': 'Frass',
      'symptoms': 'Sawdust-like droppings in leaf whorls or around stems.',
      'recommendation': 'Remove infected leaves and use eco-pesticides.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Treatment & Recommendations"),
        backgroundColor: Colors.green,
      ),
      body: ListView.separated(
        itemCount: stages.length,
        padding: EdgeInsets.symmetric(vertical: 16),
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Icon(Icons.info_outline, color: Colors.green),
                title: Text(
                  stages[index]['stage']!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PesticideDetailScreen(
                        product: {
                          'name': stages[index]['stage'],
                          'composition': 'Neem oil-based',
                          'application_instructions': 'Apply on leaves',
                          'application_method': 'Spray',
                          'weather_conditions': 'Dry weather',
                          'toxicity': 'Low toxicity',
                          'safety_precautions': 'Wear gloves',
                          'control_methods': 'Biological controls',
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class StageDetailPage extends StatelessWidget {
  final String stage;
  final String symptoms;
  final String recommendation;

  const StageDetailPage({
    required this.stage,
    required this.symptoms,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stage),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Symptoms",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(symptoms, style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Text(
              "Recommendation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(recommendation, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
