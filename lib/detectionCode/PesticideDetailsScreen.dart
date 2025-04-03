import 'package:flutter/material.dart';

class PesticideDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const PesticideDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _PesticideDetailScreenState createState() => _PesticideDetailScreenState();
}

class _PesticideDetailScreenState extends State<PesticideDetailScreen> {
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
        title: Text(
          widget.product["name"]!,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              widget.product["name"]!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Loading pesticide details...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pesticide Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.product["name"]!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Composition: ${widget.product["composition"]}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Details Section
              _buildDetailCard(
                title: "Application Instructions",
                content: widget.product["application_instructions"],
                icon: Icons.info_outline,
              ),
              _buildDetailCard(
                title: "Application Method",
                content: widget.product["application_method"],
                icon: Icons.handyman,
              ),
              _buildDetailCard(
                title: "Weather Conditions",
                content: widget.product["weather_conditions"],
                icon: Icons.cloud,
              ),
              _buildDetailCard(
                title: "Toxicity",
                content: widget.product["toxicity"],
                icon: Icons.warning_amber_outlined,
              ),
              _buildDetailCard(
                title: "Safety Precautions",
                content: widget.product["safety_precautions"],
                icon: Icons.health_and_safety,
              ),
              _buildDetailCard(
                title: "Control Methods",
                content: widget.product["control_methods"],
                icon: Icons.bug_report,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}