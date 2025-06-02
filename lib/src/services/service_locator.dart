import 'configuration/configuration_service.dart';
import 'session/session_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  ConfigurationService? _configurationService;
  SessionService? _sessionService;

  ConfigurationService get configurationService {
    _configurationService ??= ConfigurationService();
    return _configurationService!;
  }

  SessionService get sessionService {
    _sessionService ??= SessionService();
    return _sessionService!;
  }

  // Reset method for testing
  void reset() {
    _configurationService?.reset();
    _configurationService = null;
    _sessionService?.reset();
    _sessionService = null;
  }
}
