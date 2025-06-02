import 'package:flutter_core_sdk/src/metrics/metrics_state_manager.dart';

import '../services/service_locator.dart';
import 'event_base.dart';

class SeekedEvent extends BaseEvent {
  final String? viewSeekDuration;
  final String? viewMaxSeekDuration;

  const SeekedEvent({
    super.workSpaceId,
    super.viewId,
    super.viewSequenceNumber,
    super.playerSequenceNumber,
    super.beaconDomain,
    super.playheadTime,
    super.viewerTimeStamp,
    super.playerInstanceId,
    this.viewSeekDuration,
    this.viewMaxSeekDuration,
  });

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'vesedu': viewSeekDuration,
      'vemaseti': viewMaxSeekDuration,
      'evna': 'seeked',
    };
  }

  static Future<SeekedEvent> createSeekedEvent({
    required String viewSeekDuration,
    required String viewMaxSeekDuration,
  }) async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);
    await MetricsStateManager().handleSeeked(
      DateTime.fromMillisecondsSinceEpoch(configService.currentTimeStamp()),
    );

    return SeekedEvent(
      workSpaceId: baseData['wsid'],
      viewId: baseData['veid'],
      viewSequenceNumber: baseData['vesqnu'],
      playerSequenceNumber: baseData['plsqnu'],
      beaconDomain: baseData['bedn'],
      playheadTime: baseData['plphti'],
      viewerTimeStamp: baseData['vitp'],
      playerInstanceId: baseData['plinid'],
      viewSeekDuration: viewSeekDuration,
      viewMaxSeekDuration: viewMaxSeekDuration,
    );
  }
}
