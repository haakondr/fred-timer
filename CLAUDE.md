# Claude Development Instructions

## Project
**App Name**: Fred (English and Norwegian)
**Purpose**: Timer app that encourages kids to stay quiet by resetting when noise levels exceed a threshold
**App Icon**: Digital timer "10:00" above vertical dB meter bar (green/orange/dark blocks)
  - Source: `icon_concepts/meter_with_timer_v2.svg`
  - Generated PNGs in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Reference: `app_icon.png` (1024x1024)

## How The App Works

### Core Functionality
Fred is a countdown timer that monitors ambient noise levels using the device microphone. The timer resets when noise exceeds a configurable threshold, encouraging kids to maintain quiet behavior.

### Main Features

**1. Timer**
- Default duration: 10 minutes (configurable 1-60 minutes in settings)
- Displays countdown in MM:SS format (72pt monospace font)
- Timer color changes based on noise level:
  - Dark blue-gray: Normal/quiet
  - Orange gradient: Warning zone
  - Red: Threshold exceeded
- **Reset Animation**: When timer resets due to noise, it scales to 1.5x and blinks for 5 seconds

**2. Noise Monitoring**
- Real-time microphone monitoring using `noise_meter` package
- **Median smoothing**: 1-second sliding window to filter out transient spikes
- **Sustained noise detection**: 2-second threshold required before reset (prevents false triggers from coughs/spikes)
- Default thresholds:
  - Warning: 75 dB (visual + haptic feedback)
  - Reset: 80 dB (sustained for 2 seconds)

**3. Visual Feedback**
- **Alsamixer-style vertical meter** (160px wide, 200px tall, 25 blocks):
  - Green blocks: Quiet zone (bottom 60%)
  - Orange blocks: Warning zone (60-80%)
  - Red blocks: Danger zone (top 20%)
  - Dark/empty blocks: Above current level
- **Background blinking**:
  - Orange blink: Warning threshold exceeded
  - Red blink: Reset threshold exceeded
- **Solarized color palette**: Cream backgrounds, blue/green/orange/red accents

**4. Haptic Feedback**
- Light pulsing vibration (1-second intervals) in warning zone
- Triple-burst heavy vibration on timer reset

**5. Completion Celebration**
- Light cream background (Solarized base3)
- Sparkling fireworks animation (5 fireworks, 40 particles each with physics)
- Localized success message: "Timer Complete!" / "Bra jobba!"
- Restart button to begin again

**6. Internationalization**
- Supports English and Norwegian (Bokmål)
- System language detection with English fallback for unsupported languages
- User can override language in settings
- All UI strings localized via ARB files

**7. Settings**
- **Timer Duration**: 1-60 minutes (slider)
- **Noise Threshold**: 40-100 dB (slider)
- **Warning Threshold**: 30 dB to (threshold - 5) dB (slider)
- **Language**: System default / English / Norwegian
- **Decibel Reference Guide**: Common sound levels for context

### Technical Implementation

**Architecture**
- Flutter/Dart iOS app
- Single-screen app with modal settings screen
- State management: StatefulWidget with AnimationControllers
- Settings persistence: SharedPreferences

**Key Packages**
- `noise_meter ^5.0.1`: Real-time audio level monitoring
- `permission_handler ^11.0.1`: Microphone permission handling
- `vibration ^2.0.0`: Haptic feedback
- `shared_preferences ^2.2.2`: Settings storage
- `flutter_localizations`: Built-in i18n support

**Noise Processing Pipeline**
1. Raw dB reading from microphone
2. Add to 1-second sliding window
3. Calculate median value (removes spikes)
4. Check if exceeds warning threshold → haptic + visual feedback
5. Check if exceeds reset threshold → start 2-second sustained timer
6. If sustained for 2 seconds → reset timer + triple vibration
7. If drops below threshold → cancel sustained timer

**Animation Controllers**
- `_celebrationController`: Fireworks animation (3s, looping)
- `_warningController`: Deprecated (was for warning animations)
- `_backgroundBlinkController`: Background color blink (500ms oscillate)
- `_resetAnimationController`: Timer scale/blink on reset (5s)

## Critical Build Requirements

### Flutter Build Integrity
- **CRITICAL**: Ensure Flutter build always passes before completing any task
- Run `flutter build ios --no-codesign` or equivalent to verify builds succeed
- Never leave the codebase in a non-buildable state

### Internationalization (i18n)
- i18n files must always be generated after ARB file changes
- Run `flutter gen-l10n` after modifying any `.arb` files in `lib/l10n/`
- Localization files are generated in `lib/l10n/` (not `flutter_gen`)
- Import path: `import '../l10n/app_localizations.dart';` (or `'l10n/app_localizations.dart'` from main.dart)

### Pre-delivery Checklist
Before marking work complete:
1. ✅ Run `flutter gen-l10n` if ARB files were modified
2. ✅ Run `flutter build ios --no-codesign` to verify build passes
3. ✅ Fix any compilation errors
4. ✅ Ensure all imports resolve correctly
