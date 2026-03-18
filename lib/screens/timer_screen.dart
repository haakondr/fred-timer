import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../strings.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/app_settings.dart';
import '../theme/app_colors.dart';
import '../widgets/confetti_physics.dart';
import '../services/audio_monitor_factory.dart';
import '../services/audio_monitor.dart';
import '../theme/app_colors.dart';
import 'privacy_policy_screen.dart';

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
  late AudioMonitor _audioMonitor;
  StreamSubscription<double>? _audioSubscription;
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
  ConfettiPhysicsWorld? _confettiPhysics;
  Timer? _confettiSpawnTimer;
  Timer? _physicsUpdateTimer;

  // Milestone tracking for confetti
  bool _reached25Percent = false;
  bool _reached50Percent = false;
  bool _reached75Percent = false;
  bool _reached90Percent = false;
  bool _showRestartButton = false;

  @override
  void initState() {
    super.initState();
    _audioMonitor = createAudioMonitor();
    _remainingSeconds = widget.settings.timerDurationMinutes * 60;
    _celebrationController = AnimationController(
      duration: const Duration(minutes: 5),
      vsync: this,
    );
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
    final hasPermission = await _audioMonitor.hasPermission();
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
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
    WakelockPlus.disable();
    _stopMonitoring();
    _audioMonitor.dispose();
    _timer?.cancel();
    _confettiSpawnTimer?.cancel();
    _physicsUpdateTimer?.cancel();
    _confettiPhysics?.dispose();
    _celebrationController.dispose();
    _warningController.dispose();
    _backgroundBlinkController.dispose();
    _resetAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset timer only if duration changed
    if (oldWidget.settings.timerDurationMinutes != widget.settings.timerDurationMinutes) {
      // Stop and reset timer
      _stopAndReset();
    }
  }

  Future<void> _requestPermission() async {
    debugPrint('Requesting microphone permission...');

    try {
      final granted = await _audioMonitor.requestPermission();
      debugPrint('Permission granted: $granted');

      if (mounted) {
        setState(() {
          _hasPermission = granted;
        });
      }

      // If not granted, show info dialog (web will show browser permission prompt)
      if (!granted && mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(Strings.microphonePermissionRequired),
            content: Text(Strings.pleaseEnableMicrophoneAccess),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(Strings.cancel),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Permission request failed: $e');
      if (mounted) {
        setState(() {
          _hasPermission = false;
        });
      }
    }
  }

  void _startMonitoring() {
    if (!_hasPermission) {
      _requestPermission();
      return;
    }

    try {
      // Start audio monitoring
      _audioMonitor.startMonitoring();

      // Subscribe to decibel stream
      _audioSubscription = _audioMonitor.decibelStream.listen(
        (db) {
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
          debugPrint('Audio monitor error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error starting audio monitor: $e');
    }
  }

  void _stopMonitoring() {
    _audioSubscription?.cancel();
    _audioSubscription = null;
    _audioMonitor.stopMonitoring();
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
        // Heavy reset vibration - triple burst with actual vibration
        await Vibration.vibrate(duration: 200);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 200);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 200);
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
      _reached25Percent = false;
      _reached50Percent = false;
      _reached75Percent = false;
      _reached90Percent = false;
    });

    // Keep screen on while timer is running
    WakelockPlus.enable();

    _startMonitoring();

    // Initialize physics world for confetti
    final screenSize = MediaQuery.of(context).size;
    _confettiPhysics = ConfettiPhysicsWorld(screenSize: screenSize);

    // Start confetti rain - scale interval to timer duration so buildup is gradual
    // Target ~50 particles in the first 25% of the timer
    final baseIntervalMs = (widget.settings.timerDurationMinutes * 60 * 1000 * 0.25 / 50).round().clamp(500, 5000);
    _startConfettiSpawn(screenSize, particlesPerSpawn: 1, intervalMs: baseIntervalMs);

    // Start physics update timer
    _physicsUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || _confettiPhysics == null) {
        return;
      }

      // Continue physics while running or completed
      if (_isRunning || _isCompleted) {
        setState(() {
          _confettiPhysics!.step(0.016); // 60 FPS

          // Check if confetti has reached half screen height on completion
          if (_isCompleted && !_showRestartButton && _confettiPhysics!.confettiBodies.isNotEmpty) {
            // Find the highest confetti piece (lowest Y value)
            double highestY = double.infinity;
            for (var confetti in _confettiPhysics!.confettiBodies) {
              if (confetti.position.dy < highestY) {
                highestY = confetti.position.dy;
              }
            }

            // Show button when confetti reaches halfway up the screen
            if (highestY < screenSize.height / 2) {
              _showRestartButton = true;
            }
          }
        });
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            _checkConfettiMilestones();
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
    WakelockPlus.disable();
    _stopMonitoring();
    _decibelReadings.clear();
    _longTermReadings.clear();
    _firstThresholdExceededTime = null;
    _lastWarningVibrationTime = null;
    _backgroundBlinkController.stop();
    _backgroundBlinkController.reset();

    // Pause confetti spawning but keep existing confetti
    _confettiSpawnTimer?.cancel();
    _physicsUpdateTimer?.cancel();
  }

  void _stopAndReset() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = widget.settings.timerDurationMinutes * 60;
      _reached25Percent = false;
      _reached50Percent = false;
      _reached75Percent = false;
      _reached90Percent = false;
      _showRestartButton = false;
    });
    _timer?.cancel();
    WakelockPlus.disable();
    _stopMonitoring();
    _decibelReadings.clear();
    _longTermReadings.clear();
    _firstThresholdExceededTime = null;
    _lastWarningVibrationTime = null;
    _backgroundBlinkController.stop();
    _backgroundBlinkController.reset();

    // Clear confetti
    _confettiSpawnTimer?.cancel();
    _physicsUpdateTimer?.cancel();
    _confettiPhysics?.dispose();
    _confettiPhysics = null;
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = widget.settings.timerDurationMinutes * 60;
      _reached25Percent = false;
      _reached50Percent = false;
      _reached75Percent = false;
      _reached90Percent = false;
      _showRestartButton = false;
    });
    _resetAnimationController.forward(from: 0.0);

    // Clear confetti on reset and restart spawning
    _confettiSpawnTimer?.cancel();
    _confettiPhysics?.dispose();
    final screenSize = MediaQuery.of(context).size;
    _confettiPhysics = ConfettiPhysicsWorld(screenSize: screenSize);
    _startConfettiSpawn(screenSize, particlesPerSpawn: 1, intervalMs: 1000);
  }

  void _checkConfettiMilestones() {
    if (_confettiPhysics == null || !_isRunning) return;

    final totalSeconds = widget.settings.timerDurationMinutes * 60;
    final elapsedSeconds = totalSeconds - _remainingSeconds;
    final percentComplete = (elapsedSeconds / totalSeconds);
    final screenSize = MediaQuery.of(context).size;

    // Scale spawn rates to timer duration
    // Target totals: ~50 by 25%, ~150 by 50%, ~350 by 75%, ~600 by 100%
    final quarterDuration = totalSeconds * 0.25;

    // 25% milestone
    if (percentComplete >= 0.25 && !_reached25Percent) {
      _reached25Percent = true;
      final intervalMs = (quarterDuration * 1000 / 100).round().clamp(200, 3000);
      _startConfettiSpawn(screenSize, particlesPerSpawn: 1, intervalMs: intervalMs);
    }

    // 50% milestone
    if (percentComplete >= 0.50 && !_reached50Percent) {
      _reached50Percent = true;
      final intervalMs = (quarterDuration * 1000 / 200).round().clamp(150, 2000);
      _startConfettiSpawn(screenSize, particlesPerSpawn: 1, intervalMs: intervalMs);
    }

    // 75% milestone
    if (percentComplete >= 0.75 && !_reached75Percent) {
      _reached75Percent = true;
      final intervalMs = (quarterDuration * 1000 / 250).round().clamp(100, 1000);
      _startConfettiSpawn(screenSize, particlesPerSpawn: 2, intervalMs: intervalMs);
    }

    // 90% milestone
    if (percentComplete >= 0.90 && !_reached90Percent) {
      _reached90Percent = true;
      final intervalMs = (totalSeconds * 0.10 * 1000 / 200).round().clamp(100, 500);
      _startConfettiSpawn(screenSize, particlesPerSpawn: 3, intervalMs: intervalMs);
    }
  }

  void _startConfettiSpawn(Size screenSize, {required int particlesPerSpawn, required int intervalMs}) {
    _confettiSpawnTimer?.cancel();

    // Spawn initial batch immediately
    if (_confettiPhysics != null && _confettiPhysics!.confettiBodies.length < 2000) {
      for (int i = 0; i < particlesPerSpawn; i++) {
        final random = Random();
        final x = random.nextDouble() * screenSize.width;
        final color = randomConfettiColor();
        final size = random.nextDouble() * 12 + 6;
        final shape = randomShape();

        _confettiPhysics!.addConfetti(
          Offset(x, -20),
          color,
          size,
          shape,
        );
      }
    }

    _confettiSpawnTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (_confettiPhysics == null || !mounted) {
        timer.cancel();
        return;
      }

      // Only spawn if we haven't hit the total limit
      if (_confettiPhysics!.confettiBodies.length < 2000) {
        for (int i = 0; i < particlesPerSpawn; i++) {
          final random = Random();
          final x = random.nextDouble() * screenSize.width;
          final color = randomConfettiColor();
          final size = random.nextDouble() * 12 + 6;
          final shape = randomShape();

          _confettiPhysics!.addConfetti(
            Offset(x, -20),
            color,
            size,
            shape,
          );
        }
      }
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    WakelockPlus.disable();
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
      _showRestartButton = false; // Hide button initially, show when confetti reaches half screen
    });

    // Physics world already exists from timer, just intensify confetti spawning
    final screenSize = MediaQuery.of(context).size;

    // Start the animation controller
    _celebrationController.repeat();

    // Big confetti burst for celebration (~50 particles per second)
    _confettiSpawnTimer?.cancel();
    _startConfettiSpawn(screenSize, particlesPerSpawn: 5, intervalMs: 100);

    _triggerHapticFeedback(intensity: 3);
  }

  void _restart() {
    _confettiSpawnTimer?.cancel();
    _physicsUpdateTimer?.cancel();
    _confettiPhysics?.dispose();
    _confettiPhysics = null;

    setState(() {
      _remainingSeconds = widget.settings.timerDurationMinutes * 60;
      _isCompleted = false;
      _isRunning = false;
      _reached25Percent = false;
      _reached50Percent = false;
      _reached75Percent = false;
      _reached90Percent = false;
      _showRestartButton = false;
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
        colors: [AppColors.iceBlue, AppColors.violet],
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
      // Fuchsia blink
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF1493).withValues(alpha: baseOpacity), // Fuchsia
          Color(0xFFFF1493).withValues(alpha: baseOpacity * 0.8),
        ],
      );
    } else if (_currentDecibels >= widget.settings.warningThreshold) {
      // Coral blink
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF7F50).withValues(alpha: baseOpacity), // Coral
          Color(0xFFFF7F50).withValues(alpha: baseOpacity * 0.8),
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

    if (!_hasPermission) {
      return Container(
        color: const Color(0xFFFDF6E3), // Solarized base3 (cream)
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(Icons.mic_off, size: 80, color: const Color(0xFF073642).withValues(alpha: 0.4)),
              const SizedBox(height: 24),
              Text(
                Strings.microphoneAccessRequired,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                Strings.microphoneAccessDescription,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.mic),
                label: Text(Strings.grantPermission),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, color: AppColors.violet),
                  label: Text(
                    Strings.privacyPolicy,
                    style: const TextStyle(
                      color: AppColors.violet,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
        return Container(
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(),
          ),
          child: Stack(
            children: [
              // Confetti behind everything
              if (_confettiPhysics != null && _isRunning)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ConfettiPhysicsPainter(
                        physicsWorld: _confettiPhysics!,
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      _buildTimerDisplay(),
                      const SizedBox(height: 40),
                      _buildDecibelMeter(),
                      const SizedBox(height: 24),
                      _buildControls(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerDisplay() {

    Color timerColor = const Color(0xFF073642); // Solarized base02 (dark blue-gray)
    if (_currentDecibels >= widget.settings.decibelThreshold) {
      timerColor = const Color(0xFFFF1493); // Fuchsia
    } else if (_currentDecibels >= widget.settings.warningThreshold) {
      // Gradient from coral to fuchsia based on how close to threshold
      final ratio = (_currentDecibels - widget.settings.warningThreshold) /
          (widget.settings.decibelThreshold - widget.settings.warningThreshold);
      timerColor = Color.lerp(
        const Color(0xFFFF7F50), // Coral
        const Color(0xFFFF1493), // Fuchsia
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
          ],
        );
      },
    );
  }

  Widget _buildDecibelMeter() {
    // Scale to threshold - bar fills completely when threshold is reached
    final percentage = (_currentDecibels / widget.settings.decibelThreshold).clamp(0.0, 1.0);
    final isWarning = _currentDecibels >= widget.settings.warningThreshold;
    final isOverThreshold = _currentDecibels >= widget.settings.decibelThreshold;

    Color meterColor = const Color(0xFF6C71C4); // Solarized violet
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
                    blockColor = const Color(0xFFFF1493); // Fuchsia (top 20%)
                  } else if (blockIndex >= totalBlocks * 0.6) {
                    blockColor = const Color(0xFFFF7F50); // Coral (60-80%)
                  } else {
                    blockColor = const Color(0xFFFDB813); // Yellow (bottom 60%)
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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          !_isRunning
              ? ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow, size: 32),
                  label: Text(Strings.start, style: const TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: _stopAndReset,
                  icon: const Icon(Icons.refresh, size: 32),
                  label: Text(Strings.reset, style: const TextStyle(fontSize: 20)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
          // Debug button to skip to end
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: _completeTimer,
              child: const Text('DEBUG: Skip to end'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6E3), // Solarized base3 (light cream)
      ),
      child: Stack(
        children: [
          // Confetti animation with physics
          if (_confettiPhysics != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ConfettiPhysicsPainter(
                        physicsWorld: _confettiPhysics!,
                      ),
                      child: Container(),
                    );
                  },
                ),
              ),
            ),
          // Restart button at bottom (shown when confetti reaches half screen)
          if (_showRestartButton)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: ElevatedButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh, size: 32),
                  label: Text(Strings.restart, style: const TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: const Color(0xFF6C71C4), // Solarized violet
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
