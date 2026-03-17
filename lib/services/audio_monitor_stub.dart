import 'audio_monitor.dart';
import 'audio_monitor_mobile.dart';

/// Stub - should never be called due to conditional imports
AudioMonitor createPlatformAudioMonitor() {
  return AudioMonitorMobile();
}
