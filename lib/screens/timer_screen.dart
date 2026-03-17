import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import '../models/app_settings.dart';
import '../theme/app_colors.dart';
import '../widgets/kaleidoscope_painter.dart';

class _DecibelReading {
  final double value;
  final DateTime timestamp;

  _DecibelReading(this.value, this.timestamp);
}

class TimerScreen extends StatefulWidget {
  final AppSettings settings;

  const TimerScreen({super.key, required this.settings});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late NoiseMeter _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  Timer? _timer;

  int _remainingSeconds = 0;
  double _currentDecibels = 0.0;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool _hasPermission = false;

  // Sliding window for smoothing decibel readings
  final List<_DecibelReading> _decibelReadings = [];
  static const _smoothingWindowDuration = Duration(seconds: 1);

  // 10-second window for sustained elevated noise detection
  final List<_DecibelReading> _longTermReadings = [];
  static const _longTermWindowDuration = Duration(seconds: 10);

  // Sustained noise tracking for reset
  DateTime? _firstThresholdExceededTime;
  static const _sustainedNoiseDuration = Duration(seconds: 2);

  // Vibration tracking
  DateTime? _lastWarningVibrationTime;
  static const _warningVibrationInterval = Duration(milliseconds: 1000);

  late AnimationController _celebrationController;
  late AnimationController _warningController;
  late AnimationController _backgroundBlinkController;
  late AnimationController _resetAnimationController;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
    _remainingSeconds = widget.settings.timerDurationMinutes * 60;
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && _isCompleted) {
          // Loop kaleidoscope animation
          _celebrationController.forward(from: 0.0);
        }
      });
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _warningController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _warningController.forward();
        }
      });
    _backgroundBlinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _backgroundBlinkController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          if (_isRunning && _currentDecibels >= widget.settings.warningThreshold) {
            _backgroundBlinkController.forward();
          }
        }
      });
    _resetAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.microphone.status;
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
      });
    }
  }

  void _addDecibelReading(double value) {
    final now = DateTime.now();
    _decibelReadings.add(_DecibelReading(value, now));
    _longTermReadings.add(_DecibelReading(value, now));

    // Remove readings older than 1 second from short-term window
    _decibelReadings.removeWhere((reading) =>
        now.difference(reading.timestamp) > _smoothingWindowDuration);

    // Remove readings older than 10 seconds from long-term window
    _longTermReadings.removeWhere((reading) =>
        now.difference(reading.timestamp) > _longTermWindowDuration);
  }

  double _getSmoothedDecibels() {
    if (_decibelReadings.isEmpty) return 0.0;

    // Calculate median
    final values = _decibelReadings.map((r) => r.value).toList()..sort();
    final middle = values.length ~/ 2;

    if (values.length % 2 == 0) {
      return (values[middle - 1] + values[middle]) / 2;
    } else {
      return values[middle];
    }
  }

  double _getLongTermMedianDecibels() {
    if (_longTermReadings.isEmpty) return 0.0;

    // Calculate median over 10-second window
    final values = _longTermReadings.map((r) => r.value).toList()..sort();
    final middle = values.length ~/ 2;

    if (values.length % 2 == 0) {
      return (values[middle - 1] + values[middle]) / 2;
    } else {
      return values[middle];
    }
  }

  @override
  void dispose() {
    _stopMonitoring();
    _timer?.cancel();
    _celebrationController.dispose();
    _warningController.dispose();
    _backgroundBlinkController.dispose();
    _resetAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.timerDurationMinutes != widget.settings.timerDurationMinutes) {
      if (!_isRunning) {
        setState(() {
          _remainingSeconds = widget.settings.timerDurationMinutes * 60;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    debugPrint('Requesting microphone permission...');

    // First, try to request permission (will show native iOS prompt if not asked before)
    var status = await Permission.microphone.request();
    debugPrint('Permission status after request: $status');

    // If permission not granted, show dialog to open settings
    if (!status.isGranted) {
      debugPrint('Permission not granted, showing settings dialog');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.microphonePermissionRequired),
            content: Text(l10n.pleaseEnableMicrophoneAccess),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.openSettings),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          debugPrint('Opening app settings');
          await openAppSettings();
          // After user returns from settings, check permission again
          status = await Permission.microphone.status;
          debugPrint('Permission status after returning from settings: $status');
        }
      }
    }

    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        debugPrint('Updated _hasPermission to: $_hasPermission');
      });
    }
  }

  void _startMonitoring() {
    if (!_hasPermission) {
      _requestPermission();
      return;
    }

    try {
      _noiseSubscription = _noiseMeter.noise.listen(
        (NoiseReading reading) {
          final db = reading.meanDecibel;

          // Add to sliding window
          _addDecibelReading(db);

          // Get smoothed value
          final smoothedDb = _getSmoothedDecibels();

          setState(() {
            _currentDecibels = smoothedDb;
          });

          if (_isRunning && !_isCompleted) {
            // Check 10-second median for sustained elevated noise
            final longTermMedian = _getLongTermMedianDecibels();
            if (longTermMedian >= widget.settings.decibelThreshold) {
              debugPrint('10-second median ($longTermMedian dB) exceeds threshold - RESET!');
              _resetTimer();
              _triggerHapticFeedback(intensity: 3);
              _firstThresholdExceededTime = null;
              return; // Skip further checks after reset
            }

            if (smoothedDb >= widget.settings.decibelThreshold) {
              // Start red blink if not already blinking
              if (!_backgroundBlinkController.isAnimating) {
                _backgroundBlinkController.forward();
              }

              // Track sustained high noise (2-second immediate loud noise)
              if (_firstThresholdExceededTime == null) {
                _firstThresholdExceededTime = DateTime.now();
                debugPrint('Threshold exceeded, starting sustained noise timer...');
              } else {
                final sustainedDuration = DateTime.now().difference(_firstThresholdExceededTime!);
                if (sustainedDuration >= _sustainedNoiseDuration) {
                  debugPrint('Sustained loud noise for ${sustainedDuration.inSeconds}s - RESET!');
                  _resetTimer();
                  _triggerHapticFeedback(intensity: 3);
                  _firstThresholdExceededTime = null;
                }
              }
            } else {
              // Below threshold - reset the sustained noise tracker
              if (_firstThresholdExceededTime != null) {
                debugPrint('Noise dropped below threshold - canceling reset');
                _firstThresholdExceededTime = null;
              }

              if (smoothedDb >= widget.settings.warningThreshold) {
                // Start orange blink if not already blinking
                if (!_backgroundBlinkController.isAnimating) {
                  _backgroundBlinkController.forward();
                }

                final ratio = (smoothedDb - widget.settings.warningThreshold) /
                    (widget.settings.decibelThreshold - widget.settings.warningThreshold);
                _handleWarning(ratio);

                // Pulsing vibration in warning zone
                final now = DateTime.now();
                if (_lastWarningVibrationTime == null ||
                    now.difference(_lastWarningVibrationTime!) >= _warningVibrationInterval) {
                  _lastWarningVibrationTime = now;
                  _triggerHapticFeedback(intensity: 1);
                }
              } else {
                // Stop blinking when below warning threshold
                if (_backgroundBlinkController.isAnimating) {
                  _backgroundBlinkController.stop();
                  _backgroundBlinkController.reset();
                }
                _lastWarningVibrationTime = null;
                _stopWarning();
              }
            }
          }
        },
        onError: (error) {
          debugPrint('Noise meter error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error starting noise meter: $e');
    }
  }

  void _stopMonitoring() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
  }

  void _handleWarning(double intensity) {
    if (!_warningController.isAnimating) {
      _warningController.forward();
    }

    if (intensity > 0.7) {
      _triggerHapticFeedback(intensity: 2);
    } else if (intensity > 0.4) {
      _triggerHapticFeedback(intensity: 1);
    }
  }

  void _stopWarning() {
    if (_warningController.isAnimating) {
      _warningController.stop();
      _warningController.reset();
    }
  }

  Future<void> _triggerHapticFeedback({int intensity = 1}) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      if (intensity == 3) {
        // Heavy reset vibration - triple burst
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.heavyImpact();
      } else if (intensity == 2) {
        HapticFeedback.mediumImpact();
      } else {
        // Light pulsing for warning
        HapticFeedback.lightImpact();
      }
    }
  }

  void _startTimer() {
    // Cancel any existing timer first
    _timer?.cancel();

    setState(() {
      _isRunning = true;
      _isCompleted = false;
    });

    _startMonitoring();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _completeTimer();
          }
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _stopMonitoring();
    _decibelReadings.clear();
    _longTermReadings.clear();
    _firstThresholdExceededTime = null;
    _lastWarningVibrationTime = null;
    _backgroundBlinkController.stop();
    _backgroundBlinkController.reset();
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = widget.settings.timerDurationMinutes * 60;
    });
    _resetAnimationController.forward(from: 0.0);
  }

  void _completeTimer() {
    _timer?.cancel();
    _stopMonitoring();
    _decibelReadings.clear();
    _longTermReadings.clear();
    _firstThresholdExceededTime = null;
    _lastWarningVibrationTime = null;
    _backgroundBlinkController.stop();
    _backgroundBlinkController.reset();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    _celebrationController.forward();
    _triggerHapticFeedback(intensity: 3);
  }

  void _restart() {
    setState(() {
      _remainingSeconds = widget.settings.timerDurationMinutes * 60;
      _isCompleted = false;
      _isRunning = false;
    });
    _celebrationController.stop();
    _celebrationController.reset();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  LinearGradient _getBackgroundGradient() {
    if (_isCompleted) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.iceBlue, AppColors.skyBlue],
      );
    }

    if (!_isRunning) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFDF6E3), // Solarized base3 (light cream)
          Color(0xFFEEE8D5), // Solarized base2 (light beige)
        ],
      );
    }

    // Blink opacity based on animation
    final blinkValue = _backgroundBlinkController.value;
    final baseOpacity = 0.3 + (blinkValue * 0.4); // Oscillates 0.3-0.7

    if (_currentDecibels >= widget.settings.decibelThreshold) {
      // Red blink
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFDC322F).withValues(alpha: baseOpacity), // Solarized red
          Color(0xFFDC322F).withValues(alpha: baseOpacity * 0.8),
        ],
      );
    } else if (_currentDecibels >= widget.settings.warningThreshold) {
      // Orange blink
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFCB4B16).withValues(alpha: baseOpacity), // Solarized orange
          Color(0xFFCB4B16).withValues(alpha: baseOpacity * 0.8),
        ],
      );
    }

    // Normal sandy background
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFDF6E3), // Solarized base3 (light cream)
        Color(0xFFEEE8D5), // Solarized base2 (light beige)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_hasPermission) {
      return Container(
        color: const Color(0xFFFDF6E3), // Solarized base3 (cream)
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_off, size: 80, color: const Color(0xFF073642).withValues(alpha: 0.4)),
              const SizedBox(height: 24),
              Text(
                l10n.microphoneAccessRequired,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.microphoneAccessDescription,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.mic),
                label: Text(l10n.grantPermission),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_warningController, _backgroundBlinkController]),
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: _getBackgroundGradient(),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildTimerDisplay(),
                        const SizedBox(height: 40),
                        _buildDecibelMeter(),
                        const SizedBox(height: 24),
                        _buildControls(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimerDisplay() {
    final l10n = AppLocalizations.of(context)!;

    Color timerColor = const Color(0xFF073642); // Solarized base02 (dark blue-gray)
    if (_currentDecibels >= widget.settings.decibelThreshold) {
      timerColor = const Color(0xFFDC322F); // Solarized red
    } else if (_currentDecibels >= widget.settings.warningThreshold) {
      // Gradient from orange to red based on how close to threshold
      final ratio = (_currentDecibels - widget.settings.warningThreshold) /
          (widget.settings.decibelThreshold - widget.settings.warningThreshold);
      timerColor = Color.lerp(
        const Color(0xFFCB4B16), // Solarized orange
        const Color(0xFFDC322F), // Solarized red
        ratio.clamp(0.0, 1.0),
      )!;
    }

    return AnimatedBuilder(
      animation: _resetAnimationController,
      builder: (context, child) {
        // Scale animation: 1.0 -> 1.5 -> 1.0 over 5 seconds
        final progress = _resetAnimationController.value;
        double scale = 1.0;
        if (progress > 0.0) {
          if (progress < 0.3) {
            // Scale up in first 1.5 seconds
            scale = 1.0 + (progress / 0.3) * 0.5;
          } else if (progress < 0.7) {
            // Stay at 1.5x for middle period
            scale = 1.5;
          } else {
            // Scale down in last 1.5 seconds
            scale = 1.5 - ((progress - 0.7) / 0.3) * 0.5;
          }
        }

        // Blink animation: opacity oscillates
        final blinkProgress = (progress * 10) % 1.0; // 10 blinks over 5 seconds
        final opacity = progress > 0.0 ? (0.3 + (blinkProgress * 0.7)) : 1.0;

        return Column(
          children: [
            Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 6,
                    color: timerColor,
                    shadows: _currentDecibels >= widget.settings.decibelThreshold
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!_isRunning)
              Text(
                l10n.readyToStart,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF586E75), // Solarized base01
                    ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDecibelMeter() {
    // Calculate percentage based on a reasonable scale (0-100 dB)
    final percentage = (_currentDecibels / 100).clamp(0.0, 1.0);
    final isWarning = _currentDecibels >= widget.settings.warningThreshold;
    final isOverThreshold = _currentDecibels >= widget.settings.decibelThreshold;

    Color meterColor = const Color(0xFF268BD2); // Solarized blue
    Color textColor = const Color(0xFF073642); // Solarized base02

    if (isOverThreshold) {
      meterColor = const Color(0xFFDC322F); // Solarized red
      textColor = const Color(0xFFDC322F);
    } else if (isWarning) {
      // Gradient from orange to red
      final ratio = (_currentDecibels - widget.settings.warningThreshold) /
          (widget.settings.decibelThreshold - widget.settings.warningThreshold);
      meterColor = Color.lerp(
        const Color(0xFFCB4B16), // Solarized orange
        const Color(0xFFDC322F), // Solarized red
        ratio.clamp(0.0, 1.0),
      )!;
      textColor = meterColor;
    }

    // Build alsamixer-style block meter
    const totalBlocks = 25;
    final filledBlocks = (percentage * totalBlocks).round();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Alsamixer-style vertical meter (centered, 2x wider)
          Container(
            width: 160,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF073642), // Solarized base02 (dark terminal bg)
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF586E75), // Solarized base01
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(totalBlocks, (index) {
                final blockIndex = totalBlocks - 1 - index;
                final isFilled = blockIndex < filledBlocks;

                // Determine block color based on position
                Color blockColor;
                if (isFilled) {
                  if (blockIndex >= totalBlocks * 0.8) {
                    blockColor = const Color(0xFFDC322F); // Red (top 20%)
                  } else if (blockIndex >= totalBlocks * 0.6) {
                    blockColor = const Color(0xFFCB4B16); // Orange (60-80%)
                  } else {
                    blockColor = const Color(0xFF859900); // Green (bottom 60%)
                  }
                } else {
                  blockColor = const Color(0xFF002B36); // Solarized base03 (empty)
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: Center(
                      child: Text(
                        isFilled ? '█' : '░',
                        style: TextStyle(
                          fontSize: 8,
                          color: isFilled ? blockColor : const Color(0xFF073642),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // dB reading below meter
          Text(
            '${_currentDecibels.round()} dB',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRunning)
          ElevatedButton.icon(
            onPressed: _startTimer,
            icon: const Icon(Icons.play_arrow, size: 32),
            label: Text(l10n.start, style: const TextStyle(fontSize: 20)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _pauseTimer,
            icon: const Icon(Icons.pause, size: 32),
            label: Text(l10n.pause, style: const TextStyle(fontSize: 20)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.refresh, size: 32),
          label: Text(l10n.reset, style: const TextStyle(fontSize: 20)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6E3), // Solarized base3 (light cream)
      ),
      child: Stack(
        children: [
          // Kaleidoscope color explosion animation
          AnimatedBuilder(
            animation: _celebrationController,
            builder: (context, child) {
              return CustomPaint(
                painter: KaleidoscopePainter(
                  animation: _celebrationController,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Content overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.timerComplete,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Color(0xFF859900), // Solarized green
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh, size: 32),
                  label: Text(l10n.restart, style: const TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: const Color(0xFF268BD2), // Solarized blue
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
