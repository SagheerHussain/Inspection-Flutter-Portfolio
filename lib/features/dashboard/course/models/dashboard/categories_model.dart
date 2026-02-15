import 'package:flutter/material.dart';

class DashboardCategoriesModel {
  final String title;
  final String heading;
  final String subHeading;
  final IconData? icon;
  final VoidCallback? onPress;

  DashboardCategoriesModel(
    this.title,
    this.heading,
    this.subHeading,
    this.onPress, {
    this.icon,
  });

  static List<DashboardCategoriesModel> list = [
    DashboardCategoriesModel(
      "🚗",
      "Vehicles",
      "12 Pending",
      null,
      icon: Icons.directions_car,
    ),
    DashboardCategoriesModel(
      "📋",
      "Reports",
      "8 Ready",
      null,
      icon: Icons.description,
    ),
    DashboardCategoriesModel(
      "📍",
      "Sites",
      "5 Nearby",
      null,
      icon: Icons.location_on,
    ),
    DashboardCategoriesModel(
      "📸",
      "Photos",
      "46 Synced",
      null,
      icon: Icons.camera_alt,
    ),
    DashboardCategoriesModel(
      "⏰",
      "History",
      "120+ Done",
      null,
      icon: Icons.history,
    ),
  ];
}
