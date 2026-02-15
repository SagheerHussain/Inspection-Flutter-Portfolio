import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../course/controllers/dashboard_stats_controller.dart';
import '../../../../../schedules/screens/schedules_screen.dart';

class DashboardBanners extends StatelessWidget {
  const DashboardBanners({super.key, required this.txtTheme});

  final TextTheme txtTheme;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final stats = DashboardStatsController.instance;

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1st Banner: Schedules
          Expanded(
            child: GestureDetector(
              onTap:
                  () => Get.to(
                    () => const SchedulesScreen(statusFilter: 'SCHEDULED'),
                  ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        dark
                            ? [const Color(0xFF0D1B2E), const Color(0xFF162D4A)]
                            : [
                              const Color(0xFFD6E8FA),
                              const Color(0xFFB8D4F0),
                            ],
                  ),
                  boxShadow: [],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Row: Countdown (left) + Icon (right) ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Countdown Timer Label
                        Expanded(
                          child: Obx(() {
                            if (!stats.hasCountdown.value) {
                              return const SizedBox.shrink();
                            }
                            return _CountdownPill(
                              time: stats.countdownText.value,
                              dayLabel: stats.countdownDayLabel.value,
                              dark: dark,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A90D9,
                            ).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFF4A90D9),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Center: Animated Counter
                    Center(
                      child: Obx(
                        () => _AnimatedCounter(
                          value: stats.scheduledCount.value,
                          style:
                              txtTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 64,
                                height: 1.0,
                                color: const Color(0xFF4A90D9),
                              ) ??
                              const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4A90D9),
                              ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Bottom: Title
                    Text(
                      "Schedules",
                      style: txtTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2nd Banner: Running
          Expanded(
            child: GestureDetector(
              onTap:
                  () => Get.to(
                    () => const SchedulesScreen(statusFilter: 'RUNNING'),
                  ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        dark
                            ? [const Color(0xFF2A1510), const Color(0xFF3D2218)]
                            : [
                              const Color(0xFFFFE0CC),
                              const Color(0xFFFFCDB2),
                            ],
                  ),
                  boxShadow: [],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Icon (Top Right)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFF6B35,
                          ).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Color(0xFFFF6B35),
                          size: 30,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Center: Animated Counter
                    Center(
                      child: Obx(
                        () => _AnimatedCounter(
                          value: stats.runningCount.value,
                          style:
                              txtTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 64,
                                height: 1.0,
                                color: const Color(0xFFFF6B35),
                              ) ??
                              const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF6B35),
                              ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Bottom: Title
                    Text(
                      "Running",
                      style: txtTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Countdown Pill ──
/// A small, premium countdown label with a pulsing dot indicator.
class _CountdownPill extends StatefulWidget {
  final String time;
  final String dayLabel;
  final bool dark;

  const _CountdownPill({
    required this.time,
    required this.dayLabel,
    required this.dark,
  });

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color:
            widget.dark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4A90D9).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Next inspection" label with pulsing dot
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(
                        0xFF4A90D9,
                      ).withValues(alpha: _pulseAnimation.value),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF4A90D9,
                          ).withValues(alpha: _pulseAnimation.value * 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 5),
              Text(
                'Next inspection',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.dark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.5),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          // Timer value
          Text(
            widget.time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A90D9),
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 0.5,
            ),
          ),
          // Day label
          Text(
            widget.dayLabel,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color:
                  widget.dark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.4),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated counter that counts up from 0 to the target value
class _AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle style;

  const _AnimatedCounter({required this.value, required this.style});

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value.toInt()}', style: widget.style);
      },
    );
  }
}
