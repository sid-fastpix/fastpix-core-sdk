import '../services/configuration/configuration_service.dart';

abstract class BaseEvent {
  final String? workSpaceId;
  final String? viewId;
  final String? viewSequenceNumber;
  final String? playerSequenceNumber;
  final String? beaconDomain;
  final String? playheadTime;
  final String? viewerTimeStamp;
  final String? playerInstanceId;

  const BaseEvent({
    this.workSpaceId,
    this.viewId,
    this.viewSequenceNumber,
    this.playerSequenceNumber,
    this.beaconDomain,
    this.playheadTime,
    this.viewerTimeStamp,
    this.playerInstanceId,
  });

  Map<String, String?> toJson() {
    return {
      'wsid': workSpaceId,
      'veid': viewId,
      'vesqnu': viewSequenceNumber,
      'plsqnu': playerSequenceNumber,
      'bedn': beaconDomain,
      'plphti': playheadTime,
      'vitp': viewerTimeStamp,
      'plinid': playerInstanceId,
    };
  }

  static Future<Map<String, String?>> getBaseEventData(
      ConfigurationService configService) async {
    final viewId = configService.state.viewId;
    final currentTimeStamp = configService.currentTimeStamp();
    final playerObserver = configService.playerObserver;
    final sequenceNumber = configService.incrementSequenceCounter();
    final workSpaceId = configService.workSpaceId;
    final beaconDomain = configService.beaconUrl;
    final playerId = configService.playerId;
    final playHeadTime = await playerObserver?.playerPlayHeadTime();

    return {
      'wsid': workSpaceId,
      'veid': viewId,
      'vesqnu': sequenceNumber,
      'plsqnu': sequenceNumber,
      'bedn': beaconDomain,
      'plphti': playHeadTime?.toString(),
      'vitp': currentTimeStamp.toString(),
      'plinid': playerId,
    };
  }
}
