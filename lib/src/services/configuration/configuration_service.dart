import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_core_sdk/flutter_core_sdk.dart';
import 'package:uuid/uuid.dart';
import 'configuration_state.dart';

class ConfigurationService extends ChangeNotifier {
  ConfigurationState _state = const ConfigurationState();
  final _uuid = Uuid();

  ConfigurationState get state => _state;

  // Getters for commonly accessed values
  PlayerData? get playerData => _state.playerData;

  VideoData? get videoData => _state.videoData;

  String? get viewerId => _state.viewerId;

  String? get playerId => _state.playerId;

  UserDefaults? get userDefaults => _state.userDefaults;

  PlayerObserver? get playerObserver => _state.playerObserver;

  String? get workSpaceId => _state.workSpaceId;

  String? get beaconUrl => _state.beaconUrl;

  String? get baseURL => _state.baseURL;

  String? get viewId => _state.viewId;

  // Update methods
  void updatePlayerData(PlayerData data) {
    _state = _state.copyWith(playerData: data);
    notifyListeners();
  }

  void updateVideoData(VideoData data) {
    _state = _state.copyWith(videoData: data);
    notifyListeners();
  }

  void updateViewerId(String id) {
    _state = _state.copyWith(viewId: id);
    notifyListeners();
  }

  void updateUserDefaults(UserDefaults defaults) {
    _state = _state.copyWith(userDefaults: defaults);
    notifyListeners();
  }

  void updatePlayerObserver(PlayerObserver observer) {
    _state = _state.copyWith(playerObserver: observer);
    notifyListeners();
  }

  void setPlayerId(String id) {
    _state = _state.copyWith(playerId: id);
    notifyListeners();
  }

  void updateWorkSpaceId(String id) {
    _state = _state.copyWith(workSpaceId: id);
    _updateBaseURL();
    notifyListeners();
  }

  void updateBeaconUrl(String url) {
    _state = _state.copyWith(beaconUrl: url);
    _updateBaseURL();
    notifyListeners();
  }

  void _updateBaseURL() {
    if (_state.workSpaceId != null && _state.beaconUrl != null) {
      _state = _state.copyWith(
        baseURL: 'https://${_state.workSpaceId}.${_state.beaconUrl}',
      );
    }
  }

  // Timestamp methods
  void updateViewPlayTimeStamp(int timestamp) {
    _state = _state.copyWith(viewPlayTimeStamp: timestamp);
    notifyListeners();
  }

  void updateViewPauseTimeStamp(int timestamp) {
    _state = _state.copyWith(viewPauseTimeStamp: timestamp);
    notifyListeners();
  }

  void updateIsViewTimeToFirstFrameSent(bool isViewTimeToFirstFrameSent) {
    _state = _state.copyWith(isViewTimeToFirstFrameSent: isViewTimeToFirstFrameSent);
    notifyListeners();
  }

  void updateViewerTimeStamp(int timestamp) {
    _state = _state.copyWith(viewerTimeStamp: timestamp);
    notifyListeners();
  }

  // Counter methods
  String incrementSequenceCounter() {
    final newCounter = _state.sequenceCounter + 1;
    _state = _state.copyWith(sequenceCounter: newCounter);
    notifyListeners();
    return newCounter.toString();
  }

  String incrementSeekCount() {
    final newCount = _state.viewSeekCount + 1;
    _state = _state.copyWith(viewSeekCount: newCount);
    notifyListeners();
    return newCount.toString();
  }

  String incrementRebufferCount() {
    final newCount = _state.viewRebufferCount + 1;
    _state = _state.copyWith(viewRebufferCount: newCount);
    notifyListeners();
    return newCount.toString();
  }

  // Utility methods
  int currentTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  String generateUUID() {
    return _uuid.v4();
  }

  String generateRandomIdOf24Characters() {
    const chars = '0123456789abcdef';
    final rand = Random.secure();
    return List.generate(24, (_) => chars[rand.nextInt(16)]).join();
  }

  // Metrics update methods
  void updateBufferStartedTimeStamp(int timestamp) {
    _state = _state.copyWith(bufferStartedTimeStamp: timestamp);
    notifyListeners();
  }

  void updateLastPlayHeadTime(int time) {
    _state = _state.copyWith(lastPlayHeadTime: time);
    notifyListeners();
  }

  void updateViewTotalContentPlayBackTime(int time) {
    _state = _state.copyWith(viewTotalContentPlayBackTime: time);
    notifyListeners();
  }

  void updateViewRebufferDuration(int time) {
    _state = _state.copyWith(viewReBufferDuration: time.toString());
    notifyListeners();
  }

  void updateViewTotalDownScaling(int scaling) {
    _state = _state.copyWith(viewTotalDownScaling: scaling);
    notifyListeners();
  }

  void updateViewTotalUpScaling(int scaling) {
    _state = _state.copyWith(viewTotalUpScaling: scaling);
    notifyListeners();
  }

  void updateViewMaxDownScalePercentage(int percentage) {
    _state = _state.copyWith(viewMaxDownScalePercentage: percentage);
    notifyListeners();
  }

  void updateViewMaxUpScalePercentage(int percentage) {
    _state = _state.copyWith(viewMaxUpScalePercentage: percentage);
    notifyListeners();
  }

  void updateSeekMap(Map<String, int> newSeekMap) {
    _state = _state.copyWith(seekMap: newSeekMap);
    notifyListeners();
  }

  // Reset method
  void reset() {
    _state = const ConfigurationState();
    notifyListeners();
  }

  void generateViewId(String viewId) {
    _state = _state.copyWith(viewId: viewId);
    notifyListeners();
  }

  Future<void> calculateViewScaling() async {
    final playHeadTime = await _state.playerObserver?.playerPlayHeadTime();
    final timeDiff = (playHeadTime ?? 0) - _state.lastPlayHeadTime;
    final a = min(
        (_state.playerObserver!.playerHeight() /
            _state.playerObserver!.videoSourceHeight()),
        (_state.playerObserver!.playerWidth() /
            _state.playerObserver!.videoSourceWidth()));
    final maxUpScale = max(0, a - 1);
    final maxDownScale = max(0, 1 - a);
    updateViewTotalDownScaling(maxDownScale.round() * timeDiff);
    updateViewTotalUpScaling(maxUpScale.round() * timeDiff);
    updateViewMaxUpScalePercentage(maxUpScale.round());
    updateViewMaxDownScalePercentage(maxDownScale.round());
  }
}
