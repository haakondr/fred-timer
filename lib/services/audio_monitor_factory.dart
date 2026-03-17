import 'audio_monitor.dart';
import 'audio_monitor_stub.dart'
    if (dart.library.html) 'audio_monitor_web.dart'
    if (dart.library.io) 'audio_monitor_mobile.dart';

/// Factory to create platform-specific audio monitor
AudioMonitor createAudioMonitor() {
  return createPlatformAudioMonitor();
}
