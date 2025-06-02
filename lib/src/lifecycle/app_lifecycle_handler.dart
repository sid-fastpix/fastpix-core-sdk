import 'package:flutter/widgets.dart';
import 'package:flutter_core_sdk/flutter_core_sdk.dart';
import '../services/service_locator.dart';
import '../event/view_completed_event.dart';
import '../dispatcher/event_dispatcher.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  static final AppLifecycleHandler _instance = AppLifecycleHandler._internal();
  final EventDispatcher _eventDispatcher = EventDispatcher(null);

  factory AppLifecycleHandler() {
    return _instance;
  }

  AppLifecycleHandler._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      try {
        // Create and dispatch view completed event
        final viewCompletedEvent =
            await ViewCompletedEvent.createViewCompletedEvent(
          videoContentPlaybackTime: ServiceLocator()
              .configurationService
              .state
              .viewTotalContentPlayBackTime
              .toString(),
          viewTotalContentPlayBackTime: ServiceLocator()
              .configurationService
              .state
              .viewTotalContentPlayBackTime
              .toString(),
          viewTotalDownScaling: ServiceLocator()
              .configurationService
              .state
              .viewTotalDownScaling
              .toString(),
          viewTotalUpScaling: ServiceLocator()
              .configurationService
              .state
              .viewTotalUpScaling
              .toString(),
          viewTotalDownScalePercentage: ServiceLocator()
              .configurationService
              .state
              .viewMaxDownScalePercentage
              .toString(),
          viewTotalUpScalePercentage: ServiceLocator()
              .configurationService
              .state
              .viewMaxUpScalePercentage
              .toString(),
        );

        // Force immediate dispatch of the event
        _eventDispatcher.dispatch(viewCompletedEvent.toJson());
        await _eventDispatcher
            .flush(); // Ensure the event is sent before app closes
      } catch (e) {
        // Log error but don't throw since this is during app termination
        print('Error sending view completed event during app termination: $e');
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
