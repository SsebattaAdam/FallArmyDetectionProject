import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/custom_appbar.dart';
import '../../common/custom_container.dart';
import '../../constants/constants.dart';
import '../../detectionCode/upload_capture.dart';
import '../../main.dart';
import '../category/widgets/spraying_widget.dart';
import '../category/widgets/weathercardwidget.dart';
import 'newpage.dart';
import 'WeatherAndSpraying.dart';
import 'faw_recommendation_stages_page.dart';
import 'package:fammaize/views/home/diagnosisdetailspage.dart';
// Add this import

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
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            "Fall Armyworm Diagnosis ",
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
              SizedBox(height: 30),
              HorizontalCardScroller(),
              SizedBox(height: 20),

              // First Container for Detection Options
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: kSecondary,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetectionCard(
                      title: "Upload an Image,",
                      icon: Icons.upload,
                      onTap: () {
                        Get.to(() => UploadCaptureScreen());
                      },
                    ),
                    SizedBox(height: 12.h),
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

              // Second Container for Monitoring Options
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: kSecondary,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.2,
                  ),
                  children: [
                    _buildCard(
                      title: "Maize Monitoring Reports",
                      subtitle: "View Details",
                      icon: Icons.report,
                      destinationPage: DiagnosisDetailPage(
                        diagnoses: [
                          {
                            'disease': 'Fall Armyworm',
                            'date': DateTime.now().toIso8601String(), // or just DateTime.now(),
                            'stage': 'Larval Damage',
                          },
                          {
                            'disease': 'Fall Armyworm',
                            'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
                            'stage': 'Frass Stage',
                          },
                          {
                            'disease': 'Fall Armyworm',
                            'date': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
                            'stage': 'Egg Stage',
                          },
                        ],
                      ),

                    ),
                    _buildCard(
                      title: "Treatment&Recommendations",
                      subtitle: "By FAW Stage",
                      icon: Icons.medical_services,
                      destinationPage: FAWRecommendationStagesPage(),
                    ),
                    _buildCard(
                      title: "Expert Opinions",
                      subtitle: "View Insights",
                      icon: Icons.person_search,
                      destinationPage: Newpagetobedefined(),
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

  Widget _buildDetectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: kPrimary,
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
            Icon(icon, size: 24.w, color: kPrimaryLight),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: kPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget destinationPage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(12.r),
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
            Icon(icon, size: 32.w, color: kPrimaryLight),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                color: kPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
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
