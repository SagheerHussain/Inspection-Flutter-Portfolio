import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api/api_service.dart';
import '../../../utils/constants/api_constants.dart';
import '../models/schedule_model.dart';

class ScheduleController extends GetxController {
  static ScheduleController get instance => Get.find();

  final String statusFilter;
  final String searchQuery;

  ScheduleController({this.statusFilter = 'SCHEDULED', this.searchQuery = ''});

  final schedules = <ScheduleModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final currentPage =
      1.obs; // Kept for compatibility, though pagination is now local
  final hasMoreData = true.obs;
  final int pageLimit = 10; // Increased limit for better UX

  // Local pagination storage
  List<ScheduleModel> _allFilteredRecords = [];
  int _currentIndex = 0;

  @override
  void onInit() {
    fetchSchedules();
    super.onInit();
  }

  /// Fetch all schedules from API (one huge batch), filter locally,
  /// then paginate the display locally via loadMore.
  Future<void> fetchSchedules({bool loadMore = false}) async {
    try {
      // LOCAL PAGINATION (Load More)
      if (loadMore) {
        if (!hasMoreData.value || isLoadingMore.value) return;
        isLoadingMore.value = true;

        // Simulate a tiny delay for UX (optional) or just load instantly
        // Picking next batch from local list
        final nextBatch =
            _allFilteredRecords.skip(_currentIndex).take(pageLimit).toList();

        if (nextBatch.isNotEmpty) {
          schedules.addAll(nextBatch);
          _currentIndex += nextBatch.length;
        }

        if (_currentIndex >= _allFilteredRecords.length) {
          hasMoreData.value = false;
        }

        isLoadingMore.value = false;
        return;
      }

      // INITIAL LOAD: Fetch All from Server
      isLoading.value = true;
      schedules.clear();
      _allFilteredRecords.clear();
      _currentIndex = 0;
      hasMoreData.value = true;

      // Use aggregation URL to fetch ALL records (limit=1000)
      final response = await ApiService.get(
        ApiConstants.schedulesAggregationUrl,
      );
      final List<dynamic> dataList = response['data'] ?? [];
      final allRecords =
          dataList.map((json) => ScheduleModel.fromJson(json)).toList();

      // Apply Filters Locally
      if (searchQuery.isNotEmpty) {
        // SEARCH MODE
        final query = searchQuery.toLowerCase();
        _allFilteredRecords =
            allRecords.where((record) {
              final idMatch = record.appointmentId
                  .toString()
                  .toLowerCase()
                  .contains(query);
              final phoneMatch = record.customerContactNumber
                  .toString()
                  .toLowerCase()
                  .contains(query);
              return idMatch || phoneMatch;
            }).toList();
      } else {
        // STATUS MODE
        _allFilteredRecords =
            allRecords.where((record) {
              // Exclude 'Pending' unless specific requirement
              if (record.inspectionStatus.toLowerCase() == 'pending')
                return false;
              return record.inspectionStatus.toLowerCase() ==
                  statusFilter.toLowerCase();
            }).toList();
      }

      // Initial Display Batch
      final firstBatch = _allFilteredRecords.take(pageLimit).toList();
      schedules.assignAll(firstBatch);
      _currentIndex = firstBatch.length;

      if (_currentIndex >= _allFilteredRecords.length) {
        hasMoreData.value = false;
      }
    } catch (e) {
      debugPrint('❌ Error fetching schedules: $e');
      if (!loadMore) {
        Get.snackbar(
          'Error',
          'Failed to load records: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Refresh schedules
  Future<void> refreshSchedules() async {
    hasMoreData.value = true;
    await fetchSchedules();
  }

  /// Get display title based on status filter
  String get screenTitle {
    if (searchQuery.isNotEmpty) return 'Search Results';
    switch (statusFilter.toLowerCase()) {
      case 'scheduled':
        return 'Schedules';
      case 'running':
        return 'Running Inspections';
      case 're-inspection':
        return 'Re-Inspections';
      case 'inspected':
        return 'Inspected';
      case 'canceled':
        return 'Canceled';
      default:
        return 'Records';
    }
  }

  /// Get subtitle
  String get screenSubtitle {
    if (searchQuery.isNotEmpty) return 'matches found';
    switch (statusFilter.toLowerCase()) {
      case 'scheduled':
        return 'inspection leads';
      case 'running':
        return 'active inspections';
      case 're-inspection':
        return 're-inspection records';
      case 'inspected':
        return 'completed inspections';
      case 'canceled':
        return 'canceled records';
      default:
        return 'records';
    }
  }
}
