import 'package:cwt_starter_template/utils/popups/exports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/services/api/api_service.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../dashboard/course/screens/dashboard/coursesDashboard.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// TextField Controllers
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final userName = TextEditingController();
  final phoneNumber = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  /// Loader
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isFacebookLoading = false.obs;

  @override
  void onInit() {
    // Pre-fill with saved credentials or default
    userName.text = localStorage.read('REMEMBER_ME_USERNAME') ?? 'Amit_P';
    phoneNumber.text = localStorage.read('REMEMBER_ME_PHONE') ?? '9830300300';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? 'Amit_P1974*';
    super.onInit();
  }

  /// Login using Otobix Backend API
  Future<void> login() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
        'Logging you in...',
        TImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.customToast(message: 'No Internet Connection');
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Call Backend API
      final response = await ApiService.post(ApiConstants.loginUrl, {
        'userName': userName.text.trim(),
        'phoneNumber': phoneNumber.text.trim(),
        'password': password.text.trim(),
      });

      // Save auth token if present
      if (response['token'] != null) {
        await ApiService.saveToken(response['token']);
      }

      // Save credentials for remember me
      localStorage.write('REMEMBER_ME_USERNAME', userName.text.trim());
      localStorage.write('REMEMBER_ME_PHONE', phoneNumber.text.trim());
      localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success
      TLoaders.successSnackBar(title: 'Welcome!', message: 'Login successful');

      // Navigate to Dashboard
      Get.offAll(() => const CoursesDashboard());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Login Failed', message: e.toString());
    }
  }
}
