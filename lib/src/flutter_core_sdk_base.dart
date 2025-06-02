
import 'package:logging/logging.dart';

import '../flutter_core_sdk.dart';
import 'event/event_exposer.dart';
import 'metrics/metrics_state_manager.dart';
import 'services/service_locator.dart';
import 'services/configuration/configuration_service.dart';
import 'lifecycle/app_lifecycle_handler.dart';

class FastPixMetrics {
  final MetricsConfiguration? metricsConfiguration;
  final PlayerObserver playerObserver;
  late final EventDispatcher _eventDispatcher;
  final MetricsStateManager _metricsStateManager;
  final ConfigurationService _configService;
  late final AppLifecycleHandler _lifecycleHandler;

  FastPixMetrics._builder(FastPixMetricsBuilder builder)
      : metricsConfiguration = builder._metricsConfiguration,
        playerObserver = builder._playerObserver!,
        _metricsStateManager = MetricsStateManager(),
        _configService = ServiceLocator().configurationService {
    _eventDispatcher =
        EventDispatcher(EventDispatcherConfig(useOverflowQueue: true));
    _lifecycleHandler = AppLifecycleHandler();

    // Initialize configuration
    if (metricsConfiguration != null) {
      if (metricsConfiguration!.workspaceId != null) {
        _configService.updateWorkSpaceId(metricsConfiguration!.workspaceId!);
      }
      if (metricsConfiguration!.viewerId != null) {
        _configService.updateViewerId(metricsConfiguration!.viewerId!);
      }
      if (metricsConfiguration!.beaconUrl != null) {
        _configService.updateBeaconUrl(metricsConfiguration!.beaconUrl!);
      }
      if (metricsConfiguration!.videoData != null) {
        _configService.updateVideoData(metricsConfiguration!.videoData!);
      }
      if (metricsConfiguration!.playerData != null) {
        _configService.updatePlayerData(metricsConfiguration!.playerData!);
      }
      if (metricsConfiguration!.userDefaults != null) {
        _configService.updateUserDefaults(metricsConfiguration!.userDefaults!);
      }
    }
    _configService.updateViewerId(_configService.generateUUID());
    _configService.setPlayerId(_configService.generateUUID());
    _configService.updatePlayerObserver(playerObserver);

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('[${record.level.name}] ${record.loggerName}: ${record.message}');
      if (record.error != null) {
        print('Error: ${record.error}');
      }
    });

    // Reset metrics state when initializing
    _metricsStateManager.reset();
  }

  Future<void> dispatchEvent(PlayerEvent event) async {
    switch (event) {
      case PlayerEvent.play:
        final playEvent = await PlayEvent.createPlayEvent();
        _eventDispatcher.dispatch(playEvent.toJson());
        break;
      case PlayerEvent.pause:
        final pauseEvent = await PauseEvent.createPauseEvent();
        _eventDispatcher.dispatch(pauseEvent.toJson());
        break;
      case PlayerEvent.playing:
        final playingEvent = await PlayingEvent.createPlayingEvent();
        _eventDispatcher.dispatch(playingEvent.toJson());
        break;
      case PlayerEvent.buffering:
        final bufferingEvent = await BufferingEvent.createBufferingEvent();
        _eventDispatcher.dispatch(bufferingEvent.toJson());
        break;
      case PlayerEvent.buffered:
        final bufferedEvent = await BufferedEvent.createBufferedEvent();
        _eventDispatcher.dispatch(bufferedEvent.toJson());
        break;
      case PlayerEvent.seeking:
        final seekingEvent = await SeekingEvent.createSeekingEvent();
        _eventDispatcher.dispatch(seekingEvent.toJson());
        break;
      case PlayerEvent.seeked:
        final viewSeekDuration =
            _metricsStateManager.viewSeekDuration.toString();
        final viewMaxSeekDuration =
            _metricsStateManager.viewSeekDuration.toString();
        final seekedEvent = await SeekedEvent.createSeekedEvent(
          viewSeekDuration: viewSeekDuration,
          viewMaxSeekDuration: viewMaxSeekDuration,
        );
        _eventDispatcher.dispatch(seekedEvent.toJson());
        break;
      case PlayerEvent.viewBegin:
        final viewBeginEvent = await ViewBeginEvent.createViewBeginEvent();
        _eventDispatcher.dispatch(viewBeginEvent.toJson());
        break;
      case PlayerEvent.viewCompleted:
        final videoContentPlaybackTime =
            _metricsStateManager.getVideoContentPlaybackTime().toString();
        final viewTotalContentPlayBackTime =
            _metricsStateManager.getViewTotalContentPlayBackTime().toString();
        final viewTotalDownScaling =
            _metricsStateManager.getViewTotalDownScaling().toString();
        final viewTotalUpScaling =
            _metricsStateManager.getViewTotalUpScaling().toString();
        final viewTotalDownScalePercentage =
            _metricsStateManager.getViewTotalDownScalePercentage().toString();
        final viewTotalUpScalePercentage =
            _metricsStateManager.getViewTotalUpScalePercentage().toString();
        final viewCompletedEvent =
            await ViewCompletedEvent.createViewCompletedEvent(
          videoContentPlaybackTime: videoContentPlaybackTime,
          viewTotalContentPlayBackTime: viewTotalContentPlayBackTime,
          viewTotalDownScaling: viewTotalDownScaling,
          viewTotalUpScaling: viewTotalUpScaling,
          viewTotalDownScalePercentage: viewTotalDownScalePercentage,
          viewTotalUpScalePercentage: viewTotalUpScalePercentage,
        );
        _eventDispatcher.dispatch(viewCompletedEvent.toJson());
        break;
      case PlayerEvent.variantChanged:
        final variantChangedEvent =
            await VariantChangeEvent.createVariantChangeEvent();
        _eventDispatcher.dispatch(variantChangedEvent.toJson());
        break;
      case PlayerEvent.playerReady:
        _configService
            .updateViewPlayTimeStamp(_configService.currentTimeStamp());
        final playerReadyEvent =
            await PlayerReadyEvent.createPlayerReadyEvent();
        _eventDispatcher.dispatch(playerReadyEvent.toJson());
        break;
      case PlayerEvent.error:
        final errorEvent = await ErrorEvent.createErrorEvent();
        _eventDispatcher.dispatch(errorEvent.toJson());
        break;
      case PlayerEvent.pulse:
        final pulseEvent = await PulseEvent.createPulseEvent();
        _eventDispatcher.dispatch(pulseEvent.toJson());
        break;
      case PlayerEvent.requestCompleted:
        final requestCompletedEvent =
            await RequestCompletedEvent.createRequestCompletedEvent(
          requestId: "reqid",
          // dummy or computed value
          requestUrl: "requrl",
          // dummy or computed value
          requestMethod: "reqmet",
          // dummy or computed value
          requestResponseCode: "reqrsc",
          // dummy or computed value
          requestResponseTime: "reqrst",
          // dummy or computed value
          requestResponseSize: "reqrsz",
          // dummy or computed value
          requestResponseHeaders: "reqrsh",
          // dummy or computed value
          requestResponseBody: "reqrsb", // dummy or computed value
        );
        _eventDispatcher.dispatch(requestCompletedEvent.toJson());
        break;
      case PlayerEvent.requestCancelled:
        final requestCancelledEvent =
            await RequestCancelledEvent.createRequestCancelledEvent(
          requestId: "reqid", // dummy or computed value
          requestUrl: "requrl", // dummy or computed value
          requestMethod: "reqmet", // dummy or computed value
        );
        _eventDispatcher.dispatch(requestCancelledEvent.toJson());
        break;
      case PlayerEvent.requestFailed:
        final requestFailedEvent =
            await RequestFailedEvent.createRequestFailedEvent(
          requestId: "reqid", // dummy or computed value
          requestUrl: "requrl", // dummy or computed value
          requestMethod: "reqmet", // dummy or computed value
          requestError: "reqerr", // dummy or computed value
        );
        _eventDispatcher.dispatch(requestFailedEvent.toJson());
        break;
    }
  }

  void dispose() {
    _eventDispatcher.dispose();
    _metricsStateManager.reset();
    _lifecycleHandler.dispose();
  }
}

class FastPixMetricsBuilder {
  MetricsConfiguration? _metricsConfiguration;
  PlayerObserver? _playerObserver;

  FastPixMetricsBuilder setMetricsConfiguration(
      MetricsConfiguration metricsConfiguration) {
    _metricsConfiguration = metricsConfiguration;
    return this;
  }

  FastPixMetricsBuilder setPlayerObserver(PlayerObserver playerObserver) {
    _playerObserver = playerObserver;
    return this;
  }

  FastPixMetrics build() {
    if (_metricsConfiguration == null) {
      throw Exception("MetricsConfiguration is required");
    }
    if (_playerObserver == null) {
      throw Exception("PlayerObserver is required");
    }
    return FastPixMetrics._builder(this);
  }
}
