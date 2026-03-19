import 'dart:async';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'audio_monitor.dart';

/// Factory function for conditional import
AudioMonitor createPlatformAudioMonitor() {
  return AudioMonitorMobile();
}

/// Mobile implementation using noise_meter package
class AudioMonitorMobile implements AudioMonitor {
  final _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _subscription;
  final _decibelController = StreamController<double>.broadcast();

  @override
  Stream<double> get decibelStream => _decibelController.stream;

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<void> startMonitoring() async {
    if (_subscription != null) {
      return; // Already monitoring
    }

    final hasPermission = await this.hasPermission();
    if (!hasPermission) {
      throw AudioMonitorException('Microphone permission not granted');
    }

    try {
      _subscription = _noiseMeter.noise.listen(
        (NoiseReading reading) {
          _decibelController.add(reading.meanDecibel);
        },
        onError: (error, stackTrace) {
          final exception = AudioMonitorException('Noise meter error: $error');
          Sentry.captureException(exception, stackTrace: stackTrace);
          _decibelController.addError(exception, stackTrace);
        },
      );
    } catch (e, stackTrace) {
      final exception = AudioMonitorException('Failed to start monitoring: $e');
      Sentry.captureException(exception, stackTrace: stackTrace);
      throw exception;
    }
  }

  @override
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    stopMonitoring();
    _decibelController.close();
  }
}
