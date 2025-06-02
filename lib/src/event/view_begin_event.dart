import '../services/service_locator.dart';
import 'event_base.dart';

class ViewBeginEvent extends BaseEvent {
  final String? viewBegin;
  final String? videoSourceUrl;
  final String? sessionId;
  final String? sessionStart;
  final String? sessionExpires;
  final String? fpViewerId;
  final String? videoTitle;
  final String? videoId;
  final String? playerName;
  final String? playerWidth;
  final String? playerHeight;
  final String? playerVersion;
  final String? videoWidth;
  final String? videoHeight;

  const ViewBeginEvent(
      {super.workSpaceId,
      super.viewId,
      super.viewSequenceNumber,
      super.playerSequenceNumber,
      super.beaconDomain,
      super.playheadTime,
      super.viewerTimeStamp,
      super.playerInstanceId,
      this.viewBegin,
      this.sessionId,
      this.sessionStart,
      this.videoSourceUrl,
      this.sessionExpires,
      this.fpViewerId,
      this.videoTitle,
      this.videoId,
      this.playerName,
      this.playerVersion,
      this.playerWidth,
      this.playerHeight,
      this.videoWidth,
      this.videoHeight});

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'vest': viewBegin,
      'snid': sessionId,
      'snst': sessionStart,
      'snepti': sessionExpires,
      'vdsour': videoSourceUrl,
      'fpviid': fpViewerId,
      'vdtt': videoTitle,
      'vdid': videoId,
      'plna': playerName,
      'plvn': playerVersion,
      'plwt': playerWidth,
      'plht': playerHeight,
      'rqvdwt': videoWidth,
      'rqvdht': videoHeight,
      'evna': 'viewBegin',
    };
  }

  static Future<ViewBeginEvent> createViewBeginEvent() async {
    final configService = ServiceLocator().configurationService;
    final sessionService = ServiceLocator().sessionService;
    configService.updateViewerTimeStamp(configService.currentTimeStamp());
    final baseData = await BaseEvent.getBaseEventData(configService);
    final videoData = configService.videoData;
    final playerObserver = configService.playerObserver;
    // Initialize session if not already initialized
    if (!sessionService.isSessionValid) {
      sessionService.initializeSession();
    }

    return ViewBeginEvent(
        workSpaceId: baseData['wsid'],
        viewId: baseData['veid'],
        viewSequenceNumber: baseData['vesqnu'],
        playerSequenceNumber: baseData['plsqnu'],
        beaconDomain: baseData['bedn'],
        playheadTime: baseData['plphti'],
        viewerTimeStamp: baseData['vitp'],
        playerInstanceId: baseData['plinid'],
        viewBegin: configService.currentTimeStamp().toString(),
        sessionId: sessionService.sessionId,
        sessionStart: sessionService.sessionStartTime?.toString(),
        sessionExpires: sessionService.sessionExpiryTime?.toString(),
        videoSourceUrl: videoData?.videoUrl,
        fpViewerId: configService.generateUUID(),
        videoTitle: videoData?.videoTitle,
        videoId: videoData?.videoId,
        playerName: configService.playerData?.playerName,
        playerVersion: configService.playerData?.playerVersion,
        playerWidth:
            configService.playerObserver?.playerWidth().round().toString(),
        playerHeight:
            configService.playerObserver?.playerHeight().round().toString(),
        videoHeight: playerObserver?.videoSourceHeight().round().toString(),
        videoWidth: playerObserver?.videoSourceWidth().round().toString());
  }
}
