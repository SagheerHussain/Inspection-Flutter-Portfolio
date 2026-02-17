import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/constants/inspection_statuses.dart';
import '../../../utils/popups/loaders.dart';
import '../../car_details/screens/car_details_screen.dart';
import '../../inspection_form/screens/inspection_form_screen.dart';
import '../controllers/schedule_controller.dart';
import '../models/schedule_model.dart';

class SchedulesScreen extends StatelessWidget {
  final String statusFilter;
  final String searchQuery;

  const SchedulesScreen({
    super.key,
    this.statusFilter = 'SCHEDULED',
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    // Use a unique tag so each status filter (or search) gets its own controller
    final tag =
        searchQuery.isNotEmpty ? 'search_results' : 'schedule_$statusFilter';
    final controller = Get.put(
      ScheduleController(statusFilter: statusFilter, searchQuery: searchQuery),
      tag: tag,
    );
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A0E21) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.screenTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Obx(
              () => Text(
                '${controller.schedules.length} ${controller.screenSubtitle}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: dark ? TColors.secondary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => controller.refreshSchedules(),
              icon: const Icon(Icons.refresh_rounded, size: 22),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: TColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading records...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (controller.schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _emptyIcon(statusFilter),
                  size: 64,
                  color: Colors.grey.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${controller.screenTitle.toLowerCase()} found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pull down to refresh',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: TColors.primary,
          onRefresh: controller.refreshSchedules,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                controller.fetchSchedules(loadMore: true);
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount:
                  controller.schedules.length +
                  (controller.hasMoreData.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.schedules.length) {
                  return Obx(
                    () =>
                        controller.isLoadingMore.value
                            ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: TColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                  );
                }
                return _ScheduleCard(
                  schedule: controller.schedules[index],
                  dark: dark,
                  controller: controller,
                );
              },
            ),
          ),
        );
      }),
    );
  }

  IconData _emptyIcon(String status) {
    if (status == InspectionStatuses.running)
      return Icons.play_circle_outline_rounded;
    if (status == InspectionStatuses.reInspection)
      return Icons.replay_circle_filled_rounded;
    if (status == InspectionStatuses.inspected)
      return Icons.check_circle_outline_rounded;
    if (status == InspectionStatuses.cancel) return Icons.cancel_outlined;
    return Icons.calendar_today_rounded;
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool dark;
  final ScheduleController controller;

  const _ScheduleCard({
    required this.schedule,
    required this.dark,
    required this.controller,
  });

  Color _statusColor(String status) {
    if (status == InspectionStatuses.inspected ||
        status == 'Completed' ||
        status == 'Approved')
      return const Color(0xFF4CAF50);
    if (status == InspectionStatuses.running) return const Color(0xFFFF9800);
    if (status == InspectionStatuses.scheduled) return const Color(0xFF2196F3);
    if (status == InspectionStatuses.reScheduled)
      return const Color(0xFF673AB7);
    if (status == InspectionStatuses.reInspection)
      return const Color(0xFF00BFA5);
    if (status == InspectionStatuses.cancel) return const Color(0xFFF44336);
    return const Color(0xFF9E9E9E);
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFF44336);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'low':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(schedule.inspectionStatus);

    return GestureDetector(
      onTap:
          () => Get.to(
            () => CarDetailsScreen(appointmentId: schedule.appointmentId),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1A1F36) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  dark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top Header Bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: dark ? 0.30 : 0.18),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tag, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          schedule.appointmentId,
                          style: txtTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // City Badge
                  if (schedule.city.isNotEmpty)
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_city,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                schedule.city,
                                style: txtTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Status Badge
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              schedule.inspectionStatus,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card Body ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Registration + Priority
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_car,
                                size: 16,
                                color: TColors.dark,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  schedule.carRegistrationNumber,
                                  style: txtTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _priorityColor(
                              schedule.priority,
                            ).withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          schedule.priority,
                          style: TextStyle(
                            color: _priorityColor(schedule.priority),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Owner Name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(
                          0xFF7C4DFF,
                        ).withValues(alpha: 0.1),
                        child: Text(
                          schedule.ownerName.isNotEmpty
                              ? schedule.ownerName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Color(0xFF7C4DFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.ownerName,
                              style: txtTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 13,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  schedule.customerContactNumber.isNotEmpty
                                      ? schedule.customerContactNumber
                                      : 'No phone number',
                                  style: txtTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Car Details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          dark
                              ? Colors.white.withValues(alpha: 0.04)
                              : const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.branding_watermark_rounded,
                          'Make',
                          schedule.make,
                          txtTheme,
                        ),
                        const SizedBox(height: 6),
                        _infoRow(
                          Icons.model_training_rounded,
                          'Model',
                          schedule.model,
                          txtTheme,
                        ),
                        if (schedule.variant.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _infoRow(
                            Icons.tune_rounded,
                            'Variant',
                            schedule.variant,
                            txtTheme,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Inspection Date & Time
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(
                            0xFF4A90D9,
                          ).withValues(alpha: dark ? 0.15 : 0.08),
                          const Color(
                            0xFF4A90D9,
                          ).withValues(alpha: dark ? 0.05 : 0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A90D9,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            color: Color(0xFF4A90D9),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inspection Date & Time',
                              style: txtTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              schedule.formattedInspectionDate,
                              style: txtTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4A90D9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Inspection Address with Directions
                  if (schedule.inspectionAddress.isNotEmpty)
                    GestureDetector(
                      onTap: () => _openDirections(schedule.inspectionAddress),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: dark ? 0.15 : 0.08),
                              const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: dark ? 0.05 : 0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tap for directions',
                                    style: txtTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF4CAF50),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    schedule.inspectionAddress,
                                    style: txtTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.directions_rounded,
                                color: Color(0xFF4CAF50),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Bottom Action Bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    dark
                        ? Colors.white.withValues(alpha: 0.03)
                        : const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Left Group: Workflow Actions ──
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildLeftActions(context, controller),
                    ),
                  ),
                  // ── Right Group: Call & SMS ──
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildRightActions(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Left-aligned workflow actions: Start/Resume, Re-Schedule, Cancel, Show Details, Notes
  List<Widget> _buildLeftActions(
    BuildContext context,
    ScheduleController controller,
  ) {
    final status = schedule.inspectionStatus;
    final List<Widget> items = [];

    final isScheduled = status == InspectionStatuses.scheduled;
    final isRescheduled = status == InspectionStatuses.reScheduled;
    final isRunning = status == InspectionStatuses.running;

    if (isScheduled || isRescheduled || isRunning) {
      // Primary Action (Play / Resume)
      items.add(
        _actionIcon(
          icon:
              isRunning
                  ? Icons.play_arrow_rounded
                  : Icons.play_circle_filled_rounded,
          color: const Color(0xFF4CAF50),
          tooltip: isRunning ? 'Resume Inspection' : 'Start Inspection',
          onTap: () async {
            if (isScheduled || isRescheduled) {
              // Switch to Running via API as requested
              try {
                // Keep existing values as requested
                await controller.updateTelecallingStatus(
                  telecallingId: schedule.id,
                  status: InspectionStatuses.running,
                  dateTime: schedule.inspectionDateTime?.toIso8601String(),
                  remarks: schedule.remarks,
                );
              } catch (e) {
                // Error handled in controller
                return;
              }
            }

            Get.to(
              () => InspectionFormScreen(
                appointmentId: schedule.appointmentId,
                schedule: schedule,
              ),
            );
          },
        ),
      );
      items.add(const SizedBox(width: 12));

      // Re-Schedule
      items.add(
        _actionIcon(
          icon: Icons.event_repeat_rounded,
          color: const Color(0xFFFF9800),
          tooltip: 'Re-Schedule',
          onTap: () => _showRescheduleFlow(context, controller),
        ),
      );
      items.add(const SizedBox(width: 12));

      // Cancel
      items.add(
        _actionIcon(
          icon: Icons.cancel_rounded,
          color: const Color(0xFFF44336),
          tooltip: 'Cancel',
          onTap: () => _showCancelDialog(context, controller),
        ),
      );
    } else if (status == InspectionStatuses.inspected ||
        status == 'Completed' ||
        status == 'Approved' ||
        status == InspectionStatuses.reInspection) {
      // Show Details button
      items.add(
        InkWell(
          onTap:
              () => Get.to(
                () => CarDetailsScreen(appointmentId: schedule.appointmentId),
              ),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TColors.primary.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_rounded,
                  size: 14,
                  color: TColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'View Details',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // Canceled → no workflow buttons

    // Notes (left group, after workflow actions)
    if (schedule.additionalNotes.isNotEmpty) {
      if (items.isNotEmpty) items.add(const SizedBox(width: 12));
      items.add(
        _actionIcon(
          icon: Icons.sticky_note_2_outlined,
          color: const Color(0xFFFF9800),
          tooltip: 'Notes',
          onTap: () => _showNotesDialog(context, schedule.additionalNotes),
        ),
      );
    }

    return items;
  }

  /// Right-aligned communication actions: Call & SMS
  List<Widget> _buildRightActions() {
    final List<Widget> items = [];

    // Call
    if (schedule.customerContactNumber.isNotEmpty) {
      items.add(
        _actionIcon(
          icon: Icons.phone_outlined,
          color: const Color(0xFF4CAF50),
          tooltip: 'Call',
          onTap: () => _makeCall(schedule.customerContactNumber),
        ),
      );
      items.add(const SizedBox(width: 12));
    }

    // SMS
    items.add(
      _actionIcon(
        icon: Icons.sms_rounded,
        color: const Color(0xFF2196F3),
        tooltip: 'SMS',
        onTap: () async {
          if (schedule.customerContactNumber.isNotEmpty) {
            final uri = Uri.parse('sms:${schedule.customerContactNumber}');
            if (await canLaunchUrl(uri)) launchUrl(uri);
          }
        },
      ),
    );

    return items;
  }

  void _showCancelDialog(BuildContext context, ScheduleController controller) {
    final reasonController = TextEditingController();
    final dark = THelperFunctions.isDarkMode(context);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_rounded, color: Colors.red),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Inspection',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Appointment ID: ${schedule.appointmentId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Reason for cancellation',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 4,
                style: TextStyle(color: dark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Tell us why you are canceling...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor:
                      dark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Keep it',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (reasonController.text.trim().isEmpty) {
                          TLoaders.warningSnackBar(
                            title: 'Reason Required',
                            message: 'Please provide a reason for cancellation',
                          );
                          return;
                        }
                        Get.back();
                        controller.updateTelecallingStatus(
                          telecallingId: schedule.id,
                          status: InspectionStatuses.cancel,
                          remarks: reasonController.text.trim(),
                        );
                      },
                      child: const Text(
                        'Confirm Cancel',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRescheduleFlow(
    BuildContext context,
    ScheduleController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9800),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final String isoDate = selectedDateTime.toIso8601String();

    if (!context.mounted) return;
    _showRescheduleReasonDialog(context, controller, isoDate);
  }

  void _showRescheduleReasonDialog(
    BuildContext context,
    ScheduleController controller,
    String isoDate,
  ) {
    final reasonController = TextEditingController();
    final dark = THelperFunctions.isDarkMode(context);
    final dt = DateTime.parse(isoDate);
    final displayDate = '${dt.day} ${_getMonthName(dt.month)} ${dt.year}';
    final displayTime =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_repeat_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reschedule Lead',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'ID: ${schedule.appointmentId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      dark
                          ? Colors.orange.withValues(alpha: 0.05)
                          : Colors.orange.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'NEW INSPECTION TIME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange.shade700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          displayDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          displayTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reason for rescheduling',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 4,
                style: TextStyle(color: dark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter reason here...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor:
                      dark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        _showRescheduleFlow(context, controller);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Change Date',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (reasonController.text.trim().isEmpty) {
                          TLoaders.warningSnackBar(
                            title: 'Reason Required',
                            message: 'Please provide a reason for rescheduling',
                          );
                          return;
                        }
                        Get.back();
                        controller.updateTelecallingStatus(
                          telecallingId: schedule.id,
                          status: InspectionStatuses.reScheduled,
                          dateTime: isoDate,
                          remarks: reasonController.text.trim(),
                        );
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    TextTheme txtTheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: txtTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: txtTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showNotesDialog(BuildContext context, String notes) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.sticky_note_2_outlined, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text('Additional Notes'),
              ],
            ),
            content: Text(notes),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  /// Opens Google Maps with directions FROM device's current location TO the inspection address
  Future<void> _openDirections(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    // Using Google Maps Directions API with origin=My+Location (uses device GPS)
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$encodedAddress&travelmode=driving';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Makes a phone call to the given number
  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
