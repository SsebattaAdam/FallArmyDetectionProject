import 'package:fammaize/analytics2/providers/providersfiles.dart';
import 'package:fammaize/analytics2/service/AnalyticsService2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analyticspage.dart';


class AnalyticsScreenWrapper extends StatelessWidget {
  // You can make this configurable if needed
  final String apiBaseUrl;

  const AnalyticsScreenWrapper({
    Key? key,
    this.apiBaseUrl = 'https://fastapitest-1qsv.onrender.com'
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AnalyticsProvider(
        analyticsService: AnalyticsApiService2(baseUrl: apiBaseUrl),
      ),
      child: const AnalyticsScreen(),
    );
  }
}
