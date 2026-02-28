import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../schedules/models/schedule_model.dart';
import '../controllers/inspection_form_controller.dart';
import '../models/inspection_field_defs.dart';

// ─── Custom accent color (replaces TColors.primary yellow) ───
const Color _accent = Color(0xFF0D6EFD); // Vibrant royal blue

// ─── Filled/Unfilled field styling helpers ───
const Color _filledGreen = Color(0xFF10B981); // Emerald green for filled indicator
const Color _filledBg = Color(0xFFF0FDF4);     // Very light mint green background
const Color _filledBorder = Color(0xFF86EFAC);  // Soft green border
const Color _emptyBg = Colors.white;

/// Returns a decorated container wrapping a field, with a green left-border when filled.
Widget _fieldWrapper({
  required Widget child,
  required bool isFilled,
  double bottomMargin = 14,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: bottomMargin),
    child: Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isFilled
                ? Border.all(color: _filledBorder, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: isFilled
                    ? _filledGreen.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
        // Green left-bar indicator
        if (isFilled)
          Positioned(
            left: 0,
            top: 6,
            bottom: 6,
            child: Container(
              width: 3.5,
              decoration: BoxDecoration(
                color: _filledGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Common InputDecoration for filled/unfilled state
InputDecoration _styledDecoration({
  required String label,
  required bool isOptional,
  required bool isFilled,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    label: RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isFilled ? const Color(0xFF047857) : Colors.grey.shade600,
          fontSize: 13,
          fontWeight: isFilled ? FontWeight.w600 : FontWeight.normal,
        ),
        children: [
          if (!isOptional)
            TextSpan(
              text: isFilled ? ' ✓' : ' *',
              style: TextStyle(
                color: isFilled ? const Color(0xFF047857) : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ),
    filled: true,
    fillColor: isFilled ? _filledBg : _emptyBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isFilled ? _filledBorder : Colors.grey.shade200,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isFilled ? _filledBorder : Colors.grey.shade200,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _accent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
  );
}
const Color _headerGradientStart = Color(0xFF1A237E); // Deep indigo
const Color _headerGradientEnd = Color(0xFF0D6EFD); // Royal blue

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
    final controller = Get.put(
      InspectionFormController(
        appointmentId: appointmentId,
        schedule: schedule,
      ),
      tag: 'form_$appointmentId',
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.light, // Light icons for dark gradient
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            _AppBar(schedule: schedule),
            _ProgressBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(_accent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading inspection data...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (controller.inspectionData.value == null) {
                  return Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return PageView.builder(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.sectionCount,
                  itemBuilder: (context, index) {
                    return _SectionPage(
                      section: InspectionFieldDefs.sections[index],
                      controller: controller,
                      sectionIndex: index,
                    );
                  },
                );
              }),
            ),
            _Footer(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ─── APP BAR ───
// ═══════════════════════════════════════════════
class _AppBar extends StatelessWidget {
  final ScheduleModel schedule;
  const _AppBar({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_headerGradientStart, _headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _headerGradientStart.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.fullCarName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  schedule.appointmentId,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 6, color: Colors.greenAccent),
                SizedBox(width: 6),
                Text(
                  'Inspecting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ─── PROGRESS BAR ───
// ═══════════════════════════════════════════════
class _ProgressBar extends StatelessWidget {
  final InspectionFormController controller;
  const _ProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.sectionCount,
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? _accent.withValues(alpha: 0.1)
                          : (isCompleted
                              ? Colors.green.withValues(alpha: 0.08)
                              : Colors.transparent),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? _accent
                            : (isCompleted
                                ? Colors.green.shade300
                                : Colors.grey.shade300),
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                      ),
                    Text(
                      '${index + 1}. ${controller.sectionTitles[index]}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected
                                ? _accent
                                : (isCompleted
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600),
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
}

// ═══════════════════════════════════════════════
// ─── SECTION PAGE ───
// ═══════════════════════════════════════════════
class _SectionPage extends StatefulWidget {
  final FormSectionDef section;
  final InspectionFormController controller;
  final int sectionIndex;

  const _SectionPage({
    required this.section,
    required this.controller,
    required this.sectionIndex,
  });

  @override
  State<_SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<_SectionPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _fieldKeys = {};
  Worker? _fieldNavWorker;
  String? _highlightedFieldKey;

  @override
  void initState() {
    super.initState();
    // Build GlobalKeys for each field in this section
    for (final field in widget.section.fields) {
      _fieldKeys[field.key] = GlobalKey();
    }
    // Listen for targetFieldKey changes
    _fieldNavWorker = ever(widget.controller.targetFieldKey, (String? key) {
      if (key != null && _fieldKeys.containsKey(key)) {
        _scrollToField(key);
      }
    });
  }

  @override
  void dispose() {
    _fieldNavWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToField(String fieldKey) {
    final gKey = _fieldKeys[fieldKey];
    if (gKey?.currentContext != null) {
      Scrollable.ensureVisible(
        gKey!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.3, // 30% from top
      );
      // Trigger highlight animation
      setState(() => _highlightedFieldKey = fieldKey);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _highlightedFieldKey = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          _SectionHeader(
            title: widget.section.title,
            icon: widget.section.icon,
            sectionNumber: widget.sectionIndex + 1,
            totalSections: widget.controller.sectionCount,
          ),
          const SizedBox(height: 20),
          ...widget.section.fields.map((field) {
            // Define fields that have dynamic visibility
            final visibilityParents = {
              'rcCondition': 'rcBookAvailability',
              'rtoForm28': 'rtoNoc',
              'duplicateKeyImages': 'duplicateKey',
              // Interior / Airbags
              'airbagImages': 'airbagFeaturesDriverSide',
              'coDriverAirbagImages': 'airbagFeaturesCoDriverSide',
              'driverSeatAirbagImages': 'driverSeatAirbag',
              'coDriverSeatAirbagImages': 'coDriverSeatAirbag',
              'rhsCurtainAirbagImages': 'rhsCurtainAirbag',
              'lhsCurtainAirbagImages': 'lhsCurtainAirbag',
              'driverKneeAirbagImages': 'driverSideKneeAirbag',
              'coDriverKneeAirbagImages': 'coDriverKneeSeatAirbag',
              'rhsRearSideAirbagImages': 'rhsRearSideAirbag',
              'lhsRearSideAirbagImages': 'lhsRearSideAirbag',
              // Exterior / Electricals
              'lhsFoglampImages': 'lhsFoglamp',
              'rhsFoglampImages': 'rhsFoglamp',
              'lhsRearFogLampImages': 'lhsRearFogLamp',
              'rhsRearFogLampImages': 'rhsRearFogLamp',
              'rearWiperAndWasherImages': 'rearWiperWasher',
              'reverseCameraImages': 'reverseCamera',
              'sunroofImages': 'sunroof',
              'insuranceImages': 'insurance',
            };

            Widget fieldWidget;
            if (visibilityParents.containsKey(field.key)) {
              fieldWidget = Obx(() {
                final parentKey = visibilityParents[field.key]!;
                final parentVal = widget.controller.getFieldValue(parentKey);

                if (field.key == 'rcCondition') {
                  if (parentVal != 'Original' && parentVal != 'Duplicate') {
                    return const SizedBox.shrink();
                  }
                } else if (field.key == 'rtoForm28') {
                  if (parentVal == 'Not Applicable') {
                    return const SizedBox.shrink();
                  }
                } else if (field.key == 'duplicateKeyImages') {
                  if (parentVal != 'Duplicate Key Available') {
                    return const SizedBox.shrink();
                  }
                } else {
                  if (parentVal == 'Not Applicable' ||
                      parentVal == 'Not Available' ||
                      parentVal == 'Policy Not Available') {
                    return const SizedBox.shrink();
                  }
                }

                return _buildField(field);
              });
            } else {
              fieldWidget = _buildField(field);
            }

            // Wrap with GlobalKey and highlight animation
            final isHighlighted = _highlightedFieldKey == field.key;
            return Container(
              key: _fieldKeys[field.key],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isHighlighted
                      ? Border.all(
                          color: const Color(0xFF0D6EFD).withValues(alpha: 0.6),
                          width: 2,
                        )
                      : null,
                  color: isHighlighted
                      ? const Color(0xFF0D6EFD).withValues(alpha: 0.05)
                      : Colors.transparent,
                ),
                padding: isHighlighted
                    ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                    : EdgeInsets.zero,
                child: fieldWidget,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildField(F field) {
    switch (field.type) {
      case FType.text:
        return _BoundTextField(controller: widget.controller, field: field);
      case FType.dropdown:
        return _BoundDropdown(controller: widget.controller, field: field);
      case FType.image:
        return _BoundImagePicker(controller: widget.controller, field: field);
      case FType.number:
        return _BoundNumberField(controller: widget.controller, field: field);
      case FType.video:
        return _BoundImagePicker(
          controller: widget.controller,
          field: field,
          isVideo: true,
        );
      case FType.date:
        return _BoundDateField(controller: widget.controller, field: field);
    }
  }
}

// ═══════════════════════════════════════════════
// ─── SECTION HEADER ───
// ═══════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int sectionNumber;
  final int totalSections;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.sectionNumber,
    required this.totalSections,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_headerGradientStart, _headerGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Section $sectionNumber of $totalSections',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$sectionNumber/$totalSections',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

// ═══════════════════════════════════════════════
// ─── TEXT FIELD ───
// ═══════════════════════════════════════════════
class _BoundTextField extends StatefulWidget {
  final InspectionFormController controller;
  final F field;
  const _BoundTextField({required this.controller, required this.field});

  @override
  State<_BoundTextField> createState() => _BoundTextFieldState();
}

class _BoundTextFieldState extends State<_BoundTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.getFieldValue(widget.field.key),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = widget.controller.getFieldValue(widget.field.key);
      if (_textController.text != value) {
        _textController.text = value;
      }

      final isRegNumber = widget.field.key == 'registrationNumber';

      final isFilled = value.isNotEmpty;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _fieldWrapper(
                isFilled: isFilled,
                bottomMargin: 0,
                child: TextFormField(
                  controller: _textController,
                  maxLines: widget.field.maxLines,
                  readOnly: widget.field.readonly,
                  onChanged:
                      (v) => widget.controller.updateField(widget.field.key, v),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _styledDecoration(
                    label: widget.field.label,
                    isOptional: widget.field.optional,
                    isFilled: isFilled,
                    suffixIcon: widget.field.readonly
                        ? Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: Colors.grey.shade400,
                        )
                        : null,
                  ),
                ),
              ),
            ),
            if (isRegNumber && !widget.controller.isReInspection)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  height: 45,
                  child: Obx(() {
                    final isFetching =
                        widget.controller.isFetchingDetails.value;
                    return ElevatedButton(
                      onPressed:
                          isFetching
                              ? null
                              : () =>
                                  widget.controller.autoFetchVehicleDetails(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child:
                          isFetching
                              ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: _SpinningIcon(),
                              )
                              : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh_rounded, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Fetch'.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                    );
                  }),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon();

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.refresh_rounded, size: 20),
    );
  }
}

// ═══════════════════════════════════════════════
// ─── DATE FIELD ───
// ═══════════════════════════════════════════════
class _BoundDateField extends StatelessWidget {
  final InspectionFormController controller;
  final F field;
  const _BoundDateField({required this.controller, required this.field});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rawValue = controller.getFieldValue(field.key);
      String displayText = '';
      DateTime? currentDate;

      if (rawValue.isNotEmpty) {
        // Try parsing as ISO date first
        currentDate = DateTime.tryParse(rawValue);
        if (currentDate != null) {
          displayText =
              '${currentDate.day.toString().padLeft(2, '0')}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.year}';
        } else {
          // Try parsing DD-MM-YYYY format
          final parts = rawValue.split('-');
          if (parts.length == 3) {
            final d = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            final y = int.tryParse(parts[2]);
            if (d != null && m != null && y != null) {
              currentDate = DateTime(y, m, d);
              displayText = rawValue;
            }
          }
          // Try MM-YYYY format
          if (currentDate == null && parts.length == 2) {
            final m = int.tryParse(parts[0]);
            final y = int.tryParse(parts[1]);
            if (m != null && y != null) {
              currentDate = DateTime(y, m);
              displayText = rawValue;
            }
          }
          // Fall back to raw value
          if (displayText.isEmpty) displayText = rawValue;
        }
      }

      final isFilled = displayText.isNotEmpty;

      return _fieldWrapper(
        isFilled: isFilled,
        child: Material(
          color: isFilled ? _filledBg : _emptyBg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: currentDate ?? now,
                firstDate: DateTime(1990),
                lastDate: DateTime(2040),
                builder: (ctx, child) {
                  return Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: _accent,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Color(0xFF1E293B),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                controller.updateField(field.key, picked.toIso8601String());
              }
            },
            child: InputDecorator(
              decoration: _styledDecoration(
                label: field.label,
                isOptional: field.optional,
                isFilled: isFilled,
                suffixIcon: Icon(
                  Icons.calendar_today_rounded,
                  color: isFilled ? _filledGreen : _accent,
                  size: 20,
                ),
              ),
              child: Text(
                displayText.isNotEmpty ? displayText : 'Select date',
                style: TextStyle(
                  color: displayText.isNotEmpty
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════
// ─── NUMBER FIELD ───
// ═══════════════════════════════════════════════
class _BoundNumberField extends StatefulWidget {
  final InspectionFormController controller;
  final F field;
  const _BoundNumberField({required this.controller, required this.field});

  @override
  State<_BoundNumberField> createState() => _BoundNumberFieldState();
}

class _BoundNumberFieldState extends State<_BoundNumberField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final val = widget.controller.getFieldValue(widget.field.key);
    _textController = TextEditingController(text: val == '0' ? '' : val);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final val = widget.controller.getFieldValue(widget.field.key);
      final displayVal = (val == '0' || val.isEmpty) ? '' : val;
      if (_textController.text != displayVal) {
        _textController.text = displayVal;
      }

      final isFilled = displayVal.isNotEmpty;

      return _fieldWrapper(
        isFilled: isFilled,
        child: TextFormField(
          controller: _textController,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final parsed = int.tryParse(v) ?? 0;
            widget.controller.updateField(widget.field.key, parsed);
          },
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: _styledDecoration(
            label: widget.field.label,
            isOptional: widget.field.optional,
            isFilled: isFilled,
            prefixIcon: Icon(
              Icons.numbers_rounded,
              size: 18,
              color: isFilled ? _filledGreen.withValues(alpha: 0.7) : _accent.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════
// ─── DROPDOWN ───
// ═══════════════════════════════════════════════
class _BoundDropdown extends StatefulWidget {
  final InspectionFormController controller;
  final F field;
  const _BoundDropdown({required this.controller, required this.field});

  @override
  State<_BoundDropdown> createState() => _BoundDropdownState();
}

class _BoundDropdownState extends State<_BoundDropdown> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = widget.controller.getFieldValue(widget.field.key);
      final dynamicOptions =
          widget.controller.dropdownOptions[widget.field.key];
      final options =
          (dynamicOptions != null && dynamicOptions.isNotEmpty)
              ? dynamicOptions
              : widget.field.options;

      final selectedValue =
          (value.isNotEmpty && options.contains(value)) ? value : null;

      final isFilled = selectedValue != null && selectedValue.isNotEmpty;

      return _fieldWrapper(
        isFilled: isFilled,
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          decoration: _styledDecoration(
            label: widget.field.label,
            isOptional: widget.field.optional,
            isFilled: isFilled,
            prefixIcon: Icon(
              Icons.list_rounded,
              size: 18,
              color: isFilled ? _filledGreen.withValues(alpha: 0.7) : _accent.withValues(alpha: 0.6),
            ),
          ).copyWith(
            floatingLabelStyle: TextStyle(
              color: isFilled ? _filledGreen : const Color(0xFF0D6EFD),
              fontWeight: FontWeight.bold,
            ),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isFilled ? _filledGreen.withValues(alpha: 0.7) : _accent.withValues(alpha: 0.7),
          ),
          items:
              options
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: (v) {
            if (v != null) {
              widget.controller.updateField(widget.field.key, v);
            }
          },
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════
// ─── IMAGE PICKER ───
// ═══════════════════════════════════════════════
class _BoundImagePicker extends StatelessWidget {
  final InspectionFormController controller;
  final F field;
  final bool isVideo;
  const _BoundImagePicker({
    required this.controller,
    required this.field,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVideoField = isVideo || field.type == FType.video;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  isVideoField
                      ? Icons.videocam_rounded
                      : Icons.camera_alt_rounded,
                  size: 16,
                  color: _accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: field.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                      children: [
                        if (!field.optional)
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image/Video preview grid
          Obx(() {
            controller.imageFiles.length; // trigger reactivity
            final media = controller.getImages(field.key);

            return Column(
              children: [
                if (media.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: media.length,
                      itemBuilder: (context, index) {
                        if (isVideoField) {
                          return _VideoThumbnail(
                            path: media[index],
                            onRemove:
                                () => controller.removeImage(field.key, index),
                          );
                        }
                        return _ImageThumbnail(
                          path: media[index],
                          onRemove:
                              () => controller.removeImage(field.key, index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _ImageUploadButton(
                  isVideo: isVideoField,
                  currentCount: media.length,
                  maxCount: field.maxImages,
                  onTap: () => _showPickerSheet(context),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showPickerSheet(BuildContext context) {
    final bool isVideoField = isVideo || field.type == FType.video;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isVideoField ? 'Add Video' : 'Add Photo',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  field.label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _PickerOption(
                        icon:
                            isVideoField
                                ? Icons.videocam_rounded
                                : Icons.camera_alt_rounded,
                        label: 'Camera',
                        color: _accent,
                        onTap: () {
                          Navigator.pop(ctx);
                          if (isVideoField) {
                            controller.pickVideo(field.key, ImageSource.camera);
                          } else {
                            controller.pickImage(field.key, ImageSource.camera);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PickerOption(
                        icon:
                            isVideoField
                                ? Icons.video_library_rounded
                                : Icons.photo_library_rounded,
                        label: 'Gallery',
                        color: const Color(0xFF7C3AED),
                        onTap: () {
                          Navigator.pop(ctx);
                          if (isVideoField) {
                            controller.pickVideo(
                              field.key,
                              ImageSource.gallery,
                            );
                          } else {
                            controller.pickImage(
                              field.key,
                              ImageSource.gallery,
                            );
                          }
                        },
                      ),
                    ),
                    if (!isVideoField) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: _PickerOption(
                          icon: Icons.photo_album_rounded,
                          label: 'Multiple',
                          color: const Color(0xFF059669),
                          onTap: () {
                            Navigator.pop(ctx);
                            controller.pickMultipleImages(field.key);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _ImageThumbnail({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black87,
          useSafeArea: false,
          builder: (dialogCtx) => Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    child:
                        path.startsWith('http')
                            ? Image.network(
                              path,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (c, e, s) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                            : Image.file(
                              File(path),
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (c, e, s) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                            ),
                  ),
                ),
                // Close button (top-right)
                Positioned(
                  top: MediaQuery.of(dialogCtx).padding.top + 8,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogCtx).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                // Back button (top-left)
                Positioned(
                  top: MediaQuery.of(dialogCtx).padding.top + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogCtx).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              path.startsWith('http')
                  ? Image.network(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, e, s) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  )
                  : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, e, s) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
              ),
              // Remove button
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageUploadButton extends StatelessWidget {
  final VoidCallback onTap;
  final int currentCount;
  final int maxCount;
  final bool isVideo;

  const _ImageUploadButton({
    required this.onTap,
    required this.currentCount,
    required this.maxCount,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLimitReached = maxCount > 0 && currentCount >= maxCount;
    final bool hasImages = currentCount > 0;

    String label = isVideo ? 'Tap to Add Video' : 'Tap to Add Photos';
    if (hasImages) {
      if (isLimitReached) {
        label = isVideo ? 'Video Limit Reached' : 'Photo Limit Reached';
      } else {
        label = isVideo ? 'Add More Videos' : 'Add More Photos';
      }
    }

    return GestureDetector(
      onTap: isLimitReached ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: hasImages ? 52 : 84,
        decoration: BoxDecoration(
          color: isLimitReached ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isLimitReached
                    ? Colors.grey.shade300
                    : _accent.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow:
              hasImages
                  ? []
                  : [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVideo
                        ? (hasImages
                            ? Icons.video_call_rounded
                            : Icons.videocam_rounded)
                        : (hasImages
                            ? Icons.add_photo_alternate_rounded
                            : Icons.add_a_photo_rounded),
                    color:
                        isLimitReached
                            ? Colors.grey
                            : _accent.withValues(alpha: 0.7),
                    size: hasImages ? 22 : 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: isLimitReached ? Colors.grey : _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: hasImages ? 14 : 15,
                    ),
                  ),
                ],
              ),
            ),
            if (maxCount > 0)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isLimitReached
                              ? Colors.grey.shade200
                              : _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$currentCount / $maxCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLimitReached ? Colors.grey : _accent,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _VideoThumbnail({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _VideoPreviewScreen(videoPath: path)),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: _accent,
                size: 40,
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Text(
                path.split('/').last,
                style: const TextStyle(fontSize: 8, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPreviewScreen extends StatefulWidget {
  final String videoPath;
  const _VideoPreviewScreen({required this.videoPath});

  @override
  State<_VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<_VideoPreviewScreen> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final isNetwork = widget.videoPath.startsWith('http');
      if (isNetwork) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoPath),
        );
      } else {
        final file = File(widget.videoPath);
        if (!file.existsSync()) {
          debugPrint('❌ Video file does NOT exist: ${widget.videoPath}');
          if (mounted) setState(() => _isError = true);
          return;
        }
        _controller = VideoPlayerController.file(file);
      }
      await _controller.initialize();
      if (mounted) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      }
    } catch (e) {
      debugPrint('❌ Video player error: $e');
      if (mounted) setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Video Preview'),
      ),
      body: Center(
        child:
            _isError
                ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Error loading video',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
                : _controller.value.isInitialized
                ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller),
                      VideoProgressIndicator(_controller, allowScrubbing: true),
                      Positioned(
                        bottom: 20,
                        child: FloatingActionButton(
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ─── FOOTER ───
// ═══════════════════════════════════════════════
class _Footer extends StatelessWidget {
  final InspectionFormController controller;
  const _Footer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        bottomPadding > 0 ? bottomPadding + 6 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final isEnabled =
            !controller.isLoading.value &&
            !controller.isSubmitting.value &&
            !controller.isSaving.value &&
            controller.inspectionData.value != null;
        final isFirst = controller.currentSectionIndex.value == 0;
        final isLast =
            controller.currentSectionIndex.value == controller.sectionCount - 1;

        return Row(
          children: [
            // Previous / Back
            _FooterButton(
              icon: Icons.arrow_back_rounded,
              label: isFirst ? 'Back' : 'Prev',
              color: Colors.grey.shade600,
              compact: true,
              onTap:
                  isEnabled
                      ? () {
                        if (isFirst) {
                          Navigator.of(context).pop();
                        } else {
                          controller.previousSection();
                        }
                      }
                      : null,
            ),

            const Spacer(),

            // Save Draft
            controller.isSaving.value
                ? Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
                  ),
                )
                : _FooterButton(
                  icon: Icons.save_rounded,
                  label: 'Save',
                  color: Colors.orange.shade700,
                  onTap: isEnabled ? () => controller.saveInspection() : null,
                ),

            const SizedBox(width: 12),

            // Submit
            controller.isSubmitting.value
                ? Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
                  ),
                )
                : _FooterButton(
                  icon: Icons.check_circle_rounded,
                  label: 'Submit',
                  color: Colors.green.shade700,
                  onTap: isEnabled ? () => controller.submitInspection() : null,
                ),

            const Spacer(),

            // Next
            _FooterButton(
              icon: Icons.arrow_forward_rounded,
              label: isLast ? 'End' : 'Next',
              color: isLast ? Colors.grey.shade400 : _accent,
              compact: true,
              onTap: (isEnabled && !isLast) ? controller.nextSection : null,
            ),
          ],
        );
      }),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool compact;
  final VoidCallback? onTap;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.color,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final effectiveColor = isDisabled ? Colors.grey.shade400 : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color:
                isDisabled
                    ? Colors.grey.shade100
                    : effectiveColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDisabled
                      ? Colors.transparent
                      : effectiveColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: effectiveColor, size: 20),
              if (!compact) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: effectiveColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
