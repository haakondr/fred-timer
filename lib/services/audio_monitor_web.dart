import 'dart:async';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'audio_monitor.dart';

/// Factory function for conditional import
AudioMonitor createPlatformAudioMonitor() {
  return AudioMonitorWeb();
}

/// Web implementation using Web Audio API
class AudioMonitorWeb implements AudioMonitor {
  web.AudioContext? _audioContext;
  web.AnalyserNode? _analyser;
  web.MediaStream? _stream;
  Timer? _pollTimer;
  final _decibelController = StreamController<double>.broadcast();
  bool _isMonitoring = false;

  @override
  Stream<double> get decibelStream => _decibelController.stream;

  @override
  Future<bool> hasPermission() async {
    // Return false so the intro screen is shown first
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    try {
      // Test if we can get microphone access
      final constraints = web.MediaStreamConstraints(audio: true.toJS);
      final stream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
      // Close test stream immediately
      stream.getTracks().toDart.forEach((track) => track.stop());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      return; // Already monitoring
    }

    try {
      // Request microphone access
      final constraints = web.MediaStreamConstraints(audio: true.toJS);
      _stream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;

      // Create audio context
      _audioContext = web.AudioContext();

      // Create analyser node
      _analyser = _audioContext!.createAnalyser();
      _analyser!.fftSize = 2048;
      _analyser!.smoothingTimeConstant = 0.8;

      // Connect microphone to analyser
      final source = _audioContext!.createMediaStreamSource(_stream!);
      source.connect(_analyser!);

      _isMonitoring = true;

      // Poll for audio levels at 60 FPS
      _pollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        _updateDecibels();
      });
    } catch (e) {
      throw AudioMonitorException('Failed to start web audio monitoring: $e');
    }
  }

  void _updateDecibels() {
    if (_analyser == null || !_isMonitoring) return;

    // Get frequency data
    final bufferLength = _analyser!.frequencyBinCount;
    final dataArray = Uint8List(bufferLength);
    _analyser!.getByteFrequencyData(dataArray.toJS);

    // Calculate RMS (root mean square) from frequency data
    double sum = 0;
    for (var i = 0; i < bufferLength; i++) {
      final normalized = dataArray[i] / 255.0;
      sum += normalized * normalized;
    }
    final rms = sqrt(sum / bufferLength);

    // Convert RMS to decibels
    // RMS range: 0.0 to 1.0
    // Map to dB range: 30 dB (quiet) to 100 dB (loud)
    // Using logarithmic scale
    double decibels;
    if (rms < 0.0001) {
      decibels = 30.0; // Minimum threshold
    } else {
      // Convert to dB: 20 * log10(rms)
      // Scale and offset to match mobile readings
      final rawDb = 20 * log(rms) / ln10;
      // Map from roughly -80dB..0dB to 30dB..100dB
      decibels = ((rawDb + 80) * 0.875) + 30;
      decibels = decibels.clamp(30.0, 100.0);
    }

    _decibelController.add(decibels);
  }

  @override
  void stopMonitoring() {
    _isMonitoring = false;
    _pollTimer?.cancel();
    _pollTimer = null;

    _stream?.getTracks().toDart.forEach((track) => track.stop());
    _stream = null;

    _audioContext?.close();
    _audioContext = null;
    _analyser = null;
  }

  @override
  void dispose() {
    stopMonitoring();
    _decibelController.close();
  }
}
