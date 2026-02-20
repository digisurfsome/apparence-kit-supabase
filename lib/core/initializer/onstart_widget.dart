import 'package:apparence_kit/core/initializer/models/run_state.dart';
import 'package:apparence_kit/core/initializer/onstart_service.dart';
import 'package:apparence_kit/core/initializer/pending_notification_handler.dart';
import 'package:apparence_kit/core/states/events_dispatcher.dart';
import 'package:apparence_kit/core/states/models/event_model.dart';
import 'package:apparence_kit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef OnInitErrorBuilder =
    Widget Function(BuildContext context, String error);

class Initializer extends ConsumerStatefulWidget {
  final Widget onReady;
  final Widget onLoading;
  final OnInitErrorBuilder? onError;
  final List<ProviderListenable<OnStartService>> services;

  const Initializer({
    super.key,
    required this.onReady,
    required this.onLoading,
    this.onError,
    this.services = const [],
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InitializerState();
}

class _InitializerState extends ConsumerState<Initializer> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        final onStartHandler = ref.read(onStartProvider.notifier);
        for (final service in widget.services) {
          final serviceInstance = ref.read(service);
          debugPrint('- Initializing service: ${serviceInstance.runtimeType}');
          await serviceInstance.init();
          onStartHandler.register(serviceInstance); // useless now
        }
        onStartHandler.onEnded();
        FlutterNativeSplash.remove();

        final pendingNotificationHandler = ref.read(pendingNotificationHandlerProvider);
        final pendingNotification = await pendingNotificationHandler.fetchNotificationToProcess();
        if (pendingNotification != null) {
          Future.delayed(const Duration(milliseconds: 2000), () {
            pendingNotification.onTap();
          });
        }

        ref.publishAppEvent(OnAppStartEvent.create());
      } catch (e,s) {
        Sentry.captureException(e, stackTrace: s);
        ref.read(onStartProvider.notifier).notifyError(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onStartState = ref.watch(onStartProvider);

    return switch (onStartState) {
      AppLoadingState() => widget.onLoading,
      AppReadyState() => widget.onReady,
      AppErrorState(:final error) => widget.onError?.call(context, error) 
        ?? AppErrorWidget(error: FlutterErrorDetails(exception: error, stack: StackTrace.current)),
    };
  }
}
