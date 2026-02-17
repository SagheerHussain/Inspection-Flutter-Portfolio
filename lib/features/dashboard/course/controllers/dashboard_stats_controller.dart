import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/services/api/api_service.dart';
import '../../../../utils/constants/api_constants.dart';
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

  // ── Countdown state ──
  /// The formatted countdown string: "HH:MM:SS"
  final countdownText = ''.obs;

  /// The day label: "Today", "Tomorrow", or weekday name
  final countdownDayLabel = ''.obs;

  /// Whether a valid countdown is currently active
  final hasCountdown = false.obs;

  Timer? _countdownTimer;
  DateTime? _nextInspectionTime;

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

      // Define statuses to fetch for dashboard stats
      final statuses = [
        'Scheduled',
        'Running',
        'Re-Scheduled',
        'Re-Inspection',
        'Inspected',
        'Canceled',
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

      // Update individual counts
      scheduledCount.value = results['Scheduled']?.length ?? 0;
      runningCount.value = results['Running']?.length ?? 0;
      reScheduledCount.value = results['Re-Scheduled']?.length ?? 0;
      reInspectionCount.value = results['Re-Inspection']?.length ?? 0;
      inspectedCount.value = results['Inspected']?.length ?? 0;
      canceledCount.value = results['Canceled']?.length ?? 0;

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
    _findNextInspection();

    if (_nextInspectionTime == null) {
      hasCountdown.value = false;
      countdownText.value = '';
      countdownDayLabel.value = '';
      return;
    }

    hasCountdown.value = true;
    _updateCountdownDisplay();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (_nextInspectionTime == null || now.isAfter(_nextInspectionTime!)) {
        _findNextInspection();
        if (_nextInspectionTime == null) {
          hasCountdown.value = false;
          countdownText.value = '';
          countdownDayLabel.value = '';
          _countdownTimer?.cancel();
          return;
        }
      }
      _updateCountdownDisplay();
    });
  }

  /// Scans all records and picks the closest FUTURE inspectionDateTime only.
  void _findNextInspection() {
    final now = DateTime.now();
    DateTime? nearest;

    for (final record in allRecords) {
      final dt = record.inspectionDateTime;
      if (dt == null) continue;
      final localDt = dt.toLocal();
      if (localDt.isAfter(now)) {
        if (nearest == null || localDt.isBefore(nearest)) {
          nearest = localDt;
        }
      }
    }

    _nextInspectionTime = nearest;
  }

  void _updateCountdownDisplay() {
    if (_nextInspectionTime == null) return;

    final now = DateTime.now();
    final diff = _nextInspectionTime!.difference(now);

    if (diff.isNegative) return;

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);

    countdownText.value =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    countdownDayLabel.value = _getDayLabel(_nextInspectionTime!);
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
