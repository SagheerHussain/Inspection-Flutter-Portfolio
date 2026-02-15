import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../schedules/screens/schedules_screen.dart';

class DashboardSearchBox extends StatelessWidget {
  const DashboardSearchBox({super.key, required this.txtTheme});

  final TextTheme txtTheme;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: dark ? TColors.dark : Colors.grey[200], // Darker background
        borderRadius: BorderRadius.circular(14),
        boxShadow: [], // clean look
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ), // Vertical padding handled by TextField contentPadding
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search by Appointment Id, Contact Number etc..",
          hintStyle: txtTheme.bodyMedium?.copyWith(
            color: Colors.grey.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.withValues(alpha: 0.8),
            size: 24,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Get.to(() => SchedulesScreen(searchQuery: value.trim()));
          }
        },
      ),
    );
  }
}
