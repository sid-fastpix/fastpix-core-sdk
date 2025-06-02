import '../services/service_locator.dart';
import 'event_base.dart';

class ErrorEvent extends BaseEvent {
  const ErrorEvent({
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
      'evna': 'error',
    };
  }

  static Future<ErrorEvent> createErrorEvent() async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);

    return ErrorEvent(
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
