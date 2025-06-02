import 'package:flutter_core_sdk/src/metrics/metrics_state_manager.dart';

import '../services/service_locator.dart';
import 'event_base.dart';

class SeekingEvent extends BaseEvent {
  final String? viewSeekCount;

  const SeekingEvent(
      {super.workSpaceId,
      super.viewId,
      super.viewSequenceNumber,
      super.playerSequenceNumber,
      super.beaconDomain,
      super.playheadTime,
      super.viewerTimeStamp,
      super.playerInstanceId,
      this.viewSeekCount});

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'veseco': viewSeekCount,
      'evna': 'seeking',
    };
  }

  static Future<SeekingEvent> createSeekingEvent() async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);
    final metricsManager = MetricsStateManager();

    // Update metrics state
    await metricsManager.handleSeeking(
      DateTime.fromMillisecondsSinceEpoch(configService.currentTimeStamp()),
    );

    return SeekingEvent(
        workSpaceId: baseData['wsid'],
        viewId: baseData['veid'],
        viewSequenceNumber: baseData['vesqnu'],
        playerSequenceNumber: baseData['plsqnu'],
        beaconDomain: baseData['bedn'],
        playheadTime: baseData['plphti'],
        viewerTimeStamp: baseData['vitp'],
        playerInstanceId: baseData['plinid'],
        viewSeekCount: metricsManager.viewSeekCount.toString());
  }
}
