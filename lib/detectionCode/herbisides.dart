import 'package:flutter/material.dart';

class Herbisides extends StatefulWidget {
  const Herbisides({Key? key}) : super(key: key);

  @override
  _HerbisidesState createState() => _HerbisidesState();
}

class _HerbisidesState extends State<Herbisides> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _treatments = [];

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock data - in a real app, this would come from an API or database
    setState(() {
      _treatments = [
        {
          "name": "Neem Oil",
          "type": "Organic",
          "composition": "Azadirachtin 0.5%",
          "description": "Natural pesticide effective against a wide range of pests including aphids, mealybugs, and mites.",
          "usage": "Mix 2-4 tablespoons per gallon of water and spray on affected plants."
        },
        {
          "name": "Bacillus thuringiensis",
          "type": "Biological",
          "composition": "Bt spores and proteins",
          "description": "Effective against caterpillars and larvae of many pest insects.",
          "usage": "Apply as a foliar spray when caterpillars are first noticed."
        },
        {
          "name": "Pyrethrin",
          "type": "Botanical",
          "composition": "Pyrethrum extract",
          "description": "Broad-spectrum insecticide derived from chrysanthemum flowers.",
          "usage": "Apply directly to affected plants in the evening to minimize impact on beneficial insects."
        },
        {
          "name": "Copper Fungicide",
          "type": "Fungicide",
          "composition": "Copper octanoate 1.8%",
          "description": "Controls fungal diseases including late blight, powdery mildew, and rust.",
          "usage": "Apply every 7-10 days as a preventative measure."
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Treatment Options',
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
              'Loading Treatments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Finding the best options for you...",
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
              // Treatment Information
              const Text(
                "Common Plant Treatments",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Below are effective treatments for various plant issues. Select one to see detailed application instructions.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // Treatment List
              ..._treatments.map((treatment) {
                return GestureDetector(
                  onTap: () {
                    _showTreatmentDetails(context, treatment);
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.spa,
                              size: 30,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  treatment["type"],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  treatment["name"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Composition: ${treatment["composition"]}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              // General Tips Section
              const SizedBox(height: 20),
              const Text(
                "General Treatment Tips",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                  "Always read product labels carefully before application",
                  Icons.menu_book
              ),
              _buildTipCard(
                  "Apply treatments in the early morning or evening to avoid heat",
                  Icons.wb_sunny
              ),
              _buildTipCard(
                  "Wear protective clothing when applying treatments",
                  Icons.security
              ),
              _buildTipCard(
                  "Keep treatments away from children and pets",
                  Icons.pets
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.green[700], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTreatmentDetails(BuildContext context, Map<String, dynamic> treatment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.spa, color: Colors.green, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              treatment["name"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              treatment["type"],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    treatment["description"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Composition",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    treatment["composition"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Usage Instructions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    treatment["usage"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
