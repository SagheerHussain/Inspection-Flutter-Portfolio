import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api/api_service.dart';
import '../../../utils/constants/api_constants.dart';
import '../models/inspection_form_model.dart';
import '../../schedules/models/schedule_model.dart';

class InspectionFormController extends GetxController {
  final String appointmentId;
  final ScheduleModel? schedule;

  InspectionFormController({required this.appointmentId, this.schedule});

  final Rxn<InspectionFormModel> inspectionData = Rxn<InspectionFormModel>();
  final isLoading = true.obs;

  // Tabs / Sections
  final currentSectionIndex = 0.obs;
  final pageController = PageController();

  final List<String> sections = [
    'Vehicle Info',
    'Documents',
    'Exterior',
    'Engine',
    'Interior',
    'Tires & Others',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchInspectionData();
  }

  Future<void> fetchInspectionData() async {
    isLoading.value = true;
    try {
      // Try fetching existing details
      final response = await ApiService.get(
        ApiConstants.carDetailsUrl(appointmentId),
      );

      if (response != null && response['carDetails'] != null) {
        inspectionData.value = InspectionFormModel.fromJson(
          response['carDetails'],
        );
      } else {
        _initializeNewInspection();
      }
    } catch (e) {
      // If fetch fails (e.g. 404 Not Found), start a new inspection
      print('Fetch failed, initializing new inspection: $e');
      _initializeNewInspection();
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeNewInspection() {
    // initialize defaults even if schedule is null
    final regNumber = schedule?.carRegistrationNumber ?? '';
    final make = schedule?.make ?? '';
    final model = schedule?.model ?? '';
    final variant = schedule?.variant ?? '';

    // Create a blank model populated with defaults
    inspectionData.value = InspectionFormModel(
      id: '',
      appointmentId: appointmentId,
      make: make,
      model: model,
      variant: variant,
      status: 'Pending',
      data: {
        'registrationNumber': regNumber,
        'yearMonthOfManufacture': schedule?.yearOfManufacture,
        'odometerReadingInKms': schedule?.odometerReadingInKms,
        'customerName': schedule?.ownerName,
        'customerPhone': schedule?.customerContactNumber,
        // Initialize fields with empty strings or reasonable defaults
        'bonnet': 'Original',
        'roof': 'Original',
        'engine': 'Okay',
        'comments': '',
        'insurance': 'Comprehensive',
        'rcBookAvailability': 'Original',
        'transmissionTypeDropdownList': 'Manual',
        'fuelType': 'Petrol',
      },
    );
  }

  void nextSection() {
    if (currentSectionIndex.value < sections.length - 1) {
      currentSectionIndex.value++;
      pageController.animateToPage(
        currentSectionIndex.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void previousSection() {
    if (currentSectionIndex.value > 0) {
      currentSectionIndex.value--;
      pageController.animateToPage(
        currentSectionIndex.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void jumpToSection(int index) {
    currentSectionIndex.value = index;
    pageController.jumpToPage(index);
  }

  Future<void> saveInspection() async {
    // TODO: Implement save logic when endpoint is provided
    Get.snackbar(
      'Success',
      'Inspection saved locally (API pending)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> markAsInspected() async {
    // TODO: Implement status update logic
    Get.snackbar(
      'Success',
      'Marked as Inspected (API pending)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
