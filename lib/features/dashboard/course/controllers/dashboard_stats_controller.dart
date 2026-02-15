import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/api/api_service.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../schedules/models/schedule_model.dart';

/// Central controller that loads ALL records once and exposes
/// per-status counts for the dashboard cards.
class DashboardStatsController extends GetxController {
  static DashboardStatsController get instance => Get.find();

  final isLoading = false.obs;
  final allRecords = <ScheduleModel>[].obs;

  // Counts by inspectionStatus
  final scheduledCount = 0.obs;
  final runningCount = 0.obs;
  final reInspectionCount = 0.obs;
  final inspectedCount = 0.obs;
  final canceledCount = 0.obs;

  @override
  void onInit() {
    fetchAllRecords();
    super.onInit();
  }

  Future<void> fetchAllRecords() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        ApiConstants.schedulesAggregationUrl,
      );
      final List<dynamic> dataList = response['data'] ?? [];
      final records =
          dataList.map((json) => ScheduleModel.fromJson(json)).toList();

      allRecords.assignAll(records);
      _computeCounts();
    } catch (e) {
      debugPrint('❌ Dashboard stats fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _computeCounts() {
    int scheduled = 0,
        running = 0,
        reInspection = 0,
        inspected = 0,
        canceled = 0;

    for (final record in allRecords) {
      switch (record.inspectionStatus.toLowerCase()) {
        case 'scheduled':
          scheduled++;
          break;
        case 'running':
          running++;
          break;
        case 're-inspection':
          reInspection++;
          break;
        case 'inspected':
          inspected++;
          break;
        case 'canceled':
        case 'cancelled':
          canceled++;
          break;
        // Pending and other statuses are ignored
      }
    }

    scheduledCount.value = scheduled;
    runningCount.value = running;
    reInspectionCount.value = reInspection;
    inspectedCount.value = inspected;
    canceledCount.value = canceled;
  }

  Future<void> refresh() async => await fetchAllRecords();
}
