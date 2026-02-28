import 'package:cwt_starter_template/features/authentication/screens/login/login_screen.dart';
import 'package:cwt_starter_template/features/authentication/screens/on_boarding/on_boarding_screen.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/home.dart';
import 'package:cwt_starter_template/features/schedules/screens/schedules_screen.dart';
import 'package:cwt_starter_template/personalization/screens/profile/profile_screen.dart';
import 'package:cwt_starter_template/personalization/screens/profile/re_authenticate_phone_otp_screen.dart';
import 'package:cwt_starter_template/routes/routes.dart';
import 'package:get/get.dart';
import '../bindings/notification_binding.dart';
import '../features/authentication/screens/phone_number/otp/phone_otp_screen.dart';
import '../features/authentication/screens/phone_number/phone_number_screen.dart';
import '../features/authentication/screens/welcome/welcome_screen.dart';
import '../features/dashboard/course/screens/dashboard/coursesDashboard.dart';
import '../personalization/screens/notification/notification_detail_screen.dart';
import '../personalization/screens/notification/notification_screen.dart';

import '../personalization/screens/profile/update_profile_screen.dart';

class AppRoutes {
  static final pages = [
    GetPage(name: TRoutes.logIn, page: () => const LoginScreen()),
    GetPage(name: TRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: TRoutes.onboarding, page: () => const OnBoardingScreen()),
    GetPage(
      name: TRoutes.coursesDashboard,
      page: () => const CoursesDashboard(),
    ),
    GetPage(name: TRoutes.eComDashboard, page: () => const HomeScreen()),
    GetPage(name: TRoutes.phoneSignIn, page: () => const PhoneNumberScreen()),
    GetPage(name: TRoutes.otpVerification, page: () => const PhoneOtpScreen()),
    GetPage(
      name: TRoutes.reAuthenticateOtpVerification,
      page: () => const ReAuthenticatePhoneOtpScreen(),
    ),
    GetPage(name: TRoutes.profileScreen, page: () => const ProfileScreen()),

    GetPage(
      name: TRoutes.schedules,
      page: () => const SchedulesScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: TRoutes.notification,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: TRoutes.notificationDetails,
      page: () => const NotificationDetailScreen(),
      binding: NotificationBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: TRoutes.editProfile,
      page: () => const UpdateProfileScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
