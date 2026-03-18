# Claude Development Instructions

## Project
**App Name**: Fred
**Purpose**: Timer app that rewards silence — resets when noise levels exceed a threshold, celebrates with confetti when completed
**License**: MIT (open source)
**Repo**: https://github.com/haakondr/fred-timer
**App Icon**: Terrazzo-style confetti pattern
  - Source: `icon_concepts/terrazzo_confetti.svg`
  - Dense scatter of confetti shapes (circles, rectangles, triangles, stars)
  - Uses all game confetti colors (yellow, coral, fuchsia, teal, violet, orange, hot pink)
  - Cream background (Solarized base3 #FDF6E3)
  - Generated PNGs in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Reference: `terrazzo_app_icon.png` (1024x1024)

## How The App Works

### Core Functionality
Fred is a countdown timer that monitors ambient noise levels using the device microphone. The timer resets when noise exceeds a configurable threshold, encouraging quiet time.

### Main Features

**1. Timer**
- Default duration: 10 minutes (configurable 1-60 minutes in settings)
- Displays countdown in MM:SS format (72pt monospace font)
- Timer color changes based on noise level:
  - Dark blue-gray: Normal/quiet
  - Coral-fuchsia gradient: Warning zone
  - Fuchsia: Threshold exceeded
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
  - Yellow blocks: Quiet zone (bottom 60%)
  - Coral blocks: Warning zone (60-80%)
  - Fuchsia blocks: Danger zone (top 20%)
  - Dark/empty blocks: Above current level
- **Background blinking**:
  - Coral blink: Warning threshold exceeded
  - Fuchsia blink: Reset threshold exceeded
- **Progressive confetti rain**: Physics-based confetti that builds up gradually during the timer, scaled to timer duration
- **Solarized color palette**: Cream backgrounds, blue/green/orange/red accents

**4. Haptic Feedback**
- Light pulsing vibration (1-second intervals) in warning zone
- Triple-burst heavy vibration on timer reset

**5. Completion Celebration**
- Light cream background (Solarized base3)
- Physics-based confetti explosion that fills the screen
- Restart button appears when confetti reaches half screen height

**6. Settings**
- **Timer Duration**: 1-60 minutes (slider)
- **Noise Threshold**: 40-100 dB (slider)
- **Warning Threshold**: 30 dB to (threshold - 5) dB (slider)
- **Decibel Reference Guide**: Common sound levels for context
- **Privacy Policy**: Link at bottom of settings

**7. Privacy Policy**
- In-app privacy policy screen with selectable text
- Sections: Data Collection, Microphone Usage, Local Storage, Data Security, Contact, Open Source
- Contact links to GitHub issues
- Also linked from microphone permission screen

### Technical Implementation

**Architecture**
- Flutter/Dart iOS + web app
- Single-screen app with modal settings and privacy screens
- State management: StatefulWidget with AnimationControllers
- Settings persistence: SharedPreferences
- English only (no i18n) — strings in `lib/strings.dart`
- Responsive layout: settings and privacy screens constrained to 600px max width for desktop web

**Key Packages**
- `noise_meter`: Real-time audio level monitoring
- `permission_handler`: Microphone permission handling
- `vibration`: Haptic feedback
- `shared_preferences`: Settings storage
- `forge2d`: Physics engine for confetti
- `google_fonts`: Nunito typeface
- `wakelock_plus`: Keeps screen on during timer
- `url_launcher`: Opening external links (GitHub)

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
- `_celebrationController`: Confetti celebration (5min, looping)
- `_warningController`: Warning animations
- `_backgroundBlinkController`: Background color blink (500ms oscillate)
- `_resetAnimationController`: Timer scale/blink on reset (5s)

**Key Files**
- `lib/main.dart`: App entry, main screen with timer and settings navigation
- `lib/screens/timer_screen.dart`: Timer, noise monitoring, confetti logic
- `lib/screens/settings_screen.dart`: Settings UI
- `lib/screens/privacy_policy_screen.dart`: Privacy policy view
- `lib/widgets/confetti_physics.dart`: Physics-based confetti system (forge2d)
- `lib/strings.dart`: All UI strings (English)
- `lib/theme/app_theme.dart`: Light/dark themes with Nunito font
- `lib/theme/app_colors.dart`: Color constants

## Critical Build Requirements

### Flutter Build Integrity
- **CRITICAL**: Ensure Flutter build always passes before completing any task
- Run `flutter build ios --no-codesign` or equivalent to verify builds succeed
- Never leave the codebase in a non-buildable state

### Pre-delivery Checklist
Before marking work complete:
1. ✅ Run `flutter build ios --no-codesign` to verify build passes
2. ✅ Fix any compilation errors
3. ✅ Ensure all imports resolve correctly
