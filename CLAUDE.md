# Claude Development Instructions

## Project
**App Name**: Fred (English and Norwegian)
**Purpose**: Timer app that encourages kids to stay quiet by resetting when noise levels exceed a threshold
**App Icon**: Terrazzo-style confetti pattern
  - Source: `icon_concepts/terrazzo_confetti.svg`
  - Dense scatter of confetti shapes (circles, rectangles, triangles, stars)
  - Uses all game confetti colors (yellow, coral, fuchsia, teal, violet, orange, hot pink)
  - Cream background (Solarized base3 #FDF6E3)
  - Generated PNGs in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Reference: `terrazzo_app_icon.png` (1024x1024)

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
- **Dual-window median smoothing**:
  - 1-second window: Filters transient spikes (coughs, single noises)
  - 10-second window: Detects sustained elevated noise levels
- **Dual reset triggers**:
  - Immediate: 2-second sustained loud noise above threshold
  - Elevated: 10-second median exceeds threshold (catches general high volume)
- Default thresholds:
  - Warning: 80 dB (visual + haptic feedback)
  - Reset: 90 dB (either trigger)

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
- **Kaleidoscope color explosion** animation:
  - 8-way radial symmetry with rotating/pulsing patterns
  - Layered geometric shapes (triangles, circles, diamonds)
  - Expanding color wave rings
  - Sparkle particles bursting outward
  - All colors from Solarized palette
  - 4-second looping animation
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
2. Add to both sliding windows:
   - 1-second window for instant smoothing
   - 10-second window for elevated noise detection
3. Calculate 1-second median value (instant display + removes spikes)
4. Check 10-second median → if exceeds threshold → immediate reset
5. Check 1-second median:
   - If exceeds warning threshold → haptic + visual feedback
   - If exceeds reset threshold → start 2-second sustained timer
   - If sustained for 2 seconds → reset timer + triple vibration
   - If drops below threshold → cancel sustained timer

**Animation Controllers**
- `_celebrationController`: Kaleidoscope color explosion (4s, looping)
- `_warningController`: Deprecated (was for warning animations)
- `_backgroundBlinkController`: Background color blink (500ms oscillate)
- `_resetAnimationController`: Timer scale/blink on reset (5s)

**Key Widgets**
- `lib/widgets/kaleidoscope_painter.dart`: Custom painter for completion celebration
  - 8-way radial symmetry pattern
  - Layered geometric shapes (triangles, circles, diamonds)
  - Expanding color wave rings
  - Sparkle particle effects
  - Uses all Solarized palette colors
  - Rotating and pulsing animations

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
