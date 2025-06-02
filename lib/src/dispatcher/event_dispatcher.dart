import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter_core_sdk/flutter_core_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_core_sdk/src/logger/metrics_logger.dart';
import 'package:flutter_core_sdk/src/services/service_locator.dart';
import 'package:flutter_core_sdk/src/services/configuration/configuration_service.dart';
import 'package:flutter_core_sdk/src/services/session/session_service.dart';
import 'package:flutter_core_sdk/src/event/pulse_event.dart';

class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException(this.message);

  @override
  String toString() => 'SessionExpiredException: $message';
}

class EventDispatcherConfig {
  Duration batchInterval;
  int maxBatchSize;
  int maxQueueSize;
  int maxRetries;
  final Duration retryDelay;
  bool useOverflowQueue; // New configuration option

  EventDispatcherConfig({
    this.batchInterval = const Duration(seconds: 10),
    this.maxBatchSize = 200,
    this.maxQueueSize = 1000,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.useOverflowQueue = true, // Default to using overflow queue
  });
}

class EventDispatcher {
  static final EventDispatcher _instance = EventDispatcher._internal();
  final EventDispatcherConfig config;
  final ConfigurationService _configService;
  final SessionService _sessionService;

  // Add fields for deduplication and pulse event scheduling
  Map<String, String?>? _lastSentEvent;
  Timer? _pulseTimer;
  static const Duration _pulseInterval = Duration(seconds: 10);
  bool _isPulseEventScheduled = false;

  factory EventDispatcher(EventDispatcherConfig? config) {
    if (config != null) {
      _instance.updateConfig(config);
    }
    return _instance;
  }

  EventDispatcher._internal()
      : config = EventDispatcherConfig(),
        _configService = ServiceLocator().configurationService,
        _sessionService = ServiceLocator().sessionService {
    _startTimer();
  }

  final Queue<Map<String, String?>> _eventQueue = Queue<Map<String, String?>>();
  final Queue<Map<String, String?>> _overflowQueue =
      Queue<Map<String, String?>>(); // New overflow queue
  final Map<Map<String, String?>, int> _failedEvents = {};
  Timer? _timer;
  bool _isSending = false;
  StreamController<String>? _logController;

  // Getter for the log stream
  Stream<String> get logStream {
    _logController ??= StreamController<String>.broadcast();
    return _logController!.stream;
  }

  void _log(String message) {
    MetricsLogger.logEvent('EventDispatcher', {'message': message});
    _logController?.add(message);
  }

  void updateConfig(EventDispatcherConfig newConfig) {
    if (newConfig.batchInterval != config.batchInterval) {
      _startTimer();
    }
  }

  bool dispatch(Map<String, String?> event) {
    // Handle continuous playing events after pulse
    if (_lastSentEvent != null &&
        _lastSentEvent?['evna'] == PlayerEvent.pulse.name &&
        event['evna'] == PlayerEvent.playing.name) {
      _log(
          'Playing event after pulse - dropping event and scheduling next pulse');
      _schedulePulseEvent(); // Schedule next pulse to maintain 10s interval
      return false;
    }

    // Check if this is a duplicate playing event
    if (_areEventsEqual(_lastSentEvent, event)) {
      if (event['evna'] == PlayerEvent.playing.name) {
        _log(
            'Duplicate playing event detected - dropping event and scheduling pulse');
        _schedulePulseEvent(); // Schedule pulse for continuous playing state
        return false;
      }
      // For non-playing events, just drop duplicates
      if (_lastSentEvent?['evna'] != PlayerEvent.pulse.name) {
        _log('Duplicate event detected - dropping event');
        return false;
      }
    }

    _lastSentEvent = event;

    // Only cancel pulse scheduling for non-playing events
    if (event['evna'] != PlayerEvent.playing.name) {
      _cancelPulseEvent();
    }

    if (_eventQueue.length >= config.maxQueueSize) {
      if (config.useOverflowQueue) {
        _overflowQueue.add(event);
        _log(
            'Main queue full - event added to overflow queue (size: ${_overflowQueue.length})');
        return true;
      } else {
        _log('Event queue full - dropping event');
        return false;
      }
    }
    _eventQueue.add(event);
    return true;
  }

  bool _areEventsEqual(
      Map<String, String?>? event1, Map<String, String?> event2) {
    if (event1 == null) return false;
    if (event1.length != event2.length) return false;
    return event1['evna'] == event2['evna'];
  }

  void _schedulePulseEvent() async {
    if (!_isPulseEventScheduled) {
      _isPulseEventScheduled = true;
      _pulseTimer?.cancel();
      _pulseTimer = Timer(_pulseInterval, () async {
        // Create and dispatch a pulse event directly
        final pulseEvent = await PulseEvent.createPulseEvent();
        dispatch(pulseEvent.toJson());
        _isPulseEventScheduled = false;
      });
    }
  }

  void _cancelPulseEvent() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _isPulseEventScheduled = false;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(config.batchInterval, (_) => _processEvents());
  }

  // Force immediate processing of events
  Future<void> flush() async {
    await _processEvents();
  }

  Future<void> _processEvents() async {
    if (_isSending ||
        (_eventQueue.isEmpty &&
            _failedEvents.isEmpty &&
            _overflowQueue.isEmpty)) {
      return;
    }

    _isSending = true;

    try {
      // Move events from overflow queue to main queue if space available
      while (_overflowQueue.isNotEmpty &&
          _eventQueue.length < config.maxQueueSize) {
        _eventQueue.add(_overflowQueue.removeFirst());
        _log('Moved event from overflow queue to main queue');
      }

      // Prioritize failed events based on retry count
      final retryEvents = _failedEvents.entries
          .where((entry) => entry.value < config.maxRetries)
          .map((entry) => entry.key)
          .toList();

      // Calculate how many new events we can process
      final availableBatchSize = config.maxBatchSize - retryEvents.length;
      final newEvents = _eventQueue.take(availableBatchSize).toList();

      // Combine failed events with new events
      final eventsToSend = [...retryEvents, ...newEvents];

      // Remove sent events from queues
      for (final event in eventsToSend) {
        _failedEvents.remove(event);
      }
      for (var i = 0; i < newEvents.length; i++) {
        _eventQueue.removeFirst();
      }

      if (eventsToSend.isEmpty) {
        return;
      }

      final success = await sendEventsToServer(eventsToSend);

      if (!success) {
        // If send fails, add events to failed queue with retry count
        for (final event in eventsToSend) {
          final retryCount = _failedEvents[event] ?? 0;
          if (retryCount < config.maxRetries) {
            _failedEvents[event] = retryCount + 1;
            _log('Event retry ${retryCount + 1}/${config.maxRetries}');
          } else {
            MetricsLogger.logError(
                'Event dropped after ${config.maxRetries} retries');
          }
        }

        // Wait before next retry
        await Future.delayed(config.retryDelay);
      }
    } catch (e) {
      MetricsLogger.logError('Error processing events', e);
    } finally {
      _isSending = false;
    }
  }

  // Simulated API call with random success/failure
  Future<bool> sendEventsToServer(List<Map<String, String?>> events) async {
    try {
      final baseUrl = _configService.baseURL ?? "";
      final request = {
        "metadata": {
          "transmission_timestamp":
              _configService.currentTimeStamp().toString(),
        },
        "events": events
      };
      final http.Response response =
          await http.post(Uri.parse(baseUrl), body: jsonEncode(request));

      final bool success = response.statusCode == 200;
      if (success) {
        MetricsLogger.logEvent('EventDispatcher',
            {'message': 'Successfully sent events', 'count': events});
      } else {
        MetricsLogger.logError(
            'Failed to send events - will retry. Count: $events');
      }
      return success;
    } catch (ex) {
      MetricsLogger.logError('Error sending events to server', ex);
      return false;
    }
  }

  // Get current queue statistics
  Map<String, int> getQueueStats() {
    return {
      'queuedEvents': _eventQueue.length,
      'overflowEvents': _overflowQueue.length,
      'failedEvents': _failedEvents.length,
      'totalEvents':
          _eventQueue.length + _overflowQueue.length + _failedEvents.length,
    };
  }

  // Clean up method for tests and app shutdown
  void dispose() {
    _timer?.cancel();
    _pulseTimer?.cancel();
    _timer = null;
    _pulseTimer = null;
    _eventQueue.clear();
    _overflowQueue.clear();
    _failedEvents.clear();
    _lastSentEvent = null;
    _isPulseEventScheduled = false;
    _logController?.close();
    _logController = null;
  }
}
