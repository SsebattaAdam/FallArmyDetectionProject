import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find<AnalyticsService>();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Initialize service
  Future<AnalyticsService> init() async {
    // Set analytics collection enabled (can be toggled based on user preferences)
    await _analytics.setAnalyticsCollectionEnabled(true);

    // Log app open event
    await logAppOpen();
    return this;
  }

  // Get observer for automatic screen tracking
  FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // ===== USER TRACKING =====

  // Track user ID (call after login)
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Track user properties
  Future<void> setUserProperty({required String name, required String? value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Track login
  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method ?? 'default');
  }

  // Track signup
  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'default');
  }

  // ===== NAVIGATION TRACKING =====

  // Track screen views
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Track navigation between screens
  Future<void> logNavigation(String fromScreen, String toScreen) async {
    await _analytics.logEvent(
      name: 'navigation',
      parameters: {
        'from_screen': fromScreen,
        'to_screen': toScreen,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== DETECTION TRACKING =====

  // Track detection attempts
  Future<void> logDetectionAttempt({
    required String method,
    String? source,
  }) async {
    await _analytics.logEvent(
      name: 'detection_attempt',
      parameters: {
        'method': method,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Track detection results
  Future<void> logDetectionResult({
    required String method,
    required String result,
    required double confidence,
    required bool isArmyworm,
    required int processingTimeMs,
  }) async {
    await _analytics.logEvent(
      name: 'detection_result',
      parameters: {
        'method': method,
        'result': result,
        'confidence': confidence,
        'is_armyworm': isArmyworm,
        'processing_time_ms': processingTimeMs,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Track detection errors
  Future<void> logDetectionError({
    required String method,
    required String errorType,
    required String errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'detection_error',
      parameters: {
        'method': method,
        'error_type': errorType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== FEATURE USAGE TRACKING =====

  // Track button clicks
  Future<void> logButtonClick({
    required String buttonName,
    required String screenName,
    Map<String, Object>? additionalParams,
  }) async {
    final Map<String, Object> parameters = {
      'button_name': buttonName,
      'screen_name': screenName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (additionalParams != null) {
      parameters.addAll(additionalParams);
    }

    await _analytics.logEvent(
      name: 'button_click',
      parameters: parameters,
    );
  }

  // Track feature usage
  Future<void> logFeatureUsage({
    required String featureName,
    Map<String, Object>? additionalParams,
  }) async {
    final Map<String, Object> parameters = {
      'feature_name': featureName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (additionalParams != null) {
      parameters.addAll(additionalParams);
    }

    await _analytics.logEvent(
      name: 'feature_usage',
      parameters: parameters,
    );
  }

  // Track sharing
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  // ===== PERFORMANCE TRACKING =====

  // Track app startup time
  Future<void> logAppStartupTime(int milliseconds) async {
    await _analytics.logEvent(
      name: 'app_startup_time',
      parameters: {
        'milliseconds': milliseconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Track API response time
  Future<void> logApiResponseTime({
    required String endpoint,
    required int milliseconds,
    required bool isSuccess,
    String? errorMessage,
  }) async {
    final Map<String, Object> parameters = {
      'endpoint': endpoint,
      'milliseconds': milliseconds,
      'is_success': isSuccess,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (errorMessage != null) {
      parameters['error_message'] = errorMessage;
    }

    await _analytics.logEvent(
      name: 'api_response_time',
      parameters: parameters,
    );
  }

  // ===== STANDARD EVENTS =====

  // App open
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  // Search
  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  // Tutorial begin
  Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  // Tutorial complete
  Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }

  // Generic error
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    final Map<String, Object> parameters = {
      'error_type': errorType,
      'error_message': errorMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (screenName != null) {
      parameters['screen_name'] = screenName;
    }

    await _analytics.logEvent(
      name: 'app_error',
      parameters: parameters,
    );
  }

// Change this method in your AnalyticsService class
  void logEvent({required String name, required Map<String, Object> parameters}) {
    // Log the event using Firebase Analytics
    FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
