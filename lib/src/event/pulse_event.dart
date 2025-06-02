import '../services/service_locator.dart';
import 'event_base.dart';

class PulseEvent extends BaseEvent {
  final String? viewMaxUpScalePercentage;
  final String? viewMaxDownScalePercentage;
  final String? viewTotalUpScaling;
  final String? viewTotalDownScaling;

  const PulseEvent({
    super.workSpaceId,
    super.viewId,
    super.viewSequenceNumber,
    super.playerSequenceNumber,
    super.beaconDomain,
    super.playheadTime,
    super.viewerTimeStamp,
    super.playerInstanceId,
    this.viewMaxUpScalePercentage,
    this.viewMaxDownScalePercentage,
    this.viewTotalUpScaling,
    this.viewTotalDownScaling,
  });

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'vemauppg': viewMaxUpScalePercentage,
      'vemadopg': viewMaxDownScalePercentage,
      'vetlug': viewTotalUpScaling,
      'vetldg': viewTotalDownScaling,
      'evna': 'pulse',
    };
  }

  static Future<PulseEvent> createPulseEvent() async {
    final configService = ServiceLocator().configurationService;
    final baseData = await BaseEvent.getBaseEventData(configService);
    await configService.calculateViewScaling();
    final viewMaxUpScalePercentage =
        configService.state.viewMaxUpScalePercentage;
    final viewMaxDownScalePercentage =
        configService.state.viewMaxDownScalePercentage;
    final viewTotalUpScaling = configService.state.viewTotalUpScaling;
    final viewTotalDownScaling = configService.state.viewTotalDownScaling;

    return PulseEvent(
      workSpaceId: baseData['wsid'],
      viewId: baseData['veid'],
      viewSequenceNumber: baseData['vesqnu'],
      playerSequenceNumber: baseData['plsqnu'],
      beaconDomain: baseData['bedn'],
      playheadTime: baseData['plphti'],
      viewerTimeStamp: baseData['vitp'],
      playerInstanceId: baseData['plinid'],
      viewMaxUpScalePercentage: viewMaxUpScalePercentage.toString(),
      viewMaxDownScalePercentage: viewMaxDownScalePercentage.toString(),
      viewTotalUpScaling: viewTotalUpScaling.toString(),
      viewTotalDownScaling: viewTotalDownScaling.toString(),
    );
  }
}
