import 'package:flutter/material.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../../utils/constants/sizes.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      title: Text(
        "OTOBIX",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize:
              (Theme.of(context).textTheme.headlineMedium?.fontSize ?? 24) *
              1.20,
        ),
      ),
      actions: [
        // Notification Bell with Counter Badge
        Container(
          margin: const EdgeInsets.only(right: 12, top: 7),
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
                    '0',
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

        // Otobix Logo next to bell
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 7),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Image(
              image: const AssetImage(TImages.tLogoImage),
              height: 35,
              width: 35,
              fit: BoxFit.contain,
            ),
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
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        "Notifications",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? Colors.white : TColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: TSizes.sm),
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
                          "0",
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
                  child: Center(
                    child: Text(
                      "No new notifications found.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: dark ? Colors.white70 : Colors.black54,
                      ),
                    ),
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
