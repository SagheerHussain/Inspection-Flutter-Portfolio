import 'package:flutter/material.dart';
import '../models/car_model.dart';

/// Prints every CarModel field in the format:
/// fieldName (model field) = value (user input) = Form Label | Condition: ...
void printCarModelDebug(CarModel m) {
  debugPrint('');
  debugPrint('╔══════════════════════════════════════════════════════════╗');
  debugPrint('║           CAR MODEL DEBUG OUTPUT                        ║');
  debugPrint('╚══════════════════════════════════════════════════════════╝');
  debugPrint('');

  // Helper
  void p(
    String field,
    dynamic value,
    String label, [
    String condition = 'Direct mapping',
  ]) {
    final v = value is List ? value.join(', ') : (value?.toString() ?? '');
    debugPrint(
      '$field (model field) = $v (user input) = $label | Condition: $condition',
    );
  }

  // ═══════════════════════════════════════════════
  // OLD FIELDS (above ✅ New fields comment)
  // ═══════════════════════════════════════════════
  debugPrint('────────── OLD MODEL FIELDS ──────────');
  p('id', m.id, 'Document ID');
  p(
    'timestamp',
    m.timestamp?.toIso8601String() ?? '',
    'Timestamp',
    'Auto-generated at submit time',
  );
  p(
    'emailAddress',
    m.emailAddress,
    'IE Name',
    'RENAMED to ieName → same data goes to both fields',
  );
  p('appointmentId', m.appointmentId, 'Appointment ID');
  p(
    'city',
    m.city,
    'City',
    'RENAMED to inspectionCity → same data goes to both fields',
  );
  p(
    'registrationType',
    m.registrationType,
    'Registration Type',
    'REMOVED → still sent as empty/value',
  );
  p(
    'rcBookAvailability',
    m.rcBookAvailability,
    'RC Book Availability',
    'CHANGED to rcBookAvailabilityDropdownList → String gets value, List gets [value]',
  );
  p('rcCondition', m.rcCondition, 'RC Condition');
  p('registrationNumber', m.registrationNumber, 'Registration Number');
  p(
    'registrationDate',
    m.registrationDate?.toIso8601String() ?? '',
    'Registration Date',
  );
  p(
    'fitnessTill',
    m.fitnessTill?.toIso8601String() ?? '',
    'Fitness Validity',
    'RENAMED to fitnessValidity → same data goes to both fields',
  );
  p('toBeScrapped', m.toBeScrapped, 'To Be Scrapped');
  p('registrationState', m.registrationState, 'Registration State');
  p('registeredRto', m.registeredRto, 'Registered RTO');
  p('ownerSerialNumber', m.ownerSerialNumber, 'Ownership Serial No');
  p('make', m.make, 'Make');
  p('model', m.model, 'Model');
  p('variant', m.variant, 'Variant');
  p('engineNumber', m.engineNumber, 'Engine Number');
  p('chassisNumber', m.chassisNumber, 'Chassis Number');
  p('registeredOwner', m.registeredOwner, 'Registered Owner');
  p(
    'registeredAddressAsPerRc',
    m.registeredAddressAsPerRc,
    'Registered Address as per RC',
  );
  p(
    'yearMonthOfManufacture',
    m.yearMonthOfManufacture?.toIso8601String() ?? '',
    'Vehicle Manufacture',
    'RENAMED to yearAndMonthOfManufacture → same data goes to both fields',
  );
  p('fuelType', m.fuelType, 'Fuel Type');
  p('cubicCapacity', m.cubicCapacity, 'Cubic Capacity');
  p('hypothecationDetails', m.hypothecationDetails, 'Hypothecation Details');
  p(
    'mismatchInRc',
    m.mismatchInRc,
    'Mismatch in RC',
    'CHANGED to mismatchInRcDropdownList → String gets value, List gets [value]',
  );
  p('roadTaxValidity', m.roadTaxValidity, 'Road Tax Validity');
  p('taxValidTill', m.taxValidTill?.toIso8601String() ?? '', 'Tax Valid Till');
  p(
    'insurance',
    m.insurance,
    'Insurance Type',
    'CHANGED to insuranceDropdownList → String gets value, List gets [value]',
  );
  p(
    'insurancePolicyNumber',
    m.insurancePolicyNumber,
    'Policy Number',
    'RENAMED to policyNumber → same data goes to both fields',
  );
  p(
    'insuranceValidity',
    m.insuranceValidity?.toIso8601String() ?? '',
    'Insurance Validity',
  );
  p(
    'noClaimBonus',
    m.noClaimBonus,
    'No Claim Bonus',
    'REMOVED → still sent (empty or value)',
  );
  p(
    'mismatchInInsurance',
    m.mismatchInInsurance,
    'Mismatch In Insurance',
    'CHANGED to mismatchInInsuranceDropdownList → String gets value, List gets [value]',
  );
  p('duplicateKey', m.duplicateKey, 'Duplicate Key');
  p('rtoNoc', m.rtoNoc, 'RTO NOC Details');
  p('rtoForm28', m.rtoForm28, 'RTO Form 28');
  p('partyPeshi', m.partyPeshi, 'Party Peshi');
  p(
    'additionalDetails',
    m.additionalDetails,
    'Additional Details',
    'CHANGED to additionalDetailsDropdownList → String gets value, List gets [value]',
  );
  p(
    'rcTaxToken',
    m.rcTaxToken,
    'RC Token Image',
    'RENAMED to rcTokenImages → same data goes to both fields',
  );
  p(
    'insuranceCopy',
    m.insuranceCopy,
    'Insurance Image',
    'RENAMED to insuranceImages → same data goes to both fields',
  );
  p(
    'bothKeys',
    m.bothKeys,
    'Duplicate Key Images',
    'RENAMED to duplicateKeyImages → same data goes to both fields',
  );
  p(
    'form26GdCopyIfRcIsLost',
    m.form26GdCopyIfRcIsLost,
    'Form 26 GD Copy',
    'RENAMED to form26AndGdCopyIfRcIsLostImages → same data goes to both fields',
  );

  debugPrint('');
  debugPrint('────────── EXTERIOR OLD FIELDS ──────────');
  p(
    'bonnet',
    m.bonnet,
    'Bonnet',
    'CHANGED to bonnetDropdownList → String gets value, List gets [value]',
  );
  p(
    'frontWindshield',
    m.frontWindshield,
    'Front Windshield',
    'CHANGED to frontWindshieldDropdownList',
  );
  p('roof', m.roof, 'Roof', 'CHANGED to roofDropdownList');
  p(
    'frontBumper',
    m.frontBumper,
    'Front Bumper',
    'CHANGED to frontBumperDropdownList',
  );
  p(
    'lhsHeadlamp',
    m.lhsHeadlamp,
    'LHS Headlamp',
    'CHANGED to lhsHeadlampDropdownList',
  );
  p(
    'lhsFoglamp',
    m.lhsFoglamp,
    'LHS Foglamp',
    'CHANGED to lhsFoglampDropdownList',
  );
  p(
    'rhsHeadlamp',
    m.rhsHeadlamp,
    'RHS Headlamp',
    'CHANGED to rhsHeadlampDropdownList',
  );
  p(
    'rhsFoglamp',
    m.rhsFoglamp,
    'RHS Foglamp',
    'CHANGED to rhsFoglampDropdownList',
  );
  p('lhsFender', m.lhsFender, 'LHS Fender', 'CHANGED to lhsFenderDropdownList');
  p('lhsOrvm', m.lhsOrvm, 'LHS ORVM', 'CHANGED to lhsOrvmDropdownList');
  p(
    'lhsAPillar',
    m.lhsAPillar,
    'LHS A Pillar',
    'CHANGED to lhsAPillarDropdownList',
  );
  p(
    'lhsBPillar',
    m.lhsBPillar,
    'LHS B Pillar',
    'CHANGED to lhsBPillarDropdownList',
  );
  p(
    'lhsCPillar',
    m.lhsCPillar,
    'LHS C Pillar',
    'CHANGED to lhsCPillarDropdownList',
  );
  p(
    'lhsFrontAlloy',
    m.lhsFrontAlloy,
    'LHS Front Wheel',
    'RENAMED to lhsFrontWheelDropdownList',
  );
  p(
    'lhsFrontTyre',
    m.lhsFrontTyre,
    'LHS Front Tyre',
    'CHANGED to lhsFrontTyreDropdownList',
  );
  p(
    'lhsRearAlloy',
    m.lhsRearAlloy,
    'LHS Rear Wheel',
    'RENAMED to lhsRearWheelDropdownList',
  );
  p(
    'lhsRearTyre',
    m.lhsRearTyre,
    'LHS Rear Tyre',
    'CHANGED to lhsRearTyreDropdownList',
  );
  p(
    'lhsFrontDoor',
    m.lhsFrontDoor,
    'LHS Front Door',
    'CHANGED to lhsFrontDoorDropdownList',
  );
  p(
    'lhsRearDoor',
    m.lhsRearDoor,
    'LHS Rear Door',
    'CHANGED to lhsRearDoorDropdownList',
  );
  p(
    'lhsRunningBorder',
    m.lhsRunningBorder,
    'LHS Running Border',
    'CHANGED to lhsRunningBorderDropdownList',
  );
  p(
    'lhsQuarterPanel',
    m.lhsQuarterPanel,
    'LHS Quarter Panel',
    'CHANGED to lhsQuarterPanelDropdownList',
  );
  p(
    'rearBumper',
    m.rearBumper,
    'Rear Bumper',
    'CHANGED to rearBumperDropdownList',
  );
  p(
    'lhsTailLamp',
    m.lhsTailLamp,
    'LHS Tail Lamp',
    'CHANGED to lhsTailLampDropdownList',
  );
  p(
    'rhsTailLamp',
    m.rhsTailLamp,
    'RHS Tail Lamp',
    'CHANGED to rhsTailLampDropdownList',
  );
  p(
    'rearWindshield',
    m.rearWindshield,
    'Rear Windshield',
    'CHANGED to rearWindshieldDropdownList',
  );
  p('bootDoor', m.bootDoor, 'Boot Door', 'CHANGED to bootDoorDropdownList');
  p('spareTyre', m.spareTyre, 'Spare Tyre', 'CHANGED to spareTyreDropdownList');
  p('bootFloor', m.bootFloor, 'Boot Floor', 'CHANGED to bootFloorDropdownList');
  p(
    'rhsRearAlloy',
    m.rhsRearAlloy,
    'RHS Rear Wheel',
    'RENAMED to rhsRearWheelDropdownList',
  );
  p(
    'rhsRearTyre',
    m.rhsRearTyre,
    'RHS Rear Tyre',
    'CHANGED to rhsRearTyreDropdownList',
  );
  p(
    'rhsFrontAlloy',
    m.rhsFrontAlloy,
    'RHS Front Wheel',
    'RENAMED to rhsFrontWheelDropdownList',
  );
  p(
    'rhsFrontTyre',
    m.rhsFrontTyre,
    'RHS Front Tyre',
    'CHANGED to rhsFrontTyreDropdownList',
  );
  p(
    'rhsQuarterPanel',
    m.rhsQuarterPanel,
    'RHS Quarter Panel',
    'CHANGED to rhsQuarterPanelDropdownList',
  );
  p(
    'rhsAPillar',
    m.rhsAPillar,
    'RHS A Pillar',
    'CHANGED to rhsAPillarDropdownList',
  );
  p(
    'rhsBPillar',
    m.rhsBPillar,
    'RHS B Pillar',
    'CHANGED to rhsBPillarDropdownList',
  );
  p(
    'rhsCPillar',
    m.rhsCPillar,
    'RHS C Pillar',
    'CHANGED to rhsCPillarDropdownList',
  );
  p(
    'rhsRunningBorder',
    m.rhsRunningBorder,
    'RHS Running Border',
    'CHANGED to rhsRunningBorderDropdownList',
  );
  p(
    'rhsRearDoor',
    m.rhsRearDoor,
    'RHS Rear Door',
    'CHANGED to rhsRearDoorDropdownList',
  );
  p(
    'rhsFrontDoor',
    m.rhsFrontDoor,
    'RHS Front Door',
    'CHANGED to rhsFrontDoorDropdownList',
  );
  p('rhsOrvm', m.rhsOrvm, 'RHS ORVM', 'CHANGED to rhsOrvmDropdownList');
  p('rhsFender', m.rhsFender, 'RHS Fender', 'CHANGED to rhsFenderDropdownList');
  p(
    'comments',
    m.comments,
    'Comments on Exterior',
    'RENAMED to commentsOnExteriorDropdownList',
  );

  debugPrint('');
  debugPrint('────────── EXTERIOR IMAGE OLD FIELDS ──────────');
  p('frontMain', m.frontMain, 'Front Main', 'CHANGED to frontMainImages');
  p(
    'bonnetImages',
    m.bonnetImages,
    'Bonnet Image',
    'DIVIDED into bonnetClosedImages, bonnetOpenImages and bonnetImages',
  );
  p('frontWindshieldImages', m.frontWindshieldImages, 'Front Windshield Image');
  p('roofImages', m.roofImages, 'Roof Image');
  p(
    'frontBumperImages',
    m.frontBumperImages,
    'Front Bumper Image',
    'DIVIDED into frontBumperLhs45DegreeImages, frontBumperRhs45DegreeImages, frontBumperImages',
  );
  p('lhsHeadlampImages', m.lhsHeadlampImages, 'LHS Headlamp Image');
  p('lhsFoglampImages', m.lhsFoglampImages, 'LHS Foglamp Image');
  p('rhsHeadlampImages', m.rhsHeadlampImages, 'RHS Headlamp Image');
  p('rhsFoglampImages', m.rhsFoglampImages, 'RHS Foglamp Image');
  p(
    'lhsFront45Degree',
    m.lhsFront45Degree,
    'LHS Full View',
    'RENAMED to lhsFullViewImages',
  );
  p('lhsFenderImages', m.lhsFenderImages, 'LHS Fender Image');
  p(
    'lhsFrontAlloyImages',
    m.lhsFrontAlloyImages,
    'LHS Front Wheel Image',
    'RENAMED to lhsFrontWheelImages',
  );
  p('lhsFrontTyreImages', m.lhsFrontTyreImages, 'LHS Front Tyre Image');
  p(
    'lhsRunningBorderImages',
    m.lhsRunningBorderImages,
    'LHS Running Border Image',
  );
  p('lhsOrvmImages', m.lhsOrvmImages, 'LHS ORVM Image');
  p('lhsAPillarImages', m.lhsAPillarImages, 'LHS A Pillar Image');
  p('lhsFrontDoorImages', m.lhsFrontDoorImages, 'LHS Front Door Image');
  p('lhsBPillarImages', m.lhsBPillarImages, 'LHS B Pillar Image');
  p('lhsRearDoorImages', m.lhsRearDoorImages, 'LHS Rear Door Image');
  p('lhsCPillarImages', m.lhsCPillarImages, 'LHS C Pillar Image');
  p('lhsRearTyreImages', m.lhsRearTyreImages, 'LHS Rear Tyre Image');
  p(
    'lhsRearAlloyImages',
    m.lhsRearAlloyImages,
    'LHS Rear Wheel Image',
    'RENAMED to lhsRearWheelImages',
  );
  p(
    'lhsQuarterPanelImages',
    m.lhsQuarterPanelImages,
    'LHS Quarter Panel Image',
    'DIVIDED into lhsQuarterPanelWithRearDoorOpenImages and lhsQuarterPanelImages',
  );
  p('rearMain', m.rearMain, 'Rear Main', 'RENAMED to rearMainImages');
  p(
    'rearWithBootDoorOpen',
    m.rearWithBootDoorOpen,
    'Rear With Boot Door Open',
    'RENAMED to rearWithBootDoorOpenImages',
  );
  p(
    'rearBumperImages',
    m.rearBumperImages,
    'Rear Bumper Image',
    'DIVIDED into rearBumperLhs45DegreeImages, rearBumperRhs45DegreeImages, rearBumperImages',
  );
  p('lhsTailLampImages', m.lhsTailLampImages, 'LHS Tail Lamp Image');
  p('rhsTailLampImages', m.rhsTailLampImages, 'RHS Tail Lamp Image');
  p('rearWindshieldImages', m.rearWindshieldImages, 'Rear Windshield Image');
  p('bootDoorImages', m.bootDoorImages, 'Boot Door Image', 'NEW: bootDoorImages field');
  p('spareTyreImages', m.spareTyreImages, 'Spare Tyre Image');
  p('bootFloorImages', m.bootFloorImages, 'Boot Floor Image');
  p(
    'rhsRear45Degree',
    m.rhsRear45Degree,
    'RHS Full View',
    'RENAMED to rhsFullViewImages',
  );
  p(
    'rhsQuarterPanelImages',
    m.rhsQuarterPanelImages,
    'RHS Quarter Panel Image',
    'DIVIDED into rhsQuarterPanelWithRearDoorOpenImages and rhsQuarterPanelImages',
  );
  p(
    'rhsRearAlloyImages',
    m.rhsRearAlloyImages,
    'RHS Rear Wheel Image',
    'RENAMED to rhsRearWheelImages',
  );
  p('rhsRearTyreImages', m.rhsRearTyreImages, 'RHS Rear Tyre Image');
  p('rhsCPillarImages', m.rhsCPillarImages, 'RHS C Pillar Image');
  p('rhsRearDoorImages', m.rhsRearDoorImages, 'RHS Rear Door Image');
  p('rhsBPillarImages', m.rhsBPillarImages, 'RHS B Pillar Image');
  p('rhsFrontDoorImages', m.rhsFrontDoorImages, 'RHS Front Door Image');
  p('rhsAPillarImages', m.rhsAPillarImages, 'RHS A Pillar Image');
  p(
    'rhsRunningBorderImages',
    m.rhsRunningBorderImages,
    'RHS Running Border Image',
  );
  p(
    'rhsFrontAlloyImages',
    m.rhsFrontAlloyImages,
    'RHS Front Wheel Image',
    'RENAMED to rhsFrontWheelImages',
  );
  p('rhsFrontTyreImages', m.rhsFrontTyreImages, 'RHS Front Tyre Image');
  p('rhsOrvmImages', m.rhsOrvmImages, 'RHS ORVM Image');
  p('rhsFenderImages', m.rhsFenderImages, 'RHS Fender Image');

  debugPrint('');
  debugPrint('────────── ENGINE OLD FIELDS ──────────');
  p(
    'upperCrossMember',
    m.upperCrossMember,
    'Upper Cross Member',
    'CHANGED to upperCrossMemberDropdownList',
  );
  p(
    'radiatorSupport',
    m.radiatorSupport,
    'Radiator Support',
    'CHANGED to radiatorSupportDropdownList',
  );
  p(
    'headlightSupport',
    m.headlightSupport,
    'Headlamp Support',
    'CHANGED to headlightSupportDropdownList',
  );
  p(
    'lowerCrossMember',
    m.lowerCrossMember,
    'Lower Cross Member',
    'CHANGED to lowerCrossMemberDropdownList',
  );
  p('lhsApron', m.lhsApron, 'LHS Apron', 'CHANGED to lhsApronDropdownList');
  p('rhsApron', m.rhsApron, 'RHS Apron', 'CHANGED to rhsApronDropdownList');
  p('firewall', m.firewall, 'Firewall', 'CHANGED to firewallDropdownList');
  p('cowlTop', m.cowlTop, 'Cowl Top', 'CHANGED to cowlTopDropdownList');
  p('engine', m.engine, 'Engine', 'CHANGED to engineDropdownList');
  p('battery', m.battery, 'Battery', 'CHANGED to batteryDropdownList');
  p('coolant', m.coolant, 'Coolant', 'CHANGED to coolantDropdownList');
  p(
    'engineOilLevelDipstick',
    m.engineOilLevelDipstick,
    'Engine Oil Level Dipstick',
    'CHANGED to engineOilLevelDipstickDropdownList',
  );
  p('engineOil', m.engineOil, 'Engine Oil', 'CHANGED to engineOilDropdownList');
  p(
    'engineMount',
    m.engineMount,
    'Engine Mount',
    'CHANGED to engineMountDropdownList',
  );
  p(
    'enginePermisableBlowBy',
    m.enginePermisableBlowBy,
    'Engine Permisable Blowby',
    'CHANGED to enginePermisableBlowByDropdownList',
  );
  p(
    'exhaustSmoke',
    m.exhaustSmoke,
    'Exhaust Smoke',
    'CHANGED to exhaustSmokeDropdownList',
  );
  p('clutch', m.clutch, 'Clutch', 'CHANGED to clutchDropdownList');
  p('gearShift', m.gearShift, 'Gear Shift', 'CHANGED to gearShiftDropdownList');
  p(
    'commentsOnEngine',
    m.commentsOnEngine,
    'Comment on Engine',
    'CHANGED to commentsOnEngineDropdownList',
  );
  p(
    'commentsOnEngineOil',
    m.commentsOnEngineOil,
    'Comment on Engine Oil',
    'CHANGED to commentsOnEngineOilDropdownList',
  );
  p(
    'commentsOnTowing',
    m.commentsOnTowing,
    'Comment on Towing',
    'CHANGED to commentsOnTowingDropdownList',
  );
  p(
    'commentsOnTransmission',
    m.commentsOnTransmission,
    'Comment on Transmission',
    'CHANGED to commentsOnTransmissionDropdownList',
  );
  p(
    'commentsOnRadiator',
    m.commentsOnRadiator,
    'Comment on Radiator',
    'CHANGED to commentsOnRadiatorDropdownList',
  );
  p(
    'commentsOnOthers',
    m.commentsOnOthers,
    'Comment on Others',
    'CHANGED to commentsOnOthersDropdownList',
  );
  p('engineBay', m.engineBay, 'Engine Bay', 'RENAMED to engineBayImages');
  p(
    'apronLhsRhs',
    m.apronLhsRhs,
    'Apron LHS/RHS',
    'REMOVED AND DIVIDED into lhsApronImages and rhsApronImages → data merged from both',
  );
  p('batteryImages', m.batteryImages, 'Battery Image');
  p(
    'additionalImages',
    m.additionalImages,
    'Optional Engine Images',
    'RENAMED to additionalEngineImages',
  );
  p(
    'engineSound',
    m.engineSound,
    'Engine Sound Video',
    'RENAMED to engineVideo',
  );
  p(
    'exhaustSmokeImages',
    m.exhaustSmokeImages,
    'Exhaust Smoke Video',
    'RENAMED to exhaustSmokeVideo',
  );

  debugPrint('');
  debugPrint('────────── ELECTRICAL/INTERIOR OLD FIELDS ──────────');
  p('steering', m.steering, 'Steering', 'CHANGED to steeringDropdownList');
  p('brakes', m.brakes, 'Brakes', 'CHANGED to brakesDropdownList');
  p(
    'suspension',
    m.suspension,
    'Suspension',
    'CHANGED to suspensionDropdownList',
  );
  p(
    'odometerReadingInKms',
    m.odometerReadingInKms,
    'Odometer Reading',
    'RENAMED to odometerReadingBeforeTestDrive',
  );
  p('fuelLevel', m.fuelLevel, 'Fuel Level');
  p('abs', m.abs, 'ABS');
  p(
    'electricals',
    m.electricals,
    'Electricals',
    'REMOVED → still sent as empty',
  );
  p(
    'rearWiperWasher',
    m.rearWiperWasher,
    'Rear Wiper & Washer',
    'CHANGED to rearWiperWasherDropdownList',
  );
  p(
    'rearDefogger',
    m.rearDefogger,
    'Rear Defogger',
    'CHANGED to rearDefoggerDropdownList',
  );
  p(
    'musicSystem',
    m.musicSystem,
    'Infotainment System',
    'REMOVED AND MERGED into infotainmentSystemDropdownList → comma-sep in String, list in List',
  );
  p(
    'stereo',
    m.stereo,
    'Stereo',
    'REMOVED AND MERGED into infotainmentSystemDropdownList',
  );
  p('inbuiltSpeaker', m.inbuiltSpeaker, 'Inbuilt Speaker');
  p('externalSpeaker', m.externalSpeaker, 'External Speaker');
  p(
    'steeringMountedAudioControl',
    m.steeringMountedAudioControl,
    'Steering Mounted Audio Controls',
    'REMOVED AND DIVIDED into steeringMountedMediaControls and steeringMountedSystemControls',
  );
  p('noOfPowerWindows', m.noOfPowerWindows, 'Number of Power Windows');
  p(
    'powerWindowConditionRhsFront',
    m.powerWindowConditionRhsFront,
    'Driver Door Features',
    'RENAMED to rhsFrontDoorFeaturesDropdownList',
  );
  p(
    'powerWindowConditionLhsFront',
    m.powerWindowConditionLhsFront,
    'Co-Driver Door Features',
    'RENAMED to lhsFrontDoorFeaturesDropdownList',
  );
  p(
    'powerWindowConditionRhsRear',
    m.powerWindowConditionRhsRear,
    'RHS Rear Door Features',
    'RENAMED to rhsRearDoorFeaturesDropdownList',
  );
  p(
    'powerWindowConditionLhsRear',
    m.powerWindowConditionLhsRear,
    'LHS Rear Door Features',
    'RENAMED to lhsRearDoorFeaturesDropdownList',
  );
  p(
    'commentOnInterior',
    m.commentOnInterior,
    'Comment on Interior',
    'CHANGED to commentOnInteriorDropdownList',
  );
  p('noOfAirBags', m.noOfAirBags, 'Number of Airbags');
  p(
    'airbagFeaturesDriverSide',
    m.airbagFeaturesDriverSide,
    'Driver Airbag',
    'RENAMED to driverAirbag',
  );
  p(
    'airbagFeaturesCoDriverSide',
    m.airbagFeaturesCoDriverSide,
    'Co-Driver Airbag',
    'RENAMED to coDriverAirbag',
  );
  p(
    'airbagFeaturesLhsAPillarCurtain',
    m.airbagFeaturesLhsAPillarCurtain,
    'Co-Driver Seat Airbag',
    'RENAMED to coDriverSeatAirbag',
  );
  p(
    'airbagFeaturesLhsBPillarCurtain',
    m.airbagFeaturesLhsBPillarCurtain,
    'LHS Curtain Airbag',
    'RENAMED to lhsCurtainAirbag',
  );
  p(
    'airbagFeaturesLhsCPillarCurtain',
    m.airbagFeaturesLhsCPillarCurtain,
    'LHS Rear Side Airbag',
    'RENAMED to lhsRearSideAirbag',
  );
  p(
    'airbagFeaturesRhsAPillarCurtain',
    m.airbagFeaturesRhsAPillarCurtain,
    'Driver Seat Airbag',
    'RENAMED to driverSeatAirbag',
  );
  p(
    'airbagFeaturesRhsBPillarCurtain',
    m.airbagFeaturesRhsBPillarCurtain,
    'RHS Curtain Airbag',
    'RENAMED to rhsCurtainAirbag',
  );
  p(
    'airbagFeaturesRhsCPillarCurtain',
    m.airbagFeaturesRhsCPillarCurtain,
    'RHS Rear Side Airbag',
    'RENAMED to rhsRearSideAirbag',
  );
  p('sunroof', m.sunroof, 'Sunroof', 'CHANGED to sunroofDropdownList');
  p(
    'leatherSeats',
    m.leatherSeats,
    'Leather Seats',
    'REMOVED AND MERGED to seatsUpholstery',
  );
  p(
    'fabricSeats',
    m.fabricSeats,
    'Fabric Seats',
    'REMOVED AND MERGED to seatsUpholstery',
  );
  p(
    'commentsOnElectricals',
    m.commentsOnElectricals,
    'Comments on Electricals',
    'REMOVED → still sent as empty',
  );
  p(
    'meterConsoleWithEngineOn',
    m.meterConsoleWithEngineOn,
    'Cluster Meter Image',
    'RENAMED to meterConsoleWithEngineOnImages',
  );
  p('airbags', m.airbags, 'Driver Airbag Image', 'RENAMED to airbagImages');
  p('sunroofImages', m.sunroofImages, 'Sunroof Image');
  p(
    'frontSeatsFromDriverSideDoorOpen',
    m.frontSeatsFromDriverSideDoorOpen,
    'Front Seat from Driver Side',
    'RENAMED to frontSeatsFromDriverSideImages',
  );
  p(
    'rearSeatsFromRightSideDoorOpen',
    m.rearSeatsFromRightSideDoorOpen,
    'Rear Seat from Right Side',
    'RENAMED to rearSeatsFromRightSideImages',
  );
  p(
    'dashboardFromRearSeat',
    m.dashboardFromRearSeat,
    'Dashboard from Rear Seat',
    'RENAMED to dashboardImages',
  );
  p(
    'reverseCamera',
    m.reverseCamera,
    'Reverse Camera',
    'CHANGED to reverseCameraDropdownList',
  );
  p(
    'additionalImages2',
    m.additionalImages2,
    'Additional Interior Images',
    'RENAMED to additionalInteriorImages',
  );
  p(
    'airConditioningManual',
    m.airConditioningManual,
    'AC Type',
    'RENAMED to acTypeDropdownList',
  );
  p(
    'airConditioningClimateControl',
    m.airConditioningClimateControl,
    'AC Cooling',
    'RENAMED to acCoolingDropdownList',
  );
  p('commentsOnAc', m.commentsOnAc, 'Comment on AC');
  p('approvedBy', m.approvedBy, 'Approved By');
  p('approvalDate', m.approvalDate?.toIso8601String() ?? '', 'Approval Date');
  p('approvalTime', m.approvalTime?.toIso8601String() ?? '', 'Approval Time');
  p('approvalStatus', m.approvalStatus, 'Approval Status');
  p('contactNumber', m.contactNumber, 'Contact Number');
  p(
    'newArrivalMessage',
    m.newArrivalMessage?.toIso8601String() ?? '',
    'New Arrival Message',
  );
  p('budgetCar', m.budgetCar, 'Budget Car');
  p('status', m.status, 'Status');
  p('priceDiscovery', m.priceDiscovery, 'Price Discovery');
  p('priceDiscoveryBy', m.priceDiscoveryBy, 'Price Discovery By');
  p('latlong', m.latlong, 'Lat Long');
  p('retailAssociate', m.retailAssociate, 'Retail Associate');
  p('kmRangeLevel', m.kmRangeLevel, 'KM Range Level');
  p('highestBidder', m.highestBidder, 'Highest Bidder');
  p('v', m.v, '__v');

  debugPrint('');
  debugPrint('════════════ ✅ NEW FIELDS (below comment) ════════════');
  p(
    'ieName',
    m.ieName,
    'IE Name',
    'NEW: renamed from emailAddress → same data',
  );
  p(
    'inspectionCity',
    m.inspectionCity,
    'Inspection City',
    'NEW: renamed from city → same data',
  );
  p(
    'rcBookAvailabilityDropdownList',
    m.rcBookAvailabilityDropdownList,
    'RC Book Availability',
    'NEW: changed from rcBookAvailability String→List',
  );
  p(
    'fitnessValidity',
    m.fitnessValidity?.toIso8601String() ?? '',
    'Fitness Validity',
    'NEW: renamed from fitnessTill',
  );
  p(
    'yearAndMonthOfManufacture',
    m.yearAndMonthOfManufacture?.toIso8601String() ?? '',
    'Vehicle Manufacture',
    'NEW: renamed from yearMonthOfManufacture',
  );
  p(
    'mismatchInRcDropdownList',
    m.mismatchInRcDropdownList,
    'Mismatch in RC',
    'NEW: changed from mismatchInRc',
  );
  p(
    'insuranceDropdownList',
    m.insuranceDropdownList,
    'Insurance Type',
    'NEW: changed from insurance',
  );
  p(
    'policyNumber',
    m.policyNumber,
    'Policy Number',
    'NEW: renamed from insurancePolicyNumber',
  );
  p(
    'mismatchInInsuranceDropdownList',
    m.mismatchInInsuranceDropdownList,
    'Mismatch In Insurance',
    'NEW: changed from mismatchInInsurance',
  );
  p(
    'additionalDetailsDropdownList',
    m.additionalDetailsDropdownList,
    'Additional Details',
    'NEW: changed from additionalDetails',
  );
  p(
    'rcTokenImages',
    m.rcTokenImages,
    'RC Token Image',
    'NEW: renamed from rcTaxToken',
  );
  p(
    'insuranceImages',
    m.insuranceImages,
    'Insurance Image',
    'NEW: renamed from insuranceCopy',
  );
  p(
    'duplicateKeyImages',
    m.duplicateKeyImages,
    'Duplicate Key Images',
    'NEW: renamed from bothKeys',
  );
  p(
    'form26AndGdCopyIfRcIsLostImages',
    m.form26AndGdCopyIfRcIsLostImages,
    'Form 26 GD Copy',
    'NEW: renamed from form26GdCopyIfRcIsLost',
  );
  p(
    'seatsUpholstery',
    m.seatsUpholstery,
    'Seat Upholstery',
    'NEW: merged from leatherSeats + fabricSeats',
  );
  p(
    'odometerReadingBeforeTestDrive',
    m.odometerReadingBeforeTestDrive,
    'Odometer Reading',
    'NEW: renamed from odometerReadingInKms',
  );
  p(
    'infotainmentSystemDropdownList',
    m.infotainmentSystemDropdownList,
    'Infotainment System',
    'NEW: merged from musicSystem + stereo',
  );
  p(
    'steeringMountedMediaControls',
    m.steeringMountedMediaControls,
    'Steering Mounted Media Controls',
    'NEW: divided from steeringMountedAudioControl',
  );
  p(
    'steeringMountedSystemControls',
    m.steeringMountedSystemControls,
    'Steering Mounted System Controls',
    'NEW: divided from steeringMountedAudioControl',
  );
  p(
    'acTypeDropdownList',
    m.acTypeDropdownList,
    'AC Type',
    'NEW: renamed from airConditioningManual',
  );
  p(
    'acCoolingDropdownList',
    m.acCoolingDropdownList,
    'AC Cooling',
    'NEW: renamed from airConditioningClimateControl',
  );
  p(
    'driverAirbag',
    m.driverAirbag,
    'Driver Airbag',
    'NEW: renamed from airbagFeaturesDriverSide',
  );
  p(
    'coDriverAirbag',
    m.coDriverAirbag,
    'Co-Driver Airbag',
    'NEW: renamed from airbagFeaturesCoDriverSide',
  );
  p(
    'coDriverSeatAirbag',
    m.coDriverSeatAirbag,
    'Co-Driver Seat Airbag',
    'NEW: renamed from airbagFeaturesLhsAPillarCurtain',
  );
  p(
    'lhsCurtainAirbag',
    m.lhsCurtainAirbag,
    'LHS Curtain Airbag',
    'NEW: renamed from airbagFeaturesLhsBPillarCurtain',
  );
  p(
    'lhsRearSideAirbag',
    m.lhsRearSideAirbag,
    'LHS Rear Side Airbag',
    'NEW: renamed from airbagFeaturesLhsCPillarCurtain',
  );
  p(
    'driverSeatAirbag',
    m.driverSeatAirbag,
    'Driver Seat Airbag',
    'NEW: renamed from airbagFeaturesRhsAPillarCurtain',
  );
  p(
    'rhsCurtainAirbag',
    m.rhsCurtainAirbag,
    'RHS Curtain Airbag',
    'NEW: renamed from airbagFeaturesRhsBPillarCurtain',
  );
  p(
    'rhsRearSideAirbag',
    m.rhsRearSideAirbag,
    'RHS Rear Side Airbag',
    'NEW: renamed from airbagFeaturesRhsCPillarCurtain',
  );

  // Print rest of new fields
  debugPrint('');
  debugPrint('────────── NEW-ONLY FIELDS (Fresh) ──────────');
  p(
    'chassisEmbossmentImages',
    m.chassisEmbossmentImages,
    'Chassis Embossment Image',
    'NEW: Fresh field',
  );
  p('chassisDetails', m.chassisDetails, 'Chassis Details', 'NEW: Fresh field');
  p('vinPlateImages', m.vinPlateImages, 'Vin Plate Image', 'NEW: Fresh field');
  p(
    'vinPlateDetails',
    m.vinPlateDetails,
    'Vin Plate Details',
    'NEW: Fresh field',
  );
  p('roadTaxImages', m.roadTaxImages, 'Road Tax Image', 'NEW: Fresh field');
  p(
    'seatingCapacity',
    m.seatingCapacity,
    'Seating Capacity',
    'NEW: Fresh field',
  );
  p('color', m.color, 'Color', 'NEW: Fresh field');
  p(
    'numberOfCylinders',
    m.numberOfCylinders,
    'Number of Cylinders',
    'NEW: Fresh field',
  );
  p('norms', m.norms, 'Norms', 'NEW: Fresh field');
  p('hypothecatedTo', m.hypothecatedTo, 'Hypothecated To', 'NEW: Fresh field');
  p('insurer', m.insurer, 'Insured By', 'NEW: Fresh field');
  p('pucImages', m.pucImages, 'PUC Image', 'NEW: Fresh field');
  p(
    'pucValidity',
    m.pucValidity?.toIso8601String() ?? '',
    'PUC Validity',
    'NEW: Fresh field',
  );
  p('pucNumber', m.pucNumber, 'PUC Number', 'NEW: Fresh field');
  p('rcStatus', m.rcStatus, 'RC Status', 'NEW: Fresh field');
  p(
    'blacklistStatus',
    m.blacklistStatus,
    'Blacklist Status',
    'NEW: Fresh field',
  );
  p('rtoNocImages', m.rtoNocImages, 'RTO NOC Images', 'NEW: Fresh field');
  p(
    'rtoForm28Images',
    m.rtoForm28Images,
    'RTO Form 28 Images',
    'NEW: Fresh field',
  );
  p('irvm', m.irvm, 'IRVM', 'NEW: Fresh field');
  p(
    'driverSideKneeAirbag',
    m.driverSideKneeAirbag,
    'Driver Knee Airbag',
    'NEW: Fresh field',
  );
  p(
    'coDriverKneeSeatAirbag',
    m.coDriverKneeSeatAirbag,
    'Co-Driver Knee Airbag',
    'NEW: Fresh field',
  );
  p(
    'odometerReadingAfterTestDriveInKms',
    m.odometerReadingAfterTestDriveInKms,
    'Odometer After Test Drive',
    'NEW: Fresh field',
  );
  p(
    'odometerReadingAfterTestDriveImages',
    m.odometerReadingAfterTestDriveImages,
    'Odometer After Test Drive Image',
    'NEW: Fresh field',
  );

  debugPrint('');
  debugPrint('╔══════════════════════════════════════════════════════════╗');
  debugPrint('║           END OF CAR MODEL DEBUG OUTPUT                 ║');
  debugPrint('╚══════════════════════════════════════════════════════════╝');
  debugPrint('');
}
