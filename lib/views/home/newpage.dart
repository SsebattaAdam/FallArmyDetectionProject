import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../common/app_style.dart';
import '../../common/back_ground_container.dart';
import '../../common/reusable_textwidget.dart';
import '../../constants/constants.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _showWebView = false; // Control whether to show WebView
  bool _hasError = false; // Track if there was an error loading the map
  String _mapUrl = "https://fastapitest-1qsv.onrender.com/map_view";
  Timer? _refreshTimer; // Timer for auto-refresh
  int _loadingSeconds = 0; // Track loading time
  Timer? _loadingTimer; // Timer for initial loading

  @override
  void initState() {
    super.initState();

    // Show loading indicator for at least 3 seconds
    _loadingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _loadingSeconds++;
      });

      if (_loadingSeconds >= 3) {
        _loadingTimer?.cancel();
        setState(() {
          _showWebView = true;
        });
        _initializeWebView();
      }
    });

    // Set up auto-refresh timer (every 60 seconds)
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted && !_isLoading) {
        _refreshMap();
      }
    });
  }

  void _initializeWebView() {
    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow navigation to all URLs
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_mapUrl));
  }

  void _refreshMap() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.reload();

    // Show a brief notification that the map is refreshing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing map data...'),
        duration: Duration(seconds: 2),
        backgroundColor: kPrimary,
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: .3,
        backgroundColor: kPrimary,
        title: ReusableTextwidget(
            text: 'Fall Armyworm Map',
            style: appStyle(22, kPrimaryLight, FontWeight.w600)
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: kPrimaryLight),
            onPressed: _refreshMap,
          ),
        ],
      ),
      body: BackGroundContainer(
        color: Colors.white,
        child: Stack(
          children: [
            // Show WebView only after initial loading period
            if (_showWebView && !_hasError)
              WebViewWidget(controller: _controller),

            // Error message if map fails to load
            if (_hasError && !_isLoading)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60.sp,
                    ),
                    SizedBox(height: 20.h),
                    ReusableTextwidget(
                      text: 'Failed to load map',
                      style: appStyle(18, Colors.red, FontWeight.w500),
                    ),
                    SizedBox(height: 10.h),
                    ReusableTextwidget(
                      text: 'Please check your internet connection',
                      style: appStyle(16, Colors.black54, FontWeight.w400),
                    ),
                    SizedBox(height: 30.h),
                    ElevatedButton(
                      onPressed: _refreshMap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      ),
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              ),

            // Loading indicator
            if (_isLoading || !_showWebView)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: kPrimary,
                      ),
                      SizedBox(height: 20.h),
                      ReusableTextwidget(
                        text: 'Loading Fall Armyworm Map...',
                        style: appStyle(16, kPrimary, FontWeight.w500),
                      ),
                      SizedBox(height: 10.h),
                      ReusableTextwidget(
                        text: 'Please wait while we fetch the latest data',
                        style: appStyle(14, Colors.black54, FontWeight.w400),
                      ),
                      // Show countdown for initial loading
                      if (!_showWebView)
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: ReusableTextwidget(
                            text: 'Ready in ${3 - _loadingSeconds} seconds...',
                            style: appStyle(14, Colors.black54, FontWeight.w400),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // Auto-refresh indicator
            Positioned(
              bottom: 80.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sync,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Auto-refresh: ON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Add a floating action button to toggle filters
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        child: Icon(Icons.filter_alt, color: kPrimaryLight),
        onPressed: () {
          _showFilterDialog(context);
        },
      ),
    );
  }

  // Show a dialog to filter the map data
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter Map Data',
            style: appStyle(18, kPrimary, FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time period filter
              ListTile(
                leading: Icon(Icons.calendar_today, color: kPrimary),
                title: Text(
                  'Last 7 days',
                  style: appStyle(16, Colors.black, FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _loadFilteredMap('days=7');
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today, color: kPrimary),
                title: Text(
                  'Last 30 days',
                  style: appStyle(16, Colors.black, FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _loadFilteredMap('days=30');
                },
              ),

              // Detection type filter
              ListTile(
                leading: Icon(Icons.bug_report, color: kPrimary),
                title: Text(
                  'Larval Damage',
                  style: appStyle(16, Colors.black, FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _loadFilteredMap('class=fall-armyworm-larval-damage');
                },
              ),
              ListTile(
                leading: Icon(Icons.egg, color: kPrimary),
                title: Text(
                  'Eggs',
                  style: appStyle(16, Colors.black, FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _loadFilteredMap('class=fall-armyworm-egg');
                },
              ),

              // Reset filters
              Divider(),
              ListTile(
                leading: Icon(Icons.refresh, color: kPrimary),
                title: Text(
                  'Reset Filters',
                  style: appStyle(16, Colors.black, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _loadFilteredMap('');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Load the map with filters
  void _loadFilteredMap(String queryParams) {
    setState(() {
      _isLoading = true;
      _hasError = false;
      if (queryParams.isNotEmpty) {
        _mapUrl = "https://fastapitest-1qsv.onrender.com/map_view?$queryParams";
      } else {
        _mapUrl = "https://fastapitest-1qsv.onrender.com/map_view";
      }
      _controller.loadRequest(Uri.parse(_mapUrl));
    });
  }
}
