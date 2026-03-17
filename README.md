# Quiet Timer

A Flutter iOS app that helps kids stay quiet by monitoring noise levels and counting down to a reward.

## Features

- **Real-time Decibel Monitoring**: Uses the device microphone to measure noise levels
- **Countdown Timer**: Configurable timer (default 10 minutes)
- **Auto-Reset**: Timer resets when noise exceeds the threshold
- **Visual Feedback**:
  - Background color changes from cool gray → light orange → light red as noise approaches threshold
  - Progress bar color changes: sky blue (normal) → orange → red (smooth warning to danger gradient)
  - Timer text color adapts: navy (normal) → orange → red (smooth warning to danger gradient)
- **Haptic Feedback**: Vibration with increasing intensity as noise approaches threshold
- **Celebration Screen**: Ice blue and sky blue gradient with animated celebration icon
- **Configurable Settings**:
  - Timer duration (1-60 minutes, default: 10 minutes)
  - Noise threshold (40-100 dB, default: 80 dB)
  - Warning threshold (triggers visual/haptic warnings, default: 75 dB)

## Running the App

```bash
flutter run
```

## Permissions

The app requires microphone permission to monitor noise levels. Permission is requested on first launch.

## Name Ideas

Current name: **Quiet Timer**

Alternative suggestions:
- **Hush Rush** - fun alliteration
- **Quiet Quest** - gamifies the experience
- **Shut The Front Up** - playful euphemism
- **Zip It Challenge** - casual and fun
- **Shush Timer** - simple and clear

## How It Works

1. Set your desired duration and noise thresholds in Settings
2. Press Start to begin the countdown
3. Kids need to keep quiet below the threshold
4. Visual and haptic warnings appear as noise approaches the limit
5. Timer resets if threshold is exceeded
6. Celebration screen when timer completes!

## Design System

The app uses the MEGAHARN color palette for consistent, vibrant, and sunlight-readable design:

**Color Palette:**
- **Background**: `#F5F7FA` - Cool gray (reduces glare)
- **Sky Blue**: `#57C7FF` - Primary actions and normal states
- **Ice Blue**: `#64FFDA` - Success and celebration
- **Orange**: `#FF9800` - Warning state (approaching threshold)
- **Red**: `#D32F2F` - Danger state (threshold exceeded)
- **Navy**: `#0a192f` - Text and dark elements

**Dark Mode Support:**
- Automatically follows system theme preference
- Navy background with lighter navy surfaces
- Accent colors remain vibrant for visibility

## Technical Stack

- Flutter 3.x
- Packages:
  - `noise_meter` - Decibel monitoring
  - `permission_handler` - Microphone permissions
  - `vibration` - Haptic feedback
  - `shared_preferences` - Settings storage
