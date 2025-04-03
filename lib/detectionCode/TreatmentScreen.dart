import 'dart:io';
import 'package:flutter/material.dart';
import 'PesticideDetailsScreen.dart';

class TreatmentScreen extends StatefulWidget {
  final File image;
  final String result;
  final List<Map<String, dynamic>> recommendedProducts;

  const TreatmentScreen({
    Key? key,
    required this.image,
    required this.result,
    required this.recommendedProducts,
  }) : super(key: key);

  @override
  _TreatmentScreenState createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _simulateLoading(); // Simulate loading
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate a 3-second delay
    setState(() {
      _isLoading = false; // Stop loading after delay
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnosis & Treatment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
        ),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 6,
            ),
            const SizedBox(height: 20),
            Text(
              'Diagnosis & Treatment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Analyzing treatment options...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Diagnosis Results
              const Row(
                children: [
                  Icon(Icons.looks_one, size: 30, color: Colors.green), // Green icon for section 1
                  SizedBox(width: 10),
                  Text(
                    "Diagnosis Results:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.image,
                            fit: BoxFit.cover,
                            height: 200,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.result,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // Section 2: Recommended Pesticides
              const Row(
                children: [
                  Icon(Icons.looks_two, size: 30, color: Colors.green), // Green icon for section 2
                  SizedBox(width: 10),
                  Text(
                    "Recommended Pesticides:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.recommendedProducts.map((product) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PesticideDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.spa, size: 40, color: Colors.green), // Green spraying icon
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Insecticide",
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product["name"]!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Composition: ${product["composition"]}",
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}