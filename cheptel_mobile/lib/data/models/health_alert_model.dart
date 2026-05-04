class HealthAlertModel {
  final int id;
  final String alertType;
  final String? message;
  final String dueDate;
  final bool isResolved;
  final String? severity;

  HealthAlertModel({
    required this.id,
    required this.alertType,
    this.message,
    required this.dueDate,
    required this.isResolved,
    this.severity,
  });

  factory HealthAlertModel.fromJson(Map<String, dynamic> json) {
    return HealthAlertModel(
      id: _toInt(json['id']),
      alertType: json['alertType']?.toString() ?? '',
      message: json['message']?.toString(),
      dueDate: json['dueDate']?.toString() ?? '',
      isResolved: json['isResolved'] == true,
      severity: json['severity']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}