import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/constants/inspection_statuses.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../course/controllers/dashboard_stats_controller.dart';
import '../../../../../schedules/screens/schedules_screen.dart';

class DashboardTopCourses extends StatelessWidget {
  const DashboardTopCourses({super.key, required this.txtTheme});

  final TextTheme txtTheme;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final stats = DashboardStatsController.instance;

    final quickLinks = [
      _QuickLinkItem(
        title: "Re-Schedule",
        countObs: stats.reScheduledCount,
        icon: Icons.event_repeat_rounded,
        iconColor: const Color(0xFF7C4DFF),
        statusFilter: InspectionStatuses.reScheduled,
        gradientColors:
            dark
                ? [const Color(0xFF12103A), const Color(0xFF1E1A50)]
                : [
                  const Color.fromARGB(255, 175, 149, 253),
                  const Color.fromARGB(255, 185, 169, 252),
                ],
        hasTimerObs: stats.hasReScheduledCountdown,
        timerTextObs: stats.reScheduledCountdownText,
        dayLabelObs: stats.reScheduledCountdownDayLabel,
      ),
      _QuickLinkItem(
        title: "Re-Inspected",
        countObs: stats.reInspectionCount,
        icon: Icons.replay_circle_filled_rounded,
        iconColor: const Color(0xFF00BFA5),
        statusFilter: InspectionStatuses.reInspection,
        gradientColors:
            dark
                ? [const Color(0xFF0A2028), const Color(0xFF103038)]
                : [const Color(0xFFB2DFDB), const Color(0xFF80CBC4)],
      ),
      _QuickLinkItem(
        title: "Inspected",
        countObs: stats.inspectedCount,
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF4CAF50),
        statusFilter: InspectionStatuses.inspected,
        gradientColors:
            dark
                ? [const Color(0xFF0D200F), const Color(0xFF15301A)]
                : [const Color(0xFFC8E6C9), const Color(0xFFA5D6A7)],
      ),
      _QuickLinkItem(
        title: "Canceled",
        countObs: stats.canceledCount,
        icon: Icons.cancel_rounded,
        iconColor: const Color(0xFFF44336),
        statusFilter: InspectionStatuses.cancel,
        gradientColors:
            dark
                ? [const Color(0xFF2A0F0F), const Color(0xFF3A1515)]
                : [const Color(0xFFFFCDD2), const Color(0xFFEF9A9A)],
      ),
    ];

    return SizedBox(
      height: 170,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: quickLinks.length,
        itemBuilder: (context, index) {
          final item = quickLinks[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 4),
            child: GestureDetector(
              onTap:
                  () => Get.to(
                    () => SchedulesScreen(statusFilter: item.statusFilter),
                  ),
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradientColors,
                  ),
                  boxShadow: [],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Timer (left) + Icon (right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.hasTimerObs != null)
                          Obx(() {
                            if (!item.hasTimerObs!.value)
                              return const SizedBox.shrink();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.dayLabelObs != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.dayLabelObs!.value.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.timerTextObs?.value ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Center: Animated Counter
                    Center(
                      child: Obx(
                        () => _AnimatedCounter(
                          value: item.countObs.value,
                          style:
                              txtTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: item.iconColor,
                                fontSize: 48,
                                height: 1.0,
                              ) ??
                              TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: item.iconColor,
                              ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Bottom: Title
                    Text(
                      item.title,
                      style: txtTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

class _QuickLinkItem {
  final String title;
  final RxInt countObs;
  final IconData icon;
  final Color iconColor;
  final String statusFilter;
  final List<Color> gradientColors;
  final RxBool? hasTimerObs;
  final RxString? timerTextObs;
  final RxString? dayLabelObs;

  _QuickLinkItem({
    required this.title,
    required this.countObs,
    required this.icon,
    required this.iconColor,
    required this.statusFilter,
    required this.gradientColors,
    this.hasTimerObs,
    this.timerTextObs,
    this.dayLabelObs,
  });
}
