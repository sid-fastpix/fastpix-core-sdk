import 'dart:async';
import 'dart:math' show max;
import 'package:synchronized/synchronized.dart';
import 'package:flutter_core_sdk/src/logger/metrics_logger.dart';

class MetricsStateManager {
  static final MetricsStateManager _instance = MetricsStateManager._internal();
  final _lock = Lock();

  factory MetricsStateManager() => _instance;

  MetricsStateManager._internal();

  // Event tracking
  DateTime? _lastPlayTimestamp;
  DateTime? _lastPauseTimestamp;
  DateTime? _lastSeekTimestamp;
  DateTime? _lastBufferStartTimestamp;

  // Metrics state
  int _viewWatchTime = 0;
  int _viewSeekCount = 1;
  int _viewSeekDuration = 0;
  int _viewRebufferCount = 1;
  int _viewRebufferDuration = 0;
  int _viewTotalContentPlaybackTime = 0;
  double _viewMaxUpscalePercentage = 0.0;
  double _viewMaxDownscalePercentage = 0.0;
  double _viewTotalUpscaling = 0.0;
  double _viewTotalDownscaling = 0.0;

  // Event validation
  bool _isPlaying = false;
  bool _isSeeking = false;
  bool _isBuffering = false;

  // Getters for metrics
  int get viewWatchTime => _viewWatchTime;
  int get viewSeekCount => _viewSeekCount;
  int get viewSeekDuration => _viewSeekDuration;
  int get viewRebufferCount => _viewRebufferCount;
  int get viewRebufferDuration => _viewRebufferDuration;
  int get viewTotalContentPlaybackTime => _viewTotalContentPlaybackTime;
  double get viewMaxUpscalePercentage => _viewMaxUpscalePercentage;
  double get viewMaxDownscalePercentage => _viewMaxDownscalePercentage;
  double get viewTotalUpscaling => _viewTotalUpscaling;
  double get viewTotalDownscaling => _viewTotalDownscaling;

  // Additional getters for metrics
  int getVideoContentPlaybackTime() => _viewTotalContentPlaybackTime;
  int getViewTotalContentPlayBackTime() => _viewTotalContentPlaybackTime;
  double getViewTotalDownScaling() => _viewTotalDownscaling;
  double getViewTotalUpScaling() => _viewTotalUpscaling;
  double getViewTotalDownScalePercentage() => _viewMaxDownscalePercentage;
  double getViewTotalUpScalePercentage() => _viewMaxUpscalePercentage;
  int getViewMaxSeekDuration() => _viewSeekDuration;

  // Reset all metrics
  Future<void> reset() async {
    await _lock.synchronized(() {
      _lastPlayTimestamp = null;
      _lastPauseTimestamp = null;
      _lastSeekTimestamp = null;
      _lastBufferStartTimestamp = null;

      _viewWatchTime = 0;
      _viewSeekCount = 0;
      _viewSeekDuration = 0;
      _viewRebufferCount = 0;
      _viewRebufferDuration = 0;
      _viewTotalContentPlaybackTime = 0;
      _viewMaxUpscalePercentage = 0.0;
      _viewMaxDownscalePercentage = 0.0;
      _viewTotalUpscaling = 0.0;
      _viewTotalDownscaling = 0.0;

      _isPlaying = false;
      _isSeeking = false;
      _isBuffering = false;

      MetricsLogger.logEvent('MetricsStateManager',
          {'action': 'reset', 'message': 'All metrics reset'});
    });
  }

  // Play event handling
  Future<void> handlePlay(DateTime timestamp) async {
    await _lock.synchronized(() {
      if (_isPlaying) {
        MetricsLogger.logError('Invalid play event - already playing');
        return;
      }

      _lastPlayTimestamp = timestamp;
      _isPlaying = true;
      MetricsLogger.logEvent('MetricsStateManager',
          {'action': 'play', 'timestamp': timestamp.toIso8601String()});
    });
  }

  // Pause event handling
  Future<void> handlePause(DateTime timestamp) async {
    await _lock.synchronized(() {
      if (!_isPlaying) {
        MetricsLogger.logError('Invalid pause event - not playing');
        return;
      }

      _lastPauseTimestamp = timestamp;
      _isPlaying = false;

      if (_lastPlayTimestamp != null) {
        _viewWatchTime +=
            timestamp.difference(_lastPlayTimestamp!).inMilliseconds;
      }

      MetricsLogger.logEvent('MetricsStateManager', {
        'action': 'pause',
        'timestamp': timestamp.toIso8601String(),
        'watchTime': _viewWatchTime
      });
    });
  }

  // Seek event handling
  Future<void> handleSeeking(DateTime timestamp) async {
    await _lock.synchronized(() {
      if (_isSeeking) {
        MetricsLogger.logError('Invalid seeking event - already seeking');
        return;
      }

      _lastSeekTimestamp = timestamp;
      _isSeeking = true;
      _viewSeekCount++;

      MetricsLogger.logEvent('MetricsStateManager', {
        'action': 'seeking',
        'timestamp': timestamp.toIso8601String(),
        'seekCount': _viewSeekCount
      });
    });
  }

  Future<void> handleSeeked(DateTime timestamp) async {
    await _lock.synchronized(() {
      if (!_isSeeking) {
        MetricsLogger.logError('Invalid seeked event - not seeking');
        return;
      }

      _isSeeking = false;

      if (_lastSeekTimestamp != null) {
        final seekDuration =
            timestamp.difference(_lastSeekTimestamp!).inMilliseconds;
        _viewSeekDuration += seekDuration;
      }

      MetricsLogger.logEvent('MetricsStateManager', {
        'action': 'seeked',
        'timestamp': timestamp.toIso8601String(),
        'seekDuration': _viewSeekDuration
      });
    });
  }

  // Buffer event handling
  Future<void> handleBuffering(DateTime timestamp) async {
    await _lock.synchronized(() {
      if (_isBuffering) {
        MetricsLogger.logError('Invalid buffering event - already buffering');
        return;
      }

      _lastBufferStartTimestamp = timestamp;
      _isBuffering = true;
      _viewRebufferCount++;

      MetricsLogger.logEvent('MetricsStateManager', {
        'action': 'buffering',
        'timestamp': timestamp.toIso8601String(),
        'rebufferCount': _viewRebufferCount
      });
    });
  }

  Future<void> handleBuffered(DateTime timestamp) async {
    await _lock.synchronized(() {
      if (!_isBuffering) {
        MetricsLogger.logError('Invalid buffered event - not buffering');
        return;
      }

      _isBuffering = false;

      if (_lastBufferStartTimestamp != null) {
        final bufferDuration =
            timestamp.difference(_lastBufferStartTimestamp!).inMilliseconds;
        _viewRebufferDuration += bufferDuration;
      }

      MetricsLogger.logEvent('MetricsStateManager', {
        'action': 'buffered',
        'timestamp': timestamp.toIso8601String(),
        'rebufferDuration': _viewRebufferDuration
      });
    });
  }

  // Content playback time handling
  Future<void> updateContentPlaybackTime(
      int currentPosition, int previousPosition) async {
    await _lock.synchronized(() {
      if (currentPosition > previousPosition) {
        _viewTotalContentPlaybackTime += (currentPosition - previousPosition);
        MetricsLogger.logEvent('MetricsStateManager', {
          'action': 'contentPlaybackUpdate',
          'currentPosition': currentPosition,
          'previousPosition': previousPosition,
          'totalPlaybackTime': _viewTotalContentPlaybackTime
        });
      }
    });
  }

  // Scaling metrics handling
  Future<void> updateScalingMetrics({
    required double currentScaleRatio,
    required int timeDiff,
    required int videoSourceWidth,
    required int videoSourceHeight,
    required int playerWidth,
    required int playerHeight,
  }) async {
    await _lock.synchronized(() {
      final maxUpscale = (currentScaleRatio > 1) ? currentScaleRatio - 1 : 0.0;
      final maxDownscale =
          (currentScaleRatio < 1) ? 1.0 - currentScaleRatio : 0.0;

      _viewMaxUpscalePercentage =
          max(_viewMaxUpscalePercentage, maxUpscale).toDouble();
      _viewMaxDownscalePercentage =
          max(_viewMaxDownscalePercentage, maxDownscale).toDouble();

      _viewTotalUpscaling += maxUpscale * timeDiff;
      _viewTotalDownscaling += maxDownscale * timeDiff;

      MetricsLogger.logEvent('MetricsStateManager', {
        'action': 'scalingUpdate',
        'maxUpscale': _viewMaxUpscalePercentage,
        'maxDownscale': _viewMaxDownscalePercentage,
        'totalUpscaling': _viewTotalUpscaling,
        'totalDownscaling': _viewTotalDownscaling
      });
    });
  }

  // Helper method to calculate rebuffer percentage
  double getRebufferPercentage() {
    if (_viewWatchTime == 0) return 0.0;
    return _viewRebufferDuration / _viewWatchTime;
  }

  // Helper method to calculate rebuffer frequency
  double getRebufferFrequency() {
    if (_viewWatchTime == 0) return 0.0;
    return _viewRebufferCount / (_viewWatchTime / 1000); // Convert to seconds
  }
}
