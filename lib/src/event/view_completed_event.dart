import '../services/service_locator.dart';
import 'event_base.dart';

class ViewCompletedEvent extends BaseEvent {
  final String? videoContentPlaybackTime;
  final String? viewTotalContentPlayBackTime;
  final String? viewTotalDownScaling;
  final String? viewTotalUpScaling;
  final String? viewTotalDownScalePercentage;
  final String? viewTotalUpScalePercentage;

  const ViewCompletedEvent({
    super.workSpaceId,
    super.viewId,
    super.viewSequenceNumber,
    super.playerSequenceNumber,
    super.beaconDomain,
    super.playheadTime,
    super.viewerTimeStamp,
    super.playerInstanceId,
    this.videoContentPlaybackTime,
    this.viewTotalContentPlayBackTime,
    this.viewTotalDownScaling,
    this.viewTotalUpScaling,
    this.viewTotalDownScalePercentage,
    this.viewTotalUpScalePercentage,
  });

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'vectpbti': videoContentPlaybackTime,
      'vetlctpbti': viewTotalContentPlayBackTime,
      'vetldg': viewTotalDownScaling,
      'vetlug': viewTotalUpScaling,
      'vemadopg': viewTotalDownScalePercentage,
      'vemauppg': viewTotalUpScalePercentage,
      'evna': 'viewCompleted',
    };
  }

  static Future<ViewCompletedEvent> createViewCompletedEvent({
    required String videoContentPlaybackTime,
    required String viewTotalContentPlayBackTime,
    required String viewTotalDownScaling,
    required String viewTotalUpScaling,
    required String viewTotalDownScalePercentage,
    required String viewTotalUpScalePercentage,
  }) async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);
    return ViewCompletedEvent(
      workSpaceId: baseData['wsid'],
      viewId: baseData['veid'],
      viewSequenceNumber: baseData['vesqnu'],
      playerSequenceNumber: baseData['plsqnu'],
      beaconDomain: baseData['bedn'],
      playheadTime: baseData['plphti'],
      viewerTimeStamp: baseData['vitp'],
      playerInstanceId: baseData['plinid'],
      videoContentPlaybackTime: videoContentPlaybackTime,
      viewTotalContentPlayBackTime: viewTotalContentPlayBackTime,
      viewTotalDownScaling: viewTotalDownScaling,
      viewTotalUpScaling: viewTotalUpScaling,
      viewTotalDownScalePercentage: viewTotalDownScalePercentage,
      viewTotalUpScalePercentage: viewTotalUpScalePercentage,
    );
  }
}
