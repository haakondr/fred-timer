import 'dart:async';

/// Abstract interface for audio monitoring across platforms
abstract class AudioMonitor {
  /// Stream of decibel readings
  Stream<double> get decibelStream;

  /// Check if microphone permission is granted
  Future<bool> hasPermission();

  /// Request microphone permission
  Future<bool> requestPermission();

  /// Start monitoring audio levels
  Future<void> startMonitoring();

  /// Stop monitoring audio levels
  void stopMonitoring();

  /// Dispose resources
  void dispose();
}

/// Exception thrown when audio monitoring fails
class AudioMonitorException implements Exception {
  final String message;
  AudioMonitorException(this.message);

  @override
  String toString() => 'AudioMonitorException: $message';
}
