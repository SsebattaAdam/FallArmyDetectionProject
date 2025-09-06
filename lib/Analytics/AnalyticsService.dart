import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find<AnalyticsService>();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isInitialized = false;

  Future<AnalyticsService> init() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);

      if (kDebugMode) {
        // Enable verbose logging in debug mode
        await _analytics.setSessionTimeoutDuration(const Duration(minutes: 30));
        debugPrint('Firebase Analytics initialized. Session ID: ${await _analytics.getSessionId()}');
      }

      await logAppOpen();
      _isInitialized = true;

      debugPrint('AnalyticsService initialized successfully');
    } catch (e, stack) {
      debugPrint('Error initializing AnalyticsService: $e\n$stack');
      _isInitialized = false;
    }
    return this;
  }

  FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // === Utility Functions ===
  int _currentTimestamp() => DateTime.now().millisecondsSinceEpoch;

  Map<String, Object> _withTimestamp(Map<String, Object> params) {
    return {
      ...params,
      'timestamp': _currentTimestamp(),
    };
  }

  Future<void> logAppStartupTime(int milliseconds) async {
    await logEvent(
      name: 'app_startup_time',
      parameters: {'milliseconds': milliseconds},
    );
  }

  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (screenName != null) 'screen_name': screenName,
      },
    );
  }

  Future<void> logEvent({
    required String name,
    required Map<String, Object> parameters,
    bool debugLog = true,
  }) async {
    if (!_isInitialized) {
      debugPrint('Analytics not initialized. Event $name not sent.');
      return;
    }

    try {
      final paramsWithTimestamp = _withTimestamp(parameters);
      await _analytics.logEvent(
        name: name,
        parameters: paramsWithTimestamp,
      );

      if (debugLog || kDebugMode) {
        debugPrint('''
🎯 Analytics Event Logged
┌ Event: $name
${paramsWithTimestamp.entries.map((e) => '├ ${e.key}: ${e.value}').join('\n')}
└ Timestamp: ${paramsWithTimestamp['timestamp']}
''');
      }
    } catch (e, stack) {
      debugPrint('''
❌ Failed to log event: $name
Error: $e
Parameters: $parameters
Stack: $stack
''');
    }
  }

  // === User Tracking ===
  Future<void> setUserId(String? userId) async {
    if (!_isInitialized) return;

    try {
      await _analytics.setUserId(id: userId);
      debugPrint('User ID set: ${userId ?? 'null'}');
    } catch (e, stack) {
      await _handleError('setUserId', e, stack);
    }
  }

  Future<void> setUserProperty({required String name, required String? value}) async {
    if (!_isInitialized) return;

    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('User property set - $name: ${value ?? 'null'}');
    } catch (e, stack) {
      await _handleError('setUserProperty', e, stack);
    }
  }

  Future<void> logLogin({String? method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method ?? 'default'},
    );
  }

  Future<void> logSignUp({String? method}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': method ?? 'default'},
    );
  }

  // === Navigation Tracking ===
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    bool enableFirebaseScreenView = true,
  }) async {
    if (enableFirebaseScreenView) {
      try {
        await _analytics.logScreenView(
          screenName: screenName,
          screenClass: screenClass ?? screenName,
        );
      } catch (e, stack) {
        await _handleError('logScreenView', e, stack);
      }
    }

    await logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
      },
    );
  }

  Future<void> logNavigation(String fromScreen, String toScreen) async {
    await logEvent(
      name: 'navigation',
      parameters: {
        'from_screen': fromScreen,
        'to_screen': toScreen,
      },
    );
  }

  // === Detection Tracking ===
  Future<void> logImageUpload({required String source}) async {
    await logEvent(
      name: 'image_upload',
      parameters: {'source': source},
    );
  }

  Future<void> logLeafValidation({
    required bool isMaizeLeaf,
    String? reasonIfRejected,
  }) async {
    await logEvent(
      name: 'leaf_validation',
      parameters: {
        'is_maize_leaf': isMaizeLeaf,
        if (!isMaizeLeaf && reasonIfRejected != null)
          'rejection_reason': reasonIfRejected,
      },
    );
  }

  Future<void> logDetectionAttempt({required String method, String? source}) async {
    await logEvent(
      name: 'detection_attempt',
      parameters: {
        'method': method,
        if (source != null) 'source': source,
      },
    );
  }

  Future<void> logDetectionResult({
    required String method,
    required String result,
    required double confidence,
    required bool isArmyworm,
    required int processingTimeMs,
  }) async {
    await logEvent(
      name: 'detection_result',
      parameters: {
        'method': method,
        'result': result,
        'confidence': confidence,
        'is_armyworm': isArmyworm,
        'processing_time_ms': processingTimeMs,
      },
    );
  }

  Future<void> logDetectionError({
    required String method,
    required String errorType,
    required String errorMessage,
  }) async {
    await logEvent(
      name: 'detection_error',
      parameters: {
        'method': method,
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }

  // === Feature Usage ===
  Future<void> logButtonClick({
    required String buttonName,
    required String screenName,
    Map<String, Object>? additionalParams,
  }) async {
    await logEvent(
      name: 'button_click',
      parameters: {
        'button_name': buttonName,
        'screen_name': screenName,
        ...?additionalParams,
      },
    );
  }

  // === Card View Tracking ===

  /// Track viewing of information cards (pests/diseases)
  Future<void> logCardViewed({
    required String cardType, // 'pest', 'disease', etc.
    required String cardName,
    String? cardId,
    String? category,
  }) async {
    await logEvent(
      name: 'info_card_viewed',
      parameters: {
        'card_type': cardType,
        'card_name': cardName,
        if (cardId != null) 'card_id': cardId,
        if (category != null) 'category': category,
      },
    );
  }

  /// Track viewing of treatment recommendation cards
  Future<void> logTreatmentCardViewed({
    required String diseaseName,
    required String recommendationId,
    String? treatmentType, // 'chemical', 'organic', 'prevention'
    int? severityLevel,
  }) async {
    await logEvent(
      name: 'treatment_card_viewed',
      parameters: {
        'disease_name': diseaseName,
        'recommendation_id': recommendationId,
        if (treatmentType != null) 'treatment_type': treatmentType,
        if (severityLevel != null) 'severity_level': severityLevel,
      },
    );
  }

  /// Track viewing of expert opinion cards
  Future<void> logExpertOpinionCardViewed({
    required String expertName,
    required String topic,
    String? expertiseLevel, // 'local', 'national', 'international'
    String? organization,
  }) async {
    await logEvent(
      name: 'expert_card_viewed',
      parameters: {
        'expert_name': expertName,
        'topic': topic,
        if (expertiseLevel != null) 'expertise_level': expertiseLevel,
        if (organization != null) 'organization': organization,
      },
    );
  }

  /// Track card interactions (expanded/collapsed)
  Future<void> logCardInteraction({
    required String cardType,
    required String cardId,
    required String action, // 'expanded', 'collapsed', 'shared'
    String? sourceScreen,
  }) async {
    await logEvent(
      name: 'card_interaction',
      parameters: {
        'card_type': cardType,
        'card_id': cardId,
        'action': action,
        if (sourceScreen != null) 'source_screen': sourceScreen,
      },
    );
  }

  // === Error Handling ===
  Future<void> _handleError(String methodName, dynamic error, StackTrace stack) async {
    debugPrint('''
⚠️ Analytics Error in $methodName
Error: $error
Stack Trace: $stack
''');
  }

  // === Standard Events ===
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      debugPrint('Logged app_open event');
    } catch (e, stack) {
      await _handleError('logAppOpen', e, stack);
    }
  }

  Future<void> logSearch(String searchTerm) async {
    await logEvent(
      name: 'search',
      parameters: {'search_term': searchTerm},
    );
  }
}