import '../services/service_locator.dart';
import 'event_base.dart';

class PlayingEvent extends BaseEvent {
  final String? videoStartTime;

  const PlayingEvent(
      {super.workSpaceId,
      super.viewId,
      super.viewSequenceNumber,
      super.playerSequenceNumber,
      super.beaconDomain,
      super.playheadTime,
      super.viewerTimeStamp,
      super.playerInstanceId,
      this.videoStartTime});

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'vetitofifr': videoStartTime,
      'evna': 'playing',
    };
  }

  static Future<PlayingEvent> createPlayingEvent() async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);
    var isViewTimeToFirstFrame = 0;
    if (!configService.state.isViewTimeToFirstFrameSent) {
      configService.updateIsViewTimeToFirstFrameSent(true);
      isViewTimeToFirstFrame = configService.currentTimeStamp() -
          configService.state.viewerTimeStamp!;
    }

    return PlayingEvent(
        workSpaceId: baseData['wsid'],
        viewId: baseData['veid'],
        viewSequenceNumber: baseData['vesqnu'],
        playerSequenceNumber: baseData['plsqnu'],
        beaconDomain: baseData['bedn'],
        playheadTime: baseData['plphti'],
        viewerTimeStamp: baseData['vitp'],
        playerInstanceId: baseData['plinid'],
        videoStartTime: isViewTimeToFirstFrame.toString());
  }
}
