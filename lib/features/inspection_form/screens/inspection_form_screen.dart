import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../schedules/models/schedule_model.dart';
import '../controllers/inspection_form_controller.dart';
import '../models/inspection_form_model.dart';

class InspectionFormScreen extends StatelessWidget {
  final String appointmentId;
  final ScheduleModel schedule;

  const InspectionFormScreen({
    super.key,
    required this.appointmentId,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    // Unique tag to allow multiple forms if needed
    final controller = Get.put(
      InspectionFormController(
        appointmentId: appointmentId,
        schedule: schedule,
      ),
      tag: 'form_$appointmentId',
    );
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            _buildAppBar(context, controller),

            // ─── Progress Indicator ───
            _buildProgressIndicator(controller),

            // ─── Main Form Area ───
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.inspectionData.value == null) {
                  return const Center(child: Text('No data available'));
                }

                return PageView.builder(
                  controller: controller.pageController,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable swipe to enforce buttons
                  itemCount: controller.sections.length,
                  itemBuilder: (context, index) {
                    return _buildSection(context, index, controller);
                  },
                );
              }),
            ),

            // ─── Footer Buttons ───
            _buildFooter(context, controller, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    InspectionFormController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TColors.primary,
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.fullCarName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'ID: ${schedule.appointmentId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(InspectionFormController controller) {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.sections.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.currentSectionIndex.value == index;
            final isCompleted = controller.currentSectionIndex.value > index;
            final isEnabled =
                !controller.isLoading.value &&
                controller.inspectionData.value != null;

            return GestureDetector(
              onTap: isEnabled ? () => controller.jumpToSection(index) : null,
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 24 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? TColors.primary
                                : (isCompleted
                                    ? Colors.green
                                    : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.sections[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? TColors.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    int index,
    InspectionFormController controller,
  ) {
    // Safety check just in case
    if (controller.inspectionData.value == null) return const SizedBox();

    final data = controller.inspectionData.value!;

    // Switch for different sections
    switch (index) {
      case 0:
        return _VehicleInfoSection(data: data);
      case 1:
        return _DocumentsSection(data: data);
      case 2:
        return _ExteriorSection(data: data);
      case 3:
        return _EngineSection(data: data);
      case 4:
        return _InteriorSection(data: data);
      default:
        return Center(child: Text('Section: ${controller.sections[index]}'));
    }
  }

  Widget _buildFooter(
    BuildContext context,
    InspectionFormController controller,
    bool dark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24,
      ), // Extra padding at bottom
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E2746) : Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, -4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Obx(() {
        final isEnabled =
            !controller.isLoading.value &&
            controller.inspectionData.value != null;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button
            IconButton.filledTonal(
              onPressed:
                  isEnabled
                      ? () {
                        if (controller.currentSectionIndex.value > 0) {
                          controller.previousSection();
                        } else {
                          Get.back();
                        }
                      }
                      : null,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Previous',
            ),

            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  onPressed: isEnabled ? controller.saveInspection : null,
                  style: IconButton.styleFrom(backgroundColor: Colors.orange),
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  tooltip: 'Save Draft',
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: isEnabled ? controller.markAsInspected : null,
                  style: IconButton.styleFrom(backgroundColor: Colors.green),
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Mark as Inspected',
                ),
              ],
            ),

            // Next Button
            IconButton.filledTonal(
              onPressed: isEnabled ? controller.nextSection : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              tooltip: 'Next',
            ),
          ],
        );
      }),
    );
  }
}

// ─── SECTIONS ───

// ─── HELPERS FOR PHOTO PLACEHOLDERS ───

class _PhotoPlaceholder extends StatelessWidget {
  final String label;
  const _PhotoPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ), // dashed border requires external pkg or custom painter
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo_rounded, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(
              'Add $label Photos',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleInfoSection extends StatelessWidget {
  final InspectionFormModel data;
  const _VehicleInfoSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AnimatedHeader(
            title: 'Vehicle Information',
            icon: Icons.directions_car,
          ),
          const SizedBox(height: 16),
          _PhotoPlaceholder(label: 'Vehicle'),
          const SizedBox(height: 8),
          _FormTextField(
            label: 'Registration Number',
            initialValue: data.data['registrationNumber'],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FormTextField(label: 'Make', initialValue: data.make),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormTextField(label: 'Model', initialValue: data.model),
              ),
            ],
          ),
          _FormTextField(label: 'Variant', initialValue: data.variant),
          _FormTextField(
            label: 'Mfg Year (MM/YYYY)',
            initialValue: data.data['yearMonthOfManufacture'],
          ),
          _FormTextField(
            label: 'Odometer (km)',
            initialValue: data.data['odometerReadingInKms']?.toString(),
          ),
          _FormDropdown(
            label: 'Fuel Type',
            value: data.data['fuelType'],
            items: const ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'],
          ),
          _FormDropdown(
            label: 'Transmission',
            value: data.data['transmissionTypeDropdownList']?.toString(),
            items: const ['Manual', 'Automatic', 'AMT', 'CVT'],
          ),
          _FormDropdown(
            label: 'Owner Serial',
            value: data.data['ownerSerialNumber']?.toString(),
            items: const ['1', '2', '3', '4+'],
          ),
        ],
      ),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  final InspectionFormModel data;
  const _DocumentsSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AnimatedHeader(title: 'Documents', icon: Icons.description),
          const SizedBox(height: 16),
          _PhotoPlaceholder(label: 'Document'),
          const SizedBox(height: 8),
          _FormDropdown(
            label: 'RC Availability',
            value: data.data['rcBookAvailability'],
            items: const [
              'Original',
              'Photocopy',
              'Duplicate',
              'Not Available',
            ],
          ),
          _FormDropdown(
            label: 'RC Condition',
            value: data.data['rcCondition'],
            items: const ['Okay', 'Damaged', 'Faded'],
          ),
          const Divider(height: 32),
          _FormDropdown(
            label: 'Insurance Type',
            value: data.data['insurance'],
            items: const [
              'Comprehensive',
              'Third Party',
              'Expired',
              'Not Available',
            ],
          ),
          _FormTextField(
            label: 'Insurance Validity',
            initialValue: data.data['insuranceValidity'],
          ),
          const Divider(height: 32),
          _FormDropdown(
            label: 'RTO NOC',
            value: data.data['rtoNoc'],
            items: const ['Issued', 'Not Issued', 'Not Applicable'],
          ),
          _FormDropdown(
            label: 'Road Tax',
            value: data.data['roadTaxValidity'],
            items: const ['Lifetime', 'Valid', 'Expired'],
          ),
        ],
      ),
    );
  }
}

class _ExteriorSection extends StatelessWidget {
  final InspectionFormModel data;
  const _ExteriorSection({required this.data});

  @override
  Widget build(BuildContext context) {
    const options = [
      'Original',
      'Repainted',
      'Dented',
      'Scratched',
      'Rusted',
      'Replaced',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AnimatedHeader(title: 'Exterior & Body', icon: Icons.car_repair),
          const SizedBox(height: 16),
          _PhotoPlaceholder(label: 'Exterior'),
          const SizedBox(height: 8),
          // Front
          _FormDropdown(
            label: 'Bonnet',
            value: data.data['bonnet'],
            items: options,
          ),
          _FormDropdown(
            label: 'Front Bumper',
            value: data.data['frontBumper'],
            items: options,
          ),
          _FormDropdown(
            label: 'Headlamps',
            value: data.data['lhsHeadlamp'],
            items: const ['Okay', 'Faded', 'Cracked', 'Broken'],
          ),
          _FormDropdown(
            label: 'Windshield (Front)',
            value: data.data['frontWindshield'],
            items: const ['Original', 'Replaced', 'Cracked', 'Chipped'],
          ),
          const Divider(),
          // Sides
          _FormDropdown(
            label: 'LHS Fender',
            value: data.data['lhsFender'],
            items: options,
          ),
          _FormDropdown(
            label: 'LHS Front Door',
            value: data.data['lhsFrontDoor'],
            items: options,
          ),
          _FormDropdown(
            label: 'LHS Rear Door',
            value: data.data['lhsRearDoor'],
            items: options,
          ),
          _FormDropdown(
            label: 'RHS Fender',
            value: data.data['rhsFender'],
            items: options,
          ),
          _FormDropdown(
            label: 'RHS Front Door',
            value: data.data['rhsFrontDoor'],
            items: options,
          ),
          _FormDropdown(
            label: 'RHS Rear Door',
            value: data.data['rhsRearDoor'],
            items: options,
          ),
          _FormDropdown(
            label: 'Roof',
            value: data.data['roof'],
            items: options,
          ),
          const Divider(),
          // Rear
          _FormDropdown(
            label: 'Boot Door',
            value: data.data['bootDoor'],
            items: options,
          ),
          _FormDropdown(
            label: 'Rear Bumper',
            value: data.data['rearBumper'],
            items: options,
          ),
          _FormDropdown(
            label: 'Tail Lamps',
            value: data.data['lhsTailLamp'],
            items: const ['Okay', 'Faded', 'Cracked'],
          ),

          const SizedBox(height: 16),
          _FormTextField(
            label: 'Exterior Comments',
            initialValue: data.data['comments'],
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _EngineSection extends StatelessWidget {
  final InspectionFormModel data;
  const _EngineSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AnimatedHeader(
            title: 'Engine & Mechanical',
            icon: Icons.engineering,
          ),
          const SizedBox(height: 16),
          _PhotoPlaceholder(label: 'Engine'),
          const SizedBox(height: 8),
          _FormDropdown(
            label: 'Engine Condition',
            value: data.data['engine'],
            items: const ['Okay', 'Noise', 'Blowby', 'Seized', 'Misfiring'],
          ),
          _FormDropdown(
            label: 'Engine Oil',
            value: data.data['engineOil'],
            items: const ['Clean', 'Dirty', 'Low Level', 'Sludge', 'Leakage'],
          ),
          _FormDropdown(
            label: 'Coolant',
            value: data.data['coolant'],
            items: const ['Okay', 'Dirty', 'Leakage', 'Empty'],
          ),
          _FormDropdown(
            label: 'Battery',
            value: data.data['battery'],
            items: const ['Okay', 'Weak', 'Dead'],
          ),
          _FormDropdown(
            label: 'Exhaust Smoke',
            value: data.data['exhaustSmoke'],
            items: const ['Clear', 'Black', 'White', 'Blue'],
          ),
          const Divider(),
          _FormDropdown(
            label: 'Clutch',
            value: data.data['clutch'],
            items: const ['Hard', 'Slipping', 'Okay', 'Deep'],
          ),
          _FormDropdown(
            label: 'Gear Shift',
            value: data.data['gearShift'],
            items: const ['Smooth', 'Hard', 'Noise'],
          ),
          _FormDropdown(
            label: 'Steering',
            value: data.data['steering'],
            items: const ['Okay', 'Hard', 'Noise', 'Vibration'],
          ),
          _FormDropdown(
            label: 'Suspension',
            value: data.data['suspension'],
            items: const ['Okay', 'Noise', 'Weak'],
          ),
          _FormDropdown(
            label: 'Brakes',
            value: data.data['brakes'],
            items: const ['Okay', 'Noise', 'Weak', 'Spongy'],
          ),
          const SizedBox(height: 16),
          _FormTextField(
            label: 'Mechanical Comments',
            initialValue: data.data['commentsOnEngine'],
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _InteriorSection extends StatelessWidget {
  final InspectionFormModel data;
  const _InteriorSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AnimatedHeader(
            title: 'Interior & Electricals',
            icon: Icons.airline_seat_recline_extra,
          ),
          const SizedBox(height: 16),
          _PhotoPlaceholder(label: 'Interior'),
          const SizedBox(height: 8),
          _FormDropdown(
            label: 'AC Cooling',
            value: data.data['airConditioningClimateControl'] ?? 'Okay',
            items: const [
              'Chilled',
              'Ineffective',
              'Not Working',
              'Heater Only',
            ],
          ),
          _FormDropdown(
            label: 'Music System',
            value: data.data['musicSystem'],
            items: const ['Working', 'Not Working', 'Missing', 'Aftermarket'],
          ),
          _FormDropdown(
            label: 'Power Windows',
            value: data.data['noOfPowerWindows'],
            items: const [
              'All Working',
              'Driver Not Working',
              'Some Not Working',
              'None',
            ],
          ),
          const Divider(),
          _FormDropdown(
            label: 'Seats Condition',
            value: data.data['seatsUpholstery'],
            items: const ['Okay', 'Torn', 'Dirty', 'Worn Out'],
          ),
          _FormDropdown(
            label: 'Dashboard',
            value: data.data['dashboardCondition'],
            items: const ['Okay', 'Scratched', 'Cracked'],
          ),
          _FormDropdown(
            label: 'Warning Lights',
            value: data.data['warningLights'],
            items: const ['None', 'Check Engine', 'ABS', 'Airbag'],
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ───

class _AnimatedHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _AnimatedHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColors.primary,
                    TColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final int maxLines;

  const _FormTextField({
    required this.label,
    this.initialValue,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue ?? '',
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;

  const _FormDropdown({required this.label, this.value, required this.items});

  @override
  Widget build(BuildContext context) {
    // Ensure value is in items, or null if empty
    final effectiveValue =
        (value != null && value!.isNotEmpty && items.contains(value))
            ? value
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: effectiveValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (v) {}, // TODO: Bind to controller
      ),
    );
  }
}
