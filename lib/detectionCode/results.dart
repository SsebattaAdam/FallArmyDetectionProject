import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../main.dart';
import '../views/home/homepagedef.dart';
import 'TreatmentScreen.dart';
import 'camera_screening.dart';

class DetectionResultScreen extends StatefulWidget {
  final File image;
  final String result;
  final String recommendation;

  const DetectionResultScreen({
    super.key,
    required this.image,
    required this.result,
    required this.recommendation,
  });

  @override
  _DetectionResultScreenState createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen> {
  late FlutterTts flutterTts;
  String selectedVoice = "female";
  bool _isLoading = true;

  // Define class-specific information
  final Map<String, Map<String, dynamic>> classInfo = {
    "fall-armyworm-larval-damage": {
      "title": "Fall Armyworm (Larval Damage)",
      "color": Colors.red,
      "symptoms": [
        "Windowing (transparent patches on leaves)",
        "Ragged holes in leaves",
        "Damage to tassels and ears",
        "Presence of larvae with smooth skin",
        "Variable color (tan to dark green/black)",
        "Prominent inverted 'Y' marking on the head"
      ],
      "recommendations": [
        "Apply recommended insecticides early in the morning or late evening",
        "Consider biological control agents like Bacillus thuringiensis",
        "Implement crop rotation to break the pest cycle",
        "Monitor fields regularly for early detection",
        "Use pheromone traps to detect adult moths"
      ],
      "needsTreatment": true
    },
    "fall-armyworm-egg": {
      "title": "Fall Armyworm (Egg Stage)",
      "color": Colors.orange,
      "symptoms": [
        "Clusters of eggs on leaf surfaces",
        "Eggs covered with grayish, fuzzy scales",
        "Typically found on the underside of leaves",
        "Eggs appear in masses of 100-200",
        "Whitish to light green color when fresh"
      ],
      "recommendations": [
        "Apply ovicides (egg-targeting insecticides) promptly",
        "Consider using egg parasitoids like Trichogramma",
        "Remove and destroy affected leaves if infestation is limited",
        "Implement preventive measures before eggs hatch",
        "Monitor fields regularly for early detection"
      ],
      "needsTreatment": true
    },
    "healthy-maize": {
      "title": "Healthy Maize",
      "color": Colors.green,
      "symptoms": [
        "Vibrant green leaves without damage",
        "No visible pests or eggs",
        "Uniform growth pattern",
        "Healthy tassels and developing ears",
        "No signs of wilting or discoloration"
      ],
      "recommendations": [
        "Continue regular monitoring for early pest detection",
        "Maintain proper irrigation and fertilization",
        "Implement preventive measures during high-risk seasons",
        "Consider crop rotation for the next planting season",
        "Keep records of crop health for future reference"
      ],
      "needsTreatment": false
    }
  };

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    // Delay for 2 seconds before showing content
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String cleanResultText(String text) {
    return text.replaceAll(RegExp(r'^[01]\s*'), '');
  }

  // Get the detected class from the result text
  String getDetectedClass() {
    String cleanedResult = cleanResultText(widget.result).toLowerCase();

    if (cleanedResult.contains("fall-armyworm-larval-damage") ||
        cleanedResult.contains("fall armyworm larval damage")) {
      return "fall-armyworm-larval-damage";
    } else if (cleanedResult.contains("fall-armyworm-egg") ||
        cleanedResult.contains("fall armyworm egg")) {
      return "fall-armyworm-egg";
    } else if (cleanedResult.contains("healthy-maize") ||
        cleanedResult.contains("healthy maize")) {
      return "healthy-maize";
    }

    // Default fallback
    return "unknown";
  }

  void _navigateToTreatmentScreen() {
    final List<Map<String, dynamic>> recommendedProducts = [
      {
        "name": "Emamectin Benzoate",
        "composition": "Emamectin Benzoate 5% SG",
        "application_instructions": "Apply 0.5g per liter of water and spray on affected crops.",
        "application_method": "Spraying",
        "weather_conditions": "Apply in the early morning or late afternoon to prevent evaporation.",
        "toxicity": "Moderately toxic to humans and highly toxic to aquatic life.",
        "safety_precautions": "Wear protective clothing, avoid inhalation, and wash hands after application.",
        "control_methods": "Effective against larvae by disrupting their nervous system."
      },
      {
        "name": "Spinosad",
        "composition": "Spinosyn A 45%, Spinosyn D 55%",
        "application_instructions": "Use 1.5ml per liter of water and apply thoroughly.",
        "application_method": "Spraying",
        "weather_conditions": "Best applied in calm, cool conditions with no rain forecast.",
        "toxicity": "Low toxicity to humans but toxic to pollinators like bees.",
        "safety_precautions": "Avoid spraying near beehives and wear gloves while handling.",
        "control_methods": "Kills larvae by targeting their nervous system."
      },
      {
        "name": "Chlorantraniliprole",
        "composition": "Chlorantraniliprole 18.5% SC",
        "application_instructions": "Mix 0.3ml per liter of water and apply evenly.",
        "application_method": "Spraying",
        "weather_conditions": "Apply in dry weather; avoid application before heavy rainfall.",
        "toxicity": "Low mammalian toxicity but harmful to aquatic organisms.",
        "safety_precautions": "Do not apply near water sources; wear protective gear.",
        "control_methods": "Disrupts calcium balance in larvae, causing paralysis and death."
      },
      {
        "name": "Dimilin",
        "composition": "Diflubenzuron 25% WP",
        "application_instructions": "Apply 1g per liter of water and spray on affected areas.",
        "application_method": "Spraying",
        "weather_conditions": "Apply during early morning or late evening to avoid evaporation.",
        "toxicity": "Low toxicity to humans but toxic to aquatic organisms.",
        "safety_precautions": "Wear gloves and protective clothing during application.",
        "control_methods": "Disrupts the normal development of immature insects."
      },
      {
        "name": "Intrepid",
        "composition": "Methoxyfenozide 24% SC",
        "application_instructions": "Use 2ml per liter of water and spray evenly.",
        "application_method": "Spraying",
        "weather_conditions": "Apply in calm weather with no rain forecast for 24 hours.",
        "toxicity": "Low toxicity to humans and non-target organisms.",
        "safety_precautions": "Avoid inhalation and wear protective gear.",
        "control_methods": "Prevents larvae from molting, leading to death."
      },
      {
        "name": "Neem-Based Insecticides",
        "composition": "Neem Oil 1% EC",
        "application_instructions": "Mix 5ml per liter of water and spray on crops.",
        "application_method": "Spraying",
        "weather_conditions": "Apply in the early morning or late afternoon.",
        "toxicity": "Low toxicity to humans and the environment.",
        "safety_precautions": "Avoid direct contact with skin and eyes.",
        "control_methods": "Controls larvae and eggs by disrupting their hormonal balance."
      },
      {
        "name": "Ampligo®",
        "composition": "Chlorantraniliprole 9.3%, Lambda-Cyhalothrin 4.6%",
        "application_instructions": "Mix 0.4ml per liter of water and spray on foliage.",
        "application_method": "Foliar Spraying",
        "weather_conditions": "Apply in dry weather with no rain forecast.",
        "toxicity": "Moderately toxic to aquatic organisms.",
        "safety_precautions": "Wear protective clothing and avoid application near water bodies.",
        "control_methods": "Combines systemic and contact action for effective control."
      },
      {
        "name": "DenimFit®",
        "composition": "Emamectin Benzoate 5%, Lufenuron 10%",
        "application_instructions": "Use 0.5g per liter of water and spray on crops.",
        "application_method": "Foliar Spraying",
        "weather_conditions": "Apply in calm weather with no rain forecast.",
        "toxicity": "Moderately toxic to humans and aquatic organisms.",
        "safety_precautions": "Avoid inhalation and wear protective gear.",
        "control_methods": "Targets larvae by disrupting their growth and development."
      },
      {
        "name": "Fortenza Duo",
        "composition": "Cyantraniliprole 20%, Thiamethoxam 30%",
        "application_instructions": "Apply as a seed treatment before planting.",
        "application_method": "Seed Treatment",
        "weather_conditions": "Ensure seeds are dry before planting.",
        "toxicity": "Low toxicity to humans but toxic to aquatic organisms.",
        "safety_precautions": "Wear gloves and avoid direct contact with treated seeds.",
        "control_methods": "Provides systemic protection against larvae feeding on plants."
      },
      {
        "name": "Acelepryn®",
        "composition": "Chlorantraniliprole 18.4% SC",
        "application_instructions": "Mix 0.3ml per liter of water and apply evenly.",
        "application_method": "Spraying",
        "weather_conditions": "Apply in dry weather with no rain forecast.",
        "toxicity": "Low toxicity to humans and mammals.",
        "safety_precautions": "Avoid application near water sources and wear protective gear.",
        "control_methods": "Provides long-lasting residual control of larvae."
      },
    ];

    Get.to(() => TreatmentScreen(
      image: widget.image,
      result: cleanResultText(widget.result),
      recommendedProducts: recommendedProducts,
    ));
  }

  Future<void> _speakText() async {
    String detectedClass = getDetectedClass();
    String textToRead = "Detection Result: ${cleanResultText(widget.result)}. ";

    if (classInfo.containsKey(detectedClass)) {
      var info = classInfo[detectedClass]!;
      textToRead += "Identified as ${info['title']}. ";

      textToRead += "Symptoms include: ";
      for (String symptom in info['symptoms']) {
        textToRead += "$symptom, ";
      }

      textToRead += "Recommendations: ";
      for (String recommendation in info['recommendations']) {
        textToRead += "$recommendation, ";
      }
    } else if (widget.recommendation.isNotEmpty) {
      textToRead += "Recommendations: ${widget.recommendation}.";
    }

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setVoice({"name": selectedVoice, "locale": "en-US"});
    await flutterTts.speak(textToRead);
  }

  Future<void> _generatePdfReport() async {
    final pdf = pw.Document();
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/detection_report.pdf';
    final File file = File(path);

    String detectedClass = getDetectedClass();
    bool needsTreatment = detectedClass != "healthy-maize" && detectedClass != "unknown";

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Detection Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            pw.Text("Detection Result:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(cleanResultText(widget.result), style: pw.TextStyle(fontSize: 16)),

            if (classInfo.containsKey(detectedClass)) ...[
              pw.SizedBox(height: 10),
              pw.Text("Identified as: ${classInfo[detectedClass]!['title']}",
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: detectedClass == "healthy-maize" ? PdfColors.green : PdfColors.red
                  )),
              pw.SizedBox(height: 10),

              pw.Text("Symptoms:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              for (String symptom in classInfo[detectedClass]!['symptoms'])
                pw.Bullet(text: symptom),

              pw.SizedBox(height: 10),
              pw.Text("Recommendations:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              for (String recommendation in classInfo[detectedClass]!['recommendations'])
                pw.Bullet(text: recommendation),
            ],

            if (widget.recommendation.isNotEmpty && !classInfo.containsKey(detectedClass)) ...[
              pw.SizedBox(height: 10),
              pw.Text("Recommendations:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(widget.recommendation, style: pw.TextStyle(fontSize: 16)),
            ],

            pw.SizedBox(height: 20),
            pw.Text("More Information:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.UrlLink(
              destination: "https://www.fao.org/fall-armyworm",
              child: pw.Text("FAO - Fall Armyworm Management", style: pw.TextStyle(color: PdfColors.blue)),
            ),
            pw.SizedBox(height: 5),
            pw.UrlLink(
              destination: "https://www.cabi.org/fall-armyworm",
              child: pw.Text("CABI - Fall Armyworm Information", style: pw.TextStyle(color: PdfColors.blue)),
            ),
          ],
        ),
      ),
    );

    await file.writeAsBytes(await pdf.save());
    OpenFile.open(path);
  }


  @override
  Widget build(BuildContext context) {
    String detectedClass = getDetectedClass();
    bool needsTreatment = detectedClass != "healthy-maize" && detectedClass != "unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detection Results',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Get.to(defaultHome);
          },
        ),
      ),

      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 6,
            ),
            const SizedBox(height: 20),
            const Text(
              "Analyzing Results...",
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          widget.image,
                          fit: BoxFit.cover,
                          height: 300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Detection Result:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cleanResultText(widget.result),
                      style: const TextStyle(fontSize: 16),
                    ),

                    if (classInfo.containsKey(detectedClass)) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Identified as ${classInfo[detectedClass]!['title']}:",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: classInfo[detectedClass]!['color']
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Symptoms:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String symptom in classInfo[detectedClass]!['symptoms'])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(symptom, style: const TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text("Recommendations:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String recommendation in classInfo[detectedClass]!['recommendations'])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(recommendation, style: const TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "More Information:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "FAO - Fall Armyworm Management: https://www.fao.org/fall-armyworm\n"
                            "CABI - Fall Armyworm Information: https://www.cabi.org/fall-armyworm",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],

                    if (!classInfo.containsKey(detectedClass) && widget.recommendation.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text("Recommendations:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(widget.recommendation, style: const TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Fixed Bottom Buttons
          if (needsTreatment && !_isLoading)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _navigateToTreatmentScreen,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Confirm & See Treatment", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _generatePdfReport,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("Download Report", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 30, color: Colors.green),
                    onPressed: _speakText,
                  ),
                ],
              ),
            ),
          // For healthy maize, only show download and speak buttons
          if (detectedClass == "healthy-maize" && !_isLoading)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _generatePdfReport,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("Download Report", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 30, color: Colors.green),
                    onPressed: _speakText,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
