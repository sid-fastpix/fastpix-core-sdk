
import '../metrics/metrics_state_manager.dart';
import '../services/service_locator.dart';
import '../util/device_info_helper.dart';
import 'event_base.dart';

class PlayEvent extends BaseEvent {
  final String? videoId;
  final String? viewRebufferCount;
  final String? viewRebufferDuration;
  final String? mimeType;
  final String? fastPixApiVersion;
  final String? videoCodec;
  final String? hostName;
  final String? deviceName;
  final String? deviceCategory;
  final String? deviceManufacturer;
  final String? deviceModel;
  final String? viewBufferFrequency;

  const PlayEvent(
      {super.workSpaceId,
      super.viewId,
      super.viewSequenceNumber,
      super.playerSequenceNumber,
      super.beaconDomain,
      super.playheadTime,
      super.viewerTimeStamp,
      super.playerInstanceId,
      this.videoId,
      this.viewRebufferCount,
      this.viewRebufferDuration,
      this.mimeType,
      this.fastPixApiVersion,
      this.videoCodec,
      this.hostName,
      this.deviceName,
      this.deviceCategory,
      this.deviceManufacturer,
      this.deviceModel,
      this.viewBufferFrequency});

  @override
  Map<String, String?> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'evna': 'play',
      'vdid': videoId,
      'verbco': viewRebufferCount,
      'verbdu': viewRebufferDuration,
      'vdsomity': mimeType,
      'fpaivn': fastPixApiVersion,
      'vdsocc': videoCodec,
      'vdsohn': hostName,
      'dena': deviceName,
      'decg': deviceCategory,
      'demr': deviceManufacturer,
      'demo': deviceModel,
      'verbfq': viewBufferFrequency,
    };
  }

  static Future<PlayEvent> createPlayEvent() async {
    final configService = ServiceLocator().configurationService;
    final metricsManager = MetricsStateManager();
    final baseData = await BaseEvent.getBaseEventData(configService);
    final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
    final videoData = configService.videoData;
    // Update metrics state
    await metricsManager.handlePlay(
      DateTime.fromMillisecondsSinceEpoch(configService.currentTimeStamp()),
    );

    return PlayEvent(
      workSpaceId: baseData['wsid'],
      viewId: baseData['veid'],
      viewSequenceNumber: baseData['vesqnu'],
      playerSequenceNumber: baseData['plsqnu'],
      beaconDomain: baseData['bedn'],
      playheadTime: baseData['plphti'],
      viewerTimeStamp: baseData['vitp'],
      playerInstanceId: baseData['plinid'],
      videoId: videoData?.videoId,
      viewRebufferCount: metricsManager.viewRebufferCount.toString(),
      viewRebufferDuration: metricsManager.viewRebufferDuration.toString(),
      mimeType: "",
      fastPixApiVersion: "1.0",
      videoCodec: "",
      hostName: "",
      deviceName: deviceInfo['deviceName'],
      deviceModel: deviceInfo['deviceModel'],
      deviceCategory: '',
      deviceManufacturer: deviceInfo['deviceManufacturer'],
    );
  }
}
