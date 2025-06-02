import '../services/service_locator.dart';
import 'event_base.dart';

class VariantChangeEvent extends BaseEvent {
  final String? videoSourceWidth;
  final String? videoSourceHeight;
  final String? videoId;

  const VariantChangeEvent(
      {super.workSpaceId,
      super.viewId,
      super.viewSequenceNumber,
      super.playerSequenceNumber,
      super.beaconDomain,
      super.playheadTime,
      super.viewerTimeStamp,
      super.playerInstanceId,
      this.videoSourceWidth,
      this.videoSourceHeight,
      this.videoId});

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'vdsowt': videoSourceWidth,
      'vdsoht': videoSourceHeight,
      'vdid': videoId,
      'evna': 'variantChanged',
    };
  }

  static Future<VariantChangeEvent> createVariantChangeEvent() async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);
    final playerObserver = configService.playerObserver;
    final videoId = configService.videoData?.videoId;
    return VariantChangeEvent(
        workSpaceId: baseData['wsid'],
        viewId: baseData['veid'],
        viewSequenceNumber: baseData['vesqnu'],
        playerSequenceNumber: baseData['plsqnu'],
        beaconDomain: baseData['bedn'],
        playheadTime: baseData['plphti'],
        viewerTimeStamp: baseData['vitp'],
        playerInstanceId: baseData['plinid'],
        videoSourceWidth: playerObserver?.videoSourceWidth().round().toString(),
        videoSourceHeight: playerObserver?.videoSourceHeight().round().toString(),
        videoId: videoId);
  }
}
