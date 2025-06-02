import 'package:flutter_core_sdk/flutter_core_sdk.dart';
import 'dart:math';

import 'package:uuid/uuid.dart';

class ConfigurationHelper {
  ConfigurationHelper._internal();

  static final ConfigurationHelper _instance = ConfigurationHelper._internal();

  factory ConfigurationHelper() => _instance;

  PlayerData? _playerData;
  VideoData? _videoData;
  String? _viewerId;
  UserDefaults? _userDefaults;
  PlayerObserver? _playerObserver;
  String? _workSpaceId;
  int sequenceCounter = 0;
  int? _viewerTimeStamp;
  int _viewSeekCount = 0;
  String? _beaconUrl;
  String? _baseURL;

  int? _viewPlayTimeStamp;
  int? _viewPauseTimeStamp;

  int? get viewPlayTimeStamp => _viewPlayTimeStamp;

  set viewPlayTimeStamp(int? value) {
    _viewPlayTimeStamp = value;
  }

  int? get viewerTimeStamp => _viewerTimeStamp;

  set viewerTimeStamp(int? value) {
    _viewerTimeStamp = value;
  }

  String? get viewerId => _viewerId;

  set viewerId(String? value) {
    _viewerId = value;
  }

  UserDefaults? get userDefaults => _userDefaults;

  set userDefaults(UserDefaults? value) {
    _userDefaults = value;
  }

  String incrementCount() {
    sequenceCounter++;
    return sequenceCounter.toString();
  }

  String incrementSeekCount() {
    _viewSeekCount++;
    return _viewSeekCount.toString();
  }

  int currentTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static ConfigurationHelper get instance => _instance;

  void buildBaseURL() {
    _baseURL = 'https://$_workSpaceId.$_beaconUrl';
  }

  String buildAv4() {
    final uuId = Uuid();
    return uuId.v4();
  }

  String buildRandomIdOf24Characters() {
    const chars = '0123456789abcdef';
    final rand = Random.secure();
    return List.generate(24, (_) => chars[rand.nextInt(16)]).join();
  }

  PlayerData? get playerData => _playerData;

  set playerData(PlayerData? value) {
    _playerData = value;
  }

  VideoData? get videoData => _videoData;

  set videoData(VideoData? value) {
    _videoData = value;
  }

  PlayerObserver? get playerObserver => _playerObserver;

  set playerObserver(PlayerObserver? value) {
    _playerObserver = value;
  }

  String? get workSpaceId => _workSpaceId;

  set workSpaceId(String? value) {
    _workSpaceId = value;
  }

  String? get beaconUrl => _beaconUrl;

  set beaconUrl(String? value) {
    _beaconUrl = value;
  }

  String? get baseURL => _baseURL;

  set baseURL(String? value) {
    _baseURL = value;
  }

  int? get viewPauseTimeStamp => _viewPauseTimeStamp;

  set viewPauseTimeStamp(int? value) {
    _viewPauseTimeStamp = value;
  }

  int _viewSeekTimeStamp = 0;
  int _viewSeekingTimeStamp = 0;

  int get viewSeekTimeStamp => _viewSeekTimeStamp;

  set viewSeekTimeStamp(int value) {
    _viewSeekTimeStamp = value;
  }

  int get viewSeekingTimeStamp => _viewSeekingTimeStamp;

  set viewSeekingTimeStamp(int value) {
    _viewSeekingTimeStamp = value;
  }

  int? _viewerSeekDuration;

  int? get viewerSeekDuration => _viewerSeekDuration;

  set viewerSeekDuration(int? value) {
    _viewerSeekDuration = value;
  }

  final Map<String, int> seekMap = {};
  int _viewReBufferCount = 0;

  int incrementViewReBufferCount() {
    _viewReBufferCount++;
    return _viewReBufferCount;
  }

  int _bufferStartedTimeStamp = 0;

  int get bufferStartedTimeStamp => _bufferStartedTimeStamp;

  set bufferStartedTimeStamp(int value) {
    _bufferStartedTimeStamp = value;
  }

  int _lastPlayHeadTime = 0;

  int get lastPlayHeadTime => _lastPlayHeadTime;

  set lastPlayHeadTime(int value) {
    _lastPlayHeadTime = value;
  }

  int _viewTotalContentPlayBackTime = 0;

  int get viewTotalContentPlayBackTime => _viewTotalContentPlayBackTime;

  set viewTotalContentPlayBackTime(int value) {
    _viewTotalContentPlayBackTime = value;
  }

  int _viewTotalDownScaling = 0;
  int _viewTotalUpScaling = 0;
  int _viewMaxUpScalePercentage = 0;
  int _viewMaxDownScalePercentage = 0;

  int? get viewTotalDownScaling => _viewTotalDownScaling;

  void calculateViewTotalDownscaling() async {
    final playHeadTime = await _playerObserver?.playerPlayHeadTime();
    final timeDiff = (playHeadTime ?? 0) - _lastPlayHeadTime;
    final a = min(
        (playerObserver!.playerHeight() / playerObserver!.videoSourceHeight()),
        (playerObserver!.playerWidth() / playerObserver!.videoSourceWidth()));
    final maxUpScale = max(0, a - 1);
    final maxDownScale = max(0, 1 - a);
    _viewTotalDownScaling = maxDownScale.round() * timeDiff;
    _viewTotalUpScaling = maxUpScale.round() * timeDiff;
    _viewMaxUpScalePercentage = maxUpScale.round();
    _viewMaxDownScalePercentage = maxDownScale.round();
  }

  int get viewTotalUpScaling => _viewTotalUpScaling;

  int get viewMaxUpScalePercentage => _viewMaxUpScalePercentage;

  int get viewMaxDownScalePercentage => _viewMaxDownScalePercentage;

  int _viewWatchTime = 0;

  int get viewWatchTime => _viewWatchTime;

  set viewWatchTime(int value) {
    _viewWatchTime = value;
  }

  int _playInitTime = 0;

  int get playInitTime => _playInitTime;

  set playInitTime(int value) {
    _playInitTime = value;
  }
}
