class InspectionFormModel {
  String id;
  String appointmentId;
  String make;
  String model;
  String variant;
  String status;

  // Dynamic map to hold all other fields to avoid massive boilerplate
  // while allowing flexibility for the form fields
  Map<String, dynamic> data;

  InspectionFormModel({
    required this.id,
    required this.appointmentId,
    required this.make,
    required this.model,
    required this.variant,
    required this.status,
    required this.data,
  });

  factory InspectionFormModel.fromJson(Map<String, dynamic> json) {
    return InspectionFormModel(
      id: json['_id'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      variant: json['variant'] ?? '',
      status: json['status'] ?? '',
      data: json,
    );
  }

  Map<String, dynamic> toJson() {
    // Return the original data map updated with any changes
    final map = Map<String, dynamic>.from(data);
    map['_id'] = id;
    map['appointmentId'] = appointmentId;
    // ... update other core fields if they changed
    return map;
  }

  // Helpers to get/set values safely
  String getString(String key) => data[key]?.toString() ?? '';
  void setString(String key, String value) => data[key] = value;

  List<String> getList(String key) {
    var list = data[key];
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }
}
