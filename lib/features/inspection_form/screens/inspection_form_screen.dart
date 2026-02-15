import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../schedules/models/schedule_model.dart';
import '../controllers/inspection_form_controller.dart';
import '../models/inspection_field_defs.dart';

// ─── Custom accent color (replaces TColors.primary yellow) ───
const Color _accent = Color(0xFF0D6EFD); // Vibrant royal blue
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            onTap: () => Get.back(),
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
class _SectionPage extends StatelessWidget {
  final FormSectionDef section;
  final InspectionFormController controller;
  final int sectionIndex;

  const _SectionPage({
    required this.section,
    required this.controller,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          _SectionHeader(
            title: section.title,
            icon: section.icon,
            sectionNumber: sectionIndex + 1,
            totalSections: controller.sectionCount,
          ),
          const SizedBox(height: 20),
          ...section.fields.map((field) => _buildField(field)),
        ],
      ),
    );
  }

  Widget _buildField(F field) {
    switch (field.type) {
      case FType.text:
        return _BoundTextField(controller: controller, field: field);
      case FType.dropdown:
        return _BoundDropdown(controller: controller, field: field);
      case FType.image:
        return _BoundImagePicker(controller: controller, field: field);
      case FType.number:
        return _BoundNumberField(controller: controller, field: field);
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
    final isOptional = widget.field.optional;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _textController,
        maxLines: widget.field.maxLines,
        readOnly: widget.field.readonly,
        onChanged: (v) => widget.controller.updateField(widget.field.key, v),
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText:
              isOptional
                  ? '${widget.field.label} (Optional)'
                  : widget.field.label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon:
              widget.field.readonly
                  ? Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: Colors.grey.shade400,
                  )
                  : null,
        ),
      ),
    );
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
        decoration: InputDecoration(
          labelText: widget.field.label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Icon(
            Icons.numbers_rounded,
            size: 18,
            color: _accent.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
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
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    final rawValue = widget.controller.getFieldValue(widget.field.key);
    _selectedValue =
        (rawValue.isNotEmpty && widget.field.options.contains(rawValue))
            ? rawValue
            : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: widget.field.label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
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
          color: _accent.withValues(alpha: 0.7),
        ),
        items:
            widget.field.options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => _selectedValue = v);
            widget.controller.updateField(widget.field.key, v);
          }
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ─── IMAGE PICKER ───
// ═══════════════════════════════════════════════
class _BoundImagePicker extends StatelessWidget {
  final InspectionFormController controller;
  final F field;
  const _BoundImagePicker({required this.controller, required this.field});

  @override
  Widget build(BuildContext context) {
    final isOptional = field.optional;

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
                const Icon(Icons.camera_alt_rounded, size: 16, color: _accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isOptional ? '${field.label} (Optional)' : field.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image preview grid
          Obx(() {
            controller.imageFiles.length; // trigger reactivity
            final images = controller.getImages(field.key);

            return Column(
              children: [
                if (images.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return _ImageThumbnail(
                          path: images[index],
                          onRemove:
                              () => controller.removeImage(field.key, index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _ImageUploadButton(
                  hasImages: images.isNotEmpty,
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
                const Text(
                  'Add Photo',
                  style: TextStyle(
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
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        color: _accent,
                        onTap: () {
                          Navigator.pop(ctx);
                          controller.pickImage(field.key, ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PickerOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        color: const Color(0xFF7C3AED),
                        onTap: () {
                          Navigator.pop(ctx);
                          controller.pickImage(field.key, ImageSource.gallery);
                        },
                      ),
                    ),
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
    return Container(
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
            Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder:
                  (c, e, s) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
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
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageUploadButton extends StatelessWidget {
  final bool hasImages;
  final VoidCallback onTap;
  const _ImageUploadButton({required this.hasImages, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: hasImages ? 48 : 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accent.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasImages
                    ? Icons.add_photo_alternate_rounded
                    : Icons.add_a_photo_rounded,
                color: _accent.withValues(alpha: 0.7),
                size: hasImages ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                hasImages ? 'Add More Photos' : 'Tap to Add Photos',
                style: TextStyle(
                  color: _accent.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: hasImages ? 13 : 14,
                ),
              ),
            ],
          ),
        ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
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
                          Get.back();
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
