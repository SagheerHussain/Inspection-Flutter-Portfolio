import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/helpers/helper_functions.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColors.primary,
                  TColors.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_car,
              color: TColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "OTOBIX",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        // Notification Bell with Counter Badge
        Container(
          margin: const EdgeInsets.only(right: 8, top: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: dark ? TColors.secondary : TColors.cardBackgroundColor,
          ),
          child: Stack(
            children: [
              IconButton(
                onPressed: () => _showNotificationsSheet(context),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: dark ? Colors.white : TColors.dark,
                  size: 24,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: TColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: const Text(
                    '6',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile Image
        Container(
          margin: const EdgeInsets.only(right: 20, top: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: dark ? TColors.secondary : TColors.cardBackgroundColor,
          ),
          child: IconButton(
            onPressed: () => Get.toNamed(TRoutes.profileScreen),
            icon: const Image(image: AssetImage(TImages.tUserProfileImage)),
          ),
        ),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Notifications",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "6 New",
                          style: TextStyle(
                            color: TColors.dark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Notification Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildNotificationTile(
                        context,
                        icon: Icons.calendar_today_rounded,
                        iconColor: const Color(0xFF4CAF50),
                        bgColor: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        title: "New Schedule Ready",
                        subtitle:
                            "You have a new inspection schedule assigned to you.",
                        time: "2 min ago",
                        isUnread: true,
                      ),
                      _buildNotificationTile(
                        context,
                        icon: Icons.access_time_rounded,
                        iconColor: const Color(0xFFFF9800),
                        bgColor: const Color(0xFFFF9800).withValues(alpha: 0.1),
                        title: "Appointment #26-1232",
                        subtitle:
                            "This appointment is ready in 2 hours. Please prepare documents.",
                        time: "15 min ago",
                        isUnread: true,
                      ),
                      _buildNotificationTile(
                        context,
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFF44336),
                        bgColor: const Color(0xFFF44336).withValues(alpha: 0.1),
                        title: "Inspection #26-1330 Still Running",
                        subtitle:
                            "This inspection is still open. Close it ASAP to avoid delays.",
                        time: "30 min ago",
                        isUnread: true,
                      ),
                      _buildNotificationTile(
                        context,
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: const Color(0xFF2196F3),
                        bgColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
                        title: "Inspection #26-1295 Approved",
                        subtitle:
                            "The customer has acknowledged the inspection report.",
                        time: "1 hour ago",
                        isUnread: false,
                      ),
                      _buildNotificationTile(
                        context,
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFF9C27B0),
                        bgColor: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                        title: "New Site Location Updated",
                        subtitle:
                            "The address for Lead #26-1340 has been updated by the customer.",
                        time: "2 hours ago",
                        isUnread: false,
                      ),
                      _buildNotificationTile(
                        context,
                        icon: Icons.photo_camera_outlined,
                        iconColor: const Color(0xFF00BCD4),
                        bgColor: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                        title: "Photos Uploaded Successfully",
                        subtitle:
                            "12 photos for Inspection #26-1310 have been synced to cloud.",
                        time: "3 hours ago",
                        isUnread: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread ? bgColor.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(55);
}
