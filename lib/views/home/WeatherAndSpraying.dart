import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../category/widgets/weathercardwidget.dart';
import '../category/widgets/spraying_widget.dart';

class HorizontalCardScroller extends StatefulWidget {
  const HorizontalCardScroller({super.key});

  @override
  _HorizontalCardScrollerState createState() => _HorizontalCardScrollerState();
}

class _HorizontalCardScrollerState extends State<HorizontalCardScroller> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Start the automatic page scrolling every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPage < 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to the first card
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop the timer when widget is disposed
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h, // Set the height of the scrolling view
      child: PageView(
        controller: _pageController, // Use the PageController
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add space to both sides
            child: WeatherCard(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add space to both sides
            child: SprayingConditionsCard(),
          ),
        ],
      ),
    );
  }
}
