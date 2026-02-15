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
                    // Top Row: Icon (Top Right)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
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
