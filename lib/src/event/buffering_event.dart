import 'package:flutter_core_sdk/src/metrics/metrics_state_manager.dart';

import '../services/service_locator.dart';
import 'event_base.dart';

class BufferingEvent extends BaseEvent {
  const BufferingEvent({
    super.workSpaceId,
    super.viewId,
    super.viewSequenceNumber,
    super.playerSequenceNumber,
    super.beaconDomain,
    super.playheadTime,
    super.viewerTimeStamp,
    super.playerInstanceId,
  });

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'evna': 'buffering',
    };
  }

  static Future<BufferingEvent> createBufferingEvent() async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);
    await MetricsStateManager().handleBuffering(
      DateTime.fromMillisecondsSinceEpoch(configService.currentTimeStamp()),
    );

    return BufferingEvent(
      workSpaceId: baseData['wsid'],
      viewId: baseData['veid'],
      viewSequenceNumber: baseData['vesqnu'],
      playerSequenceNumber: baseData['plsqnu'],
      beaconDomain: baseData['bedn'],
      playheadTime: baseData['plphti'],
      viewerTimeStamp: baseData['vitp'],
      playerInstanceId: baseData['plinid'],
    );
  }
}
