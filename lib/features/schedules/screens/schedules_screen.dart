import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
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
                );
              },
            ),
          ),
        );
      }),
    );
  }

  IconData _emptyIcon(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Icons.play_circle_outline_rounded;
      case 're-inspection':
        return Icons.replay_circle_filled_rounded;
      case 'inspected':
        return Icons.check_circle_outline_rounded;
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.calendar_today_rounded;
    }
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool dark;

  const _ScheduleCard({required this.schedule, required this.dark});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'inspected':
      case 'completed':
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'running':
        return const Color(0xFFFF9800);
      case 'scheduled':
        return const Color(0xFF2196F3);
      case 're-inspection':
        return const Color(0xFF00BFA5);
      case 'canceled':
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
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
                  Flexible(
                    child: Container(
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
                          Flexible(
                            child: Text(
                              schedule.appointmentId,
                              style: txtTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
                      children: _buildLeftActions(context),
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
  List<Widget> _buildLeftActions(BuildContext context) {
    final status = schedule.inspectionStatus.toLowerCase();
    final List<Widget> items = [];

    if (status == 'scheduled' || status == 'running') {
      // Primary Action (Ready / Resume)
      items.add(
        _actionIcon(
          icon:
              status == 'running'
                  ? Icons.play_arrow_rounded
                  : Icons.play_circle_filled_rounded,
          color: const Color(0xFF4CAF50),
          tooltip:
              status == 'running' ? 'Resume Inspection' : 'Start Inspection',
          onTap:
              () => Get.to(
                () => InspectionFormScreen(
                  appointmentId: schedule.appointmentId,
                  schedule: schedule,
                ),
              ),
        ),
      );
      items.add(const SizedBox(width: 12));

      // Re-Schedule
      items.add(
        _actionIcon(
          icon: Icons.event_repeat_rounded,
          color: const Color(0xFFFF9800),
          tooltip: 'Re-Schedule',
          onTap: () {
            Get.snackbar(
              'Re-Schedule',
              'Coming soon...',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      );
      items.add(const SizedBox(width: 12));

      // Cancel
      items.add(
        _actionIcon(
          icon: Icons.cancel_rounded,
          color: const Color(0xFFF44336),
          tooltip: 'Cancel',
          onTap: () {
            Get.snackbar(
              'Cancel',
              'Coming soon...',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      );
    } else if (status == 'inspected' ||
        status == 'completed' ||
        status == 'approved') {
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: TColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Show Details',
                  style: TextStyle(
                    color: TColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
