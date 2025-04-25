import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Expertsandrecomendations/Expertinsites.dart';
import '../../Expertsandrecomendations/documentupload.dart';
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
      backgroundColor:  Colors.green[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "Fall Armyworm Diagnosis ",
            style: TextStyle(
              color: Colors.green[100],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomContainer(
          containerContent: Column(
              children: [
              const SizedBox(height: 30),
          const HorizontalCardScroller(),
                const SizedBox(height: 20),
          // First Container for Detection Options
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
                color: kSecondary, // Green background
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
            BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ]),
        child: Column(
          children: [
            // Upload an Image Card
            _buildDetectionCard(
              title: "Upload an Image,",
              icon: Icons.upload,
              onTap: () {
                Get.to(() => const UploadCaptureScreenapi());
              },
            ),
            SizedBox(height: 12.h), // Spacing between cards
            // Scanning the Plant Images Card
            _buildDetectionCard(
              title: "Scanning the Plant Images",
              icon: Icons.camera_alt,
              onTap: () {
                Get.to(() => RealTimeDetection());
              },
            ),
          ],
        ),
      ),

      // Second Container for Other Options

      Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: kSecondary, // Green background
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(2, 2),
      ),
    ]),
    child: GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // Two items per row
    crossAxisSpacing: 12.w,
    mainAxisSpacing: 12.h,
    childAspectRatio: 1.2, // Slightly rectangular cards
    ),
    children: [
    _buildCard(
    title: "Herbicides",
    subtitle: "View Details",
    icon: Icons.more_horiz_sharp,
    destinationPage: ExpertInsightsPage(),
    ),
    _buildCard(
    title: "Expert Insights",
    subtitle: "View Details",
    icon: Icons.insights,
    destinationPage:  DocumentUploadPage(),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    );
  }

  // Helper function to build a detection card
  Widget _buildDetectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Occupy full width
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: kPrimary, // Inner card background color
          borderRadius: BorderRadius.circular(12.r),
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
            Icon(
              icon,
              size: 24.w,
              color:  Colors.green[800],
            ),
            SizedBox(width: 12.w), // Spacing between icon and text
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a standard card with navigation
  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget destinationPage,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to the destination page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: kPrimary, // Inner card background color
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(2, 2),
      ),
    ]),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    icon,
    size: 32.w,
      color:  Colors.green[800],
    ),
    SizedBox(height: 8.h), // Spacing between icon and text
    Text(
    title,
    style: TextStyle(
    fontSize: 18.sp,
    color: kPrimaryLight,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 4.h), // Spacing between title and subtitle
    Text(
    subtitle,
    style: TextStyle(
    fontSize: 14.sp,
    color: Colors.black.withOpacity(0.8),
    ),
    ),
    ],
    ),
    ),
    );
  }
}