import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/custom_appbar.dart';
import '../../common/custom_container.dart';
import '../../constants/constants.dart';
import '../../detectionCode/Upload_withApi_added.dart';
import '../../detectionCode/upload_capture.dart';
import '../../main.dart';
import '../category/widgets/spraying_widget.dart';
import '../category/widgets/weathercardwidget.dart';
import 'newpage.dart';
import 'WeatherAndSpraying.dart';

class Homepage2Default extends StatefulWidget {
  const Homepage2Default({super.key});

  @override
  State<Homepage2Default> createState() => _Homepage2DefaultState();
}

class _Homepage2DefaultState extends State<Homepage2Default> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Fall Armyworm Coverage",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: kPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomContainer(
          containerContent: Column(
            children: [
              SizedBox(height: 20),
              // Weather & Risk Alerts Section
              WeatherCardWidget(),
              SizedBox(height: 20),
              // Field Monitoring Reports
              _buildSectionCard(
                title: "Field Monitoring Reports",
                icon: Icons.article,
                onTap: () => Get.to(() => NewPage()),
              ),
              SizedBox(height: 12),
              // Expert Opinions
              _buildSectionCard(
                title: "Expert Opinions",
                icon: Icons.person,
                onTap: () => Get.to(() => NewPage()),
              ),
              SizedBox(height: 12),
              // Treatment & Recommendations
              _buildSectionCard(
                title: "Treatment & Recommendations",
                icon: Icons.local_hospital,
                onTap: () => Get.to(() => NewPage()),
              ),
              SizedBox(height: 20),
              // Individual FAW Stages
              _buildGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSecondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: kPrimaryLight),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: kPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      children: [
        _buildGridCard("FAW Egg Stage", Icons.bug_report, NewPage()),
        _buildGridCard("FAW Larval Damage", Icons.bug_report, NewPage()),
        _buildGridCard("FAW Frass", Icons.bug_report, NewPage()),
        _buildGridCard("Healthy Maize", Icons.grass, NewPage()),
        _buildGridCard("FAW Larva", Icons.bug_report, NewPage()),
      ],
    );
  }

  Widget _buildGridCard(String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Get.to(() => page),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: kPrimaryLight),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: kPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget NewPage() {}
}
