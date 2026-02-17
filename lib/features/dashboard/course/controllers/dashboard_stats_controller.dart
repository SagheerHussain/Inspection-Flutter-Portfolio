import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/services/api/api_service.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/inspection_statuses.dart';
import '../../../schedules/models/schedule_model.dart';

/// Central controller that loads ALL records once and exposes
/// per-status counts for the dashboard cards.
/// Also provides a live countdown to the nearest upcoming inspection.
class DashboardStatsController extends GetxController {
  static DashboardStatsController get instance => Get.find();

  final isLoading = false.obs;
  final allRecords = <ScheduleModel>[].obs;

  // Counts by inspectionStatus
  final scheduledCount = 0.obs;
  final runningCount = 0.obs;
  final reInspectionCount = 0.obs;
  final reScheduledCount = 0.obs;
  final inspectedCount = 0.obs;
  final canceledCount = 0.obs;

  // ── Countdown states ──
  final scheduledCountdownText = ''.obs;
  final scheduledCountdownDayLabel = ''.obs;
  final hasScheduledCountdown = false.obs;

  final reScheduledCountdownText = ''.obs;
  final reScheduledCountdownDayLabel = ''.obs;
  final hasReScheduledCountdown = false.obs;

  Timer? _countdownTimer;
  DateTime? _nextScheduledTime;
  DateTime? _nextReScheduledTime;

  @override
  void onInit() {
    fetchAllRecords();
    super.onInit();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchAllRecords() async {
    try {
      isLoading.value = true;
      final engineerNumber =
          GetStorage().read('INSPECTION_ENGINEER_NUMBER') ?? '9090909090';

      // Use constants from InspectionStatuses
      final statuses = [
        InspectionStatuses.scheduled,
        InspectionStatuses.running,
        InspectionStatuses.reScheduled,
        InspectionStatuses.reInspection,
        InspectionStatuses.inspected,
        InspectionStatuses.cancel,
      ];

      final Map<String, List<ScheduleModel>> results = {};

      // Fetch all statuses in parallel
      await Future.wait(
        statuses.map((status) async {
          try {
            final response = await ApiService.post(
              ApiConstants.inspectionEngineerSchedulesUrl,
              {
                "inspectionStatus": status,
                "inspectionEngineerNumber": engineerNumber,
              },
            );
            final List<dynamic> dataList = response['data'] ?? [];
            results[status] =
                dataList.map((json) => ScheduleModel.fromJson(json)).toList();
          } catch (e) {
            debugPrint('❌ Error fetching $status: $e');
            results[status] = [];
          }
        }),
      );

      // Combine all records for general use (like finding next inspection)
      final List<ScheduleModel> combined = [];
      results.values.forEach((list) => combined.addAll(list));

      allRecords.assignAll(combined);

      // Update individual counts using constants
      scheduledCount.value = results[InspectionStatuses.scheduled]?.length ?? 0;
      runningCount.value = results[InspectionStatuses.running]?.length ?? 0;
      reScheduledCount.value =
          results[InspectionStatuses.reScheduled]?.length ?? 0;
      reInspectionCount.value =
          results[InspectionStatuses.reInspection]?.length ?? 0;
      inspectedCount.value = results[InspectionStatuses.inspected]?.length ?? 0;
      canceledCount.value = results[InspectionStatuses.cancel]?.length ?? 0;

      _startCountdown();
    } catch (e) {
      debugPrint('❌ Dashboard stats fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Countdown Logic ──

  void _startCountdown() {
    _countdownTimer?.cancel();
    _findNextInspections();

    _updateAllCountdownDisplays();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      bool searchNeeded = false;

      if (_nextScheduledTime != null && now.isAfter(_nextScheduledTime!)) {
        searchNeeded = true;
      }
      if (_nextReScheduledTime != null && now.isAfter(_nextReScheduledTime!)) {
        searchNeeded = true;
      }

      if (searchNeeded) {
        _findNextInspections();
      }
      _updateAllCountdownDisplays();
    });
  }

  /// Scans records to find next inspection for Scheduled and Re-Scheduled specifically
  void _findNextInspections() {
    final now = DateTime.now();
    DateTime? nextSched;
    DateTime? nextReSched;

    for (final record in allRecords) {
      final dt = record.inspectionDateTime;
      if (dt == null) continue;
      final localDt = dt.toLocal();
      if (localDt.isBefore(now)) continue;

      if (record.inspectionStatus == InspectionStatuses.scheduled) {
        if (nextSched == null || localDt.isBefore(nextSched)) {
          nextSched = localDt;
        }
      } else if (record.inspectionStatus == InspectionStatuses.reScheduled) {
        if (nextReSched == null || localDt.isBefore(nextReSched)) {
          nextReSched = localDt;
        }
      }
    }

    _nextScheduledTime = nextSched;
    _nextReScheduledTime = nextReSched;

    hasScheduledCountdown.value = _nextScheduledTime != null;
    hasReScheduledCountdown.value = _nextReScheduledTime != null;
  }

  void _updateAllCountdownDisplays() {
    final now = DateTime.now();

    // Update Scheduled
    if (_nextScheduledTime != null) {
      final diff = _nextScheduledTime!.difference(now);
      if (diff.isNegative) {
        scheduledCountdownText.value = '00:00:00';
      } else {
        scheduledCountdownText.value = _formatDuration(diff);
        scheduledCountdownDayLabel.value = _getDayLabel(_nextScheduledTime!);
      }
    }

    // Update Re-Scheduled
    if (_nextReScheduledTime != null) {
      final diff = _nextReScheduledTime!.difference(now);
      if (diff.isNegative) {
        reScheduledCountdownText.value = '00:00:00';
      } else {
        reScheduledCountdownText.value = _formatDuration(diff);
        reScheduledCountdownDayLabel.value = _getDayLabel(
          _nextReScheduledTime!,
        );
      }
    }
  }

  String _formatDuration(Duration diff) {
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns "Today", "Tomorrow", or the weekday name.
  String _getDayLabel(DateTime target) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(target.year, target.month, target.day);
    final diff = targetDay.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[target.weekday - 1];
  }

  Future<void> refresh() async => await fetchAllRecords();
}
