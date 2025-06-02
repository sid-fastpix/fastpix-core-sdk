
import '../../flutter_core_sdk.dart';

class MetricsConfiguration {
  final String? viewerId;
  final PlayerData? playerData;
  final UserDefaults? userDefaults;
  final String? workspaceId;
  final String? beaconUrl;
  final VideoData? videoData;
  final bool enableLogging;
  final List<CustomData>? customData;

  MetricsConfiguration._builder(MetricsBuilder builder)
      : playerData = builder._playerData,
        userDefaults = builder._userDefaults,
        workspaceId = builder._workspaceId,
        beaconUrl = builder._beaconUrl,
        videoData = builder._videoData,
        enableLogging = builder._enableLogging,
        customData = builder._customData,
        viewerId = builder._viewerId;

  MetricsConfiguration(
      {this.playerData,
      this.userDefaults,
      required this.viewerId,
      required this.workspaceId,
      required this.beaconUrl,
      this.videoData,
      this.enableLogging = false,
      this.customData});
}

class MetricsBuilder {
  PlayerData? _playerData;
  UserDefaults? _userDefaults;
  String? _workspaceId;
  String? _beaconUrl;
  String? _viewerId;
  VideoData? _videoData;
  bool _enableLogging = false;
  List<CustomData>? _customData;

  MetricsBuilder setPlayerData(PlayerData playerData) {
    _playerData = playerData;
    return this;
  }

  MetricsBuilder setCustomData(List<CustomData> customData) {
    _customData = customData;
    return this;
  }

  MetricsBuilder setViewerId(String viewerId) {
    _viewerId = viewerId;
    return this;
  }

  MetricsBuilder isEnableLogging(bool enableLogging) {
    _enableLogging = enableLogging;
    return this;
  }

  MetricsBuilder setWorkSpaceId(String workSpaceId) {
    _workspaceId = workSpaceId;
    return this;
  }

  MetricsBuilder setVideoData(VideoData videoData) {
    _videoData = videoData;
    return this;
  }

  MetricsBuilder setBeaconUrl(String beaconUrl) {
    _beaconUrl = beaconUrl;
    return this;
  }

  MetricsBuilder setUserDefaults(UserDefaults userDefaults) {
    _userDefaults = userDefaults;
    return this;
  }

  MetricsConfiguration build() {
    if (_workspaceId == null) {
      throw Exception("WorkspaceId is required");
    }
    if (_beaconUrl == null) {
      throw Exception("BeaconUrl is required");
    }
    if (_viewerId == null) {
      throw Exception("ViewerId is required");
    }
    return MetricsConfiguration._builder(this);
  }
}
