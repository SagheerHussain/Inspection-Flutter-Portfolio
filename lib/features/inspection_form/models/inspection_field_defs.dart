import 'package:flutter/material.dart';

/// Field type enum
enum FType { text, dropdown, image, number, video, date }

/// Single form field definition
class F {
  final String key;
  final String label;
  final FType type;
  final List<String> options;
  final bool optional;
  final bool readonly;
  final int maxLines;
  final int minImages;
  final int maxImages;
  final int? maxDuration;

  const F.text(
    this.key,
    this.label, {
    this.optional = false,
    this.readonly = false,
    this.maxLines = 1,
  }) : type = FType.text,
       options = const [],
       minImages = 0,
       maxImages = 0,
       maxDuration = null;

  const F.drop(this.key, this.label, this.options, {this.optional = false})
    : type = FType.dropdown,
      readonly = false,
      maxLines = 1,
      minImages = 0,
      maxImages = 0,
      maxDuration = null;

  const F.img(
    this.key,
    this.label, {
    this.optional = false,
    this.minImages = 1,
    this.maxImages = 3,
  }) : type = FType.image,
       options = const [],
       readonly = false,
       maxLines = 1,
       maxDuration = null;

  const F.num(this.key, this.label, {this.optional = false})
    : type = FType.number,
      options = const [],
      readonly = false,
      maxLines = 1,
      minImages = 0,
      maxImages = 0,
       maxDuration = null;

  const F.date(
    this.key,
    this.label, {
    this.optional = false,
  }) : type = FType.date,
       options = const [],
       readonly = false,
       maxLines = 1,
       minImages = 0,
       maxImages = 0,
       maxDuration = null;

  const F.video(
    this.key,
    this.label, {
    this.optional = false,
    this.minImages = 1,
    this.maxImages = 1,
    this.maxDuration,
  }) : type = FType.video,
       options = const [],
       readonly = false,
       maxLines = 1;
}

/// A section in the form
class FormSectionDef {
  final String title;
  final IconData icon;
  final List<F> fields;
  const FormSectionDef({
    required this.title,
    required this.icon,
    required this.fields,
  });
}

/// All 9 sections with exact fields from API payload
class InspectionFieldDefs {
  InspectionFieldDefs._();

  static const List<FormSectionDef> sections = [
    // ═══════════════════════════════════════
    // 1. DOCUMENTS
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Document Details',
      icon: Icons.description,
      fields: [
        F.text('appointmentId', 'Appointment ID', readonly: true),
        F.text('city', 'City', readonly: true),
        F.text('registrationNumber', 'Registration Number'),
        F.drop('toBeScrapped', 'To Be Scrapped', ['Yes', 'No']),
        F.text('chassisDetails', 'Chassis Details'),
        F.img('chassisEmbossmentImages', 'Chassis Embossment Image'),
        F.text('vinPlateDetails', 'Vin Plate Details'),
        F.img('vinPlateImages', 'Vin Plate Image'),
        F.drop('rcBookAvailability', 'RC Book Availability', [
          'Original',
          'Duplicate',
          'Not Available',
        ]),
        F.drop('rcCondition', 'RC Condition', [
          'Good',
          'Fair',
          'Poor',
          'Damaged',
        ]),
        F.img('rcTokenImages', 'RC Token Image', minImages: 2),
        F.drop('mismatchInRc', 'Mismatch in RC', ['No', 'Yes']),
        F.date('registrationDate', 'Registration Date'),
        F.date('fitnessValidity', 'Fitness Validity'),
        F.text('engineNumber', 'Engine Number'),
        F.text('chassisNumber', 'Chassis Number'),
        F.text('make', 'Make'),
        F.text('model', 'Model'),
        F.text('variant', 'Variant'),
        F.date('yearMonthOfManufacture', 'Vehicle Manufacture'),
        F.drop('fuelType', 'Fuel Type', [
          'Petrol',
          'Diesel',
          'CNG',
          'Electric',
          'Hybrid',
          'LPG',
        ]),
        F.num('seatingCapacity', 'Seating Capacity'),
        F.text('color', 'Color'),
        F.num('cubicCapacity', 'Cubic Capacity'),
        F.drop('norms', 'Norms', ['BS4', 'BS6', 'BS3']),
        F.text('registrationState', 'Registration State'),
        F.text('registeredRto', 'Registered RTO'),
        F.num('ownerSerialNumber', 'Ownership Serial No'),
        F.text('registeredOwner', 'Registered Owner'),
        F.text(
          'registeredAddressAsPerRc',
          'Registered Address as per RC',
          maxLines: 3,
        ),
        F.drop('roadTaxValidity', 'Road Tax Validity', [
          'Valid',
          'Expired',
          'Lifetime',
        ]),
        F.date('taxValidTill', 'Tax Valid Till'),
        F.img('roadTaxImages', 'Road Tax Image', minImages: 1),
        F.text('hypothecationDetails', 'Hypothecation Details'),
        F.text('hypothecatedTo', 'Hypothecated To'),
        F.drop('insurance', 'Insurance Type', [
          'Comprehensive',
          'Third Party',
          'Expired',
          'Not Available',
          'Policy Not Available',
        ]),
        F.date('insuranceValidity', 'Insurance Validity'),
        F.text('insurer', 'Insured By'),
        F.text('insurancePolicyNumber', 'Policy Number'),
        F.img('insuranceImages', 'Insurance Image'),
        F.date('pucValidity', 'PUC Validity'),
        F.text('pucNumber', 'PUC Number'),
        F.img('pucImages', 'PUC Image'),
        F.drop('rcStatus', 'RC Status', ['Active', 'Inactive', 'Suspended']),
        F.drop('blacklistStatus', 'Blacklist Status', ['Clear', 'Blacklisted']),
        F.drop('rtoNoc', 'RTO NOC Details', [
          'Required',
          'Not Required',
          'Issued',
          'Not Applicable',
        ]),
        F.drop('rtoForm28', 'RTO Form 28 (2 Copies)', [
          'Required',
          'Not Required',
          'Available',
        ]),
        F.drop('partyPeshi', 'Party Peshi', ['Yes', 'No']),
        F.drop('duplicateKey', 'Duplicate Key', [
          'Yes',
          'No',
          'Duplicate Key Available',
        ]),
        F.img('duplicateKeyImages', 'Duplicate Key Images'),
        F.text(
          'additionalDetails',
          'Additional Details',
          optional: true,
          maxLines: 3,
        ),
      ],
    ),

    // ═══════════════════════════════════════
    // 2. FRONT
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Front',
      icon: Icons.directions_car,
      fields: [
        F.img('frontMainImages', 'Front Main'),
        F.drop('bonnet', 'Bonnet', [
          'OK',
          'Repaint',
          'Dent',
          'Scratch',
          'Rust',
          'Replaced',
        ]),
        F.img('bonnetOpenImages', 'Bonnet Open'),
        F.img('bonnetClosedImages', 'Bonnet Closed'),
        F.drop('frontWindshield', 'Front Windshield', [
          'OK',
          'Crack',
          'Chip',
          'Replaced',
        ]),
        F.img('frontWindshieldImages', 'Front Windshield Image'),
        F.drop('frontWiperAndWasher', 'Front Wiper & Washer', [
          'Working',
          'Not Working',
        ]),
        F.img('frontWiperAndWasherImages', 'Front Wiper & Washer Image'),
        F.drop('roof', 'Roof', ['OK', 'Repaint', 'Dent', 'Scratch', 'Rust']),
        F.img('roofImages', 'Roof Image'),
        F.drop('frontBumper', 'Front Bumper', [
          'OK',
          'Scratch',
          'Crack',
          'Dent',
          'Replaced',
        ]),
        F.img('frontBumperLhs45DegreeImages', 'Front Bumper LHS 45'),
        F.img('frontBumperRhs45DegreeImages', 'Front Bumper RHS 45'),
        F.img('frontBumperImages', 'Front Bumper Image', optional: true),
        F.drop('lhsHeadlamp', 'LHS Headlamp', [
          'OK',
          'Broken',
          'Fogged',
          'Replaced',
        ]),
        F.img('lhsHeadlampImages', 'LHS Headlamp Image'),
        F.drop('lhsFoglamp', 'LHS Foglamp', [
          'OK',
          'Broken',
          'Not Present',
          'Not Applicable',
        ]),
        F.img('lhsFoglampImages', 'LHS Foglamp Image'),
        F.drop('rhsHeadlamp', 'RHS Headlamp', [
          'OK',
          'Broken',
          'Fogged',
          'Replaced',
        ]),
        F.img('rhsHeadlampImages', 'RHS Headlamp Image'),
        F.drop('rhsFoglamp', 'RHS Foglamp', [
          'OK',
          'Broken',
          'Not Present',
          'Not Applicable',
        ]),
        F.img('rhsFoglampImages', 'RHS Foglamp Image'),
      ],
    ),

    // ═══════════════════════════════════════
    // 3. LEFT
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Left',
      icon: Icons.arrow_back,
      fields: [
        F.img('lhsFullViewImages', 'LHS Full View'),
        F.drop('lhsFender', 'LHS Fender', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Rust',
          'Replaced',
        ]),
        F.img('lhsFenderImages', 'LHS Fender Image'),
        F.drop('lhsFrontAlloy', 'LHS Front Wheel', [
          'OK',
          'Bent',
          'Cracked',
          'Replaced',
        ]),
        F.img('lhsFrontWheelImages', 'LHS Front Wheel Image'),
        F.drop('lhsFrontTyre', 'LHS Front Tyre', [
          'OK',
          'Worn',
          'Bald',
          'Mismatched',
        ]),
        F.img('lhsFrontTyreImages', 'LHS Front Tyre Image'),
        F.drop('lhsOrvm', 'LHS ORVM', ['OK', 'Broken', 'Missing', 'Scratched']),
        F.img('lhsOrvmImages', 'LHS ORVM Image'),
        F.drop('lhsAPillar', 'LHS A Pillar', [
          'OK',
          'Repaired',
          'Dented',
          'Repainted',
        ]),
        F.img('lhsAPillarImages', 'LHS A Pillar Image'),
        F.drop('lhsFrontDoor', 'LHS Front Door', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Replaced',
        ]),
        F.img('lhsFrontDoorImages', 'LHS Front Door Image'),
        F.drop('lhsBPillar', 'LHS B Pillar', [
          'OK',
          'Repaired',
          'Dented',
          'Repainted',
        ]),
        F.img('lhsBPillarImages', 'LHS B Pillar Image'),
        F.drop('lhsRearDoor', 'LHS Rear Door', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Replaced',
        ]),
        F.img('lhsRearDoorImages', 'LHS Rear Door Image'),
        F.drop('lhsCPillar', 'LHS C Pillar', [
          'OK',
          'Repaired',
          'Dented',
          'Repainted',
        ]),
        F.img('lhsCPillarImages', 'LHS C Pillar Image'),
        F.drop('lhsRunningBorder', 'LHS Running Border', [
          'OK',
          'Dent',
          'Rust',
          'Damaged',
        ]),
        F.img('lhsRunningBorderImages', 'LHS Running Border Image'),
        F.drop('lhsRearAlloy', 'LHS Rear Wheel', [
          'OK',
          'Bent',
          'Cracked',
          'Replaced',
        ]),
        F.img('lhsRearWheelImages', 'LHS Rear Wheel Image'),
        F.drop('lhsRearTyre', 'LHS Rear Tyre', [
          'OK',
          'Worn',
          'Bald',
          'Mismatched',
        ]),
        F.img('lhsRearTyreImages', 'LHS Rear Tyre Image'),
        F.drop('lhsQuarterPanel', 'LHS Quarter Panel', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Replaced',
        ]),
        F.img(
          'lhsQuarterPanelWithRearDoorOpenImages',
          'LHS Quarter Panel With Boot Door Open Image',
        ),
        F.img('lhsQuarterPanelImages', 'LHS Quarter Panel Image'),
      ],
    ),

    // ═══════════════════════════════════════
    // 4. REAR
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Rear',
      icon: Icons.arrow_downward,
      fields: [
        F.img('rearMainImages', 'Rear Main'),
        F.drop('rearBumper', 'Rear Bumper', [
          'OK',
          'Scratch',
          'Crack',
          'Dent',
          'Replaced',
        ]),
        F.img('rearBumperLhs45DegreeImages', 'Rear Bumper LHS 45'),
        F.img('rearBumperRhs45DegreeImages', 'Rear Bumper RHS 45'),
        F.img('rearBumperImages', 'Rear Bumper Image'),
        F.drop('lhsTailLamp', 'LHS Tail Lamp', ['OK', 'Broken', 'Fogged']),
        F.img('lhsTailLampImages', 'LHS Tail Lamp Image'),
        F.drop('lhsRearFogLamp', 'LHS Rear Fog Lamp', [
          'Present',
          'Not Present',
          'Broken',
          'Not Applicable',
        ]),
        F.img('lhsRearFogLampImages', 'LHS Rear Fog Lamp Image'),
        F.drop('rhsTailLamp', 'RHS Tail Lamp', ['OK', 'Broken', 'Fogged']),
        F.img('rhsTailLampImages', 'RHS Tail Lamp Image'),
        F.drop('rhsRearFogLamp', 'RHS Rear Fog Lamp', [
          'Present',
          'Not Present',
          'Broken',
          'Not Applicable',
        ]),
        F.img('rhsRearFogLampImages', 'RHS Rear Fog Lamp Image'),
        F.drop('rearWindshield', 'Rear Windshield', [
          'OK',
          'Crack',
          'Chip',
          'Replaced',
        ]),
        F.img('rearWindshieldImages', 'Rear Windshield Image'),
        F.drop('bootDoor', 'Boot Door', [
          'OK',
          'Dent',
          'Scratch',
          'Repaint',
          'Replaced',
        ]),
        F.img('bootDoorImages', 'Boot Door Image', optional: true),
        F.img('rearWithBootDoorOpenImages', 'Rear With Boot Door Open Image'),
        F.drop('spareWheel', 'Spare Wheel', ['Available', 'Not Available']),
        F.img('spareWheelImages', 'Spare Wheel Image'),
        F.drop('spareTyre', 'Spare Tyre', [
          'Available',
          'Not Available',
          'Worn',
        ]),
        F.img('spareTyreImages', 'Spare Tyre Image'),
        F.drop('bootFloor', 'Boot Floor', ['OK', 'Rust', 'Damaged']),
        F.img('bootFloorImages', 'Boot Floor Image'),
      ],
    ),

    // ═══════════════════════════════════════
    // 5. RIGHT
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Right',
      icon: Icons.arrow_forward,
      fields: [
        F.img('rhsFullViewImages', 'RHS Full View'),
        F.drop('rhsQuarterPanel', 'RHS Quarter Panel', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Replaced',
        ]),
        F.img(
          'rhsQuarterPanelWithRearDoorOpenImages',
          'RHS Quarter Panel With Boot Door Open',
        ),
        F.img('rhsQuarterPanelImages', 'RHS Quarter Panel Image'),
        F.drop('rhsRearAlloy', 'RHS Rear Wheel', [
          'OK',
          'Bent',
          'Cracked',
          'Replaced',
        ]),
        F.img('rhsRearWheelImages', 'RHS Rear Wheel Image'),
        F.drop('rhsRearTyre', 'RHS Rear Tyre', [
          'OK',
          'Worn',
          'Bald',
          'Mismatched',
        ]),
        F.img('rhsRearTyreImages', 'RHS Rear Tyre Image'),
        F.drop('rhsRunningBorder', 'RHS Running Border', [
          'OK',
          'Dent',
          'Rust',
          'Damaged',
        ]),
        F.img('rhsRunningBorderImages', 'RHS Running Border Image'),
        F.drop('rhsCPillar', 'RHS C Pillar', [
          'OK',
          'Repaired',
          'Dented',
          'Repainted',
        ]),
        F.img('rhsCPillarImages', 'RHS C Pillar Image'),
        F.drop('rhsRearDoor', 'RHS Rear Door', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Replaced',
        ]),
        F.img('rhsRearDoorImages', 'RHS Rear Door Image'),
        F.drop('rhsBPillar', 'RHS B Pillar', [
          'OK',
          'Repaired',
          'Dented',
          'Repainted',
        ]),
        F.img('rhsBPillarImages', 'RHS B Pillar Image'),
        F.drop('rhsFrontDoor', 'RHS Front Door', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Replaced',
        ]),
        F.img('rhsFrontDoorImages', 'RHS Front Door Image'),
        F.drop('rhsAPillar', 'RHS A Pillar', [
          'OK',
          'Repaired',
          'Dented',
          'Repainted',
        ]),
        F.img('rhsAPillarImages', 'RHS A Pillar Image'),
        F.drop('rhsOrvm', 'RHS ORVM', ['OK', 'Broken', 'Missing', 'Scratched']),
        F.img('rhsOrvmImages', 'RHS ORVM Image'),
        F.drop('rhsFrontAlloy', 'RHS Front Wheel', [
          'OK',
          'Bent',
          'Cracked',
          'Replaced',
        ]),
        F.img('rhsFrontWheelImages', 'RHS Front Wheel Image'),
        F.drop('rhsFrontTyre', 'RHS Front Tyre', [
          'OK',
          'Worn',
          'Bald',
          'Mismatched',
        ]),
        F.img('rhsFrontTyreImages', 'RHS Front Tyre Image'),
        F.drop('rhsFender', 'RHS Fender', [
          'OK',
          'Scratch',
          'Dent',
          'Repaint',
          'Rust',
          'Replaced',
        ]),
        F.img('rhsFenderImages', 'RHS Fender Image'),
      ],
    ),

    // ═══════════════════════════════════════
    // 6. ENGINE BAY
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Engine Bay',
      icon: Icons.engineering,
      fields: [
        F.img('engineBayImages', 'Engine Bay'),
        F.video('engineVideo', 'Engine Sound Video', maxDuration: 15),
        F.drop('engine', 'Engine', [
          'OK',
          'Noise',
          'Leak',
          'Misfire',
          'Seized',
        ]),
        F.text(
          'commentsOnEngine',
          'Comment on Engine',
          optional: true,
          maxLines: 2,
        ),
        F.drop('engineOilLevelDipstick', 'Engine Oil Level Dipstick', [
          'OK',
          'Low',
          'High',
          'Empty',
        ]),
        F.drop('engineOil', 'Engine Oil', [
          'OK',
          'Low',
          'Dirty',
          'Sludge',
          'Leakage',
        ]),
        F.text(
          'commentsOnEngineOil',
          'Comment on Engine Oil',
          optional: true,
          maxLines: 2,
        ),
        F.drop('enginePermisableBlowBy', 'Engine Permisable Blowby', [
          'No',
          'Yes',
        ]),
        F.drop('coolant', 'Coolant', [
          'OK',
          'Low',
          'Dirty',
          'Leakage',
          'Empty',
        ]),
        F.drop('cowlTop', 'Cowl Top', ['OK', 'Repaired', 'Damaged']),
        F.img('cowlTopImages', 'Cowl Top Image'),
        F.drop('firewall', 'Firewall', ['OK', 'Repaired', 'Damaged']),
        F.img('firewallImages', 'Firewall Image'),
        F.drop('abs', 'ABS', ['Working', 'Not Working', 'Not Available']),
        F.drop('lhsApron', 'LHS Apron', ['OK', 'Repaired', 'Damaged']),
        F.img('lhsApronImages', 'LHS Apron Image'),
        F.drop('rhsApron', 'RHS Apron', ['OK', 'Repaired', 'Damaged']),
        F.img('rhsApronImages', 'RHS Apron Image'),
        F.drop('battery', 'Battery', ['OK', 'Weak', 'Replace', 'Dead']),
        F.img('batteryImages', 'Battery Image'),
        F.drop('upperCrossMember', 'Upper Cross Member', [
          'OK',
          'Repaired',
          'Damaged',
        ]),
        F.drop('lhsSideMember', 'LHS Side Member', [
          'OK',
          'Repaired',
          'Damaged',
        ]),
        F.drop('rhsSideMember', 'RHS Side Member', [
          'OK',
          'Repaired',
          'Damaged',
        ]),
        F.drop('engineMount', 'Engine Mount', ['OK', 'Worn', 'Damaged']),
        F.drop('headlightSupport', 'Headlamp Support', [
          'OK',
          'Repaired',
          'Damaged',
        ]),
        F.drop('radiatorSupport', 'Radiator Support', [
          'OK',
          'Repaired',
          'Damaged',
        ]),
        F.text(
          'commentsOnRadiator',
          'Comment on Radiator',
          optional: true,
          maxLines: 2,
        ),
        F.drop('lowerCrossMember', 'Lower Cross Member', [
          'OK',
          'Repaired',
          'Damaged',
        ]),
        F.img('additionalImages', 'Optional Images', optional: true),
        F.drop('exhaustSmoke', 'Exhaust Smoke', [
          'Normal',
          'White',
          'Black',
          'Blue',
        ]),
        F.video('exhaustSmokeVideo', 'Exhaust Smoke Video', maxDuration: 10),
        F.text(
          'commentsOnTowing',
          'Comment on Towing',
          optional: true,
          maxLines: 2,
        ),
        F.text(
          'commentsOnOthers',
          'Comment on Others',
          optional: true,
          maxLines: 2,
        ),
      ],
    ),

    // ═══════════════════════════════════════
    // 7. ELECTRICALS
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Electricals',
      icon: Icons.electric_bolt,
      fields: [
        F.img(
          'meterConsoleWithEngineOnImages',
          'Cluster Meter (With Engine Running)',
        ),
        F.num('odometerReadingInKms', 'Odometer Reading'),
        F.text('fuelLevel', 'Fuel Level'),
        F.text(
          'commentsOnClusterMeter',
          'Comment on Cluster Meter',
          optional: true,
          maxLines: 2,
        ),
        F.drop('irvm', 'IRVM', ['OK', 'Broken', 'Missing']),
        F.drop('dashboard', 'Dashboard', ['OK', 'Scratch', 'Crack', 'Damaged']),
        F.drop('infotainmentSystem', 'Infotainment System', [
          'Working',
          'Not Working',
          'Not Available',
        ]),
        F.drop('inbuiltSpeaker', 'Inbuilt Speaker', [
          'OK',
          'Not Working',
          'Not Available',
        ]),
        F.drop('externalSpeaker', 'External Speaker', [
          'OK',
          'Not Working',
          'N/A',
        ]),
        F.drop(
          'steeringMountedAudioControl',
          'Steering Mounted Audio Controls',
          ['Working', 'Not Working', 'Not Available'],
        ),
        F.drop(
          'steeringMountedSystemControls',
          'Steering Mounted System Controls',
          ['Working', 'Not Working', 'Not Available'],
        ),
        F.drop('acType', 'AC Type', ['Manual', 'Climate Control', 'Dual Zone']),
        F.drop('acCooling', 'AC Cooling', [
          'Good',
          'Average',
          'Poor',
          'Not Working',
        ]),
        F.text('commentsOnAC', 'Comment on AC', optional: true, maxLines: 2),
        F.img('acImages', 'AC Image'),
        F.drop('rearDefogger', 'Rear Defogger', [
          'Working',
          'Not Working',
          'Not Available',
        ]),
        F.drop('rearWiperWasher', 'Rear Wiper & Washer', [
          'Working',
          'Not Working',
          'Not Available',
          'Not Applicable',
        ]),
        F.img('rearWiperAndWasherImages', 'Rear Wiper & Washer Image'),
        F.drop('reverseCamera', 'Reverse Camera', [
          'Working',
          'Not Working',
          'Not Available',
          'Not Applicable',
        ]),
        F.img('reverseCameraImages', 'Reverse Camera Image'),
        F.drop('sunroof', 'Sunroof', ['Yes', 'No', 'Jammed', 'Not Applicable']),
        F.img('sunroofImages', 'Sunroof Image'),
        F.drop('noOfPowerWindows', 'Number of Power Windows', [
          'Not Applicable',
          '1',
          '2',
          '4',
          '6',
          '7',
          '8',
          '9',
          '10',
          '12',
        ]),
        F.drop('powerWindowConditionRhsFront', 'Driver Door Features', [
          'Power Window',
          'Central Lock',
          'Manual',
        ]),
        F.drop('powerWindowConditionLhsFront', 'Co-Driver Door Features', [
          'Power Window',
          'Central Lock',
          'Manual',
        ]),
        F.drop('powerWindowConditionRhsRear', 'RHS Rear Door Features', [
          'Power Window',
          'Central Lock',
          'Manual',
        ]),
        F.drop('powerWindowConditionLhsRear', 'LHS Rear Door Features', [
          'Power Window',
          'Central Lock',
          'Manual',
        ]),
      ],
    ),

    // ═══════════════════════════════════════
    // 8. INTERIOR
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Interior',
      icon: Icons.airline_seat_recline_extra,
      fields: [
        F.drop('noOfAirBags', 'Number of Airbags', [
          'Not Applicable',
          '1',
          '2',
          '4',
          '6',
          '7',
          '8',
          '9',
          '10',
          '12',
        ]),
        F.drop('airbagFeaturesDriverSide', 'Driver Airbag', [
          'Present',
          'Not Present',
          'Deployed',
          'Not Applicable',
        ]),
        F.img('airbagImages', 'Driver Airbag Image', optional: true),
        F.drop('airbagFeaturesCoDriverSide', 'Co-Driver Airbag', [
          'Present',
          'Not Present',
          'Deployed',
          'Not Applicable',
        ]),
        F.img('coDriverAirbagImages', 'Co-Driver Airbag Image', optional: true),
        F.drop('driverSeatAirbag', 'Driver Seat Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'driverSeatAirbagImages',
          'Driver Seat Airbag Image',
          optional: true,
        ),
        F.drop('coDriverSeatAirbag', 'Co-Driver Seat Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'coDriverSeatAirbagImages',
          'Co-Driver Seat Airbag Image',
          optional: true,
        ),
        F.drop('rhsCurtainAirbag', 'RHS Curtain Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'rhsCurtainAirbagImages',
          'RHS Curtain Airbag Image',
          optional: true,
        ),
        F.drop('lhsCurtainAirbag', 'LHS Curtain Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'lhsCurtainAirbagImages',
          'LHS Curtain Airbag Image',
          optional: true,
        ),
        F.drop('driverSideKneeAirbag', 'Driver Knee Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'driverKneeAirbagImages',
          'Driver Knee Airbag Image',
          optional: true,
        ),
        F.drop('coDriverKneeSeatAirbag', 'Co-Driver Knee Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'coDriverKneeAirbagImages',
          'Co-Driver Knee Airbag Image',
          optional: true,
        ),
        F.drop('rhsRearSideAirbag', 'RHS Rear Side Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'rhsRearSideAirbagImages',
          'RHS Rear Side Airbag Image',
          optional: true,
        ),
        F.drop('lhsRearSideAirbag', 'LHS Rear Side Airbag', [
          'Present',
          'Not Present',
          'Not Applicable',
        ]),
        F.img(
          'lhsRearSideAirbagImages',
          'LHS Rear Side Airbag Image',
          optional: true,
        ),
        F.drop('seatsUpholstery', 'Seat Upholstery', [
          'Fabric',
          'Leather',
          'Synthetic',
          'Mixed',
        ]),
        F.drop('driverSeat', 'Driver Seat', ['OK', 'Torn', 'Stained', 'Worn']),
        F.drop('coDriverSeat', 'Co-Driver Seat', [
          'OK',
          'Torn',
          'Stained',
          'Worn',
        ]),
        F.drop('frontCentreArmRest', 'Front Centre Arm Rest', [
          'Present',
          'Not Present',
          'Damaged',
        ]),
        F.drop('rearSeats', 'Rear Seats', ['OK', 'Stained', 'Torn', 'Worn']),
        F.drop('thirdRowSeats', 'Third Row Seats', [
          'Present',
          'Not Applicable',
          'Damaged',
        ]),
        F.img(
          'frontSeatsFromDriverSideImages',
          'Front Seat from Driver Side (Door Open)',
        ),
        F.img(
          'rearSeatsFromRightSideImages',
          'Rear Seat from Right Side (Door Open)',
        ),
        F.img('dashboardImages', 'Dashboard from Rear Seat'),
        F.text(
          'commentOnInterior',
          'Comment on Interior',
          optional: true,
          maxLines: 3,
        ),
      ],
    ),

    // ═══════════════════════════════════════
    // 9. STEERING, SUSPENSION & BRAKES
    // ═══════════════════════════════════════
    FormSectionDef(
      title: 'Steering, Suspension & Brakes',
      icon: Icons.settings,
      fields: [
        F.drop('steering', 'Steering', [
          'OK',
          'Hard',
          'Noise',
          'Vibration',
          'Play',
        ]),
        F.drop('clutch', 'Clutch', ['OK', 'Hard', 'Slipping', 'Deep', 'Noise']),
        F.drop('gearShift', 'Gear Shift', ['OK', 'Hard', 'Noise', 'Jumping']),
        F.drop('transmissionType', 'Transmission Type', [
          'Manual',
          'Automatic',
          'AMT',
          'CVT',
          'DCT',
        ]),
        F.drop('driveTrain', 'Drive Train', ['FWD', 'RWD', 'AWD', '4WD']),
        F.text(
          'commentsOnTransmission',
          'Comment on Transmission',
          optional: true,
          maxLines: 2,
        ),
        F.drop('brakes', 'Brakes', [
          'OK',
          'Spongy',
          'Noise',
          'Weak',
          'Pulling',
        ]),
        F.drop('suspension', 'Suspension', ['OK', 'Noise', 'Weak', 'Leaking']),
        F.num(
          'odometerReadingAfterTestDriveInKms',
          'Odometer Reading after Test Drive',
        ),
        F.img(
          'odometerReadingAfterTestDriveImages',
          'Odometer Reading after Test Drive Image',
        ),
      ],
    ),
  ];
}
