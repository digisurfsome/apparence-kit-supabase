import 'dart:async';

import 'package:apparence_kit/core/initializer/onstart_service.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:apparence_kit/core/states/models/user_state.dart';
import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/modules/notifications/repositories/device_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final facebookEventApiProvider = Provider(
  (ref) => FacebookEventApi(
    deviceRepository: ref.watch(deviceRepositoryProvider),
    userState: ref.watch(userStateNotifierProvider),
  ),
);

class FacebookEventApi implements OnStartService {
  final DeviceRepository deviceRepository;
  final UserState userState;

  FacebookEventApi({
    required this.deviceRepository,
    required this.userState,
  });

  @override
  Future<void> init() async {
    if (kIsWeb) {
      return;
    }
    // We must init the facebook app events
    final facebookAppEvents = FacebookAppEvents();
    // This is required by RevenueCat
    await facebookAppEvents.setAutoLogAppEventsEnabled(false);
  }

  Future<void> initUser(String userId) async {
    if (kIsWeb) {
      return;
    }
    final facebookAppEvents = FacebookAppEvents();
    await facebookAppEvents.setUserID(userId);

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    final isGranted = await Permission.appTrackingTransparency.isGranted;
    if (!isGranted) {
      return;
    }
    await facebookAppEvents.setAdvertiserTracking(enabled: true);
  }

  Future<void> requestIDFA() async {
    if (kIsWeb) {
      return;
    }
    final facebookAppEvents = FacebookAppEvents();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.appTrackingTransparency.request();
      // analyticsApi?.logEvent('att_request', {
      //   'granted': true,
      // });

      debugPrint("IDFA status: $status");
      if (status.isGranted) {
        // collect identifiers for REVENUECAT
        await Purchases.collectDeviceIdentifiers();
        await facebookAppEvents.setAdvertiserTracking(enabled: true);
        await _initMetaUser();
        unawaited(facebookAppEvents.flush());
        await deviceRepository.refreshExtraData();
      } else { 
        await facebookAppEvents.setAdvertiserTracking(enabled: false);
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await _initMetaUser();
      await facebookAppEvents.setAutoLogAppEventsEnabled(true);
    }
  }

  Future<void> _initMetaUser() async {
    final facebookAppEvents = FacebookAppEvents();
    final userId = userState.user.idOrNull;
    if (userId != null) {
      await facebookAppEvents.setUserID(userId);
    }
    final userAnonId = await facebookAppEvents.getAnonymousId();
    
    if (userAnonId != null) {
      await Purchases.setFBAnonymousID(userAnonId);
    }
  }

  Future<void> logMetaStartTrial(String orderId, double price, String currency) async {
    try {
      final facebookAppEvents = FacebookAppEvents();
      await facebookAppEvents.logStartTrial(orderId: orderId, price: price, currency: currency);
    } catch (e) {
      Logger().e("Error logging StartTrial (facebook): $e");
      Sentry.captureException(e, stackTrace: StackTrace.current);
    }
  }

  Future<void> logMetaSubscribe(String orderId, double price, String currency) async {
    try {
      final facebookAppEvents = FacebookAppEvents();
      await facebookAppEvents.logSubscribe(orderId: orderId, price: price, currency: currency);
    } catch (e) {
      Logger().e("Error logging Subscribe (facebook): $e");
      Sentry.captureException(e, stackTrace: StackTrace.current);
    }
  }
}
