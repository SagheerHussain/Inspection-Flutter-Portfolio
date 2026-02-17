import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/api/api_service.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/popups/exports.dart';
import '../models/inspection_field_defs.dart';
import '../models/inspection_form_model.dart';
import '../../schedules/models/schedule_model.dart';

class InspectionFormController extends GetxController {
  final String appointmentId;
  final ScheduleModel? schedule;

  InspectionFormController({required this.appointmentId, this.schedule});

  final Rxn<InspectionFormModel> inspectionData = Rxn<InspectionFormModel>();
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final isSaving = false.obs;
  final isFetchingDetails = false.obs;

  // Tabs / Sections
  final currentSectionIndex = 0.obs;
  final pageController = PageController();
  final _storage = GetStorage();
  final _picker = ImagePicker();

  // Image storage: key → list of local file paths
  final RxMap<String, List<String>> imageFiles = <String, List<String>>{}.obs;

  // Dynamic Dropdown Options: key → list of string options
  final RxMap<String, List<String>> dropdownOptions =
      <String, List<String>>{}.obs;

  List<String> get sectionTitles =>
      InspectionFieldDefs.sections.map((s) => s.title).toList();

  int get sectionCount => InspectionFieldDefs.sections.length;

  // ─── Non-mandatory field keys (can be empty on submit) ───
  static const Set<String> nonMandatoryKeys = {
    'additionalDetails',
    'bonnetImages',
    'frontBumperImages',
    'commentsOnEngine',
    'commentsOnEngineOil',
    'commentsOnRadiator',
    'additionalImages',
    'commentsOnTowing',
    'commentsOnOthers',
    'commentsOnClusterMeter',
    'commentsOnAC',
    'airbagImages',
    'coDriverAirbagImages',
    'driverSeatAirbagImages',
    'coDriverSeatAirbagImages',
    'rhsCurtainAirbagImages',
    'lhsCurtainAirbagImages',
    'driverKneeAirbagImages',
    'coDriverKneeAirbagImages',
    'rhsRearSideAirbagImages',
    'lhsRearSideAirbagImages',
    'commentOnInterior',
    'commentsOnTransmission',
  };

  @override
  void onInit() {
    super.onInit();
    fetchDropdownList();
    fetchInspectionData();
  }

  Future<void> fetchInspectionData() async {
    isLoading.value = true;
    try {
      // Check for local draft first
      final draftKey = 'draft_$appointmentId';
      final localDraft = _storage.read(draftKey);
      if (localDraft != null && localDraft is Map) {
        inspectionData.value = InspectionFormModel.fromJson(
          Map<String, dynamic>.from(localDraft),
        );
        // Restore image paths from draft
        final imgKey = 'draft_images_$appointmentId';
        final savedImages = _storage.read(imgKey);
        if (savedImages != null && savedImages is Map) {
          for (final entry in savedImages.entries) {
            final list = entry.value;
            if (list is List) {
              imageFiles[entry.key.toString()] =
                  list.map((e) => e.toString()).toList();
            }
          }
        }
        Get.snackbar(
          'Draft Loaded',
          'Continuing from your saved progress.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Try fetching from API
      final response = await ApiService.get(
        ApiConstants.carDetailsUrl(appointmentId),
      );
      if (response['carDetails'] != null) {
        inspectionData.value = InspectionFormModel.fromJson(
          response['carDetails'],
        );
      } else {
        _initializeNewInspection();
      }
    } catch (e) {
      debugPrint('Fetch failed, initializing new: $e');
      _initializeNewInspection();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDropdownList() async {
    try {
      final response = await ApiService.get(ApiConstants.getAllDropdownsUrl);
      if (response['data'] is List) {
        final List<dynamic> data = response['data'];
        final Map<String, List<String>> apiDropdowns = {};

        // 1. Build the API dropdown map (isActive only)
        for (var item in data) {
          if (item is Map &&
              item['dropdownName'] != null &&
              item['dropdownValues'] is List &&
              item['isActive'] == true) {
            final String name = item['dropdownName'];
            final List<dynamic> vals = item['dropdownValues'];
            apiDropdowns[name] = vals.map((v) => v.toString()).toList();
          }
        }

        if (apiDropdowns.isEmpty) return;

        // 2. Map API dropdowns to form fields using Priority Rules
        final Map<String, List<String>> mappedOptions = {};

        // Internal helper for normalization
        String normalize(String s) =>
            s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

        // Internal helper for Levenshtein Distance (Similarity)
        double calculateSimilarity(String s1, String s2) {
          if (s1 == s2) return 1.0;
          if (s1.isEmpty || s2.isEmpty) return 0.0;

          List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
          List<int> v1 = List<int>.filled(s2.length + 1, 0);

          for (int i = 0; i < s1.length; i++) {
            v1[0] = i + 1;
            for (int j = 0; j < s2.length; j++) {
              int cost = (s1[i] == s2[j]) ? 0 : 1;
              v1[j + 1] = [
                v1[j] + 1,
                v0[j + 1] + 1,
                v0[j] + cost,
              ].reduce((a, b) => a < b ? a : b);
            }
            v0 = List.from(v1);
          }
          int distance = v0[s2.length];
          return 1.0 -
              (distance /
                  [s1.length, s2.length].reduce((a, b) => a > b ? a : b));
        }

        for (final section in InspectionFieldDefs.sections) {
          for (final field in section.fields) {
            if (field.type != FType.dropdown) continue;

            final fieldKey = field.key;
            final fieldLabel = field.label;
            final normKey = normalize(fieldKey);
            final normLabel = normalize(fieldLabel);

            String? bestMatchName;
            double bestScore = 0.0;

            for (final dropdownName in apiDropdowns.keys) {
              final normApiName = normalize(dropdownName);

              // Priority 1 & 2: Exact/Normalized Match
              if (normKey == normApiName || normLabel == normApiName) {
                bestMatchName = dropdownName;
                bestScore = 1.0;
                break;
              }

              // Priority 3: Fuzzy Match (Confidence Check)
              final keyScore = calculateSimilarity(normKey, normApiName);
              final labelScore = calculateSimilarity(normLabel, normApiName);
              final currentBest = keyScore > labelScore ? keyScore : labelScore;

              if (currentBest > bestScore) {
                bestScore = currentBest;
                bestMatchName = dropdownName;
              }
            }

            // High confidence threshold (0.75) for fuzzy matching
            if (bestMatchName != null && bestScore >= 0.75) {
              mappedOptions[fieldKey] = apiDropdowns[bestMatchName]!;
              debugPrint(
                '🔗 Mapped [$fieldKey] to API [$bestMatchName] (Score: ${bestScore.toStringAsFixed(2)})',
              );
            }
          }
        }

        if (mappedOptions.isNotEmpty) {
          dropdownOptions.addAll(mappedOptions);
          debugPrint(
            '✨ Dynamic mapping complete. ${mappedOptions.length} fields populated from API.',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error mapping dropdowns: $e');
    }
  }

  void _initializeNewInspection() {
    inspectionData.value = InspectionFormModel(
      id: '',
      appointmentId: appointmentId,
      make: schedule?.make ?? '',
      model: schedule?.model ?? '',
      variant: schedule?.variant ?? '',
      status: 'Pending',
      data: {
        'appointmentId': appointmentId,
        'registrationNumber': schedule?.carRegistrationNumber ?? '',
        'yearMonthOfManufacture': schedule?.yearOfManufacture ?? '',
        'odometerReadingInKms': schedule?.odometerReadingInKms ?? 0,
        'customerName': schedule?.ownerName ?? '',
        'customerPhone': schedule?.customerContactNumber ?? '',
        'city': schedule?.city ?? '',
        'make': schedule?.make ?? '',
        'model': schedule?.model ?? '',
        'variant': schedule?.variant ?? '',
        'ownerSerialNumber': schedule?.ownershipSerialNumber ?? 1,
      },
    );
  }

  // ─── Field Operations ───
  void updateField(String key, dynamic value) {
    final data = inspectionData.value;
    if (data != null) {
      data.data[key] = value;
      inspectionData.refresh();
    }
  }

  String getFieldValue(String key) {
    return inspectionData.value?.data[key]?.toString() ?? '';
  }

  // ─── Image Operations ───
  Future<void> pickImage(String key, ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (picked != null) {
        final currentList = imageFiles[key] ?? [];
        currentList.add(picked.path);
        imageFiles[key] = List.from(currentList);
        imageFiles.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  Future<void> pickMultipleImages(String key) async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (picked.isNotEmpty) {
        final currentList = imageFiles[key] ?? [];
        currentList.addAll(picked.map((x) => x.path));
        imageFiles[key] = List.from(currentList);
        imageFiles.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not pick images: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  void removeImage(String key, int index) {
    final currentList = imageFiles[key] ?? [];
    if (index >= 0 && index < currentList.length) {
      currentList.removeAt(index);
      imageFiles[key] = List.from(currentList);
      imageFiles.refresh();
    }
  }

  List<String> getImages(String key) {
    return imageFiles[key] ?? [];
  }

  // ─── Navigation ───
  void nextSection() {
    if (currentSectionIndex.value < sectionCount - 1) {
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

  // ─── Save Draft (Local) ───
  Future<void> saveInspection() async {
    final data = inspectionData.value;
    if (data == null) return;

    isSaving.value = true;
    try {
      // Build a clean serializable map from data
      final draftKey = 'draft_$appointmentId';
      final saveMap = <String, dynamic>{};
      data.data.forEach((key, value) {
        // Only save primitive types and lists of primitives
        if (value is String || value is num || value is bool || value == null) {
          saveMap[key] = value;
        } else if (value is List) {
          saveMap[key] = value.map((e) => e.toString()).toList();
        } else {
          saveMap[key] = value.toString();
        }
      });
      // Ensure identity fields
      saveMap['_id'] = data.id;
      saveMap['appointmentId'] = data.appointmentId;
      saveMap['make'] = data.make;
      saveMap['model'] = data.model;
      saveMap['variant'] = data.variant;
      saveMap['status'] = data.status;

      await _storage.write(draftKey, saveMap);

      // Also save image paths
      final imgKey = 'draft_images_$appointmentId';
      final imgMap = <String, dynamic>{};
      imageFiles.forEach((k, v) {
        imgMap[k] = v;
      });
      await _storage.write(imgKey, imgMap);

      debugPrint('💾 Draft saved successfully to local storage');

      Get.rawSnackbar(
        titleText: const Text(
          'Data Saved',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: const Text(
          'Your data has been saved as Draft',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 28),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    } catch (e) {
      debugPrint('Save draft error: $e');
      Get.snackbar(
        'Save Failed',
        'Could not save draft. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ─── Submit to API ───
  Future<void> submitInspection() async {
    final data = inspectionData.value;
    if (data == null) return;

    // Validate ALL required fields across every section
    final missingBySection = <String, List<String>>{};
    for (final section in InspectionFieldDefs.sections) {
      for (final field in section.fields) {
        // Skip non-mandatory fields
        if (field.optional || nonMandatoryKeys.contains(field.key)) continue;

        if (field.type == FType.image) {
          final imgs = getImages(field.key);
          if (imgs.isEmpty) {
            missingBySection
                .putIfAbsent(section.title, () => [])
                .add(field.label);
          }
        } else {
          final val = getFieldValue(field.key);
          if (val.isEmpty || val == '0') {
            // Allow 0 for numbers that might legitimately be 0
            if (field.type == FType.number && val == '0') continue;
            missingBySection
                .putIfAbsent(section.title, () => [])
                .add(field.label);
          }
        }
      }
    }

    if (missingBySection.isNotEmpty) {
      final totalMissing = missingBySection.values.fold<int>(
        0,
        (sum, list) => sum + list.length,
      );

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Missing Required Fields',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '$totalMissing field(s) need to be completed',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      missingBySection.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0D6EFD,
                                  ).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${entry.key} (${entry.value.length})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D6EFD),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Field list
                              ...entry.value
                                  .take(5)
                                  .map(
                                    (f) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        bottom: 3,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 5,
                                            color: Colors.red.shade300,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              f,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              if (entry.value.length > 5)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    top: 2,
                                  ),
                                  child: Text(
                                    '+ ${entry.value.length - 5} more...',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 16),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(Get.context!).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "OK, I'll fix them",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );
      return;
    }

    // Build and submit payload
    isSubmitting.value = true;
    try {
      final payload = _buildFullPayload(data);

      debugPrint('📡 Submitting inspection payload...');
      debugPrint('📦 Payload keys: ${payload.keys.toList()}');

      final response = await ApiService.post(
        ApiConstants.inspectionSubmitUrl,
        payload,
      );

      // Clear local draft on success
      await _storage.remove('draft_$appointmentId');
      await _storage.remove('draft_images_$appointmentId');

      Get.snackbar(
        'Submitted ✓',
        response['message'] ?? 'Inspection submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(Icons.check_circle, color: Colors.white, size: 28),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () => Get.back());
    } catch (e) {
      debugPrint('❌ Submit error: $e');
      Get.snackbar(
        'Submission Failed',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Auto Fetch Vehicle Details ───
  Future<void> autoFetchVehicleDetails() async {
    final regNo = getFieldValue('registrationNumber').trim();
    if (regNo.isEmpty) {
      TLoaders.warningSnackBar(
        title: 'Registration Missing',
        message: 'Please enter a vehicle registration number first.',
      );
      return;
    }

    try {
      isFetchingDetails.value = true;

      final response = await ApiService.post(
        ApiConstants.fetchVehicleDetailsUrl,
        {"vehicleRegistrationNumber": regNo},
      );

      // Print auto-fetched data to console as requested
      debugPrint('🚀 [AutoFetch] Response: $response');

      // Access data.result as specified
      final result = response['data']?['result'];
      if (result != null && result is Map<String, dynamic>) {
        _applyFetchedData(result);
        TLoaders.successSnackBar(
          title: 'Details Fetched',
          message: 'Vehicle information has been auto-filled.',
        );
      } else {
        throw 'No details found for this registration number.';
      }
    } catch (e) {
      debugPrint('❌ AutoFetch Error: $e');
      TLoaders.errorSnackBar(
        title: 'Fetch Failed',
        message:
            e.toString().contains('No details found')
                ? 'No data found for this vehicle.'
                : 'Unable to connect to RTO service.',
      );
    } finally {
      isFetchingDetails.value = false;
    }
  }

  void _applyFetchedData(Map<String, dynamic> result) {
    debugPrint(
      '🧩 [AutoFetch] Starting data mapping. Available keys: ${result.keys.toList()}',
    );

    // Helper to find a value by checking multiple potential keys case-insensitively
    dynamic find(List<String> keys) {
      final searchKeys =
          keys
              .map(
                (k) => k.toLowerCase().replaceAll('_', '').replaceAll(' ', ''),
              )
              .toSet();

      for (final entry in result.entries) {
        final entryKey = entry.key
            .toLowerCase()
            .replaceAll('_', '')
            .replaceAll(' ', '');
        if (searchKeys.contains(entryKey) &&
            entry.value != null &&
            entry.value.toString().isNotEmpty) {
          return entry.value;
        }
      }
      return null;
    }

    final mapping = {
      'registrationDate': [
        'registration_date',
        'reg_date',
        'regDate',
        'date_of_registration',
        'reg_dt',
      ],
      'fitnessValidity': [
        'fitness_upto',
        'fitness_valid_upto',
        'fitnessValidity',
        'fitness_limit',
        'fit_dt',
      ],
      'engineNumber': [
        'engine_number',
        'engine_no',
        'engineNo',
        'eng_no',
        'engineNumber',
      ],
      'chassisNumber': [
        'chassis_number',
        'chassis_no',
        'chassisNo',
        'chassisNumber',
      ],
      'chassisDetails': [
        'chassis_number',
        'chassis_no',
        'chassisNo',
        'chassisNumber',
      ], // Also fill chassis details
      'make': ['maker', 'make', 'manufacturer', 'brand', 'maker_name'],
      'model': ['model', 'maker_model', 'model_name'],
      'variant': ['variant', 'series', 'model_variant'],
      'yearMonthOfManufacture': [
        'manufacturing_date',
        'mfg_date',
        'mfgDate',
        'year_of_manufacture',
        'manufacturing_month_year',
        'manu_month_yr',
      ],
      'fuelType': ['fuel_type', 'fuelType', 'fuel', 'fuel_descr'],
      'seatingCapacity': [
        'seating_capacity',
        'seat_cap',
        'seatingCapacity',
        'seat_capacity',
      ],
      'color': ['color', 'colour'],
      'cubicCapacity': [
        'cubic_capacity',
        'cc',
        'engine_capacity',
        'displacement',
      ],
      'norms': [
        'norms',
        'pollution_norms',
        'norms_type',
        'emission_norms',
        'norms_descr',
      ],
      'registrationState': [
        'state',
        'st_name',
        'registration_state',
        'state_name',
      ],
      'registeredRto': [
        'rto',
        'rto_name',
        'registered_rto',
        'rto_code',
        'rto_descr',
      ],
      'ownerSerialNumber': [
        'owner_serial_number',
        'owner_count',
        'owner_number',
        'ownership_count',
        'owner_sr',
      ],
      'registeredOwner': [
        'owner_name',
        'registered_owner',
        'ownerName',
        'owner',
      ],
      'registeredAddressAsPerRc': [
        'permanent_address',
        'address',
        'owner_address',
        'present_address',
      ],
      'taxValidTill': [
        'tax_upto',
        'tax_paid_upto',
        'tax_validity',
        'mv_tax_upto',
        'tax_dt',
      ],
      'hypothecatedTo': [
        'hypothecated_to',
        'financer',
        'hypothecation_details',
        'financed_by',
        'fncr',
      ],
      'insuranceValidity': [
        'insurance_upto',
        'insurance_valid_upto',
        'insurance_validity',
        'ins_upto',
        'ins_dt',
      ],
      'insurer': [
        'insurance_company',
        'insurer_name',
        'insurance_name',
        'ins_name',
        'insurance_descr',
      ],
      'insurancePolicyNumber': [
        'insurance_policy_number',
        'policy_no',
        'policyNumber',
        'policy_number',
        'ins_policy_no',
      ],
      'pucValidity': [
        'puc_upto',
        'puc_valid_upto',
        'puc_validity',
        'pollution_upto',
        'puc_dt',
      ],
      'pucNumber': ['puc_number', 'pucNo', 'pollution_no', 'puc_no'],
      'rcStatus': [
        'rc_status',
        'status_as_on',
        'status',
        'rc_status_description',
        'status_descr',
      ],
      'blacklistStatus': [
        'blacklist_status',
        'is_blacklisted',
        'blacklisted_details',
      ],
      'rtoNoc': ['noc_details', 'rto_noc', 'noc_status'],
    };

    bool updatedAny = false;
    mapping.forEach((targetKey, sourceKeys) {
      final value = find(sourceKeys);
      if (value != null) {
        // Log mapping attempt
        debugPrint(
          '📍 Mapping [$targetKey] <--- Found value: "$value" in source keys: $sourceKeys',
        );

        // Overwrite the field with the new value
        updateField(targetKey, value.toString());
        updatedAny = true;
        debugPrint('✅ [$targetKey] Overwrite SUCCESS');
      }
    });

    if (updatedAny) {
      debugPrint('✨ Data mapping completed. Refreshing UI...');
      inspectionData.refresh();
    } else {
      debugPrint(
        '📢 No fields were updated (all fields may already have data).',
      );
    }
  }

  Map<String, dynamic> _buildFullPayload(InspectionFormModel data) {
    final payload = <String, dynamic>{};

    // Copy all form data values
    data.data.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        payload[key] = value;
      }
    });

    // Add image paths (as arrays — in production these would be Cloudinary URLs)
    imageFiles.forEach((key, paths) {
      if (paths.isNotEmpty) {
        payload[key] = paths;
      }
    });

    // Ensure core identification fields
    payload['appointmentId'] = appointmentId;
    payload['make'] = data.make;
    payload['model'] = data.model;
    payload['variant'] = data.variant;
    payload['timestamp'] = DateTime.now().toUtc().toIso8601String();

    return payload;
  }
}
