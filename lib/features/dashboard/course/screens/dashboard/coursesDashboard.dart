import 'package:cwt_starter_template/common/widgets/drawer/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../personalization/controllers/user_controller.dart';
import '../../controllers/dashboard_stats_controller.dart';
import 'widgets/appbar.dart';
import 'widgets/banners.dart';
import 'widgets/categories.dart';
import 'widgets/search.dart';
import 'widgets/top_courses.dart';
import '../../../../../utils/constants/image_strings.dart';

class CoursesDashboard extends StatelessWidget {
  const CoursesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    // final dark = THelperFunctions.isDarkMode(context);
    // Initialize dashboard stats controller
    Get.put(DashboardStatsController());
    Get.put(UserController());

    return SafeArea(
      child: Scaffold(
        appBar: const DashboardAppBar(),
        drawer: TDrawer(),
        body: SingleChildScrollView(
          child: Container(
            // padding: const EdgeInsets.all(TSizes.lg), // Removed for full screen layout
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Greeting
                      Text(
                        UserController.instance.user.value.fullName.isEmpty
                            ? "Hey, Inspection Engineer"
                            : "Hey, ${UserController.instance.user.value.fullName}",
                        style: txtTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Row 2: Welcome Back
                      Text(
                        "Welcome Back 👋",
                        style: txtTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Row 3: Platform Name
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image(
                              image: const AssetImage(TImages.tLogoImage),
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Otobix Inspections Platform",
                              style: txtTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.lg),

                // Search Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DashboardSearchBox(txtTheme: txtTheme),
                ),
                const SizedBox(height: TSizes.lg),

                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DashboardCategories(txtTheme: txtTheme),
                ),
                const SizedBox(height: TSizes.lg),

                // Banners (Row 4: Schedules + Running)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DashboardBanners(txtTheme: txtTheme),
                ),
                const SizedBox(height: TSizes.lg + 4),

                // Row 5: Quick Links Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Quick Links",
                    style: txtTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: txtTheme.headlineMedium!.fontSize! * 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Row 6: Quick Links Carousel
                DashboardTopCourses(txtTheme: txtTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
